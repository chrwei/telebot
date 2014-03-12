import processing.net.*;

int PORT = 8571; // TODO: tcp port (in server.js of the web app)
String ServerIP = "192.168.1.125"; //bot PC
//String ServerIP = "127.0.0.1";

int DebugState = 0;
Client c;
boolean clientConnected = false;

int LastDirection = 6;
int LastSpeed = 4;
int boxW = 60;
int boxH = 60;
int boxStartX = 10;
int boxStartY = 65;
int boxSpace = 5;
int padding = 8;
int arrowLen = 10;
int infoY, motorLY, motorRY, sensY;

void setup() {
  PFont myFont = createFont("Arial", 20);
  textFont(myFont);

  int boxX, boxY;
  boxW = (int)textWidth(" SPEED ") + 6;

  size((boxW*4)+(boxSpace*3)+(boxStartX*2), 480); //width is 4 boxes, 3 spaces, and 2 borders
  background(0);
  frameRate(10); // Slow it down a little

  textAlign(CENTER);
  text("Press Number or Letter", ((boxW*4)+(boxSpace*3)+(boxStartX*2))/2, 27);
  text("to pick direction", ((boxW*4)+(boxSpace*3)+(boxStartX*2))/2, 57);

  boxX = boxStartX;
  boxY = boxStartY;
  for (int i=1 ; i<=12 ; i++) {
    fill(0);
    stroke(255);
    //button box
    rect(boxX, boxY, boxW, boxH);

    //arrow and text, i is not in order of the text to display
    switch(i) {
     case 1:
       line(boxX+padding                       , boxY+padding  , (boxX+padding) + (arrowLen*2.25)                        , (boxY+padding) + (arrowLen*2.25));
       line(boxX+padding                       , boxY+padding  , boxX+padding                                         , (boxY+padding) + arrowLen);
       line(boxX+padding                       , boxY+padding  , (boxX+padding) + arrowLen                            , boxY+padding);
       fill(255);
       text(" 7 T ", boxX + (boxW/2), boxY+padding + (boxH/2) + 15);
       break;
     case 2:
       line(boxX+(boxW/2)                      , boxY+padding  , boxX+(boxW/2)                                        , (boxY+padding) + (arrowLen*2.25));
       line(boxX+(boxW/2)                      , boxY+padding  , (boxX+(boxW/2)) - (arrowLen + cos(45))               , (boxY+padding) + (arrowLen + cos(45)));
       line(boxX+(boxW/2)                      , boxY+padding  , (boxX+(boxW/2)) + (arrowLen + cos(45))               , (boxY+padding) + (arrowLen + cos(45)));
       fill(255);
       text(" 8 Y ", boxX + (boxW/2), boxY+padding + (boxH/2) + 15);
       break;
     case 3:
       line((boxX) + (boxW - padding)  , boxY+padding  , ((boxX) + (boxW - padding)) - (arrowLen*2.25)   , (boxY+padding) + (arrowLen*2.25));
       line((boxX) + (boxW - padding)  , boxY+padding  , (boxX) + (boxW - padding)                    , (boxY+padding) + arrowLen);
       line((boxX) + (boxW - padding)  , boxY+padding  , (boxX) + (boxW - padding) - arrowLen         , boxY+padding);
       fill(255);
       text(" 9 U ", boxX + (boxW/2), boxY+padding + (boxH/2) + 15);
       break;
     case 4:
       fill(255);
       text(" Speed ", boxX + (boxW/2), boxY+padding + (boxH/2) - 5 );
       text(" 1 ", boxX + (boxW/2), boxY+padding + (boxH/2) + 15);
       break;
     case 5:
       line(boxX+padding                       , boxY+(boxH/4)   , (boxX+padding) + (arrowLen*2.25)                        , boxY+(boxH/4));
       line(boxX+padding                       , boxY+(boxH/4)   , (boxX+padding) + (arrowLen + cos(45))                , (boxY+(boxH/4)) - (arrowLen + cos(45)));
       line(boxX+padding                       , boxY+(boxH/4)   , (boxX+padding) + (arrowLen + cos(45))                , (boxY+(boxH/4)) + (arrowLen + cos(45)));
       fill(255);
       text(" 4 G ", boxX + (boxW/2), boxY+padding + (boxH/2) + 15);
       break;
     case 6:
       fill(255);
       text("STOP", boxX + (boxW/2), boxY+padding  + 15);
       text(" 5 H ", boxX + (boxW/2), boxY+padding + (boxH/2) + 15);
       break;
     case 7:
       line(boxX+(boxW - padding)              , boxY+(boxH/4)   , (boxX+(boxW - padding)) - (arrowLen*2.25)              , boxY+(boxH/4));
       line(boxX+(boxW - padding)              , boxY+(boxH/4)   , (boxX+(boxW - padding)) - (arrowLen + cos(45))         , (boxY+(boxH/4)) - (arrowLen + cos(45)));
       line(boxX+(boxW - padding)              , boxY+(boxH/4)   , (boxX+(boxW - padding)) - (arrowLen + cos(45))         , (boxY+(boxH/4)) + (arrowLen + cos(45)));
       fill(255);
       text(" 6 J ", boxX + (boxW/2), boxY+padding + (boxH/2) + 15);
       break;
     case 8:
       fill(255);
       text(" Speed ", boxX + (boxW/2), boxY+padding + (boxH/2) - 5 );
       text(" 2 ", boxX + (boxW/2), boxY+padding + (boxH/2) + 15);
       break;
     case 9:
       line(boxX+padding               , (boxY+padding) + (arrowLen*2.25)  , (boxX+padding) + (arrowLen*2.25)       , boxY+padding );
       line(boxX+padding               , (boxY+padding) + (arrowLen*2.25)  , boxX+padding                           , (boxY+padding)+ (arrowLen*2.25) - arrowLen);
       line(boxX+padding               , (boxY+padding) + (arrowLen*2.25)  , (boxX+padding) + arrowLen              , (boxY+padding) + (arrowLen*2.25));
       fill(255);
       text(" 1 B ", boxX + (boxW/2), boxY+padding + (boxH/2) + 15);
       break;
     case 10:
       line(boxX+(boxW/2)              , boxY+padding                      , boxX+(boxW/2)                          , (boxY+padding) + (arrowLen*2.25));
       line(boxX+(boxW/2)              , (boxY+padding) + (arrowLen*2.25)  , (boxX+(boxW/2)) - (arrowLen + cos(45)) , ((boxY+padding) + (arrowLen*2.25)) - (arrowLen + cos(45)));
       line(boxX+(boxW/2)              , (boxY+padding) + (arrowLen*2.25)  , (boxX+(boxW/2)) + (arrowLen + cos(45)) , ((boxY+padding) + (arrowLen*2.25)) - (arrowLen + cos(45)));
       fill(255);
       text(" 2 N ", boxX + (boxW/2), boxY+padding + (boxH/2) + 15);
       break;
     case 11:
       line((boxX) + (boxW - padding)  , (boxY+padding) + (arrowLen*2.25)  , ((boxX) + (boxW - padding)) - (arrowLen*2.25)   , boxY+padding);
       line((boxX) + (boxW - padding)  , (boxY+padding) + (arrowLen*2.25)  , (boxX) + (boxW - padding)                    , ((boxY+padding) + (arrowLen*2.25)) - arrowLen);
       line((boxX) + (boxW - padding)  , (boxY+padding) + (arrowLen*2.25)  , (boxX) + (boxW - padding) - arrowLen         , (boxY+padding) + (arrowLen*2.25));
       fill(255);
       text(" 3 M ", boxX + (boxW/2), boxY+padding + (boxH/2) + 15);
       break;
     case 12:
       fill(255);
       text(" Speed ", boxX + (boxW/2), boxY+padding + (boxH/2) - 5 );
       text(" 3 ", boxX + (boxW/2), boxY+padding + (boxH/2) + 15);
       break;
    }
    if(i % 4 == 0) {
      boxX = boxStartX;
      boxY += (boxH + boxSpace);
    } else {
      boxX += (boxW + boxSpace);
    }
  }

  infoY = boxY + 15;
  motorLY = boxY + 35;
  motorRY = boxY + 55;
  sensY = boxY + 75;

  fill(255);
  textAlign(LEFT);
  text("Left Motor:", 0, motorLY);
  text("Right Motor:", 0, motorRY);
  text("Sensors (cm):", 0, sensY);

  connectClient();
}

