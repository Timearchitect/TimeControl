
static String getClassName(Object o) {
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
  Ability() { 
    //name=this.getClass().getSimpleName();
    //name=this.getClass().getCanonicalName();

    //name=this.getClass().getSimpleName();
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
  }
  void release() {
  }
  void hold() {
  }
  void action() {
  }
  void onHit() {
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
      deActivate();
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
    void deActivate() {
    super.deActivate();
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
      deActivate();
    }
  }
  @Override
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
        line(owner.cx+ cos(radians(-90-i))*80, owner.cy+sin(radians(-90-i))*80, owner.cx+ cos(radians(-90-i))*130, owner.cy+sin(radians(-90-i))*130);
      }
      text(displayTime, owner.cx, owner.y-owner.h*1);
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
  final int damage=16, slashdamage2=2, threashold =2;
  final int slashDuration=190, slashRange=100, slashdamage=4;
  boolean alternate;
  ThrowDagger() {
    super();
    name=getClassName(this);
    activeCost=8;
    regenRate=0.16;
  } 
  @Override
    void action() {
    if (abs(owner.vx)>threashold  ||  abs(owner.vy)>threashold) {
      if (abs(owner.keyAngle-owner.angle)<5) {
        if (alternate) {
          projectiles.add( new IceDagger(owner, int( owner.cx+cos(radians(owner.keyAngle-45))*75), int(owner.cy+sin(radians(owner.keyAngle-45))*75), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, int(damage*1.2)));
          projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 120, owner.angle+100, 24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
        } else {
          projectiles.add( new IceDagger(owner, int( owner.cx+cos(radians(owner.keyAngle+45))*75), int(owner.cy+sin(radians(owner.keyAngle+45))*75), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, int(damage*1.2)));
          projectiles.add( new Slash(owner, int( owner.cx+sin(owner.keyAngle)*50), int(owner.cy+cos(owner.keyAngle)*50), 30, owner.playerColor, 120, owner.angle-100, -24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
        }
      } else {
        if (alternate) {
          projectiles.add( new ArchingIceDagger(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 1000, owner.keyAngle, (owner.keyAngle-owner.angle)*8, owner.ax*24, owner.ay*24, damage));
          projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 120, owner.angle+100, 24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
        } else { 
          projectiles.add( new ArchingIceDagger(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 1000, owner.keyAngle, (owner.keyAngle-owner.angle)*8, owner.ax*24, owner.ay*24, damage));
          projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 120, owner.angle-100, -24, 80, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage2, true));
        }
      }
      alternate=!alternate;
    } else {
      owner.pushForce(-13, owner.angle);
      // for (int i=0; i<360; i+=10) {
      //  projectiles.add( new ArchingIceDagger(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 1000, owner.angle, owner.angle+90, sin(radians(i))*20, -cos(radians(i))*20, damage));
      //}

      projectiles.add( new ArchingIceDagger(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 1000, owner.angle, owner.angle, sin(radians(owner.angle+140))*20, -cos(radians(owner.angle+140))*20, damage*2));
      projectiles.add( new ArchingIceDagger(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 1000, owner.angle, owner.angle+180, sin(radians(owner.angle+40))*20, -cos(radians(owner.angle+40))*20, damage*2));
      projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, int(slashDuration), owner.angle+90, 22, slashRange, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage, true));
      projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, int(slashDuration), owner.angle-90, -22, slashRange, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, slashdamage, true));
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
class Pistol extends Ability {//---------------------------------------------------    Revolver   ---------------------------------
  final int damage=14;
  int r;
  float accuracy=1, MODIFIED_ANGLE_FACTOR=0.2;
  Pistol() {
    super();
    name=getClassName(this);
    activeCost=maxEnergy;
    maxAmmo=12;
    ammo=maxAmmo;
    cooldownTimer=240;
    regenRate=0.24;
  } 
  @Override
    void action() {
    if (energy>=maxEnergy)
      projectiles.add( new RevolverBullet(owner, int( owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 85, 12, owner.playerColor, 1000, owner.angle, damage));

    else
      projectiles.add( new RevolverBullet(owner, int( owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 75, 10, owner.playerColor, 1000, owner.angle, damage));

    particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 20, 32, 55, WHITE));
    owner.pushForce(-5, owner.angle);
    owner.angle+=random(-90, 90);
    ammo--;
    r=30;
  }

  @Override
    void press() {
    // particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
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
    strokeWeight(3);
    stroke(owner.playerColor);
    noFill();
    for (int i=0; i< ammo; i++)line(owner.cx-20, owner.cy+50+i*8, owner.cx+20, owner.cy+50+i*8);
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
}
class Revolver extends Ability {//---------------------------------------------------    Revolver   ---------------------------------
  final int damage=38;
  int r;
  float accuracy=1, MODIFIED_ANGLE_FACTOR=0.18;
  Revolver() {
    super();
    name=getClassName(this);
    activeCost=maxEnergy;
    maxAmmo=6;
    ammo=maxAmmo;
    cooldownTimer=240;
    regenRate=0.26;
  } 
  @Override
    void action() {
    if (energy>=maxEnergy)  projectiles.add( new RevolverBullet(owner, int( owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 65, 30, owner.playerColor, 1000, owner.angle, damage*1.2));
    else projectiles.add( new RevolverBullet(owner, int( owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 60, 25, owner.playerColor, 1000, owner.angle, damage));
    particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 30, 32, 75, owner.playerColor));
    projectiles.add( new  Blast(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 5, 100, owner.playerColor, 50, owner.angle, damage));

    owner.pushForce(-13, owner.angle);
    owner.angle+=random(-180, 180);
    owner.pushForce(4, owner.keyAngle);
    ammo--;
    r=30;
  }

