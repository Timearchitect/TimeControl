
/**------------------------------------------------------------//
 //                                                            //
 //  Coding dojo  - Prototype of a timecontrol game            //
 //  av: Alrik He    v.0.7.17                                  //
 //  Arduino verstad Malmö                                     //
 //                                                            //
 //      2014-09-21    -     2017-09-29                        //
 //                                                            //
 //                                                            //
 //         Used for weapon test & prototyping timebending     //
 //   link:  www.github.com/timearchitect/timecontrol          //
 //                                                            //
 --------------------------------------------------------------*/

import processing.opengl.*;
import beads.*;
import java.util.Arrays; 
import processing.serial.*;
import net.java.games.input.*;
import net.java.games.input.EventQueue;
import net.java.games.input.Event;

AudioContext  ac = new AudioContext();
AudioContext  as = new AudioContext();

AudioContext an= new AudioContext();
beads.Noise n = new beads.Noise(an);
SamplePlayer musicPlayer;
SamplePlayer chargeSound, pewSound, shineSound, deathSound, peSound, thunderSound, zapSound, slashSound, teleportSound, sipSound, thumpSound,
  shotSound, tickSound, clinkSound, machineSound,reflectSound,tickingSound,pumpSound,sniperSound;

Envelope speedControl;


final color BGcolor=color(100);
PFont font;
PGraphics GUILayer;
PShader  Blur;

final int MaxSkillAmount= 100;
int[] skillMaxAmount, currentTotalSkillAmount;
boolean hitBox=false, fixedSkillpoint=false, cleanStart=true, preSelectedSkills=true, RandomSkillsOnDeath=false, noFlash=false, noShake=false, slow, reverse, fastForward, freeze, controlable=true, cheatEnabled, debug, origo, noisy, mute=false, inGame;
boolean gradualCleaning=false;
final float flashAmount=0.2, shakeAmount=0.1, effectVolume=0.012;
Gain   g = new Gain(ac, 1, 0.05); //volume
Gain  g3 = new Gain(an, 1, 0.0);
Gain  gainSoundeffect = new Gain(as, 1, effectVolume);

int mouseSelectedPlayerIndex=0;
int halfWidth, halfHeight, coins, mouseScroll;
UpgradebleButton skillpointsButton;
//int gameMode=0;
GameType gameMode=GameType.MENU;
final byte AmountOfPlayers=3, AmountOfModes=7; // start players
final float DIFFICULTY_LEVEL=1.2;

final int WHITE=color(255), GREY=color(172), BLACK=color(0), GOLD=color(255, 220, 0), RED=color(255, 0, 0), GREEN=color(0, 255, 0);
final int speedFactor= 2;
final float MIN_DAMAGE=0.02;
final float slowFactor= 0.3;
final String version="0.7.19";
static long prevMillis, addMillis, forwardTime, reversedTime, freezeTime, stampTime, fallenTime;
final int baudRate= 19200;
final static float DEFAULT_FRICTION=0.1;
final int startBalls=0;
final int  ballSize=100;
final int playerSize=100;
static int playersAlive, playerAliveIndex; // amount of players alive
static float GUIpercent;

static Player AI;
final  boolean xBox=true;
final int offsetX=1250, offsetY=-50;//final int offsetX=950, offsetY=100;
static int shakeTimer, shakeX=0, shakeY=0, maxShake=80;
final float DEFAULT_ZOOMRATE=0.02;
static float F=1, S=1, timeBend=1, zoom=0.8, tempZoom=1.0, actualPercentScale, tempOffsetX=0, tempOffsetY=0, zoomX, zoomY, zoomXAim, zoomYAim, zoomAim=1, zoomRate=0.02;
final int keyResponseDelay=30;  // eventhe refreashrate equal to arduino devices
final char keyRewind='§', keyFreeze='x', keyFastForward='f', keySlow='z', keyIceDagger='p', ResetKey='0', RandomKey='7';
final int ICON_AMOUNT=60;
final PImage[] icons=new PImage[ICON_AMOUNT];
Serial port[]=new Serial[AmountOfPlayers];  // Create object from Serial class
String portName[]=new String[AmountOfPlayers];

