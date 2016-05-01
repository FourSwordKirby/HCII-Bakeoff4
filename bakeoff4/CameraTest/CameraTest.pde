import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;
import ketai.camera.*;

KetaiSensor sensor;
KetaiCamera cam;
String colorText = "";
PVector[] colors = new PVector[4];
boolean colorCorrect = false;
String colorDetectInfo = "";

float cursorX, cursorY;
float light = 0;
float lightThres = 10;


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
float circleRadius = 100;
int countDownTimerWait = 0;

void setup() {
  size(600,600); //you can change this to be fullscreen
  frameRate(60);
  sensor = new KetaiSensor(this);
  sensor.start();
  cam = new KetaiCamera(this, 320, 240, 24);
  cam.start();
  imageMode(CORNER);
  orientation(PORTRAIT);
  
  colors[0] = new PVector(255, 0, 0);
  colors[1] = new PVector(85, 255, 0);
  colors[2] = new PVector(0, 128, 255);
  colors[3] = new PVector(255, 147, 0);

  rectMode(CENTER);
  textFont(createFont("Arial", 40)); //sets the font to Arial size 20
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
  
  countDownTimerWait--;
  
  if (startTime == 0)
    startTime = millis();
  
  if (trialIndex==targets.size() && !userDone)
  {
    userDone=true;
    finishTime = millis();
  }
  
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount,1) + " sec per target", width/2, 150);
    return;
  }
  
  /*for (int i=0;i<4;i++)
  {
    if(targets.get(trialIndex).target==i)
       fill(0,255,0);
       else
       fill(180,180,180);
    ellipse(300,i*150+100,100,100);
  }*/
  if(!userDone) {
    int idx = targets.get(trialIndex).target;
    fill(colors[idx].x, colors[idx].y, colors[idx].z);
    if(light > lightThres) {
      colorCorrect = detectColor(cam, colors[idx].x, colors[idx].y, colors[idx].z, 0.2);
      if(colorCorrect)
        circleRadius = 200;
      else
        circleRadius = 100;
    }
    image(cam, 0, 0);
    text(colorDetectInfo, 100, height-50);
    ellipse(width/2, height/2, circleRadius, circleRadius);
  }
 
  fill(255);//white
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, 50);
  text("Target #" + (targets.get(trialIndex).target)+1, width/2, 100);
  
  if (targets.get(trialIndex).action==0)
    text("UP", width/2, 150);
  else
     text("DOWN", width/2, 150);
}
  
void onAccelerometerEvent(float x, float y, float z)
{
  if (userDone)
    return;
    
  if (light>lightThres) //only update cursor, if light is low
  {
    cursorX = 300+x*40; //cented to window and scaled
    cursorY = 300-y*40; //cented to window and scaled
  }
  
  Target t = targets.get(trialIndex);
  
  if (light<=lightThres && abs(z-9.8)>4 && countDownTimerWait<0) //possible hit event
  {
    //if (hitTest()==t.target)//check if it is the right target
    if(colorCorrect)
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

void onCameraPreviewEvent()
{
  if(userDone) return;
  cam.read();
}

boolean detectColor(PImage img, float r, float g, float b, float ratio) {
  if(userDone) return false;
  int count = 0;
  int total = 0;
  for(int i=0; i<img.width*img.height; i+=100) {
    int val = img.pixels[i];
    float d = dist(r, g, b, red(val), green(val), blue(val));
    if(d < 100) count++;
    total ++;
  }
  colorDetectInfo = "Count: "+count+" Total: "+total;
  return count * 1.0 / total > ratio;
}