  @Override
    void press() {
    // particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
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
      ellipse(owner.cx+cos(radians(i))*90, owner.cy+sin(radians(i))*90, 40, 40);
    }
    fill(owner.playerColor);
    for (int i =0; i<=maxAmmo; i++) {
      if (ammo>i)ellipse(owner.cx+cos(radians(i*360/maxAmmo-r))*90, owner.cy+sin(radians(i*360/maxAmmo-r))*90, 30, 30);
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
}
class ForceShoot extends Ability {//---------------------------------------------------    forceShoot   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=60;
  final int damageFactor=4;
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
      particles.add(new Flash(100, 6, WHITE)); 
      particles.add(new Gradient(1000, int(owner.cx), int(owner.cy), 0, 0, 4, 100, owner.angle, owner.playerColor));
      shakeTimer+=10;
    }
    projectiles.add( new forceBall(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), forceAmount*2+4, 30, owner.playerColor, 2000, owner.angle, forceAmount*damageFactor));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity) && energy>(0+activeCost)&& !hold && !active && !channeling && !owner.dead) {
      activate();
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
        restForce = MAX_FORCE-forceAmount;
        forceAmount+=ChargeRate*timeBend; 
        particles.add(new RParticles(int(owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), random(-restForce*0.5, restForce*0.5), random(-restForce*0.5, restForce*0.5), int(random(30)+10), 200, owner.playerColor));
        particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), int(forceAmount*.5), 16, int(forceAmount*.5), owner.playerColor));
      } else {
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
      fill(255);
      pushMatrix();
      translate(int(owner.cx), int(owner.cy));
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
        energy+=activeCost;
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
  @Override
    void action() {
    for (int i=0; i<5; i++) {
      particles.add(new Particle(int(owner.cx), int(owner.cy), random(-10, 10), random(-10, 10), int(random(20)+5), 800, 255));
    }
    // stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    try {
      switch(dir%4) {
      case 0:
        currentClone=new Player(players.size()-1, owner.playerColor, int(owner.x-cos(radians(owner.angle))*range), int(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.down, owner.up, owner.right, owner.left, owner.triggKey, new CloneMultiply(), owner.abilityList.get(1).clone());
        break;
      case 1:
        currentClone=new Player(players.size()-1, owner.playerColor, int(owner.x-cos(radians(owner.angle))*range), int(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.right, owner.left, owner.up, owner.down, owner.triggKey, new CloneMultiply(), owner.abilityList.get(1).clone());
        break;
      case 2:
        currentClone=new Player(players.size()-1, owner.playerColor, int(owner.x-cos(radians(owner.angle))*range), int(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.up, owner.down, owner.left, owner.right, owner.triggKey, new CloneMultiply(), owner.abilityList.get(1).clone());
        break;
      case 3:
        currentClone=new Player(players.size()-1, owner.playerColor, int(owner.x-cos(radians(owner.angle))*range), int(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.left, owner.right, owner.down, owner.up, owner.triggKey, new CloneMultiply(), owner.abilityList.get(1).clone());
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
    stamps.add( new StateStamp(players.size()-1, int(owner.x), int(owner.y), owner.state, owner.health, true));
    currentClone.dead=false;
    currentClone.maxHealth=int(owner.maxHealth*0.5);
    currentClone.health=int(owner.health*0.5);
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
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
  @Override
    void action() {
    //projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 75, owner.playerColor, 1000, owner.angle, 0, 0, damage, false));
    for (int i=0; i<10; i++) {
      particles.add(new Particle(int(owner.cx), int(owner.cy), random(-10, 10), random(-10, 10), int(random(20)+5), 800, 255));
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
    void reset() {
    super.reset();
    //if (owner.turret || owner.clone) players.remove( owner);
    //for (TimeStamp s:stamps )if(s.playerIndex==players.indexOf(owner))stamps.remove(players.indexOf(owner));


    /* for (int i =players.size()-1; i>= 0; i--) {
     if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
     }*/
  }
  @Override
    void onDeath() {
    if ((!reverse || owner.reverseImmunity)&&  owner.health<=0 && (!freeze || owner.freezeImmunity)) {
      projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 120, owner.playerColor, 1000, owner.angle, owner.vx, owner.vy, damage, false));
    }
  }
}

class Stealth extends Ability {//---------------------------------------------------    Stealth   ---------------------------------
  int projectileDamage=12, wait;
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
        particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
        projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, int(duration), owner.angle, 24, range, 0, 0, int(projectileDamage+wait*0.1), true));
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
    energy=110;
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
      projectiles.add( new Slash(owner, int( owner.cx+cos(radians(owner.angle))*75), int(owner.cy+sin(radians(owner.angle))*75), 30, owner.playerColor, 130, owner.angle-100, -24, 100, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, int(damage*0.4), true));
      owner.pushForce(5, owner.angle);
      if (!freeze ) {
        projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle+30))*150), int(owner.cy+sin(radians(owner.angle+30))*150), owner.playerColor, 325, owner.angle-90+30, damage, int(cos(radians(owner.angle+30))*125), int(sin(radians(owner.angle+30))*125)));
        projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle))*150), int(owner.cy+sin(radians(owner.angle))*150), owner.playerColor, 350, owner.angle-90, damage, int(cos(radians(owner.angle))*125), int(sin(radians(owner.angle))*125)));
        projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle-30))*150), int(owner.cy+sin(radians(owner.angle-30))*150), owner.playerColor, 375, owner.angle-90-30, damage, int(cos(radians(owner.angle-30))*125), int(sin(radians(owner.angle-30))*125)));
      } else {
        projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle+30))*150), int(owner.cy+sin(radians(owner.angle+30))*150), owner.playerColor, 325, owner.angle-90+30, damage));
        projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle))*150), int(owner.cy+sin(radians(owner.angle))*150), owner.playerColor, 350, owner.angle-90, damage));
        projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle-30))*150), int(owner.cy+sin(radians(owner.angle-30))*150), owner.playerColor, 375, owner.angle-90-30, damage));
      }
      break;
    case 2:
      projectiles.add( new Slash(owner, int( owner.cx+cos(radians(owner.angle))*65), int(owner.cy+sin(radians(owner.angle))*65), 32, owner.playerColor, 130, owner.angle+100, 24, 130, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, int(damage*0.6), true));
      owner.pushForce(20, owner.angle);
      particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 175, owner.playerColor));

      break;
    case 3:
      projectiles.add( new Slash(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 500, owner.angle+200, -25, 175, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, int(damage*0.9), true));
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

class Laser extends Ability {//---------------------------------------------------    Laser   ---------------------------------
  int damage=3, duration=2400, delay=500, laserWidth=75, chargelevel;
  long timer;
  float MODIFIED_ANGLE_FACTOR=0, MODIFIED_MAX_ACCEL=0.006; 
  long startTime;
  boolean charging;
  ArrayList<Projectile> laserList = new ArrayList<Projectile>();

