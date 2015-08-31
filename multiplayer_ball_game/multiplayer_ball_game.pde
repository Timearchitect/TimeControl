
/**------------------------------------------------------------//
 //                                                            //
 //  Coding dojo  - Prototype of a timecontrol game            //
 //  av: Alrik He    v.0.6.5                                   //
 //  Arduino verstad Malmö                                     //
 //                                                            //
 //      2014-09-21                                            //
 //                                                            //
 //                                                            //
 --------------------------------------------------------------*/
import processing.opengl.*;
import beads.*;
import java.util.Arrays; 
AudioContext  ac = new AudioContext();
AudioContext an= new AudioContext();
Noise n = new Noise(an);
SamplePlayer musicPlayer;
Envelope speedControl;
Gain   g = new Gain(ac, 1, 0.05); //volume

PFont font;
PGraphics GUILayer;
PShader  Blur;
boolean slow, reverse, fastForward, freeze, controlable=true, cheatEnabled, origo, noisy;
final int speedFactor= 3;
final float slowFactor= 0.3;
static long prevMillis, addMillis, forwardTime, reversedTime, freezeTime, stampTime, fallenTime;
final String version="0.6.5";
import processing.serial.*;
final int baudRate= 19200;
final static float FRICTION=0.1;
final int AmountOfPlayers=4; // start players
final int startBalls=5;
final int  ballSize=50;
final int playerSize=100;
int playersAlive; // amount of players alive
int offsetX=950, offsetY=100;
static int shakeTimer;
static float F=1, S=1;
//int keyCooldown[]= new int[AmountOfPlayers];
final int keyResponseDelay=30;  // eventhe refreashrate equa to arduino devices

Serial port[]=new Serial[AmountOfPlayers];  // Create object from Serial class
String portName[]=new String[AmountOfPlayers];

ArrayList <Player> players = new ArrayList<Player>();
ArrayList <TimeStamp> stamps= new ArrayList<TimeStamp>();
ArrayList <Projectile> projectiles = new ArrayList<Projectile>();
ArrayList <Particle> particles = new ArrayList<Particle>();

Ability abilityList[] = new Ability[]{
  new FastForward(),
  new Freeze(),
  new Reverse(),
  new Slow(),
  new SaveState(),
  new ThrowDagger(),
  //new ForceShoot(),
  new Blink(),
  new Multiply(),
  new Stealth(),
  //new Laser(),
  //new TimeBomb(),
  new RapidFire(),
  new MachineGunFire(),
  new Battery(),
  //new ThrowBoomerang(){{ reset();}},
  //new PhotonicPursuit(){{ reset();}},
  //new DeployThunder(){{ reset();}},
  //new DeployShield(){{ reset();}},
  new DeployElectron(){{ reset();}},
 // new Gravity(){{ reset();}}
};

Ability[] abilities= { 
  new Random().randomize(), new Random().randomize(), new Random().randomize(), new Random().randomize(), new Random().randomize()
  };

char keyRewind='r', keyFreeze='v', keyFastForward='f', keySlow='z', keyIceDagger='p', ResetKey='0';
int playerControl[][]= {
  {
    UP, DOWN, LEFT, RIGHT, int(',')
  }
  , {
    int('w')-32, int('s')-32, int('a')-32, int('d')-32, int('t')-32
  }
  , 
  {
    888, 888, 888, 888, 888 // mouse
  }
    , {
    int('i')-32, int('k')-32, int('j')-32, int('l')-32, int('ö')-32
  }
  , {
    int('g')-32, int('b')-32, int('v')-32, int('n')-32, int('m')-32
  }
};
boolean sketchFullScreen() {
  return false;
}

void setup() {

  size(displayWidth, displayHeight, P3D);
  font= loadFont("PressStart2P-Regular-28.vlw");
  Blur= loadShader("blur.glsl");
  textFont(font, 18);
  randomSeed(12345);
  noSmooth();
  //noCursor();
  colorMode(HSB);
  for (int i=0; i< AmountOfPlayers; i++) {
    players.add(new Player(i, color((255/AmountOfPlayers)*i, 255, 255), int(random(width-playerSize*1)+playerSize), int(random(height-playerSize*1)+playerSize), playerSize, playerSize, playerControl[i][0], playerControl[i][1], playerControl[i][2], playerControl[i][3], playerControl[i][4], abilities[i]));

    if (players.get(i).mouse)players.get(i).friction=0.11; //mouse
  }
  for (int i=0; i< startBalls; i++) {
    projectiles.add(new Ball(int(random(width-ballSize)+ballSize*0.5), int(random(height-ballSize)+ballSize*0.5), int(random(20)-10), int(random(20)-10), int(random(ballSize)+10), color(random(255), 0, 0)));
  }
  println("amount of serial ports: "+Serial.list().length);
  for (int i=0; i<Serial.list ().length; i++) {
    portName[i] = Serial.list()[i];   // du kan också skriva COM + nummer på porten   
    port[i] = new Serial(this, portName[i], baudRate);   // du måste ha samma baudrate t.ex 9600
    // println(port[i].available());
    //println(portName[i]);
    players.get(i).MAX_ACCEL=0.16;
    players.get(i).DEFAULT_MAX_ACCEL=0.16;
    players.get(i).arduino=true;
    players.get(i).friction=0.062;
  }
  GUILayer= createGraphics(width, height);
  GUILayer.beginDraw();
  GUILayer.noStroke();
  GUILayer.fill(0);
  GUILayer.endDraw();
  drawTimeSymbol();
  prevMillis=millis(); // init time

  try {  
    // initialize the SamplePlayer
    //musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/TooManyCooksAdultSwim.mp3"));
      musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/Velocity.mp3")); 
    //musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/Branching time.mp3")); 
    // musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/orange caramel -aing.mp3"));
    // musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/goodbye.mp3"));
   // musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/wierd.mp3"));
  }
  catch(Exception e) {
    println("Exception while attempting to load sample!");
    e.printStackTrace(); // then print a technical description of the error
    exit(); // and exit the program
  }

  g.addInput(musicPlayer);
  ac.out.addInput(g);
  speedControl = new Envelope(ac, 1);
  musicPlayer.setPosition(2500);
  musicPlayer.setRate(speedControl); // yo
  musicPlayer.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  //  speedControl.addSegment(1, 3000); //now rewind
  ac.start(); //start music


  Gain g2 = new Gain(an, 1, 0);
  g2.addInput(n);
  an.out.addInput(g2);
  an.start();  //start noise

  particles.add(new Flash(1500, 5, color(255)));   // flash
  particles.get(0).opacity=0;
}


