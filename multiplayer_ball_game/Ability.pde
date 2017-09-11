

abstract class Ability implements Cloneable {
  AbilityType type=AbilityType.ACTIVE;
  String name="???";
  Player owner;  
  PImage icon;
  long cooldown;
  int cooldownTimer, unlockCost=1000, x, y;
  float ammo, maxAmmo, critDamage, critChance, inAccuracy, damageMod, speedMod, attackSpeedMod, costMod, rangeMod, accuracyMod, criticalDamageMod, criticalChanceMod;
  float energy=90, maxEnergy=100, activeCost=5, channelCost, deChannelCost, deactiveCost, maxCooldown, regenRate=0.1, loadRate;
  boolean active, channeling, cooling, hold, regen=true, meta, unlocked, deactivated, sellable=true, deactivatable=true;
  ArrayList<Buff> buffList;
  Ability() { 
    icon=icons[8];
    setAllMod();
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
  void press() {
    // particles.add( new Star(2000, int(owner.cx), int( owner.cy), 0, 0, 300, 0.9, owner.playerColor) );
  }
  void release() {
  }
  void hold() {
  }
  void action() {
  }
  void onHit() {
  }
  void wallHit() {
  }
  void update() {
  }
  void channel() {
    if (energy>0) {
      energy -= channelCost*timeBend;
      channeling=true;
    } else {
      deChannel();
    }
  }
  void deChannel() {
    energy -= deChannelCost;
    channeling=false;
  }
  void display() {
  }
  void activate() { 
    active=true;
    energy -= activeCost;
  }

  void deactivate() {
    active=false;
    energy -= deactiveCost;
  }

  void enableCooldown() {
    //cooldown=maxCooldown;
    cooldown=stampTime+cooldownTimer;
    cooling=true;
  }
  void regen() {
    if (reverse && !owner.reverseImmunity) {
      if (regen && energy>0) {
        energy -= regenRate*timeBend;
      }
    } else {
      if (regen && energy<maxEnergy) {
        energy += regenRate*timeBend;
      } else {
        // stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=false;
      }
    }
  }
  void load() {
    if (ammo<maxAmmo)ammo+=loadRate;
  }
  void passive() {
  }
  void onDeath() {
  }
  void reset() {
    active=false;
    energy=maxEnergy;
    cooldown=0;
    setAllMod();
    if (owner!=null) {
      owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    }
  }
  void setOwner(Player _owner) {
    owner=_owner;
    setAllMod();
  }
  void setAllMod() {
    setDamageMod();
    setAccuracyMod();
    setCostMod();
    setAttackSpeedMod();
    setCriticalChanceMod();
    setCriticalDamageMod();
    setWeaponEnergyMod();
  }
  public void setDamageMod() {
    if (owner!=null) {
      damageMod=owner.weaponDamage;
    }
  }
  public void setSpeedMod() {
    if (owner!=null) {
      speedMod=owner.weaponSpeed;
    }
  }
  public void setAccuracyMod() {
    if (owner!=null) {
      accuracyMod=owner.weaponAccuracy;
    }
  }
  public void setCostMod() {
    if (owner!=null) {
      costMod=owner.weaponCost;
    }
  }
  public void setRangeMod() {
    if (owner!=null) {
      rangeMod=owner.weaponRange;
    }
  }
  public void setAttackSpeedMod() {
    if (owner!=null) {
      attackSpeedMod=owner.weaponAttackSpeed;
    }
  }
  public void setCriticalChanceMod() {
    if (owner!=null) {
      criticalChanceMod=owner.weaponCritChance;
    }
  }
  public void setCriticalDamageMod() {
    if (owner!=null) {
      criticalDamageMod=owner.weaponCritDamage;
    }
  }
  public void setWeaponEnergyMod() {
    if (owner!=null) {
      costMod=owner.weaponEnergy;
    }
  }


  public Ability clone()throws CloneNotSupportedException {  
    return (Ability)super.clone();
  }
  void setIcon(PImage _icon) {
    icon=_icon;
  }
  Ability addBuff(Buff ...bA) {
    buffList=new ArrayList<Buff>();
    for (Buff b : bA) buffList.add(b);
    return this;
  }
}

class NoActive extends Ability {//---------------------------------------------------    HpRegen   ---------------------------------

  NoActive() {
    super();
    icon=icons[31];
    sellable=false;
    // deactivatable=false;
    name=getClassName(this);
    unlocked=true;
  } 
  /*@Override
   void action() {
   }
   @Override
   void press() {
   }
   @Override
   void passive() {
   }
   @Override
   void reset() {
   }*/
}

class FastForward extends Ability { //---------------------------------------------------    FastForward   ---------------------------------

  FastForward() {
    super();
    name=getClassName(this);
    activeCost=8;
    channelCost=0.03;
    deactiveCost=8;
    active=false;
    meta=true;
  }
  @Override
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
  void press() {
    if (!active) {
      if (energy>0+activeCost) {
        activate();
      }
    } else {
      deactivate();
    }
  }
  void activate() { 
    active=true;
    energy -= activeCost;
    action();
    regen=false;
  }
  @Override
    void deactivate() {
    super.deactivate();
    regen=true;
    action();
  }
  @Override
    void passive() {
    if (active) {
      channel();
      if (energy<0) {
        deactivate();
      }
    }
  }

  @Override
    void reset() {
    super.reset();
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    fastForward=false;
    F =1;
    timeBend=1;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 400); //now fastforward
    //controlable=(controlable)?false:true;
    regen=true;
    drawTimeSymbol();
  }
  @Override
    void setOwner(Player _owner) {
    super.setOwner(_owner);
    if (round(random(1))==0)owner.fastforwardImmunity=true;
  }
}



class Freeze extends Ability { //---------------------------------------------------    Freeze   ---------------------------------

  Freeze() {
    super();
    icon=icons[3];
    name=getClassName(this);
    activeCost=16;
    energy=50;
    channelCost=0.08;
    deactiveCost=4;
    active=false;
    meta=true;
  }
  @Override
    void action() {
    quitOrigo();
    if (owner.freezeImmunity) {
      for (int i =0; i<4; i++) {
        particles.add( new Feather(400, int(owner.cx), int(owner.cy), random(-5, 5), random(-5, 5), 15, owner.playerColor));
      }
      particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, owner.w, 50, owner.playerColor));
    }
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    freeze=(freeze)?false:true;
    speedControl.clear();
    speedControl.addSegment((freeze)?0:1, 150); //now stop
    controlable=(controlable)?false:true;
    /* for (int i=0; i< players.size (); i++) {
     stamps.add( new ControlStamp(i, int(players.get(i).x), int( players.get(i).y), 0, 0, 0, 0));
     stamps.add( new ControlStamp(i, int(players.get(i).x), int( players.get(i).y), players.get(i).vx, players.get(i).vy, players.get(i).ax, players.get(i).ay));
     }*/
    for (Player P : players) {
      stamps.add( new ControlStamp(P.index, int(P.x), int( P.y), 0, 0, 0, 0));
      stamps.add( new ControlStamp(P.index, int(P.x), int( P.y), P.vx, P.vy, P.ax, P.ay));
    }
    controlable=(controlable)?false:true;
    drawTimeSymbol();
  }

  @Override
    void press() {
    if (!active) {
      if (energy>0+activeCost) {
        activate();
      }
    } else {
      deactivate();
    }
  }
  void activate() { 
    active=true;
    energy -= activeCost;
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 150, owner.playerColor));
    stamps.add( new ControlStamp(owner.index, int(owner.x), int( owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    regen=false;
    action();
  }

  @Override
    void deactivate() {
    super.deactivate();
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 200, 16, 850, owner.playerColor));
    action();
    //  stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
    regen=true;
  }
  @Override
    void passive() {
    if (active) {
      channel();
      if (energy<0) {
        deactivate();
      }
    }
  }
  @Override
    void reset() {
    super.reset();
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    freeze=false;
    speedControl.clear();
    speedControl.addSegment((freeze)?0:1, 150); //now stop
    controlable=true;
    for (Player P : players) {
      stamps.add( new ControlStamp(P.index, int(P.x), int( P.y), 0, 0, 0, 0));
      stamps.add( new ControlStamp(P.index, int(P.x), int( P.y), P.vx, P.vy, P.ax, P.ay));
    }
    drawTimeSymbol();
  }
  @Override
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
    channelCost=0.04;
    deactiveCost=8;
    active=false;
    meta=true;
  }
  @Override
    void action() {
    if (!mute)musicPlayer.pause(false);
    reverse=(reverse)?false:true;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 600); //now rewind
    controlable=(controlable)?false:true;
    drawTimeSymbol();
    quitOrigo();
  }
  @Override
    void press() {
    if (!active) {
      if (energy>0+activeCost) {
        activate();
      }
    } else {
      deactivate();
    }
  }
  @Override
    void activate() { 
    energy -= activeCost;
    action();
    active=true;
    regen=false;
  }
  @Override
    void deactivate() {
    super.deactivate();
    //  stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
    action();
    active=false;
    regen=true;
  }
  void passive() {
    if (active|| reverse) {
      channel();
      if (energy<0) {
        deactivate();
      }
    }
  }
  @Override
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
  @Override
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
  @Override
    void press() {
    if (!active) {
      if (energy>0+activeCost) {
        activate();
        action();
      }
    } else {
      deactivate();
      action();
    }
  }
  @Override
    void deactivate() {
    super.deactivate();
    //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
    stamps.add( new AbilityStamp(this));

    regen=true;
  }
  @Override
    void reset() {
    super.reset();
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    if (mute)musicPlayer.pause(false);
    slow=false;
    S =1;
    timeBend=1;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 800); //now slow
    //controlable=(controlable)?false:true;
    drawTimeSymbol();
  }

  @Override
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
  @Override
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
        particles.add(new ShockWave(int(p.cx), int( p.cy), 20, 16, 500, p.playerColor));
        particles.add( new  Particle(int(p.cx), int( p.cy), 0, 0, int(p.w), 1000, p.playerColor));
      }
      // speedControl.clear();
      displayTime=int(stampTime*0.001);
      saved =new CheckPoint(); // timeStamps special object
    }
    regen=false;
    drawTimeSymbol();
  }
  @Override
    void press() {
    if (!active ) {
      if (energy>0+activeCost && !owner.dead) {
        activate();
        action();
      }
    } else {
      deactivate();
    }
  }
  @Override
    void deactivate() {
    quitOrigo();
    super.deactivate();
    saved.call();
    shakeTimer=30;
    particles.add(new Flash(1200, 5, WHITE));   // flash
    regen=true;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 100); 
    drawTimeSymbol();
    pulse=0;
  }
  @Override
    void passive() {
    if (!freeze && active) { 
      passiveUpdate();
    }
    passiveDisplay();
  }

  void passiveUpdate() {
    if (active) {
      if (endTime<stampTime) {
        particles.add(new Flash(1500, 5, WHITE));   // flash
        for (int i=0; i< 10; i++) {
          balls.add(new Ball(int(owner.cx), int(owner.cy), int(cos(radians(i*36))*8), int(sin(radians(i*36))*8), int(40), owner.playerColor));
          balls.get(balls.size()-1).owner=owner;  
          balls.get(balls.size()-1).ally=owner.ally;  
          projectiles.add(balls.get(balls.size()-1));
        }
        super.deactivate();
        regen=true;
        energy+=deactiveCost;
      }
      pulse+=4;
    }
  }

  void passiveDisplay() {
    stroke(WHITE);
    strokeWeight(int(sin(radians(pulse))*8)+1);
    fill(WHITE);
    if (active) { 
      float f = (float)(endTime-stampTime)/duration;
      for (int i=0; i<360*f; i+= (360/12)) {
        line(owner.cx+ cos(radians(-90-i))*80, owner.cy+sin(radians(-90-i))*80, owner.cx+ cos(radians(-90-i))*130, owner.cy+sin(radians(-90-i))*130);
      }
      text(displayTime, owner.cx, owner.y-owner.h);
    }
    noFill();
    // point(owner.cx+cos(radians(owner.angle))*range, owner.cy+sin(radians(owner.angle))*range);
    ellipse(owner.cx, owner.cy, owner.w*2, owner.h*2);
  }
  void reset() {
    super.reset();
    for (Ball b : balls) {
      b.dead=true;
      b.deathTime=stampTime;
    }
    balls.clear();
  }
}


class ThrowDagger extends Ability {//---------------------------------------------------    ThrowDagger   ---------------------------------
  int damage=18, slashdamage2=2, threashold =2;
  final int slashDuration=190, slashRange=100, slashdamage=4;
  boolean alternate;
  ThrowDagger() {
    super();
    icon=icons[0];
    name=getClassName(this);
    activeCost=8;
    cooldownTimer=80;
    regenRate=0.16;
    unlockCost=1500;
  } 
  @Override
    void action() {
    particles.add( new Star(2000, int(owner.cx), int( owner.cy), 300, 0, 0, 0.9, owner.playerColor) );

    if (abs(owner.vx)>threashold  ||  abs(owner.vy)>threashold) {
      if (abs(owner.keyAngle-owner.angle)<5) {
        if (alternate) {
          projectiles.add( new IceDagger(owner, int( owner.cx+cos(radians(owner.keyAngle-45))*75), int(owner.cy+sin(radians(owner.keyAngle-45))*75), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*32, owner.ay*32, int((damage+damageMod*.3)*1.2)));
          projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 120, owner.angle+100, 24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
          particles.add(new LineWave(int(owner.cx+cos(radians(owner.keyAngle-45))*75), int(owner.cy+sin(radians(owner.keyAngle-45))*75), 40, 100, owner.playerColor, owner.keyAngle));
        } else {
          projectiles.add( new IceDagger(owner, int( owner.cx+cos(radians(owner.keyAngle+45))*75), int(owner.cy+sin(radians(owner.keyAngle+45))*75), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*32, owner.ay*32, int((damage+damageMod*.3)*1.2)));
          projectiles.add( new Slash(owner, int( owner.cx+sin(owner.keyAngle)*50), int(owner.cy+cos(owner.keyAngle)*50), 30, owner.playerColor, 120, owner.angle-100, -24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
          particles.add(new LineWave(int(owner.cx+cos(radians(owner.keyAngle+45))*75), int(owner.cy+sin(radians(owner.keyAngle+45))*75), 40, 100, owner.playerColor, owner.keyAngle));
        }
      } else {
        if (alternate) {
          projectiles.add( new ArchingIceDagger(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 1000, owner.keyAngle, (owner.keyAngle-owner.angle)*8, owner.ax*24, owner.ay*24, int(damage+damageMod*.3)));
          projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 120, owner.angle+100, 24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
          particles.add( new Feather(100, int(owner.cx+cos(radians(owner.keyAngle-45))*75), int(owner.cy+sin(radians(owner.keyAngle-45))*75), owner.ax*10, owner.ay*10, -10, owner.playerColor));
        } else { 
          projectiles.add( new ArchingIceDagger(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 1000, owner.keyAngle, (owner.keyAngle-owner.angle)*8, owner.ax*24, owner.ay*24, int(damage+damageMod*.3)));
          projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 120, owner.angle-100, -24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
          particles.add( new Feather(100, int(owner.cx+cos(radians(owner.keyAngle+45))*75), int(owner.cy+sin(radians(owner.keyAngle+45))*75), owner.ax*10, owner.ay*10, 40, owner.playerColor));
        }
      }
      alternate=!alternate;
      owner.pushForce(-6, owner.angle);
    } else {
      owner.pushForce(-12, owner.angle);
      // for (int i=0; i<360; i+=10) {
      //  projectiles.add( new ArchingIceDagger(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 1000, owner.angle, owner.angle+90, sin(radians(i))*20, -cos(radians(i))*20, damage));
      //}

      projectiles.add( new ArchingIceDagger(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 1000, owner.angle, owner.angle, sin(radians(owner.angle+140))*20, -cos(radians(owner.angle+140))*20, int(damage+damageMod*.3)*2).addBuff(new Cold(owner, 3000)));
      projectiles.add( new ArchingIceDagger(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 1000, owner.angle, owner.angle+180, sin(radians(owner.angle+40))*20, -cos(radians(owner.angle+40))*20, int(damage+damageMod*.3)*2).addBuff(new Cold(owner, 3000)));
      projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, int(slashDuration), owner.angle+90, 22, slashRange, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage, true));
      projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, int(slashDuration), owner.angle-90, -22, slashRange, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage, true));
      particles.add( new Feather(100, int(owner.cx+cos(radians(owner.keyAngle-45))*75), int(owner.cy+sin(radians(owner.keyAngle-45))*75), owner.ax*10, owner.ay*10, -10, owner.playerColor));
      particles.add( new Feather(100, int(owner.cx+cos(radians(owner.keyAngle+45))*75), int(owner.cy+sin(radians(owner.keyAngle+45))*75), owner.ax*10, owner.ay*10, 40, owner.playerColor));
    }
    enableCooldown();
  }

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost&&  cooldown<stampTime && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      deactivate();
    }
  }
}
class Torpedo extends Ability implements AmmoBased {//---------------------------------------------------    Torpedo   ---------------------------------
  final int damage=26, angleRecoil=115, projectileSize=60;
  float accuracy=1, MODIFIED_ANGLE_FACTOR=0.2;
  Torpedo() {
    super();
    icon=icons[57];

    name=getClassName(this);
    activeCost=maxEnergy;
    maxAmmo=2;
    cooldownTimer=400;
    regenRate=0.7;
    unlockCost=500;
    unlocked=true;
  } 
  @Override
    void action() {
    stamps.add( new AbilityStamp(this));
    RCRocket RC= new RCRocket(owner, int( owner.cx), int(owner.cy), projectileSize, owner.playerColor, 2000, owner.angle, 0, cos(radians(owner.angle))*0, sin(radians(owner.angle))*0, int(damage+damageMod*.5), true, false);
    RC.blastRadius=300;
    RC.acceleration=4.2;
    projectiles.add(RC);
    particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 30, 42, 65, WHITE));
    owner.pushForce(-25, owner.angle);
    owner.angle+=random(-angleRecoil, angleRecoil);
    owner.keyAngle=owner.angle;
    ammo--;
  }

  @Override
    void press() {
    // particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
    if ( ammo > 0&& cooldown<stampTime  &&(!reverse || owner.reverseImmunity)&&  !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      enableCooldown();

      action();
    } else {
      if (energy>=0+activeCost  && ammo<=0 && !owner.dead) {
        reload();
        activate();
        regen=true;
      }
    }
  }
  @Override
    void passive() {
    if (!owner.stealth) { 
      strokeWeight(14);
      //stroke(owner.playerColor);
      stroke(BLACK);
      noFill();
      //fill(0);
      line(owner.cx+cos(radians(owner.angle-140))*owner.radius-cos(radians(owner.angle))*+owner.w, owner.cy+sin(radians(owner.angle-140))*owner.radius-sin(radians(owner.angle))*+owner.w, owner.cx+cos(radians(owner.angle-140))*owner.radius+cos(radians(owner.angle))*+owner.radius, owner.cy+sin(radians(owner.angle-140))*owner.radius+sin(radians(owner.angle))*+owner.radius);
      strokeWeight(5);
      if (ammo>0)triangle(owner.cx+cos(radians(owner.angle-140))*projectileSize+cos(radians(owner.angle))*+owner.w, owner.cy+sin(radians(owner.angle-140))*projectileSize+sin(radians(owner.angle))*+owner.w, owner.cx+cos(radians(owner.angle))*projectileSize+cos(radians(owner.angle))*+owner.w, owner.cy+sin(radians(owner.angle))*projectileSize+sin(radians(owner.angle))*+owner.w, owner.cx+cos(radians(owner.angle+140))*projectileSize+cos(radians(owner.angle))*+owner.w, owner.cy+sin(radians(owner.angle+140))*projectileSize +sin(radians(owner.angle))*+owner.w );
      fill(BLACK);
      if (ammo>1) {
        textSize(40);
        text(int(ammo), owner.cx+cos(radians(owner.angle))*+owner.w, owner.cy+sin(radians(owner.angle))*+owner.w);
      }
    }
    // strokeWeight(5);
    //  stroke(BLACK);
    // fill(BLACK);
    //ellipse(x, y, (, (size*(deathTime-stampTime)/time)-size );
    // triangle(x+cos(radians(angle-140))*timedScale, y+sin(radians(angle-140))*timedScale, x+cos(radians(angle))*timedScale, y+sin(radians(angle))*timedScale, x+cos(radians(angle+140))*timedScale, y+sin(radians(angle+140))*timedScale  );
    // noFill();

    owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
  }
  void reload() {
    owner.stop();
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 24, 200, owner.playerColor));
    particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w)+50, 900, color(255, 0, 255)));
    ammo=maxAmmo;
  }
  void reloadCancel() {
  }
  void reset() {
    super.reset();
    cooldownTimer=int(400-attackSpeedMod*3); //100
  }
}
class Pistol extends Ability {//---------------------------------------------------    Pistol   ---------------------------------
  final int damage=16, angleRecoil=45;
  int r;
  float accuracy=1, MODIFIED_ANGLE_FACTOR=0.2;
  Pistol() {
    super();
    name=getClassName(this);
    activeCost=maxEnergy;
    cooldownTimer=200;
    maxAmmo=12;
    ammo=0;
    icon=icons[38];
    cooldownTimer=240;
    regenRate=0.24;
    unlockCost=500;
    unlocked=true;
  } 
  @Override
    void action() {
    owner.addBuff(new SpeedBuff(owner, 1500, 0.12).apply(BuffType.ONCE));
    stamps.add( new AbilityStamp(this));
    if (energy>=maxEnergy)
      projectiles.add( new RevolverBullet(owner, int( owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 70, 16, owner.playerColor, 1000, owner.angle, int(damage+damageMod*.6)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod)*1.5)));