  Laser() {
    super();
    name=getClassName(this);
    activeCost=24;
  } 
  @Override
    void action() {
    timer=millis();
    chargelevel++;
    particles.add(new Gradient(150*chargelevel, int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 75*chargelevel, 6*chargelevel, owner.angle, owner.playerColor));
    particles.add(new RShockWave(int(owner.cx), int(owner.cy), 270*chargelevel, 16+10*chargelevel, 150*chargelevel, owner.playerColor));
    charging=true;
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
      // particles.add(new  Gradient(1000,int(owner.cx +cos(radians(owner.angle))*owner.radius), int(owner.cy+sin(radians(owner.angle))*owner.radius), 0, 0, 3, owner.angle, owner.playerColor));
    }
  }
  void passive() {
    if (charging && (timer+delay/S/F)<millis()) {
      particles.add(new ShockWave(int(owner.cx), int(owner.cy), 200*chargelevel, 16, 500, owner.playerColor));
      particles.add(new Flash(50, 6, WHITE)); 

      Projectile l =new ChargeLaser(owner, int( owner.cx+random(50, -50)), int(owner.cy+random(50, -50)), laserWidth*chargelevel, owner.playerColor, duration, owner.angle, damage*chargelevel);
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
    deActivate();
    timer=0;
    super.reset();
  }
}
class Shotgun extends Ability {//---------------------------------------------------    Shotgun   ---------------------------------
  int damage=4, duration=900, delay=300, laserWidth=75, chargelevel;
  long timer;
  float MODIFIED_ANGLE_FACTOR=0.5, MODIFIED_MAX_ACCEL=0.006; 
  long startTime;
  boolean charging;
  Shotgun() {
    super();
    name=getClassName(this);
    activeCost=30;
    regenRate=0.23;
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
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
  void passive() {
    if (charging && (timer+delay/S/F)<millis()) {
      //particles.add(new ShockWave(int(owner.cx), int(owner.cy), 200*chargelevel, 16, 500, owner.playerColor));
      //particles.add(new Flash(50, 6, WHITE)); 
      projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 40, owner.playerColor, 1, owner.angle, cos(radians(owner.angle))*20, sin(radians(owner.angle))*20, damage, false));
      projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 50, 100, owner.playerColor, 200, owner.angle, damage));
      projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 20, 200, owner.playerColor, 200, owner.angle, damage));

      for (int i=0; i<8; i++) { //!!!
        float InAccurateAngle=random(-35, 35), shotSpeed=random(30, 80);
        projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*shotSpeed, sin(radians(owner.angle+InAccurateAngle))*shotSpeed, damage));
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
    regenRate=0.23;
    energy=maxEnergy*0.5;
  } 
  @Override
    void action() {
    owner.pushForce(-8, owner.angle);
    //if (int(random(5))!=0) {
    if (energy<maxEnergy-activeCost) {
      projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, int(random(500, 2000)), owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, true));
    } else {
      projectiles.add( new Mine(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 80000, owner.angle, cos(radians(owner.angle))*shootSpeed*0.5, sin(radians(owner.angle))*shootSpeed*0.5, damage, true));
      particles.add(new Particle(int(owner.cx+cos(radians(owner.angle))*325), int(owner.cy+sin(radians(owner.angle))*325), 0, 0, 100, 300, BLACK));
    }
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
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
    }
  }
}


class ElemetalLauncher extends Ability {//---------------------------------------------------    Bazooka   ---------------------------------
  int  damage=28, shootSpeed=30, ammoType=0, maxAmmotype=6;
  float MODIFIED_MAX_ACCEL=0.1; 
  Containable payload[];
  ElemetalLauncher() {
    super();
    cooldownTimer=500;
    name=getClassName(this);
    activeCost=25;
    regenRate=0.2;
    energy=130;
  } 
  @Override
    void action() {
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
    particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    switch(ammoType%maxAmmotype) {

    case 5:
      Container iceRocket= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 500, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
      payload=new Containable[10];
      for (int i=0; i<10; i++) {
        payload[i] =new IceDagger(owner, 0, 0, 20, owner.playerColor, 2000, owner.angle, random(40)-20+cos(radians(owner.angle))*shootSpeed*1.2, random(40)-20+sin(radians(owner.angle))*shootSpeed*1.2, int(damage*.4)).parent(iceRocket);
      }
      iceRocket.contains(payload);
      projectiles.add((Projectile)iceRocket);
      break;
    case 2:
      Container thunderRocket= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 700, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
      payload=new Containable[6];
          for (int i=0; i<6; i++) {
          payload[i] =new Thunder(owner, int(random(800)-400), int(random(800)-400), 200, color(owner.playerColor), 500+(150*i), 0, 0, 0, int(damage*2), 0).parent(thunderRocket);
      }

      thunderRocket.contains(payload);
      projectiles.add((Projectile)thunderRocket);
      break;
    case 3:
      Container rockRocket= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*shootSpeed*.5+owner.vx, sin(radians(owner.angle))*shootSpeed*.5+owner.vy, damage, false);
      payload=new Containable[1];
      payload[0]= new Block(players.size(), owner, 0,0, 200, 200, 200,new Armor()).parent(rockRocket);
      rockRocket.contains(payload);
      projectiles.add((Projectile)rockRocket);
      break;
      
          case 4:
      Container natureRocket= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 700, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false);
      payload=new Containable[1];
      payload[0]= new  Heal(owner, 0,0, 400, owner.playerColor, 10000, 0,1, 1, 4, true).parent(natureRocket) ;
  
      natureRocket.contains(payload);
      projectiles.add((Projectile)natureRocket);
      break;
    default:

      Container fireRocket= new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 500, owner.angle, cos(radians(owner.angle))*shootSpeed*1.5+owner.vx, sin(radians(owner.angle))*shootSpeed*1.5+owner.vy, damage, false);
      payload=new Containable[11];

      for (int i=0; i<10; i++) {
        payload[i]= new  Blast(owner, int(cos(radians(i*36))*120), int(sin(radians(i*36))*120), 15, 100, owner.playerColor, 400, i*36, 1, 15).parent(fireRocket);
      }
      payload[10]= new  Blast(owner, 0, 0, 0, 600, owner.playerColor, 400, 0, 1, 20).parent(fireRocket);
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

    fill(255);
    switch(ammoType%maxAmmotype) {
    case 0:
      text("WATER", int(owner.cx), int(owner.cy-90));
      break;
    case 1:
      text("FIRE", int(owner.cx), int(owner.cy-90));
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
    }
    owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
  }
  @Override
    void press() {
    //(!reverse || owner.reverseImmunity)
    if (cooldown<stampTime &&(!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      enableCooldown();
      activate();
      action();
      deActivate();
    }
  }
  @Override
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
  float MODIFIED_MAX_ACCEL=0.06; 
  Bazooka() {
    super();
    cooldownTimer=1000;
    name=getClassName(this);
    activeCost=22;
    regenRate=0.13;
    energy=130;
  } 
  @Override
    void action() {
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
    particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    switch(ammoType%maxAmmotype) {

    case 0:
      projectiles.add( new RCRocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 2500, owner.angle, 0, cos(radians(owner.angle))*shootSpeed*.02+owner.vx, sin(radians(owner.angle))*shootSpeed*.02+owner.vy, damage, false));
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
      sr.count=90;
      projectiles.add( sr);
      sr= new SinRocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 2500, owner.angle, cos(radians(owner.angle))*shootSpeed*.01+owner.vx, sin(radians(owner.angle))*shootSpeed*.01+owner.vy, damage*2, false);
      sr.count=275;
      projectiles.add( sr);
      break;
    case 3:
      projectiles.add( new Missle(owner, int( owner.cx), int(owner.cy), 30, owner.playerColor, 7000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, false));

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
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      enableCooldown();
      activate();
      action();
      deActivate();
    }
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

