/*
     Arduino - Processing Real Time Spectrum Analyzer
This program is intended output a FFT from a pc on a RGB matrix
The program is based on the adafruit RGB matrix library: https://learn.adafruit.com/32x16-32x32-rgb-led-matrix/
The FFT results in the complimentary processing code handles 64 bands so the code calls for 2 panels, but can be modified for only one easily
More information, including full parts list and videos of the final product can be seen on 12vtronix.com
Youtube video sample: https://www.youtube.com/watch?v=X35HbE7k3DA
           Created: 22nd Sep 2013 by Stephen Singh
     Last Modified: 10th May 2014 by Stephen Singh
     
     Variables with the <-O-> symbol indicates that it can be adjusted for the reason specified
*/

#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
#include <avr/power.h>
#endif
#define PIN 6

#define CLK 8  // MUST be on PORTB!
#define LAT A3
#define OE  9
#define A   A0
#define B   A1
#define C   A2
// Last parameter = 'true' enables double-buffering, for flicker-free,
// buttery smooth animation.  Note that NOTHING WILL SHOW ON THE DISPLAY
// until the first call to swapBuffers().  This is normal.
//RGBmatrixPanel matrix(A, B, C, CLK, LAT, OE, true);

Adafruit_NeoPixel strip = Adafruit_NeoPixel(144, PIN, NEO_GRB + NEO_KHZ800);


int prevBassVolume = 0;
bool peakReached = 0;
int bassPeakMinimum = 20;



void setup() 
{ 
  strip.begin();
  strip.show(); // initialize all pixels to 'off'
  strip.setBrightness(255);
  
  Serial.begin(115200);
  pinMode(3, OUTPUT);
  digitalWrite(3, HIGH);
  delay(1000);
  digitalWrite(3, LOW);
}



void loop() { 
  int bassVolume = Serial.read();
  
  // if we are just about to descend the peak play the lights
  if(bassVolume < prevBassVolume && prevBassVolume >= bassPeakMinimum && !peakReached){
    setOn(0, 143);
    setAllOff();
    peakReached = 1;
  }
  // if we start climbing the wave again
  if(bassVolume > prevBassVolume){
    peakReached = 0;
  }    
  prevBassVolume = bassVolume;
}



void setAllOff(){
  for(int x = 0; x < 144; x++){
    strip.setPixelColor(x, 0, 0, 0);  
  }
  strip.show();
}



void setAllOn(){
  for(int x = 0; x < 144; x++){
    strip.setPixelColor(x, 0, 255, 0);  
  }
  strip.show();
}



void setOn(int start, int end){
  for(int x = start; x <= end; x++){
    strip.setPixelColor(x, 0, 255, 0);  
  }
  strip.show();
}



void setOff(int start, int end){
  for(int x = start; x <= end; x++){
    strip.setPixelColor(x, 0, 0, 0);  
  }
  strip.show();
}

