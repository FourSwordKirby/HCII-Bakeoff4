import ketai.camera.*;

KetaiCamera cam;

void setup() {
  imageMode(CENTER);
  cam = new KetaiCamera(this, 320, 240, 24);
  cam.start();
  textSize(60);
}

void draw() {
  background(80);
  image(cam, width/2, height/2);
  int r=0, g=0, b=0;
  int total=0;
  for(int i=0; i<cam.width*cam.height; i+=100) {
    total++;
    int val = cam.pixels[i];
    r += red(val);
    g += green(val);
    b += blue(val);
  }
  r /= total;
  g /= total;
  b /= total;
  textMode(CENTER);
  text("R: "+r+" G: "+g+" B: "+b, 10, 200);
}

void onCameraPreviewEvent()
{
  cam.read();
}