    else
      projectiles.add( new RevolverBullet(owner, int( owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 60, 14, owner.playerColor, 1000, owner.angle, int(damage+damageMod*.6)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod)*1.5)));


    particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 20, 32, 55, WHITE));
    owner.pushForce(-10, owner.angle);
    owner.angle+=random(-angleRecoil, angleRecoil);
    owner.keyAngle=owner.angle;
    ammo--;
    r=30;
  }

  @Override
    void press() {
    // particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
    if ( cooldown<stampTime && ammo > 0&& cooldown<stampTime  &&(!reverse || owner.reverseImmunity)&&  !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      action();
      enableCooldown();
    } else {
      if (energy>=0+activeCost  && ammo<=0) {
        reload();

        activate();
        regen=true;
      } else {
        r=70;
      }
    }
  }
  @Override
    void passive() {
    if (!owner.stealth) { 
      strokeWeight(3);
      stroke(owner.playerColor);
      noFill();
      for (int i=0; i< ammo; i++)line(owner.cx-20, owner.cy+50+i*8, owner.cx+20, owner.cy+50+i*8);
    }
    owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
  }
  void reload() {
    r=-30;
    owner.vx*=.5;
    owner.vy*=.5;
    owner.ax*=.5;
    owner.ay*=.5;
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 24, 200, owner.playerColor));
    particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    ammo=maxAmmo;
  }
  void reset() {
    super.reset();
    cooldownTimer=int(170-attackSpeedMod*1.7); //100
  }
}
class Revolver extends Ability {//---------------------------------------------------    Revolver   ---------------------------------
  final int damage=45, angleRecoil=180;
  int r;
  float accuracy=1, MODIFIED_ANGLE_FACTOR=0.18;
  Revolver() {
    super();
    icon=icons[9];
    name=getClassName(this);
    activeCost=maxEnergy;
    maxAmmo=6;
    ammo=0;
    cooldownTimer=250;
    regenRate=0.24;
    critDamage=20;
    critChance=20;
    unlockCost=5000;
  } 
  @Override
    void action() {
    stamps.add( new AbilityStamp(this));
    if (energy>=maxEnergy)  projectiles.add( new RevolverBullet(owner, int( owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 65, 30, owner.playerColor, 1000, owner.angle, (damage+damageMod)*1.2).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod)*1.2)));
    else projectiles.add( new RevolverBullet(owner, int( owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 60, 25, owner.playerColor, 1000, owner.angle, damage+damageMod).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
    particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 30, 32, 75, owner.playerColor));
    projectiles.add( new  Blast(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 5, 100, owner.playerColor, 50, owner.angle, 0));
    shakeTimer+=8;
    owner.pushForce(-13, owner.angle);
    owner.angle+=random(-angleRecoil, angleRecoil);
    owner.angle=owner.keyAngle;
    owner.pushForce(4, owner.keyAngle);
    ammo--;
    r=30;
  }

  @Override
    void press() {
    // particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
    if ( ammo > 0&& cooldown<stampTime  &&(!reverse || owner.reverseImmunity)&&  !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      action();
      enableCooldown();
    } else {
      if (energy>=0+activeCost  && ammo<=0) {
        reload();
        activate();
        regen=true;
      } else {
        r=70;
      }
    }
  }
  @Override
    void passive() {
    if (!owner.stealth) { 
      strokeWeight(2);
      stroke(owner.playerColor);
      noFill();
      if (r<90)r+=int(5*timeBend);
      for (int i =-r; i<=360; i+= 360/maxAmmo) {
        ellipse(owner.cx+cos(radians(i))*90, owner.cy+sin(radians(i))*90, 40, 40);
      }
      fill(owner.playerColor);
      for (int i =0; i<=maxAmmo; i++) {
        if (ammo>i)ellipse(owner.cx+cos(radians(i*360/maxAmmo-r))*90, owner.cy+sin(radians(i*360/maxAmmo-r))*90, 30, 30);
      }
    }
    owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
  }
  void reload() {
    r=-30;
    owner.stop();
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 24, 200, owner.playerColor));
    particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    ammo=maxAmmo;
  }

  void reset() {
    super.reset();
    regen=true;
    active=false;
    deChannel();
    energy=50;
    ammo=0;
    cooldown=0;
  }
}
class ForceShoot extends Ability {//---------------------------------------------------    forceShoot   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=60;
  final int damageFactor=5;
  float forceAmount=0, MODIFIED_MAX_ACCEL=0.02, MODIFIED_ANGLE_FACTOR=0.16;
  float ChargeRate=0.4, restForce;
  boolean maxed;
  ForceShoot() {
    super();
    icon=icons[1];
    name=getClassName(this);
    regenRate=0.2;
    activeCost=8;
    channelCost=0.1;
    unlockCost=3000;
  } 
  @Override
    void action() {
    //  Gradient(int _time, int _x, int _y, float _vx, float _vy, int _maxSize, float _shrinkRate, float _angle, color _particleColor) {


    if (forceAmount>=MAX_FORCE) { 
      particles.add(new Flash(100, 6, WHITE)); 
      particles.add(new Gradient(3000, int(owner.cx), int(owner.cy), 0, 0, 25, 1, owner.angle, WHITE));
      particles.add(new Gradient(2000, int(owner.cx), int(owner.cy), 0, 0, 50, 2, owner.angle, owner.playerColor));
      particles.add(new Gradient(1000, int(owner.cx), int(owner.cy), 0, 0, 100, 10, owner.angle, WHITE));
      shakeTimer+=10;
    }

    projectiles.add( new ForceBall(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), forceAmount*2+4, 35, owner.playerColor, 2000, owner.angle, forceAmount*damageFactor+damageMod));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity) && energy>(0+activeCost)&& !hold && !active && !channeling && !owner.dead) {
      activate();
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=false;
    }
  }
  @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity) &&  active && !owner.dead) {
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      if (MAX_FORCE>forceAmount) { 
        channel();
        if (!active || energy<0 ) {
          release();
        }
        maxed=false;
        restForce = MAX_FORCE-forceAmount;
        forceAmount+=ChargeRate*timeBend; 
        particles.add(new RParticles(int(owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), random(-restForce*0.5, restForce*0.5), random(-restForce*0.5, restForce*0.5), int(random(30)+10), 200, owner.playerColor));
        particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), int(forceAmount*.5), 16, int(forceAmount*.5), owner.playerColor));
      } else {
        if (!maxed) {
          particles.add( new Star(2000, int(owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 0, 0, 450, 0.9, WHITE) );
          maxed=true;
        }  
        particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 0, 0, int(MAX_FORCE*1.5), 30, color(255, 0, 255)));
      }
    }
    if (!active)press(); // cancel
    if (owner.hit)release(); // cancel
  }
  @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        owner.pushForce(-forceAmount, owner.angle);
        regen=true;
        action();
        deChannel();
        deactivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        forceAmount=0;
      }
    }
  }
  void reset() {
    super.reset();
    forceAmount=0;
    //   hold=false;
    //  active=false;
    regen=true;
    //  channeling=false;
    deChannel();
    release();
  }
  @Override
    void passive() {
    if (MAX_FORCE<=forceAmount) {
      fill(WHITE);
      pushMatrix();
      translate(int(owner.cx), int(owner.cy));
      rotate(radians(owner.angle-90));
      rect(-5, 0, 10, 2000);
      popMatrix();
    }
  }
}

class Blink extends Ability {//---------------------------------------------------    Blink   ---------------------------------
  final int range=250, damage=40;
  Blink() {
    super();
    icon=icons[7];
    name=getClassName(this);
    activeCost=10;
    energy=40;
    unlockCost=2000;
    critChance=20;
    critDamage=20;
  } 
  @Override
    void action() {
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
    particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    for (int i =0; i<3; i++) {
      particles.add( new Feather(300, int(owner.cx), int(owner.cy), random(-2, 2), random(-2, 2), 15, owner.playerColor));
    }
    owner.x+=cos(radians(owner.angle))*range;
    owner.y+=sin(radians(owner.angle))*range;
    checkInside();
    //projectiles.add( new IceDagger(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, 10));

    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      deactivate();
    }
  }
  void checkInside() {
    for (Player enemy : players) {
      if (!enemy.dead  && owner.ally != enemy.ally&& enemy.targetable && dist(owner.x, owner.y, enemy.x, enemy.y)<90) {
        enemy.hit(damage+damageMod+ int(owner.hit ?int(crit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))) : 0));
        energy+=activeCost*.5;
        particles.add(new Flash(100, 8, BLACK));  
        particles.add( new TempFreeze(200));
        //for (int i =0; i<2; i++) {
        particles.add( new Feather(300, int(owner.cx), int(owner.cy), random(-4, 4), random(-4, 4 ), 20, enemy.playerColor));
        //}
        particles.add(new ShockWave(int(enemy.x+enemy.radius), int(enemy.y+enemy.radius), 300, 16, 300, WHITE));
        particles.add(new ShockWave(int(enemy.x+enemy.radius), int(enemy.y+enemy.radius), 100, 16, 300, owner.playerColor));
        for (int i=0; i<360; i+=30) particles.add(new Spark( 1000, int(enemy.x+enemy.radius), int(enemy.y+enemy.radius), -cos(radians(i))*5, -sin(radians(i))*5, 6, i, owner.playerColor));
      }
    }
  }
  void reset() {
    super.reset();
    energy=40;
  }
}
class Multiply extends Ability {//---------------------------------------------------    Multiply   ---------------------------------
  int range=playerSize, cloneDamage=3, dir;
  float cloneHealthPercent=0.5;
  ArrayList<Player> cloneList= new ArrayList<Player>();
  Player currentClone;
  Multiply() {
    super();
    icon=icons[33];
    name=getClassName(this);
    activeCost=70;
    unlockCost=3500;
  } 
  @Override
    void action() {
    for (int i=0; i<5; i++) {
      particles.add(new Particle(int(owner.cx), int(owner.cy), random(-10, 10), random(-10, 10), int(random(20)+5), 800, 255));
    }
    // stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    try {
      switch(dir%4) {
      case 0:
        currentClone=new Player(players.size()-1, owner.playerColor, int(owner.x-cos(radians(owner.angle))*range), int(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.down, owner.up, owner.right, owner.left, owner.triggKey, new Suicide());
        break;
      case 1:
        currentClone=new Player(players.size()-1, owner.playerColor, int(owner.x-cos(radians(owner.angle))*range), int(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.right, owner.left, owner.up, owner.down, owner.triggKey, new Suicide());
        break;
      case 2:
        currentClone=new Player(players.size()-1, owner.playerColor, int(owner.x-cos(radians(owner.angle))*range), int(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.up, owner.down, owner.left, owner.right, owner.triggKey, new Suicide());
        break;
      case 3:
        currentClone=new Player(players.size()-1, owner.playerColor, int(owner.x-cos(radians(owner.angle))*range), int(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.left, owner.right, owner.down, owner.up, owner.triggKey, new Suicide());
        break;
      }
      //currentClone.abilityList=owner.abilityList;
      for (Ability a : owner.abilityList) {
        Ability temp=a.clone();
        temp.setOwner(currentClone);
        temp.reset();
        currentClone.abilityList.add(temp);
      }

      currentClone.replaceAbility(new Multiply(), new NoActive() );
    }
    catch(Exception e) {
      println(e +"multiply");
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
    currentClone.freezeImmunity=owner.freezeImmunity;
    currentClone.reverseImmunity=owner.reverseImmunity;
    currentClone.slowImmunity=owner.slowImmunity;
    currentClone.fastforwardImmunity=owner.fastforwardImmunity;
    players.add(currentClone);
    cloneList.add(currentClone);
    //stamps.add( new StateStamp(currentClone.index, int(owner.x), int(owner.y), owner.state, owner.health, true));
    stamps.add( new StateStamp(players.size()-1, int(owner.x), int(owner.y), owner.state, owner.health, true));
    currentClone.dead=false;
    currentClone.maxHealth=int(owner.maxHealth*cloneHealthPercent);
    currentClone.health=int(owner.health*cloneHealthPercent);
    currentClone.abilityList.get(0).energy=int(owner.abilityList.get(0).energy);

    //   owner.ability.owner=owner;
    /* for (int i =players.size()-1; i>= 0; i--) {
     if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
     }*/
  }
  @Override
    void reset() {
    cloneList.clear();
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      deactivate();
    }
  }
}
/*class CloneMultiply extends Multiply { // ability that have no effect as clones.
 int damage=50;
 CloneMultiply() {
 super();
 name=getClassName(this);
 }
 @Override
 void action() {
 //projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 75, owner.playerColor, 1000, owner.angle, 0, 0, damage, false));
 // for (int i=0; i<10; i++) {
 // particles.add(new Particle(int(owner.cx), int(owner.cy), random(-10, 10), random(-10, 10), int(random(20)+5), 800, 255));
 // }
 }
 @Override
 void press() {
 if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
 stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
 regen=true;
 activate();
 action();
 deactivate();
 }
 }
 @Override
 void reset() {
 super.reset();
 //if (owner.turret || owner.clone) players.remove( owner);
 //for (TimeStamp s:stamps )if(s.playerIndex==players.indexOf(owner))stamps.remove(players.indexOf(owner));
 
 
 // for (int i =players.size()-1; i>= 0; i--) {
 // if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
 // }
 }
 @Override
 void onDeath() {
 if ((!reverse || owner.reverseImmunity)&&  owner.health<=0 && (!freeze || owner.freezeImmunity)) {
 projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 160, owner.playerColor, 1000, owner.angle, owner.vx, owner.vy, damage, false));
 }
 }
 }*/

class Stealth extends Ability {//---------------------------------------------------    Stealth   ---------------------------------
  int projectileDamage=16, wait;
  float MODIFIED_MAX_ACCEL=0.06;
  float range=160, duration=300;
  Stealth() {
    super();
    icon=icons[4];
    active=false;
    name=getClassName(this);
    activeCost=25;
    energy=25;
    unlockCost=2500;
  } 
  @Override
    void action() {
    stamps.add( new StateStamp(owner.index, int(owner.x), int(owner.y), owner.state, owner.health, owner.dead));
    particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 300, color(255, 0, 255)));
    //  for (int i =0; i<10; i++) {
    particles.add( new Feather(300, int(owner.cx), int(owner.cy), random(-2, 2), random(-2, 2), 500, owner.playerColor));
    //}
    owner.stealth=true;
  }
  @Override
    void press() {

    if ((!reverse || owner.reverseImmunity)&& !owner.dead && (!freeze || owner.freezeImmunity)) {
      if (energy>0+activeCost && !active) { 
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        stamps.add( new StateStamp(owner.index, int(owner.x), int(owner.y), owner.state, owner.health, owner.dead));
        regen=false;
        activate();
        particles.add(new Flash(300, 6, owner.playerColor));  
        action();
        owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      } else if (owner.stealth) {
        stamps.add( new StateStamp(owner.index, int(owner.x), int(owner.y), owner.state, owner.health, owner.dead));
        deactivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        regen=true;
        owner.stealth=false;
        particles.add(new TempSlow(int(wait*.1), 0.02, 1.06));
        particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
        projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 70, owner.playerColor, int(duration), owner.angle, 24, range, 0, 0, int(projectileDamage+wait*0.1+damageMod), true));
        particles.add(new TempZoom(owner, 1000, 1.1, DEFAULT_ZOOMRATE, true));

        if (wait>=400)projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 120, owner.playerColor, int(duration*.3), owner.angle-80, -24, range*2, 0, 0, int(projectileDamage+wait*0.03+damageMod*0.8), true));

        wait=0;
      }
    }
  }

  @Override
    void reset() {
    owner.stealth=false;
    active=false;
    regen=true;
    energy=25;
  }
  @Override
    void passive() {
    if (owner.stealth ) {
      if (wait<400)wait++;
      //text(wait, owner.x, owner.y);
      //line(owner.x,owner.x,owner.x+cos(),owner.y+sin());
      if ( int(random(60))==0)particles.add(new Particle(int(owner.cx), int(owner.cy), random(-5, 5), random(-5, 5), int(random(20)+5), 600, 255));
    }
  }
}


class Combo extends Ability {//---------------------------------------------------    Combo   ---------------------------------
  int projectileDamage=34, step=1, maxStep=3, damage=12, shootSpeed=35;
  float MODIFIED_MAX_ACCEL=0.08, MODIFIED_MAX_ACCEL_2=0.25, MODIFIED_FRICTION_FACTOR=0.12;
  int comboMinWindow= 185, comboMaxWindow=800;
  long comboWindowTimer;
  int stepActivateCost[]={0, 10, 5, 8, 5};
  Combo() {
    super();

    icon=icons[15];
    active=false;
    name=getClassName(this);
    activeCost=stepActivateCost[1];
    energy=110;
    regenRate=0.15;
    unlockCost=5500;
  } 

  @Override
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
  void attack() {
    switch(step) {
    case 1:
      projectiles.add( new Slash(owner, int( owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 30, owner.playerColor, 130, owner.angle-100, -24, 100, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, int((damage+damageMod*0.1)*0.4), true));
      owner.pushForce(4, owner.angle);
      if (!freeze ) {
        projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle+30))*150), int(owner.cy+sin(radians(owner.angle+30))*150), owner.playerColor, 325, owner.angle-90+30, damage+damageMod, int(cos(radians(owner.angle+30))*125), int(sin(radians(owner.angle+30))*125)));
        projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle))*150), int(owner.cy+sin(radians(owner.angle))*150), owner.playerColor, 350, owner.angle-90, damage+damageMod, int(cos(radians(owner.angle))*125), int(sin(radians(owner.angle))*125)));
        projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle-30))*150), int(owner.cy+sin(radians(owner.angle-30))*150), owner.playerColor, 375, owner.angle-90-30, damage+damageMod, int(cos(radians(owner.angle-30))*125), int(sin(radians(owner.angle-30))*125)));
      } else {
        projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle+30))*150), int(owner.cy+sin(radians(owner.angle+30))*150), owner.playerColor, 325, owner.angle-90+30, damage+damageMod));
        projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle))*150), int(owner.cy+sin(radians(owner.angle))*150), owner.playerColor, 350, owner.angle-90, damage+damageMod));
        projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle-30))*150), int(owner.cy+sin(radians(owner.angle-30))*150), owner.playerColor, 375, owner.angle-90-30, damage+damageMod));
      }
      break;
    case 2:
      projectiles.add( new Slash(owner, int( owner.cx+cos(radians(owner.angle))*65), int(owner.cy+sin(radians(owner.angle))*65), 32, owner.playerColor, 130, owner.angle+100, 24, 140, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, int((damage+damageMod*0.1)*0.9), true));
      owner.pushForce(20, owner.angle);
      particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 175, owner.playerColor));

      break;
    case 3:
      projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 60, owner.playerColor, 500, owner.angle+200, -25, 175, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, int((damage+damageMod*0.1)*1.1), true));
      owner.pushForce(4, owner.angle);
      particles.add( new Feather(350, int(owner.cx), int(owner.cy), owner.vx, owner.vy, 30, owner.playerColor));

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
  @Override
    void press() {

    if ((!reverse || owner.reverseImmunity)&& !owner.dead && (!freeze || owner.freezeImmunity)) {
      activeCost=stepActivateCost[step];
      if (energy>0+activeCost ) { 
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        stamps.add( new StateStamp(owner.index, int(owner.x), int(owner.y), owner.state, owner.health, owner.dead));

        //particles.add(new Flash(300, 6, owner.playerColor));  
        action();
        // owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      }
    }
  }
  @Override
    void reset() {
    super.reset();
    active=false;
    regen=true;
    //energy=maxEnergy;
  }
  @Override
    void passive() {
    //if (owner.stealth && int(random(60))==0)particles.add(new Particle(int(owner.cx), int(owner.cy), random(-5, 5), random(-5, 5), int(random(20)+5), 600, 255));
    if (step==3) {
      owner.MAX_ACCEL= MODIFIED_MAX_ACCEL_2;
      owner.FRICTION_FACTOR=MODIFIED_FRICTION_FACTOR;
      // if(random(10)<2)particles.add( new Feather(350, int(owner.cx), int(owner.cy), random(-1, 1), random(-1, 1), 30, owner.playerColor));
      particles.add(new Particle(int(owner.cx), int(owner.cy), owner.vx, owner.vy, 120, 50, WHITE));
    } else {
      owner.MAX_ACCEL= MODIFIED_MAX_ACCEL;
      owner.FRICTION_FACTOR= DEFAULT_FRICTION;
    }

    if (debug)text(step, int(owner.x), int(owner.y));
    if (stampTime>comboWindowTimer+comboMaxWindow) {
      if (step>1)step--;
      comboWindowTimer=stampTime;
    }
  }
}

class Laser extends Ability {//---------------------------------------------------    Laser Ability  ---------------------------------
  int damage=3, duration=2400, delay=500, laserWidth=75, chargelevel;
  long timer;
  float MODIFIED_ANGLE_FACTOR=0, MODIFIED_MAX_ACCEL=0.006; 
  long startTime;
  boolean charging;
  ArrayList<Projectile> laserList = new ArrayList<Projectile>();

  Laser() {
    super();
    icon=icons[2];
    name=getClassName(this);
    activeCost=24;
    unlockCost=4500;
  } 
  @Override
    void action() {
    timer=millis();
    chargelevel++;
    particles.add(new  Gradient(  1000, int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 2500, 75*chargelevel, 4, owner.angle, owner.playerColor));
    //  if (!maxed) {
    particles.add( new Star(2500, int(owner.cx), int( owner.cy), 0, 0, 500*chargelevel, 0.8, owner.playerColor) );
    //  maxed=true;
    //}
    // particles.add(new Gradient(150*chargelevel, int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 75*chargelevel, 6*chargelevel, owner.angle, owner.playerColor));
    particles.add(new RShockWave(int(owner.cx), int(owner.cy), 270*chargelevel, 16+10*chargelevel, 150*chargelevel, owner.playerColor));
    charging=true;
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      action();
      startTime=stampTime;
      deactivate();
      // particles.add(new  Gradient(1000,int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 3, owner.angle, owner.playerColor));
    }
  }
  void passive() {
    if (charging && (timer+delay/S/F)<millis()) {
      particles.add(new ShockWave(int(owner.cx), int(owner.cy), 200*chargelevel, 16, 500, owner.playerColor));
      particles.add(new Flash(50, 6, WHITE)); 

      Projectile l =new ChargeLaser(owner, int( owner.cx+random(50, -50)), int(owner.cy+random(50, -50)), laserWidth*chargelevel, owner.playerColor, duration, owner.angle, 0, damage*chargelevel+damageMod*.1, true);
      laserList.add(l);
      projectiles.add(l);
      // projectiles.add( new ChargeLaser(owner, int( owner.cx+random(50, -50)), int(owner.cy+random(50, -50)), laserWidth*chargelevel, owner.playerColor, duration, owner.angle, damage*chargelevel));

      charging=false;
      chargelevel=0;
    } else {
      owner.ANGLE_FACTOR=(owner.DEFAULT_ANGLE_FACTOR/duration)*(stampTime-startTime)*0.02*timeBend;
      owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.3*timeBend;
      if (stampTime>=duration+startTime) {
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
      }
    }
  }
  @Override
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
    deactivate();
    timer=stampTime;
    super.reset();
  }
}

class DoubleTap extends Laser {//---------------------------------------------------    DoubleTap Ability  ---------------------------------
  int maxChargeLevel=2;
  DoubleTap() {
    super();
    duration=180;
    delay=170;
    damage=30;
    icon=icons[2];
    name=getClassName(this);
    activeCost=15;
    regenRate=0.2;
    unlockCost=4500;
  } 
  @Override
    void action() {
    timer=millis();
    chargelevel++;
    particles.add(new Gradient(150*chargelevel, int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 20*chargelevel, 6*chargelevel, owner.angle, owner.playerColor));
    particles.add(new RShockWave(int(owner.cx+cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 270*chargelevel, 16+10*chargelevel, 150*chargelevel+150, owner.playerColor));
    charging=true;
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost&& maxChargeLevel>chargelevel && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      action();
      startTime=stampTime;
      deactivate();
      // particles.add(new  Gradient(1000,int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 3, owner.angle, owner.playerColor));
    }
  }
  void passive() {
    if (charging && (timer+delay/S/F)<millis()) {

      switch(chargelevel) {
      case 1:
        projectiles.add( new Slug(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 1200, owner.angle, cos(radians(owner.angle))*36, sin(radians(owner.angle))*36, int(damage+damageMod)));
        break;
      case 2:
        projectiles.add( new Slug(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 160, owner.playerColor, 10000, owner.angle, cos(radians(owner.angle))*10, sin(radians(owner.angle))*10, int(damage*3+damageMod*2)));
        particles.add(new Flash(50, 6, WHITE)); 
        break;
      }    
      particles.add(new ShockWave(int(owner.cx), int(owner.cy), 100*chargelevel, 16*chargelevel, 400, owner.playerColor));

      owner.pushForce(-20*chargelevel, owner.angle);

      // projectiles.add( new ChargeLaser(owner, int( owner.cx+random(50, -50)), int(owner.cy+random(50, -50)), laserWidth*chargelevel, owner.playerColor, duration, owner.angle, damage*chargelevel));

      charging=false;
      chargelevel=0;
    } else {
      owner.ANGLE_FACTOR=(owner.DEFAULT_ANGLE_FACTOR/duration)*(stampTime-startTime)*0.02*timeBend;
      owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.3*timeBend;
      if (stampTime>=duration+startTime) {
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
      }
    }
  }
  @Override
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
    deactivate();
    timer=0;
    super.reset();
  }
}

class Shotgun extends Ability {//---------------------------------------------------    Shotgun   ---------------------------------
  int damage=5, duration=900, delay=300, laserWidth=75, chargelevel;
  long timer;
  float MODIFIED_ANGLE_FACTOR=0.5, MODIFIED_MAX_ACCEL=0.006; 
  long startTime;
  boolean charging;
  Shotgun() {
    super();
    icon=icons[10];
    name=getClassName(this);
    inAccuracy=35;
    activeCost=30;
    critDamage=2;
    critChance=20;
    regenRate=0.24;
    unlockCost=3500;
    inAccuracy=40-accuracyMod*.135;
    if (inAccuracy<0)inAccuracy=0;
  } 
  @Override
    void action() {
    timer=millis();
    // chargelevel++;
    // particles.add(new Gradient(150*chargelevel, int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 75*chargelevel, 6*chargelevel, owner.angle, owner.playerColor));
    particles.add(new RShockWave(int(owner.cx+cos(radians(owner.angle))*120), int(owner.cy+sin(radians(owner.angle))*120), 300, 16+10, 150, WHITE));
    charging=true;
    //projectiles.add( new ChargeLaser(owner.index, int( owner.cx), int(owner.cy), owner.playerColor, duration, owner.angle, damage));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !charging&& !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      if (!charging)action();
      startTime=stampTime;
      deactivate();
      // particles.add(new  Gradient(1000,int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 3, owner.angle, owner.playerColor));
    }
  }
  void passive() {
    if (charging && (timer+delay/S/F)<millis()) {
      //particles.add(new ShockWave(int(owner.cx), int(owner.cy), 200*chargelevel, 16, 500, owner.playerColor));
      //particles.add(new Flash(50, 6, WHITE)); 
      projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 40, owner.playerColor, 1, owner.angle, cos(radians(owner.angle))*20, sin(radians(owner.angle))*20, int(damage*0.2), false));
      projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 50, 100, owner.playerColor, 200, owner.angle, damage*0.1));
      projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 20, 200, owner.playerColor, 200, owner.angle, damage*0.1));
      inAccuracy=40-accuracyMod*.135;
      if (inAccuracy<0)inAccuracy=0;
      for (int i=0; i<14; i++) { //!!!
        float InAccurateAngle=random(-inAccuracy, inAccuracy), shotSpeed=random(30, 80);
        projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 450, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*shotSpeed, sin(radians(owner.angle+InAccurateAngle))*shotSpeed, int(damage+damageMod*.5)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
      }
      owner.pushForce(-40, owner.angle);
      charging=false;
      // chargelevel=0;
    } else {
      owner.ANGLE_FACTOR=(owner.DEFAULT_ANGLE_FACTOR/duration)*(stampTime-startTime)*0.03*timeBend;
      owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.4*timeBend;
      if (stampTime>=duration+startTime) {
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
      }
    }
  }
  void reset() {
    super.reset();
    startTime=stampTime;
    charging=false;
    owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}
