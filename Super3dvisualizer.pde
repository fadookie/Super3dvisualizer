import ddf.minim.analysis.*;
import ddf.minim.*;
 
Minim minim;
AudioInput in;
FFT fft;

static int sampleRate = 64;
static int power = 1;
int timer = 0;
static int timerMax = 100;
static float xStretch = 5.0;
static float yStretch = 8.0;
static float zStretch = 5.0;
float savedmouseX;
float savedmouseY;

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
  
  //frameRate(1);


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
  float fov = (savedmouseX /float(width) * PI/2) * -1;
  float cameraZ = cameraY / tan(fov / 2.0);
  float aspect = float(width)/float(height);
  if (mousePressed) {
    aspect = aspect / 2.0;
  }
  perspective(fov, aspect, cameraZ/10.0, cameraZ*10.0);
  translate(width/2+30, height/2, 0);
  rotateX(-PI/6);
  rotateY(PI/3 + savedmouseY/float(height) * PI);

  
 //draw FFT
 translate(0, -1*height, 0); 
 
 fft.forward(in.mix);
 //print(fft.calcAvg(10, 20000));

  for(int i = 0; i < fft.specSize(); i++)
  {    
    geomBuffer[timer][i] = fft.getBand(i);
  }
  
  fill(timer, timer - 100, timer -50);
  stroke(0);
  strokeWeight(2);
  
  for (int time = 0; time < timer; time++) {
     beginShape(TRIANGLE_STRIP);
      for (int band = 0; band < fft.specSize(); band++) {
        vertex((band)* xStretch, height + geomBuffer[time][band] * yStretch, time * zStretch);
        vertex((band)* xStretch, height + geomBuffer[time+1][band] * yStretch, (time+1) * zStretch);
      }
        //vertex(0,height, time * zStretch);
      endShape();
  }
      

  //translate(0,0,0);
  
  if (timer < timerMax) {
    timer = timer + 1;
  } else {
    timer = 0;
  }
  
  //Draw X, Y, Z axis
  stroke(255,0,0);
  line (0,height,0,50,height,0); //x+ axis
  stroke(0,0,255);
  line (0,height,0,0,height+50,0); //y+ axis
  stroke(0,255,0);
  line (0,height,0,0,height,50); //z axis
  stroke(255);
  fill(255);


}

void mouseDragged() {
   savedmouseX = mouseX;
   savedmouseY = mouseY;
}
 
 
void stop()
{
  // always close Minim audio classes when you are done with them
  in.close();
  minim.stop();
 
  super.stop();
}
