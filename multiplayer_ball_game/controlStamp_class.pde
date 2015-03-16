class ControlStamp extends TimeStamp{
  float  vx, vy, ax, ay;
  PVector speed,accel;
  ControlStamp(int _player, int _x, int _y, float _vx, float _vy, float _ax, float _ay) {
    super(_player);
    x= _x;
    y= _y;
    vx= _vx;
    vy= _vy;
    ax= _ax;
    ay= _ay;
  }
    ControlStamp(int _player,PVector _coord,PVector _speed,PVector _accel) { // vector
    super(_player);
    coord=_coord;
    speed=_speed;
    accel=_accel;
  }

  void display() {
    super.display();
    point(x,y);
    point(coord.x,coord.y);
  }
  void revert() {
    if (reverse && ! players.get(playerIndex).reverseImmunity && stampTime<time) {
     // players.get(playerIndex).coord=coord;
      players.get(playerIndex).x=x;
      players.get(playerIndex).y=y;
    //  players.get(playerIndex).speed=speed;
      players.get(playerIndex).vx=vx;
      players.get(playerIndex).vy=vy;
     // players.get(playerIndex).accel=accel;
      players.get(playerIndex).ax=ax;
      players.get(playerIndex).ay=ay;
      stamps.remove(this);
      //  super.revert();
    }
  }
}

