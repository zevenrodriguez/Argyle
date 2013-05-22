 
/////////////////////////////////////////
////////////// controls /////////////////
/////////////////////////////////////////
int howManyNotes = 12;
public static final int radiusOfCircleSquared = 25;
int[] majorScaleMask = {
  1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1
};
int backgroundEnabled = 1; // the background color will be "no sound"
int trainingDelay = 200;

//Save colors
String colors[] = new String[howManyNotes];
Boolean noData = false;

//set toggle for off
int brightToggle = 5;
boolean off = false;



/////////////////////////////////////////
////////////// setup /////////////////
/////////////////////////////////////////
import processing.video.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import processing.net.*;

boolean clicked=false;
Capture video;
PImage vidImg;
int centerIndex;
float currentHue;
float avgHue;
float currentBrightness;
float avgBrightness;

int trainingFlag;
int training;

float rtrained[];
float gtrained[];
float btrained[];


int[] rpix;
int[] bpix;
int[] gpix;

AudioOutput out;
SineWave sine1;
SineWave sine2;
SineWave sine3;
SineWave sine4;
SineWave sine5;
Minim Minim;

float semitoneRatio;
float[] semitoneList;
//short[][] circleMask;
int scaleIndex;
int freqIndex;
float[] majorScaleFreqs;
int numNotes;

float freq;
int currentFreqIndex = 0;

int ctrx;
int ctry;

int currentNote = -100;

AudioSample notes[];

void setup() {

  size(320, 240, P2D);
  frameRate(10);


  Minim = new Minim(this);
  notes = new AudioSample[12];
  notes[0] = Minim.loadSample( "C.mp3", 512);
  notes[1] = Minim.loadSample( "D.mp3", 512);
  notes[2] = Minim.loadSample( "E.mp3", 512);
  notes[3] = Minim.loadSample( "F.mp3", 512);
  notes[4] = Minim.loadSample( "G.mp3", 512);
  notes[5] = Minim.loadSample( "HA.mp3", 512);
  notes[6] = Minim.loadSample( "HB.mp3", 512);
  notes[7] = Minim.loadSample( "HC.mp3", 512);
  notes[8] = Minim.loadSample( "HD.mp3", 512);
  notes[9] = Minim.loadSample( "HE.mp3", 512);
  notes[10] = Minim.loadSample( "HF.mp3", 512);
  notes[11] = Minim.loadSample( "HG.mp3", 512);

  if (backgroundEnabled==1)
  {
    howManyNotes ++; // to account for background
  }


  rtrained = new float[howManyNotes];
  gtrained = new float[howManyNotes];
  btrained = new float[howManyNotes];

  String lines[] = loadStrings("data.txt");

  //println(lines.length);

  if (lines.length == 0) {
    noData = true;
  }

  if (lines.length > 0) {
    for (int i = 0; i<lines.length; i++) {
      //println(lines[i].length());
      if (lines[i].equals("null")) {
        noData = true;
        //println(noData);
        break;
      }
    }

    if (noData == false) {
      for (int i = 0; i<lines.length; i++) {
        String[] temp = split(lines[i], ',');
        //println(temp.length);
        rtrained[i]=Float.parseFloat(temp[0]);
        gtrained[i]=Float.parseFloat(temp[1]);
        btrained[i]=Float.parseFloat(temp[2]);
      }
    }
  }

  println(noData);

  String[] cameras = Capture.list();
  println(cameras);

  training=0;

  // makes array of 157 gets filled up?
  rpix = new int[int(PI*radiusOfCircleSquared*2)];
  gpix = new int[int(PI*radiusOfCircleSquared*2)];
  bpix = new int[int(PI*radiusOfCircleSquared*2)];


  //try{
  video = new Capture(this, cameras[22]);
  //}catch{

  //}
  video.start();
  vidImg = createImage(width, height, ARGB);  
  centerIndex = int(((width * height) / 2.0));
  currentHue = 0;
  avgHue = 0;
  currentBrightness = 0;
  avgBrightness = 0;
  rectMode(CENTER);
  ctrx = width / 2;
  ctry = height / 2;
}

int calcClosest(float[] rr, float[] gg, float[] bb, float r, float g, float b, int tot)
{
  float minDist=1000000; // 10 million is more than 255*255*3, so initialized high
  float currDist;
  int minIndex=-1;
  float rdif;
  float gdif;
  float bdif;
  float r2;
  float g2;
  float b2;
  for (int i=0;i<tot;i++)
  {
    rdif=rr[i]-r;
    r2=rdif*rdif;
    gdif=gg[i]-g;
    g2=gdif*gdif;
    bdif=bb[i]-b;
    b2=bdif*bdif;
    currDist=r2+g2+b2;

    //println(currDist);

    //println(minDist);


    if (currDist<minDist)
    {
      //println("currDist");
      minDist=currDist;
      minIndex=i;
    }
  }

  minDist=sqrt(minDist);
  //println(minIndex);

  if (minDist<100)
  {
    return minIndex;
  }
  else
  {
    return -1;
  }
}

float mean(int[] pix, int tot)
{
  float sum=0;
  for (int i=0;i<tot;i++)
  {
    sum += pix[i];
  }
  return (sum/tot);
}

