
/**------------------------------------------------------------//
 //                                                            //
 //  Coding dojo  - Prototype of a timecontrol game            //
 //  av: Alrik He    v.0.7.12                                  //
 //  Arduino verstad Malmö                                     //
 //                                                            //
 //      2014-09-21    -     2017-08-18                        //
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
final color BGcolor=color(100);
PFont font;
PGraphics GUILayer;
PShader  Blur;
boolean hitBox=false, cleanStart=true, preSelectedSkills=true, RandomSkillsOnDeath=false, noFlash=false, noShake=false, slow, reverse, fastForward, freeze, controlable=true, cheatEnabled, debug, origo, noisy, mute=true, inGame;
boolean gradualCleaning=true;
final float flashAmount=0.5, shakeAmount=0.8;
int mouseSelectedPlayerIndex=0;
int halfWidth, halfHeight, coins, mouseScroll;
//int gameMode=0;
GameType gameMode=GameType.MENU;
final int AmountOfPlayers=3; // start players
final float DIFFICULTY_LEVEL=1.2;

final int WHITE=color(255), GREY=color(172), BLACK=color(0), GOLD=color(255, 220, 0);
final int speedFactor= 2;
final float slowFactor= 0.3;
final String version="0.7.12";
static long prevMillis, addMillis, forwardTime, reversedTime, freezeTime, stampTime, fallenTime;
final int baudRate= 19200;
final static float DEFAULT_FRICTION=0.1;
final int startBalls=0;
final int  ballSize=100;
final int playerSize=100;
static int playersAlive; // amount of players alive
static Player AI;
final int offsetX=1250, offsetY=-50;//final int offsetX=950, offsetY=100;
static int shakeTimer, shakeX=0, shakeY=0, maxShake=80;
final float DEFAULT_ZOOMRATE=0.02;
static float F=1, S=1, timeBend=1, zoom=0.7, tempZoom=1.0, tempOffsetX=0, tempOffsetY=0, zoomX, zoomY, zoomXAim, zoomYAim, zoomAim=1, zoomRate=0.02;
final int keyResponseDelay=30;  // eventhe refreashrate equal to arduino devices
final char keyRewind='r', keyFreeze='v', keyFastForward='f', keySlow='z', keyIceDagger='p', ResetKey='0', RandomKey='7';
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
  , { int('w')-32, int('s')-32, int('a')-32, int('d')-32, int('t')-32 }
  , { 888, 888, 888, 888, 888 }// mouse 
  , { int('i')-32, int('k')-32, int('j')-32, int('l')-32, int('ö')-32 }
  , { int('g')-32, int('b')-32, int('v')-32, int('n')-32, int('m')-32}
  , { '8', '5', '4', '6', '3'}
};

/*boolean sketchFullScreen() { // p2 legacy
 return false;
 }
 */