ArrayList <Player> players = new ArrayList<Player>();
ArrayList <TimeStamp> stamps= new ArrayList<TimeStamp>();
ArrayList <Projectile> projectiles = new ArrayList<Projectile>();
ArrayList <Particle> particles = new ArrayList<Particle>();
Ability[] ChloeSet;


final Projectile allProjectiles[] = new Projectile[]{
  // new IceDagger(),new forceBall(),new RevolverBullet()
};
//final int ABILITY_AMOUNT=45, PASSIVE_AMOUNT=22;
Ability abilityList[], passiveList[];
Ability westAbilityList[], westPassiveList[];
/*Ability[][] abilities= { 
 player 1  {new Random().randomize(),new Random().randomize(passiveList)}, 
 player 2  {new Random().randomize(),new Random().randomize(passiveList)}, 
 player 3 mouse  {new  Random().randomize(),new  Random().randomize()}, 
 player 4  {new Random().randomize(),new Random().randomize()}, 
 {new Random().randomize(), new Random().randomize(passiveList)}, 
 {new Random().randomize(), new Random().randomize(passiveList)}
 };*/
Ability[][] abilities= new Ability[AmountOfPlayers][];
int playerControl[][]= {
  { UP, DOWN, LEFT, RIGHT, int(',') }
  , { int('w')-32, int('s')-32, int('a')-32, int('d')-32, int('e')-32 }
  , { 888, 888, 888, 888, 888 }// mouse 
  , { int('i')-32, int('k')-32, int('j')-32, int('l')-32, int('ö')-32 }
  , { int('g')-32, int('b')-32, int('v')-32, int('n')-32, int('m')-32}
  , { '8', '5', '4', '6', '3'}
  , { int('f')-32, int('v')-32, int('c')-32, int('b')-32, int(' ')-32}
};

/*boolean sketchFullScreen() { // p2 legacy
 return false;
 }
 */
//import processing.sound.*;
//SoundFile  deathSound, chargeSound, shineSound, pewSound;



