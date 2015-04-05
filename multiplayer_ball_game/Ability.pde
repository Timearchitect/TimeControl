class Ability {
  String name;
  Player player;
  float energy=90, maxEnergy=100, activeCost=5, channelCost, deChannelCost, deactiveCost, cooldown, maxCooldown, regenRate=0.1, ammo, maxAmmo, loadRate;
  boolean active, channeling, cooling, hold, regen=true, meta;
  void Ability() { 
    energy=100;
    maxEnergy=energy;
  }
  void Ability(  Player _player) { 
    player=_player;
    energy=100;
    maxEnergy=energy;
  }
  void press(Player player) {
  }
  void release(Player player) {
  }
  void hold(Player player) {
  }
  void action(Player player) {
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
  void regen(Player player) {
    if (reverse && !player.reverseImmunity) {
      if (regen && energy>0) {
        energy -= regenRate*S*F;
      }
    } else {
      if (regen && energy<maxEnergy) {
        energy += regenRate*S*F;
      } else if (regen) {
        stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
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
    void action(Player player) {
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
  void press(Player player) {
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
    action(player);
    regen=false;
  }
  @Override
    void deActivate() {
    super.deActivate();
    regen=true;
    action(player);
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
    void action(Player player) {
    quitOrigo();
    if (player.freezeImmunity) {
      for (int i =0; i<4; i++) {
        particles.add( new Feather(400, int(player.x+player.w/2), int(player.y+player.h/2), random(-5, 5), random(-5, 5), 15, player.playerColor));
      }
      particles.add( new  Particle(int(player.x+player.w/2), int(player.y+player.h/2), 0, 0, player.w, 50, player.playerColor));
    }
    stamps.add( new ControlStamp(player.index, int(player.x), int(player.y), player.vx, player.vy, player.ax, player.ay));
    freeze=(freeze)?false:true;
    speedControl.clear();
    speedControl.addSegment((freeze)?0:1, 150); //now stop
    controlable=(controlable)?false:true;
    for (int i=0; i< players.size (); i++) {
      stamps.add( new ControlStamp(i, int(players.get(i).x), int( players.get(i).y), 0, 0, 0, 0));
      stamps.add( new ControlStamp(i, int(players.get(i).x), int( players.get(i).y), players.get(i).vx, players.get(i).vy, players.get(i).ax, players.get(i).ay));
    }
    controlable=(controlable)?false:true;
    drawTimeSymbol();
  }

  @Override
    void press(Player player) {
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
    particles.add(new ShockWave(int(player.x+player.w/2), int(player.y+player.h/2), 20, 150, player.playerColor));
    stamps.add( new ControlStamp(player.index, int(player.x), int( player.y), player.vx, player.vy, player.ax, player.ay));
    action(player);
    regen=false;
  }

  @Override
    void deActivate() {
    super.deActivate();
    particles.add(new ShockWave(int(player.x+player.w/2), int(player.y+player.h/2), 200, 850, player.playerColor));
    action(player);
    //  stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
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
    void action(Player player) {
    musicPlayer.pause(false);
    reverse=(reverse)?false:true;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*S*F:1*S*F, 600); //now rewind
    controlable=(controlable)?false:true;
    drawTimeSymbol();
    quitOrigo();
  }
  @Override
    void press(Player player) {
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
    action(player);
    active=true;
    regen=false;
  }
  @Override
    void deActivate() {
    super.deActivate();
    //  stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
    action(player);
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
    void action(Player player) {
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
    void press(Player player) {
    if (!active) {
      if (energy>0+activeCost) {
        activate();
        action(player);
      }
    } else {
      deActivate();
      action(player);
    }
  }
  @Override
    void deActivate() {
    super.deActivate();
    // stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
    regen=true;
  }
}

class SaveState extends Ability { //---------------------------------------------------    SaveState   ---------------------------------
  int stampIndex;
  TimeStamp saved;
  SaveState() {
    super();
    name=this.toString();
    activeCost=70;
    deactiveCost=40;
    active=false;
    meta=true;
  }
  @Override
    void action(Player player) {
    musicPlayer.pause(false);

    for (int i=0; i< players.size (); i++) {  
      if (!players.get(i).dead) {
        particles.add(new ShockWave(int(players.get(i).x+players.get(i).w/2), int(players.get(i).y+players.get(i).h/2), 20, 500, players.get(i).playerColor));
        particles.add( new  Particle(int(players.get(i).x+players.get(i).w/2), int(players.get(i).y+players.get(i).h/2), 0, 0, int(players.get(i).w), 1000, players.get(i).playerColor));
      }
      // speedControl.clear();
      saved =new CheckPoint(); // timeStamps special object
    }
    regen=false;
    drawTimeSymbol();
  }
  @Override
    void press(Player player) {
    if (!active) {
      if (energy>0+activeCost) {
        activate();
        action(player);
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
    shakeTimer=50;
    particles.add(new Flash(1200, 5, color(255)));   // flash
    regen=true;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*S*F:1*S*F, 100); 
    drawTimeSymbol();
  }
  @Override
    void passive() {
    if (active) {
      stroke(255);
      strokeWeight(1);
      noFill();
      // point(player.x+player.w/2+cos(radians(player.angle))*range, player.y+player.h/2+sin(radians(player.angle))*range);
      ellipse(player.x+player.w/2, player.y+player.h/2, player.w*2, player.h*2);
    }
  }
}


class ThrowDagger extends Ability {//---------------------------------------------------    ThrowDagger   ---------------------------------
  int damage=8;

  ThrowDagger() {
    super();
    name=this.toString();
    activeCost=8;
  } 
  @Override
    void action(Player player) {
    projectiles.add( new IceDagger(player.index, int( player.x+player.w/2), int(player.y+player.h/2), 30, player.playerColor, 1000, player.angle, player.ax*24, player.ay*24,damage));
  }
  @Override
    void press(Player player) {
    if ((!reverse || player.reverseImmunity)&& energy>0+activeCost && !player.dead && (!freeze || player.freezeImmunity)) {
      stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action(player);
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
    void action(Player player) {
    projectiles.add( new forceBall(player.index, int( player.x+player.w/2), int(player.y+player.h/2), forceAmount*2, 30, player.playerColor, 2000, player.angle, forceAmount));
  }
  @Override
    void press(Player player) {
    if ((!reverse || player.reverseImmunity) && energy>(0+activeCost) && !active && !channeling && !player.dead) {
      activate();
      stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
      regen=false;
    }
  }
  @Override
    void hold(Player player) {

    if ((!reverse || player.reverseImmunity) &&  active && !player.dead) {
      player.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      if (MAX_FORCE>forceAmount) { 
        channel();
        if (!active || energy<0 ) {
          release(player);
        }
        restForce = MAX_FORCE-forceAmount;
        forceAmount+=ChargeRate*S*F; 
        particles.add(new Particle(int(player.x+player.w/2), int(player.y+player.h/2), random(-restForce/2, restForce/2), random(-restForce/2, restForce/2), int(random(30)+10), 300, player.playerColor));
        particles.add(new ShockWave(int(player.x+player.w/2), int(player.y+player.h/2), int(forceAmount), 50, player.playerColor));
      } else {
        //  particles.add(new ShockWave(int(player.x+player.w/2), int(player.y+player.h/2), int(forceAmount), 50, color(255, 0, 255)));
        particles.add( new  Particle(int(player.x+player.w/2), int(player.y+player.h/2), 0, 0, int(MAX_FORCE*2), 50, color(255, 0, 255)));
      }
    }
    if (!active)press(player); // cancel
    if (player.hit)release(player); // cancel
  }
  @Override
    void release(Player player) {
    if ((!reverse || player.reverseImmunity ) ) {
      if (!player.dead && (!freeze || player.freezeImmunity)&& active && channeling) {
        stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        action(player);
        deChannel();
        deActivate();
        player.MAX_ACCEL=player.DEFAULT_MAX_ACCEL;
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
    void action(Player player) {
    stamps.add( new ControlStamp(player.index, int(player.x), int(player.y), player.vx, player.vy, player.ax, player.ay));
    particles.add(new ShockWave(int(player.x+player.w/2), int(player.y+player.h/2), 20, 200, player.playerColor));
    particles.add( new  Particle(int(player.x+player.w/2), int(player.y+player.h/2), 0, 0, int(player.w), 800, color(255, 0, 255)));
    for (int i =0; i<3; i++) {
      particles.add( new Feather(300, int(player.x+player.w/2), int(player.y+player.h/2), random(-2, 2), random(-2, 2), 15, player.playerColor));
    }
    player.x+=cos(radians(player.angle))*range;
    player.y+= sin(radians(player.angle))*range;

    // particles.add( new  Particle(int(player.x+player.w/2), int(player.y+player.h/2), 0, 0, int(player.w), 1000, color(255, 0, 255)));
    particles.add(new ShockWave(int(player.x+player.w/2), int(player.y+player.h/2), 20, 200, player.playerColor));
    //projectiles.add( new IceDagger(player.index, int( player.x+player.w/2), int(player.y+player.h/2), 30, player.playerColor, 1000, player.angle, player.ax*24, player.ay*24));
  }
  @Override
    void press(Player player) {
    if ((!reverse || player.reverseImmunity)&& energy>0+activeCost && !player.dead && (!freeze || player.freezeImmunity)) {
      stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action(player);
      deActivate();
    }
  }
  /*@Override
   void passive() {
   stroke(255);
   strokeWeight(1);
   noFill();
   point(player.x+player.w/2+cos(radians(player.angle))*range, player.y+player.h/2+sin(radians(player.angle))*range);
   ellipse(player.x+player.w/2+cos(radians(player.angle))*range, player.y+player.h/2+sin(radians(player.angle))*range,player.w,player.h);
   }*/
}
class Multiply extends Ability {//---------------------------------------------------    Multiply   ---------------------------------
  int range=playerSize;
  Multiply() {
    super();
    name=this.toString();
    activeCost=100;
  } 
  @Override
    void action(Player player) {
    for (int i=0; i<12; i++) {
      particles.add(new Particle(int(player.x+player.w/2), int(player.y+player.h/2), random(-10, 10), random(-10, 10), int(random(20)+5), 800, 255));
    }
    stamps.add( new ControlStamp(player.index, int(player.x), int(player.y), player.vx, player.vy, player.ax, player.ay));
    players.add(new Player(players.size(), player.playerColor, int(player.x-cos(radians(player.angle))*range), int(player.y-sin(radians(player.angle))*range), playerSize, playerSize, player.down, player.up, player.right, player.left, player.triggKey, player.ability));
    player.x+=cos(radians(player.angle))*range;
    player.y+= sin(radians(player.angle))*range;
    players.get(players.size()-1).clone=true;
    players.get(players.size()-1).ally=player.ally; //same ally
    players.get(players.size()-1).dead=true;
    stamps.add( new StateStamp(players.size()-1, int(player.x), int(player.y), player.state, player.health, true));
    players.get(players.size()-1).dead=false;
    players.get(players.size()-1).maxHealth=player.maxHealth/2;
    players.get(players.size()-1).health=player.health/2;
  }
  @Override
    void press(Player player) {
    if ((!reverse || player.reverseImmunity)&& energy>0+activeCost && !player.dead && (!freeze || player.freezeImmunity)) {
      stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action(player);
      deActivate();
    }
  }
}
class Stealth extends Ability {//---------------------------------------------------    Stealth   ---------------------------------
 int projectileDamage=10;
  Stealth() {
    super();
    active=false;
    name=this.toString();
    activeCost=24;
        energy=-50;
  } 
  @Override
    void action(Player player) {
    stamps.add( new StateStamp(player.index, int(player.x), int(player.y), player.state, player.health, player.dead));
    particles.add( new  Particle(int(player.x+player.w/2), int(player.y+player.h/2), 0, 0, int(player.w), 300, color(255, 0, 255)));
    for (int i =0; i<10; i++) {
      particles.add( new Feather(500, int(player.x+player.w/2), int(player.y+player.h/2), random(-2, 2), random(-2, 2), 500, player.playerColor));
    }
    player.stealth=true;
  }
  @Override
    void press(Player player) {

    if ((!reverse || player.reverseImmunity)&& !player.dead && (!freeze || player.freezeImmunity)) {
      if (energy>0+activeCost && !active) { 
        stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
        regen=false;
        activate();
        particles.add(new Flash(400, 4, player.playerColor));  
        action(player);
      } else if (player.stealth) {
        deActivate();
        regen=true;
        player.stealth=false;
        particles.add(new ShockWave(int(player.x+player.w/2), int(player.y+player.h/2), 20, 200, player.playerColor));
        for (int i=0; i<=360; i+=30) {
          projectiles.add( new IceDagger(player.index, int( player.x+player.w/2), int(player.y+player.h/2), 30, player.playerColor, 150, i, cos(radians(i))*20, sin(radians(i))*20,projectileDamage));
        }
      }
    }
  }
  @Override
    void passive() {
    if (int(random(60))==0)particles.add(new Particle(int(player.x+player.w/2), int(player.y+player.h/2), random(-5, 5), random(-5, 5), int(random(20)+5), 600, 255));
  }
}
class Laser extends Ability {//---------------------------------------------------    Stealth   ---------------------------------
 int damage=40;
  Laser() {
    super();
    name=this.toString();
    activeCost=16;
  } 
  @Override
    void action(Player player) {
    projectiles.add( new ChargeLaser(player.index, int( player.x+player.w/2), int(player.y+player.h/2), player.playerColor, 450, player.angle,damage));
                                
}
  @Override
    void press(Player player) {
    if ((!reverse || player.reverseImmunity)&& energy>0+activeCost && !player.dead && (!freeze || player.freezeImmunity)) {
      stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      player.vx=0;
      player.vy=0;
      player.ax=0;
      player.ay=0;
      action(player);
      deActivate();
    }
  }
}


