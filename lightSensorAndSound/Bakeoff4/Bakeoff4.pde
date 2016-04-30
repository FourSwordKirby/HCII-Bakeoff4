import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;

KetaiSensor sensor;

float cursorX, cursorY;
float light = 0;


  private class Target
  {
    int target = 0;
    int action = 0;
  }

  int trialCount = 5; //this will be set higher for the bakeoff
  int trialIndex = 0;
  ArrayList<Target> targets = new ArrayList<Target>();
     
  int startTime = 0; // time starts when the first click is captured
  int finishTime = 0; //records the time of the final click
  boolean userDone = false;
  int countDownTimerWait = 0;
  
  final float screenPPI = 577;
  float inchesToPixels(float inch)
  {
    return inch*screenPPI;
  }
  
  
  void setup() {
    fullScreen();
    frameRate(60);
    sensor = new KetaiSensor(this);
    sensor.start();
    orientation(PORTRAIT);
  
    rectMode(CENTER);
    textFont(createFont("Arial", 50)); //sets the font to Arial size 20
    textAlign(CENTER);
    
    for (int i=0;i<trialCount;i++)  //don't change this!
    {
      Target t = new Target();
      t.target = ((int)random(1000))%4;
      t.action = ((int)random(1000))%2;
      targets.add(t);
      println("created target with " + t.target + "," + t.action);
    }
    
    Collections.shuffle(targets); // randomize the order of the button;
  }

  void draw() {
    background(80); //background is light grey
    noStroke(); //no stroke
    fill(255);
    
    if(light < 20)
      text("Selection Confirmed:", width/2, 3*height/4);
    
    ellipse(cursorX,cursorY,50,50);
    
    if(cursorX < width/2)
      text("Left Selection", width/2, height/2);
    else
      text("Right Selection", width/2, height/2);
          
    return;
  }
  
void onAccelerometerEvent(float x, float y, float z)
{
  if (userDone)
    return;
    
  if (light>20) //only update cursor, if light is low
  {
    cursorX = width/2-x*80; //cented to window and scaled
    cursorY = height/2; //cented to window and scaled
  }
  
  /*
  Target t = targets.get(trialIndex);
  
  if (light<=20 && abs(z-9.8)>4 && countDownTimerWait<0) //possible hit event
  {
    if (hitTest()==t.target)//check if it is the right target
    {
      println(z-9.8);
      if (((z-9.8)>4 && t.action==0) || ((z-9.8)<-4 && t.action==1))
      {
        println("Right target, right z direction! " + hitTest());
        trialIndex++; //next trial!
      }
      else
        println("right target, wrong z direction!");
        
      countDownTimerWait=30; //wait 0.5 sec before allowing next trial
    }
    else
      println("Missed target! " + hitTest()); //no recording errors this bakeoff.
  }
  */
}

int hitTest() 
{
   for (int i=0;i<4;i++)
      if (dist(300,i*150+100,cursorX,cursorY)<100)
        return i;
 
    return -1;
}

  
void onLightEvent(float v) //this just updates the light value
{
  light = v;
}