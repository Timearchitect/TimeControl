
String getClassName(Object o) {

  return o.getClass().getSimpleName();
}
class Ability implements Cloneable {
  String name="???";
  Player owner;  
  PImage icon;
  long cooldown;
  int cooldownTimer;
  float energy=90, maxEnergy=100, activeCost=5, channelCost, deChannelCost, deactiveCost, maxCooldown, regenRate=0.1, ammo, maxAmmo, loadRate;
  boolean active, channeling, cooling, hold, regen=true, meta;
  void Ability() { 
    //name=this.getClass().getSimpleName();
    //name=this.getClass().getCanonicalName();

    //name=this.getClass().getSimpleName();
    //name=this.getClass().getCanonicalName();

    icon = loadImage("Ability Icons-04.jpg");
    //energy=100;
    //maxEnergy=energy;
  }
  void Ability( Player _owner) { 
    Ability();
    owner=_owner;
  }
  void press() {
  }
  void release() {
  }
  void hold() {
  }
  void action() {
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

  void deActivate() {
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
      } else if (regen) {
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
    if (owner!=null) {
      owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    }
  }
  void setOwner(Player _owner) {
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
    background(0, 255, 255);
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
      deActivate();
    }
  }
  void activate() { 
    active=true;
    energy -= activeCost;
    action();
    regen=false;
  }
  @Override
    void deActivate() {
    super.deActivate();
    regen=true;
    action();
  }
  @Override
    void passive() {
    if (active) {
      channel();
      if (energy<0) {
        deActivate();
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
        particles.add( new Feather(400, int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-5, 5), random(-5, 5), 15, owner.playerColor));
      }
      particles.add( new  Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, owner.w, 50, owner.playerColor));
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
      deActivate();
    }
  }
  void activate() { 
    active=true;
    energy -= activeCost;
    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 16, 150, owner.playerColor));
    stamps.add( new ControlStamp(owner.index, int(owner.x), int( owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    regen=false;
    action();
  }

  @Override
    void deActivate() {
    super.deActivate();
    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 200, 16, 850, owner.playerColor));
    action();
    //  stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
    regen=true;
  }
  @Override
    void passive() {
    if (active) {
      channel();
      if (energy<0) {
        deActivate();
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
      deActivate();
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
    void deActivate() {
    super.deActivate();
    //  stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
    action();
    active=false;
    regen=true;
  }
  void passive() {
    if (active|| reverse) {
      channel();
      if (energy<0) {
        deActivate();
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
      deActivate();
      action();
    }
  }
  @Override
    void deActivate() {
    super.deActivate();
    stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
    for (int i=0; i< players.size (); i++) {  
      if (!players.get(i).dead) {
        particles.add(new ShockWave(int(players.get(i).x+players.get(i).w*0.5), int(players.get(i).y+players.get(i).h*0.5), 20, 16, 500, players.get(i).playerColor));
        particles.add( new  Particle(int(players.get(i).x+players.get(i).w*0.5), int(players.get(i).y+players.get(i).h*0.5), 0, 0, int(players.get(i).w), 1000, players.get(i).playerColor));
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
      deActivate();
    }
  }
  @Override
    void deActivate() {
    quitOrigo();
    super.deActivate();
    saved.call();
    shakeTimer=30;
    particles.add(new Flash(1200, 5, color(255)));   // flash
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
        particles.add(new Flash(1500, 5, color(255)));   // flash
        for (int i=0; i< 10; i++) {
          balls.add(new Ball(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), int(cos(radians(i*36))*8), int(sin(radians(i*36))*8), int(40), owner.playerColor));
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

  void passiveDisplay() {
    stroke(255);
    strokeWeight(int(sin(radians(pulse))*8)+1);
    fill(255);
    if (active) { 
      float f = (float)(endTime-stampTime)/duration;
      for (int i=0; i<360*f; i+= (360/12)) {
        line(owner.x+owner.w*0.5+ cos(radians(-90-i))*80, owner.y+owner.w*0.5+sin(radians(-90-i))*80, owner.x+owner.w*0.5+ cos(radians(-90-i))*130, owner.y+owner.w*0.5+sin(radians(-90-i))*130);
      }
      text(displayTime, owner.x+owner.w*0.5, owner.y-owner.h*1);
    }
    noFill();
    // point(owner.x+owner.w*0.5+cos(radians(owner.angle))*range, owner.y+owner.h*0.5+sin(radians(owner.angle))*range);
    ellipse(owner.x+owner.w*0.5, owner.y+owner.h*0.5, owner.w*2, owner.h*2);
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
  final int damage=17, slashdamage2=2, threashold =2;
  final int slashDuration=190, slashRange=100, slashdamage=4;
  boolean alternate;
  ThrowDagger() {
    super();
    name=getClassName(this);
    activeCost=8;
    regenRate=0.15;
  } 
  @Override
    void action() {
    if (abs(owner.vx)>threashold  ||  abs(owner.vy)>threashold) {
      if (abs(owner.keyAngle-owner.angle)<5) {
        if (alternate) {
          projectiles.add( new IceDagger(owner, int( owner.x+owner.w*0.5+cos(radians(owner.keyAngle-45))*75), int(owner.y+owner.h*0.5+sin(radians(owner.keyAngle-45))*75), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, int(damage*1.2)));
          projectiles.add( new Slash(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 120, owner.angle+100, 24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
        } else {
          projectiles.add( new IceDagger(owner, int( owner.x+owner.w*0.5+cos(radians(owner.keyAngle+45))*75), int(owner.y+owner.h*0.5+sin(radians(owner.keyAngle+45))*75), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, int(damage*1.2)));
          projectiles.add( new Slash(owner, int( owner.x+owner.w*0.5+sin(owner.keyAngle)*50), int(owner.y+owner.h*0.5+cos(owner.keyAngle)*50), 30, owner.playerColor, 120, owner.angle-100, -24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
        }
      } else {
        if (alternate) {
          projectiles.add( new ArchingIceDagger(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.50), 30, owner.playerColor, 1000, owner.keyAngle, (owner.keyAngle-owner.angle)*8, owner.ax*24, owner.ay*24, damage));
          projectiles.add( new Slash(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 120, owner.angle+100, 24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
        } else { 
          projectiles.add( new ArchingIceDagger(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 1000, owner.keyAngle, (owner.keyAngle-owner.angle)*8, owner.ax*24, owner.ay*24, damage));
          projectiles.add( new Slash(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 120, owner.angle-100, -24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
        }
      }
      alternate=!alternate;
    } else {
      owner.pushForce(-13, owner.angle);
      // for (int i=0; i<360; i+=10) {
      //  projectiles.add( new ArchingIceDagger(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 1000, owner.angle, owner.angle+90, sin(radians(i))*20, -cos(radians(i))*20, damage));
      //}

      projectiles.add( new ArchingIceDagger(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 1000, owner.angle, owner.angle, sin(radians(owner.angle+140))*20, -cos(radians(owner.angle+140))*20, damage));
      projectiles.add( new ArchingIceDagger(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 1000, owner.angle, owner.angle+180, sin(radians(owner.angle+40))*20, -cos(radians(owner.angle+40))*20, damage));
      projectiles.add( new Slash(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, int(slashDuration), owner.angle+90, 22, slashRange, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage, true));
      projectiles.add( new Slash(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, int(slashDuration), owner.angle-90, -22, slashRange, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage, true));
    }
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
}

class Revolver extends Ability {//---------------------------------------------------    ThrowDagger   ---------------------------------
  final int damage=36;
  int r;
  float accuracy=1, MODIFIED_ANGLE_FACTOR=0.18;
  Revolver() {
    super();
    name=getClassName(this);
    activeCost=maxEnergy;
    maxAmmo=6;
    ammo=maxAmmo;
    cooldownTimer=240;
    regenRate=0.25;
  } 
  @Override
    void action() {
    projectiles.add( new RevolverBullet(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*75), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*75), 60, 25, owner.playerColor, 1000, owner.angle, damage));
    particles.add(new ShockWave(int(owner.x+owner.w*0.5+cos(radians(owner.angle))*75), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*75), 30, 32, 75, owner.playerColor));
    owner.pushForce(-13, owner.angle);
    owner.angle+=random(-180, 180);
    ammo--;
    r=30;
  }

  @Override
    void press() {
    // particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 16, 200, owner.playerColor));
    if ( ammo > 0&& cooldown<stampTime  &&(!reverse || owner.reverseImmunity)&&  !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
  @Override
    void passive() {
    strokeWeight(2);
    stroke(owner.playerColor);
    noFill();
    if (r<90)r+=int(5*timeBend);
    for (int i =-r; i<=360; i+= 360/maxAmmo) {
      ellipse(owner.x+owner.w*0.5+cos(radians(i))*90, owner.y+owner.h*0.5+sin(radians(i))*90, 40, 40);
    }
    fill(owner.playerColor);
    for (int i =0; i<=maxAmmo; i++) {
      if (ammo>i)ellipse(owner.x+owner.w*0.5+cos(radians(i*360/maxAmmo-r))*90, owner.y+owner.h*0.5+sin(radians(i*360/maxAmmo-r))*90, 30, 30);
    }
    owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
  }
  void reload() {
    r=-30;
    owner.vx=0;
    owner.vy=0;
    owner.ax=0;
    owner.ay=0;
    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 24, 200, owner.playerColor));
    particles.add( new  Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    ammo=maxAmmo;
  }
}
class ForceShoot extends Ability {//---------------------------------------------------    forceShoot   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=60;
  float forceAmount=0, MODIFIED_MAX_ACCEL=0.02, MODIFIED_ANGLE_FACTOR=0.16;
  float ChargeRate=0.4, restForce;

  ForceShoot() {
    super();
    name=getClassName(this);
    activeCost=8;
    channelCost=0.1;
  } 
  @Override
    void action() {
    if (forceAmount>=MAX_FORCE) { 
      particles.add(new Flash(100, 6, color(255))); 
      particles.add(new  gradient(1000, int(owner.x+playerSize*0.5), int(owner.y+playerSize*0.5), 0, 0, 4, 100, owner.angle, owner.playerColor));

      shakeTimer=20;
    }
    projectiles.add( new forceBall(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), forceAmount*2+4, 30, owner.playerColor, 2000, owner.angle, forceAmount*6));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity) && energy>(0+activeCost)&& !hold && !active && !channeling && !owner.dead) {
      activate();
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=false;
    }
  }
  @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead) {
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      if (MAX_FORCE>forceAmount) { 
        channel();
        if (!active || energy<0 ) {
          release();
        }
        restForce = MAX_FORCE-forceAmount;
        forceAmount+=ChargeRate*timeBend; 
        particles.add(new Particle(int(owner.x+owner.w*0.5+cos(radians(owner.angle))*75), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*75), random(-restForce*0.5, restForce*0.5), random(-restForce*0.5, restForce*0.5), int(random(30)+10), 300, owner.playerColor));
        particles.add(new ShockWave(int(owner.x+owner.w*0.5+cos(radians(owner.angle))*75), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*75), int(forceAmount/3), 16, int(forceAmount/3), owner.playerColor));
      } else {
        particles.add( new  Particle(int(owner.x+owner.w*0.5+cos(radians(owner.angle))*75), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*75), 0, 0, int(MAX_FORCE*1.5), 30, color(255, 0, 255)));
      }
    }
    if (!active)press(); // cancel
    if (owner.hit)release(); // cancel
  }
  @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
  void reset() {
    hold=false;
    active=false;
    regen=true;
    channeling=false;
    super.reset();
  }
  @Override
    void passive() {
    if (MAX_FORCE<=forceAmount) {
      fill(255);
      pushMatrix();
      translate(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5));
      rotate(radians(owner.angle-90));
      rect(-5, 0, 10, 2000);
      popMatrix();
    }
  }
}

class Blink extends Ability {//---------------------------------------------------    Blink   ---------------------------------
  int range=250, damage=50;
  Blink() {
    super();
    name=getClassName(this);
    activeCost=10;
  } 
  @Override
    void action() {
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 16, 200, owner.playerColor));
    particles.add( new  Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    for (int i =0; i<3; i++) {
      particles.add( new Feather(300, int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-2, 2), random(-2, 2), 15, owner.playerColor));
    }
    owner.x+=cos(radians(owner.angle))*range;
    owner.y+= sin(radians(owner.angle))*range;
    checkInside();
    //projectiles.add( new IceDagger(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, 10));

    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 16, 200, owner.playerColor));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
  void checkInside() {
    for (Player enemy : players) {
      if (!enemy.dead  && owner.ally != enemy.ally && dist(owner.x, owner.y, enemy.x, enemy.y)<90) {
        enemy.hit(damage);
        particles.add(new Flash(100, 8, color(0)));  
        particles.add( new TempFreeze(200));
        for (int i =0; i<2; i++) {
          particles.add( new Feather(300, int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-4, 4), random(-4, 4 ), 20, enemy.playerColor));
        }
        particles.add(new ShockWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 300, 16, 300, color(255)));
        particles.add(new ShockWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 100, 16, 300, owner.playerColor));
        for (int i=0; i<360; i+=30) particles.add(new Spark( 1000, int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), -cos(radians(i))*5, -sin(radians(i))*5, 6, i, owner.playerColor));
      }
    }
  }
}
class Multiply extends Ability {//---------------------------------------------------    Multiply   ---------------------------------
  int range=playerSize, cloneDamage=3, dir;
  ArrayList<Player> clone= new ArrayList();
  Player currentClone;
  Multiply() {
    super();
    name=getClassName(this);
    activeCost=80;
  } 
  @Override
    void action() {
    for (int i=0; i<12; i++) {
      particles.add(new Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-10, 10), random(-10, 10), int(random(20)+5), 800, 255));
    }
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    switch(dir%4) {
    case 0:
      currentClone=new Player(players.size(), owner.playerColor, int(owner.x-cos(radians(owner.angle))*range), int(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.down, owner.up, owner.right, owner.left, owner.triggKey, new CloneMultiply());
      break;
    case 1:
      currentClone=new Player(players.size(), owner.playerColor, int(owner.x-cos(radians(owner.angle))*range), int(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.right, owner.left, owner.up, owner.down, owner.triggKey, new CloneMultiply());
      break;
    case 2:
      currentClone=new Player(players.size(), owner.playerColor, int(owner.x-cos(radians(owner.angle))*range), int(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.up, owner.down, owner.left, owner.right, owner.triggKey, new CloneMultiply());
      break;
    case 3:
      currentClone=new Player(players.size(), owner.playerColor, int(owner.x-cos(radians(owner.angle))*range), int(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.left, owner.right, owner.down, owner.up, owner.triggKey, new CloneMultiply());
      break;
    }
    dir++;

    players.add(currentClone);
    clone.add(players.get(players.size()-1));
    // clone.add(players.get(players.size()-1));
    // Player currentClone=clone.get(clone.size()-1);

    owner.x+=cos(radians(owner.angle))*range;
    owner.y+= sin(radians(owner.angle))*range;
    currentClone.clone=true;
    currentClone.ally=owner.ally; //same ally
    currentClone.dead=true;
    currentClone.damage=cloneDamage;
    stamps.add( new StateStamp(players.size()-1, int(owner.x), int(owner.y), owner.state, owner.health, true));
    currentClone.dead=false;
    currentClone.maxHealth=int(owner.maxHealth*0.5);
    currentClone.health=int(owner.health*0.5);
    currentClone.ability.energy=int(owner.ability.energy);

    //   owner.ability.owner=owner;
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
}
class CloneMultiply extends Multiply { // ability that have no effect as clones.
  int damage=30;
  CloneMultiply() {
    super();
    name=getClassName(this);
  }
  @Override
    void action() {
    //projectiles.add( new Bomb(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 75, owner.playerColor, 1000, owner.angle, 0, 0, damage, false));
    for (int i=0; i<12; i++) {
      particles.add(new Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-10, 10), random(-10, 10), int(random(20)+5), 800, 255));
    }
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
  @Override
    void onDeath() {
    if ((!reverse || owner.reverseImmunity)&&  owner.health<=0 && (!freeze || owner.freezeImmunity)) {
      projectiles.add( new Bomb(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 120, owner.playerColor, 1200, owner.angle, owner.vx, owner.vy, damage, false));
    }
  }
}

class Stealth extends Ability {//---------------------------------------------------    Stealth   ---------------------------------
  int projectileDamage=10, wait;
  float MODIFIED_MAX_ACCEL=0.06;
  float range=200, duration=300;
  Stealth() {
    super();
    active=false;
    name=getClassName(this);
    activeCost=25;
    energy=25;
  } 
  @Override
    void action() {
    stamps.add( new StateStamp(owner.index, int(owner.x), int(owner.y), owner.state, owner.health, owner.dead));
    particles.add( new  Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, int(owner.w), 300, color(255, 0, 255)));
    for (int i =0; i<10; i++) {
      particles.add( new Feather(300, int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-2, 2), random(-2, 2), 500, owner.playerColor));
    }
    owner.stealth=true;
  }
  @Override
    void press() {

    if ((!reverse || owner.reverseImmunity)&& !owner.dead && (!freeze || owner.freezeImmunity)) {
      if (energy>0+activeCost && !active) { 
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new StateStamp(owner.index, int(owner.x), int(owner.y), owner.state, owner.health, owner.dead));

        regen=false;
        activate();
        particles.add(new Flash(300, 6, owner.playerColor));  
        action();
        owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      } else if (owner.stealth) {
        stamps.add( new StateStamp(owner.index, int(owner.x), int(owner.y), owner.state, owner.health, owner.dead));
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        regen=true;
        owner.stealth=false;
        particles.add(new TempSlow(int(wait*.1), 0.02, 1.06));
        particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 16, 200, owner.playerColor));
        projectiles.add( new Slash(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, int(duration), owner.angle, 24, range, 0, 0, int(projectileDamage+wait*0.1), true));
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
      if ( int(random(60))==0)particles.add(new Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-5, 5), random(-5, 5), int(random(20)+5), 600, 255));
    }
  }
}


