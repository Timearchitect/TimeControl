
/**------------------------------------------------------------//
 //                                                            //
 //  Coding dojo  - Prototype of a timecontrol game            //
 //  av: Alrik He    v.0.5.0                                   //
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
SamplePlayer musicPlayer;
Envelope speedControl;
Gain   g = new Gain(ac, 1, 0.5); //volume
PFont font;
PGraphics GUILayer;
PShader  Blur;
boolean slow, reverse, fastForward, freeze, controlable=true, cheatEnabled=true;
final int speedFactor= 3;
final float slowFactor= 0.3;
static long prevMillis, addMillis, forwardTime, reversedTime, freezeTime, stampTime;
final String version="0.5.0";
import processing.serial.*;
final int baudRate= 19200;
final static float FRICTION=0.1;
final int AmountOfPlayers=4;
final int startBalls=5;
final int  ballSize=50;
final int playerSize=100;

int offsetX=950, offsetY=100;
static int shakeTimer;
static float F=1, S=1;
int keyCooldown[]= new int[AmountOfPlayers];
final int keyResponseDelay=30;  // eventhe refreashrate equa to arduino devices
//Ability[] abilities=  new  Ability[AmountOfPlayers];
//Ability[] abilities={new Reverse(),new Reverse(),new Reverse(),new Reverse()};
//Ability[] abilities={new FastForward(),new FastForward(),new FastForward(),new FastForward()};
//Ability[] abilities={new Freeze(),new Freeze(),new Freeze(),new Freeze()};
//Ability[] abilities= {  new FastForward(), new Freeze(), new Slow(), new Reverse()};
//Ability[] abilities= { new throwDagger(), new throwDagger(), new throwDagger(), new throwDagger()};
Ability[] abilities= { 
  new throwDagger(), new forceShoot(), new throwDagger(), new forceShoot()
};

Serial port[]=new Serial[AmountOfPlayers];  // Create object from Serial class
String portName[]=new String[AmountOfPlayers];
//int playerControl[]= new int[AmountOfPlayers];
ArrayList  <Ball> balls= new ArrayList<Ball>();
ArrayList <Player> players = new ArrayList<Player>();
ArrayList  <TimeStamp> stamps= new ArrayList<TimeStamp>();
ArrayList <Projectile> projectiles = new ArrayList<Projectile>();
ArrayList <Particle> particles = new ArrayList<Particle>();
char keyRewind='r', keyFreeze='v', keyFastForward='f', keySlow='z', keyIceDagger='p';
int playerControl[][]= {
  {
    UP, DOWN, LEFT, RIGHT, int(',')
  }
  , {
    int('w')-32, int('s')-32, int('a')-32, int('d')-32, int('t')-32
  }
  , {
    int('i')-32, int('k')-32, int('j')-32, int('l')-32, int('ö')-32
  }
  , {
    int('g')-32, int('b')-32, int('v')-32, int('n')-32, int('m')-32
  }
};
boolean sketchFullScreen() {
  return true;
}

void setup() {
  size(displayWidth, displayHeight, P3D);
  font= loadFont("PressStart2P-Regular-28.vlw");
  Blur= loadShader("blur.glsl");
  textFont(font, 18);
  //conway = loadShader("conway.glsl");
  randomSeed(12345);
  noSmooth();
  noCursor();
  for (int i=0; i< AmountOfPlayers; i++) {
    colorMode(HSB);
    players.add(new Player(i, color((255/AmountOfPlayers)*i, 255, 255), int(random(width-playerSize*1)+playerSize), int(random(height-playerSize*1)+playerSize), playerSize, playerSize, playerControl[i][0], playerControl[i][1], playerControl[i][2], playerControl[i][3], playerControl[i][4], abilities[i]));
  }
  for (int i=0; i< startBalls; i++) {
    colorMode(HSB);
    balls.add(new Ball(int(random(width-ballSize)+ballSize/2), int(random(height-ballSize)+ballSize/2), int(random(20)-10), int(random(20)-10), int(random(ballSize)+10), color(random(255), 0, 0)));
  }
  println("amount of serial ports: "+Serial.list().length);
  for (int i=0; i<Serial.list ().length; i++) {
    portName[i] = Serial.list()[i];   // du kan också skriva COM + nummer på porten   
    port[i] = new Serial(this, portName[i], baudRate);   // du måste ha samma baudrate t.ex 9600
    // println(port[i].available());
    //println(portName[i]);
    players.get(i).MAX_ACCEL=0.3;
    players.get(i).arduino=true;
  }
  GUILayer= createGraphics(width, height);
  GUILayer.beginDraw();
  GUILayer.noStroke();
  GUILayer.fill(0);
  GUILayer.endDraw();
  drawTimeSymbol();
  prevMillis=millis();

  try {  
    // initialize the SamplePlayer
    musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/TooManyCooksAdultSwim.mp3"));
    //musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/Velocity.mp3")); 
    //musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/orange caramel -aing.mp3"));
    // musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/MagnoliaUnplugged.mp3"));
  }
  catch(Exception e) {
    println("Exception while attempting to load sample!");
    e.printStackTrace(); // then print a technical description of the error
    exit(); // and exit the program
  }
  // note that we want to play the sample multiple times
  // player.setKillOnEnd(false);

  g.addInput(musicPlayer);
  ac.out.addInput(g);
  speedControl = new Envelope(ac, 1);
  // player.setPosition(3000);
  musicPlayer.setRate(speedControl);
  musicPlayer.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  //  speedControl.addSegment(1, 3000); //now rewind
  ac.start();
}

void draw() {
  addMillis=millis()-prevMillis;
  pushMatrix();
  if (shakeTimer>0) {
    shake(2*shakeTimer);
    shakeTimer--;
  } else {
    shakeTimer=0;
  } // shake screen

  fill(100);
  if (fastForward) {
    fill(240, 200, 255, 70);
  }
  // f =(fastForward)?speedFactor:1;
  if (slow) {
    fill(240, 10*F, 250, 20);
    // addMillis*=s;
  }
  //  s =(slow)?slowFactor:1;
  if (freeze) {
    fill(150, 200, 255);
    // addMillis=0;
  }
  if (freeze) {
    freezeTime+=addMillis;
  } else {
    if (reverse) {
      shake(4);
      fill(40, 200*F*S, 255*F);
      reversedTime+=addMillis*F*S;
      // reversedTime=millis()-forwardTime;
      //  reversedTime+=((millis()-forwardTime)-reversedTime);
    } else {
      forwardTime+=addMillis*F*S;
      // forwardTime=millis()-reversedTime;
      // forwardTime+=((millis()-reversedTime)-forwardTime);
    }
    stampTime=forwardTime-reversedTime;
    //stampTime+=((forwardTime-reversedTime)-stampTime);
    if (stampTime<0) {   // origin of time
      musicPlayer.pause(true);
      noLoop();
    }
  }
  prevMillis=millis();
  // println("stampTime"+stampTime);
  // println("forward"+forwardTime);
  // println("reverse"+reversedTime);

  noStroke();
  rect(0-10, 0-10, width+20, height+20); // background

  for (int i=0; i< balls.size (); i++) {
    balls.get(i).checkBounds();
    balls.get(i).move();
    balls.get(i).display();
  }

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
  checkPlayerVSBallColloision();
  for (int i=0; i<AmountOfPlayers; i++) {       
    if (!players.get(i).dead) {

      if (reverse && !players.get(i).reverseImmunity) {

        if (!freeze ||  players.get(i).freezeImmunity) {
          players.get(i).update();
          players.get(i).checkBounds();
        }
        players.get(i).display();
      } else {
        if (!freeze || players.get(i).freezeImmunity) {
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
  checkKeyHold();
  for (int i=stamps.size ()-1; i>= 0; i--) { // checkStamps
    // stamps.get(i).display(); // hid this when not DEBUGGING
    stamps.get(i).revert();
  }
  checkWinner();
  println(stamps.size()); // timestamps current in game
  if (cheatEnabled)displayInfo();
  popMatrix();

  for (int i=0; i<AmountOfPlayers; i++) {    // resetstate
    if (!players.get(i).dead) {
      players.get(i).state=0;
      players.get(i).hit=false;
    }
  }
}
/*void stop() {
 ac.stop();
 super.stop();
 } */
