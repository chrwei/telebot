#include <SPI.h>  
#include <Pixy.h>
#include <Servo.h> 

#define X_CENTER    160L
#define RCS_MIN_POS     500L
#define RCS_MAX_POS     2300L
#define RCS_CENTER_POS	((RCS_MAX_POS-RCS_MIN_POS)/2)+RCS_MIN_POS


class ServoLoop
{
public:
  ServoLoop(int32_t pgain, int32_t dgain);

  void update(int32_t error);
   
  int32_t m_pos;
  int32_t m_prevError;
  int32_t m_pgain;
  int32_t m_dgain;
  long int vel;
};


ServoLoop::ServoLoop(int32_t pgain, int32_t dgain)
{
  m_pos = RCS_CENTER_POS;
  m_pgain = pgain;
  m_dgain = dgain;
  m_prevError = 0x80000000L;
}

void ServoLoop::update(int32_t error)
{
  if (m_prevError!=0x80000000)
  {	
    vel = (error*m_pgain + (error - m_prevError)*m_dgain)>>10;
    m_pos += vel;
    if (m_pos>RCS_MAX_POS) 
      m_pos = RCS_MAX_POS; 
    else if (m_pos<RCS_MIN_POS) 
      m_pos = RCS_MIN_POS;
  }
  m_prevError = error;
}

Servo myservo;
Pixy pixy;
ServoLoop panLoop(500, 800);

void setup()
{
  Serial.begin(115200);
  Serial.print("Starting...\n");
    
  myservo.attach(8);  // attaches the servo on pin 9 to the servo object 
  myservo.writeMicroseconds(RCS_CENTER_POS);

  delay(1000);
  Serial.print("...Done!\n");
}

void loop()
{ 
  uint16_t blocks;
  int32_t panError;
  uint16_t i=0, j;
  uint16_t minX, maxX;
  uint16_t minY, maxY;
  
  blocks = pixy.getBlocks();
  
  if (blocks)
  {
    minX = pixy.blocks[0].x - (pixy.blocks[0].width/2);
    maxX = pixy.blocks[0].x + (pixy.blocks[0].width/2);
    minY = pixy.blocks[0].y - (pixy.blocks[0].height/2);
    maxY = pixy.blocks[0].y + (pixy.blocks[0].height/2);
    //find biggest
    for (j=1; j<blocks; j++)
    {
      if(minX > pixy.blocks[j].x - (pixy.blocks[0].width/2)) 
        minX = pixy.blocks[j].x - (pixy.blocks[0].width/2);
      if(maxX < pixy.blocks[i].x + (pixy.blocks[i].width/2))  
        maxX = pixy.blocks[i].x + (pixy.blocks[i].width/2);
        
      if(minY > pixy.blocks[j].y - (pixy.blocks[0].height/2)) 
        minY = pixy.blocks[j].y - (pixy.blocks[0].height/2);
      if(maxY < pixy.blocks[i].y + (pixy.blocks[0].height/2))
        maxY = pixy.blocks[i].y + (pixy.blocks[0].height/2);
    }

    panError = X_CENTER - (((maxX-minX)/2) + minX);
    panLoop.update(panError);
    
    Serial.println("D:1");
    Serial.print("B:");
    Serial.print(minX);
    Serial.print(":");
    Serial.print(minY);
    Serial.print(":");
    Serial.print(maxX-minX);
    Serial.print(":");
    Serial.print(maxY-minY);
    Serial.println(":");

    myservo.writeMicroseconds(panLoop.m_pos);
    delay(15);
  }
}