class Combo extends Ability {//---------------------------------------------------    Stealth   ---------------------------------
  int projectileDamage=34, step=1, maxStep=3, damage=10, shootSpeed=35;
  float MODIFIED_MAX_ACCEL=0.08, MODIFIED_MAX_ACCEL_2=0.25, MODIFIED_FRICTION_FACTOR=0.12;
  int comboMinWindow= 185, comboMaxWindow=800;
  long comboWindowTimer;
  int stepActivateCost[]={0, 10, 5, 8, 5};
  Combo() {
    super();
    active=false;
    name=getClassName(this);
    activeCost=stepActivateCost[1];
    energy=100;
  } 

  @Override
    void action() {
    //stamps.add( new StateStamp(owner.index, int(owner.x), int(owner.y), owner.state, owner.health, owner.dead));
    // particles.add( new  Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, int(owner.w), 300, color(255, 0, 255)));
    //for (int i =0; i<10; i++) {
    //  particles.add( new Feather(300, int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-2, 2), random(-2, 2), 500, owner.playerColor));
    //}
    if (step==1||stampTime>comboWindowTimer+comboMinWindow && stampTime<comboWindowTimer+comboMaxWindow) {
      activate();
      comboWindowTimer=stampTime;
      //particles.add( new  Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, 200, 300, color(255, 0, 255)));
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
      projectiles.add( new Slash(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*75), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*75), 30, owner.playerColor, 130, owner.angle-100, -24, 100, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, int(damage*0.4), true));
      owner.pushForce(5, owner.angle);
      projectiles.add( new Shield( owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*50), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*50), owner.playerColor, 225, owner.angle+90+30, damage, int(cos(radians(owner.angle+30))*100), int(sin(radians(owner.angle+30))*100)));
      projectiles.add( new Shield( owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*50), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*50), owner.playerColor, 250, owner.angle+90, damage, int(cos(radians(owner.angle))*100), int(sin(radians(owner.angle))*100)));
      projectiles.add( new Shield( owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*50), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*50), owner.playerColor, 275, owner.angle+90-30, damage, int(cos(radians(owner.angle-30))*100), int(sin(radians(owner.angle-30))*100)));

      break;
    case 2:
      projectiles.add( new Slash(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*50), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*50), 30, owner.playerColor, 130, owner.angle+100, 24, 130, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, int(damage*0.6), true));
      owner.pushForce(18, owner.angle);
      particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 16, 175, owner.playerColor));

      break;
    case 3:
      projectiles.add( new Slash(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 500, owner.angle+200, -25, 175, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, int(damage*0.9), true));
      owner.pushForce(4, owner.angle);
      particles.add( new Feather(350, int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), owner.vx, owner.vy, 30, owner.playerColor));

      // projectiles.add( new Bomb(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, owner.playerColor, 600, owner.angle-20, cos(radians(owner.angle-20))*shootSpeed, sin(radians(owner.angle-20))*shootSpeed, damage*2, false));
      //  projectiles.add( new Bomb(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, owner.playerColor, 600, owner.angle+20, cos(radians(owner.angle+20))*shootSpeed, sin(radians(owner.angle+20))*shootSpeed, damage*2, false));
      // projectiles.add( new Rocket(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 1000, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage*2, false));
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
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
    //if (owner.stealth && int(random(60))==0)particles.add(new Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-5, 5), random(-5, 5), int(random(20)+5), 600, 255));
    if (step==3) {
      owner.MAX_ACCEL= MODIFIED_MAX_ACCEL_2;
      owner.FRICTION_FACTOR=MODIFIED_FRICTION_FACTOR;
      // if(random(10)<2)particles.add( new Feather(350, int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-1, 1), random(-1, 1), 30, owner.playerColor));
      particles.add(new Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), owner.vx, owner.vy, 120, 50, color(255)));
    } else {
      owner.MAX_ACCEL= MODIFIED_MAX_ACCEL;
      owner.FRICTION_FACTOR= DEFAULT_FRICTION;
    }

    text(step, int(owner.x), int(owner.y));
    if (stampTime>comboWindowTimer+comboMaxWindow) {
      if (step>1)step--;
      comboWindowTimer=stampTime;
    }
  }
}