void connectClient() {
  try {
    c = new Client(this, ServerIP, PORT); // Replace with your server's IP and port
    clientConnected = true;
    //println(c);
  } catch(Exception e){
    clientConnected = false;
  }
}

void draw() {
  String data[];
  String input;
  int boxX, boxY;
  boxX = boxStartX;
  boxY = boxStartY;
  stroke(0);
  for (int i=1 ; i<=12 ; i++) {
    if(i == LastDirection) {
      fill(0,255,0);
      ellipse(boxX + (boxW - padding), boxY+ (boxH/2) + 15, 6, 6);
   } else if(i == LastSpeed) {
      fill(255,0,0);
      ellipse(boxX + (boxW - padding), boxY+ (boxH/2) + 15, 6, 6);
   } else {
     fill(0);
     ellipse(boxX + (boxW - padding), boxY+ (boxH/2) + 15, 7, 7);
   }

    if(i % 4 == 0) {
      boxX = boxStartX;
      boxY += (boxH + boxSpace);
    } else {
      boxX += (boxW + boxSpace);
    }
  }

  if (c.available() > 0) {
    input = c.readStringUntil('\n');
    println(input + '|');
    if (input == null) return;
    input = input.substring(0, input.length() - 1); //strip the \n
    data = split(input, ':');
    if(data[0].equals("I")) {
      if (data.length == 1) {
        infotext("");
      } else {
        infotext(data[1]);
      }
    } else if(data[0].equals("S")) {
      if (data[1].equals("")) { //Stop is cleared
        infoping(255, 0);
      } else {
        infoping(Integer.parseInt(data[1]), Integer.parseInt(data[2]));
      }
    } else if(data[0].equals("P")) {
      infomotor(Integer.parseInt(data[1]), Integer.parseInt(data[3]), Integer.parseInt(data[2]), Integer.parseInt(data[4]));
    }
  }
}