class Stars extends Ability {//---------------------------------------------------    Bazooka   ---------------------------------
  int  damage=15, shootSpeed=8;
  float MODIFIED_MAX_ACCEL=0.04; 
  Stars() {
    super();
    cooldownTimer=1000;
    name=getClassName(this);
    activeCost=32;
    regenRate=0.17;
    energy=130;
  } 
  @Override
    void action() {
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(int(owner.cx), int(owner.cy), 50, 16, 500, owner.playerColor));
    // particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    for (int i=0; i<359; i+=40) {
      projectiles.add( new RCRocket(owner, int( owner.cx+cos(radians(owner.angle+i))*50), int(owner.cy+sin(radians(owner.angle+i))*50), 10, owner.playerColor, 1700, owner.angle+i, i, cos(radians(owner.angle+i))*shootSpeed*.02+owner.vx, sin(radians(owner.angle+i))*shootSpeed*.02+owner.vy, damage, false));
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
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      enableCooldown();
      activate();
      action();
      deActivate();
    }
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

class RapidFire extends Ability {//---------------------------------------------------    RapidFire   ---------------------------------
  float accuracy = 1, MODIFIED_ANGLE_FACTOR=-0.0008, r=50  ;
  int Interval=110;
  long  PastTime;
  int projectileDamage=5;
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
      projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
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
      projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
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
    channelCost=0.2;
    accuracy = 0;
    projectileDamage=6;
    cooldownTimer=900;
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
      channel();
      if (!active || energy<0 ) {
        release();
        //if(sutainCount>10)sutainCount-=10;
      }
      PastTime=stampTime;
      alt++;
      if (alt%3==0) {
        e=retractLength;
        projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w+cos(radians(owner.angle+90))*17), int(owner.cy+sin(radians(owner.angle))*owner.w+sin(radians(owner.angle+90))*17), 60, owner.playerColor, 600, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage));
        particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*100+cos(radians(owner.angle+90))*17), int(owner.cy+sin(radians(owner.angle))*100+sin(radians(owner.angle+90))*17), 0, 0, 50, 50, WHITE));
      } else if (alt%3==1) {
        r=retractLength;
        projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w+cos(radians(owner.angle-90))*17), int(owner.cy+sin(radians(owner.angle))*owner.w+sin(radians(owner.angle-90))*17), 60, owner.playerColor, 600, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage));
        particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*100+cos(radians(owner.angle-90))*17), int(owner.cy+sin(radians(owner.angle))*100+sin(radians(owner.angle-90))*17), 0, 0, 50, 50, WHITE));
      } else {  
        projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 600, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage));
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
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 0, 0, 100, 50, color(255, 0, 255)));

        owner.pushForce(8, owner.angle+180);

        for (int i=0; sutainCount/8>i; i++) {
          float InAccurateAngle=random(-accuracy*2, accuracy*2);
          projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 700, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*projectileSpeed, sin(radians(owner.angle+InAccurateAngle))*projectileSpeed, projectileDamage*2));
        }
        owner.angle+=random(-90, 90);
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
    line(owner.cx+cos(radians(owner.angle+90))*offset, owner.cy+sin(radians(owner.angle+90))*offset, owner.cx+cos(radians(owner.angle))*e+cos(radians(owner.angle+90))*offset, owner.cy+sin(radians(owner.angle))*e+sin(radians(owner.angle+90))*offset);
    line(owner.cx+cos(radians(owner.angle))*offset, owner.cy+sin(radians(owner.angle))*offset, owner.cx+cos(radians(owner.angle))*t+cos(radians(owner.angle))*offset, owner.cy+sin(radians(owner.angle))*t+sin(radians(owner.angle))*offset);
    line(owner.cx+cos(radians(owner.angle-90))*offset, owner.cy+sin(radians(owner.angle-90))*offset, owner.cx+cos(radians(owner.angle))*r+cos(radians(owner.angle-90))*offset, owner.cy+sin(radians(owner.angle))*r+sin(radians(owner.angle-90))*offset);
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
    projectileDamage=210;
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
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;

        float tempA=random(-inAccurateAngle, inAccurateAngle);
        projectiles.add( new SniperBullet(owner, int( owner.cx+cos(radians(tempA+owner.angle))*nullRange), int(owner.cy+sin(radians(tempA+owner.angle))*nullRange), 50, owner.playerColor, 10, owner.angle+tempA, int(projectileDamage-inAccurateAngle*2)));

        owner.pushForce(-12, owner.angle);
        shakeTimer+=15; 
        inAccurateAngle=startAccuracy;
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
  int  maxInterval=5, damage=7, count=0, maxCount=6;
  float  accuracy=10, interval, MODIFIED_ANGLE_FACTOR=0.02;

  Battery() {
    super();
    name=getClassName(this);
    activeCost=24;
    regenRate=0.11;
  } 

  @Override
    void action() {
    //projectiles.add(charge.get(count));
    float inAccuracy;
    inAccuracy =random(-accuracy, accuracy);
    switch(count) {
    case 0:
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*20, sin(radians(owner.angle+inAccuracy))*20, damage));        
      break;
    case 1:
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*25, sin(radians(owner.angle+inAccuracy))*25, damage));        
      break;
    case 2:
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*30, sin(radians(owner.angle+inAccuracy))*30, damage));        
      break;     
    case 3:
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*35, sin(radians(owner.angle+inAccuracy))*35, damage));        
      break;
    case 4:
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*40, sin(radians(owner.angle+inAccuracy))*40, damage));        
      break;
    case 5:
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*45, sin(radians(owner.angle+inAccuracy))*45, damage));        
      break;
    default:
      for (int i=0; i<4; i++) {
        inAccuracy =random(-accuracy*2, accuracy*2);
        projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*40, sin(radians(owner.angle+inAccuracy))*40, damage));
      }
      projectiles.add( new  Blast(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 5, 150, owner.playerColor, 75, owner.angle, damage));

      projectiles.add( new RevolverBullet(owner, int( owner.cx+cos(radians(owner.angle))*50), int(owner.cy+sin(radians(owner.angle))*50), 60, 25, owner.playerColor, 1000, owner.angle, damage));

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
      interval+=1*timeBend;
    }
  }
}
class AssaultBattery extends Ability {//---------------------------------------------------    Battery   ---------------------------------
  int  maxInterval=6, damage=25, count=0, maxCount=14, flip=1;
  float  inAccuarcy=90, accuracy=inAccuarcy, interval, MODIFIED_ANGLE_FACTOR=0.001, MODIFIED_MAX_ACCEL=0.05; 

