import ddf.minim.*;

Minim minim;
AudioInput in;

import ddf.minim.analysis.*;
import ddf.minim.*;

FFT fft;

AudioOutput out;

void setup()
{
  size(512, 400, P3D);
  minim = new Minim(this);
  in = minim.getLineIn(); 
  fft = new FFT( in.bufferSize(), in.sampleRate() );
}

void draw()
{
  background(0); 
  stroke(255);
  
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
  }
  
  fft.forward(in.left);
  for(int i = 0; i < fft.specSize(); i++)
  {
    rect( i*2, height, 2,  - fft.getBand(i)*8 );
  }

}



