import processing.serial.*;

Serial arduino;
boolean bSerialReady = false;
String theserial = "/dev/ttyACM0";

void setup() {
  background(0);

  size(320, 200);
  frameRate(60);

    // find our arduino
    int i;
    while (!bSerialReady) {
      for (i=0; i<Serial.list().length; i++) {
        println("Checking port: " + Serial.list()[i]); 
        if (Serial.list()[i].equals(theserial)) {
          arduino = new Serial(this, Serial.list()[i], 115200);
          bSerialReady = true;
          break;
        }
      }
      if (!bSerialReady) {
        delay(10000);
      }
    }
}

void draw() {
  String data[];
  String input;
  
  if(arduino.available() > 0) {
    input = arduino.readStringUntil('\n'); //iput will include \n
    //print(input);
    if (input != null) {
      input = input.substring(0, input.length() - 2); //strip last character, zero indexed
      data = split(input, ':');
      if(data[0].equals("D") && !data[1].equals("")) {
        background(0); //clear it
        input = null;
        for (int j=0; j < Integer.parseInt(data[1]) ; j++) {
          input = arduino.readStringUntil('\n'); //iput will include \n
          if(input != null) {
            input = input.substring(0, input.length() - 2); //strip last character, zero indexed
            data = split(input, ':');
            if(data[0].equals("B")) {
              fill(0);
              stroke(255);
              rect(Integer.parseInt(data[1]), Integer.parseInt(data[2]), Integer.parseInt(data[3]), Integer.parseInt(data[4]));
            }
          }
        }
      }
    }
  } 
}