class Laser extends Ability {//---------------------------------------------------    Laser   ---------------------------------
  int damage=3, duration=2400, delay=500, laserWidth=75,chargelevel;
  long timer;
  float MODIFIED_ANGLE_FACTOR=0, MODIFIED_MAX_ACCEL=0.006; 
  long startTime;
  boolean charging;
  Laser() {
    super();
    name=getClassName(this);
    activeCost=24;
  } 
  @Override
    void action() {
    timer=millis();
    chargelevel++;
    particles.add(new gradient(150*chargelevel, int(owner.x+owner.w*0.5 +cos(radians(owner.angle))*owner.w*0.5), int(owner.y+owner.w*0.5+sin(radians(owner.angle))*owner.w*0.5), 0, 0, 75*chargelevel, 6*chargelevel, owner.angle, owner.playerColor));
    particles.add(new RShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.w*0.5), 270*chargelevel, 16+10*chargelevel, 150*chargelevel, owner.playerColor));
    charging=true;
    //projectiles.add( new ChargeLaser(owner.index, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), owner.playerColor, duration, owner.angle, damage));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      action();
      startTime=stampTime;
      deActivate();
      // particles.add(new  gradient(1000,int(owner.x+owner.w*0.5 +cos(radians(owner.angle))*owner.w*0.5), int(owner.y+owner.w*0.5+sin(radians(owner.angle))*owner.w*0.5), 0, 0, 3, owner.angle, owner.playerColor));
    }
  }
  void passive() {
    if (charging && (timer+delay/S/F)<millis()) {
      particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 200*chargelevel, 16, 500, owner.playerColor));
      particles.add(new Flash(50, 6, color(255))); 

      // for (int i=0; i<chargelevel; i++) { //!!!
      projectiles.add( new ChargeLaser(owner, int( owner.x+owner.w*0.5+random(50, -50)), int(owner.y+owner.h*0.5+random(50, -50)), laserWidth*chargelevel, owner.playerColor, duration, owner.angle, damage*chargelevel));
      // }
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
}