void keyPressed() {
  String data = "";

  switch(key) {
    case 'b':
    case 'B':
    case '1':
      LastDirection = 9; //match up to for loop that draws
      break;
    case 'n':
    case 'N':
    case '2':
      LastDirection = 10; //match up to for loop that draws
      break;
    case 'm':
    case 'M':
    case '3':
      LastDirection = 11; //match up to for loop that draws
      break;
    case 'g':
    case 'G':
    case '4':
      LastDirection = 5; //match up to for loop that draws
      break;
    case 'h':
    case 'H':
    case '5':
      LastDirection = 6; //match up to for loop that draws
      break;
    case 'j':
    case 'J':
    case '6':
      LastDirection = 7; //match up to for loop that draws
      break;
    case 't':
    case 'T':
    case '7':
      LastDirection = 1; //match up to for loop that draws
      break;
    case 'y':
    case 'Y':
    case '8':
      LastDirection = 2; //match up to for loop that draws
      break;
    case 'u':
    case 'U':
    case '9':
      LastDirection = 3; //match up to for loop that draws
      break;

    case 'o':
    case 'O':
      LastSpeed = 4; //match up to for loop that draws
      data = getMotorData(LastSpeed);
      break;
    case 'l':
    case 'L':
      LastSpeed = 8; //match up to for loop that draws
      data = getMotorData(LastSpeed);
      break;
    case '.':
      LastSpeed = 12; //match up to for loop that draws
      data = getMotorData(LastSpeed);
      break;

    case 'd':
    case 'D':
      DebugState = 1 - DebugState; //toggles between 0 and 1
      data = "D" + DebugState;
      break;

    case 'p':
    case 'P':
      data = "P1";
      break;
    case 'q':
    case 'Q':
      data = "P0";
      break;

    default:
      return;
  }

  if (data == "") {
    data = getMotorData(LastDirection);
  }
  try {
    println(c);
    if (!clientConnected) {
      connectClient();
    }
    if (clientConnected) { //only if connectClient() sucseeded
      println(c);
      c.write(data + "\n");
    }
  } catch(Exception e){
    clientConnected = false;
    c.stop();
  }
}

