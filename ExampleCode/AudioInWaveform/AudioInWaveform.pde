import ddf.minim.*;

Minim minim;
AudioInput in;

void setup()
{
  size(512, 200, P3D);
  minim = new Minim(this);
  in = minim.getLineIn();  
}

void draw()
{
  background(0); 
  stroke(255);
  
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
  }

}

