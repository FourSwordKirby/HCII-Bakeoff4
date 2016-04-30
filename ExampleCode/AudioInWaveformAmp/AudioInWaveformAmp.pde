import ddf.minim.*;

Minim minim;
AudioInput in;

void setup()
{
  size(512, 400, P3D);
  minim = new Minim(this);
  in = minim.getLineIn();
  noStroke();  
  background(0);
}

int index = 0;

void draw()
{
  fill(0,1);
  rect(0,0,width,height);
  
  float max = 0;    
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    if (max<in.left.get(i))
      max = in.left.get(i);
  }

  fill(255);
  rect(index,390,1,-max*200-1);
  index++;
  
  if (index>512)
    index=0;
}

