
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
     for (Player p:players) {
      checkPointStamps.add( new ControlStamp(p.index, int(p.x), int(p.y), p.vx, p.vy, p.ax, p.ay)); //save coords and controll
      checkPointStamps.add( new StateStamp(p.index, int(p.x), int(p.y), p.state, p.health, p.dead)); //save players state
    }

    for (Projectile p:projectiles) {  // clone projectiles
      try {
        clonedProjectiles.add( p.clone());
      }
      catch(CloneNotSupportedException e) {
      }
    }

    for (Particle p:particles) { // clone particles
      try {
        clonedParticles.add( p.clone());
      }
      catch(CloneNotSupportedException e) {
      }
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

  void call() {
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
     for (TimeStamp t:checkPointStamps) {
      t.call();
    }
    musicPlayer.pause(musicPause);
    musicPlayer.setPosition(musicTime);
  }
}

class StateStamp extends TimeStamp {  // save player 
  int playerState=0;
  int playerHealth=0;
  boolean playerDead;
  boolean stealth;
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

  void display() {
    super.display();
    stroke(255);
    point(x, y);
    point(coord.x, coord.y);
  }

  void revert() {
    if (reverse && ! players.get(playerIndex).reverseImmunity && stampTime<time) {
      call();
      stamps.remove(this);
      // super.revert();
    }
  }
  void call() {
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

  void display() {
    super.display();
    stroke(255);
    point(x, y);
    //point(coord.x, coord.y);
  }

  void revert() {
    if (reverse && ! players.get(playerIndex).reverseImmunity && stampTime<time) {
      //background(255);
      call();
      stamps.remove(this);
      // super.revert();
    }
  }
  void call() {
    players.get(playerIndex).abilityList.get(0).energy=energy;
    players.get(playerIndex).abilityList.get(0).regen=regen;
    players.get(playerIndex).abilityList.get(0).active=active;
    players.get(playerIndex).abilityList.get(0).channeling=channeling;
    players.get(playerIndex).abilityList.get(0).cooling=cooling;
  }
}