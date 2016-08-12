class Turret extends Player { 
  long deathTime, spawnTime, duration=100000;
  Boolean stationary=true;
  int lvl;
  Player owner;

  Turret(int _index, Player _owner, int _x, int _y, int _w, int _h, int _health, Ability _ability) {
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
  void display() {
    if (!stealth) {
      stroke((freeze && !freezeImmunity)?255:0);
      strokeWeight(2);
      fill(255, 0, 255-deColor*0.5, 50+deColor);
      textAlign(CENTER, CENTER);
      //textMode(CENTER);
      //rect(x, y, w, h);
      ellipse(x+w*0.5, y+h*0.5, w, h);

      pushMatrix();
      translate(x+w*0.5, y+h*0.5);
      rotate(radians(angle+90));
      // shape(arrowSVG,x+w/2- arrowSVG.width/2, y-arrowSVG.height/2, arrowSVG.width, arrowSVG.height); // default render
      fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s, 50+deColor);
      shape(arrowSVG, -arrowSVG.width*0.5+30, -arrowSVG.height+0, arrowSVG.width, arrowSVG.height);
      popMatrix();

      fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s);
      displayAbilityEnergy();
      displayHealth();
      displayName();

      if (cheatEnabled && ability.active)text("A", x+w*0.5, y-h*2);
      if (cheatEnabled && holdTrigg)text("H", x+w*0.5, y+h*0.5-h);
      if (deColor>0)deColor-=int(10*s*f);
    } else { //stealth
      stroke(255, 40);
      noFill();
      strokeWeight(1);
      ellipse(x+w*0.5, y+h*0.5, w, h);
    }
    if (freezeImmunity || reverseImmunity || fastforwardImmunity || slowImmunity) {
      noFill();
      ellipse(x+w*0.5, y+h*0.5, w*1.1, h*1.1);
    }
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