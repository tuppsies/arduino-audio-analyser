/*
     Arduino - Processing Real Time Spectrum Analyzer
This program is intended to do a FFT on incoming audio signal for a line-in input on PC 
The program is based on http://processing.org/learning/libraries/forwardfft.html
The FFT results are sent to two arduinos via a string of 32 integers
More information, including full parts list and videos of the final product can be seen on 12vtronix.com
Youtube video sample: https://www.youtube.com/watch?v=X35HbE7k3DA
           Created: 22nd Sep 2013 by Stephen Singh
     Last Modified: 10th May 2014 by Stephen Singh
     
     Variables with the <-O-> symbol indicates that it can be adjusted for the reason specified
*/
 
import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.serial.*; 
 
Serial port1; 

Minim minim;
//AudioInput in;
AudioPlayer in;
FFT fft;
PrintWriter output;

int buffer_size = 4096; 
float sample_rate = 200000;

int freq_width = 250; // <-O-> set the frequency range for each band over 400hz. larger bands will have less intensity per band. smaller bands would result in the overall range being limited

//arrays to hold the 64 bands' data
int[] freq_array = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
float[] freq_height = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

void setup()
{
  //size(200, 200);
  output = createWriter("data.txt");

  printArray(Serial.list());
  minim = new Minim(this);
  port1 = new Serial(this, "COM3" , 115200); // <-O-> set baud rate and port for first RGB matrix  
  in = minim.loadFile("sample2.mp3");
 
  // create an FFT object that has a time-domain buffer 
  // the same size as line-in's sample buffer
  fft = new FFT(in.bufferSize(), in.sampleRate());
  // Tapered window important for log-domain display
  fft.window(FFT.HAMMING);
}


void draw(){
   
  
  // initialise the array
   for(int k=0; k<64; k++){
     freq_array[k] = 0;
   }
  
  // play the track
  in.play();

  // perform a forward FFT on the samples in input buffer
  fft.forward(in.mix);
  
  freq_height[0] = fft.calcAvg((float) 0, (float) 30);
  freq_height[1] = fft.calcAvg((float) 31, (float) 60);
  freq_height[2] = fft.calcAvg((float) 61, (float) 100);
  freq_height[3] = fft.calcAvg((float) 101, (float) 150);
  freq_height[4] = fft.calcAvg((float) 151, (float) 200);
  freq_height[5] = fft.calcAvg((float) 201, (float) 250);
  freq_height[6] = fft.calcAvg((float) 251, (float) 300);
  freq_height[7] = fft.calcAvg((float) 301, (float) 350);
  freq_height[8] = fft.calcAvg((float) 351, (float) 400);
  
  for(int n = 9; n < 64; n++)
  {
  freq_height[n] = fft.calcAvg((float) (351+(freq_width*(n-9))), (float) (500+(freq_width*(n-9))));
  }
  
  freq_height[64] = (fft.calcAvg((float) 20, (float) 60));
  
  
  // <-O-> Log scaling function. Feel free to adjust x and y 
  float x = 8;
  float y = 3;
  for(int j=0; j<64; j++){    
    freq_height[j] = freq_height[j]*(log(x)/y);
    x = x + (x); 
  }
  

   

  // Amplitude Ranges  if else tree
    for(int j=0; j<65; j++){    
    if (freq_height[j] < 2000 && freq_height[j] > 180){freq_array[j] = 16;}
    else{ if (freq_height[j] <= 180 && freq_height[j] > 160){freq_array[j] = 15;}
    else{ if (freq_height[j] <= 160 && freq_height[j] > 130){freq_array[j] = 14;}
    else{ if (freq_height[j] <= 130 && freq_height[j] > 110){freq_array[j] = 13;}
    else{ if (freq_height[j] <= 110 && freq_height[j] > 90){freq_array[j] = 12;}
    else{ if (freq_height[j] <= 90 && freq_height[j] > 70){freq_array[j] = 11;}
    else{ if (freq_height[j] <= 70 && freq_height[j] > 60){freq_array[j] = 10;}
    else{ if (freq_height[j] <= 60 && freq_height[j] > 50){freq_array[j] = 9;}
    else{ if (freq_height[j] <= 50 && freq_height[j] > 40){freq_array[j] = 8;}
    else{ if (freq_height[j] <= 40 && freq_height[j] > 30){freq_array[j] = 7;}
    else{ if (freq_height[j] <= 30 && freq_height[j] > 20){freq_array[j] = 6;}
    else{ if (freq_height[j] <= 20 && freq_height[j] > 15){freq_array[j] = 5;}
    else{ if (freq_height[j] <= 15 && freq_height[j] > 11){freq_array[j] = 4;}
    else{ if (freq_height[j] <= 11 && freq_height[j] > 8){freq_array[j] = 3;}
    else{ if (freq_height[j] <= 8 && freq_height[j] > 5){freq_array[j] = 2;}
    else{ if (freq_height[j] <= 5 && freq_height[j] > 2){freq_array[j] = 1;}
    else{ if (freq_height[j] <= 2 && freq_height[j] > 0){freq_array[j] = 0;}
  }}}}}}}}}}}}}}}}}
  

  // get the time of the track for debugging purposes
  float timeMilli = in.position()/1000; 
  
  // add the values up just from the bass
  float bassTotal = 0;
  for(int z = 0; z < 3; z++){
      bassTotal += freq_array[z];
  }

  byte bassByte = (byte)(bassTotal);
  port1.write(bassByte);

  // print the information
  output.print(bassByte + " ");
  println(timeMilli + "\t\t" + bassTotal + "\t\t" + bassByte + "\n");
  delay(1); // don't overwork the program
}
 
 
void stop()
{
  // always close Minim audio classes when you finish with them
  in.close();
  minim.stop();
 
  super.stop();
}