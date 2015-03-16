class StateStamp extends TimeStamp {
  int playerState=0;
  int playerHealth=0;
  boolean playerDead;

  StateStamp(int _player, int _x, int _y, int _state, int _health, boolean _dead) {
    super(_player);
    x=_x;
    y=_y;
    playerState=_state;
    playerHealth=_health;
    playerDead=_dead;
  }
  StateStamp(int _player, PVector _coord, int _state, int _health, boolean _dead) {
    super(_player);
    coord=_coord;
    playerState=_state;
    playerHealth=_health;
    playerDead=_dead;
  }

  void display() {
    super.display();
    stroke(255);
    point(x, y);
    point(coord.x, coord.y);
  }

  void revert() {
    if (reverse && ! players.get(playerIndex).reverseImmunity && stampTime<time) {
      players.get(playerIndex).state=playerState;
      players.get(playerIndex).health=playerHealth;
      players.get(playerIndex).dead=playerDead;
      stamps.remove(this);
      // super.revert();
    }
  }
}

class AbilityStamp extends TimeStamp {
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
      background(255);
      players.get(playerIndex).ability.energy=energy;
      players.get(playerIndex).ability.regen=regen;
      players.get(playerIndex).ability.active=active;
      players.get(playerIndex).ability.channeling=channeling;
      players.get(playerIndex).ability.cooling=cooling;
      stamps.remove(this);
      // super.revert();
    }
  }
}