  AssaultBattery() {
    super();
    name=getClassName(this);
    activeCost=45;
    regenRate=0.19;
  } 

  @Override
    void action() {
    strokeWeight(1400);
    stroke(owner.playerColor);
    if (flip==1) {
      arc(owner.cx, owner.cy, 1500, 1500, radians(owner.angle-accuracy*.6), radians(owner.angle));
    } else {
      arc(owner.cx, owner.cy, 1500, 1500, radians(owner.angle), radians(owner.angle+accuracy*.6));
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
      accuracy*=0.82;
      accuracy--;
    }

    projectiles.add( new SniperBullet(owner, int( owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 50, owner.playerColor, 10, owner.angle, int(damage)));
    owner.pushForce(-.5, owner.angle);

    if (count>=maxCount) {
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      owner.MAX_ACCEL= owner.DEFAULT_MAX_ACCEL;
      accuracy=inAccuarcy;
      regen=true;
    }
    particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 5, 10+5*count, 20, WHITE));
    owner.pushForce(-2, owner.angle);
  }

  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {

      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=false;
      owner.angle+= flip*accuracy*.75;
      activate();
      // action();
    }
    if ((!reverse || owner.reverseImmunity)&& energy<20 && !owner.dead && !active&& (!freeze || owner.freezeImmunity)) {
      projectiles.add( new SniperBullet(owner, int( owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 70, owner.playerColor, 20, owner.angle, int(damage*1.5)));
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      // owner.angle+= flip*accuracy*.75;
      // activate();
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
    damage=9;  
    maxCount=3;
    MODIFIED_ANGLE_FACTOR=0.02;
    activeCost=10;
    regenRate=0.13;
  } 

  @Override
    void action() {
    //projectiles.add(charge.get(count));
    float inAccuracy;
    inAccuracy =random(-accuracy, accuracy);
    switch(count) {
    case 0:
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*75, sin(radians(owner.angle+inAccuracy))*75, damage));        
      particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*105), int(owner.cy+sin(radians(owner.angle))*105), 5, 22, 20, WHITE));
      accuracy+=swayRate;
      break;
    case 1:
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*70, sin(radians(owner.angle+inAccuracy))*70, damage));        
      particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*105), int(owner.cy+sin(radians(owner.angle))*105), 5, 22, 20, WHITE));
      accuracy+=swayRate;
      break;
    case 2:
      projectiles.add(new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*65, sin(radians(owner.angle+inAccuracy))*65, damage));        
      particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*105), int(owner.cy+sin(radians(owner.angle))*105), 5, 22, 20, WHITE));
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
      interval+=1*timeBend;
    } else     if (accuracy>0)accuracy--;
  }

  void reset() {
    super.reset();
    active=false;
  }
}

class MissleLauncher extends Ability {//---------------------------------------------------    MissleLauncher   ---------------------------------
  int interval, maxInterval=6, damage=17, offset=50, accuracy=10, count=0, maxCount=6, shootSpeed=34, duration=4000;
  float  MODIFIED_ANGLE_FACTOR=0.02;

  MissleLauncher() {
    super();
    cooldownTimer=2200;
    name=getClassName(this);
    activeCost=35;
    regenRate=0.12;
  } 

  @Override
    void action() {

    switch(count) {
    case 0:
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle+90))*50), int(owner.cy+sin(radians(owner.angle+90))*50), 30, owner.playerColor, duration, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, false));
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle+90))*50), int(owner.cy+sin(radians(owner.angle+90))*50), 0, 0, 50, 50, WHITE));

      break;
    case 1:
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle-90))*50), int(owner.cy+sin(radians(owner.angle-90))*50), 30, owner.playerColor, duration, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, false));
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle-90))*50), int(owner.cy+sin(radians(owner.angle-90))*50), 0, 0, 50, 50, WHITE));
      break;
    case 2:
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle+95))*50), int(owner.cy+sin(radians(owner.angle+95))*50), 30, owner.playerColor, duration, owner.angle+10, cos(radians(owner.angle+10))*shootSpeed, sin(radians(owner.angle+10))*shootSpeed, damage, false));
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle+90))*50), int(owner.cy+sin(radians(owner.angle+90))*50), 0, 0, 50, 50, WHITE));

      break;     
    case 3:
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle-95))*50), int(owner.cy+sin(radians(owner.angle-95))*50), 30, owner.playerColor, duration, owner.angle-10, cos(radians(owner.angle-10))*shootSpeed, sin(radians(owner.angle-10))*shootSpeed, damage, false));
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle-90))*50), int(owner.cy+sin(radians(owner.angle-90))*50), 0, 0, 50, 50, WHITE));

      break;
    case 4:
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle+100))*50), int(owner.cy+sin(radians(owner.angle+100))*50), 30, owner.playerColor, duration, owner.angle+20, cos(radians(owner.angle+20))*shootSpeed, sin(radians(owner.angle+20))*shootSpeed, damage, false));
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle-90))*50), int(owner.cy+sin(radians(owner.angle-90))*50), 0, 0, 50, 50, WHITE));

      break;
    case 5:
      projectiles.add( new Missle(owner, int( owner.cx+cos(radians(owner.angle-100))*50), int(owner.cy+sin(radians(owner.angle-100))*50), 30, owner.playerColor, duration, owner.angle-20, cos(radians(owner.angle-20))*shootSpeed, sin(radians(owner.angle-20))*shootSpeed, damage, false));
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
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();

      // action();
    }
  }

  @Override
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
}

class AutoGun extends Ability {//---------------------------------------------------    AutoGun   ---------------------------------

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
    if ((!reverse || owner.reverseImmunity) &&(!freeze || owner.freezeImmunity)&& energy>(0+activeCost) && !active && !channeling && !owner.dead) {
      activate();
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
          if (!p.dead && owner !=p && owner.ally!=p.ally) {

            if (amountP==alternate) {
              calcAngle(p);
              projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*60), int(owner.cy+sin(radians(owner.angle))*60), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*60, sin(radians(owner.angle))*60, damage));
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
  int damage=25, range=1000, minRange=400, maxSpanAngle=80;
  float spanAngle=5;
  ArrayList<Player> targets= new ArrayList<Player>() ;
  int amountOfTargets;
  SeekGun() {
    super();
    name=getClassName(this);
    activeCost=40;
    channelCost=0.05;
    regenRate=0.35;
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
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
        if (!p.dead && p.ally!=owner.ally && dist(owner.cx, owner.cy, p.cx, p.cy)<range+p.radius && dist(owner.cx, owner.cy, p.cx, p.cy)>minRange-p.radius
          && calcAngleBetween(p, owner)<= (owner.angle+spanAngle*.5)%360 &&calcAngleBetween(p, owner)>= (owner.angle-spanAngle*.5)%360  ) {
          if (!targets.contains(p)) {
            targets.add(p);
            particles.add(new ShockWave(int(p.cx), int(p.cy), 140, 22, 300, WHITE));
          }
        }
      }
      if (maxSpanAngle>spanAngle)spanAngle*=1.1;
      noFill();
      strokeWeight(range-minRange);
      stroke(owner.playerColor, 50);
      arc(owner.cx, owner.cy, range+minRange, range+minRange, radians(owner.angle-spanAngle*.5), radians(owner.angle+spanAngle*.5));
      strokeWeight(1);
      ellipse(owner.cx, owner.cy, range*2, range*2);
      ellipse(owner.cx, owner.cy, minRange*2, minRange*2);