class Sluggun extends Ability {//---------------------------------------------------    Shotgun   ---------------------------------
  int damage=45, duration=900, delay=300, laserWidth=75, chargelevel;
  long timer;
  float MODIFIED_ANGLE_FACTOR=0.5, MODIFIED_MAX_ACCEL=0.006, InAccurateAngle; 
  long startTime;
  boolean charging;
  Sluggun() {
    super();
    icon=icons[17];
    name=getClassName(this);
    activeCost=30;
    regenRate=0.25;
    unlockCost=3500;
  } 
  @Override
    void action() {
    timer=millis();
    // chargelevel++;
    // particles.add(new Gradient(150*chargelevel, int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 75*chargelevel, 6*chargelevel, owner.angle, owner.playerColor));
    particles.add(new RShockWave(int(owner.cx+cos(radians(owner.angle))*120), int(owner.cy+sin(radians(owner.angle))*120), 300, 16+10, 150, WHITE));
    charging=true;
    //projectiles.add( new ChargeLaser(owner.index, int( owner.cx), int(owner.cy), owner.playerColor, duration, owner.angle, damage));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !charging&& !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      if (!charging)action();
      startTime=stampTime;
      deactivate();
      // particles.add(new  Gradient(1000,int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 3, owner.angle, owner.playerColor));
    }
  }
  void passive() {
    if (charging && (timer+delay/S/F)<millis()) {


      InAccurateAngle=random(-inAccuracy, inAccuracy);
      println(InAccurateAngle);
      //particles.add(new ShockWave(int(owner.cx), int(owner.cy), 200*chargelevel, 16, 500, owner.playerColor));
      //particles.add(new Flash(50, 6, WHITE)); 
      projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 40, owner.playerColor, 1, owner.angle, cos(radians(owner.angle))*20, sin(radians(owner.angle))*20, damage, false));
      projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 30, 100, owner.playerColor, 200, owner.angle, damage));
      projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 10, 200, owner.playerColor, 200, owner.angle, damage));
      projectiles.add( new Slug(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 70, owner.playerColor, 1500, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, int(damage+damageMod)));
      owner.pushForce(-40, owner.angle);
      charging=false;
      // chargelevel=0;
    } else {
      owner.ANGLE_FACTOR=(owner.DEFAULT_ANGLE_FACTOR/duration)*(stampTime-startTime)*0.03*timeBend;
      owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.4*timeBend;
      if (stampTime>=duration+startTime) {
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
      }
    }
  }
  void reset() {
    super.reset();
    inAccuracy=20-accuracyMod*.1;
    if (inAccuracy<0)inAccuracy=0;
    charging=false;
    startTime=stampTime;
    owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class TimeBomb extends Ability {//---------------------------------------------------    TimeBomb   ---------------------------------
  int damage=55;
  int shootSpeed=32;
  TimeBomb() {
    super();
    icon=icons[6];
    name=getClassName(this);
    activeCost=12;
    regenRate=0.32;
    energy=maxEnergy*0.5;
    unlockCost=2500;
  } 
  @Override
    void action() {
    owner.pushForce(-8, owner.angle);
    //if (int(random(5))!=0) {
    if (energy<maxEnergy-activeCost) {
      projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, int(random(500, 2200)), owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, int(damage+damageMod), true));
    } else {
      projectiles.add( new Mine(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 80000, owner.angle, cos(radians(owner.angle))*shootSpeed*0.5, sin(radians(owner.angle))*shootSpeed*0.5, int(damage+damageMod), true));
      particles.add(new Particle(int(owner.cx+cos(radians(owner.angle))*325), int(owner.cy+sin(radians(owner.angle))*325), 0, 0, 100, 300, BLACK));
    }
    owner.angle+=random(-30, 30);
  }
  @Override
    void passive() {
    if (energy>=maxEnergy) {
      noFill();
      strokeWeight(4);
      stroke(owner.playerColor);
      rect(owner.cx+cos(radians(owner.angle))*325-25, owner.cy+sin(radians(owner.angle))*325-25, 50, 50);
      stroke(color(random(255)));
      rect(owner.cx+cos(radians(owner.angle))*325-35, owner.cy+sin(radians(owner.angle))*325-35, 70, 70);
      for (int i = 0; i <= 7; i++) {
        float x = lerp(owner.cx, owner.cx+cos(radians(owner.angle))*325, i/10.0) + 10;
        float y = lerp(owner.cy, owner.cy+sin(radians(owner.angle))*325, i/10.0);
        point(x, y);
      }
    }
  }

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      deactivate();
    }
  }
}
class GranadeLauncher extends Ability {//---------------------------------------------------    TimeBomb   ---------------------------------
  int damage=40;
  int shootSpeed=42;
  GranadeLauncher() {
    super();
    icon=icons[6];
    name=getClassName(this);
    activeCost=22;
    regenRate=0.32;
    cooldownTimer=300;
    energy=maxEnergy*0.5;
    unlockCost=2500;
  } 
  @Override
    void action() {

    //if (int(random(5))!=0) {
    Granade b=new Granade(owner, int( owner.cx), int(owner.cy), 60, owner.playerColor, int(random(2000, 3000)), owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, int(damage+damageMod*.8), true);
    owner.pushForce(-12, owner.angle);
    Buff buff=new StickyBomb(owner, 2000, 20);
    buff.type= BuffType.MULTIPLE;
    b.addBuff(buff);
    b.blastRadius=270;
    b.friction=0.97;
    projectiles.add( b);
    owner.angle+=random(-30, 30);
  }
  @Override
    void passive() {
    if (cooldown<stampTime) {
      noFill();
      strokeWeight(4);
      stroke(owner.playerColor);
      for (int i = 0; i <= 20; i++) {
        float x = lerp(owner.cx, owner.cx+cos(radians(owner.angle))*325, i/10.0) + 10;
        float y = lerp(owner.cy, owner.cy+sin(radians(owner.angle))*325, i/10.0);
        point(x, y);
      }
    }
  }

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&&  cooldown<stampTime &&energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      deactivate();
      enableCooldown();
    }
  }
}


class ElemetalLauncher extends Ability {//---------------------------------------------------    ElemetalLauncher   ---------------------------------
  int  damage=22, shootSpeed=30, ammoType=0, maxAmmotype=7;
  float MODIFIED_MAX_ACCEL=0.1; 
  Containable payload[];
  ElemetalLauncher() {
    super();
    icon=icons[11];
    cooldownTimer=800;
    name=getClassName(this);
    activeCost=30;
    regenRate=0.2;
    energy=130;
    unlockCost=8000;
  } 
  @Override
    void action() {
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
    particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    switch(ammoType%maxAmmotype) {
    case 1:
      Container waterRocket= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, int(damage*0.3), false);
      payload=new Containable[2];
      payload[0]= new ChargeLaser(owner, 0, 0, 1000, owner.playerColor, 150, owner.angle-180, 20, damage*.3 ).parent(waterRocket); 
      payload[1]= new ChargeLaser(owner, 0, 0, 1000, owner.playerColor, 150, owner.angle+180, -20, damage*.3 ).parent(waterRocket); 

      waterRocket.contains(payload);
      projectiles.add((Projectile)waterRocket);
      break;
    case 2:
      Container thunderRocket= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 700, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
      payload=new Containable[6];
      for (int i=0; i<6; i++) {
        payload[i] =((Containable)new Thunder(owner, int(random(600)-300), int(random(600)-300), 220, color(owner.playerColor), 500+(150*i), 0, 0, 0, int(damage*2.5), 0, false).addBuff(new Stun(owner, 2000))).parent(thunderRocket);
      }
      thunderRocket.contains(payload);
      projectiles.add((Projectile)thunderRocket);
      break;
    case 3:
      Container rockRocket= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*shootSpeed*.5+owner.vx, sin(radians(owner.angle))*shootSpeed*.5+owner.vy, damage, false);
      payload=new Containable[1];
      payload[0]= new Block(players.size(), AI, 0, 0, 200, 200, 150, new Armor()).parent(rockRocket);
      rockRocket.contains(payload);
      projectiles.add((Projectile)rockRocket);
      break;

    case 4:
      Container natureRocket= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 700, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
      payload=new Containable[1];
      payload[0]= new  Heal(owner, 0, 0, 400, owner.playerColor, 10000, 0, 1, 1, 4, true).parent(natureRocket);
      natureRocket.contains(payload);
      projectiles.add((Projectile)natureRocket);
      break;
    case 5:
      Container iceRocket= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 500, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
      payload=new Containable[16];
      for (int i=0; i<payload.length; i++) {
        float accuracy=random(-40, 40);
        float ProjetcileSpeed=random(.5, 2);

        payload[i] =((Containable)new IceDagger(owner, 0, 0, 25, owner.playerColor, 2000, owner.angle+accuracy, cos(radians(owner.angle+accuracy))*shootSpeed*ProjetcileSpeed, sin(radians(owner.angle+accuracy))*shootSpeed*ProjetcileSpeed, int(damage*.4)).addBuff(new Cold(owner, 6000))).parent(iceRocket);
      }
      iceRocket.contains(payload);
      projectiles.add((Projectile)iceRocket);
      break;
    case 6:
      Container airRocket= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 300, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
      payload=new Containable[1];

      payload[0] =((Containable)new Graviton(owner, 0, 0, 500, owner.playerColor, 800, owner.angle, 30, int( cos(radians(owner.angle))*shootSpeed*2), int(sin(radians(owner.angle))*shootSpeed*2), damage*.6, 4).addBuff(new Stun(owner, 500))).parent(airRocket); 

      airRocket.contains(payload);
      projectiles.add((Projectile)airRocket);
      break;
    default:

      Container fireRocket= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 500, owner.angle, cos(radians(owner.angle))*shootSpeed*1.5+owner.vx, sin(radians(owner.angle))*shootSpeed*1.5+owner.vy, damage, false);
      payload=new Containable[11];

      for (int i=0; i<10; i++) {
        payload[i]= new  Blast(owner, int(cos(radians(i*36))*120), int(sin(radians(i*36))*120), 15, 100, owner.playerColor, 400, i*36, 1, 10, 15).parent(fireRocket);
      }
      payload[10]= ((Containable)new  Blast(owner, 0, 0, 0, 650, owner.playerColor, 500, 0, 0, 20, 20).addBuff(new Burn( owner, 5000, 0.004, 500))).parent(fireRocket);
      fireRocket.contains(payload);
      projectiles.add((Projectile)fireRocket);
      break;
    }
    owner.pushForce(-10, owner.angle);
    ammoType++;
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
  }
  void passive() {
    noStroke();
    textSize(24);
    fill(255);
    switch(ammoType%maxAmmotype) {
    case 0:
      text("FIRE", int(owner.cx), int(owner.cy-90));
      break;
    case 1:
      text("WATER", int(owner.cx), int(owner.cy-90));
      break;
    case 2:
      text("LIGHTNING", int(owner.cx), int(owner.cy-90));
      break;
    case 3:
      text("ROCK", int(owner.cx), int(owner.cy-90));
      break;
    case 4:
      text("NATURE", int(owner.cx), int(owner.cy-90));
      break;
    case 5:
      text("ICE", int(owner.cx), int(owner.cy-90));
      break;
    case 6:
      text("AIR", int(owner.cx), int(owner.cy-90));
      break;
    }
    owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
  }
  @Override
    void press() {
    //(!reverse || owner.reverseImmunity)
    if (cooldown<stampTime &&(!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      enableCooldown();
      activate();
      action();
      deactivate();
    }
  }
  @Override
    void reset() {
    super.reset();
    energy=90;
    deactivate();
    deChannel();
    regen=true;
    active=false;
    cooldown=stampTime;
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}




class Bazooka extends Ability {//---------------------------------------------------    Bazooka   ---------------------------------
  int  damage=28, shootSpeed=40, ammoType=2, maxAmmotype=4;
  float MODIFIED_MAX_ACCEL=0.06; 
  Bazooka() {
    super();
    icon=icons[11];
    cooldownTimer=1000;
    name=getClassName(this);
    activeCost=22;
    regenRate=0.13;
    energy=130;
    unlockCost=4500;
  } 
  @Override
    void action() {
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
    particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    switch(ammoType%maxAmmotype) {

    case 0:
      // Container R= new RCRocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 2500, owner.angle, 0, cos(radians(owner.angle))*shootSpeed*.02+owner.vx, sin(radians(owner.angle))*shootSpeed*.02+owner.vy, damage, false, true)
      projectiles.add( new RCRocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 2500, owner.angle, 0, cos(radians(owner.angle))*shootSpeed*.02+owner.vx, sin(radians(owner.angle))*shootSpeed*.02+owner.vy, damage, false, true).addBuff(new ArmorPiercing( owner, 20000, 10)));
      //  clusterRocket.contains(payload);

      // projectiles.add((Projectile)clusterRocket);
      break;
    case 1:

      Container clusterRocket= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 1000, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
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
      sr= new SinRocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 2500, owner.angle, cos(radians(owner.angle))*shootSpeed*.01+owner.vx, sin(radians(owner.angle))*shootSpeed*.01+owner.vy, damage*2, false);
      sr.count=95;
      projectiles.add( sr);
      sr= new SinRocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 2500, owner.angle, cos(radians(owner.angle))*shootSpeed*.01+owner.vx, sin(radians(owner.angle))*shootSpeed*.01+owner.vy, damage*2, false);
      sr.count=275;
      projectiles.add( sr);
      break;
    case 3:
      //  projectiles.add( new Missle(owner, int( owner.cx), int(owner.cy), 35, owner.playerColor, 7000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, false));
      Missle m= new Missle(owner, int( owner.cx), int(owner.cy), 40, owner.playerColor, 1100+int(random(400)), owner.angle, cos(radians(owner.angle))*60, sin(radians(owner.angle))*60, damage, true);
      m.blastRadius=400;
      m.addBuff(new Cold(owner, 9000));
      m.angleSpeed=15; // speed
      m.turnRate=0.15;
      m.seekRange=1000;
      projectiles.add( m);


      break;
    }
    owner.pushForce(-18, owner.angle);
    ammoType++;
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
  }
  void passive() {
    noFill();
    stroke(255);
    strokeWeight(3);
    triangle(int( owner.cx-45), int(owner.cy-110), int( owner.cx+45), int(owner.cy-110), int( owner.cx), int(owner.cy-30));
    textSize(16);
    fill(255);
    switch(ammoType%maxAmmotype) {
    case 0:
      text("RC", int(owner.cx), int(owner.cy-90));
      break;
    case 1:
      text("CL", int(owner.cx), int(owner.cy-90));
      break;
    case 2:
      text("SN", int(owner.cx), int(owner.cy-90));
      break;
    case 3:
      text("MI", int(owner.cx), int(owner.cy-90));
      break;
    }
    owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
  }
  @Override
    void press() {
    //(!reverse || owner.reverseImmunity)
    if (cooldown<stampTime &&(!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      enableCooldown();
      activate();
      action();
      deactivate();
    }
  }
  @Override
    void reset() {
    super.reset();
    energy=90;
    release();
    deactivate();
    deChannel();
    regen=true;
  }
}

class Stars extends Ability {//---------------------------------------------------    Stars   ---------------------------------
  int  damage=45, shootSpeed=6, size=20;
  float MODIFIED_MAX_ACCEL=0.04; 
  Stars() {
    super();
    icon=icons[22];
    cooldownTimer=1000;
    name=getClassName(this);
    activeCost=32;
    regenRate=0.17;
    energy=130;
    unlockCost=3000;
  } 
  @Override
    void action() {
    particles.add(new TempZoom(owner, 2000, 0.5, DEFAULT_ZOOMRATE, true));
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 50, 16, 500, owner.playerColor));
    // particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    for (int i=0; i<359; i+=40) {
      RCRocket s= new RCRocket(owner, int( owner.cx+cos(radians(owner.angle+i))*50), int(owner.cy+sin(radians(owner.angle+i))*50), size, owner.playerColor, 1700, owner.angle+i, i, cos(radians(owner.angle+i))*shootSpeed*.02+owner.vx, sin(radians(owner.angle+i))*shootSpeed*.02+owner.vy, damage, false, true);
      s.shakeness=2;
      projectiles.add( s);
    }
    owner.pushForce(5, owner.angle);
    // particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
  }
  void passive() {
    // noFill();
    // stroke(255);
    //strokeWeight(3);
    //triangle(int( owner.cx-45), int(owner.cy-110), int( owner.cx+45), int(owner.cy-110), int( owner.cx), int(owner.cy-30));
    if (cooldown<stampTime)owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
    else owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
  @Override
    void press() {
    //(!reverse || owner.reverseImmunity)
    if (cooldown<stampTime &&(!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      enableCooldown();
      activate();
      action();
      deactivate();
    }
  }
  @Override
    void reset() {
    super.reset();
    energy=90;
    release();

    deactivate();
    deChannel();
    regen=true;
  }
}

class RapidFire extends Ability {//---------------------------------------------------    RapidFire   ---------------------------------
  float accuracy = 1, MODIFIED_ANGLE_FACTOR=-0.0008, r=50, maxR=100;  
  int Interval=100;
  long  PastTime;
  int projectileDamage=5;

  RapidFire() {
    super();
    icon=icons[32];
    name=getClassName(this);
    deactiveCost=6;
    regenRate=0.15;
    critDamage=5;
    critChance=10;
    channelCost=0.13;
    unlockCost=1000;
  } 

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity) && energy>(0+activeCost) && !active && !channeling && !owner.dead) {
      activate();

      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=false;
    }
  }
  @Override
    void hold() {
    println(critChance+criticalChanceMod);
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead &&(stampTime-PastTime) >= Interval) {
      float InAccurateAngle=random(-accuracy, accuracy);
      projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage).addBuff(new Enlarge(owner, 3000, 4)).addBuff(new Burn(owner, 200, 1, 50)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
      particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 5, 22, 20, WHITE));
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      r=50;
      channel();
      if (!active || energy<0 ) {
        release();
      }
      PastTime=stampTime;
    } else if ((!freeze || owner.freezeImmunity) &&  active && !owner.dead &&(stampTime+freezeTime-PastTime) >= Interval) {
      float InAccurateAngle=random(-accuracy, accuracy);
      projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage).addBuff(new Enlarge(owner, 3000, 4)).addBuff(new Burn(owner, 200, 1, 50)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
      particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 5, 22, 20, WHITE));
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      r=50;
      channel();
      if (!active || energy<0 ) {
        release();
      }
      PastTime=freezeTime+stampTime;
    }
    // if (!active)press(); // cancel
    if (owner.hit) {
      release(); // cancel
    }
  }
  @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        regen=true;
        hold=false;
        deChannel();
        deactivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      }
    }
  }
  @Override
    void passive() {
    if (!owner.stealth) {
      stroke(owner.playerColor);
      strokeWeight(12);
      if (r<maxR)r*=1.1;
      line(owner.cx, owner.cy, owner.cx+cos(radians(owner.angle))*r, owner.cy+sin(radians(owner.angle))*r);
    }
  }
  void reset() {
    super.reset();
    PastTime=stampTime;

    // channeling=false;
    // active=false;
    // hold=false;
    // deactivate();
    // deChannel();
    // regen=true;
    //release();
  }
}

class SerpentFire extends Ability {//---------------------------------------------------    SerpentFire   ---------------------------------
  float interval, accuracy = 5, MODIFIED_ANGLE_FACTOR=-0.0008, r=50, shootSpeed=60 ;
  int  minInterval=80, recoil =5 ;
  boolean alt;
  long  PastTime;
  int damage;
  SerpentFire() {
    super();
    icon=icons[28];
    name=getClassName(this);
    deactiveCost=0;
    channelCost=5;
    damage=3;
    regenRate=0.3;
    unlockCost=3000;
  } 

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity) && energy>(0+activeCost) && !active && !channeling && !owner.dead) {
      activate();
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=false;
    }
  }
  @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead &&(stampTime-PastTime) >= interval) {
      float InAccurateAngle=random(-accuracy, accuracy);

      SinRocket sr= new SinRocket(owner, int( owner.cx), int(owner.cy), 25, owner.playerColor, 2000, owner.angle, cos(radians(owner.angle))*shootSpeed*.01+owner.vx, sin(radians(owner.angle))*shootSpeed*.01+owner.vy, int(damage*damageMod*.2), false);
      Containable[] payload=new Containable[1];
      payload[0]= ((Containable) new Blast(owner, 0, 0, 15, 60, owner.playerColor, 60, owner.angle, 1, 12, 15).addBuff(new Burn( owner, 1500+int(200*damageMod), 0.00001+(damageMod*0.0001), 550))).parent(sr);
      sr.blastRadius=120;
      sr.contains(payload);

      if (alt) { 
        sr.count=100;
        sr.angleSpeed=int(35+InAccurateAngle);
      } else {
        sr.count=280;
        sr.angleSpeed=int(35+InAccurateAngle);
      }
      alt=!alt;
      projectiles.add( sr);
      projectiles.add( new  Blast(owner, int(owner.cx+cos(radians(owner.angle))*95), int(owner.cy+sin(radians(owner.angle))*95), 0, 50, owner.playerColor, 100, owner.angle, 1));

      owner.pushForce(-recoil, owner.keyAngle);
      /* SinRocket sr= new SinRocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 2500, owner.angle, cos(radians(owner.angle))*shootSpeed*.01+owner.vx, sin(radians(owner.angle))*shootSpeed*.01+owner.vy, damage*2, false);
       sr.count=275;
       projectiles.add( sr);*/
      // projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
      particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 5, 22, 20, WHITE));
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      r=50;
      channel();
      interval+=30;
      if (!active || energy<0 ) {
        release();
      }
      PastTime=stampTime;
    } else if ((!freeze || owner.freezeImmunity) &&  active && !owner.dead &&(stampTime+freezeTime-PastTime) >= interval) {
      // float InAccurateAngle=random(-accuracy, accuracy);
      // projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
      particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 5, 22, 20, WHITE));
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
  @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active || channeling) {
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        regen=true;
        deChannel();
        r=50;
        deactivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      }
    }
  }
  @Override
    void passive() {
    if (interval>minInterval)interval-=2*timeBend;
    if (!owner.stealth) { 
      stroke(owner.playerColor);
      strokeWeight(12);
      if (r<100)r*=1.12;
      line(owner.cx, owner.cy, owner.cx+cos(radians(owner.angle))*r, owner.cy+sin(radians(owner.angle))*r);
    }
  }
  @Override
    void reset() {
    super.reset();
    r=50;
    interval=2;
    energy=90;
    deChannel();
    deactivate();
    active=false;
    regen=true;
    PastTime=stampTime;
  }
}

class MachineGun extends RapidFire {//---------------------------------------------------    MachineGun   ---------------------------------