void dispose() {
  ac.stop();
  super.dispose();
}

void displayInfo() {
  fill(0);
  text("add Time: "+addMillis+" freezeTime: " + freezeTime+" reversed: " + reversedTime+" forward: " + forwardTime+ " current: "+  stampTime, width/2, 50);
  text("version: "+version, width/2, 20);
  text(frameRate, width-80, 50);
  //int i=1;
  //  text("player "+ i +"   x: " +players.get(i).x +" coord.x:" +players.get(i).coord.x, 500, 150);
  // text("player "+ i +"   x: " +players.get(i).y +" coord.x:" +players.get(i).coord.y, 500, 200 );
}

void shake(int amount) {
  translate( int(random(amount)-amount/2), int(random(amount)-amount/2));
}
void checkPlayerVSBallColloision() { // to balls
  if (!freeze && !reverse) {
    for (int j=0; j<AmountOfPlayers; j++) {  
      if (!players.get(j).dead) {
        for (int i=0; i< balls.size (); i++) {
          if ( players.get(j).x<balls.get(i).coord.x &&  players.get(j).x+ players.get(j).w>balls.get(i).coord.x &&  players.get(j).y<balls.get(i).coord.y &&  players.get(j).y+ players.get(j).h>balls.get(i).coord.y) {
            // stamps.add( new StateStamp(index, int(x), int(y), state, health, dead));
            players.get(j).hit(1);
            //  } else {
            // players.get(j).state=0;
            //    players.get(j).hit=false;
          }
        }
      }
    }
  }
}
void checkPlayerVSPlayerColloision() {
  if (!freeze &&!reverse) {
    for (int i=0; i<AmountOfPlayers; i++) {       
      for (int j=0; j<AmountOfPlayers; j++) {       
        if (j!=i && !players.get(i).dead && !players.get(j).dead ) {
          if (dist(players.get(i).x, players.get(i).y, players.get(j).x, players.get(j).y)<playerSize) {
            players.get(i).hit(1);
            // players.get(j).hit(1);
          }
        }
      }
    }
  }
}