      //particles.add(new ShockWave(int(owner.cx+cos(radians(owner.angle))*85), int(owner.cy+sin(radians(owner.angle))*85), 5, 22, 20, WHITE));
    }
  }
  @Override
    void passive() {
    //if (owner.angle<0){owner.angle+=360;owner.keyAngle+=360;}
    for (Player t : targets) {
      targetVarning(t);
    }
  }
  @Override
    void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        particles.add(new ShockWave(int(owner.cx), int(owner.cy), 150, 62, 400, WHITE));

        for (Player t : targets) {
          float tempAngle=calcAngleBetween(t, owner);
          HomingMissile p=new HomingMissile(owner, int( owner.cx+cos(radians(tempAngle))*50), int(owner.cy+sin(radians(tempAngle))*50), 60+30*targets.size(), owner.playerColor, 1400, owner.angle, cos(radians(owner.angle))*30, sin(radians(owner.angle))*30, damage+15*targets.size());
          p.angle=tempAngle;
          p.locking();  
          p.ReactionTime=5*targets.size();
          projectiles.add(p);
        }
        owner.stop();
        targets.clear();
        spanAngle=5;
        regen=true;
        action();
        deChannel();
        deActivate();
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      }
    }
  }
  float  calcAngleBetween(Player target, Player from) {
    return degrees(atan2((target.cy-from.cy), (target.cx-from.cx)))%360;
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
    spanAngle=5;
    regen=true;
    action();
    owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}



class ThrowBoomerang extends Ability {//---------------------------------------------------    Boomerang   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=64;
  float forceAmount=0, MODIFIED_MAX_ACCEL=0.04;
  float ChargeRate=1, restForce, recoveryEnergy;
  int damage=2, projectileSize=60;
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
    projectiles.add( new Boomerang(owner, int( owner.cx), int(owner.cy), projectileSize, owner.playerColor, int(300*forceAmount)+100, owner.angle, cos(radians(owner.angle))*(forceAmount+4), sin(radians(owner.angle))*(forceAmount+4), damage, recoveryEnergy, int(forceAmount*0.5+13)));
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
    // for (int i=0; i<2; i++) {
    particles.add(new Particle(int(owner.cx+cos(radians(owner.angle-90))*50), int(owner.cy+cos(radians(owner.angle-90))*50), random(10)-5+cos(radians(owner.angle-90))*10, random(10)-5+sin(radians(owner.angle-90))*10, int(random(20)+5), 800, 255));
    particles.add(new Particle(int(owner.cx+cos(radians(owner.angle+90))*50), int(owner.cy+cos(radians(owner.angle+90))*50), random(10)-5+cos(radians(owner.angle+90))*10, random(10)-5+sin(radians(owner.angle+90))*10, int(random(20)+5), 800, 255));
    // }   