  int alt, count, retractLength=40, projectileSpeed=55;
  float sutainCount, MAX_sutainCount=110, e, t;
  MachineGun() {
    super();
    icon=icons[5];
    name=getClassName(this);
    deactiveCost=5;
    channelCost=0.2;
    accuracy = 0;
    projectileDamage=7;
    critDamage=5;
    critChance=10;
    cooldownTimer=900;
    e=10;
    t=10;
    r=10;
    MODIFIED_ANGLE_FACTOR=0.001;
    unlockCost=4000;
  } 
  void press() {
    super.press();
  }
  void action() {

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
        projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w+cos(radians(owner.angle+90))*17), int(owner.cy+sin(radians(owner.angle))*owner.w+sin(radians(owner.angle+90))*17), 60, owner.playerColor, 600, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
        particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*100+cos(radians(owner.angle+90))*17), int(owner.cy+sin(radians(owner.angle))*100+sin(radians(owner.angle+90))*17), 0, 0, 50, 50, WHITE));
      } else if (alt%3==1) {
        r=retractLength;
        projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w+cos(radians(owner.angle-90))*17), int(owner.cy+sin(radians(owner.angle))*owner.w+sin(radians(owner.angle-90))*17), 60, owner.playerColor, 600, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
        particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*100+cos(radians(owner.angle-90))*17), int(owner.cy+sin(radians(owner.angle))*100+sin(radians(owner.angle-90))*17), 0, 0, 50, 50, WHITE));
      } else {  
        projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 600, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
        particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*100+cos(radians(owner.angle+0))*17), int(owner.cy+sin(radians(owner.angle))*100+sin(radians(owner.angle+0))*17), 0, 0, 50, 50, WHITE));
        t=retractLength;
      }
    } else if ((!freeze || owner.freezeImmunity) &&  active && !owner.dead &&(stampTime+freezeTime-PastTime) >= Interval) {
      float InAccurateAngle=random(-accuracy, accuracy);
      projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage));
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
  void hold() {
    owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
    if (cooldown<stampTime) {
      action();
      // if (!active)press(); // cancel
      if (owner.hit)        if (sutainCount>10)sutainCount-=10;
      //release(); // cancel

      sutainCount+=0.4*timeBend;
      if (sutainCount>MAX_sutainCount) {
        sutainCount=MAX_sutainCount;
        owner.pushForce(1, owner.angle+180);
      }
      accuracy=sutainCount*0.1;
      Interval=int((MAX_sutainCount+5-sutainCount)*5);
    }
  }

  void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        regen=true;
        deChannel();
        deactivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 0, 0, 100, 50, color(255, 0, 255)));

        owner.pushForce(8, owner.angle+180);

        for (int i=0; sutainCount/10>i; i++) {
          float InAccurateAngle=random(-accuracy*2, accuracy*2);
          projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 700, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage));
        }
        owner.angle+=random(-90, 90);
        sutainCount=0;
        enableCooldown();
      }
    }
  }

  @Override
    void passive() {
    if (!owner.stealth) { 
      int offset=17;
      stroke(owner.playerColor);
      strokeWeight(15);
      if (r<80)r*=1.1;
      if (e<80)e*=1.1;
      if (t<80)t*=1.1;
      line(owner.cx+cos(radians(owner.angle+90))*offset, owner.cy+sin(radians(owner.angle+90))*offset, owner.cx+cos(radians(owner.angle))*e+cos(radians(owner.angle+90))*offset, owner.cy+sin(radians(owner.angle))*e+sin(radians(owner.angle+90))*offset);
      line(owner.cx+cos(radians(owner.angle))*offset, owner.cy+sin(radians(owner.angle))*offset, owner.cx+cos(radians(owner.angle))*t+cos(radians(owner.angle))*offset, owner.cy+sin(radians(owner.angle))*t+sin(radians(owner.angle))*offset);
      line(owner.cx+cos(radians(owner.angle-90))*offset, owner.cy+sin(radians(owner.angle-90))*offset, owner.cx+cos(radians(owner.angle))*r+cos(radians(owner.angle-90))*offset, owner.cy+sin(radians(owner.angle))*r+sin(radians(owner.angle-90))*offset);
    }
  }
  @Override
    void reset() {
    super.reset();
    energy=90;
    deactivate();
    deChannel();
    regen=true;
  }
}

class Sniper extends RapidFire {//---------------------------------------------------    Sniper   ---------------------------------
  int  startAccuracy=100, nullRange=400;
  float aimRate=0.04, sutainCount, MAX_sutainCount=40, inAccurateAngle=startAccuracy, MODIFIED_ANGLE_FACTOR=0, MODIFIED_MAX_ACCEL=0.05; 
  Sniper() {
    super();
    icon=icons[13];
    name=getClassName(this);
    deactiveCost=6;
    activeCost=4;
    channelCost=0.1;
    cooldownTimer=700;
    projectileDamage=210;
    critDamage=210;
    critChance=40;
    unlockCost=6000;
    maxR=200;
  } 
  void press() {
    super.press();
  }
  void hold() {
    if (cooldown<stampTime) {

      if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead &&(stampTime-PastTime) >= Interval) {
        owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
        owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
        zoomAim=0.8;
        channel();
        if (!active || energy<0 ) {
          release();
        }
        PastTime=stampTime;
        //if (inAccurateAngle>0)inAccurateAngle *=0.96;
        if (inAccurateAngle>0)inAccurateAngle *=1-(aimRate*timeBend);
      } else if ((!freeze || owner.freezeImmunity) &&  active && !owner.dead &&(stampTime+freezeTime-PastTime) >= Interval) {
        owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
        owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
        channel();
        if (!active || energy<0 ) {
          release();
        }
        PastTime=freezeTime+stampTime;
        if (inAccurateAngle>0)inAccurateAngle *=1-(0.04*timeBend);
      }
      // if (!active)press(); // cancel
      if (owner.hit &&inAccurateAngle<startAccuracy)inAccurateAngle+=20; //release(); // cancel

      sutainCount+=0.4;
      if (sutainCount>MAX_sutainCount) {
        sutainCount=MAX_sutainCount;
        //owner.pushForce(1, owner.angle+180);
      }
      //if (inAccurateAngle>0)inAccurateAngle *=0.96;
      //accuracy=sutainCount;
      Interval=int((MAX_sutainCount-sutainCount)*5);
    }
  }
  void passive() {
    super.passive();
    if (!owner.stealth)   line(owner.cx+cos(radians(owner.angle+5))*r, owner.cy+sin(radians(owner.angle+5))*r, owner.cx+cos(radians(owner.angle-5))*r, owner.cy+sin(radians(owner.angle-5))*r);
    if (cooldown<stampTime && active) {
      if (inAccurateAngle<0.1)stroke(255);
      else stroke(owner.playerColor);
      //float xOffset=cos(radians(owner.angle))*nullRange;
      //float yOffset=sin(radians(owner.angle))*nullRange;

      strokeWeight(1);
      //   line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(inAccurateAngle*3.25+owner.angle))*2000), int(owner.cy+sin(radians(inAccurateAngle*3.25+owner.angle))*2000));
      //   line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(-inAccurateAngle*3.25+owner.angle))*2000), int(owner.cy+sin(radians(-inAccurateAngle*3.25+owner.angle))*2000));
      aimLine(nullRange, 2000, inAccurateAngle*3.25);
      aimLine(nullRange, 2000, -inAccurateAngle*3.25);
      noFill();
      //line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(inAccurateAngle*0.25+owner.angle))*500), int(owner.cy+sin(radians(inAccurateAngle*0.25+owner.angle))*500));
      // line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(-inAccurateAngle*0.25+owner.angle))*500), int(owner.cy+sin(radians(-inAccurateAngle*0.25+owner.angle))*500));

      aimLine(nullRange, 2000, inAccurateAngle*0.25);
      aimLine(nullRange, 2000, -inAccurateAngle*0.25);
      // line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(inAccurateAngle*0.5+owner.angle))*1000), int(owner.cy+sin(radians(inAccurateAngle*0.5+owner.angle))*1000));
      // line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(-inAccurateAngle*0.5+owner.angle))*1000), int(owner.cy+sin(radians(-inAccurateAngle*0.5+owner.angle))*1000));

      aimLine(nullRange, 2000, inAccurateAngle*0.5);
      aimLine(nullRange, 2000, -inAccurateAngle*0.5);
      strokeWeight(3);
      arc(owner.cx, owner.cy, nullRange*2, nullRange*2, radians(-inAccurateAngle+owner.angle), radians(inAccurateAngle+owner.angle));

      aimLine(nullRange, 2000, inAccurateAngle);
      aimLine(nullRange, 2000, -inAccurateAngle);
      //  line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(inAccurateAngle+owner.angle))*2000), int(owner.cy+sin(radians(inAccurateAngle+owner.angle))*2000));
      //line(owner.cx+xOffset, owner.cy+yOffset, int( owner.cx+cos(radians(-inAccurateAngle+owner.angle))*2000), int(owner.cy+sin(radians(-inAccurateAngle+owner.angle))*2000));
    }
  }

  void  aimLine(float begin, float end, float inAccurate) {
    line(owner.cx+cos(radians(inAccurate+owner.angle))*begin, owner.cy+sin(radians(inAccurate+owner.angle))*begin, int( owner.cx+cos(radians(inAccurate+owner.angle))*end), int(owner.cy+sin(radians(inAccurate+owner.angle))*end));
  }  

  void release() {
    if ((!reverse || owner.reverseImmunity ) ) {

      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        zoomAim=1;
        regen=true;
        deChannel();
        deactivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        r=100;
        float tempA=random(-inAccurateAngle, inAccurateAngle);
        particles.add(new Gradient(8000, int( owner.cx+cos(radians(tempA+owner.angle))*nullRange), int(owner.cy+sin(radians(tempA+owner.angle))*nullRange), 0, 0, 15, 0.05, owner.angle+tempA, WHITE));
        particles.add(new Gradient(4000, int( owner.cx+cos(radians(tempA+owner.angle))*nullRange), int(owner.cy+sin(radians(tempA+owner.angle))*nullRange), 0, 0, 30, .4, owner.angle+tempA, owner.playerColor));
        particles.add(new Gradient(2000, int( owner.cx+cos(radians(tempA+owner.angle))*nullRange), int(owner.cy+sin(radians(tempA+owner.angle))*nullRange), 0, 0, int(250-inAccurateAngle), 8, owner.angle+tempA, WHITE));
        projectiles.add( new SniperBullet(owner, int( owner.cx+cos(radians(tempA+owner.angle))*nullRange), int(owner.cy+sin(radians(tempA+owner.angle))*nullRange), 50, owner.playerColor, 10, owner.angle+tempA, int(projectileDamage-inAccurateAngle*2)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
        owner.angle=tempA;
        owner.pushForce(-12, owner.angle);
        shakeTimer+=15; 
        inAccurateAngle=startAccuracy-accuracyMod;
        if (inAccurateAngle<0)inAccurateAngle=0;
        enableCooldown();
      }
    }
  }

  void reset() {
    super.reset();
    zoomAim=1;

    inAccurateAngle=startAccuracy-accuracyMod;
    if (inAccurateAngle<0)inAccurateAngle=0;
    active=false;
    regen=true;
    deChannel();
    deactivate();
  }
}
class HanzoMain extends Sniper {//---------------------------------------------------    Sniper   ---------------------------------
  float count=90;
  HanzoMain() {
    super();

    icon=icons[41];
    name=getClassName(this);
    deactiveCost=6;
    activeCost=4;
    channelCost=0.2;
    regenRate=0.4;
    cooldownTimer=700;
    projectileDamage=100;
    critDamage=80;
    critChance=30;
    unlockCost=6000;
    maxR=200;
    nullRange=110;
    MODIFIED_ANGLE_FACTOR=0.02;
    startAccuracy=75;
    aimRate=0.02;
    MAX_sutainCount=10;
  } 
  void press() {
    super.press();
  }
  void hold() {
    if (cooldown<stampTime) {
      // channel();

      if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead &&(stampTime-PastTime) >= Interval) {
        owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
        owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
        zoomAim=0.9;
        channel();
        // channeling=true;
        if (!active || energy<0 ) {
          release();
        }
        PastTime=stampTime;
        //if (inAccurateAngle>0)inAccurateAngle *=0.96;
        if (inAccurateAngle>0)inAccurateAngle *=1-(aimRate*timeBend);
      } else if ((!freeze || owner.freezeImmunity) &&  active && !owner.dead &&(stampTime+freezeTime-PastTime) >= Interval) {
        owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
        owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
        channel();
        //channeling=true;
        if (!active || energy<0 ) {
          release();
        }
        PastTime=freezeTime+stampTime;
        if (inAccurateAngle>0)inAccurateAngle *=1-(aimRate*timeBend);
      }
      // if (!active)press(); // cancel
      if (owner.hit &&inAccurateAngle<startAccuracy)inAccurateAngle+=20; //release(); // cancel

      sutainCount+=0.15;
      if (sutainCount>MAX_sutainCount) {
        sutainCount=MAX_sutainCount;
      }

      count+=6;
      Interval=int((MAX_sutainCount-sutainCount)*5);
    }
  }
  void passive() {
    // super.passive();
    if (!owner.stealth)   line(owner.cx+cos(radians(owner.angle+5))*r, owner.cy+sin(radians(owner.angle+5))*r, owner.cx+cos(radians(owner.angle-5))*r, owner.cy+sin(radians(owner.angle-5))*r);
    if (cooldown<stampTime && active) {
      if (sutainCount>=MAX_sutainCount)stroke(WHITE);
      else stroke(owner.playerColor);
      strokeWeight(1);
      aimLine(nullRange, 2000, sin(radians(count))*inAccurateAngle);
    }
    noFill();
    strokeWeight(8);
    stroke(owner.playerColor);
    bezier(owner.cx+cos(radians(owner.angle))*50, owner.cy+sin(radians(owner.angle))*50, owner.cx+cos(radians(owner.angle))*nullRange, owner.cy+sin(radians(owner.angle))*nullRange, owner.cx+cos(radians(owner.angle-70))*80, owner.cy+sin(radians(owner.angle-70))*80, owner.cx+cos(radians(owner.angle-60*sutainCount*.08-60))*120, owner.cy+sin(radians(owner.angle-60*sutainCount*.08-60))*120);
    bezier(owner.cx+cos(radians(owner.angle))*50, owner.cy+sin(radians(owner.angle))*50, owner.cx+cos(radians(owner.angle))*nullRange, owner.cy+sin(radians(owner.angle))*nullRange, owner.cx+cos(radians(owner.angle+70))*80, owner.cy+sin(radians(owner.angle+70))*80, owner.cx+cos(radians(owner.angle+60*sutainCount*.08+60))*120, owner.cy+sin(radians(owner.angle+60*sutainCount*.08+60))*120);
    strokeWeight(3);
    stroke(WHITE);
    line(owner.cx+cos(radians(owner.angle+180))*150*sutainCount*.12+cos(radians(owner.angle))*50, owner.cy+sin(radians(owner.angle+180))*150*sutainCount*.12+sin(radians(owner.angle))*50, owner.cx+cos(radians(owner.angle-60*sutainCount*.08-60))*110, owner.cy+sin(radians(owner.angle-60*sutainCount*.08-60))*110);
    line(owner.cx+cos(radians(owner.angle+180))*150*sutainCount*.12+cos(radians(owner.angle))*50, owner.cy+sin(radians(owner.angle+180))*150*sutainCount*.12+sin(radians(owner.angle))*50, owner.cx+cos(radians(owner.angle+60*sutainCount*.08+60))*110, owner.cy+sin(radians(owner.angle+60*sutainCount*.08+60))*110);
  }


  void release() {
    if ((!reverse || owner.reverseImmunity ) ) {

      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        zoomAim=1;
        regen=true;
        deChannel();
        deactivate();

        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        if (sutainCount>=MAX_sutainCount) {
          particles.add( new Star(1800, int(owner.cx+cos(radians(owner.angle))*nullRange), int(owner.cy+sin(radians(owner.angle))*nullRange), 0, 0, 500, 0.7, WHITE) );
        }
        r=100;

        Spike arrow= new Spike(owner, int( owner.cx+cos(radians(owner.angle))*nullRange), int(owner.cy+sin(radians(owner.angle))*nullRange), 55, owner.playerColor, 800, owner.angle+sin(radians(count))*inAccurateAngle, cos(radians(owner.angle+sin(radians(count))*inAccurateAngle))*12*sutainCount, sin(radians(owner.angle+sin(radians(count))*inAccurateAngle))*12*sutainCount, int((projectileDamage-inAccurateAngle+damageMod*.2)*sutainCount*.1));
        arrow.size=90;
        arrow.addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod)));
        projectiles.add(arrow);       
        sutainCount=0;

        owner.pushForce(-12, owner.angle);
        shakeTimer+=15; 
        inAccurateAngle=startAccuracy-accuracyMod*.26;
        if (inAccurateAngle<0)inAccurateAngle=0;
        enableCooldown();
      }
    }
  }

  void reset() {
    super.reset();
    zoomAim=1;
    sutainCount=0;
    inAccurateAngle=startAccuracy-accuracyMod*.26;
    if (inAccurateAngle<0)inAccurateAngle=0;
    regen=true;
    deChannel();
    deactivate();
    //  enableCooldown();
    active=false;
  }
}

class Battery extends Ability {//---------------------------------------------------    Battery   ---------------------------------
  int  maxInterval=5, damage=7, count=0, maxCount=6;
  float  accuracy=10, interval, MODIFIED_ANGLE_FACTOR=0.02;

  Battery() {
    super();
    name=getClassName(this);
    activeCost=24;
    critDamage=7;
    critChance=50;
    regenRate=0.12;
    unlockCost=2000;
  } 

  @Override
    void action() {
    //projectiles.add(charge.get(count));
    float inAccuracy;
    inAccuracy =random(-accuracy, accuracy);
    inAccuracy-=accuracyMod;
    if (inAccuracy<0)inAccuracy=0;
    switch(count) {
    case 0:
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*20, sin(radians(owner.angle+inAccuracy))*20, int(damage+damageMod*.2)));        
      break;
    case 1:
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*25, sin(radians(owner.angle+inAccuracy))*25, int(damage+damageMod*.2)));        
      break;
    case 2:
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*30, sin(radians(owner.angle+inAccuracy))*30, int(damage+damageMod*.2)));        
      break;     
    case 3:
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*35, sin(radians(owner.angle+inAccuracy))*35, int(damage+damageMod*.2)));        
      break;
    case 4:
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*40, sin(radians(owner.angle+inAccuracy))*40, int(damage+damageMod*.2)));        
      break;
    case 5:
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*45, sin(radians(owner.angle+inAccuracy))*45, int(damage+damageMod*.2)));        
      break;
    default:

      for (int i=0; i<5; i++) {
        inAccuracy =random(-inAccuracy*2, inAccuracy*2);
        projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*40, sin(radians(owner.angle+inAccuracy))*40, int(damage+damageMod*.2)));
      }
      projectiles.add( new  Blast(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 5, 150, owner.playerColor, 75, owner.angle, damage));

      projectiles.add( new RevolverBullet(owner, int( owner.cx+cos(radians(owner.angle))*50), int(owner.cy+sin(radians(owner.angle))*50), 60, 25, owner.playerColor, 1000, owner.angle, int(damage+damageMod*.8)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
      shakeTimer+=6;
      owner.pushForce(10, owner.angle+180);
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 0, 0, 100, 50, color(255, 0, 255)));
      owner.angle+=random(-90, 90);
    }
    particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 5, 22+3*count, 20, WHITE));
    owner.pushForce(3, owner.angle+180);
  }

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      // action();
    }
  }

  @Override
    void passive() {
    if (active) {
      if (interval>maxInterval) { // interval
        if (count<=maxCount) {
          // projectiles.add(charge.get(count));
          action();
          count++;
          interval=0; //reset
        } else {
          deactivate();
          count=0;
        }
      }
      interval+=1*timeBend;
    }
  }
}

class RapidBattery extends Battery {//---------------------------------------------------    RapidBattery Ability   ---------------------------------
  int  maxInterval=1, damage=3, count=0, maxCount=18;
  float  accuracy=5, interval;

  RapidBattery() {
    super();
    name=getClassName(this);
    activeCost=25;
    regenRate=0.3;
    critDamage=5;
    critChance=5;
    unlockCost=2000;
    MODIFIED_ANGLE_FACTOR=0.005;
  } 

  @Override
    void action() {
    owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;

    //projectiles.add(charge.get(count));
    // float inAccuracy;
    // inAccuracy =random(-accuracy, accuracy);
    Buff b=  new Cold(owner, 3000, 0.95);
    b.type=BuffType.ONCE;
    RevolverBullet p=new RevolverBullet(owner, int( owner.cx+cos(radians(owner.angle))*60), int(owner.cy+sin(radians(owner.angle))*60), 40, 50, owner.playerColor, 1000, owner.angle, damage+damageMod*.05);
    p.addBuff(b).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod)));
    projectiles.add( p);
    owner.pushForce(-2, owner.angle);
    // owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 0, 0, 50, 150, color(255, 0, 255)));
    // owner.angle+=random(-90, 90);
    particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), int( random(300)), 10, 300, WHITE));
  }

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      // action();
    }
  }

  @Override
    void passive() {
    if (active) {
      if (interval>=maxInterval) { // interval
        if (count<=maxCount) {
          action();
          count++;
          interval=0; //reset
        } else {
          owner.ANGLE_FACTOR= owner.DEFAULT_ANGLE_FACTOR;
          deactivate();
          count=0;
        }
      }
      interval+=1*timeBend;
    }
  }
}
class AssaultBattery extends Ability {//---------------------------------------------------    Battery   ---------------------------------
  int  DEFAULT_MAX_INTERVAL=10, maxInterval=DEFAULT_MAX_INTERVAL, damage=18, count=0, maxCount=14, flip=1;
  float  inAccuracy=90, accuracy=inAccuracy, interval, MODIFIED_ANGLE_FACTOR=0.001, MODIFIED_MAX_ACCEL=0.05; 

  AssaultBattery() {
    super();
    icon=icons[20];
    name=getClassName(this);
    activeCost=45;
    regenRate=0.19;
    unlockCost=4750;
    critChance=10;
    critDamage=10;
    maxInterval=int(DEFAULT_MAX_INTERVAL-attackSpeedMod*0.1);
  } 

  @Override
    void action() {
    strokeWeight(1400);
    stroke(owner.playerColor);
    if (flip==1) {
      arc(owner.cx, owner.cy, 1800, 1800, radians(owner.angle-accuracy*1.0), radians(owner.angle));
    } else {
      arc(owner.cx, owner.cy, 1800, 1800, radians(owner.angle), radians(owner.angle+accuracy*1.0));
    }
    strokeWeight(1);
    flip*=-1;

    owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
    owner.MAX_ACCEL= MODIFIED_MAX_ACCEL;

    if (accuracy>0) {
      owner.angle+= flip*accuracy;
      accuracy*=0.82;
      accuracy--;
    }

    projectiles.add( new SniperBullet(owner, int( owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 50, owner.playerColor, 10, owner.angle, int(damage+damageMod*.4)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
    owner.pushForce(-.5, owner.angle);

    if (count>=maxCount) {
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      owner.MAX_ACCEL= owner.DEFAULT_MAX_ACCEL;
      inAccuracy-=accuracyMod;
      if (inAccuracy<0)inAccuracy=0;
      accuracy=inAccuracy;
      regen=true;
    }
    particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 5, 10+5*count, 20, WHITE));
    owner.pushForce(-2, owner.angle);
  }

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {

      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=false;
      owner.angle+= flip*accuracy*.75;
      activate();
      // action();
    }
    /*
    if ((!reverse || owner.reverseImmunity)&& energy<20 && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {
     projectiles.add( new SniperBullet(owner, int( owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 70, owner.playerColor, 20, owner.angle, int(damage*1.5)));
     stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
     regen=true;
     // owner.angle+= flip*accuracy*.75;
     // activate();
     // action();
     }*/
  }

  @Override
    void passive() {
    if (active) {
      if (interval>=maxInterval) { // interval
        if (count<=maxCount) {
          // projectiles.add(charge.get(count));
          action();
          count++;
          interval=0; //reset
        } else {
          deactivate();
          count=0;
        }
      }
      interval+=1*timeBend;
    }
  }
  @Override

    void reset() {
    super.reset();
    active=false;
    energy=120;
    regen=true;
    count=0;
    interval=0;
    inAccuracy-=accuracyMod;
    if (inAccuracy<0)inAccuracy=0;
    accuracy=inAccuracy;
    maxInterval=int(DEFAULT_MAX_INTERVAL-attackSpeedMod*0.1);
    owner.MAX_ACCEL= owner.DEFAULT_MAX_ACCEL;
    owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
  }
}

class SemiAuto extends Battery implements AmmoBased {//---------------------------------------------------    Battery   ---------------------------------
  int swayRate=4, reloadCost; 
  boolean reloading;

  SemiAuto() {
    super();
    icon=icons[14];
    name=getClassName(this);
    maxInterval=4; 
    damage=10;  
    critDamage=5;
    critChance=5;
    maxCount=3;
    MODIFIED_ANGLE_FACTOR=0.02;
    activeCost=2;
    reloadCost=75;
    maxAmmo=30;
    regenRate=0.18;
    unlockCost=6000;
  } 

