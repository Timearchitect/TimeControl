

class Ability implements Cloneable {
  String name;
  Player owner;  
  PImage icon;
  float energy=90, maxEnergy=100, activeCost=5, channelCost, deChannelCost, deactiveCost, cooldown, maxCooldown, regenRate=0.1, ammo, maxAmmo, loadRate;
  boolean active, channeling, cooling, hold, regen=true, meta;
  void Ability() { 
    icon = loadImage("Ability Icons-04.jpg");
    energy=100;
    maxEnergy=energy;
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
      energy -= channelCost;
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
    cooldown=maxCooldown;
    cooling=true;
  }
  void regen() {
    if (reverse && !owner.reverseImmunity) {
      if (regen && energy>0) {
        energy -= regenRate*S*F;
      }
    } else {
      if (regen && energy<maxEnergy) {
        energy += regenRate*S*F;
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
    name=this.toString();
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
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*S*F:1*S*F, 400); //now fastforward
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
    void setOwner(Player _owner) {
    super.setOwner(_owner);
    if (round(random(1))==0)owner.fastforwardImmunity=true;
  }
}



class Freeze extends Ability { //---------------------------------------------------    Freeze   ---------------------------------

  Freeze() {
    super();
    name=this.toString();
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
    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 150, owner.playerColor));
    stamps.add( new ControlStamp(owner.index, int(owner.x), int( owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    regen=false;
    action();
  }

  @Override
    void deActivate() {
    super.deActivate();
    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 200, 850, owner.playerColor));
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
    void setOwner(Player _owner) {
    super.setOwner(_owner);
    owner.freezeImmunity=true;
  }
}




class Reverse extends Ability { //---------------------------------------------------    Reverse   ---------------------------------

  Reverse() {
    super();
    name=this.toString();
    energy=0;
    activeCost=16;
    channelCost=0.04;
    deactiveCost=8;
    active=false;
    meta=true;
  }
  @Override
    void action() {
    musicPlayer.pause(false);
    reverse=(reverse)?false:true;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*S*F:1*S*F, 600); //now rewind
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
    musicPlayer.pause(false);
    slow=(slow)?false:true;
    S =(slow)?slowFactor:1;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*S*F:1*S*F, 800); //now slow
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
    void setOwner(Player _owner) {
    super.setOwner(_owner);
    if (round(random(1))==0)owner.slowImmunity=true;
  }
}

class SaveState extends Ability { //---------------------------------------------------    SaveState   ---------------------------------
  int stampIndex, displayTime, pulse, duration=30000;
  long endTime;
  TimeStamp saved;

  SaveState() {
    super();
    name=this.toString();
    activeCost=60;
    deactiveCost=40;
    active=false;
    meta=true;
  }
  @Override
    void action() {
    musicPlayer.pause(false);
    endTime=stampTime+duration;  // init end Time
    for (int i=0; i< players.size (); i++) {  
      if (!players.get(i).dead) {
        particles.add(new ShockWave(int(players.get(i).x+players.get(i).w*0.5), int(players.get(i).y+players.get(i).h*0.5), 20, 500, players.get(i).playerColor));
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
    speedControl.addSegment((reverse)?-1*S*F:1*S*F, 100); 
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
}


class ThrowDagger extends Ability {//---------------------------------------------------    ThrowDagger   ---------------------------------
  int damage=16, threashold =1;
  int slashDuration=190, slashRange=110;
  boolean alternate;
  ThrowDagger() {
    super();
    name=this.toString();
    activeCost=8;
  } 
  @Override
    void action() {
    if (abs(owner.vx)>threashold  ||  abs(owner.vy)>threashold) {
      if (abs(owner.keyAngle-owner.angle)<5) {
        projectiles.add( new IceDagger(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, damage));
      } else {
        projectiles.add( new ArchingIceDagger(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 1000, owner.keyAngle, owner.angle, owner.ax*24, owner.ay*24, damage));
      }
    } else {
      projectiles.add( new Slash(owner.index, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, int(slashDuration), owner.angle+45, slashRange, sin(owner.keyAngle)*5, cos(owner.keyAngle)*5, damage));
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

class ForceShoot extends Ability {//---------------------------------------------------    forceShoot   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=64;
  float forceAmount=0, MODIFIED_MAX_ACCEL=0.02;
  float ChargeRate=0.4, restForce;
  ForceShoot() {
    super();
    name=this.toString();
    activeCost=8;
    channelCost=0.1;
  } 
  @Override
    void action() {
    projectiles.add( new forceBall(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), forceAmount*2, 30, owner.playerColor, 2000, owner.angle, forceAmount*4));
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
      if (MAX_FORCE>forceAmount) { 
        channel();
        if (!active || energy<0 ) {
          release();
        }
        restForce = MAX_FORCE-forceAmount;
        forceAmount+=ChargeRate*S*F; 
        particles.add(new Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-restForce*0.5, restForce*0.5), random(-restForce*0.5, restForce*0.5), int(random(30)+10), 300, owner.playerColor));
        particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), int(forceAmount/3), int(forceAmount/3), owner.playerColor));
      } else {
        //  particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), int(forceAmount), 50, color(255, 0, 255)));
        particles.add( new  Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, int(MAX_FORCE*2), 50, color(255, 0, 255)));
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
        regen=true;
        action();
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        forceAmount=0;
      }
    }
  }
  void reset() {
    active=false;
    regen=true;
    channeling=false;
    super.reset();
  }
}

