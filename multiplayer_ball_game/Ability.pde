class Ability {
  String name;
  Player owner;  
  float energy=90, maxEnergy=100, activeCost=5, channelCost, deChannelCost, deactiveCost, cooldown, maxCooldown, regenRate=0.1, ammo, maxAmmo, loadRate;
  boolean active, channeling, cooling, hold, regen=true, meta;
  void Ability() { 
    energy=100;
    maxEnergy=energy;
  }
  void Ability( Player _owner) { 
    owner=_owner;
    energy=100;
    maxEnergy=energy;
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
        stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
        regen=false;
      }
    }
  }
  void load() {
    if (ammo<maxAmmo)ammo+=loadRate;
  }
  void passive() {
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
}



class Freeze extends Ability { //---------------------------------------------------    Freeze   ---------------------------------

  Freeze() {
    super();
    name=this.toString();
    activeCost=16;
    energy=50;
    channelCost=0.05;
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
    action();
    regen=false;
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
    // stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
    regen=true;
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
  }
  @Override
    void passive() {
    if (active) {
      if (endTime<stampTime) {
        super.deActivate();
        regen=true;
        energy+=deactiveCost;
      }
      pulse+=4;
      stroke(255);
      strokeWeight(int(sin(radians(pulse))*8)+1);
      fill(255);
      float f = (float)(endTime-stampTime)/duration;
      for (int i=0; i<360*f; i+= (360/12)) {
        line(owner.x+owner.w*0.5+ cos(radians(-90-i))*80, owner.y+owner.w*0.5+sin(radians(-90-i))*80, owner.x+owner.w*0.5+ cos(radians(-90-i))*130, owner.y+owner.w*0.5+sin(radians(-90-i))*130);
      }
      text(displayTime, owner.x+owner.w*0.5, owner.y-owner.h*1);
      noFill();
      // point(owner.x+owner.w*0.5+cos(radians(owner.angle))*range, owner.y+owner.h*0.5+sin(radians(owner.angle))*range);
      ellipse(owner.x+owner.w*0.5, owner.y+owner.h*0.5, owner.w*2, owner.h*2);
    }
  }
}


class ThrowDagger extends Ability {//---------------------------------------------------    ThrowDagger   ---------------------------------
  int damage=16;

  ThrowDagger() {
    super();
    name=this.toString();
    activeCost=8;
  } 
  @Override
    void action() {
    if (int(random(4))==0) {
      projectiles.add( new IceDagger(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*30, owner.ay*30, damage));
    } else {
      projectiles.add( new ArchingIceDagger(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 30, owner.playerColor, 1000, owner.keyAngle, owner.ax*24, owner.ay*24, damage));
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
    projectiles.add( new forceBall(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), forceAmount*2, 30, owner.playerColor, 2000, owner.angle, forceAmount));
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
class CloneMultiply extends Multiply {
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
  int projectileDamage=32;
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
        regen=false;
        activate();
        particles.add(new Flash(300, 6, owner.playerColor));  
        action();
      } else if (owner.stealth) {
        deActivate();
        regen=true;
        owner.stealth=false;
        particles.add(new ShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 20, 200, owner.playerColor));
        float range=200, duration=200;
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
  int duration=2000;
  //float MODIFIED_ANGLE_FACTOR=0.000001;
  float MODIFIED_ANGLE_FACTOR=0;
  float MODIFIED_MAX_ACCEL=0.005; 
  long startTime;
  Laser() {
    super();
    name=this.toString();
    activeCost=24;
  } 
  @Override
    void action() {
    projectiles.add( new ChargeLaser(owner.index, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), owner.playerColor, duration, owner.angle, damage));
  }
  @Override
    void press() {
    if ((!reverse || owner.reverseImmunity)&& energy>0+activeCost && !owner.dead && (!freeze || owner.freezeImmunity)) {
      stamps.add( new AbilityStamp(owner.index, int(owner.x), int(owner.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      /*owner.vx=0;
       owner.vy=0;
       owner.ax=0;
       owner.ay=0;*/
      owner.ANGLE_FACTOR= MODIFIED_ANGLE_FACTOR;
      owner.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      action();
      startTime=stampTime;
      deActivate();
      particles.add(new  gradient(1000, int(owner.x+owner.w*0.5), int(owner.y+owner.w*0.5), 0, 0, 3, owner.angle, owner.playerColor));
    }
  }
  void passive() {

    owner.ANGLE_FACTOR=(owner.DEFAULT_ANGLE_FACTOR/duration)*(stampTime-startTime)*0.02*F*S;
    owner.MAX_ACCEL=(owner.DEFAULT_MAX_ACCEL/duration)*(stampTime-startTime)*0.3*F*S;
    if (stampTime>=duration+startTime) {
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
      owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
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
  float sutainCount, MAX_sutainCount=20;
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
        sutainCount=0;
        owner.pushForce(8, owner.angle+180);
        for (int i=0; 8>i; i++) {
          float InAccurateAngle=random(-accuracy*2, accuracy*2);
          projectiles.add( new Needle(owner.index, int( owner.x+owner.w*0.5+cos(radians(owner.angle))*owner.w), int(owner.y+owner.h*0.5+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle+InAccurateAngle, cos(radians(owner.angle+InAccurateAngle))*40, sin(radians(owner.angle+InAccurateAngle))*40, projectileDamage*2));
        }
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
    projectiles.add( new Boomerang(owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5), 50, owner.playerColor, int(400*forceAmount), owner.angle, cos(radians(owner.angle))*(forceAmount+2), sin(radians(owner.angle))*(forceAmount+2), damage, recoveryEnergy, int(forceAmount*0.5+12)));
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
        deChannel();
        deActivate();
        owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
        forceAmount=0;
      }
    }
  }
}


class PhotonicPursuit extends Ability {//---------------------------------------------------    ThrowDagger   ---------------------------------
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
    for(Electron p: stored){
    p.derail();
    }
      
    stored.add( new Electron( owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5),50, owner.playerColor, 10000, owner.angle,-5,-5, damage ));
    projectiles.add(stored.get(stored.size()-1));
    stored.add( new Electron( owner, int( owner.x+owner.w*0.5), int(owner.y+owner.h*0.5),50, owner.playerColor, 10000, owner.angle+180,-5,-5, damage ));
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

