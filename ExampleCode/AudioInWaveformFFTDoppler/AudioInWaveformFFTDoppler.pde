import ddf.minim.*;

Minim minim;
AudioInput in;

import ddf.minim.analysis.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

FFT fft;
AudioOutput out;
Oscil wave;

void setup()
{
  size(512, 400, P3D);
  minim = new Minim(this);
  in = minim.getLineIn();  
  
  fft = new FFT( in.bufferSize(), in.sampleRate() );
  
  out = minim.getLineOut();
  wave = new Oscil( 18000, 0.5f, Waves.SINE );
  wave.patch( out );
}

void draw()
{
  background(0); 
  stroke(255);
  
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
  }
  
  fft.forward( in.left );
  
  translate(-400*8,0);
  for(int i = 400; i < fft.specSize(); i++)
  {
    rect( i*8, 400, 8, - fft.getBand(i)*8 );
  }

}