class Blink extends Ability {//---------------------------------------------------    Blink   ---------------------------------
  int range=250;
  Blink() {
    super();
    name=this.toString();
    activeCost=10;
  } 
  @Override
    void action() {
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));
    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 200, owner.playerColor));
    particles.add( new  Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 0, 0, int(owner.w), 800, color(255, 0, 255)));
    for (int i =0; i<3; i++) {
      particles.add( new Feather(300, int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-2, 2), random(-2, 2), 15, owner.playerColor));
    }
    owner.x+=cos(radians(owner.angle))*range;
    owner.y+= sin(radians(owner.angle))*range;
    //projectiles.add( new IceDagger(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, 10));

    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 200, owner.playerColor));
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
class Multiply extends Ability {//---------------------------------------------------    Multiply   ---------------------------------
  int range=playerSize;
  ArrayList<Player> clone= new ArrayList();

  Multiply() {
    super();
    name=this.toString();
    activeCost=99;
  } 
  @Override
    void action() {
    for (int i=0; i<12; i++) {
      particles.add(new Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-10, 10), random(-10, 10), int(random(20)+5), 800, 255));
    }
    stamps.add( new ControlStamp(owner.index, int(owner.x), int(owner.y), owner.vx, owner.vy, owner.ax, owner.ay));

    players.add(new Player(players.size(), owner.playerColor, int(owner.x-cos(radians(owner.angle))*range), int(owner.y-sin(radians(owner.angle))*range), playerSize, playerSize, owner.down, owner.up, owner.right, owner.left, owner.triggKey, new CloneMultiply()));
    clone.add(players.get(players.size()-1));
    Player currentClone=clone.get(clone.size()-1);

    owner.x+=cos(radians(owner.angle))*range;
    owner.y+= sin(radians(owner.angle))*range;
    currentClone.clone=true;
    currentClone.ally=owner.ally; //same ally
    currentClone.dead=true;
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
  CloneMultiply() {
    super();
    name=this.toString();
  }
  @Override
    void action() {
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
}