class TimeBomb extends Ability {//---------------------------------------------------    TimeBomb   ---------------------------------
  int damage=50;
  int shootSpeed=32;
  TimeBomb() {
    super();
    name=getClassName(this);
    activeCost=14;
    regenRate=0.22;
    energy=maxEnergy*0.5;
  } 
  @Override
    void action() {
    owner.pushForce(-8, owner.angle);
    //if (int(random(5))!=0) {
    if (energy<maxEnergy-activeCost) {
      projectiles.add( new Bomb(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, int(random(500, 2000)), owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, true));
    } else {
      projectiles.add( new Mine(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 80000, owner.angle, cos(radians(owner.angle))*shootSpeed*0.5, sin(radians(owner.angle))*shootSpeed*0.5, damage, true));
      particles.add(new Particle(int(owner.x+owner.w*0.5+cos(radians(owner.angle))*325), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*325), 0, 0, 100, 300, color(0)));
    }
  }
  @Override
    void passive() {
    if (energy>=maxEnergy) {
      noFill();
      strokeWeight(4);
      stroke(owner.playerColor);
      rect(owner.x+owner.w*0.5+cos(radians(owner.angle))*325-25, owner.y+owner.h*0.5+sin(radians(owner.angle))*325-25, 50, 50);
      stroke(color(random(255)));
      rect(owner.x+owner.w*0.5+cos(radians(owner.angle))*325-35, owner.y+owner.h*0.5+sin(radians(owner.angle))*325-35, 70, 70);
      for (int i = 0; i <= 7; i++) {
        float x = lerp(owner.x+owner.w*0.5, owner.x+owner.w*0.5+cos(radians(owner.angle))*325, i/10.0) + 10;
        float y = lerp(owner.y+owner.w*0.5, owner.y+owner.h*0.5+sin(radians(owner.angle))*325, i/10.0);
        point(x, y);
      }
    }
  }

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      //owner.vx=0;
      // owner.vy=0;
      // owner.ax=0;
      // owner.ay=0;
      action();
      deActivate();
    }
  }
}
class Bazooka extends Ability {//---------------------------------------------------    Bazooka   ---------------------------------
  int  damage=28, shootSpeed=40, ammoType=2, maxAmmotype=4;
  float MODIFIED_MAX_ACCEL=0.06; 
  Bazooka() {
    super();
    cooldownTimer=1000;
    name=getClassName(this);
    activeCost=15;
    regenRate=0.13;
    energy=130;
  } 
  @Override
    void action() {

    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 16, 200, owner.playerColor));
    particles.add( new  Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    switch(ammoType%maxAmmotype) {

    case 0:
      projectiles.add( new RCRocket(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 2500, owner.angle, cos(radians(owner.angle))*shootSpeed*.02+owner.vx, sin(radians(owner.angle))*shootSpeed*.02+owner.vy, damage, false));
      break;

    case 1:
      projectiles.add( new Rocket(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 1000, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false));
      break;

    case 2:
      SinRocket sr;
      /*for (int i=0; i<360; i+=12) {
       sr= new SinRocket(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 2500, owner.angle, cos(radians(owner.angle))*shootSpeed*.01+owner.vx, sin(radians(owner.angle))*shootSpeed*.01+owner.vy, damage, false);
       sr.count=i;
       projectiles.add( sr);
       }*/
      sr= new SinRocket(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 2500, owner.angle, cos(radians(owner.angle))*shootSpeed*.01+owner.vx, sin(radians(owner.angle))*shootSpeed*.01+owner.vy, damage*2, false);
      sr.count=90;
      projectiles.add( sr);
      sr= new SinRocket(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 2500, owner.angle, cos(radians(owner.angle))*shootSpeed*.01+owner.vx, sin(radians(owner.angle))*shootSpeed*.01+owner.vy, damage*2, false);
      sr.count=275;
      projectiles.add( sr);
      break;
    case 3:
      projectiles.add( new Missle(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 7000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, false));

      break;
    }
    owner.pushForce(-18, owner.angle);
    ammoType++;
    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 16, 200, owner.playerColor));
  }
  void passive() {
    fill(255);
    switch(ammoType%maxAmmotype) {

    case 0:
      text("RC", int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5+100));
      break;

    case 1:
      text("CL", int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5+100));
      break;

    case 2:
      text("SN", int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5+100));
      break;
    case 3:
      text("MI", int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5+100));
      break;
    }
    owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
  }
  @Override
    void press() {
    if (cooldown<stampTime &&(!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      enableCooldown();
      activate();
      action();
      deActivate();
    }
  }
}

class RapidFire extends Ability {//---------------------------------------------------    RapidFire   ---------------------------------
  float accuracy = 1, MODIFIED_ANGLE_FACTOR=-0.0008, r=50  ;
  int Interval=110;
  long  PastTime;
  int projectileDamage=4;
  RapidFire() {
    super();
    name=getClassName(this);
    deactiveCost=6;
    channelCost=0.15;
  } 

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity) && energy>(0+activeCost) && !active && !channeling && !owner.dead) {
      activate();
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=false;
    }
  }
  @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead &&(stampTime-PastTime) >= Interval) {
      float InAccurateAngle=random(-accuracy, accuracy);
      projectiles.add( new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      r=50;
      channel();
      if (!active || energy<0 ) {
        release();
      }
      PastTime=stampTime;
    } else if ((!freeze || owner.freezeImmunity) &&  active && !owner.dead &&(stampTime+freezeTime-PastTime) >= Interval) {
      float InAccurateAngle=random(-accuracy, accuracy);
      projectiles.add( new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
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
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      }
    }
  }
  @Override
    void passive() {
    stroke(owner.playerColor);
    strokeWeight(12);
    if (r<100)r*=1.1;
    line(owner.x+owner.w*0.5, owner.y+owner.h*0.5, owner.x+owner.w*0.5+cos(radians(owner.angle))*r, owner.y+owner.h*0.5+sin(radians(owner.angle))*r);
  }
}

class MachineGun extends RapidFire {//---------------------------------------------------    RapidFire   ---------------------------------

