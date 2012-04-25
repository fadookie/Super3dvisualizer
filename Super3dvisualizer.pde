import ddf.minim.analysis.*;
import ddf.minim.*;
 
Minim minim;
AudioInput in;
FFT fft;

static int sampleRate = 64;
static int power = 1;
int timer = 0;
static float timeStretch = 0.5;
static int timerMax = 800;
static float xStretch = 2.0;

float[][] geomBuffer;

void setup()
{
  size(800, 800, P3D);
 
  minim = new Minim(this);
  //minim.debugOn();
 
  // get a line in from Minim, default bit depth is 16
  in = minim.getLineIn(Minim.STEREO, sampleRate);
  in.mute();
  
  fft = new FFT(in.bufferSize(), in.sampleRate());
    fft.logAverages(22, 3);
    
  geomBuffer = new float[timerMax + 1][fft.specSize()];


}
 
void draw()
{
//  background(0);
//  stroke(255);
//  // draw the waveforms
//  for(int i = 0; i < in.bufferSize() - 1; i++)
//  {
//    line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
//    line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
//  }
  lights();
  
   // Change height of the camera with mouseY
 /*camera(30.0, mouseY * 10, 220.0, // eyeX, eyeY, eyeZ
         0.0, 0.0, 0.0, // centerX, centerY, centerZ
         0.0, 1.0, 0.0); // upX, upY, upZ*/
         
   lights();
  background((int)fft.calcAvg(10, 20000) * 10 + 80);
  
  //camera shit
  float cameraY = (height/2.0);
  float fov = (mouseX /float(width) * PI/2) * -1;
  float cameraZ = cameraY / tan(fov / 2.0);
  float aspect = float(width)/float(height);
  if (mousePressed) {
    aspect = aspect / 2.0;
  }
  perspective(fov, aspect, cameraZ/10.0, cameraZ*10.0);
  translate(width/2+30, height/2, 0);
  rotateX(-PI/6);
  rotateY(PI/3 + mouseY/float(height) * PI);

  
 //draw FFT
 translate(0, -1*height, 0); 
 
 fft.forward(in.mix);
 //print(fft.calcAvg(10, 20000));

  for(int i = 0; i < fft.specSize(); i++)
  {
    // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
    //line(i, height + (pow(fft.getBand(i), power)*6), timer,  i+1,height + (pow(fft.getBand(i+1), power)*6), timer);
    
    geomBuffer[timer][i] = fft.getBand(i);
  }
  
  stroke(timer, timer - 100, timer -50);
  
  for (int i = 0; i <= timer; i++) {
     beginShape();
      for (int e = 0; e < fft.specSize(); e++) {
        vertex(e * xStretch, height + (pow(geomBuffer[i][e], power)*6), i * timeStretch);
      }
        vertex(0,height, i * timeStretch);
      endShape(CLOSE);
  }
      

  //translate(0,0,0);
  
  if (timer < timerMax) {
    timer = timer + 1;
  } else {
    timer = 0;
     background((int)fft.calcAvg(10, 20000) * 10 + 80);
  }
  
  //Draw axes
  stroke(255,0,0);
  line (0,height,0,50,height,0); //x+ axis
  stroke(0,0,255);
  line (0,height,0,0,height+50,0); //y+ axis
  stroke(0,255,0);
  line (0,height,0,0,height,50); //z axis
  stroke(255);
  fill(255);


}

void mousePressed() {
   background((int)fft.calcAvg(10, 20000) * 10 + 80);
}
 
 
void stop()
{
  // always close Minim audio classes when you are done with them
  in.close();
  minim.stop();
 
  super.stop();
}