  @Override
    void action() {
    stamps.add( new AbilityStamp(this));
    //projectiles.add(charge.get(count));


    inAccuracy =random(-accuracy, accuracy);
    inAccuracy-=accuracyMod;
    if (inAccuracy<0)inAccuracy=0;
    switch(count) {
    case 0:
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      projectiles.add(new Spike(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 55, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*70, sin(radians(owner.angle+inAccuracy))*70, int(damage+damageMod*.2)).addBuff(new AimLocked(owner, 5000)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));       
      particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*105), int(owner.cy+sin(radians(owner.angle))*105), 5, 22, 20, WHITE));
      accuracy+=swayRate;
      break;
    case 1:
      projectiles.add(new Spike(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 55, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*65, sin(radians(owner.angle+inAccuracy))*65, int(damage+damageMod*.2)).addBuff(new AimLocked(owner, 5000)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));       
      particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*105), int(owner.cy+sin(radians(owner.angle))*105), 5, 22, 20, WHITE));
      accuracy+=swayRate;
      break;
    case 2:
      projectiles.add(new Spike(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 55, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*60, sin(radians(owner.angle+inAccuracy))*60, int(damage+damageMod*.2)).addBuff(new AimLocked(owner, 5000)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));        
      particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*105), int(owner.cy+sin(radians(owner.angle))*105), 5, 22, 20, WHITE));
      accuracy+=swayRate;
      break;     
    default:
      accuracy+=swayRate;
      if (accuracy>75)accuracy=75;
      owner.pushForce(-8, owner.angle);
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      owner.angle+=inAccuracy;//random(-accuracy, accuracy);
      owner.keyAngle= owner.angle;
    }
    owner.pushForce(-4, owner.angle);
    owner.pushForce(3, owner.keyAngle);
    ammo--;
  }

  @Override
    void press() {
    if (ammo<=0 && reloadCost<=energy) {
      energy-=reloadCost;
      reloading=true;
      owner.pushForce(20, owner.keyAngle);
      particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 24, 200, owner.playerColor));
      particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    } else {
      reloading=false;
      if (ammo>0&& (!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        regen=true;
        activate();
        // action();
      } else {
        deactivate();
        count=0;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      }
    }
  }

  @Override
    void passive() {
    if (!owner.stealth) { 
      strokeWeight(2);
      stroke(owner.playerColor);
      noFill();
      for (int i=0; i< ammo; i++)line(owner.cx-20, owner.cy+50+i*6, owner.cx+20, owner.cy+50+i*6);
    }
    if (reloading) {
      if (ammo<maxAmmo)
        ammo++; 
      else { 
        reloading=false;        
        count=0;
      }
    }
    if (active) {
      if (interval>maxInterval) { // interval
        if (count<=maxCount) {

          // projectiles.add(charge.get(count));
          action();
          count++;
          interval=0; //reset
        } else {
          deactivate();
          count=0;
        }
      }
      interval+=1*timeBend;
    } else     if (accuracy>0)accuracy--;
  }

  void reset() {
    super.reset();
    active=false;
    reloading=false;
    regen=true;
  }
  void reload() {
  }
  void reloadCancel() {
  }
}
class MarbleLauncher extends Ability {//---------------------------------------------------    MarbleLauncher   ---------------------------------
  int maxInterval=3, count=0, damage=6, offset=50, accuracy=10, maxCount=14, shootSpeed=35, duration=4500;
  float  interval, MODIFIED_ANGLE_FACTOR=0.01;

  MarbleLauncher() {
    super();
    icon=icons[29];
    cooldownTimer=1200;
    name=getClassName(this);
    activeCost=35;
    critDamage=5;
    critChance=10;
    regenRate=0.12;
    unlockCost=5500;
  } 

  @Override
    void action() {
    Electron e=new Electron( owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*shootSpeed*.2+owner.vx, sin(radians(owner.angle))*shootSpeed*.2+owner.vy, int(damage+damageMod*.2), false );
    e.derail();
    e.orbitAngleSpeed=1;
    e.maxDistance=50;
    e.angle=owner.angle;
    e.addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod)));
    e.vx=cos(radians(owner.angle))*shootSpeed*1+owner.vx;
    e.vy=sin(radians(owner.angle))*shootSpeed*1+owner.vy;
    projectiles.add(e);

    switch(count) {
    case 0:
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      //projectiles.add( new RCRocket(owner, int( owner.cx), int(owner.cy), 20, owner.playerColor, 1000, owner.angle, 0, cos(radians(owner.angle))*shootSpeed*.2+owner.vx, sin(radians(owner.angle))*shootSpeed*.2+owner.vy, damage, false));
      //projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle+90))*50), int(owner.cy+sin(radians(owner.angle+90))*50), 30, owner.playerColor, duration, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, false));
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle+90))*50), int(owner.cy+sin(radians(owner.angle+90))*50), 0, 0, 50, 50, WHITE));

      break;

    default:
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 0, 0, 100, 50, color(255, 0, 255)));
    }
    owner.halt();
    owner.pushForce(5, owner.angle+180);

    if (maxCount-1==count) {
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      enableCooldown();
    }
    //owner.pushForce(6, owner.angle+180);
    owner.angle+=random(-accuracy, accuracy);
  }

  @Override
    void press() {

    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && cooldown<stampTime && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();

      // action();
    }
  }

  @Override
    void passive() {
    if (!owner.stealth) {
      pushMatrix();
      translate(owner.cx, owner.cy);
      noStroke();
      fill(owner.playerColor);
      rotate(radians(owner.angle));
      rectMode(CENTER);
      rect(80, 0, 70, 60);
      //  rect(-20, -owner.radius, 50, 75);
      rectMode(CORNER);
      popMatrix();
    }
    if (active) {
      if (interval>maxInterval) { // interval
        if (count<maxCount) {
          // projectiles.add(charge.get(count));
          action();
          count++;
          interval=0; //reset
        } else {
          deactivate();
          count=0;
        }
      }
      interval+=1*timeBend;
    }
  }

  @Override
    void  reset() {
    super.reset();
    active=false;
    regen=true;
    count=0;
    owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}
class MissleLauncher extends Ability {//---------------------------------------------------    MissleLauncher   ---------------------------------
  int  maxInterval=6, damage=10, offset=50, accuracy=10, count=0, maxCount=6, shootSpeed=44, duration=4500;
  float  MODIFIED_ANGLE_FACTOR=0.02, interval;

  MissleLauncher() {
    super();
    icon=icons[11];
    cooldownTimer=2200;
    name=getClassName(this);
    activeCost=35;
    regenRate=0.12;
    critDamage=5;
    critChance=40;
    unlockCost=3750;
  } 

  @Override
    void action() {

    switch(count) {
    case 0:
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle+90))*50), int(owner.cy+sin(radians(owner.angle+90))*50), 30, owner.playerColor, duration, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, int(damage+damageMod*.2), false).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle+90))*50), int(owner.cy+sin(radians(owner.angle+90))*50), 0, 0, 50, 50, WHITE));

      break;
    case 1:
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle-90))*50), int(owner.cy+sin(radians(owner.angle-90))*50), 30, owner.playerColor, duration, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, int(damage+damageMod*.2), false).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle-90))*50), int(owner.cy+sin(radians(owner.angle-90))*50), 0, 0, 50, 50, WHITE));
      break;
    case 2:
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle+95))*50), int(owner.cy+sin(radians(owner.angle+95))*50), 30, owner.playerColor, duration, owner.angle+10, cos(radians(owner.angle+10))*shootSpeed, sin(radians(owner.angle+10))*shootSpeed, int(damage+damageMod*.2), false).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle+90))*50), int(owner.cy+sin(radians(owner.angle+90))*50), 0, 0, 50, 50, WHITE));

      break;     
    case 3:
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle-95))*50), int(owner.cy+sin(radians(owner.angle-95))*50), 30, owner.playerColor, duration, owner.angle-10, cos(radians(owner.angle-10))*shootSpeed, sin(radians(owner.angle-10))*shootSpeed, int(damage+damageMod*.2), false).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle-90))*50), int(owner.cy+sin(radians(owner.angle-90))*50), 0, 0, 50, 50, WHITE));

      break;
    case 4:
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle+100))*50), int(owner.cy+sin(radians(owner.angle+100))*50), 30, owner.playerColor, duration, owner.angle+20, cos(radians(owner.angle+20))*shootSpeed, sin(radians(owner.angle+20))*shootSpeed, int(damage+damageMod*.2), false).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle-90))*50), int(owner.cy+sin(radians(owner.angle-90))*50), 0, 0, 50, 50, WHITE));

      break;
    case 5:
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle-100))*50), int(owner.cy+sin(radians(owner.angle-100))*50), 30, owner.playerColor, duration, owner.angle-20, cos(radians(owner.angle-20))*shootSpeed, sin(radians(owner.angle-20))*shootSpeed, int(damage+damageMod*.2), false).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle-90))*50), int(owner.cy+sin(radians(owner.angle-90))*50), 0, 0, 50, 50, WHITE));
      owner.pushForce(5, owner.angle+180);
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      enableCooldown();
      break;
    default:
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 0, 0, 100, 50, color(255, 0, 255)));
    }
    owner.halt();
    owner.pushForce(6, owner.angle+180);
  }

  @Override
    void press() {

    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && cooldown<stampTime && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();

      // action();
    }
  }

  @Override
    void passive() {
    if (!owner.stealth) {
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
    }
    if (active) {
      if (interval>maxInterval) { // interval
        if (count<maxCount) {
          // projectiles.add(charge.get(count));
          action();
          count++;
          interval=0; //reset
        } else {
          deactivate();
          count=0;
        }
      }
      interval+=1*timeBend;
    }
  }

  @Override
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

  float  MODIFIED_MAX_ACCEL=0.09, count;
  int damage=5, alternate, projectileSpeed=50;
  ArrayList<Player> targets= new ArrayList<Player>() ;
  int amountOfTargets;
  AutoGun() {
    super();
    icon=icons[30];
    name=getClassName(this);
    activeCost=12;
    channelCost=0.1;
    regenRate=0.18;
    unlockCost=3000;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity) &&(!freeze || owner.freezeImmunity)&& energy>(0+activeCost) && !active && !channeling && !owner.dead) {
      activate();
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=false;
    }
  }
  @Override
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

          if (!p.dead && owner !=p&& p.targetable && owner.ally!=p.ally) {

            if (amountP==alternate) {
              calcAngle(p);
              projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*60), int(owner.cy+sin(radians(owner.angle))*60), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*projectileSpeed, sin(radians(owner.angle))*projectileSpeed, int(damage+damageMod*.1)).addBuff(new CriticalHit(owner, 10, 20)));
              particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 5, 22, 20, WHITE));
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
  @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        regen=true;
        action();
        deChannel();
        deactivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
      }
    }
  }
  void calcAngle(Player target) {
    owner.angle = degrees(atan2((target.cy-owner.cy), (target.cx-owner.cx)));
    owner.keyAngle =owner.angle;
    strokeWeight(1);
    stroke(255);
    line(target.cx, target.cy, owner.cx, owner.cy);
    targetVarning( target);
  }
  void targetVarning(Player target) {
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
  @Override
    void  reset() {
    super.reset();
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class SeekGun extends Ability {//---------------------------------------------------    SeekGun   ---------------------------------

  float  MODIFIED_MAX_ACCEL=0.08, MODIFIED_ANGLE_FACTOR=0.05, count;
  int damage=30, range=1000, minRange=400, maxSpanAngle=80;
  float spanAngle=2, minAngle=10;
  ArrayList<Player> targets= new ArrayList<Player>() ;
  // int amountOfTargets;
  SeekGun() {
    super();
    icon=icons[23];
    name=getClassName(this);
    activeCost=40;
    channelCost=0.05;
    regenRate=0.4;
    critDamage=15;
    critChance=20;
    unlockCost=5500;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity) &&(!freeze || owner.freezeImmunity)&& energy>(0+activeCost) && !active && !channeling && !owner.dead) {
      activate();
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      regen=false;
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
    }
  }
  @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead &&(!freeze || owner.freezeImmunity)) {
      channel();
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      if (!active || energy<0 ) {
        release();
      }

      for (Player p : players) {
        if (p.targetable) {
          if (debug) {
            fill(p.playerColor);
            text(int(calcAngleBetween(p, owner)), p.cx+200, p.cy+200);
            if (owner.angle+spanAngle*.5>=0 && owner.angle+spanAngle*.5<=spanAngle) {
              particles.add(new Text(owner, String.valueOf(int(owner.angle+spanAngle*.5)), 0, -250, 60, 0, 20, owner.playerColor, 0));
            } else if (owner.angle-spanAngle*.5<=0 && owner.angle-spanAngle*.5>=-spanAngle) {
              particles.add(new Text(owner, String.valueOf(int(owner.angle-spanAngle*.5)), 0, -250, 60, 0, 20, color(150, 255, 255), 0));
            } else {
              particles.add(new Text(owner, String.valueOf(int(owner.angle+spanAngle*.5)), 0, -200, 50, 0, 20, BLACK, 0));
            }
          }

          if (!p.dead && p.ally!=owner.ally && (dist(owner.cx, owner.cy, p.cx, p.cy)<range+p.radius && dist(owner.cx, owner.cy, p.cx, p.cy)>minRange-p.radius
            && ((calcAngleBetween(p, owner)<= (owner.angle+spanAngle*.5+360)%360 &&calcAngleBetween(p, owner)>= (owner.angle-spanAngle*.5+360)%360) 
            ||(owner.angle+spanAngle*.5>=0 && owner.angle+spanAngle*.5<=spanAngle && owner.angle+spanAngle*.5>=calcAngleBetween(p, owner))
            || (owner.angle-spanAngle*.5<=0 && owner.angle-spanAngle*.5>=-spanAngle && owner.angle-spanAngle*.5<=calcAngleBetween(p, owner)-360)))) {
            //|| (owner.angle+spanAngle*.5>360 && calcAngleBetween(p, owner)<= (owner.angle+spanAngle*.5)%360)
            // || (owner.angle-spanAngle*.5<0 &&calcAngleBetween(p, owner)>= (owner.angle-spanAngle*.5)%360 ))) {
            //background(0,255,255,100);
            //if(owner.angle+spanAngle*.5>360 && calcAngleBetween(p, owner)<= (owner.angle+spanAngle*.5)%360)
            // if(owner.angle-spanAngle*.5<0 &&calcAngleBetween(p, owner)>= (owner.angle-spanAngle*.5)%360 )  background(100,255,255,100);


            if (!targets.contains(p)) {
              targets.add(p);
              particles.add( new TempZoom(p, 250, 1.1, DEFAULT_ZOOMRATE, true) );
              zoomRate=0.3;
              particles.add(new ShockWave(int(p.cx), int(p.cy), 140, 22, 300, WHITE));
            }
          }
        }
      }
      if (maxSpanAngle>spanAngle)spanAngle*=1.1;

      if (debug) {
        //  fill(owner.playerColor);
        //text(int(calcAngleBetween(p, owner)), owner.cx+ cos(radians(owner.angle))*400, owner.cy+sin(radians(owner.angle))*400);
        fill(BLACK);
        text(int((owner.angle+360)%360), owner.cx+ cos(radians(owner.angle))*300, owner.cy+sin(radians(owner.angle))*300);
        text(int((owner.angle+spanAngle*.5+360)%360), owner.cx+ cos(radians(owner.angle+spanAngle*.5))*300, owner.cy+ sin(radians(owner.angle+spanAngle*.5))*300);
        text(int((owner.angle-spanAngle*.5+360)%360), owner.cx+cos(radians(owner.angle-spanAngle*.5))*300, owner.cy+sin(radians(owner.angle-spanAngle*.5))*300);
      }
      drawRange();

      //particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 5, 22, 20, WHITE));
    }
  }
  void drawRange() {
    noFill();
    strokeWeight(range-minRange);
    stroke(owner.playerColor, 50);
    arc(owner.cx, owner.cy, range+minRange, range+minRange, radians(owner.angle-spanAngle*.5), radians(owner.angle+spanAngle*.5));
    strokeWeight(1);
    ellipse(owner.cx, owner.cy, range*2, range*2);
    ellipse(owner.cx, owner.cy, minRange*2, minRange*2);
  }
  @Override
    void passive() {
    //if (owner.angle<0){owner.angle+=360;owner.keyAngle+=360;}

    for (Player t : targets) {

      if (debug) {
        fill(owner.playerColor);
        text(calcAngleBetween(t, owner), t.cx+200, t.cy+200);
      }
      targetVarning(t);
      line(owner.cx, owner.cy, t.cx, t.cy);
      if (t.dead) {
        targets.remove(t); 
        break;
      }
    }
  }
  @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        particles.add( new TempZoom(halfWidth, halfHeight, 300, 0.9, DEFAULT_ZOOMRATE, true) );

        // zoomXAim=halfWidth;
        // zoomYAim=height*.5;
        // zoomRate=DEFAULT_ZOOMRATE;
        particles.add(new ShockWave(int(owner.cx), int(owner.cy), 150, 62, 400, WHITE));

        for (Player t : targets) {
          float tempAngle=calcAngleBetween(t, owner);
          HomingMissile p=new HomingMissile(owner, int( owner.cx+cos(radians(tempAngle))*50), int(owner.cy+sin(radians(tempAngle))*50), 60+30*targets.size(), owner.playerColor, 1400, owner.angle, cos(radians(owner.angle))*30, sin(radians(owner.angle))*30, int(damage+damageMod*.7+(15+damageMod*.5)*targets.size()));
          p.angle=tempAngle;
          p.locking();  
          p.addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod)));
          p.reactionTime=5*targets.size();
          projectiles.add(p);
        }
        if (targets.size()>0) {
          particles.add(new RShockWave(int(owner.cx), int(owner.cy), 400, 10, 850, WHITE));
          particles.add( new Star(1800, int(owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 0, 0, 500+200*targets.size(), 0.7, WHITE) );
        }
        owner.stop();
        targets.clear();
        spanAngle=minAngle;
        regen=true;
        action();
        deChannel();
        deactivate();
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
      }
    }
  }
  float  calcAngleBetween(Player target, Player from) {
    return (degrees(atan2((target.cy-from.cy), (target.cx-from.cx)))+360)%360;
  }
  void targetVarning(Player target) {
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
  @Override
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
class HitScanGun extends SeekGun {
  int alt;
  HitScanGun() {
    super();
    icon=icons[43];
    name=getClassName(this);
    activeCost=2;
    channelCost=0.05;
    regenRate=0.5;
    critDamage=5;
    critChance=20;
    unlockCost=5500;
    cooldownTimer=80;
    damage=8;
    range=2000;
    minRange=50; 
    maxSpanAngle=80;
    spanAngle=15;
    minAngle=10;
    MODIFIED_ANGLE_FACTOR=0.09;
  }
  @Override
    void press() {
    //drawRange();
  }
  @Override
    void hold() {

    if (cooldown<stampTime &&(!reverse || owner.reverseImmunity) &&(!freeze || owner.freezeImmunity)&& energy>(0+activeCost)  && !owner.dead) {
      activate();
      enableCooldown();
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;

      stamps.add( new AbilityStamp(this));

      for (Player p : players) {
        if (p.targetable) {
          if (!p.dead && p.ally!=owner.ally && (dist(owner.cx, owner.cy, p.cx, p.cy)<range+p.radius && dist(owner.cx, owner.cy, p.cx, p.cy)>minRange-p.radius
            && ((calcAngleBetween(p, owner)<= (owner.angle+spanAngle*.5+360)%360 &&calcAngleBetween(p, owner)>= (owner.angle-spanAngle*.5+360)%360) 
            ||(owner.angle+spanAngle*.5>=0 && owner.angle+spanAngle*.5<=spanAngle && owner.angle+spanAngle*.5>=calcAngleBetween(p, owner))
            || (owner.angle-spanAngle*.5<=0 && owner.angle-spanAngle*.5>=-spanAngle && owner.angle-spanAngle*.5<=calcAngleBetween(p, owner)-360)))) {
            //|| (owner.angle+spanAngle*.5>360 && calcAngleBetween(p, owner)<= (owner.angle+spanAngle*.5)%360)
            // || (owner.angle-spanAngle*.5<0 &&calcAngleBetween(p, owner)>= (owner.angle-spanAngle*.5)%360 ))) {
            //background(0,255,255,100);
            //if(owner.angle+spanAngle*.5>360 && calcAngleBetween(p, owner)<= (owner.angle+spanAngle*.5)%360)
            // if(owner.angle-spanAngle*.5<0 &&calcAngleBetween(p, owner)>= (owner.angle-spanAngle*.5)%360 )  background(100,255,255,100);

            if (!targets.contains(p)) {
              targets.add(p);
              //particles.add( new TempZoom(p, 250, 1.1, DEFAULT_ZOOMRATE, true) );
              // zoomRate=0.3;
              //particles.add(new ShockWave(int(p.cx), int(p.cy), 50, 82, 200, WHITE));
            }
          }
        }
      }

      try {
        for (Player t : targets) {
          if (!t.dead) {
            alt++;
            for (int i=0; i<4; i++) {
              // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
              particles.add(new Spark( 1000, int(t.cx), int(t.cy), cos(radians((i*90)+(alt%2==0?45:0)))*15, sin(radians((i*90)+(alt%2==0?45:0)))*15, 6, (i*90)+(alt%2==0?45:0), owner.playerColor));
              particles.add(new Spark( 1000, int(t.x+random(t.w)), int(t.y+random(t.w)), cos(radians(owner.angle))*random(10), sin(radians(owner.angle))*random(10), 6, owner.angle, owner.playerColor));
            }
            particles.add( new  Particle(int(t.cx), int(t.cy), cos(radians(owner.angle))*12, sin(radians(owner.angle))*12, 120, 100, color(255, 0, 255)));

            // targetVarning(t);
            t.hit(int(damage+damageMod*.1)+crit(owner.playerColor, t, critChance+criticalChanceMod, (critDamage+criticalDamageMod)));
            t.pushForce(3, calcAngleBetween( t, owner));
          }
        }
      }
      catch(Exception e) {
        println(e+"seekgun target");
      }
      targets.clear();
      particles.add(new LineWave(int(owner.cx+cos(radians(owner.angle))*owner.w*2.5), int(owner.cy+sin(radians(owner.angle))*owner.w*2.5), 60, 200, owner.playerColor, owner.angle));
      particles.add(new LineWave(int(owner.cx+cos(radians(owner.angle))*owner.w*2.2), int(owner.cy+sin(radians(owner.angle))*owner.w*2.2), 50, 300, WHITE, owner.angle));

      particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*115), int(owner.cy+sin(radians(owner.angle))*115), 30, 32, 100, owner.playerColor));
      particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*115), int(owner.cy+sin(radians(owner.angle))*115), 10, 22, 200, WHITE));

      owner.stop();
      owner.pushForce(-2, owner.angle);
    }
  }
  @Override

    void release() {
    regen=true;
  }

  @Override
    void passive() {

    strokeWeight(1);
    stroke(owner.playerColor);
    line(owner.cx, owner.cy, owner.cx+cos(radians(owner.angle+spanAngle)*range), owner.cy+sin(radians(owner.angle+spanAngle)*range));
    line(owner.cx, owner.cy, owner.cx+cos(radians(owner.angle-spanAngle)*range), owner.cy+sin(radians(owner.angle-spanAngle)*range));
  }
}


