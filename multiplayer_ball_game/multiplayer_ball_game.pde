
/**------------------------------------------------------------//
 //                                                            //
 //  Coding dojo  - Prototype of a timecontrol game            //
 //  av: Alrik He    v.0.7.7                                   //
 //  Arduino verstad Malmö                                     //
 //                                                            //
 //      2014-09-21    -     2016-11-05                        //
 //                                                            //
 //                                                            //
 //         Used for weapon test & prototyping timebending     //
 //                                                            //
 //                                                            //
 --------------------------------------------------------------*/
import processing.opengl.*;
import beads.*;
import java.util.Arrays; 
import processing.serial.*;

AudioContext  ac = new AudioContext();
AudioContext an= new AudioContext();
Noise n = new Noise(an);
SamplePlayer musicPlayer;
Envelope speedControl;
Gain   g = new Gain(ac, 1, 0.05); //volume

PFont font;
PGraphics GUILayer;
PShader  Blur;
boolean noFlash=true, noShake=true, slow, reverse, fastForward, freeze, controlable=true, cheatEnabled, debug, origo, noisy, mute=true;
final float flashAmount=0.2;
int mouseSelectedPlayerIndex=0;
int halfWidth, halfHeight;
int gameMode=1;
final int WHITE=color(255), GREY=color(172), BLACK=color(0);
final int speedFactor= 2;
final float slowFactor= 0.3;
final String version="0.7.7";
static long prevMillis, addMillis, forwardTime, reversedTime, freezeTime, stampTime, fallenTime;
final int baudRate= 19200;
final static float DEFAULT_FRICTION=0.1;
final int AmountOfPlayers=4; // start players
final int startBalls=0;
final int  ballSize=100;
final int playerSize=100;
static int playersAlive; // amount of players alive
static Player AI;
final int offsetX=950, offsetY=100;
static int shakeTimer, shakeX=0, shakeY=0;
static float F=1, S=1, timeBend=1, zoom=0.8;//0.7;
//int keyCooldown[]= new int[AmountOfPlayers];
final int keyResponseDelay=30;  // eventhe refreashrate equal to arduino devices
final char keyRewind='r', keyFreeze='v', keyFastForward='f', keySlow='z', keyIceDagger='p', ResetKey='0', RandomKey='7';

Serial port[]=new Serial[AmountOfPlayers];  // Create object from Serial class
String portName[]=new String[AmountOfPlayers];

ArrayList <Player> players = new ArrayList<Player>();
ArrayList <TimeStamp> stamps= new ArrayList<TimeStamp>();
ArrayList <Projectile> projectiles = new ArrayList<Projectile>();
ArrayList <Particle> particles = new ArrayList<Particle>();

final Projectile allProjectiles[] = new Projectile[]{
  // new IceDagger(),new forceBall(),new RevolverBullet()
};

final Ability abilityList[] = new Ability[]{
  // new FastForward(), 
  // new Freeze(), 
  // new Reverse(), 
  // new Slow(), 
  new ThrowDagger(), 
  new Revolver(), 
  new ForceShoot(), 
  new Blink(), 
  new Multiply(), 
  new Stealth(), 
  new Laser(), 
  new TimeBomb(), 
  new RapidFire(), 
  new MachineGun(), 
  new Battery(), 
  new Ram(), 
  new Detonator(), 
  new PhotonicWall(), 
  new Sniper(), 
  new ThrowBoomerang(), 
  new PhotonicPursuit(), 
  new DeployThunder(), 
  new DeployShield(), 
  new DeployElectron(), 
  new Gravity(), 
  new DeployTurret(), 
  new Bazooka(), 
  new MissleLauncher(), 
  new AutoGun(), 
  new Combo(), 
  new KineticPulse(), 
  new TeslaShock(), 
  new RandoGun(), 
  new Shotgun(), 
  new FlameThrower(), 
  new DeployDrone(), 
  new DeployBodyguard(), 
  new SemiAuto(), 
  new Pistol(), 
  new AssaultBattery(), 
  new Stars(), 
  new SeekGun(),
  new ElemetalLauncher()
  //new SummonEvil()
};

final Ability passiveList[] = new Ability[]{
  new Repel(), 
  new Gravitation(), 
  new Speed(), 
  new Armor(), 
  new HpRegen(), 
  new Static(), 
  new SuppressFire(), 
  new Nova(), 
  new Trail(), 
  new Gloss(), 
  new BackShield(), 
  new PainPulse(), 
  new Boost(), 
  new Glide(), 
  new MpRegen(), 
  new BulletTime(), 
  new Emergency(), 
  new Adrenaline(), 
  new BulletCutter()
  //new Redemption(), // buggy on survival
  //new Undo() // buggy on survival
};

Ability[][] abilities= { 
  {new ElemetalLauncher(), new BulletCutter()}, 
  {new SeekGun(), new Emergency()}, 
  { new AutoGun(), new Adrenaline()}, 
  {new Shotgun(), new Adrenaline()}, 
  {new Random().randomize(), new RandomPassive().randomize()}, 
  {new Random().randomize(), new RandomPassive().randomize()}
};

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
  , 
  {
    '8', '5', '4', '6', '3'
  }
};
/*boolean sketchFullScreen() { // p2 legacy
 return false;
 }
 */
