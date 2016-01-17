class ControlStamp extends TimeStamp {  // save movements & speed 
  float  vx, vy, ax, ay;
  boolean holdLeft, holdRight, holdUp, holdDown, holdTrigg;
  PVector speed, accel;
  ControlStamp(int _player, int _x, int _y, float _vx, float _vy, float _ax, float _ay) {
    super(_player);
    x= _x;
    y= _y;
    vx= _vx;
    vy= _vy;
    ax= _ax;
    ay= _ay;
  }
  ControlStamp(int _player, PVector _coord, PVector _speed, PVector _accel) { // vector
    super(_player);
    coord=_coord;
    speed=_speed;
    accel=_accel;
  }

  void display() {
    super.display();
    point(x, y);
    point(coord.x, coord.y);
  }
  void revert() {
    if (reverse && ! players.get(playerIndex).reverseImmunity && stampTime<time) {
      call();
      //  super.revert();
      stamps.remove(this);
    }
  }
  void call() {
    // players.get(playerIndex).coord=coord;
    players.get(playerIndex).x=x;
    players.get(playerIndex).y=y;
    //  players.get(playerIndex).speed=speed;
    players.get(playerIndex).vx=vx;
    players.get(playerIndex).vy=vy;
    // players.get(playerIndex).accel=accel;
    players.get(playerIndex).ax=ax;
    players.get(playerIndex).ay=ay;
  }
}

class AngleControlStamp extends TimeStamp {  // save angle  
  float  keyAngle, angle, ANGLE_FACTOR;

  AngleControlStamp(int _player, float _keyAngle, float _angle, float _ANGLE_FACTOR) {
    super(_player);
    keyAngle=_keyAngle;
    angle=_angle;
    ANGLE_FACTOR=_ANGLE_FACTOR;
  }


  void display() {
    super.display();
    point(x, y);
    point(coord.x, coord.y);
  }
  void revert() {
    if (reverse && ! players.get(playerIndex).reverseImmunity && stampTime<time) {
      call();
      //  super.revert();
      stamps.remove(this);
    }
  }
  void call() {
    // players.get(playerIndex).coord=coord;
    players.get(playerIndex).keyAngle=this.keyAngle;
    players.get(playerIndex).angle=this.angle;
    players.get(playerIndex).ANGLE_FACTOR= this.ANGLE_FACTOR;
  }
}