    lockProjectiles.add(new HomingMissile(owner, int( owner.cx+cos(radians(owner.angle+100))*150), int(owner.cy+sin(radians(owner.angle+100))*150), 60, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
    lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
    lockProjectiles.get(lockProjectiles.size()-1).locking();
    projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
    lockProjectiles.add(new HomingMissile(owner, int( owner.cx+cos(radians(owner.angle+90))*120), int(owner.cy+sin(radians(owner.angle+90))*120), 70, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
    lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
    lockProjectiles.get(lockProjectiles.size()-1).locking();
    lockProjectiles.get(lockProjectiles.size()-1).ReactionTime=45;
    projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
    lockProjectiles.add(new HomingMissile(owner, int( owner.cx+cos(radians(owner.angle-90))*120), int(owner.cy+sin(radians(owner.angle-90))*120), 70, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
    lockProjectiles.get(lockProjectiles.size()-1).angle=owner.angle;
    lockProjectiles.get(lockProjectiles.size()-1).locking();
    lockProjectiles.get(lockProjectiles.size()-1).ReactionTime=45;
    projectiles.add(lockProjectiles.get(lockProjectiles.size()-1));
    lockProjectiles.add(new HomingMissile(owner, int( owner.cx+cos(radians(owner.angle-100))*150), int(owner.cy+sin(radians(owner.angle-100))*150), 60, owner.playerColor, 1400, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
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

          HomingMissile h= new HomingMissile(owner, int( owner.cx), int(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage);
          h.target=p;
          projectiles.add(h);
          customAngle=90;

          h= new HomingMissile(owner, int( owner.cx), int(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage);
          h.target=p;
          projectiles.add(h);
          customAngle=0;
        }
      }
    }

    customAngle=-90;
    projectiles.add( new HomingMissile(owner, int( owner.cx), int(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));

    customAngle=90;
    projectiles.add( new HomingMissile(owner, int( owner.cx), int(owner.cy), 70, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
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
    arc(owner.cx, owner.cy, r, r, radians(owner.angle+45), radians(owner.angle+45+90));
    arc(owner.cx, owner.cy, r, r, radians(owner.angle+225), radians(owner.angle+225+90));
  }
}

class DeployThunder extends TimeBomb {//---------------------------------------------------    DeployThunder   ---------------------------------

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
      projectiles.add( new Thunder(owner, int( owner.cx), int(owner.cy), 500, owner.playerColor, 4000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, int(damage*1.3), 6));
    } else {
      particles.add( new Text("!", int( owner.cx), int(owner.cy), 0, 0, 140, 0, 2000, BLACK, 1));
      particles.add( new Text("!", int( owner.cx), int(owner.cy), 0, 0, 180, 0, 2000, owner.playerColor, 0));
      projectiles.add( new Thunder(owner, int( owner.cx), int(owner.cy), 400, owner.playerColor, 2000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, 5));
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
       projectiles.add( new Shield( owner, int( owner.cx+cos(radians(owner.angle))*i), int(owner.cy+sin(radians(owner.angle))*i), owner.playerColor, 10000, owner.angle, damage ));
       }*/
      particles.add(new ShockWave(int(owner.cx), int(owner.cy), 300, 16, 90, WHITE));

      for (int i=0; i<360; i+=30) {
        projectiles.add( new Shield( owner, int( owner.cx+cos(radians(i))*195), int(owner.cy+sin(radians(i))*195), owner.playerColor, 2200, i+90, damage ));
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
    name=getClassName(this);
    activeCost=12;
  } 
  @Override
    void action() {
    if (energy>=maxEnergy-activeCost) {
      stored.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
      stored.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle+120, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
      stored.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle+240, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
    } else {
      stored.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle, -5, -5, damage ));
      projectiles.add(stored.get(stored.size()-1));
      stored.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle+180, -5, -5, damage ));
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
    strokeWeight(1);
    stroke(owner.playerColor);
    noFill();
    for (float i =0; i<=PI*2; i+=PI/6) {
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
    name=getClassName(this);
    activeCost=25;
    regenRate=.15;
    cooldownTimer=1000;
  } 
  @Override
    void action() {
    Graviton g;
    if (energy>=maxEnergy-activeCost) {
      g= new  Graviton(owner, int( owner.cx), int(owner.cy), 400, owner.playerColor, 12000, owner.angle, 0, 0, damage*3, 4);
    } else if (energy>=maxEnergy*.5) {
      g= new  Graviton(owner, int( owner.cx), int(owner.cy), 300, owner.playerColor, 10000, owner.angle, 0, 0, damage*2, 3);
    } else {
      g= new  Graviton(owner, int( owner.cx), int(owner.cy), 250, owner.playerColor, 8000, owner.angle, 0, 0, damage, 2);
    }
    gravitonList.add(g);
    projectiles.add(g);
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
    for (Graviton g : gravitonList) {
      g.deathTime=stampTime;
      g.dead=true;
    }
    gravitonList.clear();
  }
  void passive() {
    float c =((cooldown>stampTime)?int(cooldownTimer-(cooldown-stampTime)):cooldownTimer)*0.15;
    r+=(abs(owner.vx)+abs(owner.vy))+2;
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
  float sustainSpeed=1.5, damage= .4, speed;
  Ram() {
    super();
    name=getClassName(this);
    activeCost=10;
    channelCost=0.23;
    energy=50;
    regenRate=0.3;
    cooldownTimer=1000;
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
      projectiles.add(new Thunder(owner, int( owner.cx), int(owner.cy), 300, color(owner.playerColor), 0, 0, 0, 0, int(damage*10), 0) );

      particles.add(new ShockWave(int(owner.cx), int(owner.cy), 400, 22, 150, owner.playerColor));
    }
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
      particles.add(new Particle(int(owner.cx), int(owner.cy), random(-speed, speed), random(-speed, speed), int(random(20)+10), 150, owner.playerColor));
      particles.add(new RShockWave(int(owner.cx), int(owner.cy), 175, 14, 175, owner.playerColor));
    }
  }

  void passive() {
    speed = int(abs(owner.vx)+abs(owner.vy));
    owner.damage=int(speed*damage);
    stroke(owner.playerColor);
    strokeWeight(3);
    noFill();
    pushMatrix();
    translate(owner.cx+cos(radians(owner.angle))*50, owner.cy+sin(radians(owner.angle))*50);
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
    regenRate=0.16;
  } 
  @Override
    void action() {

    switch(turretLevel) { 
      /*  case 0:
       currentTurret=new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 100, new CloneMultiply());
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
      currentTurret=new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 400, new Laser());
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
    //arc(int(owner.cx), int(owner.cy),150,150, 0+turretLevel*PI*2/4, PI*2/4+turretLevel*PI*2/4);
    // arc(int(owner.cx), int(owner.cy),150,150,radians(90),120);

    for (int i = 0; i < turretLevel; i++) {
      arc(int(owner.cx), int(owner.cy), 130, 130, 0+i*PI*0.5+(PI*0.05), PI*0.5+i*PI*0.5-(PI*0.05));
    }
    activeCost=energy-1;
  }
  @Override
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
    regenRate=0.18;
  } 
  @Override
    void action() {

    currentDrone=new Drone(players.size(), owner, int(owner.x+cos(radians(owner.angle))*100), int(owner.y+sin(radians(owner.angle))*100), int(playerSize*0.5), int(playerSize*0.5), 20, 200, new AutoGun(), new RandomPassive().randomize() );
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
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();

      action();
      deActivate();
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
class DeployBodyguard extends DeployDrone {//---------------------------------------------------    DeployDrone  ---------------------------------
  int type;
  DeployBodyguard() {
    super();
    cooldownTimer=2000;
    name=getClassName(this);
    activeCost=80;
    energy=40;
    speed=10;
    regenRate=0.18;
  } 
  @Override
    void action() {

    currentDrone=new FollowDrone(players.size(), owner, int(owner.x+cos(radians(owner.angle))*100), int(owner.y+sin(radians(owner.angle))*100), int(playerSize*0.5), int(playerSize*0.5), 20, 100, type, new Combo(), new RandomPassive().randomize());
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
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action();
      deActivate();
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

class KineticPulse extends Ability {//---------------------------------------------------    KineticPulse   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=30, ChargeRate=0.4, MODIFIED_MAX_ACCEL=0.005, MODIFIED_ANGLE_FACTOR=0.03;
  final int radius=220;
  float forceAmount=0, restForce;
  int damage=74, distanceX, distanceY;

  KineticPulse() {
    super();
    name=getClassName(this);
    activeCost=22;
    cooldownTimer=1400;
    channelCost=0.01;
  } 
  @Override
    void action() {
    particles.add(new Flash(100, 6, WHITE)); 
    shakeTimer+=15;
    for (int i=45; i<360; i+= (360/4)) {
      particles.add( new Shock(170, distanceX, distanceY, 0, 0, 5, i, WHITE)) ;
    }
    particles.add(new ShockWave(distanceX, distanceY, 140, 90, 300, owner.playerColor));

    projectiles.add(new Thunder(owner, distanceX, distanceY, radius, color(owner.playerColor), 700, 0, 0, 0, int(damage), 4) );
    enableCooldown();
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&&(!freeze || owner.freezeImmunity) && energy>(0+activeCost)&& stampTime>cooldown  && !hold && !active && !channeling && !owner.dead) {
      activate();
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
          projectiles.add(new Thunder(owner, distanceX, distanceY, int(radius*.5), color(owner.playerColor), 900, 0, 0, 0, int(damage*.5), 1) );
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
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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
  } 
  @Override
    void action() {
    bomb = new  DetonateBomb(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 60000, owner.angle, 0, 0, damage, true);
    projectiles.add(bomb);
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
      deActivate();
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
    damage=1;
    shootSpeed=0;
    regenRate=0.43;
    name=getClassName(this);
    activeCost=10;
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

    projectiles.add( new CurrentLine(owner, int( owner.cx), int(owner.cy), range, owner.playerColor, duration, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage));

    if (energy>=maxEnergy-activeCost) {   
      // particles.add( new Text("!", int( owner.cx), int(owner.cy), 0, 0, 180, 0, 4000, BLACK, 1));
      //   projectiles.add( new Thunder(owner, int( owner.cx), int(owner.cy), 400, owner.playerColor, 2000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, 5));
    }
  }

  void  passive() {
    stroke(owner.playerColor);
    noFill();
    ellipse(owner.cx, owner.cy, range, range);

    //owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.6;
    if (stampTime>=duration+startTime) {
      owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    }
    if (range>owner.w*3)range-=15;
  }
  @Override
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
    regenRate=0.21;
    energy=maxEnergy*0.5;
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
      projectiles.add( new forceBall(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, 25, owner.playerColor, 2000, owner.angle, damage));

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
      projectiles.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle, -5, -5, damage ));
      projectiles.add( new Electron( owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 10000, owner.angle+180, -5, -5, damage ));

      break;
    case 7:
      projectiles.add( new ChargeLaser(owner, int( owner.cx+random(50, -50)), int(owner.cy+random(50, -50)), 100, owner.playerColor, 500, owner.angle, damage*0.08));
      owner.halt();
      break;
    case 8:
      projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, int(random(500, 2000)), owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage*2, true));

      break;
    case 9:
      projectiles.add( new RCRocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 2500, owner.angle, random(-10, 10), cos(radians(owner.angle))*shootSpeed*.02+owner.vx, sin(radians(owner.angle))*shootSpeed*.02+owner.vy, damage, false));

      break;
    case 10:
      projectiles.add( new Boomerang(owner, int( owner.cx), int(owner.cy), 80, owner.playerColor, int(300*50)+100, owner.angle, cos(radians(owner.angle))*(70+2), sin(radians(owner.angle))*(70+2), int(damage*0.07), 50, int(50*0.5+12)));
      break;

    case 11:
      projectiles.add( new SniperBullet(owner, int( owner.cx+cos(radians(owner.angle))*400), int(owner.cy+sin(radians(owner.angle))*400), 50, owner.playerColor, 10, owner.angle, int(damage*2)));

      break;
    case 12:
      projectiles.add( new Thunder(owner, int( owner.cx+cos(radians(owner.angle))*400), int(owner.cy+sin(radians(owner.angle))*400), 400, owner.playerColor, 1500, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage, 5));
      break;
    case 13:
      projectiles.add( new Rocket(owner, int( owner.cx), int(owner.cy), 50, owner.playerColor, 1000, owner.angle, cos(radians(owner.angle))*shootSpeed+owner.vx, sin(radians(owner.angle))*shootSpeed+owner.vy, damage, false));
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
    }
    if (energy<maxEnergy)choosenProjectileIndex= (int)random(17);
  }
  @Override
    void passive() {

    if (energy>=maxEnergy) {
      fill(owner.playerColor);
      text( description[choosenProjectileIndex], int( owner.cx), int(owner.cy)+100);
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
class FlameThrower extends Ability {//---------------------------------------------------    FlameThrower   ---------------------------------

  int alt, count, projectileDamage;
  float sutainCount, MAX_sutainCount=50, accuracy, MODIFIED_ANGLE_FACTOR=0.8, MODIFIED_MAX_ACCEL=0.1;
  FlameThrower() {
    super();
    name=getClassName(this);
    deactiveCost=0;
    activeCost=0;
    channelCost=0.23;
    accuracy = 20;
    projectileDamage=1;
    cooldownTimer=900;
    MODIFIED_ANGLE_FACTOR=0.035;
  } 
  void press() {
    super.press();
    if (!active) {
      active=true;
      projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 0, 75, owner.playerColor, 200, owner.angle, projectileDamage));
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
      if (sutainCount%2<1)projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 25+sutainCount, 75, owner.playerColor, 200, owner.angle+InAccurateAngle, int(projectileDamage+sutainCount*.02)));
      particles.add( new  Particle(int(owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 0, 0, 150, 50, color(255, 0, 255)));
    }
  }
  void hold() {

    if (cooldown<stampTime) {
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      action();
      // if (!active)press(); // cancel
      if (owner.hit)        if (sutainCount>10)sutainCount-=10;
      //release(); // cancel

      sutainCount+=0.3;
      if (sutainCount>MAX_sutainCount) {
        sutainCount=MAX_sutainCount;
        owner.pushForce(1, owner.angle+180);
      }
      accuracy=sutainCount*0.1;
    }
  }

  void release() {
    if ((!reverse || owner.reverseImmunity ) ) {
      if (!owner.dead && (!freeze || owner.freezeImmunity)&& active) {
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
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

  @Override
    void passive() {
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
class SummonEvil extends Ability {//---------------------------------------------------    SummonEvil   ---------------------------------
  int range=500, maxRange=1600, duration=350;
  float MODIFIED_MAX_ACCEL=0.01, damage=1; 
  long startTime;
  ArrayList<Player> enemies = new  ArrayList<Player>();

  SummonEvil() {
    super();
    regenRate=0.33;
    name=getClassName(this);
    activeCost=40;
  } 
  void press() {
    super.press();
    action();
  }
  @Override
    void action() {
    particles.add(new  Tesla( int(owner.cx), int(owner.cy), 200, 500, owner.playerColor));
    players.add(new Turret(players.size(), int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 200, new AutoGun(), new RandomPassive().randomize() ));
    players.add(new FollowDrone(players.size(), int(owner.x+cos(radians(owner.angle))*100), int(owner.y+sin(radians(owner.angle))*100), int(playerSize*0.5), int(playerSize*0.5), 20, 200, 1, new AutoGun(), new RandomPassive().randomize() ));
    println("hello");
    projectiles.add( new IceDagger(owner, int( owner.cx+cos(radians(owner.keyAngle))*75), int(owner.cy+sin(radians(owner.keyAngle))*75), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, int(damage*1.2)));
  }

  void  passive() {
    stroke(owner.playerColor);
    noFill();
    ellipse(owner.cx, owner.cy, range, range);

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

class Random extends Ability {//---------------------------------------------------    Random   ---------------------------------

  Random() {
    super();
  } 
  Ability randomize() {
    Ability rA=null;
    try {
      rA = abilityList[int(random(abilityList.length))].clone();
    }
    catch(CloneNotSupportedException e) {
      println("not cloned from Random Ability");
    }
    return rA;  // clone it
  }
}