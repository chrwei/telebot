import processing.net.*;
import processing.serial.*;

int PORT = 8571; // TODO: tcp port (in server.js of the web app)
Server s;
Client c;

// -- ARDUINO -- //
Serial arduino;
boolean bSerialReady = false;
String theserial = "COM7"; // TODO: port of your arduino

void setup() {
  PFont myFont = createFont("Arial", 14);
  textFont(myFont);

  background(0);

  size(400, 200);
  frameRate(60);
  
  s = new Server(this, PORT); // Start a simple server on a port
  
  // find our arduino
  int i;
  //while (!bSerialReady) {
    for (i=0; i<Serial.list().length; i++) {
      if (Serial.list()[i].equals(theserial)) {
        infotext("Serial located at " + Serial.list()[i]);
        arduino = new Serial(this, Serial.list()[i], 115200);
        bSerialReady = true;
        break;
      }
    }
    if (!bSerialReady) {
      infotext("Serial not found, pausing 10 seconds before retry");
    //  delay(10000);
    } else {
      infotext("");
    }
  //}

  fill(255);
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
      data = c.readString();
      println("\n" + "data: " + data);
      // parse the message
      if(data.substring(0, 1).equals("M")) {
        // motor command, send data packat to ardunio as is
        infotext("Motor Command");
        if (bSerialReady) 
          arduino.write(data);
        else
          infotext("Serial not ready:" + data);
      } else if(data.substring(0, 1).equals("D")) {
        infotext("Debug Command");
        if(data.substring(1, 2).equals("0")) { //debug off, clear sensor area
          infoping(255, 0);
        }
        if (bSerialReady) 
          arduino.write(data);
        else
          infotext("Serial not ready:" + data);   
      } else {
        infotext("Unhandled Command");
      }
    }
  }
}

void serialEvent(Serial myPort) {
  String data[];
  String input;

  input = myPort.readStringUntil('\n'); //iput will include \n
  input = input.substring(0, input.length() - 2); //strip last character, zero indexed
  println("\n" + "data: " + input);
  data = split(input, ':');
  if(data[0].equals("I")) {
    infotext("Information:" + data[1]);
  } else if(data[0].equals("E")) {
    infotext("Error:" + data[1]);
  } else if(data[0].equals("S")) {
    if (data[1].equals("")) { //Stop is cleared
      infoping(255, 0);
    } else {
      infoping(Integer.parseInt(data[2]), Integer.parseInt(data[3]));
    }
    print("Stopped:Sensor:");
    print(data[1]);
    print(":Distance:");
    print(data[2]);
    println("cm");
  } else if(data[0].equals("P")) {
    infomotor(Integer.parseInt(data[1]), Integer.parseInt(data[3]), Integer.parseInt(data[2]), Integer.parseInt(data[4]));
    print("Power:L:");
    print(data[1]);
    print("<-");
    print(data[3]);
    print(":L:");
    print(data[2]);
    print("<-");
    println(data[4]);
  } else if(data[0].equals("D")) {
    print("Debug:");
    if (data[1].equals("P")) {
      infoping(Integer.parseInt(data[2]), Integer.parseInt(data[3]));
      print("Ping:Sensor:");
      print(data[2]);
      print(":Distance:");
      print(data[3]);
      println("cm");
    }
  }
}

void infotext(String text) {
  fill(0);
  rect(0, 0, width, 18);
  fill(255);
  textAlign(CENTER);
  text(text, width/2, 15);
}

void infomotor(int LT, int LA, int RT, int RA) {
  int barOffset = textWidth("Right Motor:  ");  //start of bars
  int barWidth = width - barOffset ; //max wdith
  int bardot = barWidth/180; //pixels per power #
  
  fill(0);
  rect(barOffset, 20, width, 38);
  rect(barOffset, 40, width, 58);
  fill(255);
  text("Left Motor:", 0, 35);
  text("Right Motor:", 0, 55);
  
  rect(barOffset + (bardot*90), 20, barOffset + (barOffset*LA), 35);
  rect(barOffset + (bardot*90), 40, barOffset + (barOffset*RA), 55);
  
  fill(128);
  rect(barOffset + (bardot*LT), 20, barOffset + 5 + (barOffset*LT), 35);
  rect(barOffset + (bardot*RT), 40, barOffset + 5 + (barOffset*RT), 55);
  
}

void infoping(int S, int cm) {
  int pingOffset = textWidth("Sensors (cm):  ");  //start of display
  int pingWidth = width - barOffset ; //max wdith
  int pingSpacing = pingWidth/4; 
  
  if(S==255) { //clear whole area
    fill(0);
    rect(pingOffset, 60, width, 78);
  } else {
    fill(0);
    rect(pingOffset + (S*pingSpacing), 60, pingOffset + ((S+1)*pingSpacing), 78);
    fill(255);
    text(cm, pingOffset + (S*pingSpacing), 75);
  }
}