void draw() {
  addMillis=millis()-prevMillis;
  prevMillis=millis();
  if (origo) {
    fallenTime+=addMillis*F*S;
    background(255);
  } else {
    pushMatrix();
  screenShake();

    fill(100);

    if (fastForward) {
      fill(240, 200, 255, 70);
    }
    if (slow) {
      fill(240, 10*F, 250, 20);
    }
    if (freeze) {
      fill(150, 200, 255);
    }
    if (freeze) {
      freezeTime+=addMillis;
    } else {
      if (reverse) {
        if (stampTime<6000) {
          Gain g3 = new Gain(an, 1, 0.0);
          g3.setGain((6000-stampTime)*0.0000001);
          if (!noisy)g3.addInput(n);

          an.out.addInput(g3);

          shake(int((6000-stampTime)*0.01) );
          noisy=true;
        } else {

          shake(4);
        }
        fill(40, 200*F*S, 255*F);
        reversedTime+=addMillis*F*S;
      } else {
        forwardTime+=addMillis*F*S;
      }
      if (stampTime<0 && reverse) {   // origin of time
        musicPlayer.pause(true);
        origo=true;
      }
      stampTime=forwardTime-reversedTime;
  
    }
    // prevMillis=millis();
    // println("stampTime"+stampTime);
    // println("forward"+forwardTime);
    // println("reverse"+reversedTime);
    noStroke();
    rect(0-10, 0-10, width+20, height+20); // background


    //--------------------- projectiles-----------------------


    for (int i= projectiles.size ()-1; i>= 0; i--) { // checkStamps
      projectiles.get(i).update();  
      projectiles.get(i).display();
      projectiles.get(i).revert();
    }


    //-----------------------  particles------------------------


    for (int i=particles.size ()-1; i>= 0; i--) { // checkStamps
      particles.get(i).update();  
      particles.get(i).display();
      particles.get(i).revert();
    }

    //-----------------------  USB ------------------------

    for (int i=0; i<Serial.list ().length; i++) {   // USB devices
      if (portName[i]!= null && port[i].available() > 0) {  //ta in data och ignorerar skräpdata    
        players.get(i).control(port[i].read());
        // println("INPUT!!!!!!!!!!!!!!!!!!!!!!!");
      }
    }

    checkPlayerVSPlayerColloision();
    checkPlayerVSProjectileColloision();

    for (int i=0; i<players.size (); i++) {       
      if (!players.get(i).dead) {

        if (reverse && !players.get(i).reverseImmunity) {
          players.get(i).display();
          if (!freeze ||  players.get(i).freezeImmunity) {
            // players.get(i).checkBounds();
            players.get(i).mouseControl() ;
            players.get(i).update();
          }
        } else {
          if (!freeze || players.get(i).freezeImmunity) {
            players.get(i).mouseControl() ;
            players.get(i).update();
            players.get(i).checkBounds();
          }
          players.get(i).display();
        }
      }
      if (freeze) {
        colorMode(RGB);
        for (int b=0; b<2; b++) {
          filter(Blur);
        }
      } else {   
        colorMode(HSB);
      }
      if (slow) {
        noStroke();
        fill(0, 0, 0, 30);
        rect(0-10, 0-10, width+20, height+20); // background
      }
      image(GUILayer, 0, 0);
    }
    mouseDot();
    checkKeyHold();
    for (int i=stamps.size ()-1; i>= 0; i--) { // checkStamps
      // stamps.get(i).display(); // hid this when not DEBUGGING
      stamps.get(i).revert();
    }
    checkWinner();

    popMatrix();

    for (int i=0; i<players.size (); i++) {    // resetstate
      if (!players.get(i).dead) {
        players.get(i).state=0;
        players.get(i).hit=false;
      }
    }
  }// origo
  // prevMillis=millis();
  if (cheatEnabled) {
    displayInfo();
  } else {
    displayClock();
  }
}