void mouseReleased() {
  String data = "";
  int boxX, boxY;
  boxX = boxStartX;
  boxY = boxStartY;

  for (int i=1 ; i<=12 ; i++) {
    if(mouseX > boxX && mouseX < boxX + boxW &&
       mouseY > boxY && mouseY < boxY + boxH) {
      if(i % 4 == 0) { //speed button
        LastSpeed = i;
        data = getMotorData(LastSpeed);
      } else { //motor button
        LastDirection = i;
        data = getMotorData(LastDirection);
      }
      try {
        if (!clientConnected) {
          connectClient();
        }
        if (clientConnected) { //only if connectClient() sucseeded
          c.write(data + "\n");
        }
      } catch(Exception e){
        clientConnected = false;
      }
    }

    if(i % 4 == 0) {
      boxX = boxStartX;
      boxY += (boxH + boxSpace);
    } else {
      boxX += (boxW + boxSpace);
    }
  }
}

String getMotorData(int Dir) {
  String data = "";
  switch(Dir) {
    case 9:
      data = "M1"; //motor move
      break;
    case 10:
      data = "M2"; //motor move
      break;
    case 11:
      data = "M3"; //motor move
      break;
    case 5:
      data = "M4"; //motor move
      break;
    case 6:
      data = "M5"; //motor move
      break;
    case 7:
      data = "M6"; //motor move
      break;
    case 1:
      data = "M7"; //motor move
      break;
    case 2:
      data = "M8"; //motor move
      break;
    case 3:
      data = "M9"; //motor move
      break;
    //speed data
    case 4:
      data = "S1";
      break;
    case 8:
      data = "S2";
      break;
    case 12:
      data = "S3";
      break;
  }
  return data;
}

void infotext(String text) {
  fill(0);
  rect(0, infoY-15, width, 18);
  fill(255);
  textAlign(CENTER);
  text(text, width/2, infoY);
}

void infomotor(int LT, int LA, int RT, int RA) {
  int barOffset = (int)textWidth("Right Motor:  ");  //start of bars
  int barWidth = width - barOffset - 5 ; //max wdith
  float bardot = barWidth/180.0; //pixels per power #

  fill(0);
  rect(barOffset, motorLY-15, width - barOffset, 18);
  rect(barOffset, motorRY-15, width - barOffset, 18);

  fill(255);
  rect(barOffset + (bardot*90), motorLY-15, ((bardot*LA) - (bardot*90)), 15);
  rect(barOffset + (bardot*90), motorRY-15, ((bardot*RA) - (bardot*90)), 15);

  fill(255, 64, 0);
  rect(barOffset + (bardot*LT), motorLY-15, 5, 15);
  rect(barOffset + (bardot*RT), motorRY-15, 5, 15);
}

void infoping(int S, int cm) {
  int pingOffset = (int)textWidth("Sensors (cm):  ");  //start of display
  int pingWidth = width - pingOffset ; //max wdith
  int pingSpacing = pingWidth/4;

  S = 3 - S; //invert for display

  if(S < 0) { //clear whole area... invert makes the 255 negative
    fill(0);
    rect(pingOffset, sensY-15, width - pingOffset, 18);
  } else {
    fill(0);
    rect(pingOffset + (S*pingSpacing), sensY-15, pingSpacing, 18);
    fill(255);
    text(cm, pingOffset + 15 + (S*pingSpacing), sensY);
  }
}