class ThrowBoomerang extends Ability {//---------------------------------------------------    Boomerang   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=64;
  float forceAmount=0, MODIFIED_MAX_ACCEL=0.04;
  float ChargeRate=1, restForce, recoveryEnergy, damage=3.1;
  int projectileSize=60;
  PShape boomerang;
  ThrowBoomerang() {
    super();
    icon=icons[18];
    name=getClassName(this);
    activeCost=15;
    channelCost=0.1;
    critChance=5;
    critDamage=2;
    recoveryEnergy=activeCost*0.9;
    unlockCost=1250;
  } 
  @Override
    void action() {
    projectiles.add( new Boomerang(owner, int( owner.cx), int(owner.cy), int(projectileSize+forceAmount*.5), owner.playerColor, int(300*forceAmount)+100, owner.angle, owner.vx+cos(radians(owner.angle))*(forceAmount+4), owner.vy+sin(radians(owner.angle))*(forceAmount+4), damage+damageMod*.08, recoveryEnergy, int(forceAmount*0.5+13)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity) && energy>(0+activeCost) && !active && !channeling && !owner.dead) {
      activate();
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=false;
    }
  }
  @Override
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
        particles.add(new Particle(int(owner.cx), int(owner.cy), random(-restForce*0.5, restForce*0.5), random(-restForce*0.5, restForce*0.5), int(random(30)+10), 300, owner.playerColor));
        particles.add(new ShockWave(int(owner.cx), int(owner.cy), int(forceAmount*.33), 16, int(forceAmount*.33), owner.playerColor));
      } else {
        //  particles.add(new ShockWave(int(owner.cx), int(owner.cy), int(forceAmount), 50, color(255, 0, 255)));
        particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(MAX_FORCE*2), 50, color(255, 0, 255)));
      }
    }
  }
  @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        // particles.add(new Fragment(int(owner.x), int(owner.y), 0, 0, 40, 10, 500, 100, owner.playerColor) );
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        regen=true;
        action();
        owner.pushForce(-forceAmount*0.5, owner.angle);
        deChannel();
        deactivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        forceAmount=0;
      }
    }
  }
  void passive() {
    // rect(owner.x,owner.y,50,50);
    if (active) {
      pushMatrix();
      translate(owner.cx-cos(radians(owner.angle))*forceAmount, owner.cy-sin(radians(owner.angle))*forceAmount);
      rotate(radians(owner.angle)+forceAmount);
      shape(boomerang, boomerang.width*.5, boomerang.height*.5, boomerang.width, boomerang.height);
      popMatrix();
    }
  }
  @Override
    void  reset() {
    super.reset();
    regen=true;
    forceAmount=0;
    deChannel();
    release();
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    setOwner(owner);
  }
  @Override
    void setOwner(Player owner) {
    super.setOwner( owner);
    boomerang=createShape();
    boomerang.beginShape();
    boomerang.strokeWeight(6);
    boomerang.stroke(owner.playerColor);
    boomerang.noFill();
    boomerang.vertex(int (projectileSize*0.6), int (-projectileSize*0.5) );
    boomerang.vertex(int (+projectileSize*1.2), int (0));
    boomerang.vertex(int (0), int (0));

    boomerang.vertex(int (-projectileSize), int (0));

    boomerang.vertex(int (0), int (0));
    boomerang.vertex(int (-projectileSize*1.2), int (0));
    boomerang.vertex(int (-projectileSize*0.6), int (+projectileSize*0.5) );




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
  int rows=1, duration=330, damage=24, customAngle, initialSpeed=5;
  long timer;
  ArrayList<HomingMissile> lockProjectiles= new ArrayList<HomingMissile>();
  float MODIFIED_ANGLE_FACTOR=0.018;
  float MODIFIED_MAX_ACCEL=0.04; 
  PhotonicWall() {
    super();
    icon=icons[19];
    name=getClassName(this);
    activeCost=10;
    regenRate=0.3;
    critDamage=15;
    critChance=20;
    channelCost=8;
    energy=40;
    unlockCost=4000;
  } 
  @Override
    void action() {
    if (rows>0) {
      particles.add(new Particle(int(owner.cx+cos(radians(owner.angle-90))*50), int(owner.cy+sin(radians(owner.angle-90))*50), random(10)-5+cos(radians(owner.angle-90))*10, random(10)-5+sin(radians(owner.angle-90))*10, int(random(20)+5), 800, 255));
      particles.add(new Particle(int(owner.cx+cos(radians(owner.angle+90))*50), int(owner.cy+sin(radians(owner.angle+90))*50), random(10)-5+cos(radians(owner.angle+90))*10, random(10)-5+sin(radians(owner.angle+90))*10, int(random(20)+5), 800, 255));
    }   
    for (int i=0; i<rows; i++) {
      lockProjectiles.add(new HomingMissile(owner, int( owner.cx+cos(radians(owner.angle+(90+i*10)))*(100+i*20)), int(owner.cy+sin(radians(owner.angle+(90+i*10)))*(100+i*20)), 70, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, int(damage+damageMod*.4)));
      lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
      lockProjectiles.get(lockProjectiles.size()-1).locking();
      lockProjectiles.get(lockProjectiles.size()-1).reactionTime=45-i*2;
      lockProjectiles.get(lockProjectiles.size()-1).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod)));
      projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));

      lockProjectiles.add(new HomingMissile(owner, int( owner.cx+cos(radians(owner.angle-(90+i*10)))*(100+i*20)), int(owner.cy+sin(radians(owner.angle-(90+i*10)))*(100+i*20)), 70, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, int(damage+damageMod*.4)));
      lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
      lockProjectiles.get(lockProjectiles.size()-1).locking();
      lockProjectiles.get(lockProjectiles.size()-1).reactionTime=45-i*2;
      lockProjectiles.get(lockProjectiles.size()-1).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod)));
      projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
    }
    /*
      lockProjectiles.add(new HomingMissile(owner, int( owner.cx+cos(radians(owner.angle+100))*150), int(owner.cy+sin(radians(owner.angle+100))*150), 60, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
     lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
     lockProjectiles.get(lockProjectiles.size()-1).locking();
     projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
     lockProjectiles.add(new HomingMissile(owner, int( owner.cx+cos(radians(owner.angle+90))*120), int(owner.cy+sin(radians(owner.angle+90))*120), 70, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
     lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
     lockProjectiles.get(lockProjectiles.size()-1).locking();
     lockProjectiles.get(lockProjectiles.size()-1).reactionTime=45;
     projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
     lockProjectiles.add(new HomingMissile(owner, int( owner.cx+cos(radians(owner.angle-90))*120), int(owner.cy+sin(radians(owner.angle-90))*120), 70, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
     lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
     lockProjectiles.get(lockProjectiles.size()-1).locking();
     lockProjectiles.get(lockProjectiles.size()-1).reactionTime=45;
     projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
     lockProjectiles.add(new HomingMissile(owner, int( owner.cx+cos(radians(owner.angle-100))*150), int(owner.cy+sin(radians(owner.angle-100))*150), 60, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
     lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
     lockProjectiles.get(lockProjectiles.size()-1).locking();
     projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));*/
    owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
    owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
    //owner.pushForce(-7, owner.angle);
    owner.pushForce(-rows*2, owner.angle);
  }
  void press() {
    hold=true;
  }
  /* @Override
   void press() {
   if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
   //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
   stamps.add( new AbilityStamp(this));
   regen=true;
   activate();
   action();
   deactivate();
   }
   }*/
  void hold() {
    if (!freeze || owner.freezeImmunity) {
      if (energy+channelCost>0&&timer+duration<stampTime) {
        rows++;
        timer=stampTime;
        //particles.add(new Particle(int(owner.cx+cos(radians(owner.angle-(90+rows*10)))*(50+rows*20)), int(owner.cy+cos(radians(owner.angle-90))*(50+rows*20)), random(10)-5+cos(radians(owner.angle-(90+rows*10)))*10, random(10)-5+sin(radians(owner.angle-(90+rows*10)))*(10+rows*20), int(random(20)+5), 800, 255));
        // particles.add(new Particle(int(owner.cx+cos(radians(owner.angle+(90+rows*10)))*(50+rows*20)), int(owner.cy+cos(radians(owner.angle+90))*(50+rows*20)), random(10)-5+cos(radians(owner.angle+(90+rows*10)))*10, random(10)-5+sin(radians(owner.angle+(90+rows*10)))*(10+rows*20), int(random(20)+5), 800, 255));
        // particles.add(new Particle(int(owner.cx+cos(radians(owner.angle-(90+rows*10)))*(50+rows*20)), int(owner.cy+cos(radians(owner.angle-90))*(50+rows*20)), 0, 0, int(random(20)+15), 1800, 255));
        // particles.add(new Particle(int(owner.cx+cos(radians(owner.angle+(90+rows*10)))*(50+rows*20)), int(owner.cy+cos(radians(owner.angle+90))*(50+rows*20)), 0, 0, int(random(20)+15), 1800, 255));
        energy-=channelCost;
      }
      if (energy<=0) {
        hold=false;
        regen=true;
        action();
        deactivate();
        rows=0;
      }
    }
  }
  @Override
    void release() {
    hold=false;

    if ((!reverse || owner.reverseImmunity) && energy>0+activeCost&& !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      deactivate();
      rows=1;
      timer=stampTime;
    }
  }
  @Override
    void passive() {
    if (hold) {
      hold();
      noFill();
      stroke(255);
      for (int i=0; i<rows; i++) {
        ellipse(owner.cx+cos(radians(owner.angle+(90+i*10)))*(100+i*20), owner.cy+sin(radians(owner.angle+(90+i*10)))*(100+i*20), 50, 50);
        ellipse(owner.cx+cos(radians(owner.angle-(90+i*10)))*(100+i*20), owner.cy+sin(radians(owner.angle-(90+i*10)))*(100+i*20), 50, 50);
      }
    }
    owner.MAX_ACCEL+= (owner.DEFAULT_MAX_ACCEL-owner.MAX_ACCEL)*.018;
    owner.ANGLE_FACTOR+= (owner.DEFAULT_ANGLE_FACTOR-owner.MAX_ACCEL)*.018;
  }
  @Override
    void reset() {
    super.reset();
    hold=false;
    rows=1;
    owner.MAX_ACCEL= owner.DEFAULT_MAX_ACCEL;
    owner.ANGLE_FACTOR= owner.DEFAULT_ANGLE_FACTOR;
  }
}
class PhotonicPursuit extends Ability {//---------------------------------------------------    PhotonicPursuit   ---------------------------------
  int damage=32, customAngle, initialSpeed=6, r;
  final int shellRadius =125;
  PhotonicPursuit() {
    super();
    icon=icons[59];
    name=getClassName(this);
    activeCost=15;
    energy=85;
    critDamage=8;
    critChance=50;
    r=200;
    unlockCost=1750;
  } 
  @Override
    void action() {

    if (energy>=maxEnergy-15) {

      for (Player p : players) {
        if (!p.dead && p.targetable) {
          customAngle=-90;
          particles.add( new Star(2000, int(owner.cx+cos(radians( owner.angle+90))*80), int( owner.cy+sin(radians( owner.angle+90))*80), 0, 0, 150, 0.9, WHITE) );
          particles.add( new Star(2000, int(owner.cx+cos(radians( owner.angle-90))*80), int( owner.cy+sin(radians( owner.angle-90))*80), 0, 0, 150, 0.9, WHITE) );

          HomingMissile h= new HomingMissile(owner, int( owner.cx), int(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, int(damage+damageMod*.5));
          h.target=p;
          projectiles.add(h.addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
          customAngle=90;

          h= new HomingMissile(owner, int( owner.cx), int(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, int(damage+damageMod*.5));
          h.target=p;
          projectiles.add(h.addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
          customAngle=0;
        }
      }
    }

    customAngle=-90;
    projectiles.add( new HomingMissile(owner, int( owner.cx), int(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, int(damage+damageMod*.4)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));

    customAngle=90;
    projectiles.add( new HomingMissile(owner, int( owner.cx), int(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, int(damage+damageMod*.4)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      deactivate();
      r+=50;
    }
  }
  void passive() {
    if (!owner.stealth) {  
      if ((!freeze || owner.freezeImmunity) && r>shellRadius)r*=0.95;
      stroke(owner.playerColor);
      strokeWeight(15);
      noFill();
      arc(owner.cx, owner.cy, r, r, radians(owner.angle+45), radians(owner.angle+45+90));
      arc(owner.cx, owner.cy, r, r, radians(owner.angle+225), radians(owner.angle+225+90));
    }
  }
}

class DeployThunder extends TimeBomb {//---------------------------------------------------    DeployThunder   ---------------------------------

  float MODIFIED_MAX_ACCEL=0.01, duration=300; 
  long startTime;
  DeployThunder() {
    super();
    icon=icons[12];
    damage=120;
    shootSpeed=0;
    regenRate=0.45;
    name=getClassName(this);
    activeCost=40;
    unlockCost=2000;
  } 
  @Override
    void action() {
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 10, 16, 1000, owner.playerColor));

    //    particles.add( new Shock(1000, int( owner.cx), int(owner.cy), owner.vx, owner.vy, 2, owner.angle, owner.playerColor)) ;
    // particles.add( new Shock(1000, int( owner.cx), int(owner.cy), owner.vx, owner.vy, 3, owner.angle, owner.playerColor)) ;
    // particles.add( new Shock(1000, int( owner.cx), int(owner.cy), owner.vx, owner.vy, 1, owner.angle, owner.playerColor)) ;

    startTime=stampTime;
    owner.MAX_ACCEL=owner.MAX_ACCEL*3;
    for (int i=0; i<7; i++) {
      particles.add(new Spark(700, int( owner.cx), int(owner.cy), random(-15, 15), random(-15, 15), 2, random(360), owner.playerColor));
    }

    if (energy>=maxEnergy-activeCost) {   
      particles.add( new Text("!", int( owner.cx), int(owner.cy), 0, 0, 180, 0, 4000, BLACK, 1));
      particles.add( new Text("!", int( owner.cx), int(owner.cy), 0, 0, 240, 0, 4000, owner.playerColor, 0));
      projectiles.add( new Thunder(owner, int( owner.cx), int(owner.cy), 500, owner.playerColor, 3000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, int((damage+damageMod)*1.2), 6, true).addBuff(new Stun(owner, 1500)));
    } else {
      particles.add( new Text("!", int( owner.cx), int(owner.cy), 0, 0, 140, 0, 2000, BLACK, 1));
      particles.add( new Text("!", int( owner.cx), int(owner.cy), 0, 0, 180, 0, 2000, owner.playerColor, 0));
      projectiles.add( new Thunder(owner, int( owner.cx), int(owner.cy), 400, owner.playerColor, 2000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, int(damage+damageMod), 5, true).addBuff(new Stun(owner, 1000)));
    }
  }

  void  passive() {
    //owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.6;
    if (stampTime>=duration+startTime) {
      owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    }
  }
  @Override
    void  reset() {
    super.reset();
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class DeployShield extends Ability {//---------------------------------------------------    DeployShield   ---------------------------------
  int damage=12, shell=80, pHealth;

  DeployShield() {
    super();
    icon=icons[35];
    name=getClassName(this);
    activeCost=35;
    cooldownTimer=2750;
    unlockCost=2000;
  } 
  @Override
    void action() {
    if (owner.health>=owner.maxHealth*.5) {
      /*for (int i=200; i<900; i+=75) {
       projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle))*i), int(owner.cy+sin(radians(owner.angle))*i), owner.playerColor, 10000, owner.angle, damage ));
       }*/
      particles.add(new ShockWave(int(owner.cx), int(owner.cy), 300, 16, 90, WHITE));

      for (int i=0; i<360; i+=30) {
        Container s = new Shield( owner, int( owner.cx+cos(radians(i))*195), int(owner.cy+sin(radians(i))*195), owner.playerColor, 2200, i+90, damage );
        Containable payload[]={   
          new IceDagger(owner, int( owner.cx), int(owner.cy), 25, owner.playerColor, 300, i-15, cos(radians(i-15))*50, sin(radians(i-15))*50, int(damage+damageMod*.5)).parent(s), 
          new IceDagger(owner, int( owner.cx), int(owner.cy), 25, owner.playerColor, 300, i, cos(radians(i))*50, sin(radians(i))*50, int(damage+damageMod*.5)).parent(s), 
          new IceDagger(owner, int( owner.cx), int(owner.cy), 25, owner.playerColor, 300, i+15, cos(radians(i+15))*50, sin(radians(i+15))*50, int(damage+damageMod*.5)).parent(s)

        };
        s.contains(payload);
        projectiles.add((Projectile)s);
      }
    } else {
      // particles.add(new Particle(int(owner.cx), int(owner.cy), 0, 0, 120, 500, WHITE));
      particles.add(new ShockWave(int(owner.cx), int(owner.cy), 100, 16, 80, owner.playerColor));
      particles.add(new LineWave(int( owner.cx+cos(radians(owner.angle))*200), int(owner.cy+sin(radians(owner.angle))*200), 10, 200, WHITE, owner.angle+90));

      projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle-25))*220), int(owner.cy+sin(radians(owner.angle-25))*220), owner.playerColor, 11000, owner.angle+90, damage ));
      projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle))*200), int(owner.cy+sin(radians(owner.angle))*200), owner.playerColor, 11100, owner.angle+90, damage ));
      projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle+25))*220), int(owner.cy+sin(radians(owner.angle+25))*220), owner.playerColor, 11000, owner.angle+90, damage ));
    }
    owner.stop();
  }
  @Override
    void press() {
    if (cooldown<stampTime &&(!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      enableCooldown();
      deactivate();
    }
  }

  @Override
    void passive() {

    if (owner.health>=owner.maxHealth*.5) {
      cooldownTimer=2850;
      activeCost=35;
      owner.armor=1;
      stroke(owner.playerColor);
      strokeWeight(5);
      fill(255, owner.health-owner.maxHealth*.5);
      quad(owner.cx+shell, owner.cy, owner.cx, owner.cy+shell, owner.cx-shell, owner.cy, owner.cx, owner.cy-shell);
    } else {
      if (pHealth>=owner.maxHealth*.5) {
        cooldownTimer=1000;
        activeCost=20;
        owner.armor=0;
        shatter();
      }
    }
    pHealth=owner.health;
  }

  void shatter() {
    owner.halt();
    for (int i=0; i<24; i++) {
      projectiles.add( new IceDagger(owner, int( owner.cx), int(owner.cy), 25, owner.playerColor, 500, i*36, cos(radians(i*36))*50, sin(radians(i*36))*50, damage));
    }
    projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 220, owner.playerColor, 1, owner.angle, owner.vx, owner.vy, damage, false));

    shakeTimer+=10;
    particles.add(new Flash(200, 10, WHITE));   // flash
  }
  void reset() {
    super.reset();
    owner.armor=0;
  }
}

class DeployElectron extends Ability {//---------------------------------------------------    DeployElectron   ---------------------------------
  int damage=32;

  ArrayList<Electron> stored =new ArrayList<Electron> ();
  DeployElectron() {
    super();
    icon=icons[25];
    name=getClassName(this);
    activeCost=12;
    unlockCost=1500;
  } 
  @Override
    void action() {
    if (energy>=maxEnergy-activeCost) {
      stored.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle, -5, -5, int(damage+damageMod*.3), true ));
      projectiles.add(stored.get(stored.size()-1));
      stored.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle+120, -5, -5, int(damage+damageMod*.3), true ));
      projectiles.add(stored.get(stored.size()-1));
      stored.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle+240, -5, -5, int(damage+damageMod*.3), true ));
      projectiles.add(stored.get(stored.size()-1));
    } else {
      stored.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle, -5, -5, int(damage+damageMod*.3), true));
      projectiles.add(stored.get(stored.size()-1));
      stored.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle+180, -5, -5, int(damage+damageMod*.3), true));
      projectiles.add(stored.get(stored.size()-1));
    }
  }
  @Override
    void press() {
    for (Electron e : stored) {
      if (e.distance>=e.maxDistance)e.derail();
    }
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      deactivate();
    }
  }
  @Override
    void passive() {
    strokeWeight(1);
    stroke(owner.playerColor);
    noFill();
    for (float i =0; i<=TAU; i+=PI/6) {
      arc(int( owner.cx), int(owner.cy), 400, 400, i, i+PI*.03);
    }
  }
  @Override
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
    icon=icons[24];
    name=getClassName(this);
    activeCost=25;
    regenRate=.15;
    cooldownTimer=1000;
    unlockCost=3000;
  } 
  @Override
    void action() {
    Graviton g;
    if (energy>=maxEnergy-activeCost) {
      g= new  Graviton(owner, int( owner.cx), int(owner.cy), 400, owner.playerColor, 12000, owner.angle, 9, 0, 0, int(damage+damageMod*.08)*3, 4);
    } else if (energy>=maxEnergy*.5) {
      g= new  Graviton(owner, int( owner.cx), int(owner.cy), 300, owner.playerColor, 10000, owner.angle, 8, 0, 0, int(damage+damageMod*.07)*2, 3);
    } else {
      g= new  Graviton(owner, int( owner.cx), int(owner.cy), 250, owner.playerColor, 8000, owner.angle, 7, 0, 0, int(damage+damageMod*.06), 2);
    }
    gravitonList.add(g);
    projectiles.add(g);
  }

  @Override
    void press() {
    if (cooldown<stampTime && (!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      enableCooldown();
      deactivate();
    }
  }
  @Override
    void reset() {
    super.reset();
    owner.armor=0;
    for (Graviton g : gravitonList) {
      g.deathTime=stampTime;
      g.dead=true;
    }
    gravitonList.clear();
  }
  void passive() {
    float c =((cooldown>stampTime)?int(cooldownTimer-(cooldown-stampTime)):cooldownTimer)*0.15;
    if (!freeze || owner.freezeImmunity) r+=(abs(owner.vx)+abs(owner.vy))+2;
    //stroke(owner.playerColor);
    strokeWeight(2);
    stroke(255);
    noFill();
    bezier(int( owner.cx), int(owner.cy), int( owner.cx), int(owner.cy), int(owner.cx)+cos(radians(r+50+180))*100, int(owner.cy)+sin(radians(r+50+180))*100, int(owner.cx)+cos(radians(r+180))*c, int(owner.cy)+sin(radians(r+180))*c);

    bezier(int( owner.cx), int(owner.cy), int( owner.cx), int(owner.cy), int(owner.cx)+cos(radians(r+50))*100, int(owner.cy)+sin(radians(r+50))*100, int(owner.cx)+cos(radians(r))*c, int(owner.cy)+sin(radians(r))*c);
  }
}

class Ram extends Ability {//---------------------------------------------------    Ram   ---------------------------------
  int boostSpeed=32;
  float sustainSpeed=1.5, damage=.3, speed;
  Ram() {
    super();
    icon=icons[26];
    name=getClassName(this);
    activeCost=10;
    channelCost=0.23;
    energy=50;
    regenRate=0.3;
    critDamage=10;
    critChance=0;
    cooldownTimer=1000;
    unlockCost=2000;
  } 
  @Override
    void action() {
    active=true;
    //owner.damage=damage;
    owner.pushForce(boostSpeed*0.5, owner.keyAngle);
    // particles.add(new ShockWave(int(owner.cx), int(owner.cy), 150, 22, 150, owner.playerColor));
  }
  void onHit() {
    //active=true;
    //owner.damage=damage;
    if (abs(owner.vx)+abs(owner.vy)> 20 && cooldown<stampTime) {
      enableCooldown();
      owner.pushForce(boostSpeed, owner.keyAngle);

      //projectiles.add(new Thunder(owner, int( owner.cx), int(owner.cy), 300, color(owner.playerColor), 0, 0, 0, 0, int(damage*10), 0, true) );
      particles.add(new ShockWave(int(owner.cx), int(owner.cy), 400, 22, 150, owner.playerColor));
    }
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
    }
  }
  void hold() {
    if (active) {
      channel();
      if (!active || energy<0 ) {
        release();
        deactivate();
        active=false;
      }
      channel();
      owner.pushForce(sustainSpeed, owner.keyAngle);
      particles.add(new Particle(int(owner.cx), int(owner.cy), random(-speed, speed), random(-speed, speed), int(random(20)+10), 150, owner.playerColor));
      particles.add(new RShockWave(int(owner.cx), int(owner.cy), 175, 14, 175, owner.playerColor));
    }
  }

  void passive() {
    speed = int(abs(owner.vx)+abs(owner.vy));
    owner.damage=int(speed*(damage+damageMod*.04)) + int(owner.hit ?int(crit(owner, critChance+criticalChanceMod+speed, (critDamage+criticalDamageMod))) : 0);
    if (!owner.stealth) {
      stroke(owner.playerColor);
      strokeWeight(3);
      noFill();
      pushMatrix();
      translate(owner.cx+cos(radians(owner.angle))*50, owner.cy+sin(radians(owner.angle))*50);
      rotate(radians(owner.angle-90));
      triangle(speed*.5*2, 0, 0, speed*4, -speed*.5*2, 0);
      popMatrix();
    }
  }

  void reset() {
    super.reset();
    energy=50;
    owner.damage=1;
  }
  void release() {
    owner.damage=1;
    deactivate();
  }
}
class DeployTurret extends Ability {//---------------------------------------------------    DeployTurret  ---------------------------------
  int damage=50, range=75, turretLevel=0;
  Turret currentTurret;
  ArrayList<Turret> turretList= new  ArrayList<Turret>();
  DeployTurret() {
    super();
    icon=icons[37];
    cooldownTimer=2000;
    name=getClassName(this);
    activeCost=25;
    energy=20;
    regenRate=0.15;
    unlockCost=7000;
  } 
  @Override
    void action() {

    switch(turretLevel) { 
      /*  case 0:
       currentTurret=new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 100, new Suicide());
       break;*/
    case 1:
      currentTurret=new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 50, new Battery());
      turretList.add(currentTurret);
      players.add(currentTurret);
      break;
    case 2:
      currentTurret=new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 100, new TimeBomb());
      turretList.add(currentTurret);
      players.add(currentTurret);
      break;
    case 3:
      currentTurret=new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 200, new Bazooka());
      turretList.add(currentTurret);
      players.add(currentTurret);
      break;
    case 4:
      currentTurret=new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 300, new Laser());
      turretList.add(currentTurret);
      players.add(currentTurret);
      break;
    }

    activeCost=25;
    energy=0;
    turretLevel=0;
  }
  @Override
    void activate() { 

    super.activate();
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //println("activeCost "+activeCost);
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();

      action();
      deactivate();
    }
  }
  void passive() {
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
    //arc(int(owner.cx), int(owner.cy),150,150, 0+turretLevel*TAU/4, TAU/4+turretLevel*TAU/4);
    // arc(int(owner.cx), int(owner.cy),150,150,radians(90),120);

    for (int i = 0; i < turretLevel; i++) {
      arc(int(owner.cx), int(owner.cy), 130, 130, -PI-i*PI*0.5+(PI*0.05), -PI*0.5-i*PI*0.5-(PI*0.05), 1);
    }
    // activeCost=energy-1;
  }
  @Override
    void reset() {
    super.reset();
    energy=20;

    players.remove(turretList);
  }
}
class DeployDrone extends Ability {//---------------------------------------------------    DeployDrone  ---------------------------------

