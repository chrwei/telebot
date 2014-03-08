import processing.net.*;

int PORT = 8571; // TODO: tcp port (in server.js of the web app)
String ServerIP = "127.0.0.1";

int DebugState = 0;
Client c;

int LastDirection = 5;
int boxW = 60; 
int boxH = 60;
int boxStartX = 10;
int boxStartY = 65;
int padding = 8;
int arrowLen = 10;

void setup() {
  PFont myFont = createFont("Arial", 20);
  textFont(myFont);

  size(640, 480);
  background(0);
  frameRate(10); // Slow it down a little

  textAlign(CENTER);
  text("Press Number or Letter", 120, 27);
  text("to pick direction", 120, 57);

  int boxX, boxY;
  boxW = (int)textWidth(" STOP ") + 6; 
  boxX = boxStartX; 
  boxY = boxStartY;
  for (int i=1 ; i<=9 ; i++) {
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
       text(" 7 T ", boxX + (boxW/2), boxY+padding + (boxH/2) + (padding*2));
       break;
     case 2:
       line(boxX+(boxW/2)                      , boxY+padding  , boxX+(boxW/2)                                        , (boxY+padding) + (arrowLen*2.25));
       line(boxX+(boxW/2)                      , boxY+padding  , (boxX+(boxW/2)) - (arrowLen + cos(45))               , (boxY+padding) + (arrowLen + cos(45)));
       line(boxX+(boxW/2)                      , boxY+padding  , (boxX+(boxW/2)) + (arrowLen + cos(45))               , (boxY+padding) + (arrowLen + cos(45)));
       fill(255);
       text(" 8 Y ", boxX + (boxW/2), boxY+padding + (boxH/2) + (padding*2));
       break;
     case 3:
       line((boxX) + (boxW - padding)  , boxY+padding  , ((boxX) + (boxW - padding)) - (arrowLen*2.25)   , (boxY+padding) + (arrowLen*2.25));
       line((boxX) + (boxW - padding)  , boxY+padding  , (boxX) + (boxW - padding)                    , (boxY+padding) + arrowLen);
       line((boxX) + (boxW - padding)  , boxY+padding  , (boxX) + (boxW - padding) - arrowLen         , boxY+padding);
       fill(255);
       text(" 9 U ", boxX + (boxW/2), boxY+padding + (boxH/2) + (padding*2));
       break;
     case 4:
       line(boxX+padding                       , boxY+(boxH/4)   , (boxX+padding) + (arrowLen*2.25)                        , boxY+(boxH/4));
       line(boxX+padding                       , boxY+(boxH/4)   , (boxX+padding) + (arrowLen + cos(45))                , (boxY+(boxH/4)) - (arrowLen + cos(45)));
       line(boxX+padding                       , boxY+(boxH/4)   , (boxX+padding) + (arrowLen + cos(45))                , (boxY+(boxH/4)) + (arrowLen + cos(45)));
       fill(255);
       text(" 4 G ", boxX + (boxW/2), boxY+padding + (boxH/2) + (padding*2));
       break;
     case 5:
       fill(255);
       text("STOP", boxX + (boxW/2), boxY+padding  + (padding*2));
       text(" 5 H ", boxX + (boxW/2), boxY+padding + (boxH/2) + (padding*2));
       break;
     case 6:
       line(boxX+(boxW - padding)              , boxY+(boxH/4)   , (boxX+(boxW - padding)) - (arrowLen*2.25)              , boxY+(boxH/4));
       line(boxX+(boxW - padding)              , boxY+(boxH/4)   , (boxX+(boxW - padding)) - (arrowLen + cos(45))         , (boxY+(boxH/4)) - (arrowLen + cos(45)));
       line(boxX+(boxW - padding)              , boxY+(boxH/4)   , (boxX+(boxW - padding)) - (arrowLen + cos(45))         , (boxY+(boxH/4)) + (arrowLen + cos(45)));
       fill(255);
       text(" 6 J ", boxX + (boxW/2), boxY+padding + (boxH/2) + (padding*2));
       break;
     case 7:
       line(boxX+padding               , (boxY+padding) + (arrowLen*2.25)  , (boxX+padding) + (arrowLen*2.25)       , boxY+padding );
       line(boxX+padding               , (boxY+padding) + (arrowLen*2.25)  , boxX+padding                           , (boxY+padding)+ (arrowLen*2.25) - arrowLen);
       line(boxX+padding               , (boxY+padding) + (arrowLen*2.25)  , (boxX+padding) + arrowLen              , (boxY+padding) + (arrowLen*2.25));
       fill(255);
       text(" 1 B ", boxX + (boxW/2), boxY+padding + (boxH/2) + (padding*2));
       break;
     case 8:
       line(boxX+(boxW/2)              , boxY+padding                      , boxX+(boxW/2)                          , (boxY+padding) + (arrowLen*2.25));
       line(boxX+(boxW/2)              , (boxY+padding) + (arrowLen*2.25)  , (boxX+(boxW/2)) - (arrowLen + cos(45)) , ((boxY+padding) + (arrowLen*2.25)) - (arrowLen + cos(45)));
       line(boxX+(boxW/2)              , (boxY+padding) + (arrowLen*2.25)  , (boxX+(boxW/2)) + (arrowLen + cos(45)) , ((boxY+padding) + (arrowLen*2.25)) - (arrowLen + cos(45)));
       fill(255);
       text(" 2 N ", boxX + (boxW/2), boxY+padding + (boxH/2) + (padding*2));
       break;
     case 9:
       line((boxX) + (boxW - padding)  , (boxY+padding) + (arrowLen*2.25)  , ((boxX) + (boxW - padding)) - (arrowLen*2.25)   , boxY+padding);
       line((boxX) + (boxW - padding)  , (boxY+padding) + (arrowLen*2.25)  , (boxX) + (boxW - padding)                    , ((boxY+padding) + (arrowLen*2.25)) - arrowLen);
       line((boxX) + (boxW - padding)  , (boxY+padding) + (arrowLen*2.25)  , (boxX) + (boxW - padding) - arrowLen         , (boxY+padding) + (arrowLen*2.25));
       fill(255);
       text(" 3 M ", boxX + (boxW/2), boxY+padding + (boxH/2) + (padding*2));
       break;
    }
    if(i % 3 == 0) {
      boxX = boxStartX;
      boxY += (boxH + 5);
    } else {
      boxX += (boxW + 5);
    }
  }

  c = new Client(this, ServerIP, PORT); // Replace with your server's IP and port
}

