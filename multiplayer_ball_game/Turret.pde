class Turret extends Player { 
  long deathTime, spawnTime, duration=100000;
  Boolean stationary=true;
  Player owner;

  Turret(int _index, Player _owner, int _x, int _y, int _w, int _h,int _health, Ability _ability) {
    super( _index, _owner.playerColor, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;
    owner=_owner;
    this.ally=_owner.index;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
  }
  void displayAbilityEnergy() {
  }

  void update() {
    if (!freeze || freezeImmunity) {

      if (reverse && !reverseImmunity) {

        angle+=1*F*S;
        keyAngle+=1*F*S;
      } else {
        angle-=1*F*S;
        keyAngle-=1*F*S;
      }
    }
    super.update();

    if (random(100)<1) {
      ability.press();
    }
  }
  void control(int dir) {
  }
  void pushForce(float amount, float angle) {
    if (!stationary) super.pushForce( amount, angle);
  }
  void pushForce(float _vx, float _vy, float _angle) {
    if (!stationary) super.pushForce( _vx, _vy, _angle);
  }
  void displayName() {
  }
}