  int speed=40;
  Drone currentDrone;
  ArrayList<Drone> droneList= new  ArrayList<Drone>();
  DeployDrone() {
    super();
    //icon=icons[39];
    icon=icons[44];
    cooldownTimer=2000;
    name=getClassName(this);
    activeCost=50;
    energy=25;
    regenRate=0.18;
    unlockCost=7500;
  } 
  @Override
    void action() {

    currentDrone=new Drone(players.size(), owner, int(owner.x+cos(radians(owner.angle))*100), int(owner.y+sin(radians(owner.angle))*100), int(playerSize*0.5), int(playerSize*0.5), 20, 200, new AutoGun(), new Random().randomize(passiveList) );
    currentDrone.vx=cos(radians(owner.angle))*speed;
    currentDrone.vy=sin(radians(owner.angle))*speed;
    currentDrone.stationary=false;
    droneList.add(currentDrone);
    players.add(currentDrone);
  }
  @Override
    void activate() { 

    super.activate();
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();

      action();
      deactivate();
    }
  }
  void passive() {
    strokeWeight(10);
    noFill();
    stroke(255);
  }
  @Override
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
    icon=icons[45];
    cooldownTimer=2000;
    name=getClassName(this);
    activeCost=80;
    energy=40;
    speed=10;
    regenRate=0.18;
    unlockCost=8000;
  } 
  @Override
    void action() {

    currentDrone=new FollowDrone(players.size(), owner, int(owner.x+cos(radians(owner.angle))*100), int(owner.y+sin(radians(owner.angle))*100), int(playerSize*0.5), int(playerSize*0.5), 20, 100, type, new Combo(), new Random().randomize(passiveList));
    currentDrone.vx=cos(radians(owner.angle))*speed;
    currentDrone.vy=sin(radians(owner.angle))*speed;
    currentDrone.stationary=false;

    droneList.add(currentDrone);
    players.add(currentDrone);
    currentDrone.abilityList.get(0).press();
  }
  @Override
    void activate() { 

    super.activate();
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      deactivate();
    }
  }
  void passive() {
    strokeWeight(10);
    noFill();
    stroke(255);
  }
  @Override
    void reset() {
    super.reset();
    players.remove(droneList);
  }
}

class CloudStrike extends Ability {//---------------------------------------------------    CloudStrike   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=30, ChargeRate=0.4, MODIFIED_MAX_ACCEL=0.005, MODIFIED_ANGLE_FACTOR=0.03;
  final int radius=220;
  float forceAmount=0, restForce;
  int damage=74, distanceX, distanceY;

  CloudStrike() {
    super();
    icon=icons[16];
    name=getClassName(this);
    activeCost=22;
    cooldownTimer=1400;
    channelCost=0;
    unlockCost=3750;
  } 
  @Override
    void action() {
    owner.stop();
    particles.add(new Flash(100, 6, WHITE)); 
    shakeTimer+=15;
    for (int i=45; i<360; i+= (360/4)) {
      particles.add( new Shock(170, distanceX, distanceY, 0, 0, 5, i, WHITE)) ;
    }
    particles.add(new ShockWave(distanceX, distanceY, 140, 90, 300, owner.playerColor));

    projectiles.add(new Thunder(owner, distanceX, distanceY, radius, color(owner.playerColor), 700, 0, 0, 0, int(damage+damageMod*.8), 4, true).addBuff(new Stun(owner, 1200)));
    enableCooldown();
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity) && energy>(0+activeCost)&& stampTime>cooldown  && !hold && !active && !channeling && !owner.dead) {
      activate();
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=false;
      if (energy>=maxEnergy-activeCost-20) {
        owner.pushForce(-12, owner.angle);
      }
    }
  }
  @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity)&& stampTime>cooldown&&  active && !owner.dead) {
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR-forceAmount*0.001;
      if (MAX_FORCE>forceAmount) { 
        channel();
        if (!active || energy<0 ) {
          release();
        }

        restForce = MAX_FORCE-forceAmount;
        forceAmount+=ChargeRate*timeBend; 
        distanceX=int(owner.cx+cos(radians(owner.angle))*50*forceAmount);
        distanceY=int(owner.cy+sin(radians(owner.angle))*50*forceAmount);

        if (energy>=maxEnergy-activeCost-20 && int((forceAmount*2+2)%8)==0) {
          if (forceAmount<5)forceAmount=5;
          projectiles.add(new Thunder(owner, distanceX, distanceY, int(radius*.5), color(owner.playerColor), 900, 0, 0, 0, int((damage+damageMod*.5)*.5), 1, false).addBuff(new Stun(owner, 1000)) );
        }

        crossVarning(distanceX, distanceY );
      } else {
        owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
        owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR-forceAmount*0.001;
        particles.add( new  Particle(distanceX, distanceY, 0, 0, int(MAX_FORCE*1.5), 30, color(255, 0, 255)));
      }
    }
    if (!active)press(); // cancel
    if (owner.hit)release(); // cancel
  }
  @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        //owner.pushForce(-forceAmount, owner.angle);
        regen=true;
        action();
        deChannel();
        deactivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        forceAmount=0;
      }
    }
  }
  void reset() {
    super.reset();
    deChannel();
    release();
    forceAmount=0;
  }
  @Override
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
    critChance=20;
    critDamage=15;
    unlockCost=3500;
  } 
  @Override
    void action() {
    bomb = new  DetonateBomb(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 60000, owner.angle, 0, 0, int(damage+damageMod*.7), true);
    projectiles.add(bomb.addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
  }

  @Override
    void press() {
    if ( bomb!= null && !bomb.dead && bomb.deathTime>stampTime) {
      bomb.deathTime=stampTime;
      owner.pushForce(25, degrees(atan2((owner.cy)-bomb.y, (owner.cx)-bomb.x)));
      //bomb.detonate();
      particles.add(new ShockWave(int(owner.cx), int(owner.cy), 50, 16, 50, owner.playerColor));
    } else if ((!reverse|| owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)   ) {
      // stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deactivate();
    }
  }
  void reset() {
    super.reset();
    projectiles.remove(bomb);
    bomb=null;
  }
}

class TeslaShock extends TimeBomb {//---------------------------------------------------    TimeBomb   ---------------------------------
  int range=500, maxRange=1600, duration=350;
  float MODIFIED_MAX_ACCEL=0.01; 
  long startTime;
  TeslaShock() {
    super();
    icon=icons[27];
    damage=1;
    shootSpeed=0;
    regenRate=0.4;
    name=getClassName(this);
    energy=20;
    activeCost=10;
    unlockCost=2250;
  } 
  @Override
    void action() {
    if (maxRange>range)range+=300;
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 10, 16, 1000, owner.playerColor));

    // particles.add( new Shock(1000, int( owner.cx), int(owner.cy), owner.vx, owner.vy, 2, owner.angle, owner.playerColor)) ;
    // particles.add( new Shock(1000, int( owner.cx), int(owner.cy), owner.vx, owner.vy, 3, owner.angle, owner.playerColor)) ;
    // particles.add( new Shock(1000, int( owner.cx), int(owner.cy), owner.vx, owner.vy, 1, owner.angle, owner.playerColor)) ;
    // for (int i=0; i<7; i++) {
    particles.add(new  Tesla( int(owner.cx), int(owner.cy), 200, 500, owner.playerColor));
    //}

    projectiles.add( new CurrentLine(owner, int( owner.cx), int(owner.cy), range, owner.playerColor, duration, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage).addBuff(new Paralysis(owner, 3000).apply(BuffType.ONCE)));

    /*  if (energy>=maxEnergy-activeCost) {   
     // particles.add( new Text("!", int( owner.cx), int(owner.cy), 0, 0, 180, 0, 4000, BLACK, 1));
     //   projectiles.add( new Thunder(owner, int( owner.cx), int(owner.cy), 400, owner.playerColor, 2000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, 5));
     }*/
  }

  void  passive() {
    if (!owner.stealth) {  
      /*  stroke(owner.playerColor);
       noFill();
       ellipse(owner.cx, owner.cy, range, range);*/
    }
    //owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.6;
    if (stampTime>=duration+startTime) {
      owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    }

    if (range>owner.w*3)range-=15;
  }
  @Override
    void  reset() {
    super.reset();
    energy=20;
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class RandoGun extends Ability {//---------------------------------------------------    RandoGun   ---------------------------------
  int damage =28, choosenProjectileIndex;
  int shootSpeed=35;
  final String description[]={"dagger", "tesla", "force", "shotgun", "revolver", "Homing missile", "electron", "laser", "bomb", "RC", "Boomerang", "Sniper", "thunder", "cluster", "mine", "missles", "rocket", "torpedo", "slice"};
  RandoGun() {
    super();
    name=getClassName(this);
    activeCost=18;
    regenRate=0.21;
    energy=maxEnergy*0.5;
    unlockCost=1000;
  } 
  @Override
    void action() {

    owner.pushForce(random(-50, 20), owner.angle+random(-90, 90));
    //projectiles.add( allProjectiles[(int)random(allProjectiles.length)]);
    switch(choosenProjectileIndex) {
    case 0:
      projectiles.add( new IceDagger(owner, int( owner.cx+cos(radians(owner.keyAngle))*75), int(owner.cy+sin(radians(owner.keyAngle))*75), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, int(damage*1.2)));
      break;
    case 1:
      // particles.add(new  Tesla( int(owner.cx), int(owner.cy), 200, 500, owner.playerColor));
      projectiles.add( new CurrentLine(owner, int( owner.cx), int(owner.cy), 400, owner.playerColor, 2000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, int(damage*0.15)));
      owner.pushForce(20, owner.angle);
      break;
    case 2:
      projectiles.add( new ForceBall(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, 25, owner.playerColor, 2000, owner.angle, damage));

      break;
    case 3:
      projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle+10))*owner.w), int(owner.cy+sin(radians(owner.angle+10))*owner.w), 60, owner.playerColor, 800, owner.angle+10, cos(radians(owner.angle+10))*36, sin(radians(owner.angle+10))*36, int(damage*0.8)));
      projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle-10))*owner.w), int(owner.cy+sin(radians(owner.angle-10))*owner.w), 60, owner.playerColor, 800, owner.angle-10, cos(radians(owner.angle-10))*36, sin(radians(owner.angle-10))*36, int(damage*0.8)));
      projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*36, sin(radians(owner.angle))*36, int(damage*0.8)));

      break;
    case 4:
      // projectiles.add( new  Graviton(owner, int( owner.cx), int(owner.cy), 250, owner.playerColor, 8000, owner.angle, int( owner.vx), int( owner.vy), damage, 2));
      projectiles.add( new SinRocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 2500, owner.angle-55, cos(radians(owner.angle+15))*shootSpeed*.01+owner.vx, sin(radians(owner.angle+15))*shootSpeed*.01+owner.vy, damage, false));

      break;
    case 5:
      projectiles.add(new HomingMissile(owner, int( owner.cx), int(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle-200))*shootSpeed, sin(radians(owner.angle-200))*shootSpeed, damage));
      projectiles.add(new HomingMissile(owner, int( owner.cx), int(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle-160))*shootSpeed, sin(radians(owner.angle-160))*shootSpeed, damage));

      break;
    case 6:
      projectiles.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle, -5, -5, damage, true));
      projectiles.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle+180, -5, -5, damage, true ));

      break;
    case 7:
      projectiles.add( new ChargeLaser(owner, int( owner.cx+random(50, -50)), int(owner.cy+random(50, -50)), 100, owner.playerColor, 500, owner.angle, 0, damage*0.08, true));
      owner.halt();
      break;
    case 8:
      projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, int(random(500, 2000)), owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage*2, true));

      break;
    case 9:
      projectiles.add( new RCRocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 2500, owner.angle, random(-10, 10), cos(radians(owner.angle))*shootSpeed*.02+owner.vx, sin(radians(owner.angle))*shootSpeed*.02+owner.vy, damage, false, true));

      break;
    case 10:
      projectiles.add( new Boomerang(owner, int( owner.cx), int(owner.cy), 80, owner.playerColor, int(300*50)+100, owner.angle, cos(radians(owner.angle))*(70+2), sin(radians(owner.angle))*(70+2), int(damage*0.07), 50, int(50*0.5+12)));
      break;

    case 11:
      projectiles.add( new SniperBullet(owner, int( owner.cx+cos(radians(owner.angle))*400), int(owner.cy+sin(radians(owner.angle))*400), 50, owner.playerColor, 10, owner.angle, int(damage*2)));

      break;
    case 12:
      projectiles.add( new Thunder(owner, int( owner.cx+cos(radians(owner.angle))*400), int(owner.cy+sin(radians(owner.angle))*400), 400, owner.playerColor, 1500, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, 5, true));
      break;
    case 13:
      Rocket r= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 1000, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
      Containable payload[]={
        new Bomb(owner, 0, 0, 25, owner.playerColor, 1000, 0, cos(radians(0))*14, sin(radians(0))*14, damage, false).parent(r), 
        new Bomb(owner, 0, 0, 25, owner.playerColor, 1000, 120, cos(radians(120))*14, sin(radians(120))*14, damage, false).parent(r), 
        new Bomb(owner, 0, 0, 25, owner.playerColor, 1000, 245, cos(radians(240))*14, sin(radians(245))*14, damage, false).parent(r), 
      };
      r.contains(payload);
      projectiles.add((Projectile)r);

      break;
    case 14:
      projectiles.add( new Mine(owner, int( owner.cx), int(owner.cy), 100, owner.playerColor, 50000, owner.angle, cos(radians(owner.angle))*shootSpeed*0.1, sin(radians(owner.angle))*shootSpeed*0.1, damage, true));
      break;
    case 15:
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle+90))*50), int(owner.cy+sin(radians(owner.angle+90))*50), 30, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle-90))*shootSpeed, sin(radians(owner.angle-90))*shootSpeed, damage, false));
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle+90))*50), int(owner.cy+sin(radians(owner.angle+90))*50), 30, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+90))*shootSpeed, sin(radians(owner.angle+90))*shootSpeed, damage, false));
      break;
    case 16:
      projectiles.add( new RevolverBullet(owner, int( owner.cx+cos(radians(owner.angle))*shootSpeed*1.5), int(owner.cy+sin(radians(owner.angle))*shootSpeed*1.5), 60, 25, owner.playerColor, 1000, owner.angle, damage));

      break;
    case 17:
      RCRocket RC= new RCRocket(owner, int( owner.cx), int(owner.cy), 100, owner.playerColor, 2000, owner.angle, 0, cos(radians(owner.angle))*0, sin(radians(owner.angle))*0, damage, true, false);
      RC.blastRadius=200;
      RC.acceleration=2.0;
      projectiles.add(RC);
      break;
    case 18:
      projectiles.add(new Slice(owner, int(owner.cx-cos(radians(owner.angle))*350), int(owner.cy-sin(radians(owner.angle))*350), 350, owner.playerColor, 180, owner.angle+145, 6, 130, cos(radians(owner.angle))*2, sin(radians(owner.angle))*2, int(10), false));

      break;
    }
    if (energy<maxEnergy)choosenProjectileIndex= (int)random(19);
  }
  @Override
    void passive() {

    if (energy>=maxEnergy) {
      fill(owner.playerColor);
      textSize(28);
      text( description[choosenProjectileIndex], int( owner.cx), int(owner.cy)+100);
    }
  }

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      deactivate();
    }
  }
  @Override
    void reset() {
    super.reset();
    energy=90;
    deactivate();
    deChannel();
    regen=true;
  }
}
class FlameThrower extends Ability {//---------------------------------------------------    FlameThrower   ---------------------------------

  int alt, count;
  float sutainCount, MAX_sutainCount=50, accuracy, MODIFIED_ANGLE_FACTOR=0.7, MODIFIED_MAX_ACCEL=0.1, projectileDamage;
  FlameThrower() {
    super();
    icon=icons[55];

    name=getClassName(this);
    deactiveCost=0;
    activeCost=0;
    channelCost=0.23;
    accuracy = 20;
    projectileDamage=0.05;
    cooldownTimer=900;
    MODIFIED_ANGLE_FACTOR=0.035;
    unlockCost=2750;
  } 
  void press() {
    super.press();
    if (!active) {
      active=true;
      projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 0, 150, owner.playerColor, 200, owner.angle, projectileDamage));
    }
  }
  void action() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead ) {
      float InAccurateAngle=random(-accuracy, accuracy);

      if (!active || energy<=0 ) {
        release();
        //if(sutainCount>10)sutainCount-=10;
      }
      channel();
      if (sutainCount%2<0.5) {
        projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 1+sutainCount, 45, owner.playerColor, 170, owner.angle+InAccurateAngle, int(projectileDamage+sutainCount*.01)).addBuff(new Burn( owner, 2000, 0.00005, int(random(500, 2000)))));
        particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 0, 0, 150, 50, color(255, 0, 255)));
      }
    }
  }
  void hold() {

    if (cooldown<stampTime) {
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      action();
      // if (!active)press(); // cancel
      if (owner.hit)  if (sutainCount>10)sutainCount-=10;  //release(); // cancel

      sutainCount+=0.3;
      if (sutainCount>MAX_sutainCount) {
        sutainCount=MAX_sutainCount;
        owner.pushForce(0.5, owner.angle+180);
      }
      accuracy=sutainCount*0.1;
    }
  }

  void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active) {
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        regen=true;
        deChannel();
        deactivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        sutainCount=0;
        enableCooldown();
      }
    }
  }

  @Override
    void passive() {
  }
  @Override
    void reset() {
    super.reset();
    energy=90;
    deactivate();
    deChannel();
    regen=true;
  }
}
class SummonEvil extends Ability {//---------------------------------------------------    SummonEvil   ---------------------------------
  int range=400, maxRange=1600, duration=350;
  float MODIFIED_MAX_ACCEL=0.01, damage=1; 
  long startTime;
  ArrayList<Player> enemies = new  ArrayList<Player>();

  SummonEvil() {
    super();
    regenRate=0.22;
    name=getClassName(this);
    activeCost=60;
    energy=80;
    unlockCost=6500;
  } 

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      activate();
      action();
      active=true;
    }
  }

  @Override
    void action() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead ) {
      //  particles.add(new  Tesla( int(owner.cx), int(owner.cy), 200, 500, owner.playerColor));
      //players.add(new Turret(players.size(), int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 200, new AutoGun(), new Random().randomize(passiveList) ));
      players.add(new FollowDrone(players.size(), int(owner.cx+cos(radians(owner.angle))*range), int(owner.cy+sin(radians(owner.angle))*range), int(playerSize*0.5), int(playerSize*0.5), 20, 300, 2, new Random().randomize(abilityList), new Random().randomize(passiveList) ));
      particles.add(new RShockWave( int(owner.cx+cos(radians(owner.angle))*range), int(owner.cy+sin(radians(owner.angle))*range), 300, 500, 500, BLACK));

      //println("hello");
      regen=true;
    }
  }

  void  passive() {
    //stroke(owner.playerColor);
    if (!owner.stealth) {
      stroke(BLACK);
      strokeWeight(6);
      noFill();
      arc(owner.cx, owner.cy, range*2, range*2, radians(owner.angle)-QUARTER_PI, radians(owner.angle)+QUARTER_PI);
      ellipse(int(owner.cx+cos(radians(owner.angle))*range), int(owner.cy+sin(radians(owner.angle))*range), 150, 150);
    }
    if (stampTime>=duration+startTime) {
      owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    }
  }
  @Override
    void  reset() {
    super.reset();
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    energy=90;
    deactivate();
    deChannel();
    regen=true;
  }
}

class SummonIlluminati extends Ability {//---------------------------------------------------    SummonIlluminati   ---------------------------------
  int range=400, healthCost, maxRange=1600, duration=350;
  float MODIFIED_MAX_ACCEL=0.01, damage=1; 
  long startTime;
  ArrayList<Player> enemies = new  ArrayList<Player>();

  SummonIlluminati() {
    super();
    icon=icons[34];
    regenRate=0.22;
    name=getClassName(this);
    activeCost=60;
    energy=100;
    unlockCost=10000;
  } 

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      activate();
      action();
      active=true;
    }
  }

  @Override
    void action() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead ) {
      owner.hit(int(owner.health*.1));
      projectiles.add(new AbilityPack(AI, new Random(true).randomize(passiveList), int( owner.cx+cos(radians(owner.angle))*owner.w*2), int(owner.cy+sin(radians(owner.angle))*owner.w*2), 100, AI.playerColor, 30000, 0, 0, 0, true, true));

      //  particles.add(new  Tesla( int(owner.cx), int(owner.cy), 200, 500, owner.playerColor));
      players.add(new Illuminati(players.size(), AI, int(owner.cx+cos(radians(owner.angle))*range), int(owner.cy+sin(radians(owner.angle))*range), 175, 175, 999, new Stealth())) ;
      //players.add(new Turret(players.size(), int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 200, new AutoGun(), new Random().randomize(passiveList) ));
      //players.add(new Illuminati(players.size(),AI, int(owner.cx+cos(radians(owner.angle))*range), int(owner.cy+sin(radians(owner.angle))*range), int(playerSize*0.5), int(playerSize*0.5), 20, 300, 2, new Random().randomize(), new Random().randomize(passiveList) ));
      particles.add(new RShockWave( int(owner.cx+cos(radians(owner.angle))*range), int(owner.cy+sin(radians(owner.angle))*range), 300, 500, 500, BLACK));
      //println("hello");
      regen=true;
    }
  }

  void  passive() {
    //stroke(owner.playerColor);
    if (!owner.stealth) {
      stroke(BLACK);
      strokeWeight(6);
      noFill();
      arc(owner.cx, owner.cy, range*2, range*2, radians(owner.angle)-QUARTER_PI, radians(owner.angle)+QUARTER_PI);
      ellipse(int(owner.cx+cos(radians(owner.angle))*range), int(owner.cy+sin(radians(owner.angle))*range), 150, 150);
    }
    if (stampTime>=duration+startTime) {
      owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    }
  }
  @Override
    void  reset() {
    super.reset();
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    energy=90;
    deactivate();
    deChannel();
    regen=true;
  }
}

class SneakBall extends Ability {//---------------------------------------------------    SneakBall  ---------------------------------

  int shootSpeed=65;
  int damage=18;
  ArrayList<HomingMissile> missileList= new   ArrayList<HomingMissile> ();
  float MODIFIED_ANGLE_FACTOR = 0.04;   
  long timer;
  SneakBall() {
    super();
    cooldownTimer=100;
    name=getClassName(this);
    activeCost=30;
    energy=25;
    critDamage=10;
    critChance=10;
    regenRate=0.25;
    unlockCost=4500;
  } 
  @Override
    void action() {
    owner.pushForce(-8, owner.angle);
    timer=millis();
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 10, 16, 1000, owner.playerColor));

    /*
      Container ball= new Rocket(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 400, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
     Containable [] payload=new Containable[1];
     payload[0]= new HomingMissile(owner, 0, 0, 50, owner.playerColor, 4000, owner.angle, cos(radians(owner.angle))*shootSpeed*.1, sin(radians(owner.angle))*shootSpeed*.1, damage).parent(ball); 
     ((HomingMissile)payload[0]).reactionTime=20;
     ball.contains(payload);
     projectiles.add((Projectile)ball);*/

    Container ball= new Bomb(owner, int( owner.cx), int(owner.cy), 200, owner.playerColor, 400, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
    Containable[] payload=new Containable[9];

    for (int i=0; i<8; i++) {
      payload[i]= new HomingMissile(owner, int( cos(radians(i*45))*100), int(sin(radians(i*45))*100), 65, owner.playerColor, 4000, owner.angle, cos(radians(owner.angle))*shootSpeed*.1, sin(radians(owner.angle))*shootSpeed*.1, int(damage+damageMod*.4)).parent(ball); 
      ((HomingMissile)payload[i]).locking();
      ((HomingMissile)payload[i]).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod)));
      missileList.add((HomingMissile)payload[i]);
    }
    payload[8] =new Bomb(owner, 0, 0, 40, owner.playerColor, 1, owner.angle, 0, 0, int(damage+damageMod*.2), false).parent(ball);

    ball.contains(payload);
    projectiles.add((Projectile)ball);
  }
  @Override
    void activate() { 
    super.activate();
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      deactivate();
    }
  }
  void passive() {

    for (HomingMissile m : missileList) 
      if (!m.leap) m.angle=owner.angle;
    if (timer+1200<millis())  owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    else owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
    strokeWeight(10);
    noFill();
    stroke(255);
  }
  @Override
    void reset() {
    super.reset();
    deChannel();
    owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    // projectiles.remove(missileList);
    missileList.clear();
    release();
  }
}

class TripleShot extends Ability {//---------------------------------------------------    TripleShot  ---------------------------------