void setup() {

  // hint(DISABLE_OPENGL_ERROR_REPORT);
  hint(DISABLE_DEPTH_TEST);
  hint(DISABLE_ASYNC_SAVEFRAME);
  fullScreen(P3D);
  //size(displayWidth, displayHeight, P3D);
  draw();
  /*deathSound= new SoundFile(this, "death.mp3");
   deathSound.amp(effectVolume);
   pewSound= new SoundFile(this, "pew.mp3");
   pewSound.amp(effectVolume);
   // chargeSound= new SoundFile(this, "charge.mp3");
   // chargeSound.amp(effectVolume);
   shineSound= new SoundFile(this, "shine.mp3");
   shineSound.amp(effectVolume);*/
  imageMode(CENTER);
  textAlign(CENTER, CENTER);
  font= loadFont("PressStart2P-Regular-28.vlw");
  Blur= loadShader("blur.glsl");
  textFont(font, 18);
  randomSeed(12345);
  noSmooth();
  halfWidth=int(width*.5);
  halfHeight=int(height*.5);
  zoomXAim=halfWidth;
  zoomYAim=halfHeight;
  //frameRate(60);
  //noCursor();
  //cursor();
  for (int i=0; i<ICON_AMOUNT; i++ )icons[i]=loadImage("data/Ability Icons-"+(i+1)+".png");
  abilityList= new Ability[]{
    // new FastForward(), 
    // new Freeze(), 
    // new Reverse(), 
    // new Slow(), 
    new NoActive(), 
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
    new MissileLauncher(), 
    new AutoGun(), 
    new Combo(), 
    new CloudStrike(), 
    new TeslaShock(), 
    new RandoGun(), 
    new Shotgun(), 
    new Sluggun(), 
    new FlameThrower(), 
    new DeployDrone(), 
    new DeployBodyguard(), 
    new SemiAuto(), 
    new Pistol(), 
    new AssaultBattery(), 
    new Stars(), 
    new SeekGun(), 
    new ElemetalLauncher(), 
    new SummonEvil(), 
    new SummonIlluminati(), 
    new SerpentFire(), 
    new SneakBall(), 
    new TripleShot(), 
    new MarbleLauncher(), 
    new Torpedo(), 
    new PoisonDart(), 
    new Artilery(), 
    new LaserSword(), 
    new StunGun(), 
    new ChargeSlash(), 
    new GranadeLauncher(), 
    new DoubleTap(), 
    new RapidBattery(), 
    new Chivalry(), 
    new HitScanGun(), 
    new HanzoMain(), 
    new Ravine(), 
    new CutThroat(), 
    new CrossFire(), 
    new FlashBomb(), 
    new Explosion(), 
    new SplitShot()
    //new Multiply2()
  };

  passiveList = new Ability[]{
    new NoPassive(), 
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
    new BulletCutter(), 
    new Dash(), 
    new Guardian(), 
    new SnakeShield(), 
    new Stalker(), 
    new Scatter(), 
    new Tumble(), 
    new Rage(), 
    new Phase(), 
    new Dodge()
    //new Redemption(), // buggy on survival
    //new Undo() // buggy on survival
  };

  westAbilityList= new Ability[]{
    new Revolver(), 
    new Stealth(), 
    new RapidFire(), 
    new MachineGun(), 
    new Battery(), 
    new AutoGun(), 
    new Shotgun(), 
    new Sluggun(), 
    new SemiAuto(), 
    new Pistol(), 
    new TripleShot(), 
    new MarbleLauncher()
  };
  westPassiveList = new Ability[]{
    new Armor(), 
    new HpRegen(), 
    new SuppressFire(), 
    new Gloss(), 
    new Boost(), 
    new Glide(), 
    new MpRegen(), 
    new BulletTime(), 
    new Emergency(), 
    new Dash(), 
    new Redemption(), // buggy on survival
    new Undo(), // buggy on survival
    new NoPassive()
  };

  try {
    println("load savefile...");
    loadProgress();
    println("loaded");
  }
  catch (Exception e) {
    println(e);
  }
  abilityList[0].unlocked=true; // noActive
  passiveList[0].unlocked=true; // noPassive
  final int menuBtnWidth=260, menuBtnHeight=500;
  colorMode(HSB);

  mList.add( new ModeButton(GameType.BRAWL, width/AmountOfModes*mList.size(), halfHeight/AmountOfModes*mList.size(), menuBtnWidth, menuBtnHeight, color(255/AmountOfModes*mList.size(), 255, 255), icons[1]));
  mList.add( new ModeButton(GameType.HORDE, width/AmountOfModes*mList.size(), halfHeight/AmountOfModes*mList.size(), menuBtnWidth, menuBtnHeight, color(255/AmountOfModes*mList.size(), 255, 255), icons[2]));
  mList.add( new ModeButton(GameType.SURVIVAL, width/AmountOfModes*mList.size(), halfHeight/AmountOfModes*mList.size(), menuBtnWidth, menuBtnHeight, color(255/AmountOfModes*mList.size(), 255, 255), icons[12]));
  mList.add( new ModeButton(GameType.WILDWEST, width/AmountOfModes*mList.size(), halfHeight/AmountOfModes*mList.size(), menuBtnWidth, menuBtnHeight, color(255/AmountOfModes*mList.size(), 255, 255), icons[23]));
  mList.add( new ModeButton(GameType.BOSSRUSH, width/AmountOfModes*mList.size(), halfHeight/AmountOfModes*mList.size(), menuBtnWidth, menuBtnHeight, color(255/AmountOfModes*mList.size(), 255, 255), icons[34]));
  mList.add( new ModeButton(GameType.SHOP, width/AmountOfModes*mList.size(), halfHeight/AmountOfModes*mList.size(), menuBtnWidth, menuBtnHeight, color(255/AmountOfModes*mList.size(), 255, 255), icons[45]));
  mList.add( new ModeButton(GameType.SETTINGS, width/AmountOfModes*mList.size(), halfHeight/AmountOfModes*mList.size(), menuBtnWidth, menuBtnHeight, color(255/AmountOfModes*mList.size(), 255, 255), icons[55]));
  selectedModeButton=mList.get(0);
  selectedModeButton.hover=true;
  println("loaded save ... abilities!");
  abilities= new Ability[][]{ 
  /* player 1 */    new Ability[]{new Torpedo(), new Redemption()}, 
  /* player 2 */    new Ability[]{new Explosion(), new Random().randomize(passiveList)}, 
  /* player 3 mouse */    new Ability[]{new  Random().randomize(abilityList), new  Random().randomize(passiveList)}, 
  /* player 4 */    new Ability[]{new Random().randomize(abilityList), new Random().randomize(passiveList)}, 
    new Ability[]{new Random().randomize(abilityList), new Random().randomize(passiveList)}, 
    new Ability[]{new Random().randomize(abilityList), new Random().randomize(passiveList)}
  };
  currentTotalSkillAmount= new int[AmountOfPlayers];
  skillMaxAmount= new int[AmountOfPlayers];
  updateSkillPoints();

  //ChloeSet = new Ability[]{new ForceShoot(),new RapidFire(), new Dash(), new Tumble(),new Emergency()};
  //abilities[1]=ChloeSet;

  /* for (int i=0; i< AmountOfPlayers; i++) {
   try {
   players.add(new Player(i, color((255/AmountOfPlayers)*i, 255, 255), int(random(width-playerSize*1)+playerSize), int(random(height-playerSize*1)+playerSize), playerSize, playerSize, playerControl[i][0], playerControl[i][1], playerControl[i][2], playerControl[i][3], playerControl[i][4], abilities[i]));
   }
   catch(Exception e ) {§
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
   println(" port " +port[i].available(), " avalible");
   println(portName[i]);
   players.get(i).MAX_ACCEL=0.16;
   players.get(i).DEFAULT_MAX_ACCEL=0.16;
   players.get(i).arduino=true;
   players.get(i).FRICTION_FACTOR=0.062;
   }*/
  playerSetup();
  controllerSetup();
  GUILayer= createGraphics(width, height);
  GUILayer.beginDraw();
  GUILayer.noStroke();
  GUILayer.fill(0);
  GUILayer.endDraw();
  drawTimeSymbol();
  prevMillis=millis(); // init time

  try {  
    // initialize the SamplePlayer
    pewSound  = new SamplePlayer(as, new Sample(sketchPath("") +"data/pew.mp3")); 
    chargeSound  = new SamplePlayer(as, new Sample(sketchPath("") +"data/charge.mp3")); 
    deathSound  = new SamplePlayer(as, new Sample(sketchPath("") +"data/death.mp3")); 
    shineSound  = new SamplePlayer(as, new Sample(sketchPath("") +"data/shine.mp3")); 
    thunderSound  = new SamplePlayer(as, new Sample(sketchPath("") +"data/thunder.mp3")); 
    zapSound  = new SamplePlayer(as, new Sample(sketchPath("") +"data/zap.mp3")); 
    slashSound  = new SamplePlayer(as, new Sample(sketchPath("") +"data/slash.mp3")); 
    teleportSound= new SamplePlayer(as, new Sample(sketchPath("") +"data/teleport.mp3")); 
    peSound = new SamplePlayer(as, new Sample(sketchPath("") +"data/pe.mp3"));
    thumpSound= new SamplePlayer(as, new Sample(sketchPath("") +"data/thump.mp3")); 
    sipSound  = new SamplePlayer(as, new Sample(sketchPath("") +"data/sip.mp3")); 
    shotSound= new SamplePlayer(as, new Sample(sketchPath("") +"data/shot.mp3"));
    tickSound= new SamplePlayer(as, new Sample(sketchPath("") +"data/tick.mp3")); 
    clinkSound= new SamplePlayer(as, new Sample(sketchPath("") +"data/clink.mp3")); 
    machineSound= new SamplePlayer(as, new Sample(sketchPath("") +"data/machine.mp3")); 
    reflectSound= new SamplePlayer(as, new Sample(sketchPath("") +"data/reflect.mp3")); 
    tickingSound= new SamplePlayer(as, new Sample(sketchPath("") +"data/ticking.mp3")); 
    sniperSound= new SamplePlayer(as, new Sample(sketchPath("") +"data/sniper.mp3")); 
    pumpSound= new SamplePlayer(as, new Sample(sketchPath("") +"data/pump.mp3")); 
    // musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/TooManyCooksAdultSwim.mp3"));

    // musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/Velocity.mp3")); 
     musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/Death by Glamour.mp3")); 
    // musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/Branching time.mp3")); 
    // musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/orange caramel -aing.mp3"));
    // musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/goodbye.mp3"));
    // musicPlayer = new SamplePlayer(ac, new Sample(sketchPath("") +"data/wierd.mp3"));
  }
  catch(Exception e) {
    println("Exception while attempting to load sample!");
    e.printStackTrace(); // then print a technical description of the error
    exit(); // and exit the program
  }
  initSound(thumpSound);

  initSound(sipSound);
  initSound(zapSound);
  initSound(chargeSound);
  initSound(pewSound);
  initSound(peSound);
  initSound(shineSound);
  initSound(deathSound);
  initSound(thunderSound);
  initSound(slashSound);
  initSound(teleportSound);
  initSound(sipSound );
  initSound(shotSound);
  initSound(tickSound);
  initSound(clinkSound);
  initSound(machineSound);
    initSound(reflectSound);
    initSound(tickingSound);
initSound(pumpSound);
initSound(sniperSound);
  g.addInput(musicPlayer);
  ac.out.addInput(g);
  speedControl = new Envelope(ac, 1);
  musicPlayer.setPosition(2500);
  musicPlayer.setRate(speedControl); // yo
  musicPlayer.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  //  speedControl.addSegment(1, 3000); //now rewind
  if (!mute)ac.start(); //start music


  as.out.addInput(gainSoundeffect);
  as.start();

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

  resetGame();
  for (int j=0; j<AmountOfPlayers; j++) {
    for (int i=0; i<2; i++) {
      sBList.add( new SettingButton(i, settingSkillXOffset+settingSkillInterval*i, settingSkillYOffset+200*j, 100, players.get(j)) );
    }
    StatButton s=    new StatButton(icons[46], 0+players.get(j).abilityList.size(), "HP", 50, settingSkillYOffset+50+200*j, 50, players.get(j));

    players.get(j).statList.add(s);
    pSBList.add( s);
    s=  new StatButton(icons[47], 1+players.get(j).abilityList.size(), "MP", 100, settingSkillYOffset+50+200*j, 50, players.get(j)) ;
    players.get(j).statList.add(s);
    pSBList.add( s);
    s= new StatButton(icons[48], 2+players.get(j).abilityList.size(), "Sp", 150, settingSkillYOffset+50+200*j, 50, players.get(j)) ;
    players.get(j).statList.add(s);
    pSBList.add( s);
    s=  new StatButton(icons[49], 3+players.get(j).abilityList.size(), "Armor", 200, settingSkillYOffset+50+200*j, 50, players.get(j)) ;
    players.get(j).statList.add(s);
    pSBList.add( s);
    s=  new StatButton(icons[50], 4+players.get(j).abilityList.size(), "Crit%", 250, settingSkillYOffset+50+200*j, 50, players.get(j)) ;
    players.get(j).statList.add(s);
    pSBList.add( s);
    s= new StatButton(icons[51], 5+players.get(j).abilityList.size(), "CritD", 300, settingSkillYOffset+50+200*j, 50, players.get(j)) ;
    players.get(j).statList.add(s);
    pSBList.add( s);
    s=  new StatButton(icons[52], 6+players.get(j).abilityList.size(), "Damage", 350, settingSkillYOffset+50+200*j, 50, players.get(j)) ;
    players.get(j).statList.add(s);
    pSBList.add( s);
    s=  new StatButton(icons[53], 7+players.get(j).abilityList.size(), "Acc", 400, settingSkillYOffset+50+200*j, 50, players.get(j)) ;
    players.get(j).statList.add(s);
    pSBList.add( s);
    s=  new StatButton(icons[54], 8+players.get(j).abilityList.size(), "AttSp", 450, settingSkillYOffset+50+200*j, 50, players.get(j)) ;

    players.get(j).statList.add(s);
    pSBList.add( s);
    s=  new StatButton(icons[54], 9+players.get(j).abilityList.size(), "CDR", 500, settingSkillYOffset+50+200*j, 50, players.get(j)) ;
    players.get(j).statList.add(s);
    pSBList.add( s);
    println( players.get(j).statList.size());
  }
  /*   String[] args = {"Rename player"};
   PApplet sa = new PApplet();
   PApplet.runSketch(args, sa);
   */
  if (xBox)xBoxSetup();
}
void stop() {
  musicPlayer.pause(true);
  super.stop();
}