class Stealth extends Ability {//---------------------------------------------------    Stealth   ---------------------------------
  int projectileDamage=34;
  float MODIFIED_MAX_ACCEL=0.06;
  float range=200, duration=200;
  Stealth() {
    super();
    active=false;
    name=this.toString();
    activeCost=24;
    energy=0;
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
        particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 200, owner.playerColor));
        projectiles.add( new Slash(owner.index, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, int(duration), owner.angle, range, 0, 0, projectileDamage));
      }
    }
  }
  @Override
    void passive() {
    if (int(random(60))==0)particles.add(new Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-5, 5), random(-5, 5), int(random(20)+5), 600, 255));
  }
}
class Laser extends Ability {//---------------------------------------------------    Laser   ---------------------------------
  int damage=40;
  int duration=2400;
  int delay=500;
  int chargelevel;
  int laserWidth=75;
  long timer;
  float MODIFIED_ANGLE_FACTOR=0;
  float MODIFIED_MAX_ACCEL=0.005; 
  long startTime;
  boolean charging;
  Laser() {
    super();
    name=this.toString();
    activeCost=24;
  } 
  @Override
    void action() {
    timer=millis();
    chargelevel++;
    particles.add(new  gradient(1000, int(owner.x+owner.w*0.5), int(owner.y+owner.w*0.5), 0, 0, 4*chargelevel, owner.angle, owner.playerColor));
    particles.add(new RShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.w*0.5), 250*chargelevel, 300, owner.playerColor));
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
      particles.add(new  gradient(1000, int(owner.x+owner.w*0.5), int(owner.y+owner.w*0.5), 0, 0, 3, owner.angle, owner.playerColor));
    }
  }
  void passive() {
    if (charging && (timer+delay)<millis()) {
      particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 200*chargelevel, 500, owner.playerColor));
      for (int i=0; i<chargelevel; i++) {
        projectiles.add( new ChargeLaser(owner.index, int( owner.x+owner.w*0.5+random(50, -50)), int(owner.y+owner.h*0.5+random(50, -50)), laserWidth*chargelevel, owner.playerColor, duration, owner.angle, damage+10*chargelevel));
      }
      charging=false;
      chargelevel=0;
    } else {
      owner.ANGLE_FACTOR=(owner.DEFAULT_ANGLE_FACTOR/duration)*(stampTime-startTime)*0.02*F*S;
      owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.3*F*S;
      if (stampTime>=duration+startTime) {
        owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
      }
    }
  }
}