  int shootSpeed=65, minSpead=5, maxSpread=50;
  int damage=20, duration=600;
  float MODIFIED_ANGLE_FACTOR = 0.04, shrinkRate=0.5, spread=16, spreadAngle=20;   
  long timer;
  TripleShot() {
    super();
    inAccuracy=50;
    icon=icons[21];
    cooldownTimer=100;
    name=getClassName(this);
    activeCost=10;
    energy=45;
    critDamage=10;
    critChance=10;
    regenRate=0.22;
    unlockCost=2000;
  } 
  @Override
    void action() {

    particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 30, 42, 55, WHITE));
    owner.pushForce(-18, owner.angle);
    timer=millis();
    projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle+spreadAngle))*owner.w), int(owner.cy+sin(radians(owner.angle+spreadAngle))*owner.w), 60, owner.playerColor, 1000, owner.angle+spreadAngle, cos(radians(owner.angle+spreadAngle))*32, sin(radians(owner.angle+spreadAngle))*36, int((damage+damageMod*.3)*0.8)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
    projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle-spreadAngle))*owner.w), int(owner.cy+sin(radians(owner.angle-spreadAngle))*owner.w), 60, owner.playerColor, 1000, owner.angle-spreadAngle, cos(radians(owner.angle-spreadAngle))*32, sin(radians(owner.angle-spreadAngle))*36, int((damage+damageMod*.3)*0.8)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
    projectiles.add( new Spike(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 1000, owner.angle, cos(radians(owner.angle))*38, sin(radians(owner.angle))*38, int(damage+damageMod*.4)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
    spreadAngle+=spread;
    if (spreadAngle>maxSpread)spreadAngle=maxSpread;
    particles.add(new ShockWave(int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 25, 20, 400, owner.playerColor));
    //  projectiles.add( new Slug(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*36, sin(radians(owner.angle))*36, int(damage*0.8)));
  }
  @Override
    void activate() { 
    super.activate();
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=true;
      activate();
      action();
      deactivate();
    }
  }
  void passive() {
    if (spreadAngle>minSpead)spreadAngle-=shrinkRate;
    //  for (HomingMissile m : missileList) 
    // if (!m.leap) m.angle=owner.angle;
    if (timer+duration<millis())  owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    else owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
    strokeWeight(10);
    noFill();
    stroke(255);
  }
  @Override
    void reset() {
    super.reset();
    deChannel();
    owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    release();
  }
}
class PoisonDart extends Ability {//---------------------------------------------------    PoisonDart   ---------------------------------
  final int damage=0, angleRecoil=45, projectileSize=60;
  float accuracy=1, MODIFIED_ANGLE_FACTOR=0.2;
  PoisonDart() {
    super();
    icon=icons[42];
    name=getClassName(this);
    activeCost=40;
    cooldownTimer=250;
    regenRate=0.6;
    critDamage=15;
    critChance=15;
    unlockCost=1750;
  } 
  @Override
    void action() {
    stamps.add( new AbilityStamp(this));
    particles.add(new LineWave(int(owner.cx+cos(radians(owner.angle))*owner.w*2), int(owner.cy+sin(radians(owner.angle))*owner.w*2), 20, 300, owner.playerColor, owner.angle));
    // particles.add(new LineWave(int(owner.cx), int(owner.cy), 10, 100, WHITE, owner.angle));
    for (int i=0; i<4; i++) {
      particles.add(  new  Particle(int(owner.cx), int(owner.cy), cos(radians(owner.angle+random(-10, 10)))*15+owner.vx, sin(radians(owner.angle+random(-10, 10)))*15+owner.vy, int(random(40)+10), 500, BLACK));
    }
    projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*66, sin(radians(owner.angle))*66, int(damage+damageMod*.1)).addBuff(new Poison(owner, 20000+int(200*damageMod), 0.005*(damageMod*.05))).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))));
    owner.pushForce(-5, owner.angle);
    owner.angle+=random(-angleRecoil, angleRecoil);
    owner.keyAngle=owner.angle;
  }

  @Override
    void press() {
    // particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
    if (  cooldown<stampTime && activeCost<=energy  &&(!reverse || owner.reverseImmunity)&&  !owner.dead && (!freeze || owner.freezeImmunity)) {
      activate();      
      stamps.add( new AbilityStamp(this));
      action();
      deactivate();
      enableCooldown();
      regen=true;
    }
  }

  @Override
    void passive() {
    if (!owner.stealth) {
    }
    owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
  }
}
class Artilery extends Ability {//---------------------------------------------------    Artilery Ability  ---------------------------------

  int shootSpeed=40;
  int damage=20, duration=200, tDuration, alt=1;
  float r=10, r2=10, maxR=150, MODIFIED_ANGLE_FACTOR = 0.008, spreadAngle=15;   
  long timer, tTimer;
  boolean transformed, first=true;
  Artilery() {
    super();
    icon=icons[36];
    cooldownTimer=100;
    name=getClassName(this);
    activeCost=5;
    energy=45;
    regenRate=0.5;
    critDamage=10;
    critChance=10;
    channelCost=0.3;
    unlockCost=3600;
  } 
  @Override
    void action() {
    if ( owner.stationary) owner.pushForce(-3, owner.angle);
    timer=millis();
    shake(8);
    alt*=-1;
    if (alt==1) r=40;
    else r2=40;
    if (first) {
      for (int i=0; i<360; i+=20) {
        particles.add(  new  Particle(int(owner.cx), int(owner.cy), cos(radians(i))*7, sin(radians(i))*7, int(random(50)+10), 500, WHITE));
      }
      first=false;
      shakeTimer+=14;
    }
    particles.add(new ShockWave(int(owner.cx-cos(radians(owner.angle+15*alt))*75), int(owner.cy-sin(radians(owner.angle+15*alt))*75), 30, 42, 55, WHITE));
    ForceBall f=(ForceBall) new ForceBall(owner, int( owner.cx+cos(radians(owner.angle+15*alt))*owner.w), int(owner.cy+sin(radians(owner.angle+15*alt))*owner.w), shootSpeed, 35, owner.playerColor, 1200, owner.angle, int(damage+damageMod*.8)).addBuff(new CriticalHit(owner, critChance+criticalChanceMod, (critDamage+criticalDamageMod))).addBuff(new ArmorPiercing(owner, 3000, 12));
    f.shakeness=10;
    projectiles.add( f);
    particles.add(new ShockWave(int( owner.cx+cos(radians(owner.angle+15*alt))*owner.w), int(owner.cy+sin(radians(owner.angle+15*alt))*owner.w), 35, 30, 100, owner.playerColor));
    //  projectiles.add( new Slug(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*36, sin(radians(owner.angle))*36, int(damage*0.8)));
  }
  @Override
    void activate() { 
    super.activate();
    transformed=!transformed;
    owner.stationary=transformed;
  }
  @Override
    void channel() {
    super.channel();
    if (timer+duration/timeBend<millis()&&(r>maxR || r2>maxR)) action();
    if (energy<=channelCost) {
      deChannel();
      transformed=false; 
      owner.stationary=transformed;
      regen=true;
      deactivate();
    } else regen=false;
  }
  void press() {
    if ((!reverse || owner.reverseImmunity)&& !channeling && energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      activate();
      particles.add(new ShockWave(int( owner.cx), int(owner.cy), 125, 60, 300, owner.playerColor));

      //action();
    } else {
      deChannel();
      transformed=false; 
      owner.stationary=transformed;
      regen=true;
      deactivate();
    }
  }
  void deactivate() {
    super.deactivate();
    first=true;
    particles.add(new RShockWave(int(owner.cx), int(owner.cy), 370, 18, 300, owner.playerColor));
  }
  void passive() {
    if (transformed) {
      owner.stop();
      channel();
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      if (r<maxR)r*=1.11*timeBend;
      if (r2<maxR)r2*=1.11*timeBend;
    } else {
      if (r>10)r*=0.95*timeBend;
      if (r2>10)r2*=0.95*timeBend;
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    }
    //  for (HomingMissile m : missileList) 
    // if (!m.leap) m.angle=owner.angle;

    strokeWeight(24);
    noFill();
    stroke(owner.playerColor);
    line(owner.cx+cos(radians(owner.angle+45*-1))*30, owner.cy+sin(radians(owner.angle+45*-1))*30, owner.cx+cos(radians(owner.angle+10*-1))*r2, owner.cy+sin(radians(owner.angle+10*-1))*r2);
    line(owner.cx+cos(radians(owner.angle+45*1))*30, owner.cy+sin(radians(owner.angle+45*1))*30, owner.cx+cos(radians(owner.angle+10*1))*r, owner.cy+sin(radians(owner.angle+10*1))*r);
  }
  @Override
    void reset() {
    super.reset();
    first=true;
    r=40;
    r2=40;
    deChannel();
    transformed=false;
    owner.stationary=false;
    owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    release();
  }
}
class LaserSword extends Ability {//---------------------------------------------------    LaserSword Ability ---------------------------------

  int shootSpeed=40, recoil=5;
  int  duration=200, swordLength=200;
  float MODIFIED_ANGLE_FACTOR = 0.008, spreadAngle=15, damage=1;   
  long timer, tTimer;
  boolean transformed;
  ChargeLaser l;
  LaserSword() {
    super();
    icon=icons[36];
    cooldownTimer=100;
    name=getClassName(this);
    activeCost=20;
    energy=65;
    regenRate=0.9;
    channelCost=0.5;
    unlockCost=3600;
  } 

  @Override
    void activate() { 
    super.activate();
    transformed=!transformed;
    if (l!=null) l.laserLength=int(swordLength*.5);
    l = new ChargeLaser(owner, int( owner.cx), int(owner.cy), 80, owner.playerColor, 20000, owner.angle, 0, damage, false);
    l.laserLength=swordLength;
    projectiles.add(l);
  }
  @Override
    void channel() {
    super.channel();
    if (energy<=channelCost) {
      deChannel();
      transformed=false; 
      regen=true;
      l.laserLength=int(swordLength*.5);
      l.angleV=-(owner.angle-owner.keyAngle);
      l=null;
      deactivate();
    } else {
      l.x = owner.cx+cos(radians(owner.angle))*100;
      l.y = owner.cy+sin(radians(owner.angle))*100;
      l.angle=owner.angle*3;
      regen=false;
    }
  }
  void press() {
    if ((!reverse || owner.reverseImmunity)&& !channeling && energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      activate();
      particles.add(new ShockWave(int( owner.cx), int(owner.cy), 125, 60, 300, owner.playerColor));

      //action();
    } else {
      deChannel();
      transformed=false; 
      owner.stationary=transformed;
      regen=true;
      if (l!=null) { 
        l.laserLength=int(swordLength*1);
        l.damage=abs(owner.angle-owner.keyAngle)*.25;
        l.angleV=-(owner.angle-owner.keyAngle);
        l.vx=cos(radians(owner.angle))*abs(owner.angle-owner.keyAngle)+owner.vx;
        l.vy=sin(radians(owner.angle))*abs(owner.angle-owner.keyAngle)+owner.vy;
        l.follow=false;
        owner.pushForce(-recoil-abs(owner.angle-owner.keyAngle), owner.angle);
      }
      l=null;
      deactivate();
    }
  }
  void passive() {
    if (transformed) {
      l.damage=abs(owner.angle-owner.keyAngle)*.15+damage*(damageMod*.1)+((abs(owner.vx)+abs(owner.vy))*.25);
      l.laserLength=int(abs(owner.angle-owner.keyAngle)*3)+swordLength;
      l.laserWidth=int(abs(owner.angle-owner.keyAngle)*20);
      channel();
    }
  }
  @Override
    void reset() {
    super.reset();
    deChannel();
    transformed=false;
    release();
  }
}
class StunGun extends Ability {//---------------------------------------------------    StunGun   ---------------------------------
  final int damage=22, recoil=6, angleRecoil=30, projectileSize=20;
  float accuracy=1, MODIFIED_ANGLE_FACTOR=0.2;
  StunGun() {
    super();
    name=getClassName(this);
    activeCost=50;
    cooldownTimer=150;
    regenRate=0.8;
    unlockCost=2750;
  } 
  @Override
    void action() {
    stamps.add( new AbilityStamp(this));
    //particles.add(new LineWave(int(owner.cx+cos(radians(owner.angle))*owner.w*2), int(owner.cy+sin(radians(owner.angle))*owner.w*2), 20, 300, owner.playerColor, owner.angle));
    // particles.add(new LineWave(int(owner.cx), int(owner.cy), 10, 100, WHITE, owner.angle));
    /* for (int i=0; i<4; i++) {
     particles.add(  new  Particle(int(owner.cx), int(owner.cy), cos(radians(owner.angle+random(-10, 10)))*15+owner.vx, sin(radians(owner.angle+random(-10, 10)))*15+owner.vy, int(random(40)+10), 500, BLACK));
     }*/
    Missle m= new Missle(owner, int( owner.cx), int(owner.cy), projectileSize, owner.playerColor, 1100+int(random(400)), owner.angle, cos(radians(owner.angle))*80, sin(radians(owner.angle))*80, int(damage+damageMod*.6), true);
    m.addBuff(new Paralysis(owner, 9000));
    m.addBuff(new Confusion(owner, 1000));

    m.angleSpeed=45; // speed
    m.turnRate=0.03+random(0.02);
    m.seekRange=2000;
    projectiles.add( m);

    //projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*66, sin(radians(owner.angle))*66, damage).addBuff(new Poison(owner, 20000)) );
    owner.pushForce(-recoil, owner.angle);
    owner.angle+=random(-angleRecoil, angleRecoil);
    owner.keyAngle=owner.angle;
  }

  @Override
    void press() {
    // particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
    if (  cooldown<stampTime && activeCost<=energy  &&(!reverse || owner.reverseImmunity)&&  !owner.dead && (!freeze || owner.freezeImmunity)) {
      activate();      
      stamps.add( new AbilityStamp(this));
      action();
      deactivate();
      enableCooldown();
      regen=true;
    }
  }

  @Override
    void passive() {
    if (!owner.stealth) {
    }
    owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
  }
}

class Chivalry extends Ability {
  float damage=8, forceAmount=0, MODIFIED_MAX_ACCEL=0.034, MODIFIED_ANGLE_FACTOR=0.03, damageFactor=1;
  ArrayList<Projectile> shields;
  int shieldRange=175;
  boolean maxed;
  Chivalry() {
    super();
    icon=icons[58];
    name=getClassName(this);
    regenRate=0.35;
    activeCost=15;
    cooldownTimer=1000;
    channelCost=0.15;
    unlockCost=3000;
    shields=new ArrayList<Projectile>();
  }  
  @Override
    void action() {

    //particles.add(new Gradient(int(forceAmount*11), int(owner.cx), int(owner.cy), 0, 0, 4, 100, owner.angle, owner.playerColor));
    //particles.add(new Gradient(1500, int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, int(forceAmount*11), int(forceAmount*11),4, owner.angle, owner.playerColor));
    // particles.add(new  Gradient(  1000, int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, int(forceAmount*11), int(owner.radius*2), 8, owner.angle, owner.playerColor));
    // projectiles.add(new Slash(owner, int(owner.cx), int(owner.cy), 150, WHITE, int(3.3*forceAmount), owner.angle, 50, 1.5*forceAmount+50, cos(radians(owner.angle))*forceAmount*.5, sin(radians(owner.angle))*forceAmount*.5, int(forceAmount*damageFactor), true));
    // projectiles.add(new Slash(owner, int(owner.cx), int(owner.cy), 150, WHITE, 280, owner.angle, -20, 70, cos(radians(owner.angle))*forceAmount, sin(radians(owner.angle))*forceAmount, int(forceAmount*damageFactor), false));
    owner.x+=cos(radians(owner.keyAngle))*forceAmount*8;
    owner.y+=sin(radians(owner.keyAngle))*forceAmount*8;
    projectiles.add(new Slice(owner, int(owner.cx-cos(radians(owner.angle))*340), int(owner.cy-sin(radians(owner.angle))*340), 200, owner.playerColor, 140, owner.angle+145, 7, 130, cos(radians(owner.angle))*forceAmount*.5, sin(radians(owner.angle))*forceAmount*.5, int(damage*damageFactor+damageMod*0.3), true));

    //  projectiles.add( new ForceBall(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), forceAmount*2+4, 35, owner.playerColor, 2000, owner.angle, forceAmount*damageFactor));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity) && energy>(0+activeCost)&& !hold && !active && !channeling && !owner.dead) {
      owner.pushForce(-18, owner.keyAngle);
      //projectiles.add(new Slice(owner, int(owner.cx-cos(radians(owner.angle))*250), int(owner.cy-sin(radians(owner.angle))*250), 350, owner.playerColor, 180, owner.angle+145, 6, 130, cos(radians(owner.angle))*forceAmount*.5, sin(radians(owner.angle))*forceAmount*.5, int(30*damageFactor), false));
      activate();
      forceAmount=5;
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=false;
    }
  }
  @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity) &&  active && !owner.dead) {
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      channel();
      if (!active || energy<0 ) {
        release();
      }
      if (shields.size()<3) {
        if (!freeze ) {
          shields.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle+30))*shieldRange), int(owner.cy+sin(radians(owner.angle+30))*shieldRange), owner.playerColor, 10000, owner.angle-90+30, damage, int(cos(radians(owner.angle+30))*125), int(sin(radians(owner.angle+30))*125)));
          shields.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle))*shieldRange), int(owner.cy+sin(radians(owner.angle))*shieldRange), owner.playerColor, 10000, owner.angle-90, damage, int(cos(radians(owner.angle))*125), int(sin(radians(owner.angle))*125)));
          shields.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle-30))*shieldRange), int(owner.cy+sin(radians(owner.angle-30))*shieldRange), owner.playerColor, 10000, owner.angle-90-30, damage, int(cos(radians(owner.angle-30))*125), int(sin(radians(owner.angle-30))*125)));
        } else {
          shields.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle+30))*shieldRange), int(owner.cy+sin(radians(owner.angle+30))*shieldRange), owner.playerColor, 10000, owner.angle-90+30, damage));
          shields.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle))*shieldRange), int(owner.cy+sin(radians(owner.angle))*shieldRange), owner.playerColor, 10000, owner.angle-90, damage));
          shields.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle-30))*shieldRange), int(owner.cy+sin(radians(owner.angle-30))*shieldRange), owner.playerColor, 10000, owner.angle-90-30, damage));
        }
        projectiles.addAll(shields);
      }
      particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))), int(owner.cy+sin(radians(owner.angle))), int(forceAmount*.5), 16, int(forceAmount*.5), owner.playerColor));
      if (cooldown<stampTime && !maxed ) {
        particles.add( new Star(1000, int(owner.cx), int( owner.cy), 0, 0, 150, 0.9, WHITE) );
        maxed=true;
      }
    }
    //if (!active)press(); // cancel
    if (owner.hit)release(); // cancel
  }
  @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if ( !owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        particles.add(new ShockWave(int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 25, 20, 400, owner.playerColor));
        regen=true;
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        if (cooldown<stampTime)action();
        deChannel();
        deactivate();
        enableCooldown();
        maxed=false;
        //owner.pushForce(8, owner.keyAngle);
      }
      removeShields();
    }
  }
  void reset() {
    super.reset();
    forceAmount=0;
    cooldownTimer=int(1000-attackSpeedMod*9);

    regen=true;
    //  channeling=false;
    deChannel();
    release();
  }
  @Override
    void passive() {
    //if (MAX_FORCE<=forceAmount) {
    noStroke();
    fill(255);
    pushMatrix();
    translate(int(owner.cx), int(owner.cy));
    rotate(radians(owner.angle-90));
    rect(-5, 0, 10, forceAmount*11);
    popMatrix();
    // }
  }
  void removeShields() {
    for (Projectile s : shields) {
      s.dead=true;
      s.deathTime=stampTime;
    }
    shields.clear();
  }
}

class ChargeSlash extends Ability {//---------------------------------------------------    ChargeSlash   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=85, damageFactor=0.2;
  float forceAmount=0, MODIFIED_MAX_ACCEL=0.003, MODIFIED_ANGLE_FACTOR=0.1;
  float ChargeRate=0.85, restForce;
  boolean maxed;
  ChargeSlash() {
    super();
    icon=icons[40];
    name=getClassName(this);
    regenRate=0.35;
    activeCost=20;
    channelCost=0.1;
    unlockCost=3000;
  } 
  @Override
    void action() {
    if (forceAmount>=MAX_FORCE) { 
      particles.add(new Flash(100, 6, WHITE)); 
      particles.add(new Gradient(1000, int(owner.cx), int(owner.cy), 0, 0, 4, 100, owner.angle, owner.playerColor));
      shakeTimer+=10;
    }
    //particles.add(new Gradient(int(forceAmount*11), int(owner.cx), int(owner.cy), 0, 0, 4, 100, owner.angle, owner.playerColor));
    //particles.add(new Gradient(1500, int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, int(forceAmount*11), int(forceAmount*11),4, owner.angle, owner.playerColor));
    particles.add(new  Gradient(  1000, int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, int(forceAmount*11), int(owner.radius*2), 8, owner.angle, owner.playerColor));
    projectiles.add(new Slash(owner, int(owner.cx), int(owner.cy), 150, WHITE, int(3.3*forceAmount), owner.angle, 50, 1.5*forceAmount+50, cos(radians(owner.angle))*forceAmount*.5, sin(radians(owner.angle))*forceAmount*.3, int(forceAmount*damageFactor)+int(damageMod*.2), true));
    projectiles.add(new Slash(owner, int(owner.cx), int(owner.cy), 150, WHITE, 280, owner.angle, -20, 70, cos(radians(owner.angle))*forceAmount, sin(radians(owner.angle))*forceAmount, int(forceAmount*damageFactor*2)+int(damageMod*2), false));
    owner.x+=cos(radians(owner.angle))*forceAmount*11;
    owner.y+=sin(radians(owner.angle))*forceAmount*11;
  }
  @Override
    void press() {
    if (cooldown<stampTime&&(!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity) && energy>(0+activeCost)&& !hold && !active && !channeling && !owner.dead) {
      projectiles.add(new Slice(owner, int(owner.cx-cos(radians(owner.angle))*250), int(owner.cy-sin(radians(owner.angle))*250), 350, owner.playerColor, 180, owner.angle+145, 6, 130, cos(radians(owner.angle))*forceAmount*.5, sin(radians(owner.angle))*forceAmount*.5, int(30*damageFactor+damageMod*.1), false));
      activate();
      forceAmount=5;
      //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      stamps.add( new AbilityStamp(this));
      regen=false;
    }
  }
  @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity) &&  active && !owner.dead) {
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      if (MAX_FORCE>forceAmount) { 
        channel();
        if (!active || energy<0 ) {
          release();
        }
        maxed=false;
        restForce = MAX_FORCE-forceAmount;
        forceAmount+=ChargeRate*timeBend; 
        particles.add(new RParticles(int(owner.cx+cos(radians(owner.angle))), int(owner.cy+sin(radians(owner.angle))), random(-restForce*0.5, restForce*0.5), random(-restForce*0.5, restForce*0.5), int(random(30)+10), 200, owner.playerColor));
        //particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))), int(owner.cy+sin(radians(owner.angle))), int(forceAmount*.5), 16, int(forceAmount*.5), owner.playerColor));
        // particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*forceAmount*12), int(owner.cy+sin(radians(owner.angle))*forceAmount*11), 0, 0, int(MAX_FORCE*1.5), 30, color(255, 0, 255)));
      } else {
        if (!maxed) {
          particles.add( new Star(2000, int(owner.cx), int( owner.cy), 0, 0, 350, 0.9, WHITE) );
          maxed=true;
        }
      }
    }
    if (!active)press(); // cancel
    //if (owner.hit)release(); // cancel
  }
  @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        //stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new AbilityStamp(this));
        particles.add(new ShockWave(int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 25, 20, 400, owner.playerColor));

        owner.pushForce(forceAmount*.4, owner.angle);
        regen=true;
        action();
        enableCooldown();

        deChannel();
        deactivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        forceAmount=0;
      }
    }
  }
  void reset() {
    super.reset();
    forceAmount=0;
    cooldownTimer=int(400-attackSpeedMod*3);
    maxed=false;
    regen=true;
    deChannel();
    release();
  }
  @Override
    void passive() {
    //if (MAX_FORCE<=forceAmount) {
    noStroke();
    if (maxed) fill(WHITE);
    else fill(owner.playerColor);
    pushMatrix();
    translate(int(owner.cx), int(owner.cy));
    rotate(radians(owner.angle-90));
    rect(-5, 0, 10, forceAmount*11);
    popMatrix();
    // }
  }
}

class Random extends Ability {//---------------------------------------------------    Random   ---------------------------------
  Ability rA=null;
  boolean noEmpty;
  Random() {
    super();
  } 
  Random(boolean _noEmpty) {
    super();
    /* if (a.unlocked && a.deactivatable) {
     a.deactivated=!a.deactivated;
     int active=0;
     for (Ability as : abilityList) {
     if (!as.deactivated && as.unlocked )active++;
     }
     if (active<1) {
     abilityList[0].deactivated=false;
     abilityList[0].unlocked=true;
     }
     active=0;
     for (Ability as : passiveList) {
     if (!as.deactivated  && as.unlocked )active++;
     }
     if (active<1) {
     passiveList[0].deactivated=false;
     passiveList[0].unlocked=true;
     }
     }*/
    noEmpty=_noEmpty;
  } 
  Ability randomize(Ability[] list) {

    try {
      int count=0; 
      rA = list[int(random(list.length))].clone();
      if (noEmpty)while ( !rA.unlocked ||rA instanceof NoPassive||  rA instanceof NoActive || rA.deactivated &&count<300) { 
        count++;
        rA = list[int(random(list.length))].clone();
        //println(rA.name);
      } else while ( !rA.unlocked || rA.deactivated &&count<300) { 
        count++;
        rA = list[int(random(list.length))].clone();
        //println(rA.name);
      }
    }
    catch(CloneNotSupportedException e) {
      println("not cloned from Random Ability");
    }

    return rA;  // clone it
  }
}