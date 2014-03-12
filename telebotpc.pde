import processing.net.*;
import processing.serial.*;
import java.util.Map;

int PORT = 8571;
Server s;
Client c;

// -- ARDUINO -- //
boolean bDebugNoSerial = false;
Serial arduino;
boolean bSerialReady = false;
String theserial = "COM7"; // TODO: port of your arduino

String lastInfo = null;
String lastMotor = null;
String lastSensor = null;
String lastMotorCommand = "M5\n";
int lastClientSend = 0;
int clientSendDelay = 500;

void setup() {
  PFont myFont = createFont("Arial", 14);
  textFont(myFont);

  background(0);

  size(400, 100);
  frameRate(60);

  s = new Server(this, PORT); // Start a simple server on a port

  if(!bDebugNoSerial) {
    // find our arduino
    int i;
    while (!bSerialReady) {
      for (i=0; i<Serial.list().length; i++) {
        println("Checking port: " + Serial.list()[i]);
        if (Serial.list()[i].equals(theserial)) {
          infotext("Serial located at " + Serial.list()[i]);
          arduino = new Serial(this, Serial.list()[i], 115200);
          bSerialReady = true;
          break;
        }
      }
      if (!bSerialReady) {
        infotext("Serial not found, pausing 10 seconds before retry");
        delay(10000);
      } else {
        infotext("");
      }
    }
  }

  infotext("My IP is " + Server.ip());

  fill(255);
  textAlign(LEFT);
  text("Left Motor:", 0, 35);
  text("Right Motor:", 0, 55);
  text("Sensors (cm):", 0, 75);
}

void delay(int ms) {
  try
  {
    Thread.sleep(ms);
  }
  catch(Exception e){}
}

void draw() {
  String data;

  // Receive data from client
  c = s.available();
  if (c != null) {
    if (c.available() > 0) {
      data = c.readStringUntil('\n'); //leave the \n on so we don't have to add it when writing to serial
      println("\n" + "data: " + data + ";");
      // parse the message
      if(data == null) {
        infotext("null command");
      } else if(data.substring(0, 1).equals("M")) {
        // motor command, send data packat to ardunio as is
        infotext("Motor Command " + data);
        lastMotorCommand = data;
        if (bSerialReady)
          arduino.write(data);
        else
          infotext("Serial not ready;" + data);
      } else if(data.substring(0, 1).equals("D")) {
        infotext("Debug Command");
        if(data.substring(1, 2).equals("0")) { //debug off, clear sensor area
          infoping(255, 0);
        }
        if (bSerialReady)
          arduino.write(data);
        else
          infotext("Serial not ready;" + data);
      } else if(data.substring(0, 1).equals("P")) {
        infotext("Program Command");
        if (bSerialReady)
          arduino.write(data);
        else
          infotext("Serial not ready;" + data);
      } else if(data.substring(0, 1).equals("S")) {
        infotext("Speed Command");
        if (bSerialReady) {
          arduino.write(data);
          arduino.write(lastMotorCommand); //send mototr command again
        } else
          infotext("Serial not ready;" + data);
      } else {
        infotext("Unhandled Command;" + data);
      }
    }
  }

  if(millis() - lastClientSend > clientSendDelay) {
    if (lastInfo != null) {
      s.write(lastInfo + '\n');
      lastInfo = null;
    }
    if (lastMotor != null) {
      s.write(lastMotor + '\n');
      lastMotor = null;
    }
    if (lastSensor != null) {
      s.write(lastSensor + '\n');
      lastSensor = null;
    }
    lastClientSend = millis();
  }
}

void serialEvent(Serial myPort) {
  String data[];
  String input;

  try {
    input = myPort.readStringUntil('\n'); //iput will include \n
    input = input.substring(0, input.length() - 2); //strip last character, zero indexed
    infotext("");
    data = split(input, ':');
    if(data[0].equals("I")) {
      infotext("Information:" + data[1]);
    } else if(data[0].equals("E")) {
      infotext("Error:" + data[1]);
    } else if(data[0].equals("S")) {
      if (data[1].equals("")) { //Stop is cleared
        infoping(255, 0);
      } else {
        infoping(Integer.parseInt(data[1]), Integer.parseInt(data[2]));
      }
    } else if(data[0].equals("P")) {
      infomotor(Integer.parseInt(data[1]), Integer.parseInt(data[3]), Integer.parseInt(data[2]), Integer.parseInt(data[4]));
    } else if(data[0].equals("D")) {
      if (data[1].equals("P")) {
        infoping(Integer.parseInt(data[2]), Integer.parseInt(data[3]));
      }
    }
  } catch(Exception e) {
    //println("serial exception");
    //println(e);
  }
}

void infotext(String text) {
  fill(0);
  rect(0, 0, width, 18);
  fill(255);
  textAlign(CENTER);
  text(text, width/2, 15);
  lastInfo = "I:" + text;
}

void infomotor(int LT, int LA, int RT, int RA) {
  int barOffset = (int)textWidth("Right Motor:  ");  //start of bars
  int barWidth = width - barOffset - 5 ; //max wdith
  float bardot = barWidth/180.0; //pixels per power #

  //since 0 == full forward, inverse so forward goes to the right
  LA = 180 - LA;
  LT = 180 - LT;
  RA = 180 - RA;
  RT = 180 - RT;

  fill(0);
  rect(barOffset, 20, width - barOffset, 18);
  rect(barOffset, 40, width - barOffset, 18);
  fill(255);

  rect(barOffset + (bardot*90), 20, ((bardot*LA) - (bardot*90)), 15);
  rect(barOffset + (bardot*90), 40, ((bardot*RA) - (bardot*90)), 15);

  fill(255, 64, 0);
  rect(barOffset + (bardot*LT), 20, 5, 15);
  rect(barOffset + (bardot*RT), 40, 5, 15);

  lastMotor = "P:" + str(LT) + ":" + str(RT) + ":" + str(LA) + ":" + str(RA);
}

void infoping(int S, int cm) {
  int pingOffset = (int)textWidth("Sensors (cm):  ");  //start of display
  int pingWidth = width - pingOffset ; //max wdith
  int pingSpacing = pingWidth/4;

  S = 3 - S; //invert for display

  if(S < 0) { //clear whole area... invert makes the 255 negative
    fill(0);
    rect(pingOffset, 60, width - pingOffset, 18);
    lastSensor = "S::";
  } else {
    fill(0);
    rect(pingOffset + (S*pingSpacing), 60, pingSpacing, 18);
    fill(255);
    text(cm, pingOffset + 15 + (S*pingSpacing), 75);

    lastSensor = "S:" + str(S) + ":" + str(cm);
  }
}

void keyPressed() {
  switch(key) {
    case 'p':
    case 'P':
      infotext("Program Command");
      if (bSerialReady)
        arduino.write("P1" + '\n');
      else
        infotext("Serial not ready;P1");
      break;
    case 'q':
    case 'Q':
      infotext("DriveMode Command");
      if (bSerialReady) {
        arduino.write("P0" + '\n');
      } else
        infotext("Serial not ready;P0");
      break;

    default:
      return;
  }

}