void checkPlayerVSProjectileColloision() {
  if (!freeze &&!reverse) {
    for (int i=0; i< projectiles.size (); i++) {    
      for (int j=0; j<AmountOfPlayers; j++) {      
        if (!players.get(j).dead && !projectiles.get(i).dead && projectiles.get(i).playerIndex!=j  ) {
          if (dist(projectiles.get(i).x, projectiles.get(i).y, players.get(j).x+players.get(j).w/2, players.get(j).y+players.get(j).h/2)<playerSize) {
            players.get(j).hit(projectiles.get(i).damage);
            projectiles.get(i).hit(players.get(j));
          }
        }
      }
    }
  }
}

void checkWinner() {
  int playersAlive=0;
  for (int i=0; i<AmountOfPlayers; i++) {      
    if (!players.get(i).dead)playersAlive++;
  }
  if (playersAlive==1) {
    text("Winner is player ", width/2, 50);
  }
}

void drawTimeSymbol() {
  if (freeze) {
    GUILayer.beginDraw();
    GUILayer.clear();
    GUILayer.rect(offsetX-50, offsetY, 50, 200);
    GUILayer.rect(offsetX+50, offsetY, 50, 200);
    GUILayer.endDraw();
  } else {
    if (reverse) {
      GUILayer.beginDraw();
      GUILayer.clear();
      GUILayer.beginShape();
      GUILayer.vertex(offsetX, offsetY);
      GUILayer.vertex(offsetX-(75*S*F), offsetY+100);
      GUILayer.vertex(offsetX, offsetY+200);
      GUILayer.endShape();
      GUILayer.endDraw();
    }
    if (!reverse) {
      GUILayer.beginDraw();
      GUILayer.clear();
      GUILayer.beginShape();
      GUILayer.vertex(offsetX, offsetY);
      GUILayer.vertex(offsetX+(75*S*F), offsetY+100);
      GUILayer.vertex(offsetX, offsetY+200);
      GUILayer.endShape();
      GUILayer.endDraw();
    }
  }
}

