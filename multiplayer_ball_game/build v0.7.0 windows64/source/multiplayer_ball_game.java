import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.opengl.*; 
import beads.*; 
import java.util.Arrays; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class multiplayer_ball_game extends PApplet {


/**------------------------------------------------------------//
 //                                                            //
 //  Coding dojo  - Prototype of a timecontrol game            //
 //  av: Alrik He    v.0.7.7                                   //
 //  Arduino verstad Malm\u00f6                                     //
 //                                                            //
 //      2014-09-21    -     2016-11-05                        //
 //                                                            //
 //                                                            //
 //         Used for weapon test & prototyping timebending     //
 //                                                            //
 //                                                            //
 --------------------------------------------------------------*/


 


AudioContext  ac = new AudioContext();
AudioContext an= new AudioContext();
Noise n = new Noise(an);
SamplePlayer musicPlayer;
Envelope speedControl;
Gain   g = new Gain(ac, 1, 0.05f); //volume
final int BGcolor=color(100);
PFont font;
PGraphics GUILayer;
PShader  Blur;
boolean RandomSkillsOnDeath=true, noFlash=true, noShake=false, slow, reverse, fastForward, freeze, controlable=true, cheatEnabled, debug, origo, noisy, mute=true,inGame;
final float flashAmount=0.1f, shakeAmount=0.1f;
int mouseSelectedPlayerIndex=0;
int halfWidth, halfHeight;
//int gameMode=0;
GameType gameMode=GameType.BRAWL;
final int AmountOfPlayers=3; // start players
final int WHITE=color(255), GREY=color(172), BLACK=color(0);
final int speedFactor= 2;
final float slowFactor= 0.3f;
final String version="0.7.7";
static long prevMillis, addMillis, forwardTime, reversedTime, freezeTime, stampTime, fallenTime;
final int baudRate= 19200;
final static float DEFAULT_FRICTION=0.1f;
final int startBalls=0;
final int  ballSize=100;
final int playerSize=100;
static int playersAlive; // amount of players alive
static Player AI;
final int offsetX=1250, offsetY=-50;//final int offsetX=950, offsetY=100;
static int shakeTimer, shakeX=0, shakeY=0;
static float F=1, S=1, timeBend=1, zoom=0.8f;//0.7;
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
  new ElemetalLauncher(), 
  new SummonEvil()
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
  {new Random().randomize(), new CloneMultiply()}, 
  {new  Random().randomize(), new CloneMultiply()}, 
  { new  Random().randomize(), new CloneMultiply()}, 
  {new Shotgun(), new RandomPassive().randomize()}, 
  {new Random().randomize(), new RandomPassive().randomize()}, 
  {new Random().randomize(), new RandomPassive().randomize()}
};

int playerControl[][]= {
  {
    UP, DOWN, LEFT, RIGHT, PApplet.parseInt(',')
  }
  , {
    PApplet.parseInt('w')-32, PApplet.parseInt('s')-32, PApplet.parseInt('a')-32, PApplet.parseInt('d')-32, PApplet.parseInt('t')-32
  }
  , 
  {
    888, 888, 888, 888, 888 // mouse
  }
  , {
    PApplet.parseInt('i')-32, PApplet.parseInt('k')-32, PApplet.parseInt('j')-32, PApplet.parseInt('l')-32, PApplet.parseInt('\u00f6')-32
  }
  , {
    PApplet.parseInt('g')-32, PApplet.parseInt('b')-32, PApplet.parseInt('v')-32, PApplet.parseInt('n')-32, PApplet.parseInt('m')-32
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
public void setup() {
  
  //size(displayWidth, displayHeight, P3D);
  font= loadFont("PressStart2P-Regular-28.vlw");
  Blur= loadShader("blur.glsl");
  textFont(font, 18);
  randomSeed(12345);
  
  halfWidth=PApplet.parseInt(width*.5f);
  halfHeight=PApplet.parseInt(height*.5f);
  //frameRate(60);
  //noCursor();
  //cursor();

  colorMode(HSB);
  for (int i=0; i< AmountOfPlayers; i++) {
    try {
      players.add(new Player(i, color((255/AmountOfPlayers)*i, 255, 255), PApplet.parseInt(random(width-playerSize*1)+playerSize), PApplet.parseInt(random(height-playerSize*1)+playerSize), playerSize, playerSize, playerControl[i][0], playerControl[i][1], playerControl[i][2], playerControl[i][3], playerControl[i][4], abilities[i][0], abilities[i][1]));
    }
    catch(Exception e ) {
      println(e);
    }
    if (players.get(i).mouse)players.get(i).FRICTION_FACTOR=0.11f; //mouse
  }
  for (int i=0; i< startBalls; i++) {
    projectiles.add(new Ball(PApplet.parseInt(random(width-ballSize)+ballSize*0.5f), PApplet.parseInt(random(height-ballSize)+ballSize*0.5f), PApplet.parseInt(random(20)-10), PApplet.parseInt(random(20)-10), PApplet.parseInt(random(ballSize)+10), color(random(255), 0, 0)));
  }
  println("amount of serial ports: "+Serial.list().length);
  for (int i=0; i<Serial.list ().length; i++) {
    portName[i] = Serial.list()[i];   // du kan ocks\u00e5 skriva COM + nummer p\u00e5 porten   
    port[i] = new Serial(this, portName[i], baudRate);   // du m\u00e5ste ha samma baudrate t.ex 9600
    // println(port[i].available());
    //println(portName[i]);
    players.get(i).MAX_ACCEL=0.16f;
    players.get(i).DEFAULT_MAX_ACCEL=0.16f;
    players.get(i).arduino=true;
    players.get(i).FRICTION_FACTOR=0.062f;
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

  AI= new Player( -1, BLACK, halfWidth, halfHeight, 0, 0, 0, 0, 0, 0, 0, new DeployTurret());
  AI.index=-1;
  AI.angle=0;
  AI.stealth=true;
  AI.dead=true;
  AI.freezeImmunity=false;
  AI.reverseImmunity=false;
  AI.slowImmunity=false;
  AI.fastforwardImmunity=false;
  switch(gameMode) {
  case BRAWL:
    particles.add(new  Text("Brawl", 200, halfHeight, 5, 0, 100, 0, 10000, BLACK, 0) );
    particles.add(new Gradient(8000, 0, 500, 0, 0, 500, 0.5f, 0, GREY));
    break;
  case SURVIVAL:
    for (Player p : players) p.ally=0;
    players.add(AI);
    //spawningSetup();
    spawningReset();
    break;
  case PUZZLE:
    break;
  }
}
public void stop() {
  musicPlayer.pause(true);
  super.stop();
}

public void draw() {
  switch(gameMode) {
  case BRAWL:
    break;
  case SURVIVAL:
    survivalSpawning();
    break;
  case PUZZLE:
    break;
  }


  background(BGcolor);
  addMillis=millis()-prevMillis;
  prevMillis=millis();
  if (origo) {
    fallenTime+=addMillis*timeBend;
    // background(255);
  } else {
    pushMatrix();
    screenShake();

    fill(BGcolor);

    if (fastForward&& !noFlash) {
      fill(240, 100*F, 100, 50*flashAmount);
    }
    if (slow&& !noFlash) {
      fill(240, 10*F, 250, 20*flashAmount);
    }
    if (freeze ) {
      if (!noFlash)fill(150, 200, 255, flashAmount*255);
      freezeTime+=addMillis;
    } else {
      if (reverse) {
        if (stampTime<6000) {
          Gain g3 = new Gain(an, 1, 0.0f);
          g3.setGain((6000-stampTime)*0.0000001f);
          if (!noisy)g3.addInput(n);

          an.out.addInput(g3);

          shake(PApplet.parseInt((6000-stampTime)*0.01f) );
          noisy=true;
        } else {

          shake(4);
        }
        if (!noFlash)fill(40, 200*timeBend, flashAmount*255*F);
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
    translate(width*(1-zoom)*.5f, height*(1-zoom)*.5f);
    scale(zoom, zoom);

    //noStroke()
    stroke(BLACK);
    strokeWeight(10);
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
      if (portName[i]!= null && port[i].available() > 0) {  //ta in data och ignorerar skr\u00e4pdata    
        players.get(i).control(port[i].read());
        // println("INPUT!!!!!!!!!!!!!!!!!!!!!!!");
      }
    }

    checkPlayerVSPlayerColloision();
    checkProjectileVSProjectileColloision();
    checkPlayerVSProjectileColloision();

    try {
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
    }
    catch(Exception e) {

      println(e);
    }

    if (freeze) {
      // colorMode(RGB);
      //for (int b=0; b<2; b++) {
      filter(Blur);
      // }
    } 
    //image(GUILayer, 0, 0);
    mouseDot();
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
    image(GUILayer, 0, 0);
  }// origo
  // prevMillis=millis();
  if (cheatEnabled)displayInfo();
  else displayClock();
}

public static String getClassName(Object o) {
  return o.getClass().getSimpleName();
}
class Ability implements Cloneable {
  AbilityType type;
  String name="???";
  Player owner;  
  PImage icon;
  long cooldown;
  int cooldownTimer;
  float energy=90, maxEnergy=100, activeCost=5, channelCost, deChannelCost, deactiveCost, maxCooldown, regenRate=0.1f, ammo, maxAmmo, loadRate;
  boolean active, channeling, cooling, hold, regen=true, meta;
  Ability() { 
    //name=this.getClass().getSimpleName();
    //name=this.getClass().getCanonicalName();

    //nFame=this.getClass().getSimpleName();
    //name=this.getClass().getCanonicalName();

    // icon = loadImage("Ability Icons-04.jpg");
    //energy=100;
    //maxEnergy=energy;
  }
  Ability( Player _owner) { 
    this();
    owner=_owner;
  }
  public void press() {
  }
  public void release() {
  }
  public void hold() {
  }
  public void action() {
  }
  public void onHit() {
  }
  public void update() {
  }
  public void channel() {
    if (energy>0) {
      energy -= channelCost*timeBend;
      channeling=true;
    } else {
      deChannel();
    }
  }
  public void deChannel() {
    energy -= deChannelCost;
    channeling=false;
  }
  public void display() {
  }
  public void activate() { 
    active=true;
    energy -= activeCost;
  }

  public void deActivate() {
    active=false;
    energy -= deactiveCost;
  }

  public void enableCooldown() {
    //cooldown=maxCooldown;
    cooldown=stampTime+cooldownTimer;
    cooling=true;
  }
  public void regen() {
    if (reverse && !owner.reverseImmunity) {
      if (regen && energy>0) {
        energy -= regenRate*timeBend;
      }
    } else {
      if (regen && energy<maxEnergy) {
        energy += regenRate*timeBend;
      } else if (regen) {
        // stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=false;
      }
    }
  }
  public void load() {
    if (ammo<maxAmmo)ammo+=loadRate;
  }
  public void passive() {
  }
  public void onDeath() {
  }
  public void reset() {
    active=false;
    energy=maxEnergy;
    cooldown=0;
    if (owner!=null) {
      owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    }
  }
  public void setOwner(Player _owner) {
    owner=_owner;
  }
  public Ability clone()throws CloneNotSupportedException {  
    return (Ability)super.clone();
  }
}



class FastForward extends Ability { //---------------------------------------------------    FastForward   ---------------------------------

  FastForward() {
    super();
    name=getClassName(this);
    activeCost=8;
    channelCost=0.03f;
    deactiveCost=8;
    active=false;
    meta=true;
  }
  public @Override
    void action() {
    origo=false;
    if (stampTime<0) {
      stampTime=0;
    }
    if (!noFlash)background(0, 255, 255);
    fastForward=(fastForward)?false:true;
    F =(fastForward)?speedFactor:1;
    timeBend=S*F;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 400); //now fastforward
    //controlable=(controlable)?false:true;
    drawTimeSymbol();
  }
  public void press() {
    if (!active) {
      if (energy>0+activeCost) {
        activate();
      }
    } else {
      deActivate();
    }
  }
  public void activate() { 
    active=true;
    energy -= activeCost;
    action();
    regen=false;
  }
  public @Override
    void deActivate() {
    super.deActivate();
    regen=true;
    action();
  }
  public @Override
    void passive() {
    if (active) {
      channel();
      if (energy<0) {
        deActivate();
      }
    }
  }

  public @Override
    void reset() {
    super.reset();
    stamps.add( new ControlStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    fastForward=false;
    F =1;
    timeBend=1;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 400); //now fastforward
    //controlable=(controlable)?false:true;
    regen=true;
    drawTimeSymbol();
  }
  public @Override
    void setOwner(Player _owner) {
    super.setOwner(_owner);
    if (round(random(1))==0)owner.fastforwardImmunity=true;
  }
}



class Freeze extends Ability { //---------------------------------------------------    Freeze   ---------------------------------

  Freeze() {
    super();
    name=getClassName(this);
    activeCost=16;
    energy=50;
    channelCost=0.08f;
    deactiveCost=4;
    active=false;
    meta=true;
  }
  public @Override
    void action() {
    quitOrigo();
    if (owner.freezeImmunity) {
      for (int i =0; i<4; i++) {
        particles.add( new Feather(400, PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), random(-5, 5), random(-5, 5), 15, owner.playerColor));
      }
      particles.add( new  Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 0, 0, owner.w, 50, owner.playerColor));
    }
    stamps.add( new ControlStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    freeze=(freeze)?false:true;
    speedControl.clear();
    speedControl.addSegment((freeze)?0:1, 150); //now stop
    controlable=(controlable)?false:true;
    /* for (int i=0; i< players.size (); i++) {
     stamps.add( new ControlStamp(i, int(players.get(i).x), int( players.get(i).y), 0, 0, 0, 0));
     stamps.add( new ControlStamp(i, int(players.get(i).x), int( players.get(i).y), players.get(i).vx, players.get(i).vy, players.get(i).ax, players.get(i).ay));
     }*/
    for (Player P : players) {
      stamps.add( new ControlStamp(P.index, PApplet.parseInt(P.x), PApplet.parseInt( P.y), 0, 0, 0, 0));
      stamps.add( new ControlStamp(P.index, PApplet.parseInt(P.x), PApplet.parseInt( P.y), P.vx, P.vy, P.ax, P.ay));
    }
    controlable=(controlable)?false:true;
    drawTimeSymbol();
  }

  public @Override
    void press() {
    if (!active) {
      if (energy>0+activeCost) {
        activate();
      }
    } else {
      deActivate();
    }
  }
  public void activate() { 
    active=true;
    energy -= activeCost;
    particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 20, 16, 150, owner.playerColor));
    stamps.add( new ControlStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt( owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    regen=false;
    action();
  }

  public @Override
    void deActivate() {
    super.deActivate();
    particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 200, 16, 850, owner.playerColor));
    action();
    //  stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
    regen=true;
  }
  public @Override
    void passive() {
    if (active) {
      channel();
      if (energy<0) {
        deActivate();
      }
    }
  }
  public @Override
    void reset() {
    super.reset();
    stamps.add( new ControlStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    freeze=false;
    speedControl.clear();
    speedControl.addSegment((freeze)?0:1, 150); //now stop
    controlable=true;
    for (Player P : players) {
      stamps.add( new ControlStamp(P.index, PApplet.parseInt(P.x), PApplet.parseInt( P.y), 0, 0, 0, 0));
      stamps.add( new ControlStamp(P.index, PApplet.parseInt(P.x), PApplet.parseInt( P.y), P.vx, P.vy, P.ax, P.ay));
    }
    drawTimeSymbol();
  }
  public @Override
    void setOwner(Player _owner) {
    super.setOwner(_owner);
    owner.freezeImmunity=true;
  }
}




class Reverse extends Ability { //---------------------------------------------------    Reverse   ---------------------------------

  Reverse() {
    super();
    name=getClassName(this);
    energy=0;
    activeCost=16;
    channelCost=0.04f;
    deactiveCost=8;
    active=false;
    meta=true;
  }
  public @Override
    void action() {
    if (!mute)musicPlayer.pause(false);
    reverse=(reverse)?false:true;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 600); //now rewind
    controlable=(controlable)?false:true;
    drawTimeSymbol();
    quitOrigo();
  }
  public @Override
    void press() {
    if (!active) {
      if (energy>0+activeCost) {
        activate();
      }
    } else {
      deActivate();
    }
  }
  public @Override
    void activate() { 
    energy -= activeCost;
    action();
    active=true;
    regen=false;
  }
  public @Override
    void deActivate() {
    super.deActivate();
    //  stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
    action();
    active=false;
    regen=true;
  }
  public void passive() {
    if (active|| reverse) {
      channel();
      if (energy<0) {
        deActivate();
      }
    }
  }
  public @Override
    void setOwner(Player _owner) {
    super.setOwner(_owner);
    if (round(random(1))==0)owner.reverseImmunity=true;
  }
}





class Slow extends Ability { //---------------------------------------------------    Slow   ---------------------------------

  Slow() {
    super();
    name=this.toString();
    activeCost=4;
    deactiveCost=4;
    active=false;
    meta=true;
  }
  public @Override
    void action() {
    quitOrigo();
    if (mute)musicPlayer.pause(false);
    slow=(slow)?false:true;
    S =(slow)?slowFactor:1;
    timeBend=S*F;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 800); //now slow
    //controlable=(controlable)?false:true;
    drawTimeSymbol();
  }
  public @Override
    void press() {
    if (!active) {
      if (energy>0+activeCost) {
        activate();
        action();
      }
    } else {
      deActivate();
      action();
    }
  }
  public @Override
    void deActivate() {
    super.deActivate();
    stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
    regen=true;
  }
  public @Override
    void reset() {
    super.reset();
    stamps.add( new ControlStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    if (mute)musicPlayer.pause(false);
    slow=false;
    S =1;
    timeBend=1;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 800); //now slow
    //controlable=(controlable)?false:true;
    drawTimeSymbol();
  }

  public @Override
    void setOwner(Player _owner) {
    super.setOwner(_owner);
    if (round(random(1))==0)owner.slowImmunity=true;
  }
}

class SaveState extends Ability { //---------------------------------------------------    SaveState   ---------------------------------
  int stampIndex, displayTime, pulse, duration=30000;
  long endTime;
  TimeStamp saved;
  ArrayList<Ball> balls= new  ArrayList<Ball>();
  SaveState() {
    super();
    name=getClassName(this);
    activeCost=60;
    deactiveCost=40;
    active=false;
    meta=true;
  }
  public @Override
    void action() {
    if (!mute)musicPlayer.pause(false);
    endTime=stampTime+duration;  // init end Time
    /* for (int i=0; i< players.size (); i++) {  
     if (!players.get(i).dead) {
     particles.add(new ShockWave(int(players.get(i).cx), int( players.get(i).cy), 20, 16, 500, players.get(i).playerColor));
     particles.add( new  Particle(int(players.get(i).cx), int( players.get(i).cy), 0, 0, int(players.get(i).w), 1000, players.get(i).playerColor));
     }
     // speedControl.clear();
     displayTime=int(stampTime*0.001);
     saved =new CheckPoint(); // timeStamps special object
     }*/
    for (Player p : players) {  
      if (!p.dead) {
        particles.add(new ShockWave(PApplet.parseInt(p.cx), PApplet.parseInt( p.cy), 20, 16, 500, p.playerColor));
        particles.add( new  Particle(PApplet.parseInt(p.cx), PApplet.parseInt( p.cy), 0, 0, PApplet.parseInt(p.w), 1000, p.playerColor));
      }
      // speedControl.clear();
      displayTime=PApplet.parseInt(stampTime*0.001f);
      saved =new CheckPoint(); // timeStamps special object
    }
    regen=false;
    drawTimeSymbol();
  }
  public @Override
    void press() {
    if (!active ) {
      if (energy>0+activeCost && !owner.dead) {
        activate();
        action();
      }
    } else {
      deActivate();
    }
  }
  public @Override
    void deActivate() {
    quitOrigo();
    super.deActivate();
    saved.call();
    shakeTimer=30;
    particles.add(new Flash(1200, 5, WHITE));   // flash
    regen=true;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 100); 
    drawTimeSymbol();
    pulse=0;
  }
  public @Override
    void passive() {
    if (!freeze && active) { 
      passiveUpdate();
    }
    passiveDisplay();
  }

  public void passiveUpdate() {
    if (active) {
      if (endTime<stampTime) {
        particles.add(new Flash(1500, 5, WHITE));   // flash
        for (int i=0; i< 10; i++) {
          balls.add(new Ball(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), PApplet.parseInt(cos(radians(i*36))*8), PApplet.parseInt(sin(radians(i*36))*8), PApplet.parseInt(40), owner.playerColor));
          balls.get(balls.size()-1).owner=owner;  
          balls.get(balls.size()-1).ally=owner.ally;  
          projectiles.add(balls.get(balls.size()-1));
        }
        super.deActivate();
        regen=true;
        energy+=deactiveCost;
      }
      pulse+=4;
    }
  }

  public void passiveDisplay() {
    stroke(255);
    strokeWeight(PApplet.parseInt(sin(radians(pulse))*8)+1);
    fill(255);
    if (active) { 
      float f = (float)(endTime-stampTime)/duration;
      for (int i=0; i<360*f; i+= (360/12)) {
        line(owner.cx+ cos(radians(-90-i))*80, owner.cy+sin(radians(-90-i))*80, owner.cx+ cos(radians(-90-i))*130, owner.cy+sin(radians(-90-i))*130);
      }
      text(displayTime, owner.cx, owner.y-owner.h*1);
    }
    noFill();
    // point(owner.cx+cos(radians(owner.angle))*range, owner.cy+sin(radians(owner.angle))*range);
    ellipse(owner.cx, owner.cy, owner.w*2, owner.h*2);
  }
  public void reset() {
    super.reset();
    for (Ball b : balls) {
      b.dead=true;
      b.deathTime=stampTime;
    }
    balls.clear();
  }
}


class ThrowDagger extends Ability {//---------------------------------------------------    ThrowDagger   ---------------------------------
  final int damage=16, slashdamage2=2, threashold =2;
  final int slashDuration=190, slashRange=100, slashdamage=4;
  boolean alternate;
  ThrowDagger() {
    super();
    name=getClassName(this);
    activeCost=8;
    regenRate=0.16f;
  } 
  public @Override
    void action() {
    if (abs(owner.vx)>threashold  ||  abs(owner.vy)>threashold) {
      if (abs(owner.keyAngle-owner.angle)<5) {
        if (alternate) {
          projectiles.add( new IceDagger(owner, PApplet.parseInt( owner.cx+cos(radians(owner.keyAngle-45))*75), PApplet.parseInt(owner.cy+sin(radians(owner.keyAngle-45))*75), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, PApplet.parseInt(damage*1.2f)));
          projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 30, owner.playerColor, 120, owner.angle+100, 24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
        } else {
          projectiles.add( new IceDagger(owner, PApplet.parseInt( owner.cx+cos(radians(owner.keyAngle+45))*75), PApplet.parseInt(owner.cy+sin(radians(owner.keyAngle+45))*75), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, PApplet.parseInt(damage*1.2f)));
          projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx+sin(owner.keyAngle)*50), PApplet.parseInt(owner.cy+cos(owner.keyAngle)*50), 30, owner.playerColor, 120, owner.angle-100, -24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
        }
      } else {
        if (alternate) {
          projectiles.add( new ArchingIceDagger(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 30, owner.playerColor, 1000, owner.keyAngle, (owner.keyAngle-owner.angle)*8, owner.ax*24, owner.ay*24, damage));
          projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 30, owner.playerColor, 120, owner.angle+100, 24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
        } else { 
          projectiles.add( new ArchingIceDagger(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 30, owner.playerColor, 1000, owner.keyAngle, (owner.keyAngle-owner.angle)*8, owner.ax*24, owner.ay*24, damage));
          projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 30, owner.playerColor, 120, owner.angle-100, -24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
        }
      }
      alternate=!alternate;
    } else {
      owner.pushForce(-13, owner.angle);
      // for (int i=0; i<360; i+=10) {
      //  projectiles.add( new ArchingIceDagger(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 1000, owner.angle, owner.angle+90, sin(radians(i))*20, -cos(radians(i))*20, damage));
      //}

      projectiles.add( new ArchingIceDagger(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 30, owner.playerColor, 1000, owner.angle, owner.angle, sin(radians(owner.angle+140))*20, -cos(radians(owner.angle+140))*20, damage*2));
      projectiles.add( new ArchingIceDagger(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 30, owner.playerColor, 1000, owner.angle, owner.angle+180, sin(radians(owner.angle+40))*20, -cos(radians(owner.angle+40))*20, damage*2));
      projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 30, owner.playerColor, PApplet.parseInt(slashDuration), owner.angle+90, 22, slashRange, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage, true));
      projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 30, owner.playerColor, PApplet.parseInt(slashDuration), owner.angle-90, -22, slashRange, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage, true));
    }
  }

  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
}
class Pistol extends Ability {//---------------------------------------------------    Pistol   ---------------------------------
  final int damage=14;
  int r;
  float accuracy=1, MODIFIED_ANGLE_FACTOR=0.2f;
  Pistol() {
    super();
    name=getClassName(this);
    activeCost=maxEnergy;
    maxAmmo=12;
    ammo=maxAmmo;
    cooldownTimer=240;
    regenRate=0.24f;
  } 
  public @Override
    void action() {
    if (energy>=maxEnergy)
      projectiles.add( new RevolverBullet(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*75), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*75), 85, 12, owner.playerColor, 1000, owner.angle, damage));

    else
      projectiles.add( new RevolverBullet(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*75), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*75), 75, 10, owner.playerColor, 1000, owner.angle, damage));

    particles.add(new ShockWave(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*75), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*75), 20, 32, 55, WHITE));
    owner.pushForce(-5, owner.angle);
    owner.angle+=random(-90, 90);
    ammo--;
    r=30;
  }

  public @Override
    void press() {
    // particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
    if ( ammo > 0&& cooldown<stampTime  &&(!reverse || owner.reverseImmunity)&&  !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      action();
    } else {
      if (energy>=0+activeCost  && ammo<=0) {
        reload();
        enableCooldown();
        activate();
        regen=true;
      } else {
        r=70;
      }
    }
  }
  public @Override
    void passive() {
    strokeWeight(3);
    stroke(owner.playerColor);
    noFill();
    for (int i=0; i< ammo; i++)line(owner.cx-20, owner.cy+50+i*8, owner.cx+20, owner.cy+50+i*8);
    owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
  }
  public void reload() {
    r=-30;
    owner.vx*=.5f;
    owner.vy*=.5f;
    owner.ax*=.5f;
    owner.ay*=.5f;
    particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 20, 24, 200, owner.playerColor));
    particles.add( new  Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 0, 0, PApplet.parseInt(owner.w), 800, color(255, 0, 255)));
    ammo=maxAmmo;
  }
}
class Revolver extends Ability {//---------------------------------------------------    Revolver   ---------------------------------
  final int damage=38;
  int r;
  float accuracy=1, MODIFIED_ANGLE_FACTOR=0.18f;
  Revolver() {
    super();
    name=getClassName(this);
    activeCost=maxEnergy;
    maxAmmo=6;
    ammo=maxAmmo;
    cooldownTimer=240;
    regenRate=0.26f;
  } 
  public @Override
    void action() {
    if (energy>=maxEnergy)  projectiles.add( new RevolverBullet(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*75), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*75), 65, 30, owner.playerColor, 1000, owner.angle, damage*1.2f));
    else projectiles.add( new RevolverBullet(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*75), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*75), 60, 25, owner.playerColor, 1000, owner.angle, damage));
    particles.add(new ShockWave(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*75), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*75), 30, 32, 75, owner.playerColor));
    projectiles.add( new  Blast(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 5, 100, owner.playerColor, 50, owner.angle, damage));

    owner.pushForce(-13, owner.angle);
    owner.angle+=random(-180, 180);
    owner.pushForce(4, owner.keyAngle);
    ammo--;
    r=30;
  }

  public @Override
    void press() {
    // particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
    if ( ammo > 0&& cooldown<stampTime  &&(!reverse || owner.reverseImmunity)&&  !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      action();
    } else {
      if (energy>=0+activeCost  && ammo<=0) {
        reload();
        enableCooldown();
        activate();
        regen=true;
      } else {
        r=70;
      }
    }
  }
  public @Override
    void passive() {
    strokeWeight(2);
    stroke(owner.playerColor);
    noFill();
    if (r<90)r+=PApplet.parseInt(5*timeBend);
    for (int i =-r; i<=360; i+= 360/maxAmmo) {
      ellipse(owner.cx+cos(radians(i))*90, owner.cy+sin(radians(i))*90, 40, 40);
    }
    fill(owner.playerColor);
    for (int i =0; i<=maxAmmo; i++) {
      if (ammo>i)ellipse(owner.cx+cos(radians(i*360/maxAmmo-r))*90, owner.cy+sin(radians(i*360/maxAmmo-r))*90, 30, 30);
    }
    owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
  }
  public void reload() {
    r=-30;
    owner.stop();
    particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 20, 24, 200, owner.playerColor));
    particles.add( new  Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 0, 0, PApplet.parseInt(owner.w), 800, color(255, 0, 255)));
    ammo=maxAmmo;
  }

  public void reset() {
    super.reset();
    active=false;
    deChannel();
    energy=50;
    ammo=maxAmmo;
    cooldown=0;
  }
}
class ForceShoot extends Ability {//---------------------------------------------------    forceShoot   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=60;
  final int damageFactor=4;
  float forceAmount=0, MODIFIED_MAX_ACCEL=0.02f, MODIFIED_ANGLE_FACTOR=0.16f;
  float ChargeRate=0.4f, restForce;

  ForceShoot() {
    super();
    name=getClassName(this);
    activeCost=8;
    channelCost=0.1f;
  } 
  public @Override
    void action() {
    if (forceAmount>=MAX_FORCE) { 
      particles.add(new Flash(100, 6, WHITE)); 
      particles.add(new Gradient(1000, PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 0, 0, 4, 100, owner.angle, owner.playerColor));
      shakeTimer+=10;
    }
    projectiles.add( new forceBall(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), forceAmount*2+4, 30, owner.playerColor, 2000, owner.angle, forceAmount*damageFactor));
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity) && energy>(0+activeCost)&& !hold && !active && !channeling && !owner.dead) {
      activate();
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=false;
    }
  }
  public @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity) &&  active && !owner.dead) {
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      if (MAX_FORCE>forceAmount) { 
        channel();
        if (!active || energy<0 ) {
          release();
        }
        restForce = MAX_FORCE-forceAmount;
        forceAmount+=ChargeRate*timeBend; 
        particles.add(new RParticles(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*75), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*75), random(-restForce*0.5f, restForce*0.5f), random(-restForce*0.5f, restForce*0.5f), PApplet.parseInt(random(30)+10), 200, owner.playerColor));
        particles.add(new ShockWave(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*75), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*75), PApplet.parseInt(forceAmount*.5f), 16, PApplet.parseInt(forceAmount*.5f), owner.playerColor));
      } else {
        particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*75), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*75), 0, 0, PApplet.parseInt(MAX_FORCE*1.5f), 30, color(255, 0, 255)));
      }
    }
    if (!active)press(); // cancel
    if (owner.hit)release(); // cancel
  }
  public @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
        owner.pushForce(-forceAmount, owner.angle);
        regen=true;
        action();
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        forceAmount=0;
      }
    }
  }
  public void reset() {
    super.reset();
    forceAmount=0;
    //   hold=false;
    //  active=false;
    regen=true;
    //  channeling=false;
    deChannel();
    release();
  }
  public @Override
    void passive() {
    if (MAX_FORCE<=forceAmount) {
      fill(255);
      pushMatrix();
      translate(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy));
      rotate(radians(owner.angle-90));
      rect(-5, 0, 10, 2000);
      popMatrix();
    }
  }
}

class Blink extends Ability {//---------------------------------------------------    Blink   ---------------------------------
  final int range=250, damage=50;
  Blink() {
    super();
    name=getClassName(this);
    activeCost=10;
  } 
  public @Override
    void action() {
    stamps.add( new ControlStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 20, 16, 200, owner.playerColor));
    particles.add( new  Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 0, 0, PApplet.parseInt(owner.w), 800, color(255, 0, 255)));
    for (int i =0; i<3; i++) {
      particles.add( new Feather(300, PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), random(-2, 2), random(-2, 2), 15, owner.playerColor));
    }
    owner.x+=cos(radians(owner.angle))*range;
    owner.y+=sin(radians(owner.angle))*range;
    checkInside();
    //projectiles.add( new IceDagger(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, 10));

    particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 20, 16, 200, owner.playerColor));
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
  public void checkInside() {
    for (Player enemy : players) {
      if (!enemy.dead  && owner.ally != enemy.ally && dist(owner.x, owner.y, enemy.x, enemy.y)<90) {
        enemy.hit(damage);
        energy+=activeCost;
        particles.add(new Flash(100, 8, BLACK));  
        particles.add( new TempFreeze(200));
        //for (int i =0; i<2; i++) {
        particles.add( new Feather(300, PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), random(-4, 4), random(-4, 4 ), 20, enemy.playerColor));
        //}
        particles.add(new ShockWave(PApplet.parseInt(enemy.x+enemy.radius), PApplet.parseInt(enemy.y+enemy.radius), 300, 16, 300, WHITE));
        particles.add(new ShockWave(PApplet.parseInt(enemy.x+enemy.radius), PApplet.parseInt(enemy.y+enemy.radius), 100, 16, 300, owner.playerColor));
        for (int i=0; i<360; i+=30) particles.add(new Spark( 1000, PApplet.parseInt(enemy.x+enemy.radius), PApplet.parseInt(enemy.y+enemy.radius), -cos(radians(i))*5, -sin(radians(i))*5, 6, i, owner.playerColor));
      }
    }
  }
}
class Multiply extends Ability {//---------------------------------------------------    Multiply   ---------------------------------
  int range=playerSize, cloneDamage=3, dir;
  ArrayList<Player> cloneList= new ArrayList<Player>();
  Player currentClone;
  Multiply() {
    super();
    name=getClassName(this);
    activeCost=80;
  } 
  public @Override
    void action() {
    for (int i=0; i<5; i++) {
      particles.add(new Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), random(-10, 10), random(-10, 10), PApplet.parseInt(random(20)+5), 800, 255));
    }
    // stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    try {
      switch(dir%4) {
      case 0:
        currentClone=new Player(players.size()-1, owner.playerColor, PApplet.parseInt(owner.x-cos(radians(owner.angle))*range), PApplet.parseInt(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.down, owner.up, owner.right, owner.left, owner.triggKey, new CloneMultiply(), owner.abilityList.get(1).clone());
        break;
      case 1:
        currentClone=new Player(players.size()-1, owner.playerColor, PApplet.parseInt(owner.x-cos(radians(owner.angle))*range), PApplet.parseInt(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.right, owner.left, owner.up, owner.down, owner.triggKey, new CloneMultiply(), owner.abilityList.get(1).clone());
        break;
      case 2:
        currentClone=new Player(players.size()-1, owner.playerColor, PApplet.parseInt(owner.x-cos(radians(owner.angle))*range), PApplet.parseInt(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.up, owner.down, owner.left, owner.right, owner.triggKey, new CloneMultiply(), owner.abilityList.get(1).clone());
        break;
      case 3:
        currentClone=new Player(players.size()-1, owner.playerColor, PApplet.parseInt(owner.x-cos(radians(owner.angle))*range), PApplet.parseInt(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.left, owner.right, owner.down, owner.up, owner.triggKey, new CloneMultiply(), owner.abilityList.get(1).clone());
        break;
      }
    }
    catch(Exception e) {
      println(e);
    }
    dir++;


    // clone.add(players.get(players.size()-1));
    // clone.add(players.get(players.size()-1));
    // Player currentClone=clone.get(clone.size()-1);

    owner.x+=cos(radians(owner.angle))*range;
    owner.y+= sin(radians(owner.angle))*range;
    currentClone.clone=true;
    currentClone.ally=owner.ally; //same ally
    currentClone.dead=true;
    currentClone.damage=cloneDamage;
    currentClone.holdTrigg=true;
    players.add(currentClone);
    cloneList.add(currentClone);
    //stamps.add( new StateStamp(currentClone.index, int(owner.x), int(owner.y), owner.state, owner.health, true));
    stamps.add( new StateStamp(players.size()-1, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), owner.state, owner.health, true));
    currentClone.dead=false;
    currentClone.maxHealth=PApplet.parseInt(owner.maxHealth*0.5f);
    currentClone.health=PApplet.parseInt(owner.health*0.5f);
    currentClone.abilityList.get(0).energy=PApplet.parseInt(owner.abilityList.get(0).energy);

    //   owner.ability.owner=owner;
    /* for (int i =players.size()-1; i>= 0; i--) {
     if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
     }*/
  }
  public @Override
    void reset() {
    cloneList.clear();
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
}
class CloneMultiply extends Multiply { // ability that have no effect as clones.
  int damage=50;
  CloneMultiply() {
    super();
    name=getClassName(this);
  }
  public @Override
    void action() {
    //projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 75, owner.playerColor, 1000, owner.angle, 0, 0, damage, false));
    for (int i=0; i<10; i++) {
      particles.add(new Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), random(-10, 10), random(-10, 10), PApplet.parseInt(random(20)+5), 800, 255));
    }
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
  public @Override
    void reset() {
    super.reset();
    //if (owner.turret || owner.clone) players.remove( owner);
    //for (TimeStamp s:stamps )if(s.playerIndex==players.indexOf(owner))stamps.remove(players.indexOf(owner));


    /* for (int i =players.size()-1; i>= 0; i--) {
     if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
     }*/
  }
  public @Override
    void onDeath() {
    if ((!reverse || owner.reverseImmunity)&&  owner.health<=0 && (!freeze || owner.freezeImmunity)) {
      projectiles.add( new Bomb(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 120, owner.playerColor, 1000, owner.angle, owner.vx, owner.vy, damage, false));
    }
  }
}

class Stealth extends Ability {//---------------------------------------------------    Stealth   ---------------------------------
  int projectileDamage=12, wait;
  float MODIFIED_MAX_ACCEL=0.06f;
  float range=200, duration=300;
  Stealth() {
    super();
    active=false;
    name=getClassName(this);
    activeCost=25;
    energy=25;
  } 
  public @Override
    void action() {
    stamps.add( new StateStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), owner.state, owner.health, owner.dead));
    particles.add( new  Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 0, 0, PApplet.parseInt(owner.w), 300, color(255, 0, 255)));
    //  for (int i =0; i<10; i++) {
    particles.add( new Feather(300, PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), random(-2, 2), random(-2, 2), 500, owner.playerColor));
    //}
    owner.stealth=true;
  }
  public @Override
    void press() {

    if ((!reverse || owner.reverseImmunity)&& !owner.dead && (!freeze || owner.freezeImmunity)) {
      if (energy>0+activeCost && !active) { 
        stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new StateStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), owner.state, owner.health, owner.dead));

        regen=false;
        activate();
        particles.add(new Flash(300, 6, owner.playerColor));  
        action();
        owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      } else if (owner.stealth) {
        stamps.add( new StateStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), owner.state, owner.health, owner.dead));
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        regen=true;
        owner.stealth=false;
        particles.add(new TempSlow(PApplet.parseInt(wait*.1f), 0.02f, 1.06f));
        particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 20, 16, 200, owner.playerColor));
        projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 30, owner.playerColor, PApplet.parseInt(duration), owner.angle, 24, range, 0, 0, PApplet.parseInt(projectileDamage+wait*0.1f), true));
        wait=0;
      }
    }
  }

  public @Override
    void reset() {
    owner.stealth=false;
    active=false;
    regen=true;
    energy=25;
  }
  public @Override
    void passive() {
    if (owner.stealth ) {
      if (wait<400)wait++;
      //text(wait, owner.x, owner.y);
      //line(owner.x,owner.x,owner.x+cos(),owner.y+sin());
      if ( PApplet.parseInt(random(60))==0)particles.add(new Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), random(-5, 5), random(-5, 5), PApplet.parseInt(random(20)+5), 600, 255));
    }
  }
}


class Combo extends Ability {//---------------------------------------------------    Combo   ---------------------------------
  int projectileDamage=34, step=1, maxStep=3, damage=10, shootSpeed=35;
  float MODIFIED_MAX_ACCEL=0.08f, MODIFIED_MAX_ACCEL_2=0.25f, MODIFIED_FRICTION_FACTOR=0.12f;
  int comboMinWindow= 185, comboMaxWindow=800;
  long comboWindowTimer;
  int stepActivateCost[]={0, 10, 5, 8, 5};
  Combo() {
    super();
    active=false;
    name=getClassName(this);
    activeCost=stepActivateCost[1];
    energy=110;
  } 

  public @Override
    void action() {
    //stamps.add( new StateStamp(owner.index, int(owner.x), int(owner.y), owner.state, owner.health, owner.dead));
    // particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 300, color(255, 0, 255)));
    //for (int i =0; i<10; i++) {
    //  particles.add( new Feather(300, int(owner.cx), int(owner.cy), random(-2, 2), random(-2, 2), 500, owner.playerColor));
    //}
    if (step==1||stampTime>comboWindowTimer+comboMinWindow && stampTime<comboWindowTimer+comboMaxWindow) {
      activate();
      comboWindowTimer=stampTime;
      //particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, 200, 300, color(255, 0, 255)));
      //particles.add(new Flash(300, 6, owner.playerColor));
      attack();
      if (step<maxStep)step++;
      else step=1;
    } else {
      if (step>1)step=1;
      comboWindowTimer=stampTime;
    }
    regen=true;
  }
  public void attack() {
    switch(step) {
    case 1:
      projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*75), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*75), 30, owner.playerColor, 130, owner.angle-100, -24, 100, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, PApplet.parseInt(damage*0.4f), true));
      owner.pushForce(5, owner.angle);
      if (!freeze ) {
        projectiles.add( new Shield( owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle+30))*150), PApplet.parseInt(owner.cy+sin(radians(owner.angle+30))*150), owner.playerColor, 325, owner.angle-90+30, damage, PApplet.parseInt(cos(radians(owner.angle+30))*125), PApplet.parseInt(sin(radians(owner.angle+30))*125)));
        projectiles.add( new Shield( owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*150), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*150), owner.playerColor, 350, owner.angle-90, damage, PApplet.parseInt(cos(radians(owner.angle))*125), PApplet.parseInt(sin(radians(owner.angle))*125)));
        projectiles.add( new Shield( owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle-30))*150), PApplet.parseInt(owner.cy+sin(radians(owner.angle-30))*150), owner.playerColor, 375, owner.angle-90-30, damage, PApplet.parseInt(cos(radians(owner.angle-30))*125), PApplet.parseInt(sin(radians(owner.angle-30))*125)));
      } else {
        projectiles.add( new Shield( owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle+30))*150), PApplet.parseInt(owner.cy+sin(radians(owner.angle+30))*150), owner.playerColor, 325, owner.angle-90+30, damage));
        projectiles.add( new Shield( owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*150), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*150), owner.playerColor, 350, owner.angle-90, damage));
        projectiles.add( new Shield( owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle-30))*150), PApplet.parseInt(owner.cy+sin(radians(owner.angle-30))*150), owner.playerColor, 375, owner.angle-90-30, damage));
      }
      break;
    case 2:
      projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*65), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*65), 32, owner.playerColor, 130, owner.angle+100, 24, 130, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, PApplet.parseInt(damage*0.6f), true));
      owner.pushForce(20, owner.angle);
      particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 20, 16, 175, owner.playerColor));

      break;
    case 3:
      projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 30, owner.playerColor, 500, owner.angle+200, -25, 175, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, PApplet.parseInt(damage*0.9f), true));
      owner.pushForce(4, owner.angle);
      particles.add( new Feather(350, PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), owner.vx, owner.vy, 30, owner.playerColor));

      // projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 20, owner.playerColor, 600, owner.angle-20, cos(radians(owner.angle-20))*shootSpeed, sin(radians(owner.angle-20))*shootSpeed, damage*2, false));
      //  projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 20, owner.playerColor, 600, owner.angle+20, cos(radians(owner.angle+20))*shootSpeed, sin(radians(owner.angle+20))*shootSpeed, damage*2, false));
      // projectiles.add( new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 1000, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage*2, false));
      //owner.pushForce(-18, owner.angle);
      break;
    case 4:
      break;
    case 5:
      break;
    }
  }
  public @Override
    void press() {

    if ((!reverse || owner.reverseImmunity)&& !owner.dead && (!freeze || owner.freezeImmunity)) {
      activeCost=stepActivateCost[step];
      if (energy>0+activeCost ) { 
        stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new StateStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), owner.state, owner.health, owner.dead));

        //particles.add(new Flash(300, 6, owner.playerColor));  
        action();
        // owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      }
    }
  }
  public @Override
    void reset() {
    super.reset();
    active=false;
    regen=true;
    //energy=maxEnergy;
  }
  public @Override
    void passive() {
    //if (owner.stealth && int(random(60))==0)particles.add(new Particle(int(owner.cx), int(owner.cy), random(-5, 5), random(-5, 5), int(random(20)+5), 600, 255));
    if (step==3) {
      owner.MAX_ACCEL= MODIFIED_MAX_ACCEL_2;
      owner.FRICTION_FACTOR=MODIFIED_FRICTION_FACTOR;
      // if(random(10)<2)particles.add( new Feather(350, int(owner.cx), int(owner.cy), random(-1, 1), random(-1, 1), 30, owner.playerColor));
      particles.add(new Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), owner.vx, owner.vy, 120, 50, WHITE));
    } else {
      owner.MAX_ACCEL= MODIFIED_MAX_ACCEL;
      owner.FRICTION_FACTOR= DEFAULT_FRICTION;
    }

    if (debug)text(step, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y));
    if (stampTime>comboWindowTimer+comboMaxWindow) {
      if (step>1)step--;
      comboWindowTimer=stampTime;
    }
  }
}

class Laser extends Ability {//---------------------------------------------------    Laser   ---------------------------------
  int damage=3, duration=2400, delay=500, laserWidth=75, chargelevel;
  long timer;
  float MODIFIED_ANGLE_FACTOR=0, MODIFIED_MAX_ACCEL=0.006f; 
  long startTime;
  boolean charging;
  ArrayList<Projectile> laserList = new ArrayList<Projectile>();

  Laser() {
    super();
    name=getClassName(this);
    activeCost=24;
  } 
  public @Override
    void action() {
    timer=millis();
    chargelevel++;
    particles.add(new Gradient(150*chargelevel, PApplet.parseInt(owner.cx +cos(radians(owner.angle))*owner.radius), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 75*chargelevel, 6*chargelevel, owner.angle, owner.playerColor));
    particles.add(new RShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 270*chargelevel, 16+10*chargelevel, 150*chargelevel, owner.playerColor));
    charging=true;
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      action();
      startTime=stampTime;
      deActivate();
      // particles.add(new  Gradient(1000,int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 3, owner.angle, owner.playerColor));
    }
  }
  public void passive() {
    if (charging && (timer+delay/S/F)<millis()) {
      particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 200*chargelevel, 16, 500, owner.playerColor));
      particles.add(new Flash(50, 6, WHITE)); 

      Projectile l =new ChargeLaser(owner, PApplet.parseInt( owner.cx+random(50, -50)), PApplet.parseInt(owner.cy+random(50, -50)), laserWidth*chargelevel, owner.playerColor, duration, owner.angle, 0, damage*chargelevel, true);
      laserList.add(l);
      projectiles.add(l);
      // projectiles.add( new ChargeLaser(owner, int( owner.cx+random(50, -50)), int(owner.cy+random(50, -50)), laserWidth*chargelevel, owner.playerColor, duration, owner.angle, damage*chargelevel));

      charging=false;
      chargelevel=0;
    } else {
      owner.ANGLE_FACTOR=(owner.DEFAULT_ANGLE_FACTOR/duration)*(stampTime-startTime)*0.02f*timeBend;
      owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.3f*timeBend;
      if (stampTime>=duration+startTime) {
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
      }
    }
  }
  public @Override
    void reset() {
    for ( Projectile l : laserList) {
      l.deathTime=stampTime;
      l.dead=true;
    }
    laserList.clear();
    owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    charging=false;
    chargelevel=0;
    startTime=0;
    deActivate();
    timer=0;
    super.reset();
  }
}
class Shotgun extends Ability {//---------------------------------------------------    Shotgun   ---------------------------------
  int damage=4, duration=900, delay=300, laserWidth=75, chargelevel;
  long timer;
  float MODIFIED_ANGLE_FACTOR=0.5f, MODIFIED_MAX_ACCEL=0.006f; 
  long startTime;
  boolean charging;
  Shotgun() {
    super();
    name=getClassName(this);
    activeCost=30;
    regenRate=0.23f;
  } 
  public @Override
    void action() {
    timer=millis();
    // chargelevel++;
    // particles.add(new Gradient(150*chargelevel, int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 75*chargelevel, 6*chargelevel, owner.angle, owner.playerColor));
    particles.add(new RShockWave(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*120), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*120), 300, 16+10, 150, WHITE));
    charging=true;
    //projectiles.add( new ChargeLaser(owner.index, int( owner.cx), int(owner.cy), owner.playerColor, duration, owner.angle, damage));
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !charging&& !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      if (!charging)action();
      startTime=stampTime;
      deActivate();
      // particles.add(new  Gradient(1000,int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 3, owner.angle, owner.playerColor));
    }
  }
  public void passive() {
    if (charging && (timer+delay/S/F)<millis()) {
      //particles.add(new ShockWave(int(owner.cx), int(owner.cy), 200*chargelevel, 16, 500, owner.playerColor));
      //particles.add(new Flash(50, 6, WHITE)); 
      projectiles.add( new Bomb(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 40, owner.playerColor, 1, owner.angle, cos(radians(owner.angle))*20, sin(radians(owner.angle))*20, damage, false));
      projectiles.add( new  Blast(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, 100, owner.playerColor, 200, owner.angle, damage));
      projectiles.add( new  Blast(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 20, 200, owner.playerColor, 200, owner.angle, damage));

      for (int i=0; i<8; i++) { //!!!
        float InAccurateAngle=random(-35, 35), shotSpeed=random(30, 80);
        projectiles.add( new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*shotSpeed, sin(radians(owner.angle+InAccurateAngle))*shotSpeed, damage));
      }
      owner.pushForce(-40, owner.angle);
      charging=false;
      // chargelevel=0;
    } else {
      owner.ANGLE_FACTOR=(owner.DEFAULT_ANGLE_FACTOR/duration)*(stampTime-startTime)*0.03f*timeBend;
      owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.4f*timeBend;
      if (stampTime>=duration+startTime) {
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
      }
    }
  }
  public void reset() {
    super.reset();
    charging=false;
    owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class TimeBomb extends Ability {//---------------------------------------------------    TimeBomb   ---------------------------------
  int damage=55;
  int shootSpeed=32;
  TimeBomb() {
    super();
    name=getClassName(this);
    activeCost=12;
    regenRate=0.23f;
    energy=maxEnergy*0.5f;
  } 
  public @Override
    void action() {
    owner.pushForce(-8, owner.angle);
    //if (int(random(5))!=0) {
    if (energy<maxEnergy-activeCost) {
      projectiles.add( new Bomb(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, PApplet.parseInt(random(500, 2000)), owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, true));
    } else {
      projectiles.add( new Mine(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 80000, owner.angle, cos(radians(owner.angle))*shootSpeed*0.5f, sin(radians(owner.angle))*shootSpeed*0.5f, damage, true));
      particles.add(new Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*325), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*325), 0, 0, 100, 300, BLACK));
    }
  }
  public @Override
    void passive() {
    if (energy>=maxEnergy) {
      noFill();
      strokeWeight(4);
      stroke(owner.playerColor);
      rect(owner.cx+cos(radians(owner.angle))*325-25, owner.cy+sin(radians(owner.angle))*325-25, 50, 50);
      stroke(color(random(255)));
      rect(owner.cx+cos(radians(owner.angle))*325-35, owner.cy+sin(radians(owner.angle))*325-35, 70, 70);
      for (int i = 0; i <= 7; i++) {
        float x = lerp(owner.cx, owner.cx+cos(radians(owner.angle))*325, i/10.0f) + 10;
        float y = lerp(owner.cy, owner.cy+sin(radians(owner.angle))*325, i/10.0f);
        point(x, y);
      }
    }
  }

  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
}


class ElemetalLauncher extends Ability {//---------------------------------------------------    ElemetalLauncher   ---------------------------------
  int  damage=28, shootSpeed=30, ammoType=0, maxAmmotype=6;
  float MODIFIED_MAX_ACCEL=0.1f; 
  Containable payload[];
  ElemetalLauncher() {
    super();
    cooldownTimer=500;
    name=getClassName(this);
    activeCost=25;
    regenRate=0.2f;
    energy=130;
  } 
  public @Override
    void action() {
    stamps.add( new ControlStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 20, 16, 200, owner.playerColor));
    particles.add( new  Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 0, 0, PApplet.parseInt(owner.w), 800, color(255, 0, 255)));
    switch(ammoType%maxAmmotype) {
    case 1:
      Container waterRocket= new Rocket(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 900, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
      payload=new Containable[2];
      payload[0]= new ChargeLaser(owner, 0, 0, 1000, owner.playerColor, 150, owner.angle+180, 20, damage*.4f ).parent(waterRocket); 
      payload[1]= new ChargeLaser(owner, 0, 0, 1000, owner.playerColor, 150, owner.angle+180, -20, damage*.4f ).parent(waterRocket); 

      waterRocket.contains(payload);
      projectiles.add((Projectile)waterRocket);
      break;
    case 2:
      Container thunderRocket= new Rocket(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 700, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
      payload=new Containable[6];
      for (int i=0; i<6; i++) {
        payload[i] =new Thunder(owner, PApplet.parseInt(random(600)-300), PApplet.parseInt(random(600)-300), 200, color(owner.playerColor), 500+(150*i), 0, 0, 0, PApplet.parseInt(damage*2.5f), 0, false).parent(thunderRocket);
      }
      thunderRocket.contains(payload);
      projectiles.add((Projectile)thunderRocket);
      break;
    case 3:
      Container rockRocket= new Rocket(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*shootSpeed*.5f+owner.vx, sin(radians(owner.angle))*shootSpeed*.5f+owner.vy, damage, false);
      payload=new Containable[1];
      payload[0]= new Block(players.size(), owner, 0, 0, 200, 200, 200, new Armor()).parent(rockRocket);
      rockRocket.contains(payload);
      projectiles.add((Projectile)rockRocket);
      break;

    case 4:
      Container natureRocket= new Rocket(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 700, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
      payload=new Containable[1];
      payload[0]= new  Heal(owner, 0, 0, 400, owner.playerColor, 10000, 0, 1, 1, 4, true).parent(natureRocket) ;
      natureRocket.contains(payload);
      projectiles.add((Projectile)natureRocket);
      break;
    case 5:
      Container iceRocket= new Rocket(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 500, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
      payload=new Containable[12];
      for (int i=0; i<12; i++) {
        payload[i] =new IceDagger(owner, 0, 0, 25, owner.playerColor, 2000, owner.angle, random(40)-20+cos(radians(owner.angle))*shootSpeed*1.2f, random(40)-20+sin(radians(owner.angle))*shootSpeed*1.2f, PApplet.parseInt(damage*.4f)).parent(iceRocket);
      }
      iceRocket.contains(payload);
      projectiles.add((Projectile)iceRocket);
      break;
    default:

      Container fireRocket= new Rocket(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 500, owner.angle, cos(radians(owner.angle))*shootSpeed*1.5f+owner.vx, sin(radians(owner.angle))*shootSpeed*1.5f+owner.vy, damage, false);
      payload=new Containable[11];

      for (int i=0; i<10; i++) {
        payload[i]= new  Blast(owner, PApplet.parseInt(cos(radians(i*36))*120), PApplet.parseInt(sin(radians(i*36))*120), 15, 100, owner.playerColor, 400, i*36, 1, 15).parent(fireRocket);
      }
      payload[10]= new  Blast(owner, 0, 0, 0, 600, owner.playerColor, 400, 0, 1, 20).parent(fireRocket);
      fireRocket.contains(payload);
      projectiles.add((Projectile)fireRocket);
      break;
    }
    owner.pushForce(-10, owner.angle);
    ammoType++;
    particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 20, 16, 200, owner.playerColor));
  }
  public void passive() {
    noStroke();
    textSize(24);
    fill(255);
    switch(ammoType%maxAmmotype) {
    case 0:
      text("FIRE", PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy-90));
      break;
    case 1:
      text("WATER", PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy-90));
      break;
    case 2:
      text("LIGHTNING", PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy-90));
      break;
    case 3:
      text("ROCK", PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy-90));
      break;
    case 4:
      text("NATURE", PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy-90));
      break;
    case 5:
      text("ICE", PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy-90));
      break;
    }
    owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
  }
  public @Override
    void press() {
    //(!reverse || owner.reverseImmunity)
    if (cooldown<stampTime &&(!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      enableCooldown();
      activate();
      action();
      deActivate();
    }
  }
  public @Override
    void reset() {
    super.reset();
    energy=90;
    deActivate();
    deChannel();
    regen=true;
    active=false;
    cooldown=stampTime;
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}




class Bazooka extends Ability {//---------------------------------------------------    Bazooka   ---------------------------------
  int  damage=28, shootSpeed=40, ammoType=2, maxAmmotype=4;
  float MODIFIED_MAX_ACCEL=0.06f; 
  Bazooka() {
    super();
    cooldownTimer=1000;
    name=getClassName(this);
    activeCost=22;
    regenRate=0.13f;
    energy=130;
  } 
  public @Override
    void action() {
    stamps.add( new ControlStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 20, 16, 200, owner.playerColor));
    particles.add( new  Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 0, 0, PApplet.parseInt(owner.w), 800, color(255, 0, 255)));
    switch(ammoType%maxAmmotype) {

    case 0:
      projectiles.add( new RCRocket(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 2500, owner.angle, 0, cos(radians(owner.angle))*shootSpeed*.02f+owner.vx, sin(radians(owner.angle))*shootSpeed*.02f+owner.vy, damage, false));
      break;
    case 1:

      Container clusterRocket= new Rocket(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 1000, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
      Containable payload[]={
        new Bomb(owner, 0, 0, 25, owner.playerColor, 1000, 0, cos(radians(0))*12, sin(radians(0))*12, damage, false).parent(clusterRocket), 
        new Bomb(owner, 0, 0, 25, owner.playerColor, 1000, 60, cos(radians(60))*12, sin(radians(60))*12, damage, false).parent(clusterRocket), 
        new Bomb(owner, 0, 0, 25, owner.playerColor, 1000, 120, cos(radians(120))*12, sin(radians(120))*12, damage, false).parent(clusterRocket), 
        new Bomb(owner, 0, 0, 25, owner.playerColor, 1000, 180, cos(radians(180))*12, sin(radians(180))*12, damage, false).parent(clusterRocket), 
        new Bomb(owner, 0, 0, 25, owner.playerColor, 1000, 245, cos(radians(240))*12, sin(radians(245))*12, damage, false).parent(clusterRocket), 
        new Bomb(owner, 0, 0, 25, owner.playerColor, 1000, 300, cos(radians(300))*12, sin(radians(300))*12, damage, false).parent(clusterRocket), 
      };

      clusterRocket.contains(payload);

      projectiles.add((Projectile)clusterRocket);
      break;
    case 2:
      SinRocket sr;
      /*for (int i=0; i<360; i+=12) {
       sr= new SinRocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 2500, owner.angle, cos(radians(owner.angle))*shootSpeed*.01+owner.vx, sin(radians(owner.angle))*shootSpeed*.01+owner.vy, damage, false);
       sr.count=i;
       projectiles.add( sr);
       }*/
      sr= new SinRocket(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 2500, owner.angle, cos(radians(owner.angle))*shootSpeed*.01f+owner.vx, sin(radians(owner.angle))*shootSpeed*.01f+owner.vy, damage*2, false);
      sr.count=90;
      projectiles.add( sr);
      sr= new SinRocket(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 2500, owner.angle, cos(radians(owner.angle))*shootSpeed*.01f+owner.vx, sin(radians(owner.angle))*shootSpeed*.01f+owner.vy, damage*2, false);
      sr.count=275;
      projectiles.add( sr);
      break;
    case 3:
      projectiles.add( new Missle(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 30, owner.playerColor, 7000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, false));

      break;
    }
    owner.pushForce(-18, owner.angle);
    ammoType++;
    particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 20, 16, 200, owner.playerColor));
  }
  public void passive() {
    noFill();
    stroke(255);
    strokeWeight(3);
    triangle(PApplet.parseInt( owner.cx-45), PApplet.parseInt(owner.cy-110), PApplet.parseInt( owner.cx+45), PApplet.parseInt(owner.cy-110), PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy-30));
    textSize(16);
    fill(255);
    switch(ammoType%maxAmmotype) {
    case 0:
      text("RC", PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy-90));
      break;
    case 1:
      text("CL", PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy-90));
      break;
    case 2:
      text("SN", PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy-90));
      break;
    case 3:
      text("MI", PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy-90));
      break;
    }
    owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
  }
  public @Override
    void press() {
    //(!reverse || owner.reverseImmunity)
    if (cooldown<stampTime &&(!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      enableCooldown();
      activate();
      action();
      deActivate();
    }
  }
  public @Override
    void reset() {
    super.reset();
    energy=90;
    release();
    deActivate();
    deChannel();
    regen=true;
  }
}

class Stars extends Ability {//---------------------------------------------------    Stars   ---------------------------------
  int  damage=15, shootSpeed=8;
  float MODIFIED_MAX_ACCEL=0.04f; 
  Stars() {
    super();
    cooldownTimer=1000;
    name=getClassName(this);
    activeCost=32;
    regenRate=0.17f;
    energy=130;
  } 
  public @Override
    void action() {
    stamps.add( new ControlStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 50, 16, 500, owner.playerColor));
    // particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    for (int i=0; i<359; i+=40) {
      projectiles.add( new RCRocket(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle+i))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle+i))*50), 10, owner.playerColor, 1700, owner.angle+i, i, cos(radians(owner.angle+i))*shootSpeed*.02f+owner.vx, sin(radians(owner.angle+i))*shootSpeed*.02f+owner.vy, damage, false));
    }
    owner.pushForce(5, owner.angle);
    // particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
  }
  public void passive() {
    // noFill();
    // stroke(255);
    //strokeWeight(3);
    //triangle(int( owner.cx-45), int(owner.cy-110), int( owner.cx+45), int(owner.cy-110), int( owner.cx), int(owner.cy-30));
    if (cooldown<stampTime)owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
    else owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
  public @Override
    void press() {
    //(!reverse || owner.reverseImmunity)
    if (cooldown<stampTime &&(!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      enableCooldown();
      activate();
      action();
      deActivate();
    }
  }
  public @Override
    void reset() {
    super.reset();
    energy=90;
    release();

    deActivate();
    deChannel();
    regen=true;
  }
}

class RapidFire extends Ability {//---------------------------------------------------    RapidFire   ---------------------------------
  float accuracy = 1, MODIFIED_ANGLE_FACTOR=-0.0008f, r=50  ;
  int Interval=110;
  long  PastTime;
  int projectileDamage=5;
  RapidFire() {
    super();
    name=getClassName(this);
    deactiveCost=6;
    channelCost=0.15f;
  } 

  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity) && energy>(0+activeCost) && !active && !channeling && !owner.dead) {
      activate();
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=false;
    }
  }
  public @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead &&(stampTime-PastTime) >= Interval) {
      float InAccurateAngle=random(-accuracy, accuracy);
      projectiles.add( new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
      particles.add(new ShockWave(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*85), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*85), 5, 22, 20, WHITE));
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      r=50;
      channel();
      if (!active || energy<0 ) {
        release();
      }
      PastTime=stampTime;
    } else if ((!freeze || owner.freezeImmunity) &&  active && !owner.dead &&(stampTime+freezeTime-PastTime) >= Interval) {
      float InAccurateAngle=random(-accuracy, accuracy);
      projectiles.add( new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
      particles.add(new ShockWave(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*85), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*85), 5, 22, 20, WHITE));
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      r=50;
      channel();
      if (!active || energy<0 ) {
        release();
      }
      PastTime=freezeTime+stampTime;
    }
    // if (!active)press(); // cancel
    if (owner.hit)release(); // cancel
  }
  public @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      }
    }
  }
  public @Override
    void passive() {
    stroke(owner.playerColor);
    strokeWeight(12);
    if (r<100)r*=1.1f;
    line(owner.cx, owner.cy, owner.cx+cos(radians(owner.angle))*r, owner.cy+sin(radians(owner.angle))*r);
  }
}

class MachineGun extends RapidFire {//---------------------------------------------------    MachineGun   ---------------------------------

  int alt, count, retractLength=40, projectileSpeed=55;
  float sutainCount, MAX_sutainCount=110, e, t;
  MachineGun() {
    super();
    name=getClassName(this);
    deactiveCost=5;
    channelCost=0.2f;
    accuracy = 0;
    projectileDamage=6;
    cooldownTimer=900;
    e=10;
    t=10;
    r=10;
    MODIFIED_ANGLE_FACTOR=0.001f;
  } 
  public void press() {
    super.press();
  }
  public void action() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead &&(stampTime-PastTime) >= Interval) {
      float InAccurateAngle=random(-accuracy, accuracy);
      channel();
      if (!active || energy<0 ) {
        release();
        //if(sutainCount>10)sutainCount-=10;
      }
      PastTime=stampTime;
      alt++;
      if (alt%3==0) {
        e=retractLength;
        projectiles.add( new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w+cos(radians(owner.angle+90))*17), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w+sin(radians(owner.angle+90))*17), 60, owner.playerColor, 600, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage));
        particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*100+cos(radians(owner.angle+90))*17), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*100+sin(radians(owner.angle+90))*17), 0, 0, 50, 50, WHITE));
      } else if (alt%3==1) {
        r=retractLength;
        projectiles.add( new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w+cos(radians(owner.angle-90))*17), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w+sin(radians(owner.angle-90))*17), 60, owner.playerColor, 600, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage));
        particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*100+cos(radians(owner.angle-90))*17), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*100+sin(radians(owner.angle-90))*17), 0, 0, 50, 50, WHITE));
      } else {  
        projectiles.add( new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 600, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage));
        particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*100+cos(radians(owner.angle+0))*17), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*100+sin(radians(owner.angle+0))*17), 0, 0, 50, 50, WHITE));
        t=retractLength;
      }
    } else if ((!freeze || owner.freezeImmunity) &&  active && !owner.dead &&(stampTime+freezeTime-PastTime) >= Interval) {
      float InAccurateAngle=random(-accuracy, accuracy);
      projectiles.add( new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage));
      channel();
      if (!active || energy<0 ) {
        release();
        //    if(sutainCount>10)sutainCount-=10;
      }
      PastTime=freezeTime+stampTime;
      alt++;
      if (alt%3==0)e=retractLength;
      else if (alt%3==1) r=retractLength;
      else  t=retractLength;
    }
  }
  public void hold() {
    owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
    if (cooldown<stampTime) {
      action();
      // if (!active)press(); // cancel
      if (owner.hit)        if (sutainCount>10)sutainCount-=10;
      //release(); // cancel

      sutainCount+=0.4f*timeBend;
      if (sutainCount>MAX_sutainCount) {
        sutainCount=MAX_sutainCount;
        owner.pushForce(1, owner.angle+180);
      }
      accuracy=sutainCount*0.1f;
      Interval=PApplet.parseInt((MAX_sutainCount+5-sutainCount)*5);
    }
  }

  public void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 0, 0, 100, 50, color(255, 0, 255)));

        owner.pushForce(8, owner.angle+180);

        for (int i=0; sutainCount/8>i; i++) {
          float InAccurateAngle=random(-accuracy*2, accuracy*2);
          projectiles.add( new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 700, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage*2));
        }
        owner.angle+=random(-90, 90);
        sutainCount=0;
        enableCooldown();
      }
    }
  }

  public @Override
    void passive() {
    int offset=17;
    stroke(owner.playerColor);
    strokeWeight(15);
    if (r<80)r*=1.1f;
    if (e<80)e*=1.1f;
    if (t<80)t*=1.1f;
    line(owner.cx+cos(radians(owner.angle+90))*offset, owner.cy+sin(radians(owner.angle+90))*offset, owner.cx+cos(radians(owner.angle))*e+cos(radians(owner.angle+90))*offset, owner.cy+sin(radians(owner.angle))*e+sin(radians(owner.angle+90))*offset);
    line(owner.cx+cos(radians(owner.angle))*offset, owner.cy+sin(radians(owner.angle))*offset, owner.cx+cos(radians(owner.angle))*t+cos(radians(owner.angle))*offset, owner.cy+sin(radians(owner.angle))*t+sin(radians(owner.angle))*offset);
    line(owner.cx+cos(radians(owner.angle-90))*offset, owner.cy+sin(radians(owner.angle-90))*offset, owner.cx+cos(radians(owner.angle))*r+cos(radians(owner.angle-90))*offset, owner.cy+sin(radians(owner.angle))*r+sin(radians(owner.angle-90))*offset);
  }
  public @Override
    void reset() {
    super.reset();
    energy=90;
    deActivate();
    deChannel();
    regen=true;
  }
}

class Sniper extends RapidFire {//---------------------------------------------------    Sniper   ---------------------------------


  final int  startAccuracy=100, nullRange=400;
  float sutainCount, MAX_sutainCount=40, inAccurateAngle=startAccuracy, MODIFIED_ANGLE_FACTOR=0, MODIFIED_MAX_ACCEL=0.05f; 
  Sniper() {
    super();
    name=getClassName(this);
    deactiveCost=6;
    activeCost=4;
    channelCost=0.1f;
    cooldownTimer=700;
    projectileDamage=210;
  } 
  public void press() {
    super.press();
  }
  public void hold() {
    if (cooldown<stampTime) {
      if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead &&(stampTime-PastTime) >= Interval) {
        owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
        owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;

        channel();
        if (!active || energy<0 ) {
          release();
        }
        PastTime=stampTime;
        //if (inAccurateAngle>0)inAccurateAngle *=0.96;
        if (inAccurateAngle>0)inAccurateAngle *=1-(0.04f*timeBend);
      } else if ((!freeze || owner.freezeImmunity) &&  active && !owner.dead &&(stampTime+freezeTime-PastTime) >= Interval) {
        owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
        owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
        channel();
        if (!active || energy<0 ) {
          release();
        }
        PastTime=freezeTime+stampTime;
        if (inAccurateAngle>0)inAccurateAngle *=1-(0.04f*timeBend);
      }
      // if (!active)press(); // cancel
      if (owner.hit &&inAccurateAngle<startAccuracy)inAccurateAngle+=20; //release(); // cancel

      sutainCount+=0.4f;
      if (sutainCount>MAX_sutainCount) {
        sutainCount=MAX_sutainCount;
        //owner.pushForce(1, owner.angle+180);
      }
      //if (inAccurateAngle>0)inAccurateAngle *=0.96;
      //accuracy=sutainCount;
      Interval=PApplet.parseInt((MAX_sutainCount-sutainCount)*5);
    }
  }
  public void passive() {
    super.passive();
    if (cooldown<stampTime && active) {
      if (inAccurateAngle<0.1f)stroke(255);
      else stroke(owner.playerColor);
      //float xOffset=cos(radians(owner.angle))*nullRange;
      //float yOffset=sin(radians(owner.angle))*nullRange;

      strokeWeight(1);
      //   line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(inAccurateAngle*3.25+owner.angle))*2000), int(owner.cy+sin(radians(inAccurateAngle*3.25+owner.angle))*2000));
      //   line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(-inAccurateAngle*3.25+owner.angle))*2000), int(owner.cy+sin(radians(-inAccurateAngle*3.25+owner.angle))*2000));
      aimLine(nullRange, 2000, inAccurateAngle*3.25f);
      aimLine(nullRange, 2000, -inAccurateAngle*3.25f);
      noFill();
      //line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(inAccurateAngle*0.25+owner.angle))*500), int(owner.cy+sin(radians(inAccurateAngle*0.25+owner.angle))*500));
      // line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(-inAccurateAngle*0.25+owner.angle))*500), int(owner.cy+sin(radians(-inAccurateAngle*0.25+owner.angle))*500));

      aimLine(nullRange, 2000, inAccurateAngle*0.25f);
      aimLine(nullRange, 2000, -inAccurateAngle*0.25f);
      // line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(inAccurateAngle*0.5+owner.angle))*1000), int(owner.cy+sin(radians(inAccurateAngle*0.5+owner.angle))*1000));
      // line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(-inAccurateAngle*0.5+owner.angle))*1000), int(owner.cy+sin(radians(-inAccurateAngle*0.5+owner.angle))*1000));

      aimLine(nullRange, 2000, inAccurateAngle*0.5f);
      aimLine(nullRange, 2000, -inAccurateAngle*0.5f);
      strokeWeight(3);
      arc(owner.cx, owner.cy, nullRange*2, nullRange*2, radians(-inAccurateAngle+owner.angle), radians(inAccurateAngle+owner.angle));

      aimLine(nullRange, 2000, inAccurateAngle);
      aimLine(nullRange, 2000, -inAccurateAngle);
      //  line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(inAccurateAngle+owner.angle))*2000), int(owner.cy+sin(radians(inAccurateAngle+owner.angle))*2000));
      //line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(-inAccurateAngle+owner.angle))*2000), int(owner.cy+sin(radians(-inAccurateAngle+owner.angle))*2000));
    }
  }

  public void  aimLine(float begin, float end, float inAccurate) {
    line(owner.cx+cos(radians(inAccurate+owner.angle))*begin, owner.cy+sin(radians(inAccurate+owner.angle))*begin, PApplet.parseInt( owner.cx+cos(radians(inAccurate+owner.angle))*end), PApplet.parseInt(owner.cy+sin(radians(inAccurate+owner.angle))*end));
  }  

  public void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;

        float tempA=random(-inAccurateAngle, inAccurateAngle);
        projectiles.add( new SniperBullet(owner, PApplet.parseInt( owner.cx+cos(radians(tempA+owner.angle))*nullRange), PApplet.parseInt(owner.cy+sin(radians(tempA+owner.angle))*nullRange), 50, owner.playerColor, 10, owner.angle+tempA, PApplet.parseInt(projectileDamage-inAccurateAngle*2)));

        owner.pushForce(-12, owner.angle);
        shakeTimer+=15; 
        inAccurateAngle=startAccuracy;
        enableCooldown();
      }
    }
  }

  public void reset() {
    super.reset();
    inAccurateAngle=startAccuracy;
    active=false;
    regen=true;
    deChannel();
    deActivate();
  }
}

class Battery extends Ability {//---------------------------------------------------    Battery   ---------------------------------
  int  maxInterval=5, damage=7, count=0, maxCount=6;
  float  accuracy=10, interval, MODIFIED_ANGLE_FACTOR=0.02f;

  Battery() {
    super();
    name=getClassName(this);
    activeCost=24;
    regenRate=0.11f;
  } 

  public @Override
    void action() {
    //projectiles.add(charge.get(count));
    float inAccuracy;
    inAccuracy =random(-accuracy, accuracy);
    switch(count) {
    case 0:
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      projectiles.add(new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*20, sin(radians(owner.angle+inAccuracy))*20, damage));        
      break;
    case 1:
      projectiles.add(new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*25, sin(radians(owner.angle+inAccuracy))*25, damage));        
      break;
    case 2:
      projectiles.add(new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*30, sin(radians(owner.angle+inAccuracy))*30, damage));        
      break;     
    case 3:
      projectiles.add(new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*35, sin(radians(owner.angle+inAccuracy))*35, damage));        
      break;
    case 4:
      projectiles.add(new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*40, sin(radians(owner.angle+inAccuracy))*40, damage));        
      break;
    case 5:
      projectiles.add(new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*45, sin(radians(owner.angle+inAccuracy))*45, damage));        
      break;
    default:
      for (int i=0; i<4; i++) {
        inAccuracy =random(-accuracy*2, accuracy*2);
        projectiles.add(new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*40, sin(radians(owner.angle+inAccuracy))*40, damage));
      }
      projectiles.add( new  Blast(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 5, 150, owner.playerColor, 75, owner.angle, damage));

      projectiles.add( new RevolverBullet(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*50), 60, 25, owner.playerColor, 1000, owner.angle, damage));

      owner.pushForce(10, owner.angle+180);
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 0, 0, 100, 50, color(255, 0, 255)));
      owner.angle+=random(-90, 90);
    }
    particles.add(new ShockWave(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*85), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*85), 5, 22+3*count, 20, WHITE));
    owner.pushForce(3, owner.angle+180);
  }

  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      // action();
    }
  }

  public @Override
    void passive() {
    if (active) {
      if (interval>maxInterval) { // interval
        if (count<=maxCount) {
          // projectiles.add(charge.get(count));
          action();
          count++;
          interval=0; //reset
        } else {
          deActivate();
          count=0;
        }
      }
      interval+=1*timeBend;
    }
  }
}
class AssaultBattery extends Ability {//---------------------------------------------------    Battery   ---------------------------------
  int  maxInterval=6, damage=25, count=0, maxCount=14, flip=1;
  float  inAccuarcy=90, accuracy=inAccuarcy, interval, MODIFIED_ANGLE_FACTOR=0.001f, MODIFIED_MAX_ACCEL=0.05f; 

  AssaultBattery() {
    super();
    name=getClassName(this);
    activeCost=45;
    regenRate=0.19f;
  } 

  public @Override
    void action() {
    strokeWeight(1400);
    stroke(owner.playerColor);
    if (flip==1) {
      arc(owner.cx, owner.cy, 1500, 1500, radians(owner.angle-accuracy*.6f), radians(owner.angle));
    } else {
      arc(owner.cx, owner.cy, 1500, 1500, radians(owner.angle), radians(owner.angle+accuracy*.6f));
    }
    strokeWeight(1);
    flip*=-1;
    //projectiles.add(charge.get(count));
    //float inAccuracy;
    //inAccuracy =random(-accuracy, accuracy);
    owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
    owner.MAX_ACCEL= MODIFIED_MAX_ACCEL;

    if (accuracy>0) {
      owner.angle+= flip*accuracy;
      accuracy*=0.82f;
      accuracy--;
    }

    projectiles.add( new SniperBullet(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*85), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*85), 50, owner.playerColor, 10, owner.angle, PApplet.parseInt(damage)));
    owner.pushForce(-.5f, owner.angle);

    if (count>=maxCount) {
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      owner.MAX_ACCEL= owner.DEFAULT_MAX_ACCEL;
      accuracy=inAccuarcy;
      regen=true;
    }
    particles.add(new ShockWave(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*85), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*85), 5, 10+5*count, 20, WHITE));
    owner.pushForce(-2, owner.angle);
  }

  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {

      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=false;
      owner.angle+= flip*accuracy*.75f;
      activate();
      // action();
    }
    if ((!reverse || owner.reverseImmunity)&& energy<20 && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {
      projectiles.add( new SniperBullet(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*85), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*85), 70, owner.playerColor, 20, owner.angle, PApplet.parseInt(damage*1.5f)));
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      // owner.angle+= flip*accuracy*.75;
      // activate();
      // action();
    }
  }

  public @Override
    void passive() {
    if (active) {
      if (interval>maxInterval) { // interval
        if (count<=maxCount) {
          // projectiles.add(charge.get(count));
          action();
          count++;
          interval=0; //reset
        } else {
          deActivate();
          count=0;
        }
      }
      interval+=1*timeBend;
    }
  }
  public @Override

    void reset() {
    super.reset();
    active=false;
    energy=120;
    regen=true;
    count=0;
    interval=0;
    accuracy=inAccuarcy;
    owner.MAX_ACCEL= owner.DEFAULT_MAX_ACCEL;
    owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
  }
}

class SemiAuto extends Battery {//---------------------------------------------------    Battery   ---------------------------------
  int swayRate=2;

  SemiAuto() {
    super();
    name=getClassName(this);
    maxInterval=4; 
    damage=10;  
    maxCount=3;
    MODIFIED_ANGLE_FACTOR=0.02f;
    activeCost=10;
    regenRate=0.15f;
  } 

  public @Override
    void action() {
    //projectiles.add(charge.get(count));
    float inAccuracy;
    inAccuracy =random(-accuracy, accuracy);
    switch(count) {
    case 0:
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      projectiles.add(new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*75, sin(radians(owner.angle+inAccuracy))*75, damage));        
      particles.add(new ShockWave(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*105), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*105), 5, 22, 20, WHITE));
      accuracy+=swayRate;
      break;
    case 1:
      projectiles.add(new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*70, sin(radians(owner.angle+inAccuracy))*70, damage));        
      particles.add(new ShockWave(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*105), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*105), 5, 22, 20, WHITE));
      accuracy+=swayRate;
      break;
    case 2:
      projectiles.add(new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*65, sin(radians(owner.angle+inAccuracy))*65, damage));        
      particles.add(new ShockWave(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*105), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*105), 5, 22, 20, WHITE));
      accuracy+=swayRate;
      break;     
    default:
      accuracy+=swayRate;
      if (accuracy>75)accuracy=75;
      owner.pushForce(-8, owner.angle);
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      owner.angle+=random(-accuracy, accuracy);
      owner.keyAngle= owner.angle;
    }
    owner.pushForce(-4, owner.angle);
    owner.pushForce(3, owner.keyAngle);
  }

  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      // action();
    }
  }

  public @Override
    void passive() {

    if (active) {
      if (interval>maxInterval) { // interval
        if (count<=maxCount) {
          // projectiles.add(charge.get(count));
          action();
          count++;
          interval=0; //reset
        } else {
          deActivate();
          count=0;
        }
      }
      interval+=1*timeBend;
    } else     if (accuracy>0)accuracy--;
  }

  public void reset() {
    super.reset();
    active=false;
  }
}

class MissleLauncher extends Ability {//---------------------------------------------------    MissleLauncher   ---------------------------------
  int interval, maxInterval=6, damage=17, offset=50, accuracy=10, count=0, maxCount=6, shootSpeed=34, duration=4000;
  float  MODIFIED_ANGLE_FACTOR=0.02f;

  MissleLauncher() {
    super();
    cooldownTimer=2200;
    name=getClassName(this);
    activeCost=35;
    regenRate=0.12f;
  } 

  public @Override
    void action() {

    switch(count) {
    case 0:
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      projectiles.add( new Missle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle+90))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle+90))*50), 30, owner.playerColor, duration, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, false));
      particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle+90))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle+90))*50), 0, 0, 50, 50, WHITE));

      break;
    case 1:
      projectiles.add( new Missle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle-90))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle-90))*50), 30, owner.playerColor, duration, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, false));
      particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle-90))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle-90))*50), 0, 0, 50, 50, WHITE));
      break;
    case 2:
      projectiles.add( new Missle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle+95))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle+95))*50), 30, owner.playerColor, duration, owner.angle+10, cos(radians(owner.angle+10))*shootSpeed, sin(radians(owner.angle+10))*shootSpeed, damage, false));
      particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle+90))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle+90))*50), 0, 0, 50, 50, WHITE));

      break;     
    case 3:
      projectiles.add( new Missle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle-95))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle-95))*50), 30, owner.playerColor, duration, owner.angle-10, cos(radians(owner.angle-10))*shootSpeed, sin(radians(owner.angle-10))*shootSpeed, damage, false));
      particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle-90))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle-90))*50), 0, 0, 50, 50, WHITE));

      break;
    case 4:
      projectiles.add( new Missle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle+100))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle+100))*50), 30, owner.playerColor, duration, owner.angle+20, cos(radians(owner.angle+20))*shootSpeed, sin(radians(owner.angle+20))*shootSpeed, damage, false));
      particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle-90))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle-90))*50), 0, 0, 50, 50, WHITE));

      break;
    case 5:
      projectiles.add( new Missle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle-100))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle-100))*50), 30, owner.playerColor, duration, owner.angle-20, cos(radians(owner.angle-20))*shootSpeed, sin(radians(owner.angle-20))*shootSpeed, damage, false));
      particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle-90))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle-90))*50), 0, 0, 50, 50, WHITE));
      owner.pushForce(5, owner.angle+180);
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      enableCooldown();
      break;
    default:
      particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 0, 0, 100, 50, color(255, 0, 255)));
    }
    owner.halt();
    owner.pushForce(6, owner.angle+180);
  }

  public @Override
    void press() {

    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && cooldown<stampTime && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();

      // action();
    }
  }

  public @Override
    void passive() {
    pushMatrix();
    translate(owner.cx, owner.cy);
    noStroke();
    fill(owner.playerColor);
    rotate(radians(owner.angle));
    rectMode(CENTER);
    rect(-20, owner.radius, 50, 75);
    rect(-20, -owner.radius, 50, 75);
    rectMode(CORNER);
    popMatrix();

    if (active) {
      if (interval>maxInterval) { // interval
        if (count<maxCount) {
          // projectiles.add(charge.get(count));
          action();
          count++;
          interval=0; //reset
        } else {
          deActivate();
          count=0;
        }
      }
      interval++;
    }
  }

  public @Override
    void  reset() {
    super.reset();
    active=false;
    regen=true;
    count=0;
    owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class AutoGun extends Ability {//---------------------------------------------------    AutoGun   ---------------------------------

  float  MODIFIED_MAX_ACCEL=0.09f, count;
  int damage=5, alternate ;
  ArrayList<Player> targets= new ArrayList<Player>() ;
  int amountOfTargets;
  AutoGun() {
    super();
    name=getClassName(this);
    activeCost=12;
    channelCost=0.1f;
    regenRate=0.18f;
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity) &&(!freeze || owner.freezeImmunity)&& energy>(0+activeCost) && !active && !channeling && !owner.dead) {
      activate();
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=false;
    }
  }
  public @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead &&(!freeze || owner.freezeImmunity)) {
      channel();
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      if (!active || energy<0 ) {
        release();
      }
      if (count>12) {
        count=0;
        int amountP=0;
        for (Player p : players) {
          if (!p.dead && owner !=p && owner.ally!=p.ally) {

            if (amountP==alternate) {
              calcAngle(p);
              projectiles.add( new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*60), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*60), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*60, sin(radians(owner.angle))*60, damage));
              particles.add(new ShockWave(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*85), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*85), 5, 22, 20, WHITE));
            }
            amountP++;
          }
        }
        amountOfTargets=amountP+1;
        alternate++;
        alternate=alternate%amountOfTargets;

        //particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 5, 22, 20, WHITE));
      }
      count+=3*timeBend;
    }
  }
  public @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        action();
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
      }
    }
  }
  public void calcAngle(Player target) {
    owner.angle = degrees(atan2((target.cy-owner.cy), (target.cx-owner.cx)));
    owner.keyAngle =owner.angle;
    strokeWeight(1);
    stroke(255);
    line(target.cx, target.cy, owner.cx, owner.cy);
    targetVarning( target);
  }
  public void targetVarning(Player target) {
    float tcx=target.cx, tcy=target.cy;
    stroke(owner.playerColor);
    strokeWeight(4);

    noFill();
    ellipse(tcx, tcy, target.w*2, target.w*2);
    line(tcx, tcy, tcx-150, tcy);
    line(tcx, tcy, tcx+150, tcy);
    line(tcx, tcy, tcx, tcy-150);
    line(tcx, tcy, tcx, tcy+150);
  }
  public @Override
    void  reset() {
    super.reset();
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class SeekGun extends Ability {//---------------------------------------------------    SeekGun   ---------------------------------

  float  MODIFIED_MAX_ACCEL=0.08f, MODIFIED_ANGLE_FACTOR=0.05f, count;
  int damage=28, range=1000, minRange=400, maxSpanAngle=80;
  float spanAngle=2, minAngle=1;
  ArrayList<Player> targets= new ArrayList<Player>() ;
  // int amountOfTargets;
  SeekGun() {
    super();
    name=getClassName(this);
    activeCost=40;
    channelCost=0.05f;
    regenRate=0.4f;
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity) &&(!freeze || owner.freezeImmunity)&& energy>(0+activeCost) && !active && !channeling && !owner.dead) {
      activate();
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      regen=false;
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
    }
  }
  public @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead &&(!freeze || owner.freezeImmunity)) {
      channel();
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      if (!active || energy<0 ) {
        release();
      }

      for (Player p : players) {
        if (debug) {
          fill(p.playerColor);
          text(PApplet.parseInt(calcAngleBetween(p, owner)), p.cx+200, p.cy+200);
        }
        if (!p.dead && p.ally!=owner.ally && dist(owner.cx, owner.cy, p.cx, p.cy)<range+p.radius && dist(owner.cx, owner.cy, p.cx, p.cy)>minRange-p.radius
          && calcAngleBetween(p, owner)<= (owner.angle+spanAngle*.5f+360)%360 &&calcAngleBetween(p, owner)>= (owner.angle-spanAngle*.5f+360)%360  ) {
          if (!targets.contains(p)) {
            targets.add(p);

            particles.add(new ShockWave(PApplet.parseInt(p.cx), PApplet.parseInt(p.cy), 140, 22, 300, WHITE));
          }
        }
      }
      if (maxSpanAngle>spanAngle)spanAngle*=1.1f;

      if (debug) {
        //  fill(owner.playerColor);
        //text(int(calcAngleBetween(p, owner)), owner.cx+ cos(radians(owner.angle))*400, owner.cy+sin(radians(owner.angle))*400);

        fill(BLACK);

        text(PApplet.parseInt((owner.angle+360)%360), owner.cx+ cos(radians(owner.angle))*300, owner.cy+sin(radians(owner.angle))*300);
        text(PApplet.parseInt((owner.angle+spanAngle*.5f+360)%360), owner.cx+ cos(radians(owner.angle+spanAngle*.5f))*300, owner.cy+ sin(radians(owner.angle+spanAngle*.5f))*300);
        text(PApplet.parseInt((owner.angle-spanAngle*.5f+360)%360), owner.cx+cos(radians(owner.angle-spanAngle*.5f))*300, owner.cy+sin(radians(owner.angle-spanAngle*.5f))*300);
      }
      noFill();
      strokeWeight(range-minRange);
      stroke(owner.playerColor, 50);
      arc(owner.cx, owner.cy, range+minRange, range+minRange, radians(owner.angle-spanAngle*.5f), radians(owner.angle+spanAngle*.5f));
      strokeWeight(1);
      ellipse(owner.cx, owner.cy, range*2, range*2);
      ellipse(owner.cx, owner.cy, minRange*2, minRange*2);

      //particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 5, 22, 20, WHITE));
    }
  }
  public @Override
    void passive() {
    //if (owner.angle<0){owner.angle+=360;owner.keyAngle+=360;}
    for (Player t : targets) {
      if (debug) {
        fill(owner.playerColor);
        text(calcAngleBetween(t, owner), t.cx+200, t.cy+200);
      }
      targetVarning(t);
    }
  }
  public @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
        particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 150, 62, 400, WHITE));

        for (Player t : targets) {
          float tempAngle=calcAngleBetween(t, owner);
          HomingMissile p=new HomingMissile(owner, PApplet.parseInt( owner.cx+cos(radians(tempAngle))*50), PApplet.parseInt(owner.cy+sin(radians(tempAngle))*50), 60+30*targets.size(), owner.playerColor, 1400, owner.angle, cos(radians(owner.angle))*30, sin(radians(owner.angle))*30, damage+15*targets.size());
          p.angle=tempAngle;
          p.locking();  
          p.ReactionTime=5*targets.size();
          projectiles.add(p);
        }
        owner.stop();
        targets.clear();
        spanAngle=minAngle;
        regen=true;
        action();
        deChannel();
        deActivate();
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      }
    }
  }
  public float  calcAngleBetween(Player target, Player from) {
    return (degrees(atan2((target.cy-from.cy), (target.cx-from.cx)))+360)%360;
  }
  public void targetVarning(Player target) {
    float tcx=target.cx, tcy=target.cy;
    stroke(owner.playerColor);
    strokeWeight(4);

    noFill();
    ellipse(tcx, tcy, target.w*2, target.w*2);
    line(tcx, tcy, tcx-150, tcy);
    line(tcx, tcy, tcx+150, tcy);
    line(tcx, tcy, tcx, tcy-150);
    line(tcx, tcy, tcx, tcy+150);
  }
  public @Override
    void  reset() {
    super.reset();
    active=false;
    targets.clear();
    spanAngle=minAngle;
    deChannel();
    release();
    regen=true;
    action();
    owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}



class ThrowBoomerang extends Ability {//---------------------------------------------------    Boomerang   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=64;
  float forceAmount=0, MODIFIED_MAX_ACCEL=0.04f;
  float ChargeRate=1, restForce, recoveryEnergy;
  int damage=2, projectileSize=60;
  PShape boomerang;
  ThrowBoomerang() {
    super();
    name=getClassName(this);
    activeCost=15;
    channelCost=0.1f;
    recoveryEnergy=activeCost*0.9f;
  } 
  public @Override
    void action() {
    projectiles.add( new Boomerang(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), projectileSize, owner.playerColor, PApplet.parseInt(300*forceAmount)+100, owner.angle, owner.vx+cos(radians(owner.angle))*(forceAmount+4), owner.vy+sin(radians(owner.angle))*(forceAmount+4), damage, recoveryEnergy, PApplet.parseInt(forceAmount*0.5f+13)));
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity) && energy>(0+activeCost) && !active && !channeling && !owner.dead) {
      activate();
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=false;
    }
  }
  public @Override
    void hold() {

    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead) {
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      if (MAX_FORCE>forceAmount) { 
        channel();
        if (!active || energy<0 ) {
          release();
        }
        restForce = MAX_FORCE-forceAmount;
        forceAmount+=ChargeRate*timeBend; 
        particles.add(new Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), random(-restForce*0.5f, restForce*0.5f), random(-restForce*0.5f, restForce*0.5f), PApplet.parseInt(random(30)+10), 300, owner.playerColor));
        particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), PApplet.parseInt(forceAmount*.33f), 16, PApplet.parseInt(forceAmount*.33f), owner.playerColor));
      } else {
        //  particles.add(new ShockWave(int(owner.cx), int(owner.cy), int(forceAmount), 50, color(255, 0, 255)));
        particles.add( new  Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 0, 0, PApplet.parseInt(MAX_FORCE*2), 50, color(255, 0, 255)));
      }
    }
  }
  public @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        action();
        owner.pushForce(-forceAmount*0.5f, owner.angle);
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        forceAmount=0;
      }
    }
  }
  public void passive() {
    // rect(owner.x,owner.y,50,50);
    if (active) {
      pushMatrix();
      translate(owner.cx-cos(radians(owner.angle))*forceAmount, owner.cy-sin(radians(owner.angle))*forceAmount);
      rotate(radians(owner.angle)+forceAmount);
      shape(boomerang, boomerang.width*.5f, boomerang.height*.5f, boomerang.width, boomerang.height);
      popMatrix();
    }
  }
  public @Override
    void  reset() {
    super.reset();
    regen=true;
    forceAmount=0;
    deChannel();
    release();
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    setOwner(owner);
  }
  public @Override
    void setOwner(Player owner) {
    super.setOwner( owner);
    boomerang=createShape();
    boomerang.beginShape();
    boomerang.strokeWeight(6);
    boomerang.stroke(owner.playerColor);
    boomerang.noFill();
    boomerang.vertex(PApplet.parseInt (projectileSize*0.6f), PApplet.parseInt (-projectileSize*0.5f) );
    boomerang.vertex(PApplet.parseInt (+projectileSize*1.2f), PApplet.parseInt (0));
    boomerang.vertex(PApplet.parseInt (0), PApplet.parseInt (0));

    boomerang.vertex(PApplet.parseInt (-projectileSize), PApplet.parseInt (0));

    boomerang.vertex(PApplet.parseInt (0), PApplet.parseInt (0));
    boomerang.vertex(PApplet.parseInt (-projectileSize*1.2f), PApplet.parseInt (0));
    boomerang.vertex(PApplet.parseInt (-projectileSize*0.6f), PApplet.parseInt (+projectileSize*0.5f) );




    /*
    boomerang.vertex(int(cos(radians(owner.angle))*projectileSize), int( +sin(radians(owner.angle))*projectileSize));
     boomerang.vertex(int(-cos(radians(owner.angle))*projectileSize), int(-sin(radians(owner.angle))*projectileSize));
     boomerang.vertex(int(cos(radians(owner.angle+45))*projectileSize*0.6), int( +sin(radians(owner.angle+45))*projectileSize*0.6));
     boomerang.vertex(int( -cos(radians(owner.angle+45))*projectileSize*0.6), int(-sin(radians(owner.angle+45))*projectileSize*0.6));
     boomerang.vertex(int(cos(radians(owner.angle))*projectileSize), int(+sin(radians(owner.angle))*projectileSize));
     boomerang.vertex(int(cos(radians(owner.angle+45))*projectileSize*0.6), int(+sin(radians(owner.angle+45))*projectileSize*0.6));
     boomerang.vertex(int(-cos(radians(owner.angle))*projectileSize), int( -sin(radians(owner.angle))*projectileSize));
     boomerang.vertex( int(-cos(radians(owner.angle+45))*projectileSize*0.6), int(-sin(radians(owner.angle+45))*projectileSize*0.6));
     
     boomerang.vertex(int(owner.x+cos(radians(owner.angle))*projectileSize), int( owner.y+sin(radians(owner.angle))*projectileSize));
     boomerang.vertex(int(owner.x-cos(radians(owner.angle))*projectileSize), int( owner.y-sin(radians(owner.angle))*projectileSize));
     boomerang.vertex(int(owner.x+cos(radians(owner.angle+45))*projectileSize*0.6), int( owner.y+sin(radians(owner.angle+45))*projectileSize*0.6));
     boomerang.vertex(int( owner.x-cos(radians(owner.angle+45))*projectileSize*0.6), int(owner.y-sin(radians(owner.angle+45))*projectileSize*0.6));
     boomerang.vertex(int(owner.x+cos(radians(owner.angle))*projectileSize), int( owner.y+sin(radians(owner.angle))*projectileSize));
     boomerang.vertex(int(owner.x+cos(radians(owner.angle+45))*projectileSize*0.6), int(owner.y+sin(radians(owner.angle+45))*projectileSize*0.6));
     boomerang.vertex(int(owner.x-cos(radians(owner.angle))*projectileSize), int( owner.y-sin(radians(owner.angle))*projectileSize));
     boomerang.vertex( int(owner.x-cos(radians(owner.angle+45))*projectileSize*0.6), int(owner.y-sin(radians(owner.angle+45))*projectileSize*0.6));*/
    //  line(int(owner.x+cos(radians(owner.angle))*projectileSize), int( owner.y+sin(radians(owner.angle))*projectileSize), int(owner.x-cos(radians(owner.angle))*projectileSize), int( owner.y-sin(radians(owner.angle))*projectileSize));
    //  line(int(owner.x+cos(radians(owner.angle+45))*projectileSize*0.6), int( owner.y+sin(radians(owner.angle+45))*projectileSize*0.6), int( owner.x-cos(radians(owner.angle+45))*projectileSize*0.6), int(owner.y-sin(radians(owner.angle+45))*projectileSize*0.6));
    //line(int(owner.x+cos(radians(owner.angle))*projectileSize), int( owner.y+sin(radians(owner.angle))*projectileSize), int(owner.x+cos(radians(owner.angle+45))*projectileSize*0.6), int(owner.y+sin(radians(owner.angle+45))*projectileSize*0.6));
    //line(int(owner.x-cos(radians(owner.angle))*projectileSize), int( owner.y-sin(radians(owner.angle))*projectileSize), int(owner.x-cos(radians(owner.angle+45))*projectileSize*0.6), int(owner.y-sin(radians(owner.angle+45))*projectileSize*0.6));
    boomerang.endShape(CLOSE);
  }
}

class PhotonicWall extends Ability {//---------------------------------------------------    PhotonicWall   ---------------------------------
  int damage=30, customAngle, initialSpeed=5;
  ArrayList<HomingMissile> lockProjectiles= new ArrayList<HomingMissile>();
  float MODIFIED_ANGLE_FACTOR=0.018f;
  float MODIFIED_MAX_ACCEL=0.04f; 
  PhotonicWall() {
    super();
    name=getClassName(this);
    activeCost=8;
    energy=40;
  } 
  public @Override
    void action() {
    // for (int i=0; i<2; i++) {
    particles.add(new Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle-90))*50), PApplet.parseInt(owner.cy+cos(radians(owner.angle-90))*50), random(10)-5+cos(radians(owner.angle-90))*10, random(10)-5+sin(radians(owner.angle-90))*10, PApplet.parseInt(random(20)+5), 800, 255));
    particles.add(new Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle+90))*50), PApplet.parseInt(owner.cy+cos(radians(owner.angle+90))*50), random(10)-5+cos(radians(owner.angle+90))*10, random(10)-5+sin(radians(owner.angle+90))*10, PApplet.parseInt(random(20)+5), 800, 255));
    // }   

    lockProjectiles.add(new HomingMissile(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle+100))*150), PApplet.parseInt(owner.cy+sin(radians(owner.angle+100))*150), 60, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
    lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
    lockProjectiles.get(lockProjectiles.size()-1).locking();
    projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
    lockProjectiles.add(new HomingMissile(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle+90))*120), PApplet.parseInt(owner.cy+sin(radians(owner.angle+90))*120), 70, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
    lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
    lockProjectiles.get(lockProjectiles.size()-1).locking();
    lockProjectiles.get(lockProjectiles.size()-1).ReactionTime=45;
    projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
    lockProjectiles.add(new HomingMissile(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle-90))*120), PApplet.parseInt(owner.cy+sin(radians(owner.angle-90))*120), 70, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
    lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
    lockProjectiles.get(lockProjectiles.size()-1).locking();
    lockProjectiles.get(lockProjectiles.size()-1).ReactionTime=45;
    projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
    lockProjectiles.add(new HomingMissile(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle-100))*150), PApplet.parseInt(owner.cy+sin(radians(owner.angle-100))*150), 60, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
    lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
    lockProjectiles.get(lockProjectiles.size()-1).locking();
    projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
    owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
    owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
    owner.pushForce(-7, owner.angle);
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
  public @Override
    void passive() {
    owner.MAX_ACCEL+= (owner.DEFAULT_MAX_ACCEL-owner.MAX_ACCEL)*.018f;
    owner.ANGLE_FACTOR+= (owner.DEFAULT_ANGLE_FACTOR-owner.MAX_ACCEL)*.018f;
  }
  public @Override
    void reset() {
    super.reset();
    owner.MAX_ACCEL= owner.DEFAULT_MAX_ACCEL;
    owner.ANGLE_FACTOR= owner.DEFAULT_ANGLE_FACTOR;
  }
}
class PhotonicPursuit extends Ability {//---------------------------------------------------    PhotonicPursuit   ---------------------------------
  int damage=32, customAngle, initialSpeed=6, r;
  final int shellRadius =125;
  PhotonicPursuit() {
    super();
    name=getClassName(this);
    activeCost=15;
    energy=50;
    r=200;
  } 
  public @Override
    void action() {

    if (energy>=maxEnergy-15) {

      for (Player p : players) {
        if (!p.dead) {
          customAngle=-90;

          HomingMissile h= new HomingMissile(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage);
          h.target=p;
          projectiles.add(h);
          customAngle=90;

          h= new HomingMissile(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage);
          h.target=p;
          projectiles.add(h);
          customAngle=0;
        }
      }
    }

    customAngle=-90;
    projectiles.add( new HomingMissile(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));

    customAngle=90;
    projectiles.add( new HomingMissile(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
      r+=50;
    }
  }
  public void passive() {
    if (r>shellRadius)r*=0.95f;
    stroke(owner.playerColor);
    strokeWeight(15);
    noFill();
    arc(owner.cx, owner.cy, r, r, radians(owner.angle+45), radians(owner.angle+45+90));
    arc(owner.cx, owner.cy, r, r, radians(owner.angle+225), radians(owner.angle+225+90));
  }
}

class DeployThunder extends TimeBomb {//---------------------------------------------------    DeployThunder   ---------------------------------

  float MODIFIED_MAX_ACCEL=0.01f, duration=300; 
  long startTime;
  DeployThunder() {
    super();
    damage=120;
    shootSpeed=0;
    regenRate=0.45f;
    name=getClassName(this);
    activeCost=40;
  } 
  public @Override
    void action() {
    particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 10, 16, 1000, owner.playerColor));

    //    particles.add( new Shock(1000, int( owner.cx), int(owner.cy), owner.vx, owner.vy, 2, owner.angle, owner.playerColor)) ;
    // particles.add( new Shock(1000, int( owner.cx), int(owner.cy), owner.vx, owner.vy, 3, owner.angle, owner.playerColor)) ;
    // particles.add( new Shock(1000, int( owner.cx), int(owner.cy), owner.vx, owner.vy, 1, owner.angle, owner.playerColor)) ;

    startTime=stampTime;
    owner.MAX_ACCEL=owner.MAX_ACCEL*3;
    for (int i=0; i<7; i++) {
      particles.add(new Spark(700, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), random(-15, 15), random(-15, 15), 2, random(360), owner.playerColor));
    }

    if (energy>=maxEnergy-activeCost) {   
      particles.add( new Text("!", PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 0, 0, 180, 0, 4000, BLACK, 1));
      particles.add( new Text("!", PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 0, 0, 240, 0, 4000, owner.playerColor, 0));
      projectiles.add( new Thunder(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 500, owner.playerColor, 4000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, PApplet.parseInt(damage*1.3f), 6, true));
    } else {
      particles.add( new Text("!", PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 0, 0, 140, 0, 2000, BLACK, 1));
      particles.add( new Text("!", PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 0, 0, 180, 0, 2000, owner.playerColor, 0));
      projectiles.add( new Thunder(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 400, owner.playerColor, 2000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, 5, true));
    }
  }

  public void  passive() {
    //owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.6;
    if (stampTime>=duration+startTime) {
      owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    }
  }
  public @Override
    void  reset() {
    super.reset();
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class DeployShield extends Ability {//---------------------------------------------------    DeployShield   ---------------------------------
  int damage=12, shell=80, pHealth;

  DeployShield() {
    super();
    name=getClassName(this);
    activeCost=35;
    cooldownTimer=2750;
  } 
  public @Override
    void action() {
    if (owner.health>=owner.maxHealth*.5f) {
      /*for (int i=200; i<900; i+=75) {
       projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle))*i), int(owner.cy+sin(radians(owner.angle))*i), owner.playerColor, 10000, owner.angle, damage ));
       }*/
      particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 300, 16, 90, WHITE));

      for (int i=0; i<360; i+=30) {
        projectiles.add( new Shield( owner, PApplet.parseInt( owner.cx+cos(radians(i))*195), PApplet.parseInt(owner.cy+sin(radians(i))*195), owner.playerColor, 2200, i+90, damage ));
      }
    } else {
      // particles.add(new Particle(int(owner.cx), int(owner.cy), 0, 0, 120, 500, WHITE));
      particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 100, 16, 80, owner.playerColor));
      particles.add(new LineWave(PApplet.parseInt( owner.cx+cos(radians(owner.angle))*200), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*200), 10, 200, WHITE, owner.angle+90));

      projectiles.add( new Shield( owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle-25))*220), PApplet.parseInt(owner.cy+sin(radians(owner.angle-25))*220), owner.playerColor, 11000, owner.angle+90, damage ));
      projectiles.add( new Shield( owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*200), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*200), owner.playerColor, 11100, owner.angle+90, damage ));
      projectiles.add( new Shield( owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle+25))*220), PApplet.parseInt(owner.cy+sin(radians(owner.angle+25))*220), owner.playerColor, 11000, owner.angle+90, damage ));
    }
    owner.stop();
  }
  public @Override
    void press() {
    if (cooldown<stampTime &&(!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      enableCooldown();
      deActivate();
    }
  }

  public @Override
    void passive() {

    if (owner.health>=owner.maxHealth*.5f) {
      cooldownTimer=2850;
      activeCost=35;
      owner.armor=1;
      stroke(owner.playerColor);
      strokeWeight(5);
      fill(255, owner.health-owner.maxHealth*.5f);
      quad(owner.cx+shell, owner.cy, owner.cx, owner.cy+shell, owner.cx-shell, owner.cy, owner.cx, owner.cy-shell);
    } else {
      if (pHealth>=owner.maxHealth*.5f) {
        cooldownTimer=1000;
        activeCost=20;
        owner.armor=0;
        shatter();
      }
    }
    pHealth=owner.health;
  }

  public void shatter() {
    owner.halt();
    for (int i=0; i<24; i++) {
      projectiles.add( new IceDagger(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 25, owner.playerColor, 500, i*36, cos(radians(i*36))*50, sin(radians(i*36))*50, damage));
    }
    projectiles.add( new Bomb(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 220, owner.playerColor, 1, owner.angle, owner.vx, owner.vy, damage, false));

    shakeTimer+=10;
    particles.add(new Flash(200, 10, WHITE));   // flash
  }
  public void reset() {
    super.reset();
    owner.armor=0;
  }
}

class DeployElectron extends Ability {//---------------------------------------------------    DeployElectron   ---------------------------------
  int damage=32;

  ArrayList<Electron> stored =new ArrayList<Electron> ();
  DeployElectron() {
    super();
    name=getClassName(this);
    activeCost=12;
  } 
  public @Override
    void action() {
    if (energy>=maxEnergy-activeCost) {
      stored.add( new Electron( owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 10000, owner.angle, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
      stored.add( new Electron( owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 10000, owner.angle+120, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
      stored.add( new Electron( owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 10000, owner.angle+240, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
    } else {
      stored.add( new Electron( owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 10000, owner.angle, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
      stored.add( new Electron( owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 10000, owner.angle+180, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
    }
  }
  public @Override
    void press() {
    for (Electron e : stored) {
      if (e.distance>=e.maxDistance)e.derail();
    }
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
  public @Override
    void passive() {
    strokeWeight(1);
    stroke(owner.playerColor);
    noFill();
    for (float i =0; i<=PI*2; i+=PI/6) {
      arc(PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 400, 400, i, i+PI*.03f);
    }
  }
  public @Override
    void reset() {
    super.reset();
    for (Electron p : stored) {
      //p.death();
      p.dead=true;
      p.deathTime=stampTime;
    }
    stored.clear();
    energy=85;
  }
}

class Gravity extends Ability {//---------------------------------------------------    Gravity   ---------------------------------
  int damage=1;
  float r;
  ArrayList<Graviton> gravitonList= new ArrayList<Graviton>();
  Gravity() {
    super();
    name=getClassName(this);
    activeCost=25;
    regenRate=.15f;
    cooldownTimer=1000;
  } 
  public @Override
    void action() {
    Graviton g;
    if (energy>=maxEnergy-activeCost) {
      g= new  Graviton(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 400, owner.playerColor, 12000, owner.angle, 0, 0, damage*3, 4);
    } else if (energy>=maxEnergy*.5f) {
      g= new  Graviton(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 300, owner.playerColor, 10000, owner.angle, 0, 0, damage*2, 3);
    } else {
      g= new  Graviton(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 250, owner.playerColor, 8000, owner.angle, 0, 0, damage, 2);
    }
    gravitonList.add(g);
    projectiles.add(g);
  }

  public @Override
    void press() {
    if (cooldown<stampTime && (!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      enableCooldown();
      deActivate();
    }
  }
  public @Override
    void reset() {
    super.reset();
    owner.armor=0;
    for (Graviton g : gravitonList) {
      g.deathTime=stampTime;
      g.dead=true;
    }
    gravitonList.clear();
  }
  public void passive() {
    float c =((cooldown>stampTime)?PApplet.parseInt(cooldownTimer-(cooldown-stampTime)):cooldownTimer)*0.15f;
    r+=(abs(owner.vx)+abs(owner.vy))+2;
    //stroke(owner.playerColor);
    strokeWeight(2);
    stroke(255);
    noFill();
    bezier(PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), PApplet.parseInt(owner.cx)+cos(radians(r+50+180))*100, PApplet.parseInt(owner.cy)+sin(radians(r+50+180))*100, PApplet.parseInt(owner.cx)+cos(radians(r+180))*c, PApplet.parseInt(owner.cy)+sin(radians(r+180))*c);

    bezier(PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), PApplet.parseInt(owner.cx)+cos(radians(r+50))*100, PApplet.parseInt(owner.cy)+sin(radians(r+50))*100, PApplet.parseInt(owner.cx)+cos(radians(r))*c, PApplet.parseInt(owner.cy)+sin(radians(r))*c);
  }
}

class Ram extends Ability {//---------------------------------------------------    Ram   ---------------------------------
  int boostSpeed=32;
  float sustainSpeed=1.5f, damage= .4f, speed;
  Ram() {
    super();
    name=getClassName(this);
    activeCost=10;
    channelCost=0.23f;
    energy=50;
    regenRate=0.3f;
    cooldownTimer=1000;
  } 
  public @Override
    void action() {
    active=true;
    //owner.damage=damage;
    owner.pushForce(boostSpeed*0.5f, owner.keyAngle);
    // particles.add(new ShockWave(int(owner.cx), int(owner.cy), 150, 22, 150, owner.playerColor));
  }
  public void onHit() {
    //active=true;
    //owner.damage=damage;
    if (abs(owner.vx)+abs(owner.vy)> 20 && cooldown<stampTime) {
      enableCooldown();
      owner.pushForce(boostSpeed, owner.keyAngle);
      projectiles.add(new Thunder(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 300, color(owner.playerColor), 0, 0, 0, 0, PApplet.parseInt(damage*10), 0, true) );

      particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 400, 22, 150, owner.playerColor));
    }
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
    }
  }
  public void hold() {
    if (active) {
      channel();
      if (!active || energy<0 ) {
        release();
        deActivate();
        active=false;
      }
      channel();
      owner.pushForce(sustainSpeed, owner.keyAngle);
      particles.add(new Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), random(-speed, speed), random(-speed, speed), PApplet.parseInt(random(20)+10), 150, owner.playerColor));
      particles.add(new RShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 175, 14, 175, owner.playerColor));
    }
  }

  public void passive() {
    speed = PApplet.parseInt(abs(owner.vx)+abs(owner.vy));
    owner.damage=PApplet.parseInt(speed*damage);
    stroke(owner.playerColor);
    strokeWeight(3);
    noFill();
    pushMatrix();
    translate(owner.cx+cos(radians(owner.angle))*50, owner.cy+sin(radians(owner.angle))*50);
    rotate(radians(owner.angle-90));
    triangle(speed*.5f*2, 0, 0, speed*4, -speed*.5f*2, 0);
    popMatrix();
  }

  public void reset() {
    super.reset();
    energy=50;
    owner.damage=1;
  }
  public void release() {
    owner.damage=1;
    deActivate();
  }
}
class DeployTurret extends Ability {//---------------------------------------------------    DeployTurret  ---------------------------------
  int damage=50, range=75, turretLevel=0;
  Turret currentTurret;
  ArrayList<Turret> turretList= new  ArrayList<Turret>();
  DeployTurret() {
    super();
    cooldownTimer=2000;
    name=getClassName(this);
    activeCost=25;
    energy=25;
    regenRate=0.16f;
  } 
  public @Override
    void action() {

    switch(turretLevel) { 
      /*  case 0:
       currentTurret=new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 100, new CloneMultiply());
       break;*/
    case 1:
      currentTurret=new Turret(players.size(), owner, PApplet.parseInt(owner.x+cos(radians(owner.angle))*range), PApplet.parseInt(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 50, new Battery());
      turretList.add(currentTurret);
      players.add(currentTurret);
      break;
    case 2:
      currentTurret=new Turret(players.size(), owner, PApplet.parseInt(owner.x+cos(radians(owner.angle))*range), PApplet.parseInt(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 100, new TimeBomb());
      turretList.add(currentTurret);
      players.add(currentTurret);
      break;
    case 3:
      currentTurret=new Turret(players.size(), owner, PApplet.parseInt(owner.x+cos(radians(owner.angle))*range), PApplet.parseInt(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 200, new Bazooka());
      turretList.add(currentTurret);
      players.add(currentTurret);
      break;
    case 4:
      currentTurret=new Turret(players.size(), owner, PApplet.parseInt(owner.x+cos(radians(owner.angle))*range), PApplet.parseInt(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 400, new Laser());
      turretList.add(currentTurret);
      players.add(currentTurret);
      break;
    }

    activeCost=25;
    turretLevel=0;
  }
  public @Override
    void activate() { 

    super.activate();
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();

      action();
      deActivate();
    }
  }
  public void passive() {
    if (energy<=25) {
      // turretLevel=0;
    } else if (energy<=50) {
      turretLevel=1;
    } else if (energy<=75) {
      turretLevel=2;
    } else if (energy<100) {
      turretLevel=3;
    } else if (energy>=100) {
      turretLevel=4;
    }     
    strokeWeight(10);
    noFill();
    stroke(255);
    //arc(int(owner.cx), int(owner.cy),150,150, 0+turretLevel*PI*2/4, PI*2/4+turretLevel*PI*2/4);
    // arc(int(owner.cx), int(owner.cy),150,150,radians(90),120);

    for (int i = 0; i < turretLevel; i++) {
      arc(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 130, 130, 0+i*PI*0.5f+(PI*0.05f), PI*0.5f+i*PI*0.5f-(PI*0.05f));
    }
    activeCost=energy-1;
  }
  public @Override
    void reset() {
    super.reset();
    players.remove(turretList);
  }
}
class DeployDrone extends Ability {//---------------------------------------------------    DeployDrone  ---------------------------------

  int speed=40;
  Drone currentDrone;
  ArrayList<Drone> droneList= new  ArrayList<Drone>();
  DeployDrone() {
    super();
    cooldownTimer=2000;
    name=getClassName(this);
    activeCost=55;
    energy=25;
    regenRate=0.18f;
  } 
  public @Override
    void action() {

    currentDrone=new Drone(players.size(), owner, PApplet.parseInt(owner.x+cos(radians(owner.angle))*100), PApplet.parseInt(owner.y+sin(radians(owner.angle))*100), PApplet.parseInt(playerSize*0.5f), PApplet.parseInt(playerSize*0.5f), 20, 200, new AutoGun(), new RandomPassive().randomize() );
    currentDrone.vx=cos(radians(owner.angle))*speed;
    currentDrone.vy=sin(radians(owner.angle))*speed;
    currentDrone.stationary=false;
    droneList.add(currentDrone);
    players.add(currentDrone);
  }
  public @Override
    void activate() { 

    super.activate();
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();

      action();
      deActivate();
    }
  }
  public void passive() {
    strokeWeight(10);
    noFill();
    stroke(255);
  }
  public @Override
    void reset() {
    super.reset();
    deChannel();
    release();
    players.remove(droneList);
  }
}
class DeployBodyguard extends DeployDrone {//---------------------------------------------------    DeployDrone  ---------------------------------
  int type;
  DeployBodyguard() {
    super();
    cooldownTimer=2000;
    name=getClassName(this);
    activeCost=80;
    energy=40;
    speed=10;
    regenRate=0.18f;
  } 
  public @Override
    void action() {

    currentDrone=new FollowDrone(players.size(), owner, PApplet.parseInt(owner.x+cos(radians(owner.angle))*100), PApplet.parseInt(owner.y+sin(radians(owner.angle))*100), PApplet.parseInt(playerSize*0.5f), PApplet.parseInt(playerSize*0.5f), 20, 100, type, new Combo(), new RandomPassive().randomize());
    currentDrone.vx=cos(radians(owner.angle))*speed;
    currentDrone.vy=sin(radians(owner.angle))*speed;
    currentDrone.stationary=false;

    droneList.add(currentDrone);
    players.add(currentDrone);
    currentDrone.abilityList.get(0).press();
  }
  public @Override
    void activate() { 

    super.activate();
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
  public void passive() {
    strokeWeight(10);
    noFill();
    stroke(255);
  }
  public @Override
    void reset() {
    super.reset();
    players.remove(droneList);
  }
}

class KineticPulse extends Ability {//---------------------------------------------------    KineticPulse   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=30, ChargeRate=0.4f, MODIFIED_MAX_ACCEL=0.005f, MODIFIED_ANGLE_FACTOR=0.03f;
  final int radius=220;
  float forceAmount=0, restForce;
  int damage=74, distanceX, distanceY;

  KineticPulse() {
    super();
    name=getClassName(this);
    activeCost=22;
    cooldownTimer=1400;
    channelCost=0.01f;
  } 
  public @Override
    void action() {
    particles.add(new Flash(100, 6, WHITE)); 
    shakeTimer+=15;
    for (int i=45; i<360; i+= (360/4)) {
      particles.add( new Shock(170, distanceX, distanceY, 0, 0, 5, i, WHITE)) ;
    }
    particles.add(new ShockWave(distanceX, distanceY, 140, 90, 300, owner.playerColor));

    projectiles.add(new Thunder(owner, distanceX, distanceY, radius, color(owner.playerColor), 700, 0, 0, 0, PApplet.parseInt(damage), 4, true) );
    enableCooldown();
  }
  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity) && energy>(0+activeCost)&& stampTime>cooldown  && !hold && !active && !channeling && !owner.dead) {
      activate();
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=false;
      if (energy>=maxEnergy-activeCost-20) {
        owner.pushForce(-12, owner.angle);
      }
    }
  }
  public @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity)&& stampTime>cooldown&&  active && !owner.dead) {
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR-forceAmount*0.001f;
      if (MAX_FORCE>forceAmount) { 
        channel();
        if (!active || energy<0 ) {
          release();
        }

        restForce = MAX_FORCE-forceAmount;
        forceAmount+=ChargeRate*timeBend; 
        distanceX=PApplet.parseInt(owner.cx+cos(radians(owner.angle))*50*forceAmount);
        distanceY=PApplet.parseInt(owner.cy+sin(radians(owner.angle))*50*forceAmount);

        if (energy>=maxEnergy-activeCost-20 && PApplet.parseInt((forceAmount*2+2)%8)==0) {
          if (forceAmount<5)forceAmount=5;
          projectiles.add(new Thunder(owner, distanceX, distanceY, PApplet.parseInt(radius*.5f), color(owner.playerColor), 900, 0, 0, 0, PApplet.parseInt(damage*.5f), 1, true) );
        }

        crossVarning(distanceX, distanceY );
      } else {
        owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
        owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR-forceAmount*0.001f;
        particles.add( new  Particle(distanceX, distanceY, 0, 0, PApplet.parseInt(MAX_FORCE*1.5f), 30, color(255, 0, 255)));
      }
    }
    if (!active)press(); // cancel
    if (owner.hit)release(); // cancel
  }
  public @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
        //owner.pushForce(-forceAmount, owner.angle);
        regen=true;
        action();
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        forceAmount=0;
      }
    }
  }
  public void reset() {
    super.reset();
    deChannel();
    release();
    forceAmount=0;
  }
  public @Override
    void passive() {
  }
}


class Detonator extends Ability {//---------------------------------------------------    Detonator   ---------------------------------
  int damage=24;
  DetonateBomb bomb;
  boolean detonated;
  Detonator() {
    super();
    name=getClassName(this);
    activeCost=35;
  } 
  public @Override
    void action() {
    bomb = new  DetonateBomb(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 60000, owner.angle, 0, 0, damage, true);
    projectiles.add(bomb);
  }

  public @Override
    void press() {
    if ( bomb!= null && !bomb.dead && bomb.deathTime>stampTime) {
      bomb.deathTime=stampTime;
      owner.pushForce(25, degrees(atan2((owner.cy)-bomb.y, (owner.cx)-bomb.x)));
      //bomb.detonate();
      particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 50, 16, 50, owner.playerColor));
    } else if ((!reverse|| owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)   ) {
      // stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
  public void reset() {
    super.reset();
    projectiles.remove(bomb);
    bomb=null;
  }
}

class TeslaShock extends TimeBomb {//---------------------------------------------------    TimeBomb   ---------------------------------
  int range=500, maxRange=1600, duration=350;
  float MODIFIED_MAX_ACCEL=0.01f; 
  long startTime;
  TeslaShock() {
    super();
    damage=1;
    shootSpeed=0;
    regenRate=0.43f;
    name=getClassName(this);
    activeCost=10;
  } 
  public @Override
    void action() {
    if (maxRange>range)range+=300;
    particles.add(new ShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 10, 16, 1000, owner.playerColor));

    // particles.add( new Shock(1000, int( owner.cx), int(owner.cy), owner.vx, owner.vy, 2, owner.angle, owner.playerColor)) ;
    // particles.add( new Shock(1000, int( owner.cx), int(owner.cy), owner.vx, owner.vy, 3, owner.angle, owner.playerColor)) ;
    // particles.add( new Shock(1000, int( owner.cx), int(owner.cy), owner.vx, owner.vy, 1, owner.angle, owner.playerColor)) ;
    // for (int i=0; i<7; i++) {
    particles.add(new  Tesla( PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 200, 500, owner.playerColor));
    //}

    projectiles.add( new CurrentLine(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), range, owner.playerColor, duration, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage));

    /*  if (energy>=maxEnergy-activeCost) {   
     // particles.add( new Text("!", int( owner.cx), int(owner.cy), 0, 0, 180, 0, 4000, BLACK, 1));
     //   projectiles.add( new Thunder(owner, int( owner.cx), int(owner.cy), 400, owner.playerColor, 2000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, 5));
     }*/
  }

  public void  passive() {
    stroke(owner.playerColor);
    noFill();
    ellipse(owner.cx, owner.cy, range, range);

    //owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.6;
    if (stampTime>=duration+startTime) {
      owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    }
    if (range>owner.w*3)range-=15;
  }
  public @Override
    void  reset() {
    super.reset();
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class RandoGun extends Ability {//---------------------------------------------------    RandoGun   ---------------------------------
  int damage =28, choosenProjectileIndex;
  int shootSpeed=35;
  final String description[]={"dagger", "tesla", "force", "shotgun", "rocket", "Homing missile", "electron", "laser", "bomb", "RC", "Boomerang", "Sniper", "thunder", "cluster", "mine", "missles", "rocket"};
  RandoGun() {
    super();
    name=getClassName(this);
    activeCost=18;
    regenRate=0.21f;
    energy=maxEnergy*0.5f;
  } 
  public @Override
    void action() {

    owner.pushForce(random(-50, 20), owner.angle+random(-90, 90));
    //projectiles.add( allProjectiles[(int)random(allProjectiles.length)]);
    switch(choosenProjectileIndex) {
    case 0:
      projectiles.add( new IceDagger(owner, PApplet.parseInt( owner.cx+cos(radians(owner.keyAngle))*75), PApplet.parseInt(owner.cy+sin(radians(owner.keyAngle))*75), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, PApplet.parseInt(damage*1.2f)));
      break;
    case 1:
      // particles.add(new  Tesla( int(owner.cx), int(owner.cy), 200, 500, owner.playerColor));
      projectiles.add( new CurrentLine(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 400, owner.playerColor, 2000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, PApplet.parseInt(damage*0.15f)));
      owner.pushForce(20, owner.angle);
      break;
    case 2:
      projectiles.add( new forceBall(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, 25, owner.playerColor, 2000, owner.angle, damage));

      break;
    case 3:
      projectiles.add( new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle+10))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle+10))*owner.w), 60, owner.playerColor, 800, owner.angle+10, cos(radians(owner.angle+10))*36, sin(radians(owner.angle+10))*36, PApplet.parseInt(damage*0.8f)));
      projectiles.add( new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle-10))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle-10))*owner.w), 60, owner.playerColor, 800, owner.angle-10, cos(radians(owner.angle-10))*36, sin(radians(owner.angle-10))*36, PApplet.parseInt(damage*0.8f)));
      projectiles.add( new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*36, sin(radians(owner.angle))*36, PApplet.parseInt(damage*0.8f)));

      break;
    case 4:
      // projectiles.add( new  Graviton(owner, int( owner.cx), int(owner.cy), 250, owner.playerColor, 8000, owner.angle, int( owner.vx), int( owner.vy), damage, 2));
      projectiles.add( new SinRocket(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 2500, owner.angle-55, cos(radians(owner.angle+15))*shootSpeed*.01f+owner.vx, sin(radians(owner.angle+15))*shootSpeed*.01f+owner.vy, damage, false));

      break;
    case 5:
      projectiles.add(new HomingMissile(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle-200))*shootSpeed, sin(radians(owner.angle-200))*shootSpeed, damage));
      projectiles.add(new HomingMissile(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle-160))*shootSpeed, sin(radians(owner.angle-160))*shootSpeed, damage));

      break;
    case 6:
      projectiles.add( new Electron( owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 10000, owner.angle, -5, -5, damage ));
      projectiles.add( new Electron( owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 10000, owner.angle+180, -5, -5, damage ));

      break;
    case 7:
      projectiles.add( new ChargeLaser(owner, PApplet.parseInt( owner.cx+random(50, -50)), PApplet.parseInt(owner.cy+random(50, -50)), 100, owner.playerColor, 500, owner.angle, 0, damage*0.08f, true));
      owner.halt();
      break;
    case 8:
      projectiles.add( new Bomb(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, PApplet.parseInt(random(500, 2000)), owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage*2, true));

      break;
    case 9:
      projectiles.add( new RCRocket(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 2500, owner.angle, random(-10, 10), cos(radians(owner.angle))*shootSpeed*.02f+owner.vx, sin(radians(owner.angle))*shootSpeed*.02f+owner.vy, damage, false));

      break;
    case 10:
      projectiles.add( new Boomerang(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 80, owner.playerColor, PApplet.parseInt(300*50)+100, owner.angle, cos(radians(owner.angle))*(70+2), sin(radians(owner.angle))*(70+2), PApplet.parseInt(damage*0.07f), 50, PApplet.parseInt(50*0.5f+12)));
      break;

    case 11:
      projectiles.add( new SniperBullet(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*400), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*400), 50, owner.playerColor, 10, owner.angle, PApplet.parseInt(damage*2)));

      break;
    case 12:
      projectiles.add( new Thunder(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*400), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*400), 400, owner.playerColor, 1500, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, 5, true));
      break;
    case 13:
      projectiles.add( new Rocket(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 50, owner.playerColor, 1000, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false));
      break;
    case 14:
      projectiles.add( new Mine(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 100, owner.playerColor, 50000, owner.angle, cos(radians(owner.angle))*shootSpeed*0.1f, sin(radians(owner.angle))*shootSpeed*0.1f, damage, true));
      break;
    case 15:
      projectiles.add( new Missle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle+90))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle+90))*50), 30, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle-90))*shootSpeed, sin(radians(owner.angle-90))*shootSpeed, damage, false));
      projectiles.add( new Missle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle+90))*50), PApplet.parseInt(owner.cy+sin(radians(owner.angle+90))*50), 30, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+90))*shootSpeed, sin(radians(owner.angle+90))*shootSpeed, damage, false));
      break;
    case 16:
      projectiles.add( new RevolverBullet(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*shootSpeed*1.5f), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*shootSpeed*1.5f), 60, 25, owner.playerColor, 1000, owner.angle, damage));

      break;
    }
    if (energy<maxEnergy)choosenProjectileIndex= (int)random(17);
  }
  public @Override
    void passive() {

    if (energy>=maxEnergy) {
      fill(owner.playerColor);
      text( description[choosenProjectileIndex], PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy)+100);
    }
  }

  public @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
  public @Override
    void reset() {
    super.reset();
    energy=90;
    deActivate();
    deChannel();
    regen=true;
  }
}
class FlameThrower extends Ability {//---------------------------------------------------    FlameThrower   ---------------------------------

  int alt, count, projectileDamage;
  float sutainCount, MAX_sutainCount=50, accuracy, MODIFIED_ANGLE_FACTOR=0.8f, MODIFIED_MAX_ACCEL=0.1f;
  FlameThrower() {
    super();
    name=getClassName(this);
    deactiveCost=0;
    activeCost=0;
    channelCost=0.23f;
    accuracy = 20;
    projectileDamage=1;
    cooldownTimer=900;
    MODIFIED_ANGLE_FACTOR=0.035f;
  } 
  public void press() {
    super.press();
    if (!active) {
      active=true;
      projectiles.add( new  Blast(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 0, 75, owner.playerColor, 200, owner.angle, projectileDamage));
    }
  }
  public void action() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead ) {
      float InAccurateAngle=random(-accuracy, accuracy);

      if (!active || energy<=0 ) {
        release();
        //if(sutainCount>10)sutainCount-=10;
      }
      channel();
      if (sutainCount%2<1)projectiles.add( new  Blast(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 25+sutainCount, 75, owner.playerColor, 200, owner.angle+InAccurateAngle, PApplet.parseInt(projectileDamage+sutainCount*.02f)));
      particles.add( new  Particle(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 0, 0, 150, 50, color(255, 0, 255)));
    }
  }
  public void hold() {

    if (cooldown<stampTime) {
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      action();
      // if (!active)press(); // cancel
      if (owner.hit)        if (sutainCount>10)sutainCount-=10;
      //release(); // cancel

      sutainCount+=0.3f;
      if (sutainCount>MAX_sutainCount) {
        sutainCount=MAX_sutainCount;
        owner.pushForce(1, owner.angle+180);
      }
      accuracy=sutainCount*0.1f;
    }
  }

  public void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active) {
        stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        sutainCount=0;
        enableCooldown();
      }
    }
  }

  public @Override
    void passive() {
  }
  public @Override
    void reset() {
    super.reset();
    energy=90;
    deActivate();
    deChannel();
    regen=true;
  }
}
class SummonEvil extends Ability {//---------------------------------------------------    SummonEvil   ---------------------------------
  int range=400, maxRange=1600, duration=350;
  float MODIFIED_MAX_ACCEL=0.01f, damage=1; 
  long startTime;
  ArrayList<Player> enemies = new  ArrayList<Player>();

  SummonEvil() {
    super();
    regenRate=0.22f;
    name=getClassName(this);
    activeCost=60;
    energy=80;
  } 
  
  public @Override
    void press() {
   if ((!reverse || owner.reverseImmunity)&& energy>activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, PApplet.parseInt(owner.x), PApplet.parseInt(owner.y), energy, active, channeling, cooling, regen, hold));
      activate();
      action();
        active=true;
    }
  }
  
  public @Override
    void action() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead ) {
      //  particles.add(new  Tesla( int(owner.cx), int(owner.cy), 200, 500, owner.playerColor));
      //players.add(new Turret(players.size(), int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 200, new AutoGun(), new RandomPassive().randomize() ));
      players.add(new FollowDrone(players.size(), PApplet.parseInt(owner.cx+cos(radians(owner.angle))*range), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*range), PApplet.parseInt(playerSize*0.5f), PApplet.parseInt(playerSize*0.5f), 20, 200, 2, new Random().randomize(), new RandomPassive().randomize() ));
      //println("hello");
    regen=true;
    }
  }

  public void  passive() {
    //stroke(owner.playerColor);
    stroke(BLACK);
    strokeWeight(6);
    noFill();
    arc(owner.cx, owner.cy, range*2, range*2, radians(owner.angle)-QUARTER_PI, radians(owner.angle)+QUARTER_PI);
    ellipse(PApplet.parseInt(owner.cx+cos(radians(owner.angle))*range), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*range), 150, 150);
    if (stampTime>=duration+startTime) {
      owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    }
  }
  public @Override
    void  reset() {
    super.reset();
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    energy=90;
    deActivate();
    deChannel();
    regen=true;
  }
}

class Random extends Ability {//---------------------------------------------------    Random   ---------------------------------

  Random() {
    super();
  } 
  public Ability randomize() {
    Ability rA=null;
    try {
      rA = abilityList[PApplet.parseInt(random(abilityList.length))].clone();
    }
    catch(CloneNotSupportedException e) {
      println("not cloned from Random Ability");
    }
    return rA;  // clone it
  }
}

class Particle  implements Cloneable {
  int  size, opacity=255;
  float x, y, vx, vy, angle;
  long spawnTime, deathTime, time;
  int particleColor;
  boolean dead, meta;
  //  int f;
  Particle(int _x, int _y, float _vx, float _vy, int _size, int _time, int _particleColor) {
    time=_time;
    size=_size;
    spawnTime=stampTime;
    deathTime=stampTime + _time;
    particleColor= _particleColor;
    // opacity=255;
    x= _x;
    y= _y;
    vx= _vx;
    vy= _vy;
  }

  public void update() {
    if (!dead && !freeze) { 
      // f =(fastForward)?speedFactor:1;
      if (reverse) {
        opacity+=8*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        opacity-=8*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
    }
  }

  public void display() {
    if (!dead ) {
      fill(particleColor, opacity);
      noStroke();
      ellipse(x, y, size, size);
    }
  }
  public void revert() {
    if (reverse && stampTime<spawnTime) {
      particles.remove(this);
    } else if (stampTime>deathTime) {
      dead=true;
    } else if (stampTime<deathTime) {
      dead=false;
    }
  }
  public Particle clone() {  
    try {
      return (Particle)super.clone();
    }
    catch(CloneNotSupportedException e) {
      println(e);
      return null;
    }
  }
}

//-------------------------------------------------------------//    RParticles    //-------------------------------------------------------------------------

class RParticles extends Particle {
  RParticles(int _x, int _y, float _vx, float _vy, int _size, int _time, int _particleColor) {
    super( _x, _y, _vx, _vy, _size, _time, _particleColor);
    opacity=0;
    x=_vx*_time*.06f+_x;
    y=_vy*_time*.06f+_y;
  }
  public void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        opacity-=8*F;
        x+=vx*timeBend;
        y+=vy*timeBend;
      } else {
        opacity+=8*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      }
    }
  }
  /* void display() {
   if (!dead ) {  
   noFill();
   stroke(hue(particleColor), saturation(particleColor), brightness(particleColor)*S, opacity);
   strokeWeight(int(0.1*opacity));
   ellipse(x, y, size, size);
   }
   }*/
}
//-------------------------------------------------------------//    ShockWave    //-------------------------------------------------------------------------

class ShockWave extends Particle {
  int sizeRate, halfSizeRate;
  ;
  ShockWave(int _x, int _y, int _size, int _sizeRate, int _time, int _particleColor) {
    super( _x, _y, 0, 0, _size, _time, _particleColor);
    sizeRate=_sizeRate;
    halfSizeRate=PApplet.parseInt(sizeRate*0.5f);
  }
  public void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        size-=sizeRate*timeBend;
        opacity+=halfSizeRate*timeBend;
      } else {
        size+=sizeRate*timeBend;
        opacity-=halfSizeRate*timeBend;
      }
    }
  }
  public void display() {
    if (!dead ) {  
      noFill();
      stroke(hue(particleColor), saturation(particleColor), brightness(particleColor)*S, opacity);
      strokeWeight(PApplet.parseInt(0.1f*opacity));
      ellipse(x, y, size, size);
    }
  }
}

class RShockWave extends ShockWave {

  RShockWave(int _x, int _y, int _size, int _sizeRate, int _time, int _particleColor) {
    super( _x, _y, _size, _sizeRate, _time, _particleColor);
    opacity=0;
    halfSizeRate=PApplet.parseInt(sizeRate*0.5f);
  }
  public void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        size+=sizeRate*timeBend;
        opacity-=halfSizeRate*timeBend;
      } else {
        size-=sizeRate*timeBend;
        opacity+=halfSizeRate*timeBend;
        if (size<=0)dead=true;
      }
    }
  }
}
class MShockWave extends ShockWave {
  int vx, vy;
  MShockWave(int _x, int _y, int _size, int _sizeRate, int _time, int _particleColor, int _vx, int _vy) {
    super( _x, _y, _size, _sizeRate, _time, _particleColor);
    opacity=0;
    vx=_vx;
    vy=_vy;
  }
  public void update() {
    super.update();
    if (!dead && !freeze) { 
      if (reverse) {
        x-=vx;
        y-=vy;
      } else {
        x+=vx;
        y+=vy;
      }
    }
  }
}

//-------------------------------------------------------------//    LineWave    //-------------------------------------------------------------------------

class LineWave extends Particle {
  float angle;
  LineWave(int _x, int _y, int _size, int _time, int _particleColor, float _angle) {
    super( _x, _y, 0, 0, _size, _time, _particleColor);
    angle=_angle;
  }
  public void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        size-=16*timeBend;
        opacity+=8*timeBend;
      } else {
        size+=16*timeBend;
        opacity-=8*timeBend;
      }
    }
  }
  public void display() {
    if (!dead ) {
      noFill();
      stroke(hue(particleColor), saturation(particleColor), brightness(particleColor)*S, opacity);
      strokeWeight(PApplet.parseInt(0.1f*opacity));
      line(x-cos(radians(angle))*size, y-sin(radians(angle))*size, x+cos(radians(angle))*size, y+sin(radians(angle))*size);
    }
  }
}

//-------------------------------------------------------------//    TempSlow   //-------------------------------------------------------------------------

class TempSlow extends Particle {
  float  decay;
  TempSlow(int _time, float _rate, float _decayRate) {
    super( 0, 0, 0, 0, 0, _time, 255);
    S=_rate;
    //println("slow! "+ _time+" :"+_rate);
    decay= _decayRate;
    timeBend=S*F;
    slow=true;
    drawTimeSymbol();
  }
  public void update() {
    if (!dead && !freeze) { 
      // f =(fastForward)?speedFactor:1;
      if (reverse) {
        if (deathTime>stampTime && S>0 && S<1)S/=decay;
        else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          S=1; 
          timeBend=S*F;
          slow=false;

          // println( "dead");
        }
        if (S<0) {
          S=0;
          //println( "too low");
        } else if (S>1) {
          S=1;
          //println( "too high");
        }
        timeBend=S*F;
        drawTimeSymbol();
        // println( timeBend +" : "+S);
      } else {
        if (deathTime>stampTime && S>0 && S<1)S*=decay;
        else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          S=1; 
          timeBend=S*F;
          slow=false;
          // println( "dead");
        }
        if (S<0) {
          S=0;
          // println( "too low");
        } else if (S>1) {
          S=1;
          //println( "too high");
        }
        timeBend=S*F;
        drawTimeSymbol();
        //  println( timeBend +" : "+S);
      }
    }
  }
  public void revert() {
    if (reverse && stampTime<spawnTime) {
      particles.remove(this);
    } else if (stampTime>deathTime && !dead) {
      dead=true;
      S=1; 
      timeBend=S*F; 
      slow=false;
      drawTimeSymbol();
    } else if (stampTime<deathTime) {
      dead=false;
    }
  }
  public void display() {
    /*if (!dead && !freeze) {
     noStroke();
     fill(particleColor, opacity);
     rect(0-shakeTimer, 0-shakeTimer, width+shakeTimer, height+shakeTimer);
     }*/
  }
}
//-------------------------------------------------------------//    TempReverse   //-------------------------------------------------------------------------

class TempReverse extends Particle {
  float  decay;
  TempReverse(int _time) {
    super( 0, 0, 0, 0, 0, _time, 255);
    deathTime= millis()+_time;
    reverse=true;
    drawTimeSymbol();
    meta=true;
  }
  public void update() {
    if (!dead ) { 
      /*if (reverse) {
       if (deathTime>millis())reverse=true;
       else {
       // println(deathTime+" : "+stampTime);
       dead=true;
       reverse=false;
       }
       } */
    }
  }
  public void revert() {
    if (reverse && deathTime<millis()) {
      dead=true;
      reverse=false;
      drawTimeSymbol();
      particles.remove(this);
    }

    /* if (reverse && stampTime<spawnTime) {
     particles.remove(this);
     } else if (millis()>deathTime && !dead) {
     dead=true;
     reverse=false;
     drawTimeSymbol();
     } else if (millis()<deathTime) {
     reverse=false;
     }*/
  }
  public void display() {
    /*if (!dead && !freeze) {
     noStroke();
     fill(particleColor, opacity);
     rect(0-shakeTimer, 0-shakeTimer, width+shakeTimer, height+shakeTimer);
     }*/
  }
}

//-------------------------------------------------------------//    TempFreeze   //-------------------------------------------------------------------------

class TempFreeze extends Particle {
  float  decay;
  TempFreeze(int _time) {
    super( 0, 0, 0, 0, 0, _time, 255);
    deathTime= millis()+_time;
    freeze=true;
    drawTimeSymbol();
  }
  public void update() {
    if (!dead ) { 
      // f =(fastForward)?speedFactor:1;
      if (reverse) {
        if (deathTime>millis())freeze=true;
        else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          freeze=false;
        }
      } else {

        if (deathTime>millis())freeze=true;
        else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          freeze=false;
        }
      }
    }
  }
  public void revert() {
    if (reverse && stampTime<spawnTime) {
      particles.remove(this);
    } else if (millis()>deathTime && !dead) {
      dead=true;
      freeze=false;
      drawTimeSymbol();
    } else if (millis()<deathTime) {
      dead=false;
    }
  }
  public void display() {
    /*if (!dead && !freeze) {
     noStroke();
     fill(particleColor, opacity);
     rect(0-shakeTimer, 0-shakeTimer, width+shakeTimer, height+shakeTimer);
     }*/
  }
}

//-------------------------------------------------------------//    TempFast   //-------------------------------------------------------------------------

class TempFast extends Particle {
  float  decay, maxSpeed;
  TempFast(int _time, float _rate, float _decayRate) {
    super( 0, 0, 0, 0, 0, _time, 255);
    F=_rate;
    maxSpeed=F;
    //println("slow! "+ _time+" :"+_rate);
    decay= _decayRate;
    timeBend=S*F;
    fastForward=true;
    drawTimeSymbol();
  }
  public void update() {
    if (!dead && !freeze) { 
      // f =(fastForward)?speedFactor:1;
      if (reverse) {
        if (deathTime>stampTime && F>1 && F<=maxSpeed)F/=decay;
        else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          F=1; 
          timeBend=S*F;
          fastForward=false;

          // println( "dead");
        }
        if (F<1) {
          F=1;
          //println( "too low");
        } else if (F>maxSpeed) {
          F=maxSpeed;
          //println( "too high");
        }
        timeBend=S*F;
        drawTimeSymbol();
        // println( timeBend +" : "+S);
      } else {
        if (deathTime>stampTime && F>1 && F<=maxSpeed)F*=decay;
        else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          F=1; 
          timeBend=S*F;
          fastForward=false;
          // println( "dead");
        }
        if (F<1) {
          F=1;
          // println( "too low");
        } else if (F>maxSpeed) {
          F=maxSpeed;
          //println( "too high");
        }
        timeBend=S*F;
        drawTimeSymbol();
        //  println( timeBend +" : "+S);
      }
    }
  }
  public void revert() {
    if (reverse && stampTime<spawnTime) {
      particles.remove(this);
    } else if (stampTime>deathTime && !dead) {
      dead=true;
      F=1; 
      timeBend=S*F; 
      fastForward=false;
      drawTimeSymbol();
    } else if (stampTime<deathTime) {
      dead=false;
    }
  }
  public void display() {
    /*if (!dead && !freeze) {
     noStroke();
     fill(particleColor, opacity);
     rect(0-shakeTimer, 0-shakeTimer, width+shakeTimer, height+shakeTimer);
     }*/
  }
}
//-------------------------------------------------------------//    Flash    //-------------------------------------------------------------------------

class Flash extends Particle {
  float rate;
  Flash(int _time, float _rate, int _particleColor) {
    super( 0, 0, 0, 0, 0, _time, _particleColor);
    rate=_rate;
  }
  public void update() {
    if (!dead && !freeze) { 
      // f =(fastForward)?speedFactor:1;
      if (reverse) {
        opacity+=rate*timeBend;
      } else {
        opacity-=rate*timeBend;
      }
    }
  }

  public void display() {
    if (!noFlash && !dead && !freeze) {
      noStroke();
      fill(particleColor, opacity*flashAmount);
      rect(0-shakeTimer, 0-shakeTimer, width+shakeTimer, height+shakeTimer);
    }
  }
}

//-------------------------------------------------------------//    Feather    //-------------------------------------------------------------------------

class Feather extends Particle {
  float shrinkRate;
  Feather(int _time, int _x, int _y, float _vx, float _vy, float _shrinkRate, int _particleColor) {
    super( _x, _y, _vx, _vy, 100, _time, _particleColor);
    shrinkRate=_shrinkRate;
    angle=random(0, 360);
  }
  public void update() {
    if (!dead && !freeze) { 
      //f =(fastForward)?speedFactor:1;
      if (reverse) {
        angle+=16*timeBend;
        size+=shrinkRate*timeBend;
        opacity+=8*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        angle-=16*timeBend;
        size-=shrinkRate*timeBend;
        opacity-=8*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
    }
  }

  public void display() {
    if (!dead ) {
      noFill();
      stroke(hue(particleColor), saturation(particleColor), brightness(particleColor)*S, opacity);
      strokeWeight(opacity*0.1f);
      arc(x, y, size, size, radians(angle), radians(angle+180));
    }
  }
}

class Spark extends Particle {
  float shrinkRate, maxSize, brightness=255;
  Spark(int _time, int _x, int _y, float _vx, float _vy, float _shrinkRate, float _angle, int _particleColor) {
    super( _x, _y, _vx, _vy, 100, _time, _particleColor);
    angle=_angle;
    maxSize=size;
    shrinkRate=_shrinkRate;
  }
  public void update() {
    if (!dead && !freeze) { 
      //f =(fastForward)?speedFactor:1;
      if (reverse) {       
        size+=shrinkRate*timeBend;
        brightness+=16*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        size-=shrinkRate*timeBend;
        brightness-=16*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
      if (size<=0)dead=true;
    }
  }

  public void display() {
    if (!dead ) { 

      //noFill();
      stroke(hue(particleColor), saturation(particleColor)-brightness, brightness(particleColor)*S);
      strokeWeight(6);
      line(x+cos(radians(angle))*(maxSize-size), y+sin(radians(angle))*(maxSize-size), x+cos(radians(angle))*(maxSize), y+sin(radians(angle))*(maxSize));
    }
  }
}

class Gradient extends Particle {
  float shrinkRate, opacity=200, size=100;
  Gradient(int _time, int _x, int _y, float _vx, float _vy, int _maxSize, float _shrinkRate, float _angle, int _particleColor) {
    super( _x, _y, _vx, _vy, _maxSize, _time, _particleColor);
    size=_maxSize;
    angle=_angle;
    shrinkRate=_shrinkRate;
  }
  public void update() {
    if (!dead && !freeze) { 

      if (reverse) {       
        size+=shrinkRate*timeBend;
        opacity+=shrinkRate*2*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        size-=shrinkRate*timeBend;
        opacity-=shrinkRate*2*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
        if (size<0)dead=true;
      }
    }
  }

  public void display() {
    if (!dead) {

      // stroke(hue(particleColor), saturation(particleColor)-brightness, brightness(particleColor)*S);
      noStroke();
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      fill(particleColor, opacity);
      // ellipse(x, y, size*(deathTime-stampTime)/time, size*(deathTime-stampTime)/time );
      //  stroke(projectileColor);
      //ellipse(x, y, size, size);
      rect(-(size*.5f), -(size*.5f), 2400, size);
      popMatrix();
      //   strokeWeight(8);
      //     line(x+cos(radians(angle))*(maxSize-size), y+sin(radians(angle))*(maxSize-size), x+cos(radians(angle))*(maxSize), y+sin(radians(angle))*(maxSize));
    }
  }
}

class Shock extends Particle {
  float shrinkRate, brightness=255;
  PShape circle = createShape();       // First create the shape
  // star.beginShape();          // now call beginShape();


  //star.endShape(CLOSE);       // now call endShape(CLOSE);
  Shock(int _time, int _x, int _y, float _vx, float _vy, float _shrinkRate, float _angle, int _particleColor) {
    super( _x, _y, _vx, _vy, 100, _time, _particleColor);
    angle=_angle;
    shrinkRate=_shrinkRate;

    circle.beginShape();
    circle.noFill();
    for (int i=0; i<360; i+= (360/6)) {
      circle.vertex(x+cos(radians(angle+random(-i, i)*0.05f))*(size+random(i*2)), y+sin(radians(angle+random(-i, i)*0.05f))*(size+random(i*2)));
    }
    circle.endShape(OPEN);
  }
  public void update() {
    if (!dead && !freeze) { 

      if (reverse) {       
        size+=shrinkRate*timeBend;
        brightness+=16*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        size-=shrinkRate*timeBend;
        brightness-=16*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
        if (size<0) dead=true;
      }
    }
  }

  public void display() {
    if (!dead && !freeze) {
      noFill();

      beginShape();
      stroke(hue(particleColor), saturation(particleColor)-brightness, brightness(particleColor));
      strokeWeight(4);
      for (int i=0; i<360; i+= (360/6)) {
        vertex(x+cos(radians(angle+random(-i, i)*0.05f))*(size+random(i*2)), y+sin(radians(angle+random(-i, i)*0.05f))*(size+random(i*2)));
      }
      endShape();
    }
    if (!dead && freeze) { 
      shape(circle, circle.X + circle.width*.5f, circle.Y+circle.height*.5f);
    }
  }
}
class Tesla extends Particle {
  int weight, flick;
  int flux[]=new int[8];

  //Player target;

  Tesla( int _x, int _y, int _size, int _time, int _particleColor) {
    super( _x, _y, 0, 0, _size, _time, _particleColor);
    weight=size;
    x=_x;
    y=_y;
    for (int i=0; i<flux.length; i++)flux[i]=PApplet.parseInt(random(weight)-weight*.5f);
  }
  public void update() {
    if (!dead && !freeze) {
      flick=PApplet.parseInt(random(5));
      for (int i=0; i<flux.length; i++)flux[i]=PApplet.parseInt(random(weight)-weight*.5f);
    }
  }

  public void display() {
    if (!dead) {
      strokeWeight(flick);
      stroke(hue(particleColor), 255, 255);
      noFill();
      bezier( this.x+flux[0], this.y+flux[1], this.x +flux[2], this.y+flux[3], this.x+flux[4], this.y+flux[5], this.x+flux[6], this.y+flux[7]);// crosshier
    }
  }
}
class Text extends Particle {
  float shrinkRate, brightness=255;
  String text="";
  int  offsetX, offsetY, type, count;
  boolean follow;
  Player owner;
  //star.endShape(CLOSE);       // now call endShape(CLOSE);
  Text(String _text, int _x, int _y, float _vx, float _vy, float _size, float _shrinkRate, int _time, int _particleColor, int _type) {
    super( _x, _y, _vx, _vy, PApplet.parseInt(_size), _time, _particleColor);
    type= _type;
    shrinkRate=_shrinkRate;
    text=_text;
  }

  Text(Player _owner, String _text, int _offsetX, int _offsetY, float _size, float _shrinkRate, int _time, int _particleColor, int _type) {
    super( 0, 0, 0, 0, PApplet.parseInt(_size), _time, _particleColor);
    type= _type;
    shrinkRate=_shrinkRate;
    text=_text;
    follow=true;
    offsetX=_offsetX;
    offsetY=_offsetY;
    owner=_owner;
  }
  public void update() {
    if (!dead && !freeze) { 
      if (reverse) {       
        size+=shrinkRate*timeBend;
        count++;
        if (follow) {
          x=owner.cx+offsetX;
          y=owner.cy+offsetY;
        } else {
          x-=vx*timeBend;
          y-=vy*timeBend;
        }
      } else {
        count++;
        size-=shrinkRate*timeBend;
        if (follow) {
          x=owner.cx+offsetX;
          y=owner.cy+offsetY;
        } else {
          x+=vx*timeBend;
          y+=vy*timeBend;
        }
        //if (size<0) dead=true;
      }
    }
  }

  public void display() {
    if (!dead) {
      noStroke();
      switch(type) {
      case 1:
        if (count%2==0)fill(particleColor);
        else fill(255);
        break;
      default:
        fill(particleColor);
      }
      //stroke(hue(particleColor), saturation(particleColor)-brightness, brightness(particleColor));
      textSize(size);
      text(text, x, y);
    }
  }
}


class Fragment extends Particle {
  float vAngle;
  PVector p1, p2, p3;
  int maxSize;
  Fragment(int _x, int _y, float _vx, float _vy,float _vAngle, int _minSize, int _maxSize, int _time, int _particleColor) {
    super( _x, _y, _vx, _vy, _minSize, _time, _particleColor);
    vAngle=_vAngle;
   // p1=new PVector(random(_minSize-_maxSize)+_minSize, random(_minSize-_maxSize)+_minSize);
    p1=new PVector(random(_minSize-_maxSize)+_minSize, 0);
    p1.rotate(random(radians(280),radians(320)));
   // p2=new PVector(random(_minSize-_maxSize)+_minSize, random(_minSize-_maxSize)+_minSize);
    p2=new PVector(random(_minSize-_maxSize)+_minSize, 0);
    p2.rotate(random(radians(160),radians(200)));
    //p3=new PVector(random(_minSize-_maxSize)+_minSize, random(_minSize-_maxSize)+_minSize);
     p3=new PVector(random(_minSize-_maxSize)+_minSize, 0);
    p3.rotate(random(radians(40),radians(80)));
    println(p1.x, p1, y);

    opacity=255;
    x=_vx*_time*.06f+_x;
    y=_vy*_time*.06f+_y;
  }

  public void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        opacity+=8*F;
        x+=vx*timeBend;
        y+=vy*timeBend;
        angle-=radians(vAngle);
        p1.setMag(sin(radians(angle))*1);
        p2.setMag(sin(radians(angle))*1);
        p3.setMag(sin(radians(angle))*1);
      } else {
        opacity-=8*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
        angle+=radians(vAngle);
        /*  p1.setMag(sin(radians(angle))*1);
         p2.setMag(sin(radians(angle))*1);
         p3.setMag(sin(radians(angle))*1);*/
        p1.setMag((maxSize*(deathTime-stampTime)/time)+size);
        p2.setMag((maxSize*(deathTime-stampTime)/time)+size);
        p3.setMag((maxSize*(deathTime-stampTime)/time)+size);
        p1.rotate(radians(angle));
        p2.rotate(radians(angle));
        p3.rotate(radians(angle));
      }
    }
  }
  public void display() {
    if (!dead ) {  
      fill(WHITE,opacity);
      stroke(hue(particleColor), saturation(particleColor), brightness(particleColor)*S, opacity);
      strokeWeight(8);
      triangle(p1.x+x, p1.y+y, p2.x+x, p2.y+y, p3.x+x, p3.y+y);
    }
  }
}
class HpRegen extends Ability {//---------------------------------------------------    HpRegen   ---------------------------------
  float regenRate = 1;
  int count;
  HpRegen() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
  }
  public @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(1);
      ellipse(owner.cx, owner.cy, 200, 200);
      count++;
      if (count%15==0 && owner.maxHealth>owner.health)owner.health += regenRate;
    }
  }
  public @Override
    void reset() {
    // super.reset();
  }
}
class MpRegen extends Ability {//---------------------------------------------------    MpRegen   ---------------------------------
  float regenRate = 1;
  int count;
  MpRegen() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
  }
  public @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(1);
      ellipse(owner.cx, owner.cy, 200, 200);
      count++;
      if (count%10==0 && owner.abilityList.get(0).maxEnergy>owner.abilityList.get(0).energy)owner.abilityList.get(0).energy += regenRate;
    }
  }
  public @Override
    void reset() {
    // super.reset();
  }
}

class Armor extends Ability {//---------------------------------------------------    HpRegen   ---------------------------------
  // float regenRate = 1;
  int armorAmount=4, stillBonusArmor=2;
  Armor() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
  }
  public @Override
    void hold() {
    hold=true;
  }
  public @Override
    void release() {
    hold=false;
  }
  public @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      rect(owner.x, owner.y, owner.w, owner.h);

      if (hold) {
        owner.armor=PApplet.parseInt(armorAmount*.5f);
      } else {
        owner.armor=armorAmount;
        rect(owner.x-10, owner.y-10, owner.w+20, owner.h+20);
      }
      if (abs(owner.ax)+abs(owner.ay)<1) {
        owner.armor=armorAmount+stillBonusArmor;
        rect(owner.x-20, owner.y-20, owner.w+40, owner.h+40);
      }
    }
  }
  public @Override
    void reset() {
    owner.armor= PApplet.parseInt(owner.DEFAULT_ARMOR);
  }
}

class Speed extends Ability {//---------------------------------------------------    Speed   ---------------------------------
  float speedLimit = 0.25f;
  Speed() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
  }
  public @Override
    void hold() {
  }
  public @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      triangle(owner.cx+sin(0)*100, owner.cy+cos(0)*100, owner.cx+sin(radians(120))*100, owner.cy+cos(radians(120))*100, owner.cx+sin(radians(240))*100, owner.cy+cos(radians(240))*100);
      if (owner.MAX_ACCEL<speedLimit)owner.MAX_ACCEL+=0.02f;
    }
  }
  public @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}
class Gravitation extends Ability {//---------------------------------------------------    Gravitation   ---------------------------------
  float dragForce =-0.4f;
  Gravitation() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
  }
  public @Override
    void hold() {
  }
  public @Override
    void passive() {
    dragPlayersInRadius(300, false);
  }
  public @Override
    void reset() {
  }
  public float calcAngleFromBlastZone(float x, float y, float px, float py) {
    double deltaY = py - y;
    double deltaX = px - x;
    return (float)Math.atan2(deltaY, deltaX) * 180 / PI;
  }

  public void dragPlayersInRadius(int range, boolean friendlyFire) {
    if (!freeze &&!reverse) { 
      /*for (int i=0; i<players.size (); i++) { 
       if (!players.get(i).dead &&(players.get(i)!= owner || friendlyFire)) {
       if (dist(owner.cx, owner.cy, players.get(i).cx, players.get(i).cy)<range) {
       players.get(i).pushForce(dragForce*timeBend, calcAngleFromBlastZone(owner.cx, owner.cy, players.get(i).cx, players.get(i).cy));
       // if (count%10==0)players.get(i).hit(damage);
       }
       }
       }*/
      for (Player p : players) { 
        if (!p.dead &&(p!= owner && p.ally!=owner.ally || friendlyFire)) {
          if (dist(owner.cx, owner.cy, p.cx, p.cy)<range) {
            p.pushForce(dragForce*timeBend, calcAngleFromBlastZone(owner.cx, owner.cy, p.cx, p.cy));
            // if (count%10==0)players.get(i).hit(damage);
          }
        }
      }
    }
  }
}
class Repel extends Ability {//---------------------------------------------------    Gravitation   ---------------------------------
  float dragForce =0.5f;
  Repel() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
  }
  public @Override
    void hold() {
  }
  public @Override
    void passive() {
    dragPlayersInRadius(300, false);
  }
  public @Override
    void reset() {
  }
  public float calcAngleFromBlastZone(float x, float y, float px, float py) {
    double deltaY = py - y;
    double deltaX = px - x;
    return (float)Math.atan2(deltaY, deltaX) * 180 / PI;
  }

  public void dragPlayersInRadius(int range, boolean friendlyFire) {
    if (!freeze &&!reverse) { 
      /*for (int i=0; i<players.size (); i++) { 
       if (!players.get(i).dead &&(players.get(i)!= owner || friendlyFire)) {
       if (dist(owner.cx, owner.cy, players.get(i).cx, players.get(i).cy)<range) {
       players.get(i).pushForce(dragForce*timeBend, calcAngleFromBlastZone(owner.cx, owner.cy, players.get(i).cx, players.get(i).cy));
       // if (count%10==0)players.get(i).hit(damage);
       }
       }
       }
       }*/
      for (Player p : players) { 
        if (!p.dead &&(p!= owner && p.ally!=owner.ally || friendlyFire)) {
          if (dist(owner.cx, owner.cy, p.cx, p.cy)<range) {
            p.pushForce(dragForce*timeBend, calcAngleFromBlastZone(owner.cx, owner.cy, p.cx, p.cy));
            // if (count%10==0)players.get(i).hit(damage);
          }
        }
      }
    }
  }
}
class Static extends Ability {//---------------------------------------------------    Static   ---------------------------------
  int count;
  Static() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
  }
  public @Override
    void hold() {
  }
  public @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      beginShape();
      for (int i=0; i<360; i+=60) {
        vertex(owner.cx+sin(radians(i))*175, owner.cy+cos(radians(i))*175);
      }
      endShape(CLOSE);
      count++;
      if (count%100==0)projectiles.add( new CurrentLine(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), PApplet.parseInt( random(300, 700)), owner.playerColor, 50, owner.angle, cos(radians(owner.angle)), sin(radians(owner.angle)), 15));
    }
  }
  public @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class SuppressFire extends Ability {//---------------------------------------------------    SuppressFire   ---------------------------------
  int count, cooldown;
  SuppressFire() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
    if (cooldown>40) {
      noStroke();
      fill(255);
      ellipse(owner.cx+cos(radians(owner.angle))*100, owner.cy+sin(radians(owner.angle))*100, 100, 100);
      projectiles.add( new Needle(owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*owner.w), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 7));
      cooldown=0;
    }
  }
  public @Override
    void hold() {
  }
  public @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      beginShape();
      for (int i=0; i<360; i+=72.5f) {
        vertex(owner.cx+sin(radians(i))*150, owner.cy+cos(radians(i))*150);
      }

      endShape(CLOSE);
      cooldown++;
      //count++;
      //  if (count%30==0)   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 3));
    }
  }
  public @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class Gloss extends Ability {//---------------------------------------------------    Gloss   ---------------------------------
  int count;
  Gloss() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
  }
  public @Override
    void hold() {
  }
  public @Override
    void passive() {
    if (!owner.stealth) {

      cooldown+=1;
      for (int i=0; i<360; i+=30) {
        if (cooldown%360==i) {
          projectiles.add( new Shield( owner, PApplet.parseInt( owner.cx+cos(radians(i))*180), PApplet.parseInt(owner.cy+sin(radians(i))*180), owner.playerColor, 1000, i+90, 1, PApplet.parseInt( cos(radians(i))*180), PApplet.parseInt(sin(radians(i))*180)));
          projectiles.add( new Shield( owner, PApplet.parseInt( owner.cx+cos(radians(i+180))*180), PApplet.parseInt(owner.cy+sin(radians(i+180))*180), owner.playerColor, 1000, i+270, 1, PApplet.parseInt( cos(radians(i+180))*180), PApplet.parseInt(sin(radians(i+180))*180)));
        }
      }
      //count++;
      //  if (count%30==0)   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 3));
    }
  }
  public @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class BackShield extends Ability {//---------------------------------------------------    BackShield   ---------------------------------
  int count;
  Shield shield;

  BackShield() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
  }
  public @Override
    void hold() {
  }
  public @Override
    void onDeath() {
    if (shield!=null && !shield.dead) { 
      shield.size=100;
      shield.fizzle();
      shield.deathTime=stampTime;
      shield.dead=true;
    }
  }
  public @Override
    void passive() {
    if (!owner.stealth) {
      if (shield==null||shield.dead) { 
        shield=new Shield( owner, PApplet.parseInt( owner.cx+cos(radians(owner.angle))*100), PApplet.parseInt(owner.cy+sin(radians(owner.angle))*100), owner.playerColor, 100000, owner.angle+90, 1, PApplet.parseInt( cos(radians(owner.angle))*100), PApplet.parseInt(sin(radians(owner.angle))*100));
        shield.size=100;
        projectiles.add(shield );
      }
      shield.angle=owner.angle+90;
      shield.offsetX=PApplet.parseInt(cos(radians(owner.angle+180))*100);
      shield.offsetY=PApplet.parseInt(sin(radians(owner.angle+180))*100);
    }
  }
  public @Override
    void reset() {
    try {
      if (shield!=null||!shield.dead) { 
        shield.size=100;
        shield.fizzle();
        shield.deathTime=stampTime;
        shield.dead=true;
      }
    }
    catch(Exception e) {
            println(e);
    }
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}


class Trail extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int count, cooldown;
  Trail() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
  }
  public @Override
    void hold() {
    if (cooldown>6) {
      cooldown=0;
      Blast b =new  Blast(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 0, 30, owner.playerColor, 2500, owner.angle, 2, 2);
      projectiles.add(b);
    }
  }
  public @Override
    void release() {
  }
  public @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      beginShape();
      for (int i=0; i<360; i+=20) {
        vertex(owner.cx+sin(radians(i))*150, owner.cy+cos(radians(i))*150);
      }
      endShape(CLOSE);
      cooldown++;
    }
  }
  public @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}
class PainPulse extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int count, cooldown;
  PainPulse() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void onHit() {
    if (cooldown>200) {
      cooldown=0;
      for (int i=0; i<360; i+=45) {
        projectiles.add( new  Blast(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 15, 40, owner.playerColor, 350, i, 1, 10));
      }
    }
  }
  public @Override
    void hold() {
  }
  public @Override
    void release() {
  }
  public @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      beginShape();
      for (int i=0; i<360; i+=10) {
        vertex(owner.cx+sin(radians(i))*100, owner.cy+cos(radians(i))*100);
      }
      endShape(CLOSE);
      cooldown++;
    }
  }
  public @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}
class Nova extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int count, cooldown;
  Nova() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
    // if (cooldown>100) {
    //   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 5));
    // }
  }
  public @Override
    void hold() {
  }
  public @Override
    void release() {
    if (cooldown>50) {
      cooldown=0;

      projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx+sin(owner.keyAngle)*60), PApplet.parseInt(owner.cy+cos(owner.keyAngle)*60), 40, owner.playerColor, 180, owner.angle-100, -24, 110, sin(owner.keyAngle)*10, cos(owner.keyAngle)*10, 3, true));
      projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx+sin(owner.keyAngle)*60), PApplet.parseInt(owner.cy+cos(owner.keyAngle)*60), 40, owner.playerColor, 180, owner.angle-280, -24, 110, sin(owner.keyAngle)*10, cos(owner.keyAngle)*10, 3, true));
    }
  }
  public @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      beginShape();
      for (int i=0; i<360; i+=40) {
        vertex(owner.cx+sin(radians(i))*150, owner.cy+cos(radians(i))*150);
      }

      endShape(CLOSE);
      cooldown++;
      // count++;
      //  if (count%30==0)   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 3));
    }
  }
  public @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class BulletCutter extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int count, cooldown, range=450;
  float a=0, randX, randY;
  boolean alternate;
  BulletCutter() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
    // if (cooldown>100) {
    //   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 5));
    // }
  }
  public @Override
    void hold() {
    if (!owner.dead ) {
      float tempA=0, distance=0, velocity=0;
      boolean trigger=false;

      if (cooldown>10) {
        if ( !freeze || owner.freezeImmunity) {

          randX=random(range);
          randY=random(range);

          a+=30*timeBend;

          for (Projectile p : projectiles) {
            if (!p.dead && p.ally!=owner.ally && p instanceof Destroyable && dist(p.x, p.y, owner.cx, owner.cy)<range*.5f) {
              //background(owner.playerColor);
              cooldown=0;
              trigger=true;

              if (p instanceof RevolverBullet )velocity=((RevolverBullet)p).v*timeBend;
              if (p instanceof Needle )velocity=((Needle)p).v*timeBend;
              if (p instanceof HomingMissile )velocity=(abs(((HomingMissile)p).vx)+abs(((HomingMissile)p).vy)*timeBend);
              distance=dist(owner.cx, owner.cy, p.x, p.y);
              tempA=calcAngleBetween(p, owner)+180;
            }
          }
        }
        noFill();
        stroke(owner.playerColor, 50);
        strokeWeight(60);
        arc(owner.cx, owner.cy, randX, randY, radians(owner.angle+a), radians(owner.angle+a)+PI*.1f);
        stroke(hue(owner.playerColor), saturation(owner.playerColor), brightness(owner.playerColor)+50,100);
        strokeWeight(50);
        arc(owner.cx, owner.cy, randX, randY, radians(owner.angle+a+20), radians(owner.angle+a+20)+PI*.05f);
        stroke(WHITE,150);
        strokeWeight(40);
        arc(owner.cx, owner.cy, randX, randY, radians(owner.angle+a+30), radians(owner.angle+a+30)+PI*.03f);
      }

      if (trigger) {          
        alternate=!alternate;
        if (alternate)projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx+sin(tempA)*range), PApplet.parseInt(owner.cy+cos(tempA)*range), 50, owner.playerColor, 140, tempA+5, -15, distance-velocity, sin(tempA)*distance, cos(tempA)*distance, 0, true));
        else      projectiles.add( new Slash(owner, PApplet.parseInt( owner.cx+sin(tempA)*range), PApplet.parseInt(owner.cy+cos(tempA)*range), 50, owner.playerColor, 140, tempA-5, +15, distance-velocity, sin(tempA)*distance, cos(tempA)*distance, 0, true));
      }
    }
  }

  public @Override
    void release() {
  }
  public @Override
    void passive() {
    if (!owner.dead && !freeze || owner.freezeImmunity) {
      cooldown++;
    }
  }
  public @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}
class Boost extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int count, charge, cooldown;
  final int radius= 145, maxCharge=70; 
  Boost() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
    // if (cooldown>100) {
    //   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 5));
    // }
  }
  public @Override
    void hold() {
    if (charge<=maxCharge)charge++;
  }
  public @Override
    void release() {
    if (charge>maxCharge && cooldown>60) {
      cooldown=0;
      charge=0;
      projectiles.add( new  Blast(owner, PApplet.parseInt( owner.cx), PApplet.parseInt(owner.cy), 0, 50, owner.playerColor, 350, 0, 1, 10));
      owner.pushForce(35, owner.keyAngle);
    }
    charge=PApplet.parseInt(charge*.5f);
  }
  public @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      if (charge>=maxCharge) {
        strokeWeight(3);
        ellipse(owner.cx, owner.cy, radius, radius);
      } else {
        strokeWeight(10);
        arc(owner.cx, owner.cy, radius, radius, -HALF_PI, (PI*2/(maxCharge+1-charge))-HALF_PI);
      }
      cooldown++;
      // count++;
      //  if (count%30==0)   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 3));
    }
  }
  public @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class Glide extends Ability {//---------------------------------------------------    bullet   ---------------------------------

  Glide() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void press() {
    // if (cooldown>100) {
    //   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 5));
    // }
  }
  public @Override
    void hold() {
    owner.pushForce(1, owner.keyAngle);
  }
  public @Override
    void release() {
  }
  public @Override
    void passive() {
    // owner.pushForce(1,owner.keyAngle);
  }
  public @Override
    void reset() {
    // owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}


class BulletTime extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int cooldown;
  final int interval=150;
  boolean trigger;
  BulletTime() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void onHit() {
  }
  public @Override
    void hold() {
  }
  public @Override
    void release() {
  }
  public @Override
    void passive() {

    if (cooldown>interval) {
      for (Projectile p : projectiles) {
        if (!p.dead && p.ally!=owner.ally && dist(owner.cx, owner.cy, p.x, p.y)<300) {
          trigger=true;
          break;
        }
      }
      if (trigger) {
        owner.slowImmunity=true;
        particles.add(new TempSlow(1500, 0.03f, 1.05f));
        trigger=false;
        cooldown=0;
      }
    }
    cooldown++;
  }
  public @Override
    void reset() {
    owner.slowImmunity=false;
  }
}
class Adrenaline extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int cooldown;
  final int interval=300;
  boolean trigger;
  Adrenaline() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
    if (fastForward||timeBend>1)owner.health++;
  }
  public @Override
    void onHit() {
    if (fastForward||timeBend>1) {
      owner.health++;

      for (Ability a : owner.abilityList)a.energy+=2;
    }
  }
  public @Override
    void hold() {
  }
  public @Override
    void release() {
  }
  public @Override
    void passive() {
    if (fastForward)owner.armor=100;
    else owner.armor=PApplet.parseInt(owner.DEFAULT_ARMOR);

    if (cooldown>interval) {
      /* for (Projectile p : projectiles) {
       if (!p.dead && p.ally!=owner.ally && dist(owner.cx, owner.cy, p.x, p.y)<200) {
       trigger=true;
       break;
       }
       }*/
      for (Player p : players) {
        if (!p.dead && p.ally!=owner.ally && dist(owner.cx, owner.cy, p.cx, p.cy)<200) {
          trigger=true;
          break;
        }
      }
      if (trigger) {
        // owner.fastforwardImmunity=true;
        particles.add(new TempFast(2500, 2, 0.995f));
        trigger=false;
        cooldown=0;
      }
    }
    cooldown++;
  }
  public @Override
    void reset() {
    // owner.fastforwardImmunity=false;
  }
}

class Emergency extends Ability {//---------------------------------------------------    Emergency   ---------------------------------

  final int interval=1000;
  int cooldown=interval;
  float percent=0.5f;
  boolean trigger;
  Emergency() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void onHit() {
  }
  public @Override
    void hold() {
  }
  public @Override
    void release() {
  }
  public @Override
    void passive() {

    if (cooldown>interval && owner.health<owner.maxHealth*percent) {
      if (!owner.stealth) { 
        fill(owner.playerColor);
        noStroke();
        ellipse(owner.cx, owner.cy, 250, 250);
        stroke(1);
      }
      for (Projectile p : projectiles) {
        if (!p.dead && p.ally!=owner.ally && dist(owner.cx, owner.cy, p.x, p.y)<250 && owner.health<=p.damage) {
          trigger=true;
          break;
        }
      }
      if (trigger) {
        owner.freezeImmunity=true;
        particles.add(new Flash(100, 8, WHITE));  

        //particles.add(new TempSlow(1500, 0.03, 1.05));
        for (int i =0; i<3; i++) {
          particles.add( new Feather(300, PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), random(-2, 2), random(-2, 2), 25, owner.playerColor));
        }
        particles.add( new TempFreeze(4500));
        trigger=false;
        cooldown=0;
      }
    }
    if (!freeze)cooldown++;
  }
  public @Override
    void reset() {
    cooldown=interval;
    owner.freezeImmunity=false;
  }
}
class Redemption extends Ability {//---------------------------------------------------    Redemption   ---------------------------------

  final int interval=1000;
  int cooldown=interval;
  float percent=1.0f;
  boolean trigger;
  Redemption() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }
  public @Override
    void onHit() {
  }
  public @Override
    void hold() {
  }
  public @Override
    void release() {
  }
  public @Override
    void passive() {

    if (cooldown>interval ) {//&& owner.health<owner.maxHealth*percent

      if (!owner.stealth) { 
        fill(owner.playerColor);
        noStroke();
        ellipse(owner.cx, owner.cy, 250, 250);
        stroke(1);
      }
      for (Projectile p : projectiles) {
        if (!p.dead && p.ally!=owner.ally && dist(owner.cx, owner.cy, p.x, p.y)<250 && owner.health<=p.damage) {
          trigger=true;
          break;
        }
      }
      if (trigger) {
        particles.add(new Flash(100, 8, WHITE));  
        shakeTimer+=20;
        particles.add( new TempReverse(2000));
        trigger=false;
        cooldown=0;
      }
    }
    if (!freeze)cooldown++;
  }
  public @Override
    void reset() {
    cooldown=interval;
    //owner.freezeImmunity=false;
  }
}
class Undo extends Ability {//---------------------------------------------------    Undo   ---------------------------------

  final int interval=300, delay=400;
  int cooldown=interval, triggerDiff=10;
  long timer;
  float percent=1.0f, tempHealth;
  boolean trigger;
  Undo() {
    super();
    name=getClassName(this);
  } 
  public @Override
    void action() {
  }

  public @Override
    void hold() {
  }
  public @Override
    void release() {
  }
  public @Override
    void onHit() {
    if (!trigger && cooldown>interval) {//&& owner.health<owner.maxHealth*percent
      if (owner.health+triggerDiff<tempHealth) { 
        trigger=true; 
        timer=stampTime;
        particles.add(new Flash(100, 4, owner.playerColor));  
        // for (int i =0; i<10; i++) {
        particles.add( new Feather(300, PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), random(-2, 2), random(-2, 2), 200, owner.playerColor));
        //  }
        particles.add( new  Particle(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 0, 0, PApplet.parseInt(owner.w), 350, color(255, 0, 255)));
      }
    }
  }
  public @Override
    void passive() {

    if (trigger) {
      if (timer+delay<stampTime) {
        shakeTimer+=10;
        particles.add( new TempReverse(1200));
        trigger=false;
        cooldown=0;
        timer=millis();
      }
    }

    if (!trigger && cooldown>interval ) { 
      if (!owner.stealth) { 
        fill(owner.playerColor);
        noStroke();
        ellipse(owner.cx, owner.cy, 250, 250);
        stroke(1);
      }
      tempHealth=owner.health;
    } else if (!freeze) cooldown++;
  }
  public @Override
    void reset() {
    cooldown=interval;
    //owner.freezeImmunity=false;
  }
}


class RandomPassive extends Ability {//---------------------------------------------------    RandomPassive   ---------------------------------

  RandomPassive() {
    super();
  } 
  public Ability randomize() {
    Ability rA=null;
    try {
      rA = passiveList[PApplet.parseInt(random(passiveList.length))].clone();
    }
    catch(CloneNotSupportedException e) {
      println("not cloned from Random Passive");
    }
    return rA;  // clone it
  }
}


class Projectile  implements Cloneable {
  PVector coord;
  PVector speed;
  int  size, damage, ally=-1;
  float x, y, vx, vy, angle, force;
  long deathTime, spawnTime;
  int projectileColor;
  boolean dead, deathAnimation, melee;
  int  playerIndex=-1, time;
  Player owner;
  Projectile( ) { // nothing
  }
  Projectile(Projectile _p ) { // copy
    this(_p.playerIndex, PApplet.parseInt(_p.x), PApplet.parseInt(_p.y), _p.size, _p.projectileColor, _p.time) ;
    this.spawnTime=_p.spawnTime;
    this.deathTime=_p.deathTime;
  }

  Projectile( int _x, int _y, int _size, int _color, int  _time) { // no playerIndex
    x= _x;
    y= _y;
    size=_size;
    projectileColor=_color;
    spawnTime=stampTime;
    deathTime=stampTime + _time;
    time=_time;
  }
  Projectile(int _playerIndex, int _x, int _y, int _size, int _color, int  _time) {
    this(_x, _y, _size, _color, _time);
    playerIndex=_playerIndex;
    ally=players.get(_playerIndex).ally;
  }
  Projectile(Player _owner, int _x, int _y, int _size, int _color, int  _time) {
    this(_x, _y, _size, _color, _time);
    owner=_owner;
    playerIndex=owner.index;
    ally=owner.ally;
  }
  public void update() {
  }
  public void display() {
  }
  public void revert() {
    if (reverse && stampTime<spawnTime) {
      projectiles.remove(this);
    } 
    if (reverse && stampTime>deathTime) {
      if (deathAnimation) {
        deathAnimation=false;
      }
    } else if (stampTime<deathTime) {
      dead=false;
    } else if (stampTime>deathTime) {
      if (!deathAnimation) {
        fizzle();
        deathAnimation=true;
        dead=true;
      }
    }
  }
  public void fizzle() { // timed out death
  }
  public void hit(Player enemy) {// collide death
  }

  public Projectile clone() {  
    try {
      return (Projectile)super.clone();
    }
    catch( CloneNotSupportedException e) {
      println(e+" 1");
      return null;
    }
  }

  public Player seek(int senseRange) {
    for (int sense = 0; sense < senseRange; sense++) {
      for ( Player p : players) {
        if (p!= owner && !p.dead && p.ally!=owner.ally) {
          if (dist(p.x, p.y, x, y)<sense*0.5f) {  
            return p;
          }
        }
      }
    }
    return owner;
  }

  public void resetDuration() {
    spawnTime=stampTime;
    deathTime=stampTime+time;
  }
}

class Ball extends Projectile implements Reflectable { //----------------------------------------- ball objects ----------------------------------------------------
  int speedX, speedY, dirX, dirY;
  int [] allies;
  int up, down, left, right;
  //float vx, vy;
  Ball( int _x, int _y, int _speedX, int _speedY, int _size, int _color) {
    super( _x, _y, _size, _color, 999999);
    projectileColor=_color;
    damage=1;
    coord= new PVector(_x, _y);
    speed= new PVector(_speedX, _speedY);
    vx=_speedX;
    vy=_speedY;
    angle=degrees( PVector.angleBetween(coord, speed));
  }
  /*void playerBounds() {
   if (!reverse) {
   for (int i=0; i<players.size (); i++) {
   if (coord.y-size*0.5+speedY<players.get(i).y+players.get(i).h+10+players.get(i).vy && coord.y+size*0.5+speedY>players.get(i).y-10+players.get(i).vy) {
   if (coord.x+size*0.5+speedX> players.get(i).x+20 && coord.x-size*0.5+speedX< players.get(i).x + players.get(i).w-20 ) {
   // speed.set( speed.x, speed.y*(-1));
   // coord.set( coord.x+speed.x, coord.y+speed.y);
   // y-=players.get(i).vy;
   }
   }
   if (coord.y-size*0.5+speedY<players.get(i).y+players.get(i).h-20+players.get(i).vy && coord.y+size*0.5+speedY>players.get(i).y+20+players.get(i).vy) {
   if (coord.x+size*0.5+speedX> players.get(i).x-10 && coord.x-size*0.5+speedX< players.get(i).x + players.get(i).w +10 ) {
   //  speed.set( speed.x*(-1), speed.y);
   //  coord.set( coord.x+speed.x+players.get(i).vx, coord.y+speed.y+players.get(i).vy);
   //  x-=players.get(i).vx;
   }
   }
   }
   }
   }*/
  public void checkBounds() {
    /*
    if (coord.y-size*0.5<0 ) { // walls
     speed.set( speed.x, speed.y*(-1));
     } else if (coord.y+size*0.5>height) {
     speed.set( speed.x, speed.y*(-1));
     }
     if (coord.x-size*0.5<0 ) {
     speed.set( speed.x*(-1), speed.y);
     } else if (coord.x+size*0.5>width ) {
     speed.set( speed.x*(-1), speed.y);
     }
     */
    if (y-size*0.5f<0 ) { // walls
      vy*=(-1);
    } else if (y+size*0.5f>height) {
      vy*=(-1);
    }
    if (x-size*0.5f<0 ) {
      vx*=(-1);
    } else if (x+size*0.5f>width ) {
      vx*=(-1);
    }
  }

  public void display() {
    if (!dead) { 
      strokeWeight(1);
      if (freeze) {
        stroke(100);
        fill(255);
      } else {
        stroke(projectileColor);
        fill(projectileColor);
      }
      //ellipse(coord.x, coord.y, size, size);
      // line(coord.x, coord.y, coord.x +(speed.x)*10, coord.y+(speed.y)*10);
      ellipse(x, y, size, size);
      if (debug) line(x, y, x +(vx)*10, y+(vy)*10);
    }
  }

  public void move() {
    //   s =(slow)?slowFactor:1;
    //      f =(fastForward)?speedFactor:1;
    if (stampTime%1==0) {
      if (!dead && !freeze) { 
        if (reverse) {
          //angle=degrees( PVector.angleBetween(speed, coord));
          //coord.set(coord.x-speed.x*timeBend, coord.y-speed.y*timeBend);
          x-=vx*timeBend;
          y-=vy*timeBend;
        } else {
          //coord.set(coord.x+speed.x*timeBend, coord.y+speed.y*timeBend);
          //angle=degrees( PVector.angleBetween(coord, speed));
          x+=vx*timeBend;
          y+=vy*timeBend;
        }
      }
    }
  }


  public void update() {
    move();
    checkBounds();
  }

  public @Override
    void revert() {
  }
  public @Override
    void hit(Player enemy) {
    // super.hit();
    enemy.hit(damage);
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(-5, 5), random(-5, 5), PApplet.parseInt(random(20)+5), 500, 255));
    }
    /* for (int i=0; i<1; i++) {
     particles.add(new Particle(int(x), int(y), random(-10, 10), random(-10, 10), int(random(30)+10), 500, projectileColor));
     }*/
    //w particles.add(new LineWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 10, 300, projectileColor));
  }

  @Override
    public void reflect(float _angle, Player _player) {
    //playerIndex=_player.index;
    //owner=_player;
    //projectileColor=owner.playerColor;
    //ally=owner.ally;

    angle=degrees(atan2(vy, vx));
    float diff=_angle;
    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;
    for (int i=0; i<3; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5, random(10)-5, PApplet.parseInt(random(20)+5), 800, 0));
    }
    if (owner!=null) { 
      owner.ally=_player.ally;
      owner=_player;
    }
    projectileColor=_player.playerColor;
    //particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*15;
    vy= sin(radians(angle))*15;
    x+= cos(radians(angle))*10;
    y+=sin(radians(angle))*10;
  }
}

class IceDagger extends Projectile implements Reflectable, Destroyable, Containable {//----------------------------------------- IceDagger objects ----------------------------------------------------
  PShape  sh, c ;
  Projectile parent;
  int smoke;
  IceDagger(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);

    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;

    /*for (int i=0; i<7; i++) {
     particles.add(new Particle(int(x), int(y), vx/(2-0.12*i), vy/(2-0.12*i), 10+i*4, _time, _projectileColor));
     }
     for (int i=0; i<2; i++) {
     particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
     }*/
    sh = createShape();
    c = createShape();
    sh.beginShape();
    sh.fill(255);
    sh.stroke(255, 50);
    sh.vertex(PApplet.parseInt (0), PApplet.parseInt (-size*0.5f) );
    sh.vertex(PApplet.parseInt (+size*2), PApplet.parseInt (0));
    sh.vertex(PApplet.parseInt (0), PApplet.parseInt (+size*0.5f));
    sh.vertex(PApplet.parseInt (-size), PApplet.parseInt (0));
    sh.endShape(CLOSE);

    c.beginShape();
    c.fill(projectileColor);
    c.stroke(projectileColor, 50);
    c.vertex(PApplet.parseInt (0), PApplet.parseInt (-size*.33f) );
    c.vertex(PApplet.parseInt (+size), PApplet.parseInt (0));
    c.vertex(PApplet.parseInt (0), PApplet.parseInt (+size*.33f));
    c.vertex(PApplet.parseInt (-size*0.5f), PApplet.parseInt (0));
    c.endShape(CLOSE);
  }
  public void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        if (smoke%1==0)particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), vx*0.2f, vy*0.2f, PApplet.parseInt(random(10)+5), 900, projectileColor));
        smoke++;
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
    }
  }
  public void display() {
    if (!dead) { 
      // rect(x-(size*.5), y-(size*.5), (size), (size));
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      // rect(-(size*.5), -(size*.5), (size), (size));
      shape(sh, sh.width*.5f, sh.height*.5f);
      shape(c, c.width*.5f, c.height*.5f);
      popMatrix();
    }
  }
  public @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<4; i++) {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5+vx, random(10)-5+vy, PApplet.parseInt(random(20)+5), 800, 255));
      }
    }
  }
  public @Override
    void hit(Player enemy) {
    // super.hit();
    enemy.hit(damage);
    enemy.ax*=.3f;
    enemy.ay*=.3f;
    enemy.vx*=.3f;
    enemy.vy*=.3f;
    deathTime=stampTime;   // dead on collision
    dead=true;
    for (int i=0; i<4; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(20)-10, random(20)-10, PApplet.parseInt(random(20)+5), 800, 255));
    }
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(40)-20, random(40)-20, PApplet.parseInt(random(30)+10), 800, projectileColor));
    }
    //particles.add(new Flash(200, 32, 255));  
    particles.add(new LineWave(PApplet.parseInt(enemy.cx), PApplet.parseInt(enemy.cy), 10, 300, projectileColor, angle));
  }
  public void reflect(float _angle, Player _player) {
    angle=_angle;
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;
    c = createShape();

    c.beginShape();
    c.fill(projectileColor);
    c.stroke(projectileColor, 50);
    c.vertex(PApplet.parseInt (0), PApplet.parseInt (-size*.33f) );
    c.vertex(PApplet.parseInt (+size), PApplet.parseInt (0));
    c.vertex(PApplet.parseInt (0), PApplet.parseInt (+size*.33f));
    c.vertex(PApplet.parseInt (-size*0.5f), PApplet.parseInt (0));
    c.endShape(CLOSE);

    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy));
    vy= sin(radians(angle))*(abs(vx)+abs(vy));
  }
  public void destroy(Projectile destroyerP) {
    dead=true;
    deathTime=stampTime;   // projectile is dead on collision
    for (int i=0; i<4; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(20)-10, random(20)-10, PApplet.parseInt(random(20)+5), 800, 255));
    }
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(40)-20, random(40)-20, PApplet.parseInt(random(30)+10), 800, projectileColor));
    }
    //particles.add(new Flash(200, 32, 255));  
    particles.add(new LineWave(PApplet.parseInt(x), PApplet.parseInt(y), 10, 300, projectileColor, angle+90));
  }
  public Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  public void unWrap() {
    resetDuration();
    x=parent.x;
    y=parent.y;
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    // vel.rotate(radians(parent.angle));
    vel.add(pVel);
    float deltaX = 0 - vel.x;
    float deltaY = 0 - vel.y;

    angle+= atan2(deltaY, deltaX); // In radians
    //angle=90;
    vx=vel.x;
    vy=vel.y;
  }
}

class ArchingIceDagger extends IceDagger {//----------------------------------------- IceDagger objects ----------------------------------------------------
  float startCurveAngle, angleCurve, currentAngle, transition, eVx, eVy, sVx, sVy;
  final int arch =24;
  ArchingIceDagger(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _angleCurve, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time*2, _angle, _vx, _vy, _damage);
    float totalVelocity= (abs(_vx)+abs(_vy));
    eVx=sin(radians(_angleCurve))*totalVelocity;
    eVy=-cos(radians(_angleCurve))*totalVelocity;
    sVx=_vx;
    sVy=_vy;
    angleCurve= _angleCurve;
    startCurveAngle=_angle;
  }
  public void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        angleCurve();
        if (transition>0)transition-=0.01f*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
        angle-=arch*timeBend;
      } else {
        if (smoke%2==0)particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), -vx*0.1f, -vy*0.1f, PApplet.parseInt(random(10)+5), 900, projectileColor));
        smoke++;
        angle+=arch*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
        if (transition<1)transition+=0.01f*timeBend;
        angleCurve();
      }
    }
  }
  public void display() {
    if (!dead) { 
      // rect(x-(size*.5), y-(size*.5), (size), (size));
      // fill(0);
      //  text("s: "+ angleCurve, x, y-100);
      //  text("e: "+ startCurveAngle, x, y-75);
      //  text("c: "+ currentAngle, x, y-50);
      pushMatrix();
      translate(x, y);

      rotate(radians(angle));

      // rect(-(size*.5), -(size*.5), (size), (size));
      shape(sh, sh.width*.5f, sh.height*0.5f);
      shape(c, c.width*.5f, c.height*0.5f);
      popMatrix();
    }
  }

  public void angleCurve() {
    vx=sVx*(1-transition) + eVx*transition;
    vy=sVy*(1-transition) + eVy*transition;
    /*
    float totalVelocity= (abs(vx)+abs(vy))/1.2;
     currentAngle= startCurveAngle*(1-transition) + angleCurve*transition;
     vx = sin(currentAngle)*totalVelocity;
     vy = cos(currentAngle)*totalVelocity;
     */
  }
}


class forceBall extends Projectile implements Reflectable { //----------------------------------------- forceBall objects ----------------------------------------------------
  //scaled object by velocity
  float vx, vy, v, ax, ay, angleV;
  //boolean charging;
  forceBall(Player _owner, int _x, int _y, float _v, int _size, int _projectileColor, int  _time, float _angle, float _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    angleV=10;
    damage=PApplet.parseInt(_damage);
    v=_v;
    force=_v;
    vx= cos(radians(angle))*_v;
    vy= sin(radians(angle))*_v;

    for (int i=0; i<8; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), vx/(2-0.12f*i), vy/(2-0.12f*i), 10+i*4, _time, _projectileColor));
    }
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5+vx*0.5f, random(10)-5+vy*0.5f, PApplet.parseInt(random(20)+5), 800, 255));
    }
  }
  public void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        //  opacity+=8*F;
        //if (charging) angle+=angleV*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        //  opacity-=8*F;
        // if (charging) angle-=angleV*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
    }
  }
  public void display() {
    if (!dead) { 
      // rect(x-(size*.5), y-(size*.5), (size), (size));
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      // rect(-(size*.5), -(size*.5), (size), (size));
      fill(255);
      strokeWeight(5);
      stroke(projectileColor);
      ellipse(0, 0, size+size*v*0.1f, size);
      popMatrix();
    }
  }
  public @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<4; i++) {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5+vx, random(10)-5+vy, PApplet.parseInt(random(20)+5), 800, 255));
      }
    }
  }
  public @Override
    void hit(Player enemy) {
    // super.hit();
    if (damage>100) particles.add(new TempSlow(700, 0.1f, 1.05f));
    if (damage>300) particles.add( new TempFreeze(500));
    enemy.hit(damage);
    deathTime=stampTime;   // projectile is dead on collision
    dead=true;
    for (int i=0; i<PApplet.parseInt (v*0.3f); i++) { // particles
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(-PApplet.parseInt(v*0.2f), PApplet.parseInt(v*0.2f)), random(-PApplet.parseInt(v*0.2f), PApplet.parseInt(v*0.2f)), PApplet.parseInt(random(5, 30)), 800, 255));
    }
    for (int i=0; i<PApplet.parseInt (v*0.4f); i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(-PApplet.parseInt(v*0.4f), PApplet.parseInt(v*0.4f)), random(-PApplet.parseInt(v*0.4f), PApplet.parseInt(v*0.4f)), PApplet.parseInt(random(10, 50)), 800, projectileColor));
    }
    particles.add(new Flash(PApplet.parseInt(v*4), 32, 255));  
    particles.add(new ShockWave(PApplet.parseInt(enemy.cx), PApplet.parseInt(enemy.cy), 20, 16, 200, projectileColor));
    particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(v*4), 16, PApplet.parseInt(v*4), projectileColor));
    particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt( v*2), 16, PApplet.parseInt(v*5), color(255, 0, 255)));
    shakeTimer+=PApplet.parseInt(force*0.5f);
  }

  public void reflect(float _angle, Player _player) {
    // angle=angle+180;
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;
    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy));
    vy= sin(radians(angle))*(abs(vx)+abs(vy));
  }
}
class RevolverBullet extends Projectile implements Reflectable, Destroyable { //----------------------------------------- forceBall objects ----------------------------------------------------
  //scaled object by velocity
  float  v, ax, ay, angleV, spray=30, halfSize;
  RevolverBullet(Player _owner, int _x, int _y, float _v, int _size, int _projectileColor, int  _time, float _angle, float _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    angleV=10;
    damage=PApplet.parseInt(_damage);
    v=_v;
    force=5;
    halfSize=size*.5f;
    vx= cos(radians(angle))*_v;
    vy= sin(radians(angle))*_v;
    /* for (int i=0; i<4; i++) {
     particles.add(new Particle(int(x), int(y), vx/(2-0.12*i), vy/(2-0.12*i), 10+i*4, _time, _projectileColor));
     }
     for (int i=0; i<2; i++) {
     particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
     }*/
  }
  public void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
    }
  }
  public void display() {
    if (!dead) { 
      // rect(x-(size*.5), y-(size*.5), (size), (size));
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      // rect(-(size*.5), -(size*.5), (size), (size));
      fill(255);
      strokeWeight(5);
      stroke(projectileColor);
      ellipse(0, 0, size*v*0.2f, halfSize);
      popMatrix();
    }
  }
  public @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<4; i++) {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5+vx, random(10)-5+vy, PApplet.parseInt(random(20)+5), 800, 255));
      }
    }
  }
  public @Override
    void hit(Player enemy) {
    // super.hit();
    enemy.hit(damage);
    deathTime=stampTime;   // projectile is dead on collision
    dead=true;
    for (int i=0; i<12; i++) {
      float sprayAngle=random(-spray, spray)+angle;
      float sprayVelocity=random(v*0.75f);
      particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    }

    //particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle))*random(10), sin(radians(angle))*random(10), 6, angle, projectileColor));
    enemy.pushForce(damage*.5f, angle);
    particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(v*4), 22, 100, projectileColor));
    shakeTimer+=PApplet.parseInt(force*0.2f);
  }

  public void reflect(float _angle, Player _player) {
    // angle=angle+180;
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;
    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy));
    vy= sin(radians(angle))*(abs(vx)+abs(vy));
  }
  public void destroy(Projectile destroyerP) {

    deathTime=stampTime;   // projectile is dead on collision
    dead=true;
    for (int i=0; i<12; i++) {
      float sprayAngle=random(-spray, spray)+angle+180;
      float sprayVelocity=random(v*0.2f);
      particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, destroyerP.owner.playerColor));
    }
    if (destroyerP.melee) destroyerP.owner.pushForce(damage*.5f, angle);
    particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(v*4), 22, 100, destroyerP.owner.playerColor));
    shakeTimer+=PApplet.parseInt(force*0.1f);
  }
}
class Blast extends Projectile implements Containable { //----------------------------------------- forceBall objects ----------------------------------------------------
  //scaled object by velocity
  Projectile parent;
  float  v, ax, ay, angleV, spray=30, opacity, speed;
  Blast(Player _owner, int _x, int _y, float _v, int _size, int _projectileColor, int  _time, float _angle, float _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    angleV=10;
    damage=PApplet.parseInt(_damage);
    v=_v;
    force=5;
    opacity=255;
    speed=20;
    vx= cos(radians(angle))*_v;
    vy= sin(radians(angle))*_v;
  }
  Blast(Player _owner, int _x, int _y, float _v, int _size, int _projectileColor, int  _time, float _angle, float _damage, float _speed) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    angleV=10;
    damage=PApplet.parseInt(_damage);
    v=_v;
    force=5;
    opacity=255;
    speed=_speed;
    vx= cos(radians(angle))*_v;
    vy= sin(radians(angle))*_v;
  }
  public void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        opacity+=speed*timeBend;
        //if (charging) angle+=angleV*timeBend;
        angleV+=speed*timeBend;
        size-=speed*timeBend*0.75f;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        opacity-=speed*timeBend;

        angleV-=speed*timeBend;
        size+=speed*timeBend*0.75f;
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
    }
  }
  public void display() {
    if (!dead) { 
      // rect(x-(size*.5), y-(size*.5), (size), (size));
      pushMatrix();
      translate(x, y);
      rotate(radians(angleV));
      // rect(-(size*.5), -(size*.5), (size), (size));
      fill(255, opacity);
      strokeWeight(10);
      stroke(projectileColor, opacity);
      rect(0-size*0.5f, 0-size*0.5f, size, size);
      popMatrix();
    }
  }
  public @Override
    void fizzle() {    // when fizzle
  }
  public @Override
    void hit(Player enemy) {
    // super.hit();
    enemy.hit(damage);
    enemy.pushForce(v*0.1f, angle);
    //deathTime=stampTime;   // projectile is dead on collision
    //dead=true;
    /*for (int i=0; i<int (v*0.4); i++) { // particles
     particles.add(new Particle(int(x), int(y), random(-int(v*0.2), int(v*0.2)), random(-int(v*0.2), int(v*0.2)), int(random(5, 30)), 800, 255));
     }*/
    // for (int i=0; i<2; i++) {
    float sprayAngle=random(-spray, spray)+angle;
    float sprayVelocity=random(v*0.75f);
    particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    //  }
    //enemy.pushForce(0.6, angle);
    //particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle))*random(10), sin(radians(angle))*random(10), 6, angle, projectileColor));

    //particles.add(new ShockWave(int(x), int(y), int(v*4), 22, 100, projectileColor));
    // shakeTimer=int(force*0.2);
  }

  public Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  public void unWrap() {
    resetDuration();
    float tempX=parent.x, tempY=parent.y;
    x+=parent.x;
    y+=parent.y;
    //PVector vel=new PVector(vx, vy);
    //PVector pVel=new PVector(parent.vx, parent.vy);
    // vel.rotate(radians(parent.angle));
    // vel.add(pVel);
    // float deltaX = 0 - vx;
    // float deltaY = 0 - vy;

    //angle+= atan2(deltaY, deltaX); // In radians
    //angle=90;
    //vx=vel.x;
    //vy=vel.y;
  }
}
class ChargeLaser extends Projectile implements Containable { //----------------------------------------- forceBall objects ----------------------------------------------------
  long chargeTime;
  final long MaxChargeTime=500;
  final int laserLength=2500;
  float maxLaserWidth, laserWidth, laserChange, offsetAngle, angleV;
  boolean follow;
  Projectile parent;
  /* ChargeLaser( int _playerIndex, int _x, int _y, int _maxLaserWidth, color _projectileColor, int  _time, float _angle, float _damage  ) {
   super(_playerIndex, _x, _y, 1, _projectileColor, _time);
   damage= int(_damage);
   maxLaserWidth=_maxLaserWidth;
   angle=_angle;
   owner=players.get(_playerIndex);
   }*/
  ChargeLaser( Player _owner, int _x, int _y, int _maxLaserWidth, int _projectileColor, int  _time, float _angle, float _angleV, float _damage, boolean _follow ) {
    super(_owner, _x, _y, 1, _projectileColor, _time);
    follow=_follow;
    damage= PApplet.parseInt(_damage);
    maxLaserWidth=_maxLaserWidth;
    angle=_angle;
    angleV=_angleV;
  }
  ChargeLaser( Player _owner, int _x, int _y, int _maxLaserWidth, int _projectileColor, int  _time, float _angle, float _angleV, float _damage  ) {
    super(_owner, _x, _y, 1, _projectileColor, _time);
    damage= PApplet.parseInt(_damage);
    maxLaserWidth=_maxLaserWidth;
    angle=_angle;
    angleV=_angleV;
  }


  public void display() {
    if (!dead ) { 

      strokeWeight(PApplet.parseInt(laserWidth));
      stroke(projectileColor);
      line(PApplet.parseInt(x), PApplet.parseInt(y), cos(radians(angle))*laserLength+PApplet.parseInt(x), sin(radians(angle))*laserLength+PApplet.parseInt(y));
      //arc(int(x),int(y),1,1,radians(angle+90),radians(angle+275));
      ellipse(x, y, PApplet.parseInt(laserWidth*0.1f), PApplet.parseInt(laserWidth*0.1f));

      stroke(255);
      strokeWeight(PApplet.parseInt(laserWidth*0.6f));
      ellipse(x, y, PApplet.parseInt(laserWidth*0.1f), PApplet.parseInt(laserWidth*0.1f));

      //arc(int(x),int(y),1,1,radians(angle+90),radians(angle-275));
      line(PApplet.parseInt(x), PApplet.parseInt(y), cos(radians(angle))*laserLength+PApplet.parseInt(x), sin(radians(angle))*laserLength+PApplet.parseInt(y));
    }
  }
  public void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        laserChange-=2*timeBend;
        laserWidth= sin(radians(laserChange))*maxLaserWidth;
        angle-= angleV;

        if (follow) {
          angle=owner.angle;
          x=owner.cx;
          y=owner.cy;
        }
      } else {
        laserChange+=2*timeBend;
        laserWidth= sin(radians(laserChange))*maxLaserWidth;
        angle+= angleV;
        if (follow) { 
          angle=owner.angle;
          x=owner.cx;
          y=owner.cy;
        }
        if (laserWidth<0) {
          fizzle(); 
          dead=true;
          deathTime=stampTime;
        }
        owner.pushForce(-0.2f, angle);
        shakeTimer=PApplet.parseInt(laserWidth*0.1f);
        particles.add(new  Gradient(1000, PApplet.parseInt(x+size*0.5f +cos(radians(angle))*owner.radius), PApplet.parseInt(y+size*0.5f+sin(radians(angle))*owner.radius), 0, 0, PApplet.parseInt(laserWidth), 4, angle, projectileColor));

        // for (int i= 0; players.size () > i; i++)
        //  if (playerIndex!=i  && !players.get(i).dead && players.get(i).ally != owner.ally ) lineVsCircleCollision(x, y, cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y), players.get(i));
        for (Player p : players)
          if (!p.dead && p.ally != owner.ally ) lineVsCircleCollision(x, y, cos(radians(angle))*laserLength+PApplet.parseInt(x), sin(radians(angle))*laserLength+PApplet.parseInt(y), p);
      }
    }
  }
  public void lineVsCircleCollision(float x, float y, float x2, float y2, Player enemy) {
    float cx= enemy.cx, cy=enemy.cy, cr= enemy.w*0.5f;
    // float segV = dist(x2, y2, x, y);
    // float segVAngle = degrees(atan2((y2-y), (x2-x)));
    // float segC = dist(cx, cy, x, y);
    // float segCAngle = degrees(atan2((cy-y),(c2-x)));
    //  stroke(0);
    // line(x, y, cx, cy);
    //   line(x+cos(radians(segVAngle))*segC, y+sin(radians(segVAngle))*segC, cx, cy);
    //   println(segV+" angle: "+segVAngle+ "      circle:"+ segC);


    float rx, ry;
    float dx = x2 - x;
    float dy = y2 - y;
    float d = sqrt( dx*dx + dy*dy ); 

    //float a = atan2( y2 - y1, x2 - x1 ); 
    //float ca = cos( a ); 
    //float sa = sin( a ); 
    float ca = dx/d;
    float sa = dy/d;
    float mX = (-x+cx)*ca + (-y+cy)*sa; 
    //float mY = (-y+cy)*ca + ( x-cx)*sa;
    if ( mX <= 0 ) {
      rx = x; 
      ry = y;
    } else if ( mX >= d ) {
      rx = x2; 
      ry = y2;
    } else {
      rx = x + mX*ca; 
      ry = y + mX*sa;
    }

    //  stroke(255, 255, 56);
    // line(rx, ry, cx, cy);
    if (dist(rx, ry, cx, cy)<laserWidth*0.5f+cr) {
      hit(enemy);
    }
  }
  public void hit(Player enemy) {
    //  particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    enemy.hit(damage);
    enemy.pushForce(0.6f, angle);
    particles.add(new Spark( 1000, PApplet.parseInt(enemy.x+random(enemy.w)), PApplet.parseInt(enemy.y+random(enemy.w)), cos(radians(angle))*random(10), sin(radians(angle))*random(10), 6, angle, projectileColor));
    particles.add( new  Particle(PApplet.parseInt(enemy.cx), PApplet.parseInt(enemy.cy), cos(radians(angle))*12, sin(radians(angle))*12, 120, 100, color(255, 0, 255)));
  }

  public @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<10; i++) {
        int temp= PApplet.parseInt(random(laserLength));
        int tempVel= PApplet.parseInt(random(12));
        particles.add(new Spark( 1200, PApplet.parseInt(x+cos(radians(angle))*temp), PApplet.parseInt(y+sin(radians(angle))*temp), cos(radians(angle))*tempVel, sin(radians(angle))*tempVel, 4, angle, projectileColor));
      }
    }
  }
  public Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  public void unWrap() {
    resetDuration();
    x+=parent.x;
    y+=parent.y;
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    vel.rotate(parent.angle);
    vel.add(pVel);
    vx=vel.x;
    vy=vel.y;
  }
}

class SniperBullet extends ChargeLaser { //----------------------------------------- SniperBullet objects ----------------------------------------------------

  /*
  SniperBullet( int _playerIndex, int _x, int _y, int _maxLaserWidth, color _projectileColor, int  _time, float _angle, float _damage  ) {
   super( _playerIndex, _x, _y, _maxLaserWidth, _projectileColor, _time, _angle, _damage  );
   particles.add(new Flash(50, 50, BLACK));
   particles.add(new ShockWave(int(x), int(y), int(size*0.25),40, 80, WHITE));
   }*/
  SniperBullet( Player _owner, int _x, int _y, int _maxLaserWidth, int _projectileColor, int  _time, float _angle, float _damage  ) {
    super( _owner, _x, _y, _maxLaserWidth, _projectileColor, _time, _angle, 0, _damage  );
    particles.add(new Flash(50, 50, BLACK));
    particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(size*0.25f), 40, 80, WHITE));
    force=3;
    //particles.add( new TempFreeze(100));
  }


  public void display() {
    if (!dead ) { 
      //println(damage);
      strokeWeight(PApplet.parseInt(laserWidth+1));
      stroke(projectileColor);
      line(PApplet.parseInt(x), PApplet.parseInt(y), cos(radians(angle))*laserLength+PApplet.parseInt(x), sin(radians(angle))*laserLength+PApplet.parseInt(y));
      //arc(int(x),int(y),1,1,radians(angle+90),radians(angle+275));
      ellipse(x, y, PApplet.parseInt(laserWidth*0.1f), PApplet.parseInt(laserWidth*0.1f));

      stroke(255);
      strokeWeight(PApplet.parseInt(laserWidth*0.6f));
      ellipse(x, y, PApplet.parseInt(laserWidth*0.1f), PApplet.parseInt(laserWidth*0.1f));

      //arc(int(x),int(y),1,1,radians(angle+90),radians(angle-275));
      line(PApplet.parseInt(x), PApplet.parseInt(y), cos(radians(angle))*laserLength+PApplet.parseInt(x), sin(radians(angle))*laserLength+PApplet.parseInt(y));
    }
  }
  public void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        laserChange-=2*timeBend;
        laserWidth= sin(radians(laserChange))*maxLaserWidth;
        // x=owner.x+50;
        // y=owner.y+50;
      } else {
        laserChange+=2*timeBend;
        laserWidth= sin(radians(laserChange))*maxLaserWidth;
        //x=owner.x+50;
        // y=owner.y+50;
        //   particles.add( new  Particle(int(x+random(-laserWidth*1.5,laserWidth*1.5)-50), int(y+random(-laserWidth*1.5,laserWidth*1.5)-50), int( cos(radians(angle))*60), int(sin(radians(angle))*60), int(random(-laserWidth*0.5,laserWidth*0.5)), 400, projectileColor));
        //particles.add( new  Particle(int(x), int(y), 0, 0, int(125), 0, color(255, 0, 255)));
        if (laserWidth<0) {
          fizzle(); 
          dead=true;
          deathTime=stampTime;
        }
        owner.pushForce(-0.2f, angle);
        //shakeTimer=int(laserWidth*0.1);
        particles.add(new  Gradient(1000, PApplet.parseInt(x+size*0.5f +cos(radians(angle))*owner.radius), PApplet.parseInt(y+size*0.5f+sin(radians(angle))*owner.radius), 0, 0, 40, 6, angle, projectileColor));

        for (int i= 0; players.size () > i; i++)
          if (playerIndex!=i  && !players.get(i).dead && players.get(i).ally != owner.ally ) lineVsCircleCollision(x, y, cos(radians(angle))*laserLength+PApplet.parseInt(x), sin(radians(angle))*laserLength+PApplet.parseInt(y), players.get(i));
      }
    }
  }
  public @Override
    void hit(Player enemy) {
    enemy.hit(damage);
    if (damage>100) {
      particles.add( new TempFreeze(100));
      particles.add( new TempSlow(25, 0.1f, 1.00f));
    }
    //  particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));

    enemy.pushForce(3, angle);
    particles.add(new Flash(100, 24, BLACK));
    particles.add(new LineWave(PApplet.parseInt(enemy.cx), PApplet.parseInt(enemy.cy), 10, 200, projectileColor, angle+90));
    particles.add(new Spark( 1000, PApplet.parseInt(enemy.x+random(enemy.w)), PApplet.parseInt(enemy.y+random(enemy.w)), cos(radians(angle))*random(10), sin(radians(angle))*random(10), 6, angle, projectileColor));

    shakeTimer+=damage*0.3f;    
    particles.add( new  Particle(PApplet.parseInt(enemy.cx), PApplet.parseInt(enemy.cy), cos(radians(angle))*36, sin(radians(angle))*36, 100, 120, color(255, 0, 255)));
    particles.add( new  Particle(PApplet.parseInt(enemy.cx), PApplet.parseInt(enemy.cy), cos(radians(angle))*24, sin(radians(angle))*24, 200, 120, color(255, 0, 255)));
    particles.add( new  Particle(PApplet.parseInt(enemy.cx), PApplet.parseInt(enemy.cy), cos(radians(angle))*12, sin(radians(angle))*12, 300, 120, color(255, 0, 255)));
  }
}
class Heal extends Projectile implements Containable {//----------------------------------------- Heal objects ----------------------------------------------------

  float  friction=0.95f;
  long timer;
  int blastForce=40, healRadius=200, flick, interval=300;
  boolean friendlyFire;
  Projectile parent;
  Heal(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _heal, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_heal;
    healRadius=_size;
    vx= _vx;
    vy= _vy;
    friendlyFire=_friendlyFire;
    /* for (int i=0; i<2; i++) {
     particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
     }*/
  }

  public void update() {
    if (!dead && !freeze) { 
      flick=PApplet.parseInt(random(255));
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
        angle-=0.5f*timeBend;
      } else {
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
        angle+=0.5f*timeBend;
        if (timer+interval<stampTime) {
          timer=stampTime;
          hitPlayersInRadius(PApplet.parseInt(healRadius*.5f), friendlyFire);
        }
      }
    }
  }

  public void display() {
    if (!dead) { 
      strokeWeight(PApplet.parseInt(sin(radians(angle*30))*10+10));
      // stroke((friendlyFire)? BLACK:color(owner.playerColor));
      // fill((friendlyFire)? BLACK:color(owner.playerColor));
      //ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      //noFill();
      // stroke(flick);
      stroke(owner.playerColor);
      fill(owner.playerColor, sin(radians(angle*4))*100+100);
      ellipse(x, y, size, size);
      /*if ((deathTime-stampTime)<=100)size=400;
       else size=50;*/
    }
  }

  public float calcAngleFromBlastZone(float x, float y, float px, float py) {
    double deltaY = py - y;
    double deltaX = px - x;
    return (float)Math.atan2(deltaY, deltaX) * 180 / PI;
  }

  public void hitPlayersInRadius(int range, boolean _friendlyFire) {
    if (!freeze &&!reverse) { 

      for (Player p : players) { 
        if ( !p.dead && (p.ally !=owner.ally || _friendlyFire)) { //players.get(i).index!= playerIndex && 
          if (dist(x, y, p.cx, p.cy)<range) {
            p.heal(damage);
            for (int i=0; i<3; i++)particles.add( new  Particle(PApplet.parseInt(p.cx+cos(radians(random(360)))*random(100)), PApplet.parseInt(p.cy+sin(radians(random(360)))*random(100)), 0, 0, PApplet.parseInt(random(50)), 1000, WHITE));

            particles.add(new ShockWave(PApplet.parseInt(p.cx), PApplet.parseInt(p.cy), PApplet.parseInt(healRadius*0.5f), 40, 40, p.playerColor));
          }
        }
      }
    }
  }

  /*
  @Override
   void fizzle() {    // when fizzle
   if ( !dead) {         
   for (int i=0; i<5; i++) {
   particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
   }
   
   particles.add(new ShockWave(int(x), int(y), int(healRadius*0.5), 16, 200, WHITE));
   particles.add(new ShockWave(int(x), int(y), int(healRadius*0.4), 32, 150, (friendlyFire)? BLACK:color(owner.playerColor)));
   particles.add(new Flash(200, 12, WHITE));
   hitPlayersInRadius(healRadius, friendlyFire);
   // shakeTimer+=damage*.2;
   }
   }
   
   public void reflect(float _angle, Player _player) {
   angle=_angle;
   playerIndex=_player.index;
   owner=_player;
   projectileColor=owner.playerColor;
   ally=owner.ally;
   
   particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
   
   float diff=_angle;
   
   angle-=diff;
   // angle=angle%360;
   
   angle=-angle;
   angle+=diff;
   
   particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
   vx= cos(radians(angle))*(abs(vx)+abs(vy));
   vy= sin(radians(angle))*(abs(vx)+abs(vy));
   }*/
  public Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  public void unWrap() {
    resetDuration();
    x+=parent.x;
    y+=parent.y;
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    vel.rotate(parent.angle);
    vel.add(pVel);
    vx=vel.x;
    vy=vel.y;
  }
}
class Bomb extends Projectile implements Reflectable, Containable {//----------------------------------------- Bomb objects ----------------------------------------------------

  float  friction=0.95f;
  int blastForce=40, blastRadius=200, flick;
  boolean friendlyFire;
  Projectile parent;
  Bomb(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;
    friendlyFire=_friendlyFire;
    /*  for (int i=0; i<2; i++) {
     particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, WHITE));
     }*/
  }

  public void update() {
    if (!dead && !freeze) { 
      flick=PApplet.parseInt(random(255));
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
      } else {
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
      }
    }
  }

  public void display() {
    if (!dead) { 
      strokeWeight(5);
      stroke((friendlyFire)? BLACK:color(owner.playerColor));
      fill((friendlyFire)? BLACK:color(owner.playerColor));
      ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      noFill();
      stroke(flick);
      ellipse(x, y, size, size);
      /*if ((deathTime-stampTime)<=100)size=400;
       else size=50;*/
    }
  }

  public float calcAngleFromBlastZone(float x, float y, float px, float py) {
    double deltaY = py - y;
    double deltaX = px - x;
    return (float)Math.atan2(deltaY, deltaX) * 180 / PI;
  }

  public void hitPlayersInRadius(int range, boolean _friendlyFire) {
    if (!freeze &&!reverse) { 

      for (Player p : players) { 
        if ( !p.dead && (p.ally !=owner.ally || _friendlyFire)) { //players.get(i).index!= playerIndex && 
          if (dist(x, y, p.cx, p.cy)<range) {
            p.hit(damage);
            p.pushForce(blastForce, calcAngleFromBlastZone(x, y, p.cx, p.cy));
          }
        }
      }
    }
  }


  public @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<5; i++) {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(-80, 80), random(-80, 80), PApplet.parseInt(random(30)+10), 800, 255));
      }

      //   particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.5), 16, 200, WHITE));
      //   particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 32, 150, (friendlyFire)? BLACK:color(owner.playerColor)));
      particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(blastRadius*1), 16, 200, WHITE));
      particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(blastRadius*0.8f), 32, 150, (friendlyFire)? BLACK:color(owner.playerColor)));
      particles.add(new Flash(200, 12, WHITE));
      hitPlayersInRadius(blastRadius, friendlyFire);
      shakeTimer+=damage*.2f;
    }
  }

  public void reflect(float _angle, Player _player) {
    angle=_angle;
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;

    particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));

    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy));
    vy= sin(radians(angle))*(abs(vx)+abs(vy));
  }
  public Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  public void unWrap() {
    resetDuration();
    x+=parent.x;
    y+=parent.y;
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    vel.rotate(parent.angle);
    vel.add(pVel);
    vx=vel.x;
    vy=vel.y;
  }
}



class DetonateBomb extends Bomb {//----------------------------------------- Bomb objects ----------------------------------------------------

  float friction=0.95f;
  int blastForce=20, blastRadius=160;
  long originalDeathTime;
  DetonateBomb(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    originalDeathTime=deathTime;
  }
  public void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        if (deathTime>stampTime)deathTime=originalDeathTime; // resetDeathTime if detonated
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
      } else {
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
      }
    }
  }
  public void display() {
    if (!dead) { 
      strokeWeight(5);
      stroke(owner.playerColor, 15);
      fill(owner.playerColor, 15);
      ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      noFill();
      stroke(owner.playerColor, 15);
      ellipse(x, y, size, size);
      if ((deathTime-stampTime)<=100)size=400;
      else size=50;
    }
  }
  public @Override
    float calcAngleFromBlastZone(float x, float y, float px, float py) {
    double deltaY = py - y;
    double deltaX = px - x;
    return (float)Math.atan2(deltaY, deltaX) * 180 / PI;
  }
  public @Override
  /*void hitPlayersInRadius(int range, boolean _friendlyFire) {
   if (!freeze &&!reverse) { 
   for (int i=0; i<players.size(); i++) { 
   if (!players.get(i).dead &&(players.get(i).index!= playerIndex || _friendlyFire )) {
   if (dist(x, y, players.get(i).x+players.get(i).w*0.5, players.get(i).y+players.get(i).h*0.5)<range) {
   particles.add(new TempSlow(1000, 0.05, 1.05));
   players.get(i).hit(damage);
   players.get(i).pushForce(blastForce, calcAngleFromBlastZone(x, y, players.get(i).x+players.get(i).w*0.5, players.get(i).y+players.get(i).h*0.5));
   }
   }
   }
   }
   }*/

    void hitPlayersInRadius(int range, boolean _friendlyFire) {
    if (!freeze &&!reverse) {
      for (Player p : players) { 
        if ( !p.dead && (p.ally !=owner.ally || _friendlyFire)) { //players.get(i).index!= playerIndex && 
          if (dist(x, y, p.cx, p.cy)<range) {
            particles.add(new TempSlow(1000, 0.05f, 1.05f));
            p.hit(damage);
            p.pushForce(blastForce, calcAngleFromBlastZone(x, y, p.cx, p.cy));
          }
        }
      }
    }
  }

  public void detonate() {
    dead=true;
    fizzle();
  }

  public @Override
    void fizzle() {    // when fizzle
    if ( !dead) {    
      for (int i=0; i<360; i+=30) {
        Projectile p= new Needle(owner, PApplet.parseInt(x+cos(radians(i+15))*250), PApplet.parseInt(y+sin(radians(i+15))*250), 60, BLACK, 600, i+195, -cos(radians(i+15))*35, -sin(radians(i+15))*35, 25);
        p.ally=-1;
        projectiles.add(p);
        projectiles.add( new Needle(owner, PApplet.parseInt(x+cos(radians(i))*200), PApplet.parseInt(y+sin(radians(i))*200), 60, owner.playerColor, 600, i+180, -cos(radians(i))*20, -sin(radians(i))*20, 10));
      }
      for (int i=0; i<8; i++) {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(-80, 80), random(-80, 80), PApplet.parseInt(random(30)+10), 800, 255));
      }
      particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(blastRadius*0.5f), 16, 175, owner.playerColor));
      particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(blastRadius), 16, 1000, BLACK));
      //particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 125, owner.playerColor));
      particles.add(new Flash(200, 12, WHITE));
      hitPlayersInRadius(blastRadius, friendlyFire);
      shakeTimer+=20;
    }
  }
}

class Mine extends Bomb {//----------------------------------------- Mine objects ----------------------------------------------------
  int vAngle= 6;
  int freezeColor;
  Mine(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    ally=-1;
    owner=_owner;
    //  angle=_angle;
    playerIndex=-1;
    //  owner=_player;
    // projectileColor=owner.playerColor;
    // ally=owner.ally;
  }

  public @Override
    void update() {
    super.update();
    if (!dead && !freeze) {
      freezeColor=color(random(255));
      if (reverse) {
        angle-=vAngle*timeBend;
      } else {  
        angle+=vAngle*timeBend;
      }
    }
  }


  public @Override
    void display() {
    if (!dead) { 
      pushMatrix();
      translate(x, y);
      noFill();
      strokeWeight(5);
      stroke(freezeColor);
      if (spawnTime+1000<stampTime) rect(-(size*.5f), -(size*.5f), (size), (size));
      rotate(radians(angle));
      stroke((friendlyFire)? BLACK:color(owner.playerColor));
      rect(-(size*.5f), -(size*.5f), (size), (size));
      popMatrix();
    }
  }

  public @Override

    void hit(Player enemy) {
    // super.hit();
    // enemy.hit(damage);
    if (spawnTime+1000<stampTime) {
      fizzle();
      particles.add(new TempSlow(100, 0.15f, 1.05f));
      deathTime=stampTime;   // projectile is dead on collision
      dead=true;
    }
  }
  public void reflect(float _angle, Player _player) {
    owner=_player;
  }
}
class Rocket extends Bomb implements Reflectable, Destroyable, Container {//----------------------------------------- Bomb objects ----------------------------------------------------

  float timedScale;
  Containable payload[];
  Rocket(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5+vx*0.5f, random(10)-5+vy*0.5f, PApplet.parseInt(random(20)+5), 800, 255));
    }
  }

  public void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
      } else {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), 0, 0, PApplet.parseInt(random(25)+8), 800, 255));
        timedScale =size-(size*(deathTime-stampTime)/time);
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
      }
    }
  }

  public void display() {
    if (!dead) { 
      strokeWeight(5);
      stroke((friendlyFire)? BLACK:color(owner.playerColor));
      fill((friendlyFire)? BLACK:color(owner.playerColor));
      //ellipse(x, y, (, (size*(deathTime-stampTime)/time)-size );
      triangle(x+cos(radians(angle-140))*timedScale, y+sin(radians(angle-140))*timedScale, x+cos(radians(angle))*timedScale, y+sin(radians(angle))*timedScale, x+cos(radians(angle+140))*timedScale, y+sin(radians(angle+140))*timedScale  );
      noFill();
      triangle(x+cos(radians(angle-140))*size, y+sin(radians(angle-140))*size, x+cos(radians(angle))*size, y+sin(radians(angle))*size, x+cos(radians(angle+140))*size, y+sin(radians(angle+140))*size  );
      //stroke(random(255));
      // ellipse(x, y, size, size);
    }
  }


  public @Override
    void hit(Player enemy) {    // when hit
    super.hit(enemy);
    particles.add( new TempSlow(20, 0.08f, 1.05f));

    // fizzle();
    deathTime=stampTime;   // projectile is dead on collision
    dead=true;
  }
  public @Override
    void fizzle() {    // when fizzle
    //if ( !dead) {         
    payLoad();
    // }
  }
  public void payLoad() {
    for (int i=0; i<8; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(-80, 80), random(-80, 80), PApplet.parseInt(random(30)+10), 800, 255));
    }
    /* for (int i=0; i<360; i+=360/6) {
     projectiles.add( new Bomb(owner, int( x), int(y), 25, owner.playerColor, 400, owner.angle+i, cos(radians(owner.angle+i))*10+vx, sin(radians(owner.angle+i))*10+vy, damage, false));
     }*/

    if (payload!=null) {
      for (Containable p : payload) {
        if (p!=null) {
          if (p instanceof Particle )particles.add((Particle)p);
          if (p instanceof Player )players.add((Player)p);
          if (p instanceof Projectile ) projectiles.add((Projectile)p);
          p.unWrap();
        }
      }
    } else {
    }
    /* fill((friendlyFire)? BLACK:color(owner.playerColor));
     ellipse(x, y, size*5, size*5);
     particles.add(new ShockWave(int(x+vx), int(y+vy), int(blastRadius*0.5), 20, 220, WHITE));
     particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 18, 150, (friendlyFire)? BLACK:color(owner.playerColor)));
     particles.add(new Flash(200, 12, WHITE));
     hitPlayersInRadius(blastRadius, friendlyFire);
     shakeTimer+=15;*/
  }
  public void reflect(float _angle, Player _player) {
    angle=_angle;
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;

    particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));

    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff+90;

    particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy));
    vy= sin(radians(angle))*(abs(vx)+abs(vy));
  }

  public void destroy(Projectile destroyerP) {
    // fizzle();
    deathTime=stampTime;   // projectile is dead on collision
    dead=true;
    //payLoad();
  }

  public Container contains(Containable[] _payload) {
    payload=_payload;
    return this;
  }
}

class Missle extends Rocket implements Reflectable {//----------------------------------------- Bomb objects ----------------------------------------------------
  int angleSpeed=13;
  Player target;
  Missle(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5+vx*0.5f, random(10)-5+vy*0.5f, PApplet.parseInt(random(20)+5), 800, 255));
    }
    friction=0.9f;
  }
  public @Override
    void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction*timeBend;
        vy/=friction*timeBend;
      } else {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), 0, 0, PApplet.parseInt(random(size*.5f)+5), 800, owner.playerColor));


        //angle+=sin(radians(count))*10;
        // count+=10;
        timedScale =size-(size*(deathTime-stampTime)/time);
        x+=(vx+cos(radians(angle))*angleSpeed)*timeBend;
        y+=(vy+sin(radians(angle))*angleSpeed)*timeBend;

        target= seek(1200);
        if (target!=owner) { 
          float tx=target.cx, ty=target.cy, keyAngle=(atan2(ty-y, tx-x) * 180 / PI);
          keyAngle+= 360; 
          angle+= 360; 
          keyAngle= keyAngle % 360; 
          angle = angle % 360; 


          float relativeAngleToTarget = keyAngle - angle;
          //println(relativeAngleToTarget+"more "+keyAngle+" : " +angle);

          if (relativeAngleToTarget > 180)
            relativeAngleToTarget -= 360;
          else if (relativeAngleToTarget < -180)
            relativeAngleToTarget += 360;
          angle += relativeAngleToTarget * 0.15f;
          //stroke(255);
          //line(x, y, tx, ty);
          targetHommingVarning(target);
        }
        //vx+=;
        //vy+=sin(radians(angle))*10;
        //vx=constrain(vx,-10,10);
        //vy=constrain(vy,-10,10);
        vx*=1-friction*timeBend;
        vy*=1-friction*timeBend;
      }
    }
  }
  @Override
    public void payLoad() {
    for (int i=0; i<4; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(-80, 80), random(-80, 80), PApplet.parseInt(random(30)+10), 800, 255));
    }
    /*for (int i=0; i<360; i+=360/6) {
     projectiles.add( new Bomb(owner, int( x), int(y), 25, owner.playerColor, 400, owner.angle+i, cos(radians(owner.angle+i))*10+vx, sin(radians(owner.angle+i))*10+vy, damage, false));
     }*/
    fill((friendlyFire)? BLACK:color(owner.playerColor));
    ellipse(x, y, size*4, size*4);
    particles.add(new ShockWave(PApplet.parseInt(x+vx), PApplet.parseInt(y+vy), PApplet.parseInt(blastRadius*0.5f), 20, 220, WHITE));
    particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(blastRadius*0.4f), 18, 150, (friendlyFire)? BLACK:color(owner.playerColor)));
    particles.add(new Flash(200, 12, WHITE));
    hitPlayersInRadius(blastRadius, friendlyFire);
    shakeTimer+=10;
  }
}
class SinRocket extends Rocket implements Reflectable {//----------------------------------------- SinRocket objects ----------------------------------------------------
  int count, angleSpeed=16;
  Player target;
  SinRocket(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5+vx*0.5f, random(10)-5+vy*0.5f, PApplet.parseInt(random(20)+5), 800, 255));
    }
    friction=0.9f;
  }
  public @Override
    void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        angle-=sin(radians(count))*10*timeBend;
        count-=10*timeBend;
        timedScale =size-(size*(deathTime-stampTime)/time);
        x-=(vx+cos(radians(angle))*angleSpeed)*timeBend;
        y-=(vy+sin(radians(angle))*angleSpeed)*timeBend;
        vx/=friction;
        vy/=friction;
      } else {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), 0, 0, PApplet.parseInt(random(25)+8), 800, WHITE));

        angle+=sin(radians(count))*10*timeBend;
        count+=10*timeBend;
        timedScale =size-(size*(deathTime-stampTime)/time);
        x+=(vx+cos(radians(angle))*angleSpeed)*timeBend;
        y+=(vy+sin(radians(angle))*angleSpeed)*timeBend;

        //vx+=;
        //vy+=sin(radians(angle))*10;
        //vx=constrain(vx,-10,10);
        //vy=constrain(vy,-10,10);
        vx*=friction;
        vy*=friction;
      }
    }
  }
  @Override
    public void payLoad() {
    for (int i=0; i<4; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(-80, 80), random(-80, 80), PApplet.parseInt(random(30)+10), 800, 255));
    }
    /*for (int i=0; i<360; i+=360/6) {
     projectiles.add( new Bomb(owner, int( x), int(y), 25, owner.playerColor, 400, owner.angle+i, cos(radians(owner.angle+i))*10+vx, sin(radians(owner.angle+i))*10+vy, damage, false));
     }*/
    fill((friendlyFire)? BLACK:color(owner.playerColor));
    ellipse(x, y, size*4, size*4);
    particles.add(new ShockWave(PApplet.parseInt(x+vx), PApplet.parseInt(y+vy), PApplet.parseInt(blastRadius*0.5f), 20, 220, WHITE));
    particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(blastRadius*0.4f), 18, 150, (friendlyFire)? BLACK:color(owner.playerColor)));
    particles.add(new Flash(200, 12, WHITE));
    hitPlayersInRadius(blastRadius, friendlyFire);
    shakeTimer+=10;
  }
}
class RCRocket extends Rocket implements Reflectable {//----------------------------------------- Bomb objects ----------------------------------------------------
  float offsetAngle;
  RCRocket(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _offsetAngle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5+vx*0.5f, random(10)-5+vy*0.5f, PApplet.parseInt(random(20)+5), 800, 255));
    }
    offsetAngle=_offsetAngle;
    // friction=0.99;
  }
  public @Override
    void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
        angle=owner.keyAngle+offsetAngle;
      } else {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), 0, 0, PApplet.parseInt(random(25)+8), 800, owner.playerColor));
        timedScale =size-(size*(deathTime-stampTime)/time);
        angle=owner.keyAngle+offsetAngle;
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx+=cos(radians(angle))*2;
        vy+=sin(radians(angle))*2;
        vx*=friction;
        vy*=friction;
      }
    }
  }
  @Override
    public void payLoad() {
    for (int i=0; i<8; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(-80, 80), random(-80, 80), PApplet.parseInt(random(30)+10), 800, 255));
    }
    /*for (int i=0; i<360; i+=360/6) {
     projectiles.add( new Bomb(owner, int( x), int(y), 25, owner.playerColor, 400, owner.angle+i, cos(radians(owner.angle+i))*10+vx, sin(radians(owner.angle+i))*10+vy, damage, false));
     }*/
    fill((friendlyFire)? BLACK:color(owner.playerColor));
    ellipse(x, y, size*5, size*5);
    particles.add(new ShockWave(PApplet.parseInt(x+vx), PApplet.parseInt(y+vy), PApplet.parseInt(blastRadius*0.5f), 20, 220, WHITE));
    particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(blastRadius*0.4f), 18, 150, (friendlyFire)? BLACK:color(owner.playerColor)));
    particles.add(new Flash(200, 12, WHITE));
    hitPlayersInRadius(blastRadius, friendlyFire);
    shakeTimer+=damage*.2f;
  }
}
class Thunder extends Bomb {//----------------------------------------- Thunder objects ----------------------------------------------------
  int segment=40, arms;
  PShape shockCircle = createShape();       // First create the shape
  float electryfiy = 0, opacity;
  boolean firstFrozen;
  Thunder(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, int _arms, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, true);
    blastRadius=_size;
    friendlyFire=_friendlyFire;
    arms=_arms;
  }

  public void update() {
    super.update();
    if (!freeze && !dead) {
      if (reverse) {
        electryfiy-=0.006f*timeBend;
        opacity-=1.4f*timeBend;
      } else {
        electryfiy+=0.006f*timeBend;
        opacity+=1.4f*timeBend;
      }
    }
  }

  public void display() {
    if (!dead) {
      if (!freeze) {
        if (!firstFrozen) {
          shockCircle=createShape();
          firstFrozen=true;
        }
        beginShape();
        noFill();
        strokeWeight(4);
        stroke(projectileColor, opacity);

        for (int i=0; i<360; i+= (360/segment)) {
          vertex(x+cos(radians(i))*blastRadius*(1.3f-random(electryfiy)), y+sin(radians(i))*blastRadius*(1.3f-random(electryfiy)));
        }
        endShape(CLOSE);
        stroke((friendlyFire)?BLACK:WHITE, opacity);
        beginShape();
        for (int i=0; i<360; i+= (360/segment)) {
          vertex(x+cos(radians(i))*blastRadius*(1.2f-random(electryfiy)), y+sin(radians(i))*blastRadius*(1.2f-random(electryfiy)));
        }
        endShape(CLOSE);
      } else {
        if (firstFrozen) {
          shockCircle.beginShape();
          shockCircle.noFill();
          shockCircle.strokeWeight(4);
          shockCircle.stroke(projectileColor, opacity);

          for (int i=0; i<360; i+= (360/segment)) {
            shockCircle.vertex(x+cos(radians(i))*blastRadius*(1.3f-random(electryfiy)), y+sin(radians(i))*blastRadius*(1.3f-random(electryfiy)));
          }
          shockCircle.endShape(CLOSE);
          shockCircle.stroke(255);
          shockCircle.beginShape();
          for (int i=0; i<360; i+= (360/segment)) {
            shockCircle.vertex(x+cos(radians(i))*blastRadius*(1.2f-random(electryfiy)), y+sin(radians(i))*blastRadius*(1.2f-random(electryfiy)));
          }
          shockCircle.endShape(CLOSE);
          firstFrozen=false;
        } 
        shape(shockCircle, shockCircle.X + shockCircle.width*.5f, shockCircle.Y+shockCircle.height*.5f);
      }
    }
  }

  public @Override
    void fizzle() {    // when fizzle
    if ( !dead ) {         
      for (int i=0; i<5; i++) {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(-80, 80), random(-80, 80), PApplet.parseInt(random(30)+10), 800, 255));
      }
      if (arms>1) {
        for (int i=0; i<360; i+= (360/arms)) {
          particles.add( new Shock(400, PApplet.parseInt( x), PApplet.parseInt(y), 0, 0, 2, i, projectileColor)) ;
        }
      }
      particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(blastRadius*0.5f), 20, blastRadius, WHITE));
      particles.add(new Flash(500, 12, WHITE));

      beginShape();
      strokeWeight(16);
      noFill();
      stroke(random(255));
      for (int i=20; i<3000; i*= 1.1f) {
        vertex(x+cos(radians(random(360)))*i, y+sin(radians(random(360)))*i);
      }
      endShape(CLOSE);
      hitPlayersInRadius(blastRadius, friendlyFire);
      //shakeTimer=50;
      if (shakeTimer<40)shakeTimer+=PApplet.parseInt(damage*.2f);
    }
  }
  public void hit(Player enemy) {
  }
}

class CurrentLine extends Projectile {//----------------------------------------- Current objects ----------------------------------------------------
  float senseRange, tesla, homX, homY;
  int accuracy;
  boolean linked, used, follow=true;
  Player target, link;

  CurrentLine(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    damage=_damage;
  }
  CurrentLine(Player _owner, Player _linked, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    damage=_damage;
    link=_linked;
  }
  public void update() {
    if (!dead && !freeze) { 

      senseRange=size+accuracy*12 - random(accuracy*4);
      target=homingToEnemy(owner.cx, owner.cy); // homing returns 0 if it cant fin any enemy index
      // else target=homingToEnemy(owner.cx, owner.cy);
      if (link!=null)      target=homingToEnemy(link.cx, link.cy); // homing returns 0 if it cant fin any enemy index

      tesla=size+accuracy*10; // tesla effect range
      if (target!=null && !target.dead) target.hit(damage);
      if (linked && !used) {
        projectiles.add( new CurrentLine(owner, target, PApplet.parseInt( target.cx), PApplet.parseInt(target.cy), size, owner.playerColor, 300, target.angle, 0, 0, damage)); // link
        used=true;
      }
    }
  }


  public void display() {
    if (!dead) {
      stroke(hue(owner.playerColor), 255, random(100)+150);
      strokeWeight(PApplet.parseInt(random(10)));
      if (link!=null && target!=null) {
        homX=link.cx;
        homY=link.cy;
        noFill();
        ellipse(homX, homY, senseRange, senseRange);
        line(link.cx, link.cy, target.cx, target.cy);
        // if (int(random(10))==0) particles.add(new particle(7, WHITE, target.x+random(tesla)-tesla*.5, target.y+random(tesla)-tesla*.5, random(360), random(20), 50, int(random(100)+50), 8)); // electric Particles
        bezier(target.cx, target.cy, target.cx-100 +random(tesla)-tesla*.5f, target.cy+random(tesla)-tesla*.5f, target.cx+100+random(tesla)-tesla*.5f, target.cy+random(tesla)-tesla*.5f, target.cx, target.cy);// crosshier
        bezier(target.cx, target.cy, target.cx+random(tesla)-tesla*.5f, target.cy-100+random(tesla)-tesla*.5f, target.cx+random(tesla)-tesla*.5f, target.cy+100+random(tesla)-tesla*.5f, target.cx, target.cy);// crosshier
        // target.force(random(360), this.v/5 );   // force enemy back
        // target.hit(this.damage);
      } else {
        if (target!=null) {
          homX=target.cx;
          homY=target.cy;
          noFill();
          ellipse(homX, homY, senseRange*.5f, senseRange*.5f);
          line(owner.cx, owner.cy, target.cx, target.cy);
          // if (int(random(10))==0) particles.add(new particle(7, WHITE, target.x+random(tesla)-tesla*.5, target.y+random(tesla)-tesla*.5, random(360), random(20), 50, int(random(100)+50), 8)); // electric Particles
          bezier(target.cx, target.cy, target.cx-100 +random(tesla)-tesla*.5f, target.cy+random(tesla)-tesla*.5f, target.cx+100+random(tesla)-tesla*.5f, target.cy+random(tesla)-tesla*.5f, target.cx, target.cy);// crosshier
          bezier(target.cx, target.cy, target.cx+random(tesla)-tesla*.5f, target.cy-100+random(tesla)-tesla*.5f, target.cx+random(tesla)-tesla*.5f, target.cy+100+random(tesla)-tesla*.5f, target.cx, target.cy);// crosshier
          // target.force(random(360), this.v/5 );   // force enemy back
          // target.hit(this.damage);
          //   fill(255);
          particles.add(new  Tesla( PApplet.parseInt(target.cx), PApplet.parseInt(target.cy), 300, 200, owner.playerColor));
        } else {            // if enemies is not present
          noFill();
          strokeWeight(1);
          // if (int(random(20))==0) particles.add(new particle(7, WHITE, owner.cx+random(tesla)-tesla*.5, owner.cy+random(tesla)-tesla*.5, random(360), random(10), 50, int(random(50)+50), 8)); // electric Particles

          homX=owner.cx; 
          homY= owner.cy;
          ellipse(homX, homY, tesla, tesla);
          bezier(owner.cx, owner.cy, owner.cx-100 +random(tesla)-tesla*.5f, owner.cy+random(tesla)-tesla*.5f, owner.cx+100+random(tesla)-tesla*.5f, owner.cy+random(tesla)-tesla*.5f, owner.cx, owner.cy+random(tesla)-tesla*.5f);// crosshier
          bezier(owner.cx, owner.cy, owner.cx+random(tesla)-tesla*.5f, owner.cy-100+random(tesla)-tesla*.5f, owner.cx+random(tesla)-tesla*.5f, owner.cy+100+random(tesla)-tesla*.5f, owner.cx, owner.cy+random(tesla)-tesla*.5f);// crosshier
        }


        stroke(hue(owner.playerColor), 255, random(100)+150);
        noFill();
        bezier(owner.cx, owner.cy, owner.cx+10-random(100), owner.cy+10-random(100), homX+10-random(100), homY+10-random(100), homX, homY);
      }
    }
  }


  public Player homingToEnemy(float X, float Y) {  // missile range scan
    for (int sense = 0; sense < senseRange; sense++) {
      for (  Player p : players) {
        if (p!=owner && p.ally!=owner.ally && !p.dead && dist(p.cx, p.cy, X, Y)<sense*.5f) {
          if (target!=link ||(link!=null && link==owner)) {
            return null;
          }
          linked=true;
          return p;
        }
      }
    }
    return null;
  }
}

class Needle extends Projectile implements Reflectable, Destroyable {//----------------------------------------- Needle objects ----------------------------------------------------
  float v, spray=30;
  //boolean friendlyFire;
  /*Needle(int _playerIndex, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
   super(_playerIndex, _x, _y, _size, _projectileColor, _time);
   friendlyFire=_friendlyFire;
   angle=_angle;
   v=abs(_vx)+ abs(_vy); 
   damage=_damage;
   vx= _vx;
   vy= _vy;
   ally=players.get(_playerIndex).ally;
   }*/
  Needle(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    v=abs(_vx)+ abs(_vy); 
    damage=_damage;
    vx= _vx;
    vy= _vy;
    //ally=players.get(_playerIndex).ally;
  }
  public void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        //  opacity+=8*F;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        //  opacity-=8*F;
        //  particles.add(new Particle(int(x), int(y), 0, 0, 10, 200, projectileColor));
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
    }
  }
  public void display() {
    if (!dead) { 
      // strokeCap(ROUND);
      strokeWeight(6);
      // strokeJoin(ROUND);
      stroke(255);
      line(x, y, x+cos(radians(angle))*size, y+sin(radians(angle))*size);
      stroke(projectileColor);
      line(x, y, x+cos(radians(angle))*size*0.8f, y+sin(radians(angle))*size*0.8f);
      // strokeCap(NORMAL);
    }
  }

  public @Override
    void hit(Player enemy) {
    // super.hit();
    enemy.hit(damage);
    deathTime=stampTime;   // dead on collision
    dead=true;
    for (int i=0; i<4; i++) {
      // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
      float sprayAngle=random(-spray, spray)+angle;
      float sprayVelocity=random(v*0.75f);
      particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    }
    // particles.add(new LineWave(int(x), int(y), 80, 100, WHITE, angle+90));
  }
  @Override
    public void reflect(float _angle, Player _player) {
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;

    // angle=degrees(atan2(vy, vx));
    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy));
    vy= sin(radians(angle))*(abs(vx)+abs(vy));
  }
  public void destroy(Projectile destroyerP) {
    dead=true;
    deathTime=stampTime;   // dead on collision
    for (int i=0; i<4; i++) {
      // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
      float sprayAngle=random(-spray, spray)+angle+180;
      float sprayVelocity=random(v*0.3f);
      particles.add(new Spark( 750, PApplet.parseInt(x), PApplet.parseInt(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, destroyerP.owner.playerColor));
    }
  }
}

class Slash extends Projectile implements Destroyer {//----------------------------------------- Slash objects ----------------------------------------------------
  int traceAmount=8;
  float  angleV=24, range, lowRange, traceLowRange[]=new float[traceAmount];
  float pCX, pCY, traceAngle[]=new float[traceAmount];
  boolean follow;

  Slash(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _angleV, float _range, float _vx, float _vy, int _damage, boolean _follow) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    follow=_follow;
    angle=_angle;
    angleV=_angleV;
    damage=_damage;
    force=-10;
    vx= _vx;
    vy= _vy;
    range= _range;
    pCX=_owner.cx;
    pCY= _owner.cy;
    if (freeze)follow=false;
    melee=true;
    for (int i=0; i<5; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), vx/(2-0.12f*i), vy/(2-0.12f*i), 10+i*4, _time, _projectileColor));
    }
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5+vx*0.5f, random(10)-5+vy*0.5f, PApplet.parseInt(random(20)+5), 800, 255));
    }
  }
  public void update() {
    if (!dead && !freeze) { 

      if (reverse) {

        //pCX=players.get(playerIndex).x+players.get(playerIndex).w*0.5;
        // pCY= players.get(playerIndex).y+players.get(playerIndex).w*0.5;
        if (follow) {
          pCX=owner.cx;
          pCY= owner.cy;
        }
        x=pCX-cos(radians(angle))*range;
        y=pCY-sin(radians(angle))*range;
        traceAngle[0]=angle;
        for (int i=1; traceAmount>i; i++) {
          traceAngle[i]=traceAngle[i-1];
        }
        angle-=angleV*timeBend;
        traceLowRange[0]=lowRange;
        for (int i=1; traceAmount>i; i++) {
          traceLowRange[i]=traceLowRange[i-1];
        }
        lowRange=sin(radians((180*(deathTime-stampTime)/time)))*range*0.5f;
      } else {

        //pCX=players.get(playerIndex).x+players.get(playerIndex).w*0.5;
        //pCY= players.get(playerIndex).y+players.get(playerIndex).w*0.5;
        if (follow) {
          pCX=owner.cx;
          pCY= owner.cy;
        }
        x=pCX-cos(radians(angle))*range;
        y=pCY-sin(radians(angle))*range;
        traceLowRange[0]=lowRange;
        /* for (int i=1; traceAmount>i; i++) {
         traceLowRange[i]=traceLowRange[i-1];
         } */
        for (int i = traceAmount-1; i >= 1; i--) {                
          traceLowRange[i]=traceLowRange[i-1];
        }
        lowRange=sin(radians(180*(deathTime-stampTime)/time))*range*0.5f;
        //   println((range*(deathTime-stampTime)/time)-range);
        traceAngle[0]=angle;
        angle+=angleV*timeBend;
        /*  for (int i=0; traceAmount-1>i; i++) {
         //traceAngle[i]=traceAngle[i-1];
         traceAngle[i+1]=traceAngle[i];
         println(traceAngle[i]);
         }*/

        for (int i = traceAmount-1; i >= 1; i--) {                
          traceAngle[i]=traceAngle[i-1];
        }

        //    int numElts = traceAmount.length - ( remIndex + 1 ) ;
        //  System.arraycopy( traceAmount, remIndex + 1, traceAmount, remIndex, numElts ) ;

        if (lowRange<0) fizzle();
      }
    }
  }
  public void display() {
    if (!dead) { 
      // strokeWeight(84);
      strokeWeight(PApplet.parseInt(range*(angleV*0.02f)));
      for (int i=0; traceAmount>i; i++) {
        stroke(projectileColor, (traceAmount-i)*(255/traceAmount));
        // stroke(random(360), random(360), random(360));
        // line(pCX-cos(radians(angle))*(range-lowRange), pCY-sin(radians(angle))*(range-lowRange), pCX-cos(radians(angle))*range, pCY-sin(radians(angle))*range);
        line(pCX -cos(radians(traceAngle[i]))*(range-traceLowRange[i]), pCY-sin(radians(traceAngle[i]))*(range-traceLowRange[i]), pCX-cos(radians(traceAngle[i]))*range, pCY-sin(radians(traceAngle[i]))*range);
      }

      stroke(255);
      line(pCX -cos(radians(angle))*(range-lowRange), pCY-sin(radians(angle))*(range-lowRange), pCX-cos(radians(angle))*range, pCY-sin(radians(angle))*range);
    }
  }
  public @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<3; i++) {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), cos(radians(random(-15, 15)+angle-120))*10, sin(radians(random(-15, 15)+angle-120))*10, PApplet.parseInt(random(20)+5), 800, 255));
      }
    }
    dead=true;
  }
  public @Override
    void hit(Player enemy) {

    enemy.hit(damage);
    for (int i=0; i<5; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(20)-10, random(20)-10, PApplet.parseInt(random(20)+5), 800, 255));
    }
    for (int i=0; i<3; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(40)-20, random(40)-20, PApplet.parseInt(random(30)+10), 800, projectileColor));
    }
    // enemy.pushForce(-10, angle);
    // particles.add(new Flash(200, 32, 255));  
    particles.add(new LineWave(PApplet.parseInt(enemy.cx), PApplet.parseInt(enemy.cy), 10, 300, projectileColor, angle+90));
    particles.add(new LineWave(PApplet.parseInt(enemy.cx), PApplet.parseInt(enemy.cy), 10, 300, WHITE, angle+90));
  }

  public void destroying(Projectile destroyedP) {
    //   background(owner.playerColor);
    //      particles.add(new TempSlow(40, 0.03, 1.10));

    fill(WHITE);
     stroke(owner.playerColor);
     strokeWeight(8);
    triangle(x+random(50)-150, y+random(50)-25, x+random(50)+100, y+random(50)-25, x+random(50)-50, y+random(50)+75);
    particles.add(new Fragment(PApplet.parseInt(destroyedP.x), PApplet.parseInt(destroyedP.y), 0, 0, 40, 10, 500, 100, owner.playerColor) );
  }
}


class Boomerang extends Projectile implements Reflectable {//----------------------------------------- Boomerang objects ----------------------------------------------------
  float v, spray=16, pCX, pCY, graceTime=500, displayAngle, selfHitAngle=80, recoverEnergy, angleSpeed=20;
  Boomerang(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, float _recoverEnergy, float _angleSpeed) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    v=abs(_vx)+ abs(_vy); 
    damage=_damage;
    vx= _vx;
    vy= _vy;
    recoverEnergy=_recoverEnergy;
    angleSpeed=_angleSpeed;
  }
  public @Override
    void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        angle=degrees(atan2(vy, vx));
        displayAngle-=angleSpeed*timeBend;
        vy/=1-0.98f*timeBend;
        vx/=1-0.98f*timeBend;
        vx += (x-owner.cx)*0.002f;
        vy += (y-owner.cy)*0.002f;
        x-=vx*timeBend;
        y-=vy*timeBend;
        pCX=owner.cx;
        pCY=owner.cy;
      } else {
        pCX=owner.cx;
        pCY=owner.cy;
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx -= (x-owner.cx)*0.002f;
        vy -= (y-owner.cy)*0.002f;
        vx*=0.98f;
        vy*=0.98f;
        displayAngle+=angleSpeed*timeBend;
        angle=degrees(atan2(vy, vx));
        if (dist(x, y, pCX, pCY)<50 && (stampTime-spawnTime)>graceTime) retrieve();
      }
    }
  }

  public void display() {
    if (!dead) { 
      strokeWeight(8);
      stroke(projectileColor);
      fill(255);
      line(x+cos(radians(displayAngle))*size, y+sin(radians(displayAngle))*size, x-cos(radians(displayAngle))*size, y-sin(radians(displayAngle))*size);
      line(x+cos(radians(displayAngle+45))*size*0.6f, y+sin(radians(displayAngle+45))*size*0.6f, x-cos(radians(displayAngle+45))*size*0.6f, y-sin(radians(displayAngle+45))*size*0.6f);
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), cos(radians(displayAngle*2))*(vy+vx)*0.5f, sin(radians(displayAngle*2))*(vy+vx)*0.5f, PApplet.parseInt(random(10)+5), 150, 255));
      line(x+cos(radians(displayAngle))*size, y+sin(radians(displayAngle))*size, x+cos(radians(displayAngle+45))*size*0.6f, y+sin(radians(displayAngle+45))*size*0.6f);
      line(x-cos(radians(displayAngle))*size, y-sin(radians(displayAngle))*size, x-cos(radians(displayAngle+45))*size*0.6f, y-sin(radians(displayAngle+45))*size*0.6f);
    }
  }
  public @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      deathTime=stampTime;   // dead on collision with owner
      dead=true;
    }
  }

  public void retrieve() {
    if (owner.angle-selfHitAngle<angle && owner.angle+selfHitAngle>angle) { 
      owner.hit(PApplet.parseInt(damage*(abs(vx)+abs(vy))));
      particles.add( new TempFreeze(PApplet.parseInt((abs(vx)+abs(vy))*2)));
      owner.pushForce(vx, vy, angle);
      for (int i=0; i<16; i++) {
        particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), (vx+random(-spray, spray))*random(0, 0.8f), (vy+random(-spray, spray))*random(0, 0.8f), 6, angle, projectileColor));
      }
    } else {

      owner.pushForce(vx*0.2f, vy*0.2f, angle);
      owner.abilityList.get(0).energy+=recoverEnergy;
      particles.add(new RShockWave(PApplet.parseInt(owner.cx), PApplet.parseInt(owner.cy), 350, 32, 300, WHITE));
      // particles.add(new ShockWave(int(players.get(playerIndex).x+players.get(playerIndex).w*0.5), int(players.get(playerIndex).y+players.get(playerIndex).h*0.5), 20, 100, projectileColor));
    }
    deathTime=stampTime;   // dead on collision with owner
    dead=true;
  }

  public @Override
    void hit(Player enemy) {
    // super.hit();
    enemy.hit(floor(damage*(abs(vx)+abs(vy))*0.08f));
    enemy.pushForce(vx*0.05f, vy*0.05f, angle);
    //dead=true;
    for (int i=0; i<2; i++) {
      // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
      // float sprayAngle=random(-spray, spray)+angle;
      // float sprayVelocity=random(v*0.75);
      particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), (vx+random(-spray, spray))*0.4f, (vy+random(-spray, spray))*0.4f, 6, angle, projectileColor));
    }
  }
  public void reflect(float _angle, Player _player) {
    //angle=_angle;
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;

    particles.add(new Spark( 1000, PApplet.parseInt(x), PApplet.parseInt(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    // angle=degrees(atan2(vy, vx));
    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    // particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy))*1.5f;
    vy= sin(radians(angle))*(abs(vx)+abs(vy))*1.5f;
    //vx=-vx*1.5;
    //vy=-vy*1.5;
  }
}

class HomingMissile extends Projectile implements Reflectable, Destroyable {//----------------------------------------- HomingMissile objects ----------------------------------------------------

  PShape  sh, c ;
  float  homeRate, gravityRate=0.008f, count;
  int ReactionTime=40;
  final int  leapAccel=10, lockRange=300, seekRadius=4000;
  boolean locked, leap;
  Player target;
  HomingMissile(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;
    size=_size;
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5+vx*0.5f, random(10)-5+vy*0.5f, PApplet.parseInt(random(20)+5), 800, 255));
    }


    sh = createShape();
    c = createShape();
    sh.beginShape();
    sh.fill(255);
    sh.stroke(255, 50);
    sh.vertex(PApplet.parseInt (-size*0.25f), PApplet.parseInt (-size*0.25f) );
    sh.vertex(PApplet.parseInt (+size*1.5f), PApplet.parseInt (0));
    sh.vertex(PApplet.parseInt (-size*0.25f), PApplet.parseInt (+size*0.25f));
    sh.vertex(PApplet.parseInt (+size*0), PApplet.parseInt (0));
    sh.endShape(CLOSE);

    c.beginShape();
    c.fill(projectileColor);
    c.stroke(projectileColor, 50);
    c.vertex(PApplet.parseInt (0), PApplet.parseInt (-size*0.15f) );
    c.vertex(PApplet.parseInt (+size*0.75f), PApplet.parseInt (0));
    c.vertex(PApplet.parseInt (0), PApplet.parseInt (+size*0.15f));
    c.vertex(PApplet.parseInt (+size*0.25f), PApplet.parseInt (0));
    c.endShape(CLOSE);

    target=seek(seekRadius); // seek to closest enemy player
    calcAngle();
    //ellipse(target.x+target.w*0.5, target.y+target.w*0.5, 200, 200);
  }
  public void setOwner() {
  }
  public void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {

        if (target.dead ||target==owner)target=seek(seekRadius); // reseek if target is dead

        if ((locked && !leap)|| (target!=owner && !target.dead  && ReactionTime>count && dist(x, y, target.x, target.y)<lockRange)) {
          vx=cos(radians(angle))*-0.5f*timeBend;
          vy=sin(radians(angle))*-0.5f*timeBend;
          // vx=0;
          // vy=0;
          count+=1*timeBend;
          if (!locked)locking();
          if (ReactionTime<=count)leaping();
        } else if (leap) {
          vx+=cos(radians(angle))*leapAccel*timeBend;
          vy+=sin(radians(angle))*leapAccel*timeBend;
          particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), cos(radians(angle+180))*(abs(vx)+abs(vy))*0.05f, sin(radians(angle+180))*(abs(vx)+abs(vy))*0.05f, 15, 300, WHITE));
        } else if (!locked) {
          calcAngle();
          vx+=cos(radians(angle))*homeRate*timeBend;
          vy+=sin(radians(angle))*homeRate*timeBend;
          x+=((target.cx)-x)*gravityRate*timeBend;
          y+=((target.cy)-y)*gravityRate*timeBend;
        }
        x+=vx*timeBend;
        y+=vy*timeBend;

        homeRate+=0.015f*timeBend;
      }
    }
  }
  public void locking() {
    locked=true;
    particles.add(new LineWave(PApplet.parseInt(x), PApplet.parseInt(y), 30, 80, projectileColor, angle));
  }
  public void leaping() {
    leap=true;
    fill(255);
    noStroke();
    ellipse(x, y, size*2, size*2);
  }
  public void display() {
    if (!dead) { 
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      if (locked) {
        shape(sh, sh.width*0.5f, sh.height*0.5f);
        shape(c, c.width*0.5f, c.height*0.5f);
      } else {
        fill(projectileColor);
        stroke(255);
        strokeWeight(8);
        ellipse(0, 0, size, size*0.5f);
      }
      popMatrix();
      if (target!=owner && !leap ) targetVarning();
    }
  }
  public void targetVarning() {
    float tcx=target.cx, tcy=target.cy;
    stroke(projectileColor);
    strokeWeight(4);
    if (locked) {
      strokeWeight(1);
      line(x+cos(radians(angle))*2000, y+sin(radians(angle))*2000, x, y);
    } else {
      noFill();
      ellipse(tcx, tcy, target.w*2, target.w*2);
      line(tcx, tcy, tcx-150, tcy);
      line(tcx, tcy, tcx+150, tcy);
      line(tcx, tcy, tcx, tcy-150);
      line(tcx, tcy, tcx, tcy+150);
    }
  }
  public @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<3; i++) {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5+vx, random(10)-5+vy, PApplet.parseInt(random(20)+5), 800, 255));
      }
    }
  }

  public void destroy(Projectile destroyerP) {
    dead=true;
    deathTime=stampTime;   // dead on collision
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5-vx, random(10)-5-vy, PApplet.parseInt(random(20)+5), 800, destroyerP.owner.playerColor));
    }
    particles.add(new LineWave(PApplet.parseInt(x), PApplet.parseInt(y), 10, 300, destroyerP.owner.playerColor, angle+90));
    fizzle();
  }
  public @Override
    void hit(Player enemy) {
    enemy.hit(PApplet.parseInt(leap?damage:(locked?damage*0.25f:damage*0.5f)));
    deathTime=stampTime;   // dead on collision
    dead=true;
    enemy.pushForce(vx*0.05f, vy*0.05f, angle);
    for (int i=0; i<6; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(40)-20, random(40)-20, PApplet.parseInt(random(30)+10), 800, projectileColor));
    }
    particles.add(new Flash(50, 64, 255));  
    particles.add(new LineWave(PApplet.parseInt(x), PApplet.parseInt(y), 10, 300, WHITE, angle));
  }

  public void calcAngle() {
    angle = degrees(atan2(((target.cy)-y), ((target.cx)-x)));
  }



  @Override
    public void reflect(float _angle, Player _player) {
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;

    // sh = createShape();
    c = createShape();
    /* sh.beginShape();
     sh.fill(255);
     sh.stroke(255, 50);
     sh.vertex(int (-size*0.75), int (-size*0.75) );
     sh.vertex(int (+size*4), int (0));
     sh.vertex(int (-size*0.75), int (+size*0.75));
     sh.vertex(int (+size*0), int (0));
     sh.endShape(CLOSE);*/

    c.beginShape();
    c.fill(projectileColor);
    c.stroke(projectileColor, 50);
    c.vertex(PApplet.parseInt (0), PApplet.parseInt (-size*0.15f) );
    c.vertex(PApplet.parseInt (+size*0.75f), PApplet.parseInt (0));
    c.vertex(PApplet.parseInt (0), PApplet.parseInt (+size*0.15f));
    c.vertex(PApplet.parseInt (+size*0.25f), PApplet.parseInt (0));
    c.endShape(CLOSE);

    // angle=degrees(atan2(vy, vx));
    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    // particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy))*0.3f;
    vy= sin(radians(angle))*(abs(vx)+abs(vy))*0.3f;
  }

  /*public Projectile clone()throws CloneNotSupportedException {  
   
   return (Projectile)super.clone();
   }*/

  public Projectile clone() {
    target=seek(seekRadius); // seek to closest enemy player

    return (Projectile)super.clone();
    /*
    catch(Exception e) {
     println(e);
     return null;
     }*/
  }
}

class Shield extends Projectile implements Reflector { //----------------------------------------- Shield objects ----------------------------------------------------
  int brightness=255, offsetX, offsetY;
  boolean follow;
  Shield( Player _owner, int _x, int _y, int _projectileColor, int  _time, float _angle, float _damage) {
    super(_owner, _x, _y, 1, _projectileColor, _time);
    damage= PApplet.parseInt(_damage);
    size=60;
    angle=_angle;
    //follow=false;
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5, random(10)-5, PApplet.parseInt(random(20)+5), 800, 255));
    }
  }
  Shield( Player _owner, int _x, int _y, int _projectileColor, int  _time, float _angle, float _damage, int _offsetX, int _offsetY) {
    super(_owner, _x, _y, 1, _projectileColor, _time);
    damage= PApplet.parseInt(_damage);
    size=60;
    angle=_angle;
    offsetX=_offsetX;
    offsetY=_offsetY;
    follow=true;
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5, random(10)-5, PApplet.parseInt(random(20)+5), 800, 255));
    }
  }
  public void display() {
    if (!dead ) { 
      fill(0);
      //text(angle, x-100, y-100);
      strokeWeight(PApplet.parseInt(10));
      stroke(color(hue(projectileColor), 255-brightness, brightness(projectileColor)));
      // line(cos(radians(angle-90+90))*size*0.9+int(x), sin(radians(angle-90+90))*size*0.9+int(y), cos(radians(angle+90+90))*size*0.9+int(x), sin(radians(angle+90+90))*size*0.9+int(y));
      line(cos(radians(angle))*size*0.9f+PApplet.parseInt(x), sin(radians(angle))*size*0.9f+PApplet.parseInt(y), cos(radians(angle+90+90))*size*0.9f+PApplet.parseInt(x), sin(radians(angle+90+90))*size*0.9f+PApplet.parseInt(y));
    }
  }
  public void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        //  laserChange-=2;
        //  laserWidth= sin(radians(laserChange))*100;
        //   angle=players.get(playerIndex).angle;
        //  x=players.get(playerIndex).x+50;
        // y=players.get(playerIndex).y+50;
        if (follow) {
          x=owner.cx+offsetX;
          y=owner.cy+offsetY;
        }
      } else {
        if (follow) {
          x=owner.cx+offsetX;
          y=owner.cy+offsetY;
        }
        if (brightness>0)brightness-=10;
        //  laserChange+=2;
        //   laserWidth= sin(radians(laserChange))*100;
        //   angle=players.get(playerIndex).angle;
        // x=players.get(playerIndex).x+50;
        //  y=players.get(playerIndex).y+50;
        //   shakeTimer=int(laserWidth*0.1);
        // particles.add(new  Gradient(1000, int(x+size*0.5), int(y+size*0.5), 0, 0, 4, angle, projectileColor));

        /* for (int i= 0; players.size () > i; i++)
         if (playerIndex!=i  && !players.get(i).dead) lineVsCircleCollision(x, y, cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y), players.get(i));
         } */
      }
    }
  }

  public @Override
    void fizzle() {    // when fizzle
    if ( !dead && !follow) {         
      // for (int i=0; i<2; i++) {
      // particles.add(new Particle(int(x-cos(radians(angle))*15), int(y-sin(radians(angle))*15), 0, 0, int(random(25)), 500, color(projectileColor)));
      particles.add(new Particle(PApplet.parseInt(x+cos(radians(angle))*15), PApplet.parseInt(y+sin(radians(angle))*15), 0, 0, PApplet.parseInt(random(25)), 500, color(projectileColor)));
      particles.add(new Particle(PApplet.parseInt(x-cos(radians(angle))*30), PApplet.parseInt(y-sin(radians(angle))*30), 0, 0, PApplet.parseInt(random(25)), 500, color(projectileColor)));
      particles.add(new Particle(PApplet.parseInt(x+cos(radians(angle))*30), PApplet.parseInt(y+sin(radians(angle))*30), 0, 0, PApplet.parseInt(random(25)), 500, color(projectileColor)));
      particles.add(new Particle(PApplet.parseInt(x-cos(radians(angle))*50), PApplet.parseInt(y-sin(radians(angle))*50), 0, 0, PApplet.parseInt(random(25)), 500, color(projectileColor)));
      // particles.add(new Particle(int(x+cos(radians(angle))*50), int(y+sin(radians(angle))*50), 0, 0, int(random(25)), 500, color(projectileColor)));
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), 0, 0, 10, 1000, color(projectileColor)));
      //  particles.add(new Particle(int(x), int(y), random(10)-5, random(10)-5, int(random(20)+5), 1000, projectileColor));
      //}
    }
  }

  public void ProjectilelineVsProjectileCircleCollision(float x, float y, float x2, float y2, Projectile projectile) {
    float cx= projectile.x+projectile.size*0.5f, cy=projectile.y+projectile.size*0.5f; //cr= projectile.size*0.5;
    // float segV = dist(x2, y2, x, y);
    //  float segVAngle = degrees(atan2((y2-y), (x2-x)));
    //  float segC = dist(cx, cy, x, y);
    // float segCAngle = degrees(atan2((cy-y),(c2-x)));
    //  stroke(0);
    // line(x, y, cx, cy);
    //   line(x+cos(radians(segVAngle))*segC, y+sin(radians(segVAngle))*segC, cx, cy);
    //   println(segV+" angle: "+segVAngle+ "      circle:"+ segC);


    float rx, ry;
    float dx = x2 - x;
    float dy = y2 - y;
    float d = sqrt( dx*dx + dy*dy ); 

    //float a = atan2( y2 - y1, x2 - x1 ); 
    //float ca = cos( a ); 
    //float sa = sin( a ); 
    float ca = dx/d;
    float sa = dy/d;
    float mX = (-x+cx)*ca + (-y+cy)*sa; 
    //float mY = (-y+cy)*ca + ( x-cx)*sa;
    if ( mX <= 0 ) {
      rx = x; 
      ry = y;
    } else if ( mX >= d ) {
      rx = x2; 
      ry = y2;
    } else {
      rx = x + mX*ca; 
      ry = y + mX*sa;
    }

    //  stroke(255, 255, 56);
    // line(rx, ry, cx, cy);
    //  if (dist(rx, ry, cx, cy)<laserWidth*0.5+cr) {
    //  projectile.angle+=180;
    // }
  }
  public void hit(Player enemy) {
    int offset=20;
    float pushPower=0.5f;
    //  particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    //enemy.hit(2);


    // angle=degrees(atan2(vy, vx));
    float diff=angle;

    enemy.angle-=diff;
    // angle=angle%360;

    enemy.angle=-enemy.angle;
    enemy.angle+=diff;

    // particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    enemy.vx= cos(radians(enemy.angle))*(abs(enemy.vx)+abs(enemy.vy))*pushPower;
    enemy.vy= sin(radians(enemy.angle))*(abs(enemy.vx)+abs(enemy.vy))*pushPower;

    enemy.x+= cos(radians(enemy.angle))*offset;
    enemy.y+= sin(radians(enemy.angle))*offset;

    /*

     text(degrees(atan2(  -enemy.vy,-enemy.vx )), x, y);
     //   if (atan2( enemy.vy, enemy.vx)>0) {
     if(degrees(atan2(  -enemy.vy,-enemy.vx )) <=0){
     // enemy.vx=0;
     // enemy.vy=0;
     enemy.x+=cos(radians(angle-90))*offset;
     enemy.y+=sin(radians(angle-90))*offset;
     // enemy.vx+=cos(radians(angle-90))*offset;
     //enemy.vy+=sin(radians(angle-90))*offset;
     // enemy.pushForce(cos(radians(angle-90))*10,sin(radians(angle-90))*10, angle-90);
     enemy.pushForce(pushPower, angle-90);
     particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle-90))*random(10), sin(radians(angle-90))*random(10), 6, angle-90, projectileColor));
     } else {
     enemy.vx=0;
     enemy.vy=0;
     enemy.x-=cos(radians(angle+90))*offset;
     enemy.y-=sin(radians(angle+90))*offset;
     // enemy.pushForce(cos(radians(angle+90))*10, sin(radians(angle+90))*10, angle+90);
     // enemy.vx+=cos(radians(angle+90))*offset;
     // enemy.vy+=sin(radians(angle+90))*offset;
     enemy.pushForce(-pushPower, angle+90);
     particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle+90))*random(10), sin(radians(angle+90))*random(10), 6, angle+90, projectileColor));
     }*/
    enemy.ax=0;
    enemy.ay=0;
    //  particles.add( new  Particle(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), cos(radians(angle))*12, sin(radians(angle))*12, 120, 100, color(255, 0, 255)));
  }

  public void reflecting() {
    brightness=500;
    particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), size, 16, 100, WHITE));
  }
}


class Electron extends Projectile implements Reflectable {//----------------------------------------- Electron objects ----------------------------------------------------
  boolean orbit=true;
  int recoverEnergy=5;
  final float derailMultiplier=2.5f;
  float orbitAngle, vx, vy, distance=25, maxDistance=200, orbitAngleSpeed=6;
  Electron(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    orbitAngle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;
  }
  public void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        if (orbit) {
          if (distance>maxDistance) {
            distance=maxDistance;
          } else {
            distance*=1+(0.02f*timeBend);
          }
          if (owner.dead)orbit=false;
          x=owner.cx+cos(radians(orbitAngle))*distance;
          y=owner.cy+sin(radians(orbitAngle))*distance;
          orbitAngle+=orbitAngleSpeed*timeBend;
          angle+=12*timeBend;
        } else {
          angle+=6*timeBend;
          x+=vx*timeBend;
          y+=vy*timeBend;
        }
      }
    }
  }
  public void display() {
    if (!dead) { 
      fill(255);
      strokeWeight(6);
      stroke(projectileColor);
      /*  pushMatrix();
       translate(x, y);
       rotate(radians(angle));
       rect(-(size*0.5), -(size*0.5), (size), (size));
       popMatrix();*/
      if (distance<maxDistance) 
        ellipse(x, y, size*.5f, size*.5f);
      else
        ellipse(x, y, size, size);
    }
  }
  public void derail() {
    orbit=false;
    vx=cos(radians(orbitAngle+90))*0.03f*orbitAngleSpeed*distance;
    vy=sin(radians(orbitAngle+90))*0.03f*orbitAngleSpeed*distance;
    vx+= owner.ax*5;
    vy+= owner.ay*5;
    angle=orbitAngle;
  }
  public @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<4; i++) {
        particles.add(new Particle(PApplet.parseInt(x+size*.5f), PApplet.parseInt(y+size*.5f), random(10)-5+vx, random(10)-5+vy, PApplet.parseInt(random(20)+5), 800, 255));
      }
    }
  }
  public @Override
    void hit(Player enemy) {
    // super.hit();
    if (orbit) { 
      enemy.hit(PApplet.parseInt(damage*0.5f));
      enemy.pushForce(8*orbitAngleSpeed, orbitAngle+90);
      deathTime=stampTime;   // dead on collision
      dead=true;
      for (int i=0; i<16; i++) {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(20)-10, random(20)-10, PApplet.parseInt(random(20)+5), 800, 255));
      }
      for (int i=0; i<8; i++) {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(40)-20, random(40)-20, PApplet.parseInt(random(30)+10), 800, projectileColor));
      }
    } else { 
      enemy.hit(PApplet.parseInt(damage*derailMultiplier));
      enemy.pushForce(12*orbitAngleSpeed, angle);
      deathTime+=3000;
      owner.abilityList.get(0).energy+=recoverEnergy;
      orbit=true;
      projectiles.add( new CurrentLine(owner, PApplet.parseInt( enemy.cx), PApplet.parseInt( enemy.cx), 200, owner.playerColor, 200, owner.angle, 0, 0, 2));
      particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), 300, 16, 150, WHITE));

      for (int i=0; i<6; i++) {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(40)-20, random(40)-20, PApplet.parseInt(random(30)+10), 800, projectileColor));
      }
      stroke(projectileColor);
      strokeWeight(size);
      line(x, y, owner.cx+cos(radians(orbitAngle))*distance, owner.cy+sin(radians(orbitAngle))*distance);
      x=owner.cx;
      y=owner.cy;
    }

    // particles.add(new Flash(200, 32, 255));  
    // particles.add(new LineWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 10, 300, projectileColor, angle));
  }

  @Override
    public void reflect(float _angle, Player _player) {

    try {
      DeployElectron tempA=(DeployElectron)owner.abilityList.get(0);
      for (  int i=tempA.stored.size()-1; i>=0; i--) {
        if (tempA.stored.get(i)==this)tempA.stored.remove(i);
      }
    }
    catch(Exception e) {
      println(e);
    }

    vx=cos(radians(orbitAngle+90))*0.02f*orbitAngleSpeed*distance;
    vy=sin(radians(orbitAngle+90))*0.02f*orbitAngleSpeed*distance;

    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;
    orbit=false;
    // angle=degrees(atan2(vy, vx));
    float diff=_angle;

    orbitAngle-=diff;
    // angle=angle%360;

    orbitAngle=-angle;
    orbitAngle+=diff;

    // particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(orbitAngle))*(abs(vx)+abs(vy))*0.5f;
    vy= sin(radians(orbitAngle))*(abs(vx)+abs(vy))*0.5f;
  }
}

class Graviton extends Projectile {//----------------------------------------- Graviton objects ----------------------------------------------------

  float  friction=0.95f;
  int dragForce=-1, dragRadius=250, count, arms=3;
  final int bend=60;
  Graviton(Player _owner, int _x, int _y, int _size, int _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, int _arms) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;
    arms=_arms;
    dragRadius=_size;
    for (int i=0; i<2; i++) {
      particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(10)-5+vx*0.5f, random(10)-5+vy*0.5f, PApplet.parseInt(random(20)+5), 800, 255));
    }
    particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(dragRadius*0.5f), 16, 200, color(_projectileColor)));
    particles.add(new ShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(dragRadius*0.4f), 16, 150, WHITE));
  }
  public void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
        angle-=8*timeBend;
      } else {
        angle+=8*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
        dragPlayersInRadius(dragRadius, false);
        count++;
        if ((count%PApplet.parseInt(35/(timeBend)))==0)particles.add(new RShockWave(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(dragRadius*2), 16*damage, dragRadius*2, color(projectileColor)));
      }
    }
  }
  public void display() {
    if (!dead) { 

      strokeWeight(sin(radians(count*4*timeBend))*5);
      stroke(255);
      fill(projectileColor);
      ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      // line(x,y,x+cos(radians(angle))*dragRadius,y+sin(radians(angle))*dragRadius);
      noFill();
      for (int i=0; i<360; i+=360/arms) {
        bezier(x, y, x, y, x+cos(radians(angle+bend+i))*dragRadius*.5f, y+sin(radians(angle+bend+i))*dragRadius*.5f, x+cos(radians(angle+i))*dragRadius, y+sin(radians(angle+i))*dragRadius);
      }
      //bezier(x,y,x,y,x+cos(radians(angle+bend+120))*dragRadius*.5,y+sin(radians(angle+bend+120))*dragRadius*.5,x+cos(radians(angle-bend*2+120))*dragRadius,y+sin(radians(angle-bend+120))*dragRadius);
      //bezier(x,y,x,y,x+cos(radians(angle+bend+240))*dragRadius*.5,y+sin(radians(angle+bend+240))*dragRadius*.5,x+cos(radians(angle-bend*2+240))*dragRadius,y+sin(radians(angle-bend+240))*dragRadius);

      //noFill();
      // stroke(projectileColor);
      // ellipse(x, y, size, size);
      //ellipse(x, y, dragRadius*2, dragRadius*2);
      if ((deathTime-stampTime)<=100) {
        size=400;
      } else {
        size=50;
      }
    }
  }

  public float calcAngleFromBlastZone(float x, float y, float px, float py) {
    double deltaY = py - y;
    double deltaX = px - x;
    return (float)Math.atan2(deltaY, deltaX) * 180 / PI;
  }

  public void dragPlayersInRadius(int range, boolean friendlyFire) {
    if (!freeze &&!reverse) { 
      for (int i=0; i<players.size (); i++) { 
        if (!players.get(i).dead &&(players.get(i).index!= playerIndex || friendlyFire)) {
          if (dist(x, y, players.get(i).cx, players.get(i).cy)<range) {
            players.get(i).pushForce(dragForce*timeBend, calcAngleFromBlastZone(x, y, players.get(i).cx, players.get(i).cy));
            if (count%10==0)players.get(i).hit(damage);
          }
        }
      }
    }
  }

  public @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<6; i++) {
        particles.add(new Particle(PApplet.parseInt(x), PApplet.parseInt(y), random(-80, 80), random(-80, 80), PApplet.parseInt(random(30)+10), 800, 255));
      }
      // particles.add(new Flash(200, 12, WHITE));
      shakeTimer+=5;
    }
  }
}
interface Reflectable {
  Boolean reflectable=true;
  public void reflect(float angle, Player owner);
}

interface Destroyable {
  Boolean destroyable=true;
  //void destroy();
  public void destroy(Projectile destroyer);
}

interface Reflector {
  Boolean reflectable=true;
  public void reflecting();
}

interface Destroyer {
  Boolean destroyable=true;
 // void destroying();
 public void destroying(Projectile destroyed);
}

interface Container { 
  Boolean container=true;
  public Container contains(Containable[] payload);
}
interface Containable { 
  Boolean containable=true;
  public Containable parent(Container parent);
  public void unWrap();

}

class CheckPoint extends TimeStamp {  // save states
  int index;
  ArrayList<TimeStamp> checkPointStamps=new   ArrayList<TimeStamp>();  // all stamps
  ArrayList<Projectile> clonedProjectiles=new   ArrayList<Projectile>();  // all cloned projectile
  ArrayList<Particle> clonedParticles=new   ArrayList<Particle>();  // all cloned projectile

  boolean  savedSlow, savedReverse, savedFastForward, savedFreeze, musicPause;
  long  savedForwardTime, savedReversedTime, savedFreezeTime, savedStampTime;
  double musicTime;

  CheckPoint() {
    super(-1);

    // save all states

    /*for (int i=0; i<players.size (); i++) {
     checkPointStamps.add( new ControlStamp(players.get(i).index, int(players.get(i).x), int(players.get(i).y), players.get(i).vx, players.get(i).vy, players.get(i).ax, players.get(i).ay)); //save coords and controll
     checkPointStamps.add( new StateStamp(players.get(i).index, int(players.get(i).x), int(players.get(i).y), players.get(i).state, players.get(i).health, players.get(i).dead)); //save players state
     }
     
     for (int i=0; i<projectiles.size (); i++) {  // clone projectiles
     try {
     clonedProjectiles.add( projectiles.get(i).clone());
     }
     catch(CloneNotSupportedException e) {
     }
     }
     
     for (int i=0; i<particles.size (); i++) { // clone particles
     try {
     clonedParticles.add( particles.get(i).clone());
     }
     catch(CloneNotSupportedException e) {
     }
     }*/
    for (Player p : players) {
      checkPointStamps.add( new ControlStamp(p.index, PApplet.parseInt(p.x), PApplet.parseInt(p.y), p.vx, p.vy, p.ax, p.ay)); //save coords and controll
      checkPointStamps.add( new StateStamp(p.index, PApplet.parseInt(p.x), PApplet.parseInt(p.y), p.state, p.health, p.dead)); //save players state
    }

    for (Projectile p : projectiles) {  // clone projectiles
      clonedProjectiles.add( p.clone());
    }

    for (Particle p : particles) { // clone particles
      clonedParticles.add( p.clone());
    }

    //-----------------------

    // time lapse
    savedForwardTime=forwardTime;
    savedReversedTime=reversedTime; 
    savedFreezeTime=freezeTime;
    savedStampTime=stampTime;

    // time state
    savedSlow=slow; 
    savedReverse=reverse; 
    savedFastForward=fastForward; 
    savedFreeze=freeze;

    musicPause=musicPlayer.isPaused();
    musicTime=musicPlayer.getPosition();
  }

  public void call() {
    //   players.clear();
    //  players=savedPlayers;
    projectiles.clear();
    projectiles.addAll(clonedProjectiles); // add all from the saved list
    //  projectiles=savedProjectiles;
    particles.clear();
    particles.addAll(clonedParticles); // add all from the saved list
    //  particles=savedParticles;
    //   stamps.clear();
    //   stamps=savedTimeStamps;


    forwardTime=savedForwardTime;
    reversedTime=savedReversedTime; 
    freezeTime=savedFreezeTime;
    stampTime=savedStampTime;

    slow=savedSlow; 
    reverse=savedReverse; 
    fastForward=savedFastForward; 
    freeze=savedFreeze;

    /* for (int i=0; i<checkPointStamps.size (); i++) {
     checkPointStamps.get(i).call();
     }*/
    for (TimeStamp t : checkPointStamps) {
      t.call();
    }
    musicPlayer.pause(musicPause);
    musicPlayer.setPosition(musicTime);
  }
}

class StateStamp extends TimeStamp {  // save player 
  int playerState=0;
  int playerHealth=0;
  boolean playerDead, stealth;
  StateStamp(int _player, int _x, int _y, int _state, int _health, boolean _dead) {
    super(_player);
    x=_x;
    y=_y;
    playerState=_state;
    playerHealth=_health;
    playerDead=_dead;
    stealth=players.get(_player).stealth;
  }
  StateStamp(int _player, PVector _coord, int _state, int _health, boolean _dead) {
    super(_player);
    coord=_coord;
    playerState=_state;
    playerHealth=_health;
    playerDead=_dead;
    stealth=players.get(_player).stealth;
  }

  public void display() {
    super.display();
    stroke(255);
    point(x, y);
    point(coord.x, coord.y);
  }

  public void revert() {
    try {
      if (reverse && ! players.get(playerIndex).reverseImmunity && stampTime<time) {
        call();
        stamps.remove(this);
        // super.revert();
      }
    } 
    catch(Exception e) {
      println(e+" 2");
      stamps.remove(this);
    }
  }
  public void call() {
    players.get(playerIndex).state=playerState;
    players.get(playerIndex).health=playerHealth;
    players.get(playerIndex).dead=playerDead;
    players.get(playerIndex).stealth= stealth;
  }
}

class AbilityStamp extends TimeStamp { //save player ability
  float energy;
  boolean active, channeling, cooling, regen, hold;

  AbilityStamp(int _player, int _x, int _y, float _energy, boolean _active, boolean _channeling, boolean _cooling, boolean _regen, boolean _hold) {
    super(_player);
    x=_x;
    y=_y;
    energy= _energy;
    active=_active; 
    channeling=_channeling;
    cooling=_cooling; 
    regen=_regen;
    hold=_hold;
  }

  public void display() {
    super.display();
    stroke(255);
    point(x, y);
  }

  public void revert() {
    try {
      if (reverse && !players.get(playerIndex).reverseImmunity && stampTime<time) {
        //background(255);
        call();
        stamps.remove(this);
        // super.revert();
      }
    }
    catch(Exception e) {
      println(e);
    }
  }
  public void call() {
    players.get(playerIndex).abilityList.get(0).energy=energy;
    players.get(playerIndex).abilityList.get(0).regen=regen;
    players.get(playerIndex).abilityList.get(0).active=active;
    players.get(playerIndex).abilityList.get(0).channeling=channeling;
    players.get(playerIndex).abilityList.get(0).cooling=cooling;
  }
}
abstract class TimeStamp {
  long time;
  int playerIndex,x, y;
  PVector coord;
  
  TimeStamp(int _playerIndex){
  playerIndex=_playerIndex;
  time=stampTime;
  }
  
  public void display() {
    fill(0);
    stroke(0);
    strokeCap(ROUND);
    strokeWeight(2);
  }
  public void revert() {
    stamps.remove(this);
  }
  public void call(){} // execute timestamp without the respect for currenttime
}
class Turret extends Player implements Containable { 
  Projectile parent;
  long deathTime, spawnTime, duration=100000;
  Boolean stationary=true;
  int lvl;
  float angleSpeed=2;
  Player owner;
  String abilityShortName;

  Turret(int _index, Player _owner, int _x, int _y, int _w, int _h, int _health, Ability ..._ability) {

    super( _index, _owner.playerColor, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;
    owner=_owner;
    this.ally=_owner.ally;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
    abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
  }
  Turret(int _index, int _x, int _y, int _w, int _h, int _health, Ability ..._ability) { // nseutral
    super( _index, BLACK, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;

    owner=null;
    this.ally=-1;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
    abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
  }

  public void displayAbilityEnergy() {
  }
  public void display() {
    if (!stealth) {
      stroke((freeze && !freezeImmunity)?255:0);
      strokeWeight(2);
      fill(255, 0, 255-deColor*0.5f, 50+deColor);

      //textMode(CENTER);
      //rect(x, y, w, h);
      ellipse(cx, cy, w, h);

      pushMatrix();
      translate(cx, cy);
      rotate(radians(angle+90));
      // shape(arrowSVG,x+w*.5- arrowSVG.width*.5, y-arrowSVG.height*.5, arrowSVG.width, arrowSVG.height); // default render
      //fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s, 50+deColor);
      shape(arrowSVG, -arrowSVG.width*0.5f+30, -arrowSVG.height+0, arrowSVG.width, arrowSVG.height);
      popMatrix();

      //fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s );
      //displayAbilityEnergy();
      displayHealth();
      displayName();

      //if (cheatEnabled && ability.active)text("A", x+w*0.5, y-h*2);
      //if (cheatEnabled && holdTrigg)text("H", x+w*0.5, y+h*0.5-h);
      //if (deColor>0)deColor-=int(10*s*f);
      if (deColor>0)deColor-=PApplet.parseInt(10*timeBend);
    } else { //stealth
      stroke(255, 40);
      noFill();
      strokeWeight(1);
      ellipse(cx, cy, w, h);
    }
    if (freezeImmunity || reverseImmunity || fastforwardImmunity || slowImmunity) {
      noFill();
      ellipse(cx, cy, outlineDiameter, outlineDiameter);
    }
  }
  public void update() {
    if (!freeze || freezeImmunity) {

      if (reverse && !reverseImmunity) {
        //if (!stationary) {
        cx=x+radius;
        cy=y+radius;
        //}
        angle+=angleSpeed*timeBend;
        keyAngle+=angleSpeed*timeBend;
      } else {
        //     if (!stationary) {
        cx=x+radius;
        cy=y+radius;
        // }
        angle-=angleSpeed*timeBend;
        keyAngle-=angleSpeed*timeBend;
      }
    }
    // super.update();
    abilityList.get(0).passive();
    abilityList.get(0).regen();
    if (random(100)<1) {
      abilityList.get(0).press();
    }
  }
  public void control(int dir) {
  }
  public void pushForce(float amount, float angle) {
    if (!stationary) super.pushForce( amount, angle);
  }
  public void pushForce(float _vx, float _vy, float _angle) {
    if (!stationary) super.pushForce( _vx, _vy, _angle);
  }
  public void displayName() {
    //pushStyle();
    fill(playerColor);
    textAlign(CENTER, CENTER);
    textSize(26);
    text(abilityShortName, cx, cy);
    //popStyle();
  }
  public Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  public void unWrap() {
    //resetDuration();
    cx=parent.x;
    cy=parent.y;
    x=cx-w*.5f;
    y=cy-h*.5f;
    radius=PApplet.parseInt(w*.5f);
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    // vel.rotate(radians(parent.angle));
    vel.add(pVel);
    float deltaX = 0 - vel.x;
    float deltaY = 0 - vel.y;

    angle+= atan2(deltaY, deltaX); // In radians
    //angle=90;
    vx=vel.x;
    vy=vel.y;
  }
}
class Block extends Player implements Containable { 
  Projectile parent;
  long deathTime, spawnTime, duration=100000;
  Boolean stationary=true;
  int lvl;
  float angleSpeed=2;
  Player owner;
  String abilityShortName;

  Block(int _index, Player _owner, int _x, int _y, int _w, int _h, int _health, Ability ..._ability) {

    super( _index, _owner.playerColor, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;
    owner=_owner;
    this.ally=_owner.ally;
    damage=0;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
    abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
  }
  Block(int _index, int _x, int _y, int _w, int _h, int _health, Ability ..._ability) { // nseutral
    super( _index, BLACK, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;
   damage=0;
    owner=null;
    this.ally=-1;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
    abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
  }

  public void displayAbilityEnergy() {
  }
    public void displayHealth() {
    fraction=((PI*2)/maxHealth)*health;
    strokeWeight(barSize);
    //strokeCap(SQUARE);
    noFill();
    stroke(hue(playerColor), 80*S, (80-deColor)*S);
    ellipse(cx, cy, radius*1.8f, radius*1.8f);
    stroke(hue(playerColor), (255-deColor*0.5f)*S, ally==-1?0:255*S);
    arc(cx, cy, radius*1.8f, radius*1.8f, -HALF_PI +(PI*2)-fraction, PI+HALF_PI);
    //strokeWeight(1);
  }
  public void display() {
    if (!stealth) {
      stroke((freeze && !freezeImmunity)?255:0);
      strokeWeight(2);
      fill(255, 0, 255-deColor*0.5f, 50+deColor);


      rect(x, y, w, h);

      //displayHealth();
      displayName();

      if (deColor>0)deColor-=PApplet.parseInt(10*timeBend);
    } else { //stealth
      stroke(255, 40);
      noFill();
      strokeWeight(1);
      rect(x, y, w, h);

    }
    if (freezeImmunity || reverseImmunity || fastforwardImmunity || slowImmunity) {
      noFill();
       rect(x, y,  outlineDiameter, outlineDiameter);
    }
  }
  public void update() {
    if (!freeze || freezeImmunity) {

      if (reverse && !reverseImmunity) {
       // if (!stationary) {
        cx=x+radius;
        cy=y+radius;
       // }
        angle+=angleSpeed*timeBend;
        keyAngle+=angleSpeed*timeBend;
      } else {
        //if (!stationary) {
        cx=x+radius;
        cy=y+radius;
        // }
        angle-=angleSpeed*timeBend;
        keyAngle-=angleSpeed*timeBend;
      }
    }
    // super.update();
    abilityList.get(0).passive();
    abilityList.get(0).regen();
    if (random(100)<1) {
      abilityList.get(0).press();
    }
  }
  public void control(int dir) {
  }
  public void pushForce(float amount, float angle) {
    if (!stationary) super.pushForce( amount, angle);
  }
  public void pushForce(float _vx, float _vy, float _angle) {
    if (!stationary) super.pushForce( _vx, _vy, _angle);
  }
  public void displayName() {
    //pushStyle();
   // fill(playerColor);
   // textAlign(CENTER, CENTER);
   // textSize(26);
   // text(abilityShortName, cx, cy);
    //popStyle();
  }
  public Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  public void unWrap() {
    //resetDuration();
    cx=parent.x;
    cy=parent.y;
    x=cx-w*.5f;
    y=cy-h*.5f;
    radius=PApplet.parseInt(w*.5f);
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    // vel.rotate(radians(parent.angle));
    vel.add(pVel);
    float deltaX = 0 - vel.x;
    float deltaY = 0 - vel.y;

    angle+= atan2(deltaY, deltaX); // In radians
    //angle=90;
    vx=vel.x;
    vy=vel.y;
  }
}

class Drone extends Player { 
  long deathTime, spawnTime, duration=100000;
  Boolean stationary;
  int lvl, wait, type;
  Player owner;
  String abilityShortName;


  Drone(int _index, Player _owner, int _x, int _y, int _w, int _h, int speed, int _health, Ability ..._ability) {
    super( _index, _owner.playerColor, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;
    owner=_owner;
    this.ally=_owner.ally;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
    damage=5;
    armor=-10;
    abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
  }
  Drone(int _index, int _x, int _y, int _w, int _h, int speed, int _health, Ability ..._ability) { // neutral
    super( _index, BLACK, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;
    owner=null;
    this.ally=-1;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
    damage=5;
    armor=-10;
    abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
  }
  public void displayAbilityEnergy() {
  }
  public void display() {
    if (!stealth) {
      stroke((freeze && !freezeImmunity)?255:0);
      strokeWeight(2);
      fill(255, 0, 255-deColor*0.5f, 50+deColor);

      //textMode(CENTER);
      //rect(x, y, w, h);
      ellipse(cx, cy, w, h);

      pushMatrix();
      translate(cx, cy);
      rotate(radians(angle+90));
      // shape(arrowSVG,x+w*.5- arrowSVG.width*.5, y-arrowSVG.height*.5, arrowSVG.width, arrowSVG.height); // default render
      //fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s, 50+deColor);
      shape(arrowSVG, -arrowSVG.width*0.5f+30, -arrowSVG.height+0, arrowSVG.width, arrowSVG.height);
      popMatrix();

      fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s);
      //displayAbilityEnergy();
      displayHealth();
      displayName();
      //if (cheatEnabled && ability.active)text("A", x+w*0.5, y-h*2);
      //if (cheatEnabled && holdTrigg)text("H", x+w*0.5, y+h*0.5-h);
      //if (deColor>0)deColor-=int(10*s*f);
      if (deColor>0)deColor-=PApplet.parseInt(10*timeBend);
    } else { //stealth
      stroke(255, 40);
      noFill();
      strokeWeight(1);
      ellipse(cx, cy, w, h);
    }
    if (freezeImmunity || reverseImmunity || fastforwardImmunity || slowImmunity) {
      noFill();
      ellipse(cx, cy, outlineDiameter, outlineDiameter);
    }
  }
  public void update() {
    if (!freeze || freezeImmunity) {

      if (reverse && !reverseImmunity) {
        if (wait<50)  health++;
        x-=vx;
        y-=vy;
        vx/=1-FRICTION_FACTOR*.5f;
        vy/=1-FRICTION_FACTOR*.5f;
        //if (!stationary) {
        cx=x+radius;
        cy=y+radius;
        //}
        angle+=1*timeBend;
        keyAngle+=1*timeBend;
      } else {
        if (wait>50)health--;
        if (health<=0)death();
        x+=vx;
        y+=vy;
        vx*=1-FRICTION_FACTOR*.5f;
        vy*=1-FRICTION_FACTOR*.5f;
        //if (!stationary) {
        cx=x+radius;
        cy=y+radius;
        //}
        angle-=1*timeBend;
        keyAngle-=1*timeBend;
      }
    }
    switch(type) {
    case 2:
      seek(this, 1000);

      break;
    }

    for (Ability a : this.abilityList) {
      a.passive();
      a.regen();
    }

    if (wait>50) {
      for (Ability a : this.abilityList) { 
        a.press();
        a.hold();
      }
    } else wait++;


    //}
  }
  public void control(int dir) {
  }
  /* void pushForce(float amount, float angle) {
   if (!stationary) super.pushForce( amount, angle);
   }
   void pushForce(float _vx, float _vy, float _angle) {
   if (!stationary) super.pushForce( _vx, _vy, _angle);
   }*/
  public void displayName() {
    //pushStyle();
    fill(playerColor);
    textAlign(CENTER, CENTER);
    textSize(26);
    text(abilityShortName, cx, cy);
    //popStyle();
  }
}

class FollowDrone extends Drone { 

  Player target;


  FollowDrone(int _index, Player _owner, int _x, int _y, int _w, int _h, int speed, int _health, int _type, Ability ..._ability) {
    super( _index, _owner, _x, _y, _w, _h, speed, _health, _ability) ;
    owner=_owner;
    type=_type;
    //this.ally=_owner.ally;
    //turret=true;
    //spawnTime=stampTime;
    //deathTime=stampTime + duration;
    //maxHealth=_health;
    //health=maxHealth;
    damage=5;
    armor=-10;
    angle=owner.angle;
    //println(abilityList.get(0).name);
  }
  FollowDrone(int _index, int _x, int _y, int _w, int _h, int speed, int _health, int _type, Ability ..._ability) {
    super( _index, _x, _y, _w, _h, speed, _health, _ability) ;

    type=_type;
    damage=5;
    armor=-10;

  }
  public void displayAbilityEnergy() {
  }
  public void display() {
    if (!stealth) {
      stroke((freeze && !freezeImmunity)?255:0);
      strokeWeight(2);
      fill(255, 0, 255-deColor*0.5f, 50+deColor);

      //textMode(CENTER);
      //rect(x, y, w, h);
      ellipse(cx, cy, w, h);

      pushMatrix();
      translate(cx, cy);
      rotate(radians(angle+90));
      // shape(arrowSVG,x+w*.5- arrowSVG.width*.5, y-arrowSVG.height*.5, arrowSVG.width, arrowSVG.height); // default render
      //fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s, 50+deColor);
      shape(arrowSVG, -arrowSVG.width*0.5f+30, -arrowSVG.height+0, arrowSVG.width, arrowSVG.height);
      popMatrix();

      fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s);
      //displayAbilityEnergy();
      displayHealth();
      displayName();
      //if (cheatEnabled && ability.active)text("A", x+w*0.5, y-h*2);
      //if (cheatEnabled && holdTrigg)text("H", x+w*0.5, y+h*0.5-h);
      if (deColor>0)deColor-=PApplet.parseInt(10*s*f);
    } else { //stealth
      stroke(255, 40);
      noFill();
      strokeWeight(1);
      ellipse(cx, cy, w, h);
    }

    if (freezeImmunity || reverseImmunity || fastforwardImmunity || slowImmunity) {
      noFill();
      ellipse(cx, cy, w*1.1f, h*1.1f);
    }
  }
  public void update() {
    if (!freeze || freezeImmunity) {

      if (reverse && !reverseImmunity) {
        if (wait<50)  health++;
        x-=vx;
        y-=vy;
        vx/=1-FRICTION_FACTOR*.5f;
        vy/=1-FRICTION_FACTOR*.5f;
        if (!stationary) {
          cx=x+radius;
          cy=y+radius;
        }
        //angle+=1*timeBend;
        keyAngle+=1*timeBend;
      } else {
        if (wait>50)health--;
        if (health<=0)death();
        x+=vx;
        y+=vy;
        vx*=1-FRICTION_FACTOR*.5f;
        vy*=1-FRICTION_FACTOR*.5f;
        cx=x+radius;
        cy=y+radius;
        if (owner!=null) { 
          x+=(owner.cx-cx)*.03f;
          y+=(owner.cy-cy)*.03f;
        }
        //angle-=1*timeBend;
        keyAngle-=1*timeBend;
      }
    }

    for (Ability a : this.abilityList) {
      a.passive();
      a.regen();
    }
    switch(type) {
    case 2:
      target = seek(this, 1500);
      if (target!=null) {
        angle=angleAgainst(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(target.x), PApplet.parseInt(target.y));
      }
      pushForce(0.3f, angle);
       if (wait>100) {

        for (Ability a : this.abilityList) { 
          a.press();
          a.hold();
        }
        wait=PApplet.parseInt(random(100));
      } else wait++;
      break;
    default:
      target = seek(this, 1500);
      if (target!=null) {
        angle=angleAgainst(PApplet.parseInt(x), PApplet.parseInt(y), PApplet.parseInt(target.x), PApplet.parseInt(target.y));
      }
      if (wait>50) {

        wait=20;
        for (Ability a : this.abilityList) { 
          a.press();
          a.hold();
        }
      } else wait++;
    }
  }
  public void control(int dir) {
  }
  /* void pushForce(float amount, float angle) {
   //if (!stationary) super.pushForce( amount, angle);
   }
   void pushForce(float _vx, float _vy, float _angle) {
   //if (!stationary) super.pushForce( _vx, _vy, _angle);
   }*/
  public void displayName() {
    //pushStyle();
    fill(playerColor);
    textAlign(CENTER, CENTER);
    textSize(26);
    text(abilityShortName, cx, cy);
    //popStyle();
  }
}
class ControlStamp extends TimeStamp {  // save movements & speed 
  float  vx, vy, ax, ay;
  boolean holdLeft, holdRight, holdUp, holdDown, holdTrigg;
  PVector speed, accel;
  ControlStamp(int _player, int _x, int _y, float _vx, float _vy, float _ax, float _ay) {
    super(_player);
    x= _x;
    y= _y;
    vx= _vx;
    vy= _vy;
    ax= _ax;
    ay= _ay;
  }
  ControlStamp(int _player, PVector _coord, PVector _speed, PVector _accel) { // vector
    super(_player);
    coord=_coord;
    speed=_speed;
    accel=_accel;
  }

  public void display() {
    super.display();
    point(x, y);
    point(coord.x, coord.y);
  }
  public void revert() {
    if (reverse && ! players.get(playerIndex).reverseImmunity && stampTime<time) {
      call();
      //  super.revert();
      stamps.remove(this);
    }
  }
  public void call() {
    // players.get(playerIndex).coord=coord;
    players.get(playerIndex).x=x;
    players.get(playerIndex).y=y;
    //  players.get(playerIndex).speed=speed;
    players.get(playerIndex).vx=vx;
    players.get(playerIndex).vy=vy;
    // players.get(playerIndex).accel=accel;
    players.get(playerIndex).ax=ax;
    players.get(playerIndex).ay=ay;
  }
}

class AngleControlStamp extends TimeStamp {  // save angle  
  float  keyAngle, angle, ANGLE_FACTOR;

  AngleControlStamp(int _player, float _keyAngle, float _angle, float _ANGLE_FACTOR) {
    super(_player);
    keyAngle=_keyAngle;
    angle=_angle;
    ANGLE_FACTOR=_ANGLE_FACTOR;
  }


  public void display() {
    super.display();
    point(x, y);
    point(coord.x, coord.y);
  }
  public void revert() {
    if (reverse && ! players.get(playerIndex).reverseImmunity && stampTime<time) {
      call();
      //  super.revert();
      stamps.remove(this);
    }
  }
  public void call() {
    // players.get(playerIndex).coord=coord;
    players.get(playerIndex).keyAngle=this.keyAngle;
    players.get(playerIndex).angle=this.angle;
    players.get(playerIndex).ANGLE_FACTOR= this.ANGLE_FACTOR;
  }
}

ArrayList<Spawner> spawnList= new ArrayList<Spawner>();
boolean gameOver;
int survivalTime;
final float DIFFICULTY_LEVEL=0.3f;
public void spawningSetup() {

   
  /*  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.5), int(playerSize*0.5), 10, 150, 1, new Bazooka())}
    , 1000));*/
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, PApplet.parseInt(playerSize*0.5f), PApplet.parseInt(playerSize*0.5f), 10, 30,2, new CloneMultiply())}
    , 1000, 10000/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 20*DIFFICULTY_LEVEL));
/*  spawnList.add(new Spawner(new Object[]{new HomingMissile(AI, halfWidth, halfHeight, 50, GREY, 2000, 0, 0, 0, 10), new HomingMissile(AI, halfWidth, halfHeight, 50, WHITE, 2000, 0, 0, 0, 10)}
    , 1000, 100, halfWidth, halfHeight, false, 100));*/

  spawnList.add(new Spawner(new Object[]{ new Bomb(AI, halfWidth, halfHeight, 200, BLACK, 1500, 0, 0, 0, 30, false)}
    , 2000, 1500/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 200*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new HomingMissile(AI, halfWidth, halfHeight, 50, BLACK, 2000, 0, 0, 0, 10)}
    , 5000, 800/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 10*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new HomingMissile(AI, halfWidth, halfHeight, 50, BLACK, 2000, 0, 0, 0, 10), new HomingMissile(AI, halfWidth, halfHeight, 50, WHITE, 2000, 0, 0, 0, 10)}
    , 15000, 1000/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 20*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{ new Bomb(AI, halfWidth, halfHeight, 100, WHITE, 5000, 0, 0, 0, 50, false)}
    , 30000, 1200/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 200*DIFFICULTY_LEVEL));
  /*spawnList.add(new Spawner(new Object[]{new  Missle(AI, halfWidth, halfHeight, 50, BLACK, 2000, 1, 1, 1, 40, true)}
   , 30000, 2000, halfWidth, halfHeight, true, 5));
   */
  spawnList.add(new Spawner(new Object[]{new HomingMissile(AI, halfWidth, halfHeight, 50, GREY, 2000, 0, 0, 0, 10), new HomingMissile(AI, halfWidth, halfHeight, 50, WHITE, 2000, 0, 0, 0, 10)}
    , 15000, 100/DIFFICULTY_LEVEL, halfWidth, halfHeight, false, 50*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, PApplet.parseInt(playerSize*0.5f), PApplet.parseInt(playerSize*0.5f), 10, 100, 1, new AutoGun())}
    , 20000, 4000/DIFFICULTY_LEVEL, true, 10*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new Drone(players.size(), halfWidth, halfHeight, PApplet.parseInt(playerSize*0.5f), PApplet.parseInt(playerSize*0.5f), 10, 200, new AutoGun())}
    , 35000, 12000/DIFFICULTY_LEVEL, true, 3*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new Turret(players.size(), AI, halfWidth, halfHeight, playerSize, playerSize, 50, new TimeBomb())}
    , 55000, 14000/DIFFICULTY_LEVEL, true, 5*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, PApplet.parseInt(playerSize*0.5f), PApplet.parseInt(playerSize*0.5f), 10, 50, 1, new Pistol())}
    , 70000, halfWidth, halfHeight));
  spawnList.add(new Spawner(new Object[]{new Turret(players.size(), AI, halfWidth, halfHeight, playerSize, playerSize, 100, new Bazooka())}
    , 85000, 15000/DIFFICULTY_LEVEL, true, 3*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, PApplet.parseInt(playerSize*0.5f), PApplet.parseInt(playerSize*0.5f), 10, 60,2, new CloneMultiply())}
    , 90000, 8000/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 30));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, PApplet.parseInt(playerSize*0.5f), PApplet.parseInt(playerSize*0.5f), 10, 150, 1, new SemiAuto())}
    , 120000, 10000/DIFFICULTY_LEVEL, true, 5*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, PApplet.parseInt(playerSize*0.5f), PApplet.parseInt(playerSize*0.5f), 10, 150, 1, new Pistol())}
    , 130000, 10000/DIFFICULTY_LEVEL, true, 3*DIFFICULTY_LEVEL));
}



public void spawningReset() {
  for (int i=players.size()-1; i>= AmountOfPlayers; i--) {
    players.remove(i);
  }
  stamps.clear();  
  survivalTime=0;
  gameOver=false;
  players.add(AI);
  projectiles.clear();
  particles.clear(); 
  spawnList.clear();
  forwardTime=0;
  reversedTime=0;
  freezeTime=0;
  fallenTime=0;
  stampTime=0;
  spawningSetup();
    particles.add(new  Text("Survival", 200, halfHeight, 5, 0, 100, 0, 10000, BLACK, 0) );
    particles.add(new Gradient(10000, 0, 500, 0, 0, 500, 0.5f, 0, GREY));
  /*for (Spawner s : spawnList) {
   s.dead=false;
   s.times=s.initTimes;
   }*/
 if(!noFlash) background(255);
}
public void survivalSpawning() {
  if(!gameOver) for (Spawner s : spawnList)  s.update();
}


class Spawner {

  Object object[];
  long startTime, timer;
  int x, y;
  float times, interval, initTimes;
  boolean repeat, random, dead;

  <G> Spawner(G _object[], long _startTime, float _interval, int _x, int _y, boolean _random, float _times) {
    object=_object;
    startTime=_startTime;
    interval=_interval;
    timer=stampTime;
    initTimes=PApplet.parseInt(_times);
    random=_random;
    x=_x;
    y=_y;
    times=PApplet.parseInt(_times);
    if (times>0)repeat=true;
  }
  <G> Spawner(G _object[], long _startTime, float _interval, boolean _random, float _times) {
    object=_object;
    startTime=_startTime;
    interval=_interval;
    random=_random;
    timer=stampTime;
    initTimes=PApplet.parseInt(_times);
    times=PApplet.parseInt(_times);
    if (times>0)repeat=true;
  }
  <G> Spawner(G _object[], long _startTime, int _x, int _y) {
    object=_object;
    startTime=_startTime;
    x=_x;
    y=_y;
  }
  <G> Spawner(G _object[], long _startTime) {
    object=_object;
    startTime=_startTime;
  }

  public void update() {
    if (!dead && stampTime>startTime ) {
      if (repeat) {
        if (timer+interval<stampTime) {
          times--;
          timer=stampTime;
          //println("times"+times);

          if (times<1) {
            dead=true;          
            // println("dead");
          }
          try {
            spawn();
          }
          catch(Exception e) {
            println(e);
          }
        }
      } else {
        try {
          spawn();
          dead=true;
          //  println("dead");
        }
        catch(Exception e) {
          println(e);
        }
      }
    }
  }

  public void  spawn() throws Exception {
    //println("SPAWN");


    for (Object o : object) {
      if (random) {
        x=PApplet.parseInt(random(width));
        y=PApplet.parseInt(random(height));
      }


      if ( o instanceof Projectile) {
        particles.add(new ShockWave(x, y, 20, 16, 150, AI.playerColor));
        Projectile temp=((Projectile)o).clone();
        temp.deathTime=stampTime+(temp.deathTime-temp.spawnTime);
        temp.spawnTime=startTime;
        temp.x=x;
        temp.y=y;
        projectiles.add(temp);
        /*((Projectile)o).spawnTime+=startTime;
         ((Projectile)o).deathTime+=startTime;
         ((Projectile)o).x=x;
         ((Projectile)o).y=y;*/
        //projectiles.add( ((Projectile)o).clone());
      } else if ( o instanceof Player) {
        particles.add(new ShockWave(x, y, 40, 26, 350, AI.playerColor));
        Player temp = ((Player)o).clone();
        temp.cx=x;
        temp.cy=y;
        temp.x=x-temp.radius;
        temp.y=x-temp.radius;
        players.add(temp);
        /*((Player)o).cx=x;
         ((Player)o).cy=y;
         ((Player)o).x=x;
         ((Player)o).y=y;
         players.add(((Player)o).clone());*/
      } else if ( o instanceof Particle) {
        ((Particle)o).x=x;
        ((Particle)o).y=y;
        particles.add(((Particle)o).clone());
      }
    }
  }
}


<G> void  spawn(G object, int x, int y) {
  if ( object instanceof Projectile) {
    ((Projectile)object).x=x;
    ((Projectile)object).y=y;
    projectiles.add((Projectile)object);
  } else if ( object instanceof Player) {
    ((Player)object).cx=x;
    ((Player)object).cy=y;
    players.add((Player)object);
  } else if ( object instanceof Particle) {
    ((Particle)object).x=x;
    ((Particle)object).y=y;
    particles.add(((Particle)object).clone());
  }
}


<G> void  spawn(G object) {
  if ( object instanceof Projectile) {
    projectiles.add((Projectile)object);
  } else if ( object instanceof Player) {
    players.add(((Player)object).clone());
  } else if ( object instanceof Particle) {
    particles.add(((Particle)object).clone());
  }
}
 enum AbilityType {
  ACTIVE, PASSIVE,NATIVE,GLOBAL
}
 enum GameType {
  BRAWL, SURVIVAL,PUZZLE
}

public void targetHommingVarning(Player target) {
  final int r=130;
  float tcx=target.cx, tcy=target.cy;
  strokeWeight(2);
  stroke(255);
  noFill();
  ellipse(tcx, tcy, r, r);
  line(tcx+r, tcy, tcx-r, tcy);
  // line(tcx, tcy, tcx+r, tcy);
  line(tcx, tcy+r, tcx, tcy-r);
  // line(tcx, tcy, tcx, tcy+r);
}


public void crossVarning(int x, int y) {
  final int r=40;
  // float tcx=target.cx, tcy=target.cy;
  strokeWeight(3);
  stroke(255);
  noFill();
  //ellipse(tcx, tcy, r, r);
  line(x+r, y+r, x-r, y-r);
  //line(tcx, tcy, tcx+r, tcy);
  line(x+r, y-r, x-r, y+r);
  //line(tcx, tcy, tcx, tcy+r);
  strokeWeight(6);
  ellipse(x, y, r*4, r*4);
  strokeWeight(3);
  ellipse(x, y, r*5, r*5);
}

public static float angleAgainst(int x, int y, int x2, int y2) {
  //return  degrees(-( atan((y2-y)/(x2-x))));
  return  degrees(atan2(y2-y, x2-x));
}

public Player seek(Player m, int senseRange) {
  for (int sense = 0; sense < senseRange; sense++) {
    for (   Player p : players) {
      if (p!= m && !p.dead && p.ally!=m.ally) {
        if (dist(p.x, p.y, m.x, m.y)<sense*0.5f) {  
          return p;
        }
      }
    }
  }
  return null;
}  
public static float  calcAngleBetween(Player target, Player from) {
  return degrees(atan2((target.cy-from.cy), (target.cx-from.cx)))%360;
}
public static float  calcAngleBetween(Projectile target, Projectile from) {
  return degrees(atan2((target.y-from.y), (target.x-from.x)))%360;
}

public static float  calcAngleBetween(Projectile target, Player from) {
  return degrees(atan2((target.y-from.cy), (target.x-from.cx)))%360;
}

public static float  calcAngleBetween(Player target, Projectile from) {
  return degrees(atan2((target.cy-from.y), (target.cx-from.x)))%360;
}


public void generateRandomAbilities(int index, AbilityType _abilityType) {
  for (Player p : players) {      
    if (p!=AI && !p.clone &&  !p.turret) {  // no turret or clone weapon switch
      p.abilityList.get(index).reset();
      p.abilityList.set(index, (_abilityType==AbilityType.ACTIVE)?new Random().randomize():new RandomPassive().randomize());

      //abilities[i].owner=players.get(i);
      p.abilityList.get(index).setOwner(p);
      //p.ability= p.abilityList.get(0);
      announceAbility( p, index);
    }
  }
}
public void keyPressed() {

  key=Character.toLowerCase(key);// convert key to lower Case
  if (key == '#') {                    // enablecheats
    cheatEnabled=(cheatEnabled==true)?false:true;
  }
  if (key == '"') {                    // enablecheats
    debug=(debug==true)?false:true;
  }
  if (key == '\u00a4') {      
    //ac.setPause(true);
    mute=!mute;
    musicPlayer.pause(mute);
    particles.add(new Flash(3000, 3, 0));
  }

  if ((cheatEnabled||playersAlive<=1 ) && key==ResetKey) {
    if (!noFlash) background(255);
    for (int i =players.size()-1; i>= 0; i--) {
      if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
    }
    if(gameMode==GameType.SURVIVAL)spawningReset();
    if(RandomSkillsOnDeath)generateRandomAbilities(0,AbilityType.ACTIVE);

   /* //random weapon
     for (Player p:players) {    
      if (p!=AI&&!p.clone &&  !p.turret) {  // no turret or clone respawn
        p.reset();
        announceAbility( p, 1);
      } else {
        p.dead=true;
        p.state=0;
      }
    }*/

    //random weapon end

    for (Player p : players) {      
      if (p.index!=-1 )
        if (p!=AI &&!p.clone &&  !p.turret) {  // no turret or clone respawn
          p.reset();
          announceAbility( p, 0);
        } else {
          p.dead=true;
          p.state=0;
        }
    }
  }

  if (cheatEnabled ) {
    if (key==Character.toLowerCase('6')) {
     /* for (Player p : players) {      
        if (!p.clone &&  !p.turret && p!=AI) {  // no turret or clone weapon switch
          p.abilityList.get(1).reset();
          p.abilityList.set(1, new RandomPassive().randomize());
          p.abilityList.get(1).setOwner(p);
          announceAbility( p, 1);
        }
      }*/
       generateRandomAbilities(1,AbilityType.PASSIVE);

    }
    if (key==Character.toLowerCase(RandomKey)) {
      
            generateRandomAbilities(0,AbilityType.ACTIVE);
/*
      for (Player p : players) {      
        if (p!=AI && !p.clone &&  !p.turret) {  // no turret or clone weapon switch
          p.abilityList.get(0).reset();
          p.abilityList.set(0, new Random().randomize());

          //abilities[i].owner=players.get(i);
          p.abilityList.get(0).setOwner(p);
          //p.ability= p.abilityList.get(0);
          announceAbility( p, 0);
        }
      }*/
      /*for (int i=0; i<players.size(); i++) {
       if (!players.get(i).clone &&  !players.get(i).turret) {  // no turret or clone weapon switch
       abilities[i].reset();
       abilities[i]=new Random().randomize();
       
       //abilities[i].owner=players.get(i);
       abilities[i].setOwner(players.get(i));
       players.get(i).ability=abilities[i];
       announceAbility( players.get(i));
       }
       }*/
    }
    if (key==Character.toLowerCase('9')) {
      for (int i=0; i<players.size()-1; i++) {
        if (!players.get(i).clone &&  !players.get(i).turret) {  // no turret or clone weapon switch
          try {
            abilities[i][0]=new Detonator().clone();
          }
          catch(CloneNotSupportedException e) {
            println("not cloned from Random");
          }
          //abilities[i].owner=players.get(i);
          abilities[i][0].setOwner(players.get(i));
          //players.get(i).ability=abilities[i];
        }
      }
    }
    if (key==Character.toLowerCase('8')) {

      for (Player p : players) {      
        if (!p.clone &&  !p.turret) {  // no turret or clone weapon switch
          p.abilityList.get(0).energy=99999;
        }
      }
      /*
      for (int i=0; i<players.size(); i++) {
       if (!players.get(i).clone &&  !players.get(i).turret) {  //infinate energy
       //abilities[i].owner=players.get(i);
       players.get(i).ability.energy=9999999;
       }
       }*/
    }
    if (key==DELETE) {
      prevMillis=millis(); 
      addMillis=0; 
      forwardTime=0; 
      reversedTime=0; 
      freezeTime=0; 
      stampTime=millis(); 
      fallenTime=0;
      stamps.clear();
      projectiles.clear();
      particles.clear();
      if (!noFlash)background(255);
      for (int i =players.size()-1; i>= 0; i--) {
        //players.get(i).holdTrigg=true;
        if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
      }
    }
    if (key==Character.toLowerCase('-')) {
      //players.get(mouseSelectedPlayerIndex).ability.reset();
      for (int i =players.size()-1; i>= 0; i--) {
        if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
      }
      players.get(mouseSelectedPlayerIndex).abilityList.get(0).reset();
      for (  int i=0; i<abilityList.length; i++) {
        if (players.get(mouseSelectedPlayerIndex).abilityList.get(0).getClass()==abilityList[i].getClass()) {
          if (i<=0)i=abilityList.length;
          try {
            players.get(mouseSelectedPlayerIndex).abilityList.set(0, abilityList[i-1].clone());
            players.get(mouseSelectedPlayerIndex).abilityList.get(0).setOwner(players.get(mouseSelectedPlayerIndex));
            announceAbility( players.get(mouseSelectedPlayerIndex), 0);
          }
          catch(CloneNotSupportedException e) {
            println("not cloned from Random");
          }
        } //else println("not player"+ i);
      }

      /*players.get(mouseSelectedPlayerIndex).ability.reset();
       for (  int i=0; i<abilityList.length; i++) {
       //if (players.get(0).ability==abilityList[i]) {
       if (players.get(mouseSelectedPlayerIndex).ability.getClass()==abilityList[i].getClass()) {
       //println("ability match "+i+" "+abilityList[i].getClass());
       //if (i>=abilityList.length)i=0;
       if (i<=0)i=abilityList.length;
       try {
       //abilities[0]= abilityList[i-1].clone();
       //abilityList[i-1].clone().setOwner(players.get(0));
       players.get(mouseSelectedPlayerIndex).ability=abilityList[i-1].clone();
       players.get(mouseSelectedPlayerIndex).ability.setOwner(players.get(mouseSelectedPlayerIndex));
       announceAbility( players.get(mouseSelectedPlayerIndex));
       }
       catch(CloneNotSupportedException e) {
       println("not cloned from Random");
       }
       } else println("not player"+ i);
       }*/
    }
    if (key==Character.toLowerCase('+')) {
      //players.get(mouseSelectedPlayerIndex).ability.reset();
      for (int i =players.size()-1; i>= 0; i--) {
        if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
      }
      players.get(mouseSelectedPlayerIndex).abilityList.get(0).reset();
      for (  int i=0; i<abilityList.length; i++) {
        if (players.get(mouseSelectedPlayerIndex).abilityList.get(0).getClass()==abilityList[i].getClass()) {
          //println("ability match "+i+" "+abilityList[i].getClass());
          if (i>=abilityList.length-1)i=-1;
          try {
            players.get(mouseSelectedPlayerIndex).abilityList.set(0, abilityList[i+1].clone());
            players.get(mouseSelectedPlayerIndex).abilityList.get(0).setOwner(players.get(mouseSelectedPlayerIndex));
            announceAbility( players.get(mouseSelectedPlayerIndex), 0);
          }
          catch(CloneNotSupportedException e) {
            println("not cloned from Random");
          }
          break;
        }
      }
      /* players.get(mouseSelectedPlayerIndex).ability.reset();
       for (  int i=0; i<abilityList.length; i++) {
       if (players.get(mouseSelectedPlayerIndex).ability.getClass()==abilityList[i].getClass()) {
       //println("ability match "+i+" "+abilityList[i].getClass());
       if (i>=abilityList.length-1)i=-1;
       try {
       players.get(mouseSelectedPlayerIndex).ability=abilityList[i+1].clone();
       players.get(mouseSelectedPlayerIndex).ability.setOwner(players.get(mouseSelectedPlayerIndex));
       announceAbility( players.get(mouseSelectedPlayerIndex));
       }
       catch(CloneNotSupportedException e) {
       println("not cloned from Random");
       }
       break;
       }
       }*/
    }
    /*if (key==Character.toLowerCase(keyIceDagger)) {
     projectiles.add( new IceDagger(players.get(1), int( players.get(1).x+players.get(1).w*.5), int(players.get(1).y+players.get(1).h*.5), 30, players.get(1).playerColor, 800, players.get(1).angle, players.get(1).ax*15, players.get(1).ay*15, 8));
     }*/
    if (key==Character.toLowerCase( keySlow)) {
      quitOrigo();
      musicPlayer.pause(false);
      slow=(slow)?false:true;
      S =(slow)?slowFactor:1;
      timeBend=S*F;
      speedControl.clear();
      speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 800); //now slow
      drawTimeSymbol();
    }
    if (key==Character.toLowerCase(keyRewind)) {

      for (int i=0; i< players.size (); i++) {
        if (!reverse || players.get(i).reverseImmunity) { 
          if (key==Character.toLowerCase(players.get(i).triggKey)) {// ability trigg key
            //players.get(i).ability.release();
            for (Ability a : players.get(i).abilityList)  a.release();
            players.get(i).holdTrigg=false;
          }
        }
      }
      musicPlayer.pause(false);
      reverse=(reverse)?false:true;
      speedControl.clear();
      speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 600); //now rewind
      controlable=(controlable)?false:true;
      drawTimeSymbol();
      quitOrigo();
    }
    if (key==Character.toLowerCase(keyFreeze)) {
      quitOrigo();
      for (int i=0; i<players.size (); i++) {  
        stamps.add( new ControlStamp(players.get(i).index, PApplet.parseInt(players.get(i).x), PApplet.parseInt(players.get(i).y), players.get(i).vx, players.get(i).vy, players.get(i).ax, players.get(i).ay));
      }
      freeze=(freeze)?false:true;
      speedControl.clear();
      speedControl.addSegment((freeze)?0:1, 150); //now stop
      controlable=(controlable)?false:true;
      for (int i=0; i< players.size (); i++) {
        //stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new ControlStamp(i, PApplet.parseInt(players.get(i).x), PApplet.parseInt( players.get(i).y), 0, 0, 0, 0));
        stamps.add( new ControlStamp(i, PApplet.parseInt(players.get(i).x), PApplet.parseInt( players.get(i).y), players.get(i).vx, players.get(i).vy, players.get(i).ax, players.get(i).ay));
      }
      controlable=(controlable)?false:true;
      drawTimeSymbol();
    }
    if (key==Character.toLowerCase(keyFastForward)) {
     quitOrigo();
     if (!noFlash)background(0, 255, 255);
      fastForward=(fastForward)?false:true;
      F =(fastForward)?speedFactor:1;
      timeBend=S*F;
      speedControl.clear();
      speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 400); //now fastforward
      //controlable=(controlable)?false:true;
      drawTimeSymbol();
    }
  }

  //println(" code: "+ keyCode+"  key:"+int(key)+ " char:"+key  );  // test key code
  /* for (int i=0; i< players.size (); i++) {
   //if (keyCooldown[i]<=0) {
   if ((!reverse || players.get(i).reverseImmunity)|| players.get(i).ability.meta) { 
   if (key==Character.toLowerCase(players.get(i).triggKey)) {// ability trigg key
   // background(255);
   players.get(i).ability.press();
   players.get(i).holdTrigg=true;
   }
   }
   
   if (keyCode==players.get(i).up) {//up
   if ((!reverse || players.get(i).reverseImmunity))players.get(i).control(1);
   players.get(i).holdUp=true;
   }
   if (keyCode==players.get(i).down) {//down
   if ((!reverse || players.get(i).reverseImmunity)) players.get(i).control(0);
   players.get(i).holdDown=true;
   }
   if (keyCode==players.get(i).left) {//left
   if ((!reverse || players.get(i).reverseImmunity)) players.get(i).control(4);
   players.get(i).holdLeft=true;
   }
   if (keyCode==players.get(i).right) {//right
   if ((!reverse || players.get(i).reverseImmunity)) players.get(i).control(5);
   players.get(i).holdRight=true;
   }
   }*/
  try {
    for (Player p : players) {
      if (!p.turret) {
        if ((!reverse || p.reverseImmunity)|| p.abilityList.get(0).meta) { 
          if (key==Character.toLowerCase(p.triggKey)) {// ability trigg key
            //p.ability.press();
            for (Ability a : p.abilityList)  a.press();
            p.holdTrigg=true;
          }
        }

        if (keyCode==p.up) {//up
          if ((!reverse || p.reverseImmunity))p.control(1);
          p.holdUp=true;
        }
        if (keyCode==p.down) {//down
          if ((!reverse || p.reverseImmunity)) p.control(0);
          p.holdDown=true;
        }
        if (keyCode==p.left) {//left
          if ((!reverse || p.reverseImmunity)) p.control(4);
          p.holdLeft=true;
        }
        if (keyCode==p.right) {//right
          if ((!reverse || p.reverseImmunity)) p.control(5);
          p.holdRight=true;
        }
      }
    }
  } 
  catch(Exception e) {
    println(e);
  }
  //   keyCooldown[i]=keyResponseDelay;

  // keyCooldown[i]--;
  //  }
}
public void checkKeyHold() { // hold keys
  /*for (int i=0; i< players.size (); i++) {
   { 
   if (players.get(i).holdTrigg) {// ability trigg key
   if (!reverse || players.get(i).reverseImmunity)players.get(i).ability.hold();
   }
   if (players.get(i).holdUp) {//up
   if (!reverse || players.get(i).reverseImmunity) players.get(i).control(1);
   }
   if (players.get(i).holdDown) {//down
   if (!reverse || players.get(i).reverseImmunity)players.get(i).control(0);
   }
   if (players.get(i).holdLeft) {//left
   if (!reverse || players.get(i).reverseImmunity)players.get(i).control(4);
   }
   if (players.get(i).holdRight) {//right
   if (!reverse || players.get(i).reverseImmunity) players.get(i).control(5);
   }
   }
   }*/
  for (Player p : players) {
    { 
      if (!p.turret) {
        if (p.holdTrigg) {// ability trigg key
          if (!reverse || p.reverseImmunity) {
            //p.ability.hold();
            for (Ability a : p.abilityList)  a.hold();
          }
        }
        if (p.holdUp) {//up
          if (!reverse || p.reverseImmunity) p.control(1);
        }
        if (p.holdDown) {//down
          if (!reverse || p.reverseImmunity)p.control(0);
        }
        if (p.holdLeft) {//left
          if (!reverse || p.reverseImmunity)p.control(4);
        }
        if (p.holdRight) {//right
          if (!reverse || p.reverseImmunity) p.control(5);
        }
      }
    }
  }
}

public void keyReleased() {

  key=Character.toLowerCase(key);// convert key to lower Case

  /* for (int i=0; i< players.size (); i++) {
   if (key==Character.toLowerCase(players.get(i).triggKey)) {// ability trigg key
   if ( players.get(i).ability.meta || !reverse)  players.get(i).ability.release();
   players.get(i).holdTrigg=false;
   }
   // if (!reverse || players.get(i).reverseImmunity) { 
   if (keyCode==players.get(i).up) {//up
   players.get(i).holdUp=false;
   }
   if (keyCode==players.get(i).down) {//down
   players.get(i).holdDown=false;
   }
   if (keyCode==players.get(i).left) {//left
   players.get(i).holdLeft=false;
   }
   if (keyCode==players.get(i).right) {//right
   players.get(i).holdRight=false;
   }
   }*/
  for ( Player p : players) {
    if (!p.turret) {
      if (key==Character.toLowerCase(p.triggKey)) {// ability trigg key
        if ( p.abilityList.get(0).meta || !reverse)  //p.ability.release();
          for (Ability a : p.abilityList)  a.release();
        p.holdTrigg=false;
      }
      if (keyCode==p.up) {//up
        p.holdUp=false;
      }
      if (keyCode==p.down) {//down
        p.holdDown=false;
      }
      if (keyCode==p.left) {//left
        p.holdLeft=false;
      }
      if (keyCode==p.right) {//right
        p.holdRight=false;
      }
    }
  }
}
/*void stop() {
 ac.stop();
 super.stop();
 } */
public void dispose() {
  ac.stop();
  an.stop();
  super.dispose();
}

public void displayInfo() {
  fill(0);
  text("add Time: "+addMillis+" freezeTime: " + freezeTime+" reversed: " + reversedTime+" forward: " + forwardTime+ " current: "+  stampTime +" fallenTime: "+fallenTime, halfWidth, 50);
  text("version: "+version, halfWidth, 20);
  text("players: "+players.size()+" projectiles: "+projectiles.size()+" particles: "+particles.size()+" stamps: "+stamps.size(), halfWidth, 75);
  text(frameRate, width-80, 50);
}
public void displayClock() {
  fill(0);
  textSize(40);
  text(" Time: "+  PApplet.parseInt(stampTime*0.001f), halfWidth, 60);
  textSize(18);
  text("version: "+version, halfWidth, 20);
}
public void screenShake() {
  if (shakeTimer>0) {
    shake(2*shakeTimer);
  } else {
    shakeTimer=0;
  } // shake screen
}
public void shake(int amount) {
  if (!noShake) {
    // int shakeX=0, shakeY=0;
    if (!freeze) {
      shakeX=PApplet.parseInt(random(amount)-amount*0.5f);
      shakeY=PApplet.parseInt(random(amount)-amount*0.5f);
      shakeTimer--;
    }
    translate( shakeX*shakeAmount, shakeY*shakeAmount);
  }
}

public void checkPlayerVSPlayerColloision() {
  if (!freeze &&!reverse) {
    for (Player p1 : players) {       
      for (Player p2 : players) {       
        if (p1.ally!=p2.ally && !p1.dead && !p2.dead ) { //  && p1!=p2
         //    if (dist(p1.x, p1.y, p2.x, p2.y)<playerSize) { // old collision
          if (dist(p1.cx, p1.cy, p2.cx, p2.cy)<p1.radius+p2.radius) {
            p1.hit(p2.damage);
            float  deltaX =  p1.cx -  p2.cx, deltaY =  p1.cy -  p2.cy;
            p1.pushForce( ((p1.radius+p2.radius)-dist(p2.cx, p2.cy, p1.cx, p1.cy)), atan2(deltaY, deltaX) * 180 / PI);
          }
        }
      }
    }
  }
}

public void checkPlayerVSProjectileColloision() {
  if (!freeze &&!reverse) {

    try {
      for (Projectile o : projectiles) {    

        for (Player p : players) {      
          if (p.ally!=o.ally && !p.dead && !o.dead ) { // && o.playerIndex!=p.ally
            //if (dist(o.x, o.y, p.cx, p.cy)<playerSize) { //old collision
               if (dist(o.x, o.y, p.cx, p.cy)<p.radius+o.size*.5f) {

              //  players.get(j).hit(projectiles.get(i).damage);
              p.pushForce(o.force, o.angle);
              o.hit(p);
            }
          }
        }
      }
    }
    catch(Exception e) {
      println(e +" onmain projectile ");
    }
  }
}
public void checkProjectileVSProjectileColloision() {
  if (!freeze &&!reverse) {
    /* for (int i=0; i< projectiles.size (); i++) {    
     for (int j=0; j<projectiles.size (); j++) {      
     if (projectiles.get(j).ally!=projectiles.get(i).ally && !projectiles.get(j).dead && !projectiles.get(i).dead && projectiles.get(i)!=projectiles.get(j)  ) {
     if (dist(projectiles.get(i).x, projectiles.get(i).y, projectiles.get(j).x, projectiles.get(j).y)<projectiles.get(i).size*0.5+projectiles.get(j).size*0.5) {
     if (projectiles.get(i) instanceof  Reflectable  && projectiles.get(j) instanceof Reflector) {
     Reflectable reflectObject = (Reflectable)projectiles.get(i);
     Reflector reflectorObject = (Reflector)projectiles.get(j);
     reflectObject.reflect(projectiles.get(j).angle, projectiles.get(j).owner);
     reflectorObject.reflecting();
     }
     }
     }
     }
     }*/
    for (Projectile p1 : projectiles) {    
      for (Projectile p2 : projectiles) {      
        if (p2.ally!=p1.ally && !p2.dead && !p1.dead ) { //  && p1!=p2
          if (p1 instanceof  Reflectable  && p2 instanceof Reflector) {
            if (dist(p1.x, p1.y, p2.x, p2.y)<p1.size*0.5f+p2.size*0.5f) {
              /*Reflectable reflectObject = (Reflectable)p1;
               Reflector reflectorObject = (Reflector)p2;
               reflectObject.reflect(p2.angle, p2.owner);
               reflectorObject.reflecting();*/
              ((Reflectable)p1).reflect(p2.angle, p2.owner);
              ((Reflector)p2).reflecting();
              //reflectObject.reflect(p2.angle, p2.owner);
              //reflectorObject.reflecting();
            }
          }
          if (p1 instanceof  Destroyable  && p2 instanceof Destroyer) {
            if (dist(p1.x, p1.y, p2.x, p2.y)<p1.size*0.5f+p2.size*0.5f) {
              ((Destroyable)p1).destroy(p2);
              ((Destroyer)p2).destroying(p1);
            }
          }
        }
      }
    }
  }
}


public void checkPlayerVSProjectileColloisionLine() {
}

public void checkWinner() {
  int playerAliveIndex=0;
  playersAlive=0;
  for (Player p : players) {      
    if (!p.dead && !p.turret && !p.clone) {
      playersAlive++;
      playerAliveIndex=p.index;
    }
  }

  if (playersAlive<=1) {
    textSize(80);
    switch(gameMode) {
    case BRAWL:

      text(" Winner is player "+(playerAliveIndex+1), halfWidth, halfHeight);
      text(" Press ["+ResetKey+"] to restart", halfWidth, height*0.6f);
      break;
    case SURVIVAL:
      if (playersAlive==0) {
        gameOver=true;
        if(survivalTime<=0)survivalTime=PApplet.parseInt(stampTime*.001f);
        text(" Survived for "+survivalTime+ "  sek", halfWidth, halfHeight);
        text(" Press ["+ResetKey+"] to restart", halfWidth, height*0.6f);
      }
      break;
      
    case PUZZLE:
      if (playersAlive<1) {
        text(" The survivor is player "+(playerAliveIndex+1), halfWidth, halfHeight);
        text(" Press ["+ResetKey+"] to restart", halfWidth, height*0.6f);
      }
      break;
    }
    textSize(18);
  }
}

public void drawTimeSymbol() {
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
      GUILayer.vertex(offsetX-(75*timeBend), offsetY+100);
      GUILayer.vertex(offsetX, offsetY+200);
      GUILayer.endShape();
      GUILayer.endDraw();
    }
    if (!reverse) {
      GUILayer.beginDraw();
      GUILayer.clear();
      GUILayer.beginShape();
      GUILayer.vertex(offsetX, offsetY);
      GUILayer.vertex(offsetX+(75*timeBend), offsetY+100);
      GUILayer.vertex(offsetX, offsetY+200);
      GUILayer.endShape();
      GUILayer.endDraw();
    }
  }
}

public void quitOrigo() {
  origo=false;
  if (stampTime<0) {
    stampTime=0;
    reverse=false;
    musicPlayer.setPosition(1); //resetmusic s
    particles.add(new Flash(1500, 5, WHITE));   // flash
  }
}
public void mouseDot() {
  strokeWeight(5);
  //ellipse(pmouseX, pmouseY, 10, 10);
  point(mouseX, mouseY);
}

public void announceAbility(Player p, int index ) {
  if(p.textParticle!=null)particles.remove( p.textParticle );

  p.textParticle = new Text(p, p.abilityList.get(index).name, 0, -75, 30, 0, 1500, BLACK, 0);
  particles.add( p.textParticle );
}

public void mousePressed() {

  try {
    for (Player p : players) {
      if (p.mouse &&(!reverse || p.reverseImmunity || p.abilityList.get(0).meta)) { 
        if (mouseButton==LEFT) {
          //p.ability.press();
            for (Ability a : p.abilityList)  a.press();
          p.holdTrigg=true;
        }
      }
    }
  }
  catch(Exception e) {
        println(e);
  }
  if (cheatEnabled) {
       spawn(new HomingMissile(AI, mouseX, mouseY, 70, BLACK, 5000, 0, 0, 0, 10));

    // float X=(mouseX*zoom)+(width*(1-zoom)*mouseX);
    // float Y=(mouseY*zoom)+(height*(1-zoom)*mouseY);
      float X=mouseX;
      float Y=mouseY;
            ellipse(X,Y,200,200);
    for (int i=0; i<players.size(); i++) {
      if (!players.get(i).dead && dist(players.get(i).cx, players.get(i).cy, X, Y)<100) {

        mouseSelectedPlayerIndex=i;
        particles.add( new Text("player "+(i+1)+" selected", PApplet.parseInt(X), PApplet.parseInt(Y-75), 0, 0, 40, 0, 500, color(players.get(i).playerColor), 1));
      }
    }
  }
}
public void mouseHold() {
  /*for (int i=0; i< players.size (); i++) {
   if (players.get(i).mouse &&(!reverse || players.get(i).reverseImmunity || players.get(i).ability.meta)) { 
   
   if (players.get(i).holdTrigg) {// ability trigg key
   players.get(i).ability.hold();
   }
   }
   }*/
  for (Player p : players) {
    if (p.mouse &&(!reverse || p.reverseImmunity || p.abilityList.get(0).meta)) { 
      if (p.holdTrigg) {// ability trigg key
        //p.ability.hold();
        for (Ability a : p.abilityList) a.hold();
      }
    }
  }
}
public void mouseReleased() {
  /* for (int i=0; i< players.size (); i++) {
   if (players.get(i).mouse &&(!reverse || players.get(i).reverseImmunity|| players.get(i).ability.meta)) { 
   if (mouseButton==LEFT) {
   players.get(i).holdTrigg=false;
   players.get(i).ability.release();
   }
   }
   }*/
  for (Player p : players) {
    if (p.mouse &&(!reverse || p.reverseImmunity|| p.abilityList.get(0).meta)) { 
      if (mouseButton==LEFT) {
        p.holdTrigg=false;
       // p.ability.release();
        for (Ability a : p.abilityList)  a.release();
      }
    }
  }
}
class Player implements Cloneable {
  PShape arrowSVG = loadShape("arrow.svg");
  int  index, ally, radius, outlineDiameter, w, h, up, down, left, right, triggKey, deColor;
  int state=1, maxHealth=200, health=maxHealth, damage=1, armor;
  final int barSize=12, barDiameter=75, invinsTime=400, buttonHoldTime=300;
  final int mouseMargin=200;
  //float MAX_MOUSE_ACCEL=0.0035;
  final float mouseMaxAccel=1.4f;
  float  x, y, vx, vy, ax, ay, cx, cy, angle, keyAngle, f, s, bend, barFraction, fraction;
  boolean holdTrigg, holdUp, holdDown, holdLeft, holdRight, dead, stealth, hit, arduino, arduinoHold, mouse, clone, turret;
  PVector coord, speed, accel, arrow;
  float DEFAULT_MAX_ACCEL=0.15f, MAX_ACCEL=DEFAULT_MAX_ACCEL, DEFAULT_ANGLE_FACTOR=0.3f, ANGLE_FACTOR=DEFAULT_ANGLE_FACTOR, FRICTION_FACTOR, DEFAULT_ARMOR=0; 
  long invisStampTime;
  boolean invis, freezeImmunity, reverseImmunity, fastforwardImmunity, slowImmunity;
  //Ability ability;  
  ArrayList<Ability> abilityList= new ArrayList<Ability>();
  int playerColor;
  Particle textParticle;

  Player(int _index, int _playerColor, int _x, int _y, int _w, int _h, int _up, int _down, int _left, int _right, int _triggKey, Ability ..._ability) {
    FRICTION_FACTOR=DEFAULT_FRICTION;
    if (_up==888) { 
      mouse=true;
      FRICTION_FACTOR=0.045f;
      maxHealth=400;
      health=maxHealth;
    }
    index=_index;
    ally=_index;
    //ability= _ability[0];
    //ability.setOwner(this);
    //if (_ability[0]==null) ability= new Ability();
    for (Ability a : _ability) {
      this.abilityList.add(a);
      this.abilityList.get(0).setOwner(this);
      a.setOwner(this);
      //if (a==null) this.abilityList.add(new Ability());
    }
    playerColor=_playerColor;
    triggKey=_triggKey;
    speed= new PVector(0.0f, 0.0f);
    accel= new PVector(0.0f, 0.0f);
    coord= new PVector(_x, _y);
    arrow= new PVector(0.0f, 0.0f);
    x=_x;
    y=_y;
    w=_w;
    h=_h;
    radius=PApplet.parseInt(_w*0.5f);
    outlineDiameter=PApplet.parseInt(w*1.1f);
    cx=x+radius;
    cy=y+radius;
    up=_up;
    down= _down;
    left=_left;
    right=_right;
    // arrowSVG = loadShape("arrow.svg");
    shapeMode(CENTER);
    arrowSVG.disableStyle();
    shape(arrowSVG, -arrowSVG.width*0.5f+30, -arrowSVG.height, arrowSVG.width, arrowSVG.height);
  }
  public void checkBounds() {
    //if (!reverse && reverseImmunity) {
    if (x<0) {
      stamps.add( new ControlStamp(index, PApplet.parseInt(x), PApplet.parseInt(y), vx, vy, ax, ay));
      x=0;
      vx=0;
      ax=0;
      cx=x+radius;
      cy=y+radius;
      //accel.set(0.0, accel.y);
      //speed.set(0.0, speed.y);
      //coord.set(int(0.0), int(coord.y));
      wallHit(0);
    } else if (x>width-w) {
      stamps.add( new ControlStamp(index, PApplet.parseInt(x), PApplet.parseInt(y), vx, vy, ax, ay));
      x=width-w;
      vx=0;
      ax=0;
      cx=x+radius;
      cy=y+radius;
      //coord.set(width-w, coord.y);
      //accel.set(0.0, accel.y);
      //speed.set(0.0, speed.y);
      wallHit(0);
    }
    if (y<0) {
      stamps.add( new ControlStamp(index, PApplet.parseInt(x), PApplet.parseInt(y), vx, vy, ax, ay));
      y=0;
      vy=0;
      ay=0;
      cx=x+radius;
      cy=y+radius;
      //accel.set(accel.x, 0.0);
      //speed.set(speed.x, 0.0);
      //coord.set(coord.x, 0.0);
      wallHit(0);
    } else if (y>height-h) {
      stamps.add( new ControlStamp(index, PApplet.parseInt(x), PApplet.parseInt(y), vx, vy, ax, ay));
      y=height-h;
      vy=0;
      ay=0;
      cx=x+radius;
      cy=y+radius;
      //coord.set(coord.x, height-h);
      //speed.set(speed.x, 0.0);
      //accel.set(accel.x, 0.0);
      wallHit(0);
    }
  }

  public void display() {
    if (!stealth) {
      stroke((freeze && !freezeImmunity)?255:0);
      strokeWeight(2);
      fill(255, 0, 255-deColor*0.5f, 50+deColor);
      textAlign(CENTER, CENTER);
      //textMode(CENTER);
      //rect(x, y, w, h);
      ellipse(cx, cy, w, h);

      pushMatrix();
      translate(cx, cy);
      rotate(radians(angle+90));
      // shape(arrowSVG,x+radius- arrowSVG.width*.5, y-arrowSVG.height*.5, arrowSVG.width, arrowSVG.height); // default render
      fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s, 50+deColor);
      shape(arrowSVG, -arrowSVG.width*0.5f+30, -arrowSVG.height, arrowSVG.width, arrowSVG.height);
      popMatrix();

      //s fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s);
      displayAbilityEnergy(0);
      displayHealth();
      displayName();

      if (debug ) {
        if (abilityList.get(0).active) text("A", cx, y-h*2);
        if (holdTrigg)text("H", cx, cy-h);
      }

      if (deColor>0)deColor-=PApplet.parseInt(10*s*f);
    } else { //stealth
      stroke(255, 40);
      noFill();
      strokeWeight(1);
      ellipse(cx, cy, w, h);
    }
    if (freezeImmunity || reverseImmunity || fastforwardImmunity || slowImmunity) {
      noFill();
      ellipse(cx, cy, outlineDiameter, outlineDiameter);
    }
  }

  public void update() {
    // println(pow(1-FRICTION,timeBend));
    if (!dead) {
      f =(fastforwardImmunity)?1:F;
      s =(slowImmunity)?1:S;
      bend = f*s;
      if (!freeze || freezeImmunity) {
        calcAngle() ;
        if (reverse && !reverseImmunity) {

          vy/=1-FRICTION_FACTOR*bend;
          vx/=1-FRICTION_FACTOR*bend;
          //speed.set(speed.x/(1-FRICTION_FACTOR*bend), speed.y/(1-FRICTION_FACTOR*bend));
          ay/=1-FRICTION_FACTOR*bend;
          ax/=1-FRICTION_FACTOR*bend;
          //accel.set(accel.x/(1-FRICTION_FACTOR*bend), accel.y/(1-FRICTION_FACTOR*bend));
          y-=vy*bend;
          x-=vx*bend;
          //coord.set(coord.x-(speed.x*bend), coord.y-(speed.y*bend));
          vy-=ay*bend;
          vx-=ax*bend;
          cx=x+radius;
          cy=y+radius;
          //speed.set(speed.x-(accel.x*bend), speed.y-(accel.y*bend));

          for (Ability a : this.abilityList) a.regen();
        } else {
          for (Ability a : this.abilityList) a.regen();
          //speed.set(speed.x+(accel.x*bend), speed.y+(accel.y*bend));

          vx+=ax*bend;
          vy+=ay*bend;
          //coord.set(coord.x+(speed.x*bend), coord.y+(speed.y*bend));
          x+=vx*bend;
          y+=vy*bend;
          cx=x+radius;
          cy=y+radius;
          //speed.set(speed.x*(1-FRICTION_FACTOR*bend), speed.y*(1-FRICTION_FACTOR*bend));
          vx*=1-FRICTION_FACTOR*bend;
          vy*=1-FRICTION_FACTOR*bend;
          // accel.set(accel.x*(1-FRICTION_FACTOR*bend), accel.y*(1-FRICTION_FACTOR*bend));
          ax*=1-FRICTION_FACTOR*bend;
          ay*=1-FRICTION_FACTOR*bend;
          // calcAngle() ;
        }
      }
      //  ability.passive();
      for (Ability a : this.abilityList)a.passive();
    }
  }

  public void control(int dir) {
    if (dir==8) { // ability control
      //ability.press(); 
      for (Ability a : this.abilityList) a.press();
      //---------------    hold    --------------------
      int temp =PApplet.parseInt(prevMillis-millis());
      if (buttonHoldTime< temp) {
        //ability.hold();
        for (Ability a : this.abilityList) a.hold();
        //   TimeSpan t = new TimeSpan(DateTime.Now.Ticks);
      }

      //---------------    released    ----------------
      // if(arduinoHold){
      //key=ability.triggKey;
      //keyPressed();
    }
    if ((!freeze || freezeImmunity) && !dead && (!reverse || reverseImmunity)) {
      stamps.add( new ControlStamp(index, PApplet.parseInt(x), PApplet.parseInt(y), vx, vy, ax, ay));
      switch(dir) {
      case 0: // down
        // vy+=0.0;
        ay+=MAX_ACCEL*bend;
        //accel.set(accel.x, accel.y+MAX_ACCEL*bend);
        break;
      case 1: // up
        // vy+=-0.0;
        ay+=-MAX_ACCEL*bend;
        //accel.set(accel.x, accel.y-MAX_ACCEL*bend);
        break;
      case 2: // hold
        //ay=0;
        break;
      case 3: // none
        break;
      case 4: // left
        // vx+=-0.0;
        ax+=-MAX_ACCEL*bend;
        // accel.set(accel.x-MAX_ACCEL*bend, accel.y);
        break;
      case 5: // right
        //vx+=0.0;
        ax+=MAX_ACCEL*bend;
        //accel.set(accel.x+MAX_ACCEL*bend, accel.y);
        break;
      }
    }
  }

  public void mouseControl() {
    if ((!freeze || freezeImmunity) && !dead && (controlable || reverseImmunity) && mouse) {


      stamps.add( new ControlStamp(index, PApplet.parseInt(x), PApplet.parseInt(y), vx, vy, ax, ay));
      //*MAX_ACCEL*0.017*s*f;
      //*MAX_MOUSE_ACCEL*s*f;
      if (pmouseX-1<mouseX) {
        ax-=(pmouseX-mouseX)*MAX_ACCEL*0.028f*bend;
        if (ax<-mouseMaxAccel) {
          ax=-mouseMaxAccel;
        }
        // players.get(0).control(5);
        if (mouseX<mouseMargin) {
          mouseX=mouseMargin;
          pmouseX=mouseMargin;
        }
      }
      if (pmouseX+1>mouseX) {
        ax-=(pmouseX-mouseX)*MAX_ACCEL*0.028f*bend;
        if (players.get(0).ax>mouseMaxAccel) {
          players.get(0).ax=mouseMaxAccel;
        }
        //  players.get(0).control(4);
        if (mouseX>(width-mouseMargin)) {
          mouseX=(width-mouseMargin);
          pmouseX=(width-mouseMargin);
        }
      }
      if (pmouseY-1<mouseY) {
        ay-=(pmouseY-mouseY)*MAX_ACCEL*0.028f*bend;
        if (ay<-mouseMaxAccel) {
          ay=-mouseMaxAccel;
        }
        // players.get(0).control(0);
        if (mouseY<mouseMargin) {
          mouseY=mouseMargin;
          pmouseY=mouseMargin;
        }
      }
      if (pmouseY+1>mouseY) {
        ay-=(pmouseY-mouseY)*MAX_ACCEL*0.028f*bend;
        if (ay>mouseMaxAccel) {
          ay=mouseMaxAccel;
        }
        // players.get(0).control(1);
        if (mouseY>(height-mouseMargin)) {
          mouseY=(height-mouseMargin);
          pmouseY=(height-mouseMargin);
        }
      }
    }
  }


  public void calcAngle() {

    /* if (((-0.01) <accel.y && accel.y<(0.01)) && ((-0.02) <accel.x && accel.x<(0.01))) {  // volitile low value calc of angle is no alowed
     //  println("ax:"+ax + " ay:"+ay);
     } else {
     keyAngle=degrees( atan2( (accel.y+coord.y) - coord.y, (accel.x+coord.x) -coord.x ));
     }*/
    if (((-0.01f) <ay && ay<(0.01f)) && ((-0.02f) <ax && ax<(0.01f))) {  // volitile low value calc of angle is no alowed
      //  println("ax:"+ax + " ay:"+ay);
    } else {
      keyAngle=degrees( atan2( (ay+y) - y, (ax+x) -x ));
    }
    keyAngle= keyAngle % 360; 
    angle = angle % 360; 


    if (debug) {
      line(cx, cy, cx+cos(radians(keyAngle))*200, cy+sin(radians(keyAngle))*200);
      fill(0);
      textSize(20);
      text(angle, x, y);
    }
    /*angle-=keyAngle;
     float diff=keyAngle;
     keyAngle=0;
     
     //if(angle<0)angle+=360;
     if (angle < 360-angle) {
     //  angle+= angle*ANGLE_FACTOR;
     // text(angle, x, y);
     } else {
     //text(angle, x, y);
     // angle-=360-angle*ANGLE_FACTOR;
     }
     keyAngle+=diff;
     angle+=diff;*/
    if (angle<0 && (180+angle)+(180-keyAngle)<keyAngle-angle) {
      //text("L", x-50, y-50);
      angle-= (abs(angle+180)-abs(keyAngle-180))*ANGLE_FACTOR;
      angle+= 360;
    } else if (keyAngle<0 && (180+keyAngle)+(180-angle)<angle-keyAngle) {
      // text("H", x-50, y-50);
      angle+= (abs(keyAngle+180)-abs(angle-180))*ANGLE_FACTOR;
      angle-= 360;
    } else    angle+= (keyAngle-angle)*ANGLE_FACTOR;


    if (Float.isNaN(angle))angle=keyAngle; // if bugged out
  }


  public void hit(int damage) {
    stamps.add( new StateStamp(index, PApplet.parseInt(x), PApplet.parseInt(y), state, health, dead));
    damage=damage-=armor;
    if (damage>0) {
      health-=damage;
      deColor=255;
      state=2;
      hit=true;
    }
    for (Ability a : this.abilityList) {
      a.onHit();
    }
    // for (int i=0; i<2; i++) {
    particles.add(new Particle(PApplet.parseInt(cx), PApplet.parseInt(cy), random(-10, 10)+vx*0.5f, random(-10, 10)+vy*0.5f, PApplet.parseInt(random(5, 20)), 500, playerColor));
    // }
    invisStampTime=stampTime+invinsTime;
    invis=true;
    if (health<=0) {
      death();
    }
  }
  public void heal(int _health) {
    stamps.add( new StateStamp(index, PApplet.parseInt(x), PApplet.parseInt(y), state, health, dead));
    if (health<maxHealth) {
      health+=_health;
      deColor=255;
      state=2;
      //  hit=true;
      //}
      /*for (Ability a : this.abilityList) {
       a.onHit();
       }*/
      particles.add(new Particle(PApplet.parseInt(cx), PApplet.parseInt(cy), random(-10, 10)+vx*0.5f, random(-10, 10)+vy*0.5f, PApplet.parseInt(random(5, 20)), 500, playerColor));
      invisStampTime=stampTime+invinsTime;
      invis=true;
    }
  }
  public void wallHit(int damage) {
    stamps.add( new StateStamp(index, PApplet.parseInt(x), PApplet.parseInt(y), state, health, dead));
    deColor=255;
    state=2;
    hit=true;
    for (Ability a : this.abilityList) {
      a.onHit();
    }
    particles.add(new Particle(PApplet.parseInt(cx), PApplet.parseInt(cy), random(-10, 10)+vx*0.5f, random(-10, 10)+vy*0.5f, PApplet.parseInt(random(5, 20)), 500, playerColor));
  }
  public void death() {
    //ability.onDeath();
    for (Ability a : this.abilityList) {
      a.onDeath();
      a.reset();
    }
    dead=true;
    // ability.reset();
    shakeTimer+=10;
    for (int i=0; i<16; i++) {
      particles.add(new Particle(PApplet.parseInt(cx), PApplet.parseInt(cy), random(50)-25, random(50)-25, PApplet.parseInt(random(40)+10), 1500, playerColor));
    }
    particles.add(new ShockWave(PApplet.parseInt(cx), PApplet.parseInt(cy), PApplet.parseInt(random(40)+10), 16, 400, playerColor));
    particles.add(new LineWave(PApplet.parseInt(cx), PApplet.parseInt(cy), PApplet.parseInt(random(40)+10), 400, playerColor, random(360)));
    particles.add(new Flash(900, 8, playerColor));  
    state=0;
    //stamps.add( new StateStamp(index, int(x), int(y), state, health,dead));
  }
  public void displayName() {
    fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s);
    textSize(20);

    if (clone) {
      text("P"+ (ally+1), cx, cy);
      if (debug) text("index:"+ (index), cx+50, cy);
    } else {
      text("P"+ (index+1), cx, cy);
      // if (cheatEnabled) text("                              vx:"+int(vx)+" vy:"+int(vy)+" ax:"+int(ax)+" ay:"+int(ay) + " A:"+ angle, cx, cy);
      // if (cheatEnabled) text("                              left:"+holdLeft+" right:"+holdRight+" up:"+holdUp+" down:"+holdDown, cx, cy-100);
    }
  }
  public void displayHealth() {

    fraction=((PI*2)/maxHealth)*health;
    strokeWeight(barSize);
    //strokeCap(SQUARE);
    noFill();
    stroke(hue(playerColor), 80*S, (80-deColor)*S);
    ellipse(cx, cy, barDiameter, barDiameter);
    stroke(hue(playerColor), (255-deColor*0.5f)*S, ally==-1?0:255*S);
    arc(cx, cy, barDiameter, barDiameter, -HALF_PI +(PI*2)-fraction, PI+HALF_PI);
    //strokeWeight(1);
  }
  public void displayAbilityEnergy(int index ) {
    barFraction=((PI*2)/abilityList.get(index).maxEnergy)*abilityList.get(index).energy;
    fill(255);
    if (abilityList.get(index).regen) { 
      noStroke();
    } else {
      strokeWeight(6);
      stroke(hue(playerColor), 255*S, 255*S);
    }
    arc(cx, cy, barDiameter, barDiameter, (PI*1.5f)-barFraction, PI+HALF_PI);

    //arc(cx, cy, barDiameter, barDiameter, -HALF_PI +(PI*2)-barFraction, PI+HALF_PI);
    // strokeWeight(1);
  }
  public void pushForce(float amount, float angle) {
    stamps.add( new ControlStamp(index, PApplet.parseInt(x), PApplet.parseInt(y), vx, vy, ax, ay));
    vx+=cos(radians(angle))*amount;
    vy+=sin(radians(angle))*amount;
    stamps.add( new ControlStamp(index, PApplet.parseInt(x), PApplet.parseInt(y), vx, vy, ax, ay));
  }
  public void pushForce(float _vx, float _vy, float _angle) {
    stamps.add( new ControlStamp(index, PApplet.parseInt(x), PApplet.parseInt(y), vx, vy, ax, ay));
    vx+=_vx;
    vy+=_vy;
    stamps.add( new ControlStamp(index, PApplet.parseInt(x), PApplet.parseInt(y), vx, vy, ax, ay));
  }
  public void stop() {
    vx=0;
    vy=0;
    ax=0;
    ay=0;
  }
  public void halt() {
    vx=0;
    vy=0;
  }
  public void reset() {
    vx=0;
    vy=0;
    ax=0;
    ay=0;
    health=maxHealth;
    dead=false;
    //ability.reset();
    for (Ability a : this.abilityList) a.reset();
  }
  public Player clone() {  
    try {
      Player temp=(Player)super.clone();
      temp.index=players.size();
      for (int i=0; i<abilityList.size(); i++) { // clone all abilities
        Ability tempAbility =abilityList.get(i).clone();
        tempAbility.setOwner(temp);
        temp.abilityList.set(i, tempAbility);
      }

      return temp;
    }
    catch(CloneNotSupportedException c) {
      println(c);
      return null;
    }
  }
}
  public void settings() {  fullScreen(P3D);  noSmooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#D6D4D4", "--hide-stop", "multiplayer_ball_game" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
