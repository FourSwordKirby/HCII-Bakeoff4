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
String rgbInfo = "";
float colorThres = 80;

float cursorX=0f, cursorY=100f;
float light = 0;
float lightThres = 2f;
float tiltThres = 10f;

float acceleration = 0f;

boolean DEBUG = false;


private class Target
{
  int target = 0;
  int action = 0;
}

int trialCount = 75; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();
   
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
float circleRadius = 100;
int countDownTimerWait = 30;
float circleSpeed = 0f;

void setup() {
  fullScreen();
  frameRate(60);
  sensor = new KetaiSensor(this);
  sensor.start();
  cam = new KetaiCamera(this, 320, 240, 60);
  cam.start();
  cam.manualSettings();
  imageMode(CORNER);
  orientation(PORTRAIT);
  
  colors[0] = new PVector(220, 20, 10);//red
  colors[1] = new PVector(40, 120, 20); //green
  colors[2] = new PVector(0, 70, 140); //blue
  colors[3] = new PVector(220, 190, 45); //yellow

  rectMode(CORNERS);
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

  background(0); //background is light grey
  noStroke(); //no stroke
  fill(255);
  
  if(countDownTimerWait > 0) {
    countDownTimerWait--;
    return;
  }
  
  if (startTime == 0)
    startTime = millis();
  
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 100);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount,3) + " sec per target", width/2, 200);
    return;
  }
  
  
  
  pushMatrix();
  translate(width/2, height/2); // This is the center of the text i want to flip
  rotate(PI/2);
  
  float r=0;
  float g=0;
  float b=0;
  int total=0;
  for(int i=0; i<cam.height*cam.width; i+=150) {
    int val = cam.pixels[i];
    r += red(val);
    g += green(val);
    b += blue(val);
    total++;
  }
  r = r/total;
  g = g/total;
  b = b/total;
  if(DEBUG)text("R: "+int(r)+" G: "+int(g)+" B: "+int(b), 0, 300);
  
  if(!userDone) {
    //Task meta-info
    fill(255);//white
    text("Trial " + (trialIndex+1) + " of " +trialCount, 0, -width/2 + 100);
    text("Target #" + (targets.get(trialIndex).target+1), 0, -width/2 + 200);
    Target t = targets.get(trialIndex);
    int idx = t.target;
    fill(colors[idx].x, colors[idx].y, colors[idx].z);
    //if(light > lightThres) {
      circleSpeed = 0f;
      colorCorrect = detectColor(cam, colors[idx].x, colors[idx].y, colors[idx].z, 0.1);
      if(colorCorrect)
        //fill(255);
        circleRadius = 200;
      else
        circleRadius = 100;
    //}
    //else 
    if(colorCorrect) {
      checkCorrectness();
      //if(acceleration > 0 && t.action == 0
      //|| acceleration < 0 && t.action == 1) {
      //  circleSpeed += acceleration * 0.1;
      //} else {
        circleSpeed += acceleration;
      //}
      cursorX += circleSpeed / 60f;
        
      if(cursorX - circleRadius/2 < -150f) {
        cursorX = -150f+circleRadius/2;
        circleSpeed = 0f;
      }
      if(cursorX + circleRadius/2 > 150f) {
        cursorX = 150f-circleRadius/2;
        circleSpeed = 0f;
      }
    }
    else {
      circleSpeed = 0f;
      cursorX = 0f;
    }
    //ellipse(-150, -width/2 + 325, circleRadius, circleRadius);
    //text(colorDetectInfo, 0, 0);
    
    image(cam, -height/2, -width/2);
    
    /*
    if(cursorX < 0)
      text("Left Selection", 0, 50);
    else
      text("Right Selection", 0, 50);
    */
    strokeWeight(10);
    stroke(20);
    fill(255,0);
    if(t.action == 0) {
      //rect(tiltThres+100, -100, height/2, width/2);
      ellipse(tiltThres+100f, cursorY, 205f, 205f);
    }
    else {
      //rect(-tiltThres-100, -100, -height/2, width/2);
      ellipse(-tiltThres-100f, cursorY, 205f, 205f);
    }
    stroke(colors[idx].x, colors[idx].y, colors[idx].z);
    if(t.action == 1) { // RIGHT
      text("RIGHT", 0, 0);
      //rect(tiltThres+100, -100, height/2, width/2);
      ellipse(tiltThres+100f, cursorY, 205f, 205f);
    }
    else {
      text("LEFT", 0, 0);
      //rect(-tiltThres-100, -100, -height/2, width/2);
      ellipse(-tiltThres-100f, cursorY, 205f, 205f);
    }
    noStroke();
    fill(colors[idx].x, colors[idx].y, colors[idx].z);

    ellipse(cursorX,cursorY,circleRadius,circleRadius);
  }
     
  popMatrix();
}

void checkCorrectness()
{
  //if (light<=lightThres)
  //{
    //if (hitTest()==t.target)//check if it is the right target
    if(colorCorrect)
    {
      if(targets.get(trialIndex).action==0 && cursorX < -tiltThres ||
        targets.get(trialIndex).action==1 && cursorX >= tiltThres)
      {
        trialIndex++; //next trial!
        countDownTimerWait = 1;
        cursorX = 0f;
        circleRadius = 100f;
        circleSpeed = 0f;
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
      println("Missed target! " + hitTest()); //no recording errors this bakeoff.
  //}
}
  
void onAccelerometerEvent(float x, float y, float z)
{
  if (userDone)
    return;
  acceleration = y * 50f;//cented to window and scaled
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
  for(int i=0; i<img.width*img.height; i+=150) {
    int val = img.pixels[i];
    float d = dist(r, g, b, red(val), green(val), blue(val));
    if(d < colorThres) count++;
    total ++;
  }
  colorDetectInfo = "Count: "+count+" Total: "+total;
  return count * 1.0 / total > ratio;
}