void setup() {

  fullScreen(P3D);
  imageMode(CENTER);
  textAlign(CENTER, CENTER);
  //size(displayWidth, displayHeight, P3D);
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
    new MissleLauncher(), 
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
    new HanzoMain()
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
    new Tumble()
    //new Redemption(), // buggy on survival
    // new Undo() // buggy on survival
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
  mList.add( new ModeButton(GameType.BRAWL, 0, 100, 350, 600, color(255, 0, 0)));
  mList.add( new ModeButton(GameType.SURVIVAL, 300, 300, 350, 600, color(255, 255, 0)));
  mList.add( new ModeButton(GameType.WILDWEST, 600, 100, 350, 600, color(0, 255, 0)));
  mList.add( new ModeButton(GameType.BOSSRUSH, 900, 300, 350, 600, color(0, 255, 255)));
  mList.add( new ModeButton(GameType.SHOP, 1200, 100, 350, 600, color(0, 0, 255)));
  mList.add( new ModeButton(GameType.SETTINGS, 1500, 300, 350, 600, color(255, 0, 255)));

  println("loaded save ... abilities!");
  abilities= new Ability[][]{ 
  /* player 1 */    new Ability[]{new RapidBattery(), new Tumble()}, 
  /* player 2 */    new Ability[]{new RapidBattery(), new Random().randomize(passiveList)}, 
  /* player 3 mouse */   new Ability[]{new  Random().randomize(abilityList), new  Random().randomize(passiveList)}, 
  /* player 4 */    new Ability[]{new Random().randomize(abilityList), new Random().randomize(passiveList)}, 
    new Ability[]{new Random().randomize(abilityList), new Random().randomize(passiveList)}, 
    new Ability[]{new Random().randomize(abilityList), new Random().randomize(passiveList)}
  };

  //ChloeSet = new Ability[]{new ForceShoot(),new RapidFire(), new Dash(), new Tumble(),new Emergency()};
  //abilities[1]=ChloeSet;

  colorMode(HSB);
  /* for (int i=0; i< AmountOfPlayers; i++) {
   try {
   players.add(new Player(i, color((255/AmountOfPlayers)*i, 255, 255), int(random(width-playerSize*1)+playerSize), int(random(height-playerSize*1)+playerSize), playerSize, playerSize, playerControl[i][0], playerControl[i][1], playerControl[i][2], playerControl[i][3], playerControl[i][4], abilities[i]));
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

  resetGame();
  for (int j=0; j<AmountOfPlayers; j++) {
    for (int i=0; i<2; i++) {
      sBList.add( new SettingButton(i, settingSkillXOffset+200*i, 200+200*j, 100, players.get(j)) );
    }
    pSBList.add( new StatButton(icons[46],0, "HP", 50, 250+200*j, 50, players.get(j)) );
    pSBList.add( new StatButton(icons[47],1, "MP", 100, 250+200*j, 50, players.get(j)) );
    pSBList.add( new StatButton(icons[48],2, "Sp", 150, 250+200*j, 50, players.get(j)) );
    pSBList.add( new StatButton(icons[49],3, "Armor", 200, 250+200*j, 50, players.get(j)) );
    pSBList.add( new StatButton(icons[50],4, "Crit%", 250, 250+200*j, 50, players.get(j)) );

    pSBList.add( new StatButton(icons[51],5, "CritD", 300, 250+200*j, 50, players.get(j)) );
    pSBList.add( new StatButton(icons[52],6, "Damage", 350, 250+200*j, 50, players.get(j)) );
    pSBList.add( new StatButton(icons[53],7, "Acc", 400, 250+200*j, 50, players.get(j)) );
    pSBList.add( new StatButton(icons[54],8, "AttSp", 450, 250+200*j, 50, players.get(j)) );
    pSBList.add( new StatButton(icons[54],9, "CDR", 500, 250+200*j, 50, players.get(j)) );

  }
}
void stop() {
  musicPlayer.pause(true);
  super.stop();
}

void draw() {
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
  zoomX+=(zoomXAim-zoomX)*zoomRate;
  zoomY+=(zoomYAim-zoomY)*zoomRate;
  tempOffsetX=-tempZoom*zoom*zoomX+tempZoom*zoom*width*(.5/(tempZoom*zoom));//
  tempOffsetY=-tempZoom*zoom*zoomY+tempZoom*zoom*height*(.5/(tempZoom*zoom));//
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
          Gain g3 = new Gain(an, 1, 0.0);
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

    scale(zoom*tempZoom, zoom*tempZoom);

    //noStroke()
    stroke(BLACK);
    strokeWeight(10);
    rect(-10, -10, width+20, height+20); // background


    //--------------------- projectiles-----------------------


    for (int i= projectiles.size ()-1; i>= 0; i--) { // checkStamps
      projectiles.get(i).update();  
      projectiles.get(i).display();
      projectiles.get(i).revert();
      if (gradualCleaning&&!reverse  &&  projectiles.get(i).deathTime+10000<stampTime) projectiles.remove(i);
    }


    //-----------------------  particles------------------------


    for (int i=particles.size ()-1; i>= 0; i--) { // checkStamps
      particles.get(i).update();  
      particles.get(i).display();
      particles.get(i).revert();
      if (gradualCleaning &&!reverse &&  particles.get(i).deathTime+5000<stampTime) particles.remove(i);
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
      for (Player p : players) {       
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
      }
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

    pushStyle();
    textAlign(LEFT);
    textSize(12);
    strokeWeight(20);

    for (Player p : players) {
      if (p.index>-1 && p.index<5 &&!p.clone) {
        for (Ability a : p.abilityList) {
          if (a.type==AbilityType.ACTIVE) {
            noStroke();
            fill(WHITE);
            rect(100+300*p.index+30, height-65-30*p.abilityList.indexOf(a), a.energy, 30);
          }
          fill(BLACK);
          text(a.name, 100+300*p.index+40, height-40-30*p.abilityList.indexOf(a));
          image(a.icon, 100+300*p.index+15, height-50-30*p.abilityList.indexOf(a), 30, 30);
        }
        stroke(BLACK);
        line(100+300*p.index, height-20, 100+130+300*p.index, height-20);
        stroke((p.playerColor==BLACK)?WHITE:p.playerColor);
        float percent = ((float)p.health/p.maxHealth)*130;
        if (p.health>0)line(100+300*p.index, height-20, 100+percent+300*p.index, height-20);
      }
    }
    popStyle();

    if (cheatEnabled)displayInfo();
    else displayClock();
    switch(gameMode) {
    case BRAWL:
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
      /* for (int i=particles.size ()-1; i>= 0; i--) { // checkStamps
       particles.get(i).update();  
       particles.get(i).display();
       particles.get(i).revert();
       if (gradualCleaning &&!reverse &&  particles.get(i).deathTime+5000<stampTime) particles.remove(i);
       }*/
      break;
    case MENU:
      menuUpdate();
      /* for (int i=particles.size ()-1; i>= 0; i--) { // checkStamps
       particles.get(i).update();  
       particles.get(i).display();
       particles.get(i).revert();
       if (gradualCleaning &&!reverse &&  particles.get(i).deathTime+5000<stampTime) particles.remove(i);
       }*/
      break;
    case BOSSRUSH:
      bossRushSpawning();
      break;
    case SETTINGS:
      settingsUpdate();
      /* for (int i=particles.size ()-1; i>= 0; i--) { // checkStamps
       particles.get(i).update();  
       particles.get(i).display();
       particles.get(i).revert();
       if (gradualCleaning &&!reverse &&  particles.get(i).deathTime+5000<stampTime) particles.remove(i);
       }*/
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