void setup() {
  fullScreen(P3D);
  //size(displayWidth, displayHeight, P3D);
  font= loadFont("PressStart2P-Regular-28.vlw");
  Blur= loadShader("blur.glsl");
  textFont(font, 18);
  randomSeed(12345);
  noSmooth();
  halfWidth=int(width*.5);
  halfHeight=int(height*.5);
  //frameRate(60);
  //noCursor();
  //cursor();

  colorMode(HSB);
  for (int i=0; i< AmountOfPlayers; i++) {
    try {
      players.add(new Player(i, color((255/AmountOfPlayers)*i, 255, 255), int(random(width-playerSize*1)+playerSize), int(random(height-playerSize*1)+playerSize), playerSize, playerSize, playerControl[i][0], playerControl[i][1], playerControl[i][2], playerControl[i][3], playerControl[i][4], abilities[i][0], abilities[i][1]));
    }
    catch(Exception e ) {
      println(e);
    }
    if (players.get(i).mouse)players.get(i).FRICTION_FACTOR=0.11; //mouse
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
    players.get(i).FRICTION_FACTOR=0.062;
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
    // musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/TooManyCooksAdultSwim.mp3"));
    musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/Velocity.mp3")); 
    // musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/Death by Glamour.mp3")); 
    // musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/Branching time.mp3")); 
    //musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/orange caramel -aing.mp3"));
    //musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/goodbye.mp3"));
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
  if (!mute)ac.start(); //start music


  Gain g2 = new Gain(an, 1, 0);
  g2.addInput(n);
  an.out.addInput(g2);
  an.start();  //start noise

  particles.add(new Flash(1500, 5, WHITE));   // flash
  particles.get(0).opacity=0;
  //frameRate(60);

  AI= new Player( -1, GREY, halfWidth, halfHeight, 0, 0, 0, 0, 0, 0, 0, new DeployTurret());
  AI.index=-1;
  AI.angle=0;
  AI.stealth=true;
  AI.dead=true;
  AI.freezeImmunity=false;
  AI.reverseImmunity=false;
  AI.slowImmunity=false;
  AI.fastforwardImmunity=false;
  switch(gameMode) {
  case 0:
    particles.add(new  Text("Brawl", 200, halfHeight, 5, 0, 100, 0, 10000, BLACK, 0) );
    break;
  case 1:
    for (Player p : players) p.ally=0;
    players.add(AI);
    spawningSetup();
    particles.add(new  Text("Survival", 200, halfHeight, 5, 0, 100, 0, 10000, BLACK, 0) );
    break;
  }
}
void stop() {
  musicPlayer.pause(true);
  super.stop();
}

void draw() {
  switch(gameMode) {
  case 0:

    break;
  case 1:
    survivalSpawning();
    break;
  }



  background(255);
  addMillis=millis()-prevMillis;
  prevMillis=millis();
  if (origo) {
    fallenTime+=addMillis*timeBend;
    // background(255);
  } else {
    pushMatrix();
    screenShake();

    fill(100);

    if (fastForward) {
      fill(240, 100*F, 100, 50);
    }
    if (slow) {
      fill(240, 10*F, 250, 20);
    }
    if (freeze) {
      fill(150, 200, 255);
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
        fill(40, 200*timeBend, 255*F);
        reversedTime+=addMillis*timeBend;
      } else {
        forwardTime+=addMillis*timeBend;
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
    pushMatrix();
    translate(width*(1-zoom)*.5, height*(1-zoom)*.5);
    scale(zoom, zoom);

    noStroke();
    rect(-10, -10, width+20, height+20); // background


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

    for (int i=0; i<Serial.list().length; i++) {   // USB devices
      if (portName[i]!= null && port[i].available() > 0) {  //ta in data och ignorerar skräpdata    
        players.get(i).control(port[i].read());
        // println("INPUT!!!!!!!!!!!!!!!!!!!!!!!");
      }
    }

    checkPlayerVSPlayerColloision();
    checkProjectileVSProjectileColloision();
    checkPlayerVSProjectileColloision();


    for (Player p : players) {       
      if (!p.dead) {
        if (!freeze ||  p.freezeImmunity) {
          p.mouseControl() ;
          p.update();
          if (!reverse || p.reverseImmunity) {
            p.checkBounds();
          }
        }
        p.display();
      }
    }
    if (freeze) {
      // colorMode(RGB);
      //for (int b=0; b<2; b++) {
      filter(Blur);
      // }
    } /*else {   
     //colorMode(HSB);
     }*/
    if (slow) {
      noStroke();
      fill(0, 30);
      rect(10, 10, width+20, height+20); // background
    }
    image(GUILayer, 0, 0);
    //mouseDot();
    checkKeyHold();
    for (int i=stamps.size ()-1; i>= 0; i--) { // checkStamps
      // stamps.get(i).display(); // hid this when not DEBUGGING
      stamps.get(i).revert();
    }
    checkWinner();

    popMatrix();

    for (Player p : players) {    // resetstate
      if (!p.dead) {
        p.state=0;
        p.hit=false;
      }
    }
    popMatrix();
  }// origo
  // prevMillis=millis();
  if (cheatEnabled)displayInfo();
  else displayClock();
}