  int alt, count, retractLength=40;
  float sutainCount, MAX_sutainCount=120, e, t;
  MachineGun() {
    super();
    name=getClassName(this);
    deactiveCost=10;
    channelCost=0.2;
    accuracy = 0;
    projectileDamage=5;
    cooldownTimer=1000;
    e=10;
    t=10;
    r=10;
    MODIFIED_ANGLE_FACTOR=0.001;
  } 
  void press() {
    super.press();
  }
  void action() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead &&(stampTime-PastTime) >= Interval) {
      float InAccurateAngle=random(-accuracy, accuracy);
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      channel();
      if (!active || energy<0 ) {
        release();
        //if(sutainCount>10)sutainCount-=10;
      }
      PastTime=stampTime;
      alt++;
      if (alt%3==0) {
        e=retractLength;
        projectiles.add( new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w+cos(radians(owner.angle+90))*17), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w+sin(radians(owner.angle+90))*17), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
        particles.add( new  Particle(int(owner.x+owner.w*0.5+cos(radians(owner.angle))*100+cos(radians(owner.angle+90))*17), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*100+sin(radians(owner.angle+90))*17), 0, 0, 50, 50, color(255)));
      } else if (alt%3==1) {
        r=retractLength;
        projectiles.add( new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w+cos(radians(owner.angle-90))*17), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w+sin(radians(owner.angle-90))*17), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
        particles.add( new  Particle(int(owner.x+owner.w*0.5+cos(radians(owner.angle))*100+cos(radians(owner.angle-90))*17), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*100+sin(radians(owner.angle-90))*17), 0, 0, 50, 50, color(255)));
      } else {  
        projectiles.add( new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
        particles.add( new  Particle(int(owner.x+owner.w*0.5+cos(radians(owner.angle))*100+cos(radians(owner.angle+0))*17), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*100+sin(radians(owner.angle+0))*17), 0, 0, 50, 50, color(255)));
        t=retractLength;
      }
    } else if ((!freeze || owner.freezeImmunity) &&  active && !owner.dead &&(stampTime+freezeTime-PastTime) >= Interval) {
      float InAccurateAngle=random(-accuracy, accuracy);
      projectiles.add( new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
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
    if (cooldown<stampTime) {
      action();
      // if (!active)press(); // cancel
      if (owner.hit)        if (sutainCount>10)sutainCount-=10;
      //release(); // cancel

      sutainCount+=0.4;
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
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        particles.add( new  Particle(int(owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 0, 0, 100, 50, color(255, 0, 255)));

        owner.pushForce(8, owner.angle+180);
        for (int i=0; sutainCount/8>i; i++) {
          float InAccurateAngle=random(-accuracy*2, accuracy*2);
          projectiles.add( new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 700, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*40, sin(radians(owner.angle+InAccurateAngle))*40, projectileDamage*2));
        }
        sutainCount=0;
        enableCooldown();
      }
    }
  }

  @Override
    void passive() {
    int offset=17;
    stroke(owner.playerColor);
    strokeWeight(15);
    if (r<80)r*=1.1;
    if (e<80)e*=1.1;
    if (t<80)t*=1.1;
    line(owner.x+owner.w*0.5+cos(radians(owner.angle+90))*offset, owner.y+owner.h*0.5+sin(radians(owner.angle+90))*offset, owner.x+owner.w*0.5+cos(radians(owner.angle))*e+cos(radians(owner.angle+90))*offset, owner.y+owner.h*0.5+sin(radians(owner.angle))*e+sin(radians(owner.angle+90))*offset);
    line(owner.x+owner.w*0.5+cos(radians(owner.angle))*offset, owner.y+owner.h*0.5+sin(radians(owner.angle))*offset, owner.x+owner.w*0.5+cos(radians(owner.angle))*t+cos(radians(owner.angle))*offset, owner.y+owner.h*0.5+sin(radians(owner.angle))*t+sin(radians(owner.angle))*offset);
    line(owner.x+owner.w*0.5+cos(radians(owner.angle-90))*offset, owner.y+owner.h*0.5+sin(radians(owner.angle-90))*offset, owner.x+owner.w*0.5+cos(radians(owner.angle))*r+cos(radians(owner.angle-90))*offset, owner.y+owner.h*0.5+sin(radians(owner.angle))*r+sin(radians(owner.angle-90))*offset);
  }
  @Override
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
  float sutainCount, MAX_sutainCount=40, inAccurateAngle=startAccuracy, MODIFIED_ANGLE_FACTOR=0, MODIFIED_MAX_ACCEL=0.05; 
  Sniper() {
    super();
    name=getClassName(this);
    deactiveCost=6;
    activeCost=4;
    channelCost=0.1;
    cooldownTimer=700;
    projectileDamage=201;
  } 
  void press() {
    super.press();
  }
  void hold() {
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
        if (inAccurateAngle>0)inAccurateAngle *=1-(0.04*timeBend);
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
    if (cooldown<stampTime && active) {
      if (inAccurateAngle<0.1)stroke(255);
      else stroke(owner.playerColor);
      //float xOffset=cos(radians(owner.angle))*nullRange;
      //float yOffset=sin(radians(owner.angle))*nullRange;

      strokeWeight(1);
      //   line(owner.x+owner.w*0.5+xOffset, owner.y+owner.h*0.5+yOffset, int( owner.x+owner.w*0.5+cos(radians(inAccurateAngle*3.25+owner.angle))*2000), int(owner.y+owner.h*0.5+sin(radians(inAccurateAngle*3.25+owner.angle))*2000));
      //   line(owner.x+owner.w*0.5+xOffset, owner.y+owner.h*0.5+yOffset, int( owner.x+owner.w*0.5+cos(radians(-inAccurateAngle*3.25+owner.angle))*2000), int(owner.y+owner.h*0.5+sin(radians(-inAccurateAngle*3.25+owner.angle))*2000));
      aimLine(nullRange, 2000, inAccurateAngle*3.25);
      aimLine(nullRange, 2000, -inAccurateAngle*3.25);
      noFill();
      //line(owner.x+owner.w*0.5+xOffset, owner.y+owner.h*0.5+yOffset, int( owner.x+owner.w*0.5+cos(radians(inAccurateAngle*0.25+owner.angle))*500), int(owner.y+owner.h*0.5+sin(radians(inAccurateAngle*0.25+owner.angle))*500));
      // line(owner.x+owner.w*0.5+xOffset, owner.y+owner.h*0.5+yOffset, int( owner.x+owner.w*0.5+cos(radians(-inAccurateAngle*0.25+owner.angle))*500), int(owner.y+owner.h*0.5+sin(radians(-inAccurateAngle*0.25+owner.angle))*500));

      aimLine(nullRange, 2000, inAccurateAngle*0.25);
      aimLine(nullRange, 2000, -inAccurateAngle*0.25);
      // line(owner.x+owner.w*0.5+xOffset, owner.y+owner.h*0.5+yOffset, int( owner.x+owner.w*0.5+cos(radians(inAccurateAngle*0.5+owner.angle))*1000), int(owner.y+owner.h*0.5+sin(radians(inAccurateAngle*0.5+owner.angle))*1000));
      // line(owner.x+owner.w*0.5+xOffset, owner.y+owner.h*0.5+yOffset, int( owner.x+owner.w*0.5+cos(radians(-inAccurateAngle*0.5+owner.angle))*1000), int(owner.y+owner.h*0.5+sin(radians(-inAccurateAngle*0.5+owner.angle))*1000));

      aimLine(nullRange, 2000, inAccurateAngle*0.5);
      aimLine(nullRange, 2000, -inAccurateAngle*0.5);
      strokeWeight(3);
      arc(owner.x+owner.w*0.5, owner.y+owner.h*0.5, nullRange*2, nullRange*2, radians(-inAccurateAngle+owner.angle), radians(inAccurateAngle+owner.angle));

      aimLine(nullRange, 2000, inAccurateAngle);
      aimLine(nullRange, 2000, -inAccurateAngle);
      //  line(owner.x+owner.w*0.5+xOffset, owner.y+owner.h*0.5+yOffset, int( owner.x+owner.w*0.5+cos(radians(inAccurateAngle+owner.angle))*2000), int(owner.y+owner.h*0.5+sin(radians(inAccurateAngle+owner.angle))*2000));
      //line(owner.x+owner.w*0.5+xOffset, owner.y+owner.h*0.5+yOffset, int( owner.x+owner.w*0.5+cos(radians(-inAccurateAngle+owner.angle))*2000), int(owner.y+owner.h*0.5+sin(radians(-inAccurateAngle+owner.angle))*2000));
    }
  }

  void  aimLine(float begin, float end, float inAccurate) {
    line(owner.x+owner.w*0.5+cos(radians(inAccurate+owner.angle))*begin, owner.y+owner.h*0.5+sin(radians(inAccurate+owner.angle))*begin, int( owner.x+owner.w*0.5+cos(radians(inAccurate+owner.angle))*end), int(owner.y+owner.h*0.5+sin(radians(inAccurate+owner.angle))*end));
  }  

  void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;

        float tempA=random(-inAccurateAngle, inAccurateAngle);
        projectiles.add( new SniperBullet(owner, int( owner.x+owner.w*0.5+cos(radians(tempA+owner.angle))*nullRange), int(owner.y+owner.h*0.5+sin(radians(tempA+owner.angle))*nullRange), 50, owner.playerColor, 10, owner.angle+tempA, int(projectileDamage-inAccurateAngle*2)));

        // projectiles.add( new Needle(owner.index, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 60, owner.playerColor, 800, owner.angle+tempA, cos(radians(owner.angle+tempA))*80, sin(radians(owner.angle+inAccurateAngle))*80, int(projectileDamage-inAccurateAngle*2)));
        owner.pushForce(-12, owner.angle);
        shakeTimer+=15; 
        inAccurateAngle=startAccuracy;
        //owner.pushForce(8, owner.angle+180);
        /*for (int i=0; sutainCount/2>i; i++) {
         float InAccurateAngle=random(-accuracy*2, accuracy*2);
         projectiles.add( new Needle(owner.index, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*40, sin(radians(owner.angle+InAccurateAngle))*40, projectileDamage*2));
         }*/
        // sutainCount=0;
        enableCooldown();
      }
    }
  }

  void reset() {
    super.reset();
    inAccurateAngle=startAccuracy;
    active=false;
    regen=true;
    deChannel();
    deActivate();
  }
}