void draw() {
  int boxX, boxY;
  boxX = boxStartX; 
  boxY = boxStartY;
  stroke(0);
  for (int i=1 ; i<=9 ; i++) {
    if(i == LastDirection) {
      fill(0,255,0);
      ellipse(boxX + (boxW - padding), boxY+ (boxH/2) + (padding*2), 6, 6);
   } else {
      fill(0);
      ellipse(boxX + (boxW - padding), boxY+ (boxH/2) + (padding*2), 7, 7);
    }
 
    if(i % 3 == 0) {
      boxX = boxStartX;
      boxY += (boxH + 5);
    } else {
      boxX += (boxW + 5);
    }
  }
}

void keyPressed() {
  String data = "";
  
  switch(key) {
    case 'b':
    case 'B':
    case '1':
      LastDirection = 7; //match up to for loop that draws
      data = "M1"; //motor move
      break;
    case 'n':
    case 'N':
    case '2':
      LastDirection = 8; //match up to for loop that draws
      data = "M2"; //motor move
      break;
    case 'm':
    case 'M':
    case '3':
      LastDirection = 9; //match up to for loop that draws
      data = "M3"; //motor move
      break;
    case 'g':
    case 'G':
    case '4':
      LastDirection = 4; //match up to for loop that draws
      data = "M4"; //motor move
      break;
    case 'h':
    case 'H':
    case '5':
      LastDirection = 5; //match up to for loop that draws
      data = "M5"; //motor move
      break;
    case 'j':
    case 'J':
    case '6':
      LastDirection = 6; //match up to for loop that draws
      data = "M6"; //motor move
      break;
    case 't':
    case 'T':
    case '7':
      LastDirection = 1; //match up to for loop that draws
      data = "M7"; //motor move
      break;
    case 'y':
    case 'Y':
    case '8':
      LastDirection = 2; //match up to for loop that draws
      data = "M8"; //motor move
      break;
    case 'u':
    case 'U':
    case '9':
      LastDirection = 3; //match up to for loop that draws
      data = "M9"; //motor move
      break;
    
    case 'd':
    case 'D':
      DebugState = 1 - DebugState; //toggles between 0 and 1
      data = "D" + DebugState;
      break;
   
    default:
      return; 
  }
  
  if (data == "") {
    data = getMotorData(LastDirection);
  }
  c.write(data + "\n");
}

void mouseReleased() {
  String data = "";
  int boxX, boxY;
  boxX = boxStartX; 
  boxY = boxStartY;

  for (int i=1 ; i<=9 ; i++) {
    if(mouseX > boxX && mouseX < boxX + boxW &&
       mouseY > boxY && mouseY < boxY + boxH) {
      LastDirection = i;
      data = getMotorData(LastDirection);
      c.write(data + "\n");
    }

    if(i % 3 == 0) {
      boxX = boxStartX;
      boxY += (boxH + 5);
    } else {
      boxX += (boxW + 5);
    }
  }
}

String getMotorData(int Dir) {
  String data = "";
  switch(Dir) {
    case 7:
      data = "M1"; //motor move
      break;
    case 8:
      data = "M2"; //motor move
      break;
    case 9:
      data = "M3"; //motor move
      break;
    case 4:
      data = "M4"; //motor move
      break;
    case 5:
      data = "M5"; //motor move
      break;
    case 6:
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
  }
  return data;
}
