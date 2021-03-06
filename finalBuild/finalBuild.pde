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
float lightThres = 2f;
float tiltThres = 100f;

float acceleration = 100f;


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
  fullScreen();
  frameRate(60);
  sensor = new KetaiSensor(this);
  sensor.start();
  cam = new KetaiCamera(this, 320, 240, 60);
  cam.start();
  imageMode(CORNER);
  orientation(PORTRAIT);
  
  colors[0] = new PVector(255, 0, 0);
  colors[1] = new PVector(85, 255, 0);
  colors[2] = new PVector(0, 128, 255);
  colors[3] = new PVector(255, 147, 0);

  rectMode(CENTER);
  textSize(80);
  //textFont(createFont("Arial", 80)); //sets the font to Arial size 20
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
  
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount,1) + " sec per target", width/2, 150);
    return;
  }
  
  pushMatrix();
  translate(width/2, height/2); // This is the center of the text i want to flip
  rotate(PI/2);
  
  if(!userDone) {
    
    checkCorrectness();
    //Task meta-info
    fill(255);//white
    text("Trial " + (trialIndex+1) + " of " +trialCount, 0, -width/2 + 100);
    text("Target #" + (targets.get(trialIndex).target)+1, 0, -width/2 + 200);
    
    int idx = targets.get(trialIndex).target;
    fill(colors[idx].x, colors[idx].y, colors[idx].z);
    if(light > lightThres) {
      colorCorrect = detectColor(cam, colors[idx].x, colors[idx].y, colors[idx].z, 0.2);
      if(colorCorrect)
        //fill(255);
        circleRadius = 200;
      else
        circleRadius = 100;
    }
    ellipse(-150, -width/2 + 325, circleRadius, circleRadius);
    //text(colorDetectInfo, 0, 0);
    
    
    fill(colors[idx].x, colors[idx].y, colors[idx].z);
    if (targets.get(trialIndex).action==0)
    {
      if(cursorX < 0)
        fill(255);
      text("LEFT", 75, -width/2 + 350);
    }
    else
    {
      if(cursorX >= 0)
        fill(255);
      text("RIGHT", 75, -width/2 + 350);
    }
    
    //image(cam, -cam.width/2, -cam.height/+150);
    image(cam, -height/2, -width/2);

    fill(255);
    ellipse(cursorX,cursorY,50,50);
    
    /*
    if(cursorX < 0)
      text("Left Selection", 0, 50);
    else
      text("Right Selection", 0, 50);
    */
  }
     
  popMatrix();
}

void checkCorrectness()
{
  if (light<=lightThres)
  {
    //if (hitTest()==t.target)//check if it is the right target
    if(colorCorrect)
    {      
      if(targets.get(trialIndex).action==0)
      {
        if(cursorX < -tiltThres)
        {
          trialIndex++; //next trial!
          if(trialIndex >= targets.size()) {
            trialIndex = 0;
            userDone = true;
            finishTime = millis();
          }
          colorCorrect = false;
        }
        else
          print("Wrong selection");
      }
      else
      {
        if(cursorX >= tiltThres)
        {
          trialIndex++; //next trial!
          if(trialIndex >= targets.size()) {
            trialIndex = 0;
            userDone = true;
            finishTime = millis();
          }
          colorCorrect = false;
        }
        else
          print("Wrong selection");
      }
    }
    else
      println("Missed target! " + hitTest()); //no recording errors this bakeoff.
  }
}
  
void onAccelerometerEvent(float x, float y, float z)
{
  if (userDone)
    return;
    
  if (true) //only update cursor, if color is correct
  {
    cursorX = y*acceleration;//cented to window and scaled
    cursorY = 200;//cented to window and scaled
  }
  
  Target t = targets.get(trialIndex);
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
  cam.read();
}

boolean detectColor(PImage img, float r, float g, float b, float ratio) {
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