class Battery extends Ability {//---------------------------------------------------    Battery   ---------------------------------
  int interval, maxInterval=4, damage=7, accuracy=10, count=0, maxCount=6;
  float  MODIFIED_ANGLE_FACTOR=0.02;

  Battery() {
    super();
    name=getClassName(this);
    activeCost=20;
    regenRate=0.12;
  } 

  @Override
    void action() {
    //projectiles.add(charge.get(count));
    float inAccuracy;
    inAccuracy =random(-accuracy, accuracy);
    switch(count) {
    case 0:
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      projectiles.add(new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*20, sin(radians(owner.angle+inAccuracy))*20, damage));        
      break;
    case 1:
      projectiles.add(new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*25, sin(radians(owner.angle+inAccuracy))*25, damage));        
      break;
    case 2:
      projectiles.add(new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*30, sin(radians(owner.angle+inAccuracy))*30, damage));        
      break;     
    case 3:
      projectiles.add(new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*35, sin(radians(owner.angle+inAccuracy))*35, damage));        
      break;
    case 4:
      projectiles.add(new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*40, sin(radians(owner.angle+inAccuracy))*40, damage));        
      break;
    case 5:
      projectiles.add(new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*45, sin(radians(owner.angle+inAccuracy))*45, damage));        
      break;
    default:
      for (int i=0; i<5; i++) {
        inAccuracy =random(-accuracy*2, accuracy*2);
        projectiles.add(new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*40, sin(radians(owner.angle+inAccuracy))*40, damage));
      }
      /* HomingMissile h= new HomingMissile(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle))*30, sin(radians(owner.angle))*5, damage);
       h.leap=true;
       h.locked=true;
       projectiles.add(h);*/
      projectiles.add( new RevolverBullet(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*50), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*50), 60, 25, owner.playerColor, 1000, owner.angle, damage));

      owner.pushForce(10, owner.angle+180);
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      particles.add( new  Particle(int(owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 0, 0, 100, 50, color(255, 0, 255)));
    }
    owner.pushForce(3, owner.angle+180);
  }

  @Override
    void press() {

    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
          deActivate();
          count=0;
        }
      }
      interval++;
    }
  }
}

class AutoGun extends Ability {//---------------------------------------------------    Battery   ---------------------------------

