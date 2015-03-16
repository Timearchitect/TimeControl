class Ability {
  String name;
  Player player;
  float energy=90, maxEnergy=100, activeCost=5, channelCost, deChannelCost, deactiveCost, cooldown, maxCooldown, regenRate=0.1, ammo, maxAmmo, loadRate;
  boolean active, channeling, cooling, hold=false, regen=true;
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
}



class FastForward extends Ability { //---------------------------------------------------    FastForward   ---------------------------------

  FastForward() {
    super();
    name=this.toString();
    activeCost=8;
    deactiveCost=8;
    active=false;
  }
  @Override
    void action(Player player) {
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






class Freeze extends Ability { //---------------------------------------------------    Freeze   ---------------------------------

  Freeze() {
    super();
    name=this.toString();
    activeCost=16;
    deactiveCost=4;
    active=false;
  }
  @Override
    void action(Player player) {
    if (player.freezeImmunity) {
      for (int i =0; i<4; i++) {
        particles.add( new Feather(500, int(player.x+player.w/2), int(player.y+player.h/2), random(-5, 5), random(-5, 5), 15, player.playerColor));
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
        particles.add(new ShockWave(int(player.x+player.w/2), int(player.y+player.h/2), 20, 150, player.playerColor));
        stamps.add( new ControlStamp(player.index, int(player.x), int( player.y), player.vx, player.vy, player.ax, player.ay));
        action(player);
      }
    } else {
      deActivate();
      particles.add(new ShockWave(int(player.x+player.w/2), int(player.y+player.h/2), 200, 850, player.playerColor));
      action(player);
    }
  }
  @Override
    void deActivate() {
    super.deActivate();
    //  stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
    regen=true;
  }
}




class Reverse extends Ability { //---------------------------------------------------    Reverse   ---------------------------------

  Reverse() {
    super();
    name=this.toString();
    activeCost=16;
    deactiveCost=24;
    active=false;
  }
  @Override
    void action(Player player) {
    loop();
    musicPlayer.pause(false);
    reverse=(reverse)?false:true;
    speedControl.clear();
    speedControl.addSegment((reverse)?-1*S*F:1*S*F, 600); //now rewind
    controlable=(controlable)?false:true;
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
    //  stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
    regen=true;
  }
}





class Slow extends Ability { //---------------------------------------------------    Slow   ---------------------------------

  Slow() {
    super();
    name=this.toString();
    activeCost=4;
    deactiveCost=4;
    active=false;
  }
  @Override
    void action(Player player) {
    //  loop();
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


class throwDagger extends Ability {//---------------------------------------------------    throwDagger   ---------------------------------

  throwDagger() {
    super();
    name=this.toString();
    activeCost=8;
  } 
  @Override
    void action(Player player) {
    projectiles.add( new IceDagger(player.index, int( player.x+player.w/2), int(player.y+player.h/2), 30, player.playerColor, 1000, player.angle, player.ax*20, player.ay*20));
  }
  @Override
    void press(Player player) {
    if ((!reverse || player.reverseImmunity)&& energy>0+activeCost && !player.dead && (!freeze || player.freezeImmunity)) {
      stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
      regen=true;
      activate();
      action(player);
    }
  }
}

class forceShoot extends Ability {//---------------------------------------------------    forceShoot   ---------------------------------
  //boolean charging;
  final float MAX_FORCE=64;
  float forceAmount=0, MODIFIED_MAX_ACCEL=0.04;
  float ChargeRate=0.4, restForce;
  forceShoot() {
    super();
    name=this.toString();
    activeCost=8;
    channelCost=0.1;
  } 
  @Override
    void action(Player player) {
    projectiles.add( new forceBall(player.index, int( player.x+player.w/2), int(player.y+player.h/2), forceAmount, 30, player.playerColor, 2000, player.angle, forceAmount));
  }


  @Override
    void press(Player player) {
    if ((!reverse || player.reverseImmunity) && energy>0+activeCost && !active && !player.dead) {
      activate();
      stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
      regen=false;
    }
    //  projectiles.add( new forceBall(player.index, int( player.x+player.w/2), int(player.y+player.h/2), 30, player.playerColor, 1500, player.angle, player.ax*20, player.ay*20));
  }
  @Override
    void hold(Player player) {

    if ((!reverse || player.reverseImmunity) &&  active && !player.dead) {
      player.MAX_ACCEL=MODIFIED_MAX_ACCEL;
      if (MAX_FORCE>forceAmount) { 
        channel();
        if (!channeling) {
          release(player);
        }
        restForce = MAX_FORCE-forceAmount;
        forceAmount+=ChargeRate*S*F; 
        particles.add(new Particle(int(player.x+player.w/2), int(player.y+player.h/2), random(-restForce/2, restForce/2), random(-restForce/2, restForce/2), int(random(30)+10), 300, player.playerColor));
        particles.add(new ShockWave(int(player.x+player.w/2), int(player.y+player.h/2), int(forceAmount), 50, player.playerColor));
      } else {
        particles.add(new ShockWave(int(player.x+player.w/2), int(player.y+player.h/2), int(forceAmount), 50, color(255, 0, 255)));
        particles.add( new  Particle(int(player.x+player.w/2), int(player.y+player.h/2), 0, 0, int(MAX_FORCE), 50, color(255, 0, 255)));
      }
    }
     if (!active)press(player); // cancel
    if (player.hit)release(player);

  }
  @Override
    void release(Player player) {
    if ((!reverse || player.reverseImmunity) && active) {
      if (!player.dead && (!freeze || player.freezeImmunity)) {
        stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
        regen=true;
        action(player);
        deChannel();
        deActivate();
        player.MAX_ACCEL=player.DEFALUT_MAX_ACCEL;
        forceAmount=0;
      }
    }
  }
}