float std(int[] pix, int tot, float mean)
{
  float sum=0;
  float diff;
  float diffSquared;
  float stdAnswer;
  for (int i=0;i<tot;i++)
  {
    diff=(pix[i]-mean);
    diffSquared=diff*diff;
    sum += diffSquared;
  }
  stdAnswer = sqrt(sum/tot);
  return stdAnswer;
}





void train(float r, float b, float g, float sr, float sb, float sg, int num)
{
}



void captureEvent(Capture c) {
  c.read();
}

void draw() 
{
  video.read();
  video.loadPixels();
  image(video, 0, 0); 
  trainingFlag=0;

  if ((keyPressed)&&(training<howManyNotes))
  {
    delay(trainingDelay);
    trainingFlag=1;
    //println(training);
  }

  if ((training>(howManyNotes-1))||(trainingFlag==1) || (noData == false))
  {

    if ((training == howManyNotes-1) && (noData == true) ) {
      saveStrings("data/data.txt", colors);
      println("saved");
    }


    int r = 0;
    int g = 0;
    int b = 0;
    int nAvg = 10;
    float distanceSquared = radiusOfCircleSquared;
    int x;
    int y;
    double xDist;
    double yDist;
    double totalDistSquared;
    int loopCount=0;
    for (int i=0; i<nAvg; i++) {
      for (int j=0; j<nAvg; j++) {
        x=ctrx-(nAvg/2)+i;
        y=ctry-(nAvg/2)+j;
        xDist=ctrx-x;
        yDist=ctry-y;
        totalDistSquared = (xDist*xDist)+(yDist*yDist);
        //      if(circleMask[ctrx - (nAvg/2) + i][ctry-(nAvg/2)+j]==1)
        //      {

        if ( totalDistSquared < distanceSquared )
        {
          color c = video.get(x, y);
          r += (c >> 16) & 0xFF;
          rpix[loopCount]=(c >> 16) & 0xFF;
          g += (c >> 8) & 0xFF;
          gpix[loopCount]=(c >> 8) & 0xFF;
          b += c & 0xFF;
          bpix[loopCount]=c & 0xFF;
          ;
          video.set(ctrx - (nAvg/2) + i, ctry-(nAvg/2)+j, color(0));
          loopCount++;
        }
        //      }
      }
    }
    float meanr=mean(rpix, loopCount);
    float meanb=mean(bpix, loopCount);
    float meang=mean(gpix, loopCount);

    float stdr=std(rpix, loopCount, meanr);
    float stdb=std(bpix, loopCount, meanb);
    float stdg=std(gpix, loopCount, meang);

    if (training<howManyNotes-1 && (noData))
    {
      println(training);
      //train(meanr, meanb, meang, stdr, stdb, stdg, training-1);  
      rtrained[training]=meanr;
      gtrained[training]=meang;
      btrained[training]=meanb;
      print(" ");
      print(meanr);
      print(" ");
      print(meang);
      print(" ");
      print(meanb);
      println(" ");

      if (training<howManyNotes-1) {
        colors[training] = Float.toString(meanr) + "," + Float.toString(meang) + "," + Float.toString(meanb);
      }
    }


    r = int(r / (nAvg*nAvg));
    g = int(g / (nAvg*nAvg));
    b = int(b / (nAvg*nAvg));


    colorMode(RGB);
    color c = color(r, g, b);
    currentHue = hue(c);
    //avgHue = (avgHue + currentHue) / 2.0;
    avgHue = currentHue;
    currentBrightness = brightness(c);
    //println(currentBrightness);
    avgBrightness = (avgBrightness + currentBrightness) / 2.0;
    image(video, 0, 0); 
    colorMode(HSB);
    fill(avgHue, 255, avgBrightness, 200);
    translate(width/2.0, height/2.0);
    ellipse(0, 0, 50, 50);

    if (currentBrightness < brightToggle) {
      off = true;
    }
    else {
      off = false;
    }



    if (training<howManyNotes && (noData) )
    {
      /*
      sine1.setAmp(1);
       sine1.setFreq(majorScaleFreqs[training+14]);
       */
    }

    else if (training>howManyNotes || off == false)
    {
      int note=calcClosest(rtrained, gtrained, btrained, meanr, meang, meanb, howManyNotes);
      
      if (currentNote != note) {

        if (note >= 0  && note <= 11) {

          notes[note].trigger();
        }
        
        currentNote = note;
      }
    }

    float amp = avgBrightness / 255.0;

    //println(currentHue);
    training++;
    // println(training);
  }
}


void keyPressed() {
  if (key == 'p') {

    noData = true;
    training = 0;
  }

  if ( key == 'a' ) notes[0].trigger();
  if ( key == 's' ) notes[1].trigger();
  if ( key == 'd' ) notes[2].trigger();
  if ( key == 'f' ) notes[3].trigger();
  if ( key == 'g' ) notes[4].trigger();
  if ( key == 'h' ) notes[5].trigger();
  if ( key == 'j' ) notes[6].trigger();
  if ( key == 'k' ) notes[7].trigger();
  if ( key == 'l' ) notes[8].trigger();
  if ( key == ';' ) notes[9].trigger();
  if ( key == 'z' ) notes[10].trigger();
  if ( key == 'x' ) notes[11].trigger();
}