  float  MODIFIED_MAX_ACCEL=0.09, count;
  int damage=5, alternate ;
  ArrayList<Player> targets= new ArrayList<Player>() ;
  int amountOfTargets;
  AutoGun() {
    super();
    name=getClassName(this);
    activeCost=12;
    channelCost=0.1;
    regenRate=0.18;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity) && energy>(0+activeCost) && !active && !channeling && !owner.dead) {
      activate();
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=false;
    }
  }
  @Override
    void hold() {
    if ((!reverse || owner.reverseImmunity) &&  active && !owner.dead) {
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
              projectiles.add( new Needle(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*60), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*60), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*60, sin(radians(owner.angle))*60, damage));
              particles.add(new ShockWave(int(owner.x+owner.w*0.5+cos(radians(owner.angle))*85), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*85), 5, 22, 20, color(255)));
            }
            amountP++;
          }
        }
        amountOfTargets=amountP+1;
        alternate++;
        alternate=alternate%amountOfTargets;

        //particles.add(new ShockWave(int(owner.x+owner.w*0.5+cos(radians(owner.angle))*85), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*85), 5, 22, 20, color(255)));
      }
      count+=3*timeBend;
    }
  }
  @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        action();
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
      }
    }
  }
  void calcAngle(Player target) {
    owner.angle = degrees(atan2(((target.y+target.w*0.5)-owner.y-owner.h*.5), ((target.x+target.w*0.5)-owner.x-owner.w*.5)));
    owner.keyAngle =owner.angle;
    strokeWeight(1);
    stroke(255);
    line(target.x+target.h*0.5, target.y+target.w*0.5, owner.x+owner.w*.5, owner.y+owner.h*.5);
    targetVarning( target);
  }
  void targetVarning(Player target) {
    float tcx=target.x+target.w*0.5, tcy=target.y+target.w*0.5;
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


class ThrowBoomerang extends Ability {//---------------------------------------------------    Boomerang   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=64;
  float forceAmount=0, MODIFIED_MAX_ACCEL=0.04;
  float ChargeRate=0.9, restForce, recoveryEnergy;
  int damage=2, projectileSize=50;
  PShape boomerang;
  ThrowBoomerang() {
    super();
    name=getClassName(this);
    activeCost=15;
    channelCost=0.1;
    recoveryEnergy=activeCost*0.9;
  } 
  @Override
    void action() {
    projectiles.add( new Boomerang(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), projectileSize, owner.playerColor, int(300*forceAmount)+100, owner.angle, cos(radians(owner.angle))*(forceAmount+2), sin(radians(owner.angle))*(forceAmount+2), damage, recoveryEnergy, int(forceAmount*0.5+12)));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity) && energy>(0+activeCost) && !active && !channeling && !owner.dead) {
      activate();
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
        particles.add(new Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-restForce*0.5, restForce*0.5), random(-restForce*0.5, restForce*0.5), int(random(30)+10), 300, owner.playerColor));
        particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), int(forceAmount/3), 16, int(forceAmount/3), owner.playerColor));
      } else {
        //  particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), int(forceAmount), 50, color(255, 0, 255)));
        particles.add( new  Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, int(MAX_FORCE*2), 50, color(255, 0, 255)));
      }
    }
  }
  @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        action();
        owner.pushForce(-forceAmount*0.5, owner.angle);
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        forceAmount=0;
      }
    }
  }
  void passive() {
    // rect(owner.x,owner.y,50,50);
    if (active) {
      pushMatrix();
      translate(owner.x+owner.w*0.5-cos(radians(owner.angle))*forceAmount, owner.y+owner.h*0.5-sin(radians(owner.angle))*forceAmount);
      rotate(radians(owner.angle)+forceAmount);
      shape(boomerang, boomerang.width*.5, boomerang.height*.5, boomerang.width, boomerang.height);
      popMatrix();
    }
  }
  @Override
    void  reset() {
    super.reset();
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

class PhotonicWall extends Ability {//---------------------------------------------------    PhotonicPursuit   ---------------------------------
  int damage=30, customAngle, initialSpeed=5;
  ArrayList<HomingMissile> lockProjectiles= new ArrayList<HomingMissile>();
  float MODIFIED_ANGLE_FACTOR=0.018;
  float MODIFIED_MAX_ACCEL=0.04; 
  PhotonicWall() {
    super();
    name=getClassName(this);
    activeCost=8;
    energy=40;
  } 
  @Override
    void action() {
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(owner.x+owner.w*0.5+cos(radians(owner.angle-90))*50), int(owner.y+owner.h*0.5+cos(radians(owner.angle-90))*50), random(10)-5+cos(radians(owner.angle-90))*10, random(10)-5+sin(radians(owner.angle-90))*10, int(random(20)+5), 800, 255));
      particles.add(new Particle(int(owner.x+owner.w*0.5+cos(radians(owner.angle+90))*50), int(owner.y+owner.h*0.5+cos(radians(owner.angle+90))*50), random(10)-5+cos(radians(owner.angle+90))*10, random(10)-5+sin(radians(owner.angle+90))*10, int(random(20)+5), 800, 255));
    }   


    lockProjectiles.add(new HomingMissile(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle+100))*150), int(owner.y+owner.h*0.5+sin(radians(owner.angle+100))*150), 60, owner.playerColor, 1300, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
    lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
    lockProjectiles.get(lockProjectiles.size()-1).locking();
    projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
    lockProjectiles.add(new HomingMissile(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle+90))*120), int(owner.y+owner.h*0.5+sin(radians(owner.angle+90))*120), 70, owner.playerColor, 1300, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
    lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
    lockProjectiles.get(lockProjectiles.size()-1).locking();
    lockProjectiles.get(lockProjectiles.size()-1).ReactionTime=45;
    projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
    lockProjectiles.add(new HomingMissile(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle-90))*120), int(owner.y+owner.h*0.5+sin(radians(owner.angle-90))*120), 70, owner.playerColor, 1300, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
    lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
    lockProjectiles.get(lockProjectiles.size()-1).locking();
    lockProjectiles.get(lockProjectiles.size()-1).ReactionTime=45;
    projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
    lockProjectiles.add(new HomingMissile(owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle-100))*150), int(owner.y+owner.h*0.5+sin(radians(owner.angle-100))*150), 60, owner.playerColor, 1300, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
    lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
    lockProjectiles.get(lockProjectiles.size()-1).locking();
    projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
    owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
    owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
    owner.pushForce(-7, owner.angle);
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
  @Override
    void passive() {
    owner.MAX_ACCEL+= (owner.DEFAULT_MAX_ACCEL-owner.MAX_ACCEL)*.018;
    owner.ANGLE_FACTOR+= (owner.DEFAULT_ANGLE_FACTOR-owner.MAX_ACCEL)*.018;
  }
  @Override
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
  @Override
    void action() {

    if (energy>=maxEnergy-15) {

      for (Player p : players) {
        if (!p.dead) {
          customAngle=-90;

          HomingMissile h= new HomingMissile(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage);
          h.target=p;
          projectiles.add(h);
          customAngle=90;

          h= new HomingMissile(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage);
          h.target=p;
          projectiles.add(h);
          customAngle=0;

          /*   h= new HomingMissile(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage);
           h.target=p;
           projectiles.add(h);*/
        }
      }
    }

    customAngle=-90;
    projectiles.add( new HomingMissile(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));

    customAngle=90;
    projectiles.add( new HomingMissile(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
      r+=50;
    }
  }
  void passive() {
    if (r>shellRadius)r*=0.95;
    stroke(owner.playerColor);
    strokeWeight(15);
    noFill();
    arc(owner.x+owner.w*.5, owner.y+owner.h*.5, r, r, radians(owner.angle+45), radians(owner.angle+45+90));
    arc(owner.x+owner.w*.5, owner.y+owner.h*.5, r, r, radians(owner.angle+225), radians(owner.angle+225+90));
  }
}

class DeployThunder extends TimeBomb {//---------------------------------------------------    TimeBomb   ---------------------------------