void draw() {
  if (xBox)  getXboxInput() ;
  /*if (cheatEnabled && (gameMode!=GameType.MENU || gameMode!=GameType.SHOP ) && stampTime>500) {    
   //tempOffsetX=(tempZoom*zoom)*(width)-(tempZoom*zoom)*players.get(0).cx-(tempZoom*zoom)*(width*.75);
   //tempOffsetY=(tempZoom*zoom)*(height)-(tempZoom*zoom)*players.get(0).cy-(tempZoom*zoom)*(height*.75);
   zoomX=players.get(mouseSelectedPlayerIndex).cx;
   zoomY=players.get(mouseSelectedPlayerIndex).cy;
   tempOffsetX=-tempZoom*zoom*zoomX+tempZoom*zoom*width*(.5/(tempZoom*zoom));
   tempOffsetY=-tempZoom*zoom*zoomY+tempZoom*zoom*height*(.5/(tempZoom*zoom));
   tempZoom=(float)mouseX/width+1;
   } else {*/
  //tempZoom=1;
  // zoom=.8;
  tempZoom+=(zoomAim-tempZoom)*zoomRate;
  actualPercentScale=tempZoom*zoom;
  zoomX+=(zoomXAim-zoomX)*zoomRate;
  zoomY+=(zoomYAim-zoomY)*zoomRate;
  tempOffsetX=-actualPercentScale*zoomX+actualPercentScale*width*(.5/actualPercentScale);//
  tempOffsetY=-actualPercentScale*zoomY+actualPercentScale*height*(.5/actualPercentScale);//
  //}
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
    if (!noFlash) {
      if (fastForward) {
        fill(240, 100*F, 100, 50*flashAmount);
      }
      if (slow) {
        fill(240, 10*F, 250, 20*flashAmount);
      }
    }
    if (freeze ) {
      if (!noFlash)fill(150, 200, 255, flashAmount*255);
      freezeTime+=addMillis;
    } else {
      if (reverse) {
        if (stampTime<6000) {      
          g3.setGain((6000-stampTime)*0.0000001);
          if (!noisy)g3.addInput(n);
          an.out.addInput(g3);
          shake(int((6000-stampTime)*0.01) );
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
    // translate(width*(1-zoom)*.5+tempOffsetX, height*(1-zoom)*.5+tempOffsetY);
    translate(tempOffsetX, tempOffsetY);

    scale(actualPercentScale, actualPercentScale);

    //noStroke()
    stroke(BLACK);
    strokeWeight(10);
    //rect(-10, -10, width+20, height+20); // background
    rect(0, 0, width, height); // background


    //--------------------- projectiles-----------------------


    for (int i= projectiles.size ()-1; i>= 0; i--) { // checkStamps
      projectiles.get(i).update();  
      projectiles.get(i).display();
      projectiles.get(i).revert();
      if (gradualCleaning&&!reverse  &&  projectiles.get(i).deathTime+10000<stampTime) projectiles.remove(i);   //     10 SEK CLEAN
    }


    //-----------------------  particles------------------------


    for (int i=particles.size ()-1; i>= 0; i--) { // checkStamps
      particles.get(i).update();  
      particles.get(i).display();
      particles.get(i).revert();
      if (gradualCleaning &&!reverse &&  particles.get(i).deathTime+5000<stampTime) particles.remove(i); // 5 SEK
    }

    //-----------------------  USB ------------------------

    for (int i=0; i<Serial.list().length; i++) {   // USB devices & k
      if (portName[i]!= null && port[i].available() > 0) {  //ta in data och ignorerar skräpdata    
        players.get(i).control(port[i].read());
        // println("INPUT!:  "+char(port[i].read()));
      }
    }

    checkPlayerVSPlayerColloision();
    checkProjectileVSProjectileColloision();
    checkPlayerVSProjectileColloision();

    try {
      for (int i =0; i <players.size(); i++) {       
        if (!players.get(i).dead) {
          if (!freeze ||  players.get(i).freezeImmunity) {
            players.get(i).mouseControl() ;
            //p.update();
            if (!reverse || players.get(i).reverseImmunity) {
              players.get(i).checkBounds();
            }
          }
          players.get(i).update();
          players.get(i).display();
        }
      }
      /*for (Player p : players) {       
       if (!p.dead) {
       if (!freeze ||  p.freezeImmunity) {
       p.mouseControl() ;
       //p.update();
       if (!reverse || p.reverseImmunity) {
       p.checkBounds();
       }
       }
       p.update(); // !!!
       p.display();
       }
       }*/
    }
    catch(Exception e) {
      println(e +" player update");
    }

    if (freeze) {
      // colorMode(RGB);
      //for (int b=0; b<2; b++) {
      filter(Blur);
      // }
    } 
    //image(GUILayer, 0, 0);
    if (cheatEnabled)mouseDot();
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
      } else if (gradualCleaning &&!reverse &&  p.index>AmountOfPlayers ) { //
        players.remove(p);
        break;
      }
    }
    popMatrix();

    // image(GUILayer, 0, 0);

    pushStyle();
    textAlign(LEFT);
    textSize(12);
    strokeWeight(20);
    for (Player p : players) {
      if (!p.dead && p.index>-1 && p.index<=AmountOfPlayers &&!p.clone&&!p.turret) {
        noStroke();
        for (Ability a : p.abilityList) {
          if (a.type==AbilityType.ACTIVE) {
            fill(WHITE);
            rect(100+300*p.index+30, height-65-30*p.abilityList.indexOf(a), a.energy, 30);
          }
          fill(BLACK);
          text(a.name, 100+300*p.index+40, height-40-30*p.abilityList.indexOf(a));
          image(a.icon, 100+300*p.index+15, height-50-30*p.abilityList.indexOf(a), 30, 30);
        }
        stroke(BLACK);
        line(100+300*p.index, height-20, 230+300*p.index, height-20);
        stroke((p.playerColor==BLACK)?WHITE:p.playerColor);
        GUIpercent = (float(p.health)/p.maxHealth)*130;
        if (p.health>0)line(100+300*p.index, height-20, 100+GUIpercent+300*p.index, height-20);
      }
    }
    popStyle();

    if (cheatEnabled)displayInfo();
    else displayClock();
    switch(gameMode) {
    case BRAWL:
      break;
    case HORDE:
      hordeSpawning();
      break;
    case SURVIVAL:
      survivalSpawning();
      break;
    case PUZZLE:
      break;
    case WILDWEST:
      wildWestUpdate();      
      break;
    case SHOP:
      shopUpdate();
      break;
    case MENU:
      menuUpdate();
      break;
    case BOSSRUSH:
      bossRushSpawning();
      break;
    case SETTINGS:
      settingsUpdate();
      break;
    default:

      break;
    }
  }
  // origo
  // prevMillis=millis();
  pMousePressed=mousePressed;
  mouseScroll=0;
}
