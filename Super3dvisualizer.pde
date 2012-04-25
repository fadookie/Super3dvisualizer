import ddf.minim.analysis.*;
import ddf.minim.*;
 
Minim minim;
AudioInput in;
AudioPlayer groove;
FFT fft;

static int sampleRate = 512;

int bufferStart = 0;
static int bufferMax = 100;

static float power = 0.5;
static float xStretch = 5.0;
static float yStretch = 8.0;
static float zStretch = 5.0;

float savedmouseX;
float savedmouseY;

float[][] geomBuffer;

float[] sample;

void setup()
{
  size(800, 800, P3D);
 
  minim = new Minim(this);
  //minim.debugOn();
 
  // get a line in from Minim, default bit depth is 16
  in = minim.getLineIn(Minim.STEREO, sampleRate);
  in.mute();
  
  groove = minim.loadFile("Legacy.mp3", sampleRate);
  groove.play();
  
  fft = new FFT(in.bufferSize(), in.sampleRate());
    fft.logAverages(22, 3);
    
   sample = groove.mix.toArray();
    
  geomBuffer = new float[bufferMax][sample.length];
  
  print ("geomBuffer.length == "+geomBuffer.length); 
  
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
  /*float cameraY = (height/2.0);
  float fov = (savedmouseX /float(width) * PI/2) * -1;
  float cameraZ = cameraY / tan(fov / 2.0);
  float aspect = float(width)/float(height);
  if (mousePressed) {
    aspect = aspect / 2.0;
  }
  perspective(fov, aspect, cameraZ/10.0, cameraZ*10.0);
  translate(width/2+30, height/2, 0);
  rotateX(-PI/6);
  rotateY(PI/3 + savedmouseY/float(height) * PI);*/
  
   camera(mouseX, mouseY, 220.0, // eyeX, eyeY, eyeZ
         0.0, 0.0, 0.0, // centerX, centerY, centerZ
         0.0, -1.0, 0.0); // upX, upY, upZ
         
  
 //draw FFT
 translate(0, -1*height, 0); 
 
 //fft.forward(in.mix);
 sample = groove.mix.toArray();
 fft.forward(groove.mix);
 //print(fft.calcAvg(10, 20000));

  for(int i = 0; i < sample.length; i++)
  {    
    geomBuffer[bufferStart][i] = sample[i];
  }
  
  fill(bufferStart, bufferStart - 100, bufferStart -50);
  //noStroke();
  stroke(0);
  strokeWeight(2);
  
  for (int time = 0; time < bufferStart; time++) {
     beginShape(TRIANGLE_STRIP);
      for (int band = 0; band < sample.length; band++) {
        vertex((band)* xStretch, height + pow(geomBuffer[time][band], power) * yStretch, time * zStretch);
        vertex((band)* xStretch, height + pow(geomBuffer[time+1][band], power) * yStretch, (time+1) * zStretch);
      }
      endShape();
  }
  
  if (bufferStart < bufferMax - 1) {
    bufferStart++;
  } else {
    bufferStart = 0;
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
  groove.close();
  minim.stop();
 
  super.stop();
}