class TimeBomb extends Ability {//---------------------------------------------------    TimeBomb   ---------------------------------
  int damage=50;
  int shootSpeed=30;
  TimeBomb() {
    super();
    name=this.toString();
    activeCost=16;
  } 
  @Override
    void action() {
    owner.pushForce(-8, owner.angle);
    if (int(random(5))!=0) {
      projectiles.add( new Bomb(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, int(random(500, 2000)), owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage));
    } else {
      projectiles.add( new Mine(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 80000, owner.angle, cos(radians(owner.angle))*shootSpeed*0.5, sin(radians(owner.angle))*shootSpeed*0.5, damage));
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

class RapidFire extends Ability {//---------------------------------------------------    RapidFire   ---------------------------------
  float accuracy = 1, MODIFIED_ANGLE_FACTOR=-0.0008;
  int Interval=110;
  long  PastTime;
  int projectileDamage=4;
  RapidFire() {
    super();
    name=this.toString();
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
      projectiles.add( new Needle(owner.index, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
      channel();
      if (!active || energy<0 ) {
        release();
      }
      PastTime=stampTime;
    } else if ((!freeze || owner.freezeImmunity) &&  active && !owner.dead &&(stampTime+freezeTime-PastTime) >= Interval) {
      float InAccurateAngle=random(-accuracy, accuracy);
      projectiles.add( new Needle(owner.index, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*36, sin(radians(owner.angle+InAccurateAngle))*36, projectileDamage));
      owner.ANGLE_FACTOR=MODIFIED_ANGLE_FACTOR;
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
}

class MachineGunFire extends RapidFire {//---------------------------------------------------    RapidFire   ---------------------------------

  long coolDown;
  int coolDownTime=1000;
  float sutainCount, MAX_sutainCount=40;
  MachineGunFire() {
    super();
    name=this.toString();
    deactiveCost=12;
    channelCost=0.2;
    accuracy = 0;
    projectileDamage=2;
  } 
  void press() {
    super.press();
  }
  void hold() {
    if (coolDown<stampTime) {
      super.hold();
      sutainCount+=0.4;
      if (sutainCount>MAX_sutainCount) {
        sutainCount=MAX_sutainCount;
        owner.pushForce(1, owner.angle+180);
      }
      accuracy=sutainCount;
      Interval=int((MAX_sutainCount-sutainCount)*5);
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

        owner.pushForce(8, owner.angle+180);
        for (int i=0; sutainCount/2>i; i++) {
          float InAccurateAngle=random(-accuracy*2, accuracy*2);
          projectiles.add( new Needle(owner.index, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*40, sin(radians(owner.angle+InAccurateAngle))*40, projectileDamage*2));
        }
        sutainCount=0;
        coolDown=stampTime+coolDownTime;
      }
    }
  }
}

class Battery extends Ability {//---------------------------------------------------    RapidFire   ---------------------------------
  int interval, maxInterval=4, damage=8, accuracy=10, count=0, maxCount=6;

  Battery() {
    super();
    name=this.toString();
    activeCost=20;
  } 

  @Override
    void action() {
    //projectiles.add(charge.get(count));
    float inAccuracy;
    inAccuracy =random(-accuracy, accuracy);
    switch(count) {
    case 0:
      projectiles.add(new Needle(owner.index, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*20, sin(radians(owner.angle+inAccuracy))*20, damage));        
      break;
    case 1:
      projectiles.add(new Needle(owner.index, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*25, sin(radians(owner.angle+inAccuracy))*25, damage));        
      break;
    case 2:
      projectiles.add(new Needle(owner.index, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*30, sin(radians(owner.angle+inAccuracy))*30, damage));        
      break;     
    case 3:
      projectiles.add(new Needle(owner.index, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*35, sin(radians(owner.angle+inAccuracy))*35, damage));        
      break;
    case 4:
      projectiles.add(new Needle(owner.index, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*40, sin(radians(owner.angle+inAccuracy))*40, damage));        
      break;
    case 5:
      projectiles.add(new Needle(owner.index, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*45, sin(radians(owner.angle+inAccuracy))*45, damage));        
      break;
    default:
      for (int i=0; i<5; i++) {
        inAccuracy =random(-accuracy*2, accuracy*2);
        projectiles.add(new Needle(owner.index, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800*maxInterval, owner.angle+inAccuracy, cos(radians(owner.angle+inAccuracy))*40, sin(radians(owner.angle+inAccuracy))*40, damage));
      }
      owner.pushForce(10, owner.angle+180);
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


class ThrowBoomerang extends Ability {//---------------------------------------------------    Boomerang   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=64;
  float forceAmount=0, MODIFIED_MAX_ACCEL=0.04;
  float ChargeRate=0.8, restForce, recoveryEnergy;
  int damage=2;
  ThrowBoomerang() {
    super();
    name=this.toString();
    activeCost=20;
    channelCost=0.1;
    recoveryEnergy=activeCost*0.5;
  } 
  @Override
    void action() {
    projectiles.add( new Boomerang(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, int(300*forceAmount)+100, owner.angle, cos(radians(owner.angle))*(forceAmount+2), sin(radians(owner.angle))*(forceAmount+2), damage, recoveryEnergy, int(forceAmount*0.5+12)));
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
        forceAmount+=ChargeRate*S*F; 
        particles.add(new Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-restForce*0.5, restForce*0.5), random(-restForce*0.5, restForce*0.5), int(random(30)+10), 300, owner.playerColor));
        particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), int(forceAmount/3), int(forceAmount/3), owner.playerColor));
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
}


class PhotonicPursuit extends Ability {//---------------------------------------------------    PhotonicPursuit   ---------------------------------
  int damage=32, customAngle, initialSpeed=6;
  PhotonicPursuit() {
    super();
    name=this.toString();
    activeCost=16;
    energy=50;
  } 
  @Override
    void action() {
    customAngle=-90;
    projectiles.add( new HomingMissile(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));

    customAngle=90;
    projectiles.add( new HomingMissile(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 5000, owner.angle, cos(radians(owner.angle+customAngle))*30, sin(radians(owner.angle+customAngle))*initialSpeed, damage));
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

class DeployThunder extends TimeBomb {//---------------------------------------------------    TimeBomb   ---------------------------------

  float MODIFIED_MAX_ACCEL=0.01, duration=300; 
  long startTime;
  DeployThunder() {
    super();
    damage=120;
    shootSpeed=0;
    regenRate=0.5;
    name=this.toString();
    activeCost=60;
  } 
  @Override
    void action() {
    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 10, 1000, owner.playerColor));

    //    particles.add( new Shock(1000, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), owner.vx, owner.vy, 2, owner.angle, owner.playerColor)) ;
    // particles.add( new Shock(1000, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), owner.vx, owner.vy, 3, owner.angle, owner.playerColor)) ;
    // particles.add( new Shock(1000, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), owner.vx, owner.vy, 1, owner.angle, owner.playerColor)) ;

    startTime=stampTime;
    owner.MAX_ACCEL=owner.MAX_ACCEL*3;
    projectiles.add( new Thunder(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 2000, owner.angle, cos(radians(owner.angle))*shootSpeed, sin(radians(owner.angle))*shootSpeed, damage));
  }

  void  passive() {

    //owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.6;
    if (stampTime>=duration+startTime) {
      owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
    }
  }
}

class DeployShield extends Ability {//---------------------------------------------------    DeployElectron   ---------------------------------
  int damage=8;

  DeployShield() {
    super();
    name=this.toString();
    activeCost=8;
  } 
  @Override
    void action() {

    projectiles.add( new Shield( owner, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*200), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*200), owner.playerColor, 10000, owner.angle, 0 ));
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

class DeployElectron extends Ability {//---------------------------------------------------    DeployElectron   ---------------------------------
  int damage=24;
  ArrayList<Electron> stored =new ArrayList<Electron> ();
  DeployElectron() {
    super();
    name=this.toString();
    activeCost=16;
  } 
  @Override
    void action() {
    for (Electron p : stored) {
      p.derail();
    }

    stored.add( new Electron( owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 10000, owner.angle, -5, -5, damage ));
    projectiles.add(stored.get(stored.size()-1));
    stored.add( new Electron( owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 10000, owner.angle+180, -5, -5, damage ));
    projectiles.add(stored.get(stored.size()-1));
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

class Gravity extends Ability {//---------------------------------------------------    Gravity   ---------------------------------
  int damage=24;
  Gravity() {
    super();
    name=this.toString();
    activeCost=30;
  } 
  @Override
    void action() {
    projectiles.add( new  Graviton(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, 10000, owner.angle, 0, 0, damage));
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

class Ram extends Ability {//---------------------------------------------------    DeployElectron   ---------------------------------
  int damage=16;
  Ram() {
    super();
    name=this.toString();
    activeCost=16;
    channelCost=0.2;
    energy=50;
  } 
  @Override
    void action() {
    active=true;
    owner.damage=damage;
    owner.pushForce(30, owner.keyAngle);
    particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 150, 150, owner.playerColor));
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
      owner.pushForce(1, owner.keyAngle);
      owner.damage=damage/2;
      particles.add(new Particle(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), random(-50, 50), random(-50, 50), int(random(30)+10), 300, owner.playerColor));
      particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, 50, owner.playerColor));
    }
  }

  void release() {
    owner.damage=1;
    deActivate();
  }
}
class DeployTurret extends Ability {//---------------------------------------------------    DeployElectron   ---------------------------------
  int damage=50, range=75, turretLevel=0;
  DeployTurret() {
    super();
    name=this.toString();
    activeCost=25;
    energy=25;
  } 
  @Override
    void action() {
    switch(turretLevel) {
    case 0:
      players.add(new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 200, new CloneMultiply()));
      break;
    case 1:
      players.add(new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 300, new Battery()));
      break;
    case 2:
      players.add(new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 400, new TimeBomb()));
      break;
    case 3:
      players.add(new Turret(players.size(), owner, int(owner.x+cos(radians(owner.angle))*range), int(owner.y+sin(radians(owner.angle))*range), playerSize, playerSize, 500, new Laser()));
      break;
    }
    activeCost=25;
    turretLevel=0;
  }
  @Override
    void activate() { 

    if (energy<=50) {
      turretLevel=0;  
      activeCost=25;
    } else if (energy<=75) {
      turretLevel=1; 
      activeCost=50;
    } else if (energy<100) {
      turretLevel=2;  
      activeCost=75;
    } else if (energy==100) {
      turretLevel=3;  
      activeCost=100;
    }     
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
}
class Random extends Ability {//---------------------------------------------------    Gravity   ---------------------------------
  int damage=24;
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