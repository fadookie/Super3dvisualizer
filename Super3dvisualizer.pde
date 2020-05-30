/**
 * Super3dvisualizer, a 3D Surface Spectogram Audio Visualizer in Processing
 *
 * @author Eliot Lash
 * @copyright Copyright (c) 2010-2012 Eliot Lash
 */
import ddf.minim.analysis.*;
import ddf.minim.*;
import peasy.*;
import java.io.*;

Minim minim;
AudioInput in;
AudioPlayer groove;
FFT fft;
PeasyCam cam;

static int sampleRate = 512;

int bufferStart = 0;
static int bufferMax = 100;
float countRad = 0;

static float power = 1.5;
static float xStretch = 5.0;
static float yStretch = 1.0;
static float zStretch = 5.0;

float cameraCenterX = 255;
float cameraCenterY = 0;
float cameraCenterZ = 255;

static float alphaCycle = 0.03;

float savedmouseX;
float savedmouseY;
float savedmouseZ = 220.0;

float[][] geomBuffer;

void setup()
{
  size(851, 800, P3D);
 
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(800);
  CameraState camState = readCameraData();
  if(camState != null) {
    cam.setState(camState);
  }
 
  minim = new Minim(this);
  //minim.debugOn();
 
  // get a line in from Minim, default bit depth is 16
  in = minim.getLineIn(Minim.STEREO, sampleRate);
  in.mute();
  
  groove = minim.loadFile("Legacy.mp3", sampleRate);
  groove.play();
  
  fft = new FFT(groove.bufferSize(), groove.sampleRate());
    fft.logAverages(22, 3);
    
  geomBuffer = new float[bufferMax][fft.specSize()];
  
  for(int i = 0; i < fft.specSize(); i++)
  {    
    geomBuffer[bufferStart][i] = fft.getBand(i);
  }
  
  //frameRate(1);
//smooth();


}
 
void draw()
{
//  stroke(255);
//  // draw the waveforms
//  for(int i = 0; i < in.bufferSize() - 1; i++)
//  {
//    line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
//    line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
//  }
  
   // Change height of the camera with mouseY
 /*camera(30.0, mouseY * 10, 220.0, // eyeX, eyeY, eyeZ
         0.0, 0.0, 0.0, // centerX, centerY, centerZ
         0.0, 1.0, 0.0); // upX, upY, upZ*/
         
   //lights();
   
   background(10);
   
   specular(#00BFFF);
   lightSpecular(0, 191, 255);
   directionalLight(49, 140, 231, 0, 0, -1);
  //background((int)fft.calcAvg(10, 20000) * 10 + 80);
 
  
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
  
  // camera(savedmouseX, savedmouseY, savedmouseZ, // eyeX, eyeY, eyeZ
  //       cameraCenterX, cameraCenterY, cameraCenterZ, // centerX, centerY, centerZ
  //       0.0, -1.0, 0.0); // upX, upY, upZ
         
 //draw FFT
 translate(0, -1*height, 0); 
 
 fft.forward(groove.mix);
 //fft.forward(groove.mix);
 //print(fft.calcAvg(10, 20000));
  
  //fill(bufferStart, bufferStart - 100, bufferStart -50);
  //fill(#FF7E00);
  //noStroke();
  float colorPercentage = ((sin(countRad) * 0.5 + 0.5) * 255);
  
  fill(#00BFFF, colorPercentage);
  //println(colorPercentage);
  stroke(#00BFFF);
  strokeWeight(1);

      //Evil hack to draw over the gap left by an error in how we implemented our ring buffer - this is the "scan line
     beginShape(QUAD_STRIP);
      for (int band = 0; band < fft.specSize(); band++) {
        int i = bufferStart % (geomBuffer.length - 1);
        
        if ((i + 1) < geomBuffer.length) {
        vertex((band)* xStretch, height + pow(geomBuffer[i][band], power) * yStretch, bufferStart * zStretch);
        vertex((band)* xStretch, height + pow(geomBuffer[i + 1][band], power) * yStretch, (bufferStart+1) * zStretch);
        } else {
          print ("i == "+ i +". geomBuffer.length == " + geomBuffer.length + ". i >= geomBuffer.length. Waaah!\n");
        }
      }
      endShape();
      
//      beginShape(TRIANGLE_STRIP);
//      int bufferHack = bufferStart - 1;
//      if (bufferHack != -1) {
//        for (int band = 0; band < fft.specSize(); band++) {
//          int i = bufferHack % (geomBuffer.length - 1);
//          
//          if ((i + 1) < geomBuffer.length) {
//          vertex((band)* xStretch, height + geomBuffer[i][band] * yStretch, bufferHack * zStretch);
//          vertex((band)* xStretch, height + geomBuffer[i + 1][band] * yStretch, (bufferHack+1) * zStretch);
//          } else {
//            print ("i == "+ i +". geomBuffer.length == " + geomBuffer.length + ". i >= geomBuffer.length. Waaah!\n");
//          }
//        }
//        endShape();
//      }
  
  float redFactor = 30;
  float greenFactor = 0;
  float blueFactor = 200;
  
  for (int zPosition = bufferStart + 1; zPosition != bufferStart;) {

    //;pow(geomBuffer[i + 1][band], power) * -1
   //println(bufferStart + " " + zPosition);


      beginShape(TRIANGLE_STRIP);
      for (int band = 0; band < fft.specSize(); band++) {
        greenFactor += 0.004;
        int i = (bufferStart + zPosition) % (geomBuffer.length -1);
        
        stroke(redFactor, greenFactor, blueFactor);
        
        if ((i + 1) < geomBuffer.length) {
        vertex((band)* xStretch, height + pow(geomBuffer[i][band], power) * yStretch, zPosition * zStretch);
        vertex((band)* xStretch, height + pow(geomBuffer[i + 1][band], power) * yStretch, (zPosition+1) * zStretch);
        } else {
          print ("i == "+ i +". geomBuffer.length == " + geomBuffer.length + ". i >= geomBuffer.length. Waaah!\n");
        }
      }
      endShape();

      
      
    zPosition++;
    if(zPosition >= geomBuffer.length)
    {
      zPosition = 0;
    }
  }
  
  //Update our FFT data
  for(int i = 0; i < fft.specSize(); i++)
  {    
    geomBuffer[bufferStart][i] = fft.getBand(i);
  }

  
  if (bufferStart < bufferMax - 1) {
    bufferStart++;
  } else {
    bufferStart = 0;
  }
  
  if (countRad < 6.28) {
    countRad += alphaCycle;
  } else {
    countRad = 0;
  }
  //Draw X, Y, Z axis
  stroke(255,0,0);
  line (0,height,0,50,height,0); //x+ axis
  stroke(0,255,0);
  line (0,height,0,0,height+50,0); //y+ axis
  stroke(0,0,255);
  line (0,height,0,0,height,50); //z axis
  stroke(255);
  fill(255);


}

void mouseDragged() {
   savedmouseX = mouseX;
   savedmouseY = mouseY;
}
 
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      savedmouseZ += 100;
    } else if(keyCode == DOWN) {
      savedmouseZ -= 100;
    } else if(keyCode == LEFT) {
      cameraCenterX -= 100;
    } else if (keyCode == RIGHT) {
      cameraCenterX += 100;
    }
  } else {
    if (key == 'c') {
      saveCameraData();
    }
  }
}

void saveCameraData() {
  println("try to write camera state to " + sketchPath("camera.data"));
  FileOutputStream f_out = null;
  ObjectOutputStream obj_out = null;
  try {
    f_out = new FileOutputStream(sketchPath("camera.data"));
    obj_out = new ObjectOutputStream(f_out);
    CameraState state = cam.getState();
    obj_out.writeObject(state);
    println("wrote camera data");
  } catch (Exception e) {
    println(e);
  } finally {
    try {
      if (f_out != null) f_out.close();
      if (obj_out != null) obj_out.close();
    } catch (Exception e) {}
  }
}

CameraState readCameraData() {
  FileInputStream f_in = null;
  ObjectInputStream obj_in = null;
  try {
    f_in = new FileInputStream(sketchPath("camera.data"));
    obj_in = new ObjectInputStream(f_in);
    CameraState state = (CameraState)obj_in.readObject();
    return state;
  } catch (Exception e) {
    println(e);
  } finally {
    try {
      if (f_in != null) f_in.close();
      if (obj_in != null) obj_in.close();
    } catch (Exception e) {}
  }
  return null;
}
 
void stop()
{
  // always close Minim audio classes when you are done with them
  in.close();
  //groove.close();
  minim.stop();
 
  super.stop();
}