  float MODIFIED_MAX_ACCEL=0.01, duration=300; 
  long startTime;
  DeployThunder() {
    super();
    damage=120;
    shootSpeed=0;
    regenRate=0.45;
    name=getClassName(this);
    activeCost=40;
  } 
  @Override
    void action() {
    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 10, 16, 1000, owner.playerColor));

    //    particles.add( new Shock(1000, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), owner.vx, owner.vy, 2, owner.angle, owner.playerColor)) ;
    // particles.add( new Shock(1000, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), owner.vx, owner.vy, 3, owner.angle, owner.playerColor)) ;
    // particles.add( new Shock(1000, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), owner.vx, owner.vy, 1, owner.angle, owner.playerColor)) ;

    startTime=stampTime;
    owner.MAX_ACCEL=owner.MAX_ACCEL*3;
    for (int i=0; i<7; i++) {
      particles.add(new Spark(700, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-15, 15), random(-15, 15), 2, random(360), owner.playerColor));
    }

    if (energy>=maxEnergy-activeCost) {   
      particles.add( new Text("!", int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, 180, 0, 4000, color(0), 1));
      particles.add( new Text("!", int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, 240, 0, 4000, owner.playerColor, 0));
      projectiles.add( new Thunder(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 500, owner.playerColor, 4000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, int(damage*1.3)));
    } else {
      particles.add( new Text("!", int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, 140, 0, 2000, color(0), 1));
      particles.add( new Text("!", int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, 180, 0, 2000, owner.playerColor, 0));
      projectiles.add( new Thunder(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 400, owner.playerColor, 2000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage));
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
    name=getClassName(this);
    activeCost=35;
    cooldownTimer=2850;
  } 
  @Override
    void action() {
    if (owner.health>=owner.maxHealth*.5) {
      /*for (int i=200; i<900; i+=75) {
       projectiles.add( new Shield( owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*i), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*i), owner.playerColor, 10000, owner.angle, damage ));
       }*/
      particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 300, 16, 90, color(255)));

      for (int i=0; i<360; i+=30) {
        projectiles.add( new Shield( owner, int( owner.x+owner.w*0.5+cos(radians(i))*195), int(owner.y+owner.h*0.5+sin(radians(i))*195), owner.playerColor, 2200, i+90, damage ));
      }
    } else {
      // particles.add(new Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, 120, 500, color(255)));
      particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 100, 16, 80, owner.playerColor));
      particles.add(new LineWave(int( owner.x+owner.w*0.5+cos(radians(owner.angle))*200), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*200), 10, 200, color(255), owner.angle+90));

      projectiles.add( new Shield( owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle-25))*220), int(owner.y+owner.h*0.5+sin(radians(owner.angle-25))*220), owner.playerColor, 11000, owner.angle+90, damage ));
      projectiles.add( new Shield( owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*200), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*200), owner.playerColor, 11100, owner.angle+90, damage ));
      projectiles.add( new Shield( owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle+25))*220), int(owner.y+owner.h*0.5+sin(radians(owner.angle+25))*220), owner.playerColor, 11000, owner.angle+90, damage ));
    }
    owner.vx=0;
    owner.vy=0;
    owner.ax=0;
    owner.ay=0;
  }
  @Override
    void press() {
    if (cooldown<stampTime &&(!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      enableCooldown();
      deActivate();
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
      quad(owner.x+owner.w*.5+shell, owner.y+owner.h*.5, owner.x+owner.w*.5, owner.y+owner.h*.5+shell, owner.x+owner.w*.5-shell, owner.y+owner.h*.5, owner.x+owner.w*.5, owner.y+owner.h*.5-shell);
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
    owner.vx=0;
    owner.vy=0;
    for (int i=0; i<24; i++) {
      projectiles.add( new IceDagger(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 25, owner.playerColor, 500, i*36, cos(radians(i*36))*50, sin(radians(i*36))*50, damage));
    }
    projectiles.add( new Bomb(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 220, owner.playerColor, 1, owner.angle, owner.vx, owner.vy, damage, false));

    shakeTimer+=10;
    particles.add(new Flash(200, 10, color(255)));   // flash
  }
  void reset() {
    super.reset();
    owner.armor=0;
  }
}

class DeployElectron extends Ability {//---------------------------------------------------    DeployElectron   ---------------------------------
  int damage=22;
  ArrayList<Electron> stored =new ArrayList<Electron> ();
  DeployElectron() {
    super();
    name=getClassName(this);
    activeCost=12;
  } 
  @Override
    void action() {
    if (energy>=maxEnergy-activeCost) {
      stored.add( new Electron( owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 10000, owner.angle, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
      stored.add( new Electron( owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 10000, owner.angle+120, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
      stored.add( new Electron( owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 10000, owner.angle+240, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
    } else {
      stored.add( new Electron( owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 10000, owner.angle, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
      stored.add( new Electron( owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 10000, owner.angle+180, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
    }
  }
  @Override
    void press() {
    for (Electron e : stored) {
      if (e.distance>=e.maxDistance)e.derail();
    }
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
  @Override
    void passive() {
    stroke(owner.playerColor);
    noFill();
    for (float i =0; i<=PI*2; i+=PI/6) {
      arc(int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 400, 400, i, i+PI*.03);
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
  Gravity() {
    super();
    name=getClassName(this);
    activeCost=25;
    regenRate=.15;
    cooldownTimer=1000;
  } 
  @Override
    void action() {
    if (energy>=maxEnergy-activeCost) {
      projectiles.add( new  Graviton(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 400, owner.playerColor, 12000, owner.angle, 0, 0, damage*3, 4));
    } else if (energy>=maxEnergy*.5) {
      projectiles.add( new  Graviton(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 300, owner.playerColor, 10000, owner.angle, 0, 0, damage*2, 3));
    } else {
      projectiles.add( new  Graviton(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 250, owner.playerColor, 8000, owner.angle, 0, 0, damage, 2));
    }
  }

  @Override
    void press() {
    if (cooldown<stampTime && (!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      enableCooldown();
      deActivate();
    }
  }
  @Override
    void reset() {
    super.reset();
    owner.armor=0;
  }
  void passive() {
    float c =((cooldown>stampTime)?int(cooldownTimer-(cooldown-stampTime)):cooldownTimer)*0.15;
    r+=(abs(owner.vx)+abs(owner.vy))+2;
    //stroke(owner.playerColor);
    stroke(255);
    noFill();
    bezier(int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), int(owner.x+owner.w*0.5)+cos(radians(r+50+180))*100, int(owner.y+owner.h*0.5)+sin(radians(r+50+180))*100, int(owner.x+owner.w*0.5)+cos(radians(r+180))*c, int(owner.y+owner.h*0.5)+sin(radians(r+180))*c);

    bezier(int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), int(owner.x+owner.w*0.5)+cos(radians(r+50))*100, int(owner.y+owner.h*0.5)+sin(radians(r+50))*100, int(owner.x+owner.w*0.5)+cos(radians(r))*c, int(owner.y+owner.h*0.5)+sin(radians(r))*c);
  }
}

class Ram extends Ability {//---------------------------------------------------    DeployElectron   ---------------------------------
  int boostSpeed=32;
  float sustainSpeed=1.5, damage= .4, speed;
  Ram() {
    super();
    name=getClassName(this);
    activeCost=15;
    channelCost=0.22;
    energy=50;
    regenRate=0.3;
  } 
  @Override
    void action() {
    active=true;
    //owner.damage=damage;
    owner.pushForce(boostSpeed, owner.keyAngle);
    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 150, 22, 150, owner.playerColor));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
        deActivate();
        active=false;
      }
      channel();
      owner.pushForce(sustainSpeed, owner.keyAngle);
      // speed = int(abs(owner.vx)+abs(owner.vy));
      // owner.damage=damage/2;
      // owner.damage=speed;
      particles.add(new Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-speed, speed), random(-speed, speed), int(random(20)+10), 150, owner.playerColor));
      particles.add(new RShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 175, 14, 175, owner.playerColor));
    }
  }

  void passive() {
    speed = int(abs(owner.vx)+abs(owner.vy));
    owner.damage=int(speed*damage);
    stroke(owner.playerColor);
    strokeWeight(3);
    noFill();
    pushMatrix();
    translate(owner.x+owner.w*.5+cos(radians(owner.angle))*50, owner.y+owner.w*.5+sin(radians(owner.angle))*50);
    rotate(radians(owner.angle-90));
    triangle(speed*.5*2, 0, 0, speed*4, -speed*.5*2, 0);
    popMatrix();
  }

  void reset() {
    super.reset();
    energy=50;
    owner.damage=1;
  }
  void release() {
    owner.damage=1;
    deActivate();
  }
}
class DeployTurret extends Ability {//---------------------------------------------------    DeployElectron   ---------------------------------
  int damage=50, range=75, turretLevel=0;
  Turret currentTurret;
  ArrayList<Turret> turretList= new  ArrayList<Turret>();
  DeployTurret() {
    super();
    name=getClassName(this);
    activeCost=25;
    energy=25;
    regenRate=0.25;
  } 
  @Override
    void action() {

    switch(turretLevel) { 
      /*  case 0:
       currentTurret=new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 100, new CloneMultiply());
       break;*/
    case 1:
      currentTurret=new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 200, new Battery());
      turretList.add(currentTurret);
      players.add(currentTurret);
      break;
    case 2:
      currentTurret=new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 300, new TimeBomb());
      turretList.add(currentTurret);
      players.add(currentTurret);
      break;
    case 3:
      currentTurret=new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 400, new Bazooka());
      turretList.add(currentTurret);
      players.add(currentTurret);
      break;
    case 4:
      currentTurret=new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 500, new Laser());
      turretList.add(currentTurret);
      players.add(currentTurret);
      break;
    }

    activeCost=25;
    turretLevel=0;
  }
  @Override
    void activate() { 

    super.activate();
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();

      action();
      deActivate();
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
    //arc(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5),150,150, 0+turretLevel*PI*2/4, PI*2/4+turretLevel*PI*2/4);
    // arc(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5),150,150,radians(90),120);

    for (int i = 0; i < turretLevel; i++) {
      arc(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 130, 130, 0+i*PI*0.5+(PI*0.05), PI*0.5+i*PI*0.5-(PI*0.05));
    }
    activeCost=energy-1;
  }
  @Override
    void reset() {
    super.reset();
    players.remove(turretList);
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
  @Override
    void action() {
    bomb = new  DetonateBomb(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 60000, owner.angle, 0, 0, damage, true);
    projectiles.add(bomb);
  }

  @Override
    void press() {
    if ( bomb!= null && !bomb.dead && bomb.deathTime>stampTime) {
      bomb.deathTime=stampTime;
      owner.pushForce(25, degrees(atan2((owner.y+owner.w*0.5)-bomb.y, (owner.x+owner.w*0.5)-bomb.x)));
      //bomb.detonate();
      particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, 16, 50, owner.playerColor));
    } else if ((!reverse|| owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)   ) {
      // stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
  void reset() {
    super.reset();
    projectiles.remove(bomb);
  }
}
class Random extends Ability {//---------------------------------------------------    Random   ---------------------------------
  //int damage=24;
  Random() {
    super();
  } 
  Ability randomize() {
    Ability rA=null;
    try {
      rA = abilityList[int(random(abilityList.length))].clone();
    }
    catch(CloneNotSupportedException e) {
      println("not cloned from Random");
    }
    return rA;  // clone it
  }
}