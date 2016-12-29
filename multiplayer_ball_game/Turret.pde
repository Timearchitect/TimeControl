class Turret extends Player { 
  long deathTime, spawnTime, duration=100000;
  Boolean stationary=true;
  int lvl;
  float angleSpeed=2;
  Player owner;
  String abilityShortName;

  Turret(int _index, Player _owner, int _x, int _y, int _w, int _h, int _health, Ability ..._ability) {

    super( _index, _owner.playerColor, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;
    owner=_owner;
    this.ally=_owner.ally;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
    abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
  }
  Turret(int _index, int _x, int _y, int _w, int _h, int _health, Ability ..._ability) { // nseutral
    super( _index, BLACK, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;

    owner=null;
    this.ally=-1;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
    abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
  }

  void displayAbilityEnergy() {
  }
  void display() {
    if (!stealth) {
      stroke((freeze && !freezeImmunity)?255:0);
      strokeWeight(2);
      fill(255, 0, 255-deColor*0.5, 50+deColor);

      //textMode(CENTER);
      //rect(x, y, w, h);
      ellipse(cx, cy, w, h);

      pushMatrix();
      translate(cx, cy);
      rotate(radians(angle+90));
      // shape(arrowSVG,x+w*.5- arrowSVG.width*.5, y-arrowSVG.height*.5, arrowSVG.width, arrowSVG.height); // default render
      //fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s, 50+deColor);
      shape(arrowSVG, -arrowSVG.width*0.5+30, -arrowSVG.height+0, arrowSVG.width, arrowSVG.height);
      popMatrix();

      //fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s );
      //displayAbilityEnergy();
      displayHealth();
      displayName();

      //if (cheatEnabled && ability.active)text("A", x+w*0.5, y-h*2);
      //if (cheatEnabled && holdTrigg)text("H", x+w*0.5, y+h*0.5-h);
      //if (deColor>0)deColor-=int(10*s*f);
      if (deColor>0)deColor-=int(10*timeBend);
    } else { //stealth
      stroke(255, 40);
      noFill();
      strokeWeight(1);
      ellipse(cx, cy, w, h);
    }
    if (freezeImmunity || reverseImmunity || fastforwardImmunity || slowImmunity) {
      noFill();
      ellipse(cx, cy, outlineDiameter, outlineDiameter);
    }
  }
  void update() {
    if (!freeze || freezeImmunity) {

      if (reverse && !reverseImmunity) {
        //if (!stationary) {
        cx=x+radius;
        cy=y+radius;
        //}
        angle+=angleSpeed*timeBend;
        keyAngle+=angleSpeed*timeBend;
      } else {
        //     if (!stationary) {
        cx=x+radius;
        cy=y+radius;
        // }
        angle-=angleSpeed*timeBend;
        keyAngle-=angleSpeed*timeBend;
      }
    }
    // super.update();
    abilityList.get(0).passive();
    abilityList.get(0).regen();
    if (random(100)<1) {
      abilityList.get(0).press();
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
    //pushStyle();
    fill(playerColor);
    textAlign(CENTER, CENTER);
    textSize(26);
    text(abilityShortName, cx, cy);
    //popStyle();
  }
}
class Drone extends Player  { 
  long deathTime, spawnTime, duration=100000;
  Boolean stationary;
  int lvl, wait, type;
  Player owner;
  String abilityShortName;


  Drone(int _index, Player _owner, int _x, int _y, int _w, int _h, int speed, int _health, Ability ..._ability) {
    super( _index, _owner.playerColor, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;
    owner=_owner;
    this.ally=_owner.ally;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
    damage=5;
    armor=-10;
    abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
  }
  Drone(int _index, int _x, int _y, int _w, int _h, int speed, int _health, Ability ..._ability) { // neutral
    super( _index, BLACK, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;
    owner=null;
    this.ally=-1;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
    damage=5;
    armor=-10;
    abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
  }
  void displayAbilityEnergy() {
  }
  void display() {
    if (!stealth) {
      stroke((freeze && !freezeImmunity)?255:0);
      strokeWeight(2);
      fill(255, 0, 255-deColor*0.5, 50+deColor);

      //textMode(CENTER);
      //rect(x, y, w, h);
      ellipse(cx, cy, w, h);

      pushMatrix();
      translate(cx, cy);
      rotate(radians(angle+90));
      // shape(arrowSVG,x+w*.5- arrowSVG.width*.5, y-arrowSVG.height*.5, arrowSVG.width, arrowSVG.height); // default render
      //fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s, 50+deColor);
      shape(arrowSVG, -arrowSVG.width*0.5+30, -arrowSVG.height+0, arrowSVG.width, arrowSVG.height);
      popMatrix();

      fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s);
      //displayAbilityEnergy();
      displayHealth();
      displayName();
      //if (cheatEnabled && ability.active)text("A", x+w*0.5, y-h*2);
      //if (cheatEnabled && holdTrigg)text("H", x+w*0.5, y+h*0.5-h);
      //if (deColor>0)deColor-=int(10*s*f);
      if (deColor>0)deColor-=int(10*timeBend);
    } else { //stealth
      stroke(255, 40);
      noFill();
      strokeWeight(1);
      ellipse(cx, cy, w, h);
    }
    if (freezeImmunity || reverseImmunity || fastforwardImmunity || slowImmunity) {
      noFill();
      ellipse(cx, cy, outlineDiameter, outlineDiameter);
    }
  }
  void update() {
    if (!freeze || freezeImmunity) {

      if (reverse && !reverseImmunity) {
        if (wait<50)  health++;
        x-=vx;
        y-=vy;
        vx/=1-FRICTION_FACTOR*.5;
        vy/=1-FRICTION_FACTOR*.5;
        //if (!stationary) {
        cx=x+radius;
        cy=y+radius;
        //}
        angle+=1*timeBend;
        keyAngle+=1*timeBend;
      } else {
        if (wait>50)health--;
        if (health<=0)death();
        x+=vx;
        y+=vy;
        vx*=1-FRICTION_FACTOR*.5;
        vy*=1-FRICTION_FACTOR*.5;
        //if (!stationary) {
        cx=x+radius;
        cy=y+radius;
        //}
        angle-=1*timeBend;
        keyAngle-=1*timeBend;
      }
    }
    // super.update();
    for (Ability a : this.abilityList) {
      a.passive();
      a.regen();
    }

    if (wait>50) {
      for (Ability a : this.abilityList) { 
        a.press();
        a.hold();
      }
    } else wait++;

    //}
  }
  void control(int dir) {
  }
  /* void pushForce(float amount, float angle) {
   if (!stationary) super.pushForce( amount, angle);
   }
   void pushForce(float _vx, float _vy, float _angle) {
   if (!stationary) super.pushForce( _vx, _vy, _angle);
   }*/
  void displayName() {
    //pushStyle();
    fill(playerColor);
    textAlign(CENTER, CENTER);
    textSize(26);
    text(abilityShortName, cx, cy);
    //popStyle();
  }
}
class FollowDrone extends Drone { 
  //long deathTime, spawnTime, duration=100000;
  //Boolean stationary;
  //int lvl, wait;
  Player target;


  FollowDrone(int _index, Player _owner, int _x, int _y, int _w, int _h, int speed, int _health, int type, Ability ..._ability) {
    super( _index, _owner, _x, _y, _w, _h, speed, _health, _ability) ;
    owner=_owner;
    //this.ally=_owner.ally;
    //turret=true;
    //spawnTime=stampTime;
    //deathTime=stampTime + duration;
    //maxHealth=_health;
    //health=maxHealth;
    damage=5;
    armor=-10;
    angle=owner.angle;
    //println(abilityList.get(0).name);
  }
  FollowDrone(int _index, int _x, int _y, int _w, int _h, int speed, int _health, int type, Ability ..._ability) {
    super( _index, _x, _y, _w, _h, speed, _health, _ability) ;
    owner=null;
    this.ally=-1;
    //turret=true;
    //spawnTime=stampTime;
    //deathTime=stampTime + duration;
    //maxHealth=_health;
    //health=maxHealth;
    damage=5;
    armor=-10;
    //angle=owner.angle;
    //println(abilityList.get(0).name);
  }
  void displayAbilityEnergy() {
  }
  void display() {
    if (!stealth) {
      stroke((freeze && !freezeImmunity)?255:0);
      strokeWeight(2);
      fill(255, 0, 255-deColor*0.5, 50+deColor);

      //textMode(CENTER);
      //rect(x, y, w, h);
      ellipse(cx, cy, w, h);

      pushMatrix();
      translate(cx, cy);
      rotate(radians(angle+90));
      // shape(arrowSVG,x+w*.5- arrowSVG.width*.5, y-arrowSVG.height*.5, arrowSVG.width, arrowSVG.height); // default render
      //fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s, 50+deColor);
      shape(arrowSVG, -arrowSVG.width*0.5+30, -arrowSVG.height+0, arrowSVG.width, arrowSVG.height);
      popMatrix();

      fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s);
      //displayAbilityEnergy();
      displayHealth();
      displayName();
      //if (cheatEnabled && ability.active)text("A", x+w*0.5, y-h*2);
      //if (cheatEnabled && holdTrigg)text("H", x+w*0.5, y+h*0.5-h);
      if (deColor>0)deColor-=int(10*s*f);
    } else { //stealth
      stroke(255, 40);
      noFill();
      strokeWeight(1);
      ellipse(cx, cy, w, h);
    }

    if (freezeImmunity || reverseImmunity || fastforwardImmunity || slowImmunity) {
      noFill();
      ellipse(cx, cy, w*1.1, h*1.1);
    }
  }
  void update() {
    if (!freeze || freezeImmunity) {

      if (reverse && !reverseImmunity) {
        if (wait<50)  health++;
        x-=vx;
        y-=vy;
        vx/=1-FRICTION_FACTOR*.5;
        vy/=1-FRICTION_FACTOR*.5;
        if (!stationary) {
          cx=x+radius;
          cy=y+radius;
        }
        //angle+=1*timeBend;
        keyAngle+=1*timeBend;
      } else {
        if (wait>50)health--;
        if (health<=0)death();
        x+=vx;
        y+=vy;
        vx*=1-FRICTION_FACTOR*.5;
        vy*=1-FRICTION_FACTOR*.5;
        cx=x+radius;
        cy=y+radius;
        if (owner!=null) { 
          x+=(owner.cx-cx)*.03;
          y+=(owner.cy-cy)*.03;
        }
        //angle-=1*timeBend;
        keyAngle-=1*timeBend;
      }
    }

    for (Ability a : this.abilityList) {
      a.passive();
      a.regen();
    }
    target = seek(this, 1500);
    if (target!=null) {
      angle=angleAgainst(int(x), int(y), int(target.x), int(target.y));
    }
    if (wait>50) {

      wait=20;
      for (Ability a : this.abilityList) { 
        a.press();
        a.hold();
      }
    } else wait++;

    //}
  }
  void control(int dir) {
  }
  /* void pushForce(float amount, float angle) {
   //if (!stationary) super.pushForce( amount, angle);
   }
   void pushForce(float _vx, float _vy, float _angle) {
   //if (!stationary) super.pushForce( _vx, _vy, _angle);
   }*/
  void displayName() {
    //pushStyle();
    fill(playerColor);
    textAlign(CENTER, CENTER);
    textSize(26);
    text(abilityShortName, cx, cy);
    //popStyle();
  }
}