/*
This is for the Sabertooth motor controller in Servo mode

serial protocol info:
inputs, no delimiters:
  M - motor commands
    1-9 - directions match keyboard numberpad directions, 5 is STOP
    Example:  "M7" - go forward and left
  D - debug
    0 - none
    1 - ping sensor info
    Example: "D1" - enable ping debug

outputs, ":" delimited for everything, newline terminated
  I - information
    string - textual information
    Example: "I:done!" - startup done
  S - Stop info
    integer - sensor index (0-based)
    integer - distance cm
    Example: "S:2:71" - stop condition, 3rd sensor, at 71cm
  P - power info
    integer - left target
    integer - right target
    integer - left actual
    integer - right actual
    Example: "P:90:90:45:95" - target is 90/90 (stop) current is 45/135 (rotating in place, half speed)
  E - Error
    string - textual information
    Example: "E:Invalid Move" - input something not 1-9 after M
  D - debug info
    P - ping sensors
      integer - sensor index (0-based)
      integer - distance cm
      Example: "D:P:1:123" - debug ping, 2nd sensor at 123cm
    
*/
#include <Servo.h>
#include <NewPing.h>

#define MAX_DISTANCE 300 // Maximum distance we want to ping for (in centimeters). Maximum sensor distance is rated at 400-500cm.
#define MAX_SAFE 40      // max distance that it's OK to move

#define NUM_PINGS 4

enum SonarNames {
  ping0 = 0,
  ping45 = 1,
  ping90 = 2,
  ping135 = 3,
  ping180 = 4
};

NewPing sonar[NUM_PINGS] = {
  NewPing(25, 23, MAX_DISTANCE), // 60 degree
  NewPing(29, 27, MAX_DISTANCE), // 90 degree
  NewPing(33, 31, MAX_DISTANCE), // 120 degree
  NewPing(37, 35, MAX_DISTANCE) // 160 degree
};

uint8_t pingCurrent = 255; //255 means not pinging
volatile uint8_t pingNext = 255;
boolean pingDebug = false;

boolean powerEnable = true;
uint8_t lastTrigger = 255;
uint8_t powerL = 90;
uint8_t powerR = 90;
uint8_t powerLt = 90;
uint8_t powerRt = 90;
uint8_t maxPwr = 45;

//big motor controller uses RC speed control emulation, so treat it like a servo
Servo ST1, ST2; // We'll name the Sabertooth servo channel objects ST1 and ST2.

void setup() {
  Serial.begin(115200);
  Serial.print("I:starting...");
  //Set the 2 main motors up
  ST1.attach(44, 1000, 2000);
  ST2.attach(46, 1000, 2000);

  pingNext = 0;
  
  delay(500);
  Serial.println("I:done!");
}

void loop() 
{
  char cmd;
  if(pingNext < NUM_PINGS) {
    if (pingCurrent < NUM_PINGS) {
      sonar[pingCurrent].timer_stop();
    }
    pingCurrent = pingNext;
    pingNext = 255;
    sonar[pingCurrent].ping_timer(echoCheck); // Do the ping (processing continues, interrupt will call echoCheck to look for echo).
  }
  
  lastTrigger = 255;
  for (uint8_t i = 0; i < NUM_PINGS; i++) { // Loop through the sensors to see what's triggered
    if(pingDebug) {  //ping debug packet:  D:P:sensor index:distance cm
      Serial.print("D:P:"); Serial.print(i); Serial.print(":");Serial.println(sonar[i].ping_result / US_ROUNDTRIP_CM);
    }
    
    if (sonar[i].ping_result / US_ROUNDTRIP_CM > 0 && sonar[i].ping_result / US_ROUNDTRIP_CM < MAX_SAFE) {
      //S is e-stop, format is S:sensor index:distance cm
      Serial.print("S:"); Serial.print(i); Serial.print(":");Serial.println(sonar[i].ping_result / US_ROUNDTRIP_CM);
      if(powerLt < 90 && powerRt < 90) {  //only when going forward
        powerEnable = false;
        lastTrigger = i;
        powerL = 90;
        powerR = 90;
        ST1.write(90);  //90 is "center" so that's 0 power
        ST2.write(90);
      }
      break; //only need one to be over
    }
  }
  if(lastTrigger == 255 && !powerEnable) { //it passed after a failure
    powerEnable = true;
    Serial.println("S::"); //empty estop packet to clear it
  }
  
  if(Serial.available()) {            // Is data available from Internet
    //keys match number pad directions
    cmd = Serial.read();
    switch(cmd) { //read 1st byte
      case 'M': //move
        switch(Serial.read()) { //read 2nd byte
          case '8': //Forward
            powerLt = 90 - maxPwr;
            powerRt = 90 - maxPwr;
            break;
          case '9': //Forward Right
            powerLt = 90 - maxPwr;
            powerRt = 90 - (maxPwr/2);
            break;
          case '6': //Right
            powerLt = 90 - maxPwr;
            powerRt = 90 + maxPwr;
            break;
          case '3': //Reverse Right
            powerLt = 90 + maxPwr;
            powerRt = 90 + (maxPwr/2);
            break;
          case '2': //Reverse
            powerLt = 90 + maxPwr;
            powerRt = 90 + maxPwr;
            break;
          case '1': //Reverse Left
            powerLt = 90 + (maxPwr/2);
            powerRt = 90 + maxPwr;
            break;
          case '4': //Left
            powerLt = 90 + maxPwr;
            powerRt = 90 - maxPwr;
            break;
          case '7': //Forward Left
            powerLt = 90 - (maxPwr/2);
            powerRt = 90 - maxPwr;
            break;
          case '5': //Stop
            powerLt = 90;
            powerRt = 90;
            break;
          default:
            Serial.println("E:Invalid Move");
        }
        break;
      case 'D': //debug?
        switch(Serial.read()) { //read 2nd byte
          case '0':
            pingDebug = false;
            break;
          case '1': //enable
            pingDebug = true;
            break;
        }
        break;
      default:
        Serial.print("E:Invalid command "); Serial.println(cmd);
        Serial.flush();
    }
  }

  if (powerEnable) {
    ST1.write(powerL);
    ST2.write(powerR);
    delay(15);   
    if(powerL != powerLt || powerR != powerRt) {
      //ramp power towards target
      //if slowing dowm, ramp faster by doing it 2 times, also this means we don't need to check for overshooting
      if(powerLt == 90) {
        if(powerLt > powerL) powerL++;
        if(powerLt < powerL) powerL--;
      }
      if(powerLt > powerL) powerL++;
      if(powerLt < powerL) powerL--;

      if(powerRt == 90) {
        if(powerRt > powerR) powerR++;
        if(powerRt < powerR) powerR--;
      }
      if(powerRt > powerR) powerR++;
      if(powerRt < powerR) powerR--;
      //power info format: P:left target:right target:left actual:right actual
      Serial.print("P:"); Serial.print(powerLt); Serial.print(":"); Serial.print(powerRt); 
      Serial.print(":"); Serial.print(powerL); Serial.print(":"); Serial.println(powerR); 
    }
  } else {
    if(powerLt == 90 || powerRt == 90) {
      //ramp power towards target if heading to stop
      if(powerLt > powerL) powerL++;
      if(powerLt < powerL) powerL--;
      if(powerRt > powerR) powerR++;
      if(powerRt < powerR) powerR--;
    }
  }
}

void echoCheck() { // timer's up, do next sensor
  if(sonar[pingCurrent].check_timer() != 0) {
    pingNext = pingCurrent + 1;
    if (pingNext >= NUM_PINGS)
      pingNext = 0;
  }
}



