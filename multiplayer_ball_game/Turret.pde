class Turret extends Player implements Containable { 
  Projectile parent;
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
  Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  void unWrap() {
    //resetDuration();
    cx=parent.x;
    cy=parent.y;
    x=cx-w*.5;
    y=cy-h*.5;
    radius=int(w*.5);
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    // vel.rotate(radians(parent.angle));
    vel.add(pVel);
    float deltaX = 0 - vel.x;
    float deltaY = 0 - vel.y;

    angle+= atan2(deltaY, deltaX); // In radians
    //angle=90;
    vx=vel.x;
    vy=vel.y;
  }
}
class Block extends Player implements Containable { 
  Projectile parent;
  long deathTime, spawnTime, duration=100000;
  Boolean stationary=true;
  int lvl;
  float angleSpeed=2;
  Player owner;
  String abilityShortName;

  Block(int _index, Player _owner, int _x, int _y, int _w, int _h, int _health, Ability ..._ability) {

    super( _index, _owner.playerColor, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;
    owner=_owner;
    this.ally=_owner.ally;
    damage=0;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
    abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
  }
  Block(int _index, int _x, int _y, int _w, int _h, int _health, Ability ..._ability) { // nseutral
    super( _index, BLACK, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;
   damage=0;
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
    void displayHealth() {
    fraction=((PI*2)/maxHealth)*health;
    strokeWeight(barSize);
    //strokeCap(SQUARE);
    noFill();
    stroke(hue(playerColor), 80*S, (80-deColor)*S);
    ellipse(cx, cy, radius*1.8, radius*1.8);
    stroke(hue(playerColor), (255-deColor*0.5)*S, ally==-1?0:255*S);
    arc(cx, cy, radius*1.8, radius*1.8, -HALF_PI +(PI*2)-fraction, PI+HALF_PI);
    //strokeWeight(1);
  }
  void display() {
    if (!stealth) {
      stroke((freeze && !freezeImmunity)?255:0);
      strokeWeight(2);
      fill(255, 0, 255-deColor*0.5, 50+deColor);

      //textMode(CENTER);
      //rect(x, y, w, h);
      rect(x, y, w, h);

     // pushMatrix();
     // translate(cx, cy);
      //rotate(radians(angle+90));
      // shape(arrowSVG,x+w*.5- arrowSVG.width*.5, y-arrowSVG.height*.5, arrowSVG.width, arrowSVG.height); // default render
      //fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s, 50+deColor);
     // shape(arrowSVG, -arrowSVG.width*0.5+30, -arrowSVG.height+0, arrowSVG.width, arrowSVG.height);
      //popMatrix();

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
      rect(x, y, w, h);

    }
    if (freezeImmunity || reverseImmunity || fastforwardImmunity || slowImmunity) {
      noFill();
       rect(x, y,  outlineDiameter, outlineDiameter);

     // ellipse(cx, cy, outlineDiameter, outlineDiameter);
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
   // fill(playerColor);
   // textAlign(CENTER, CENTER);
   // textSize(26);
   // text(abilityShortName, cx, cy);
    //popStyle();
  }
  Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  void unWrap() {
    //resetDuration();
    cx=parent.x;
    cy=parent.y;
    x=cx-w*.5;
    y=cy-h*.5;
    radius=int(w*.5);
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    // vel.rotate(radians(parent.angle));
    vel.add(pVel);
    float deltaX = 0 - vel.x;
    float deltaY = 0 - vel.y;

    angle+= atan2(deltaY, deltaX); // In radians
    //angle=90;
    vx=vel.x;
    vy=vel.y;
  }
}

class Drone extends Player { 
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
    switch(type) {
    case 2:
      seek(this, 1000);

      break;
    }

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

  Player target;


  FollowDrone(int _index, Player _owner, int _x, int _y, int _w, int _h, int speed, int _health, int _type, Ability ..._ability) {
    super( _index, _owner, _x, _y, _w, _h, speed, _health, _ability) ;
    owner=_owner;
    type=_type;
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
  FollowDrone(int _index, int _x, int _y, int _w, int _h, int speed, int _health, int _type, Ability ..._ability) {
    super( _index, _x, _y, _w, _h, speed, _health, _ability) ;
    //owner=null;
    //this.ally=-1;
    //turret=true;
    //spawnTime=stampTime;
    //deathTime=stampTime + duration;
    //maxHealth=_health;
    //health=maxHealth;
    type=_type;
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
    switch(type) {
    case 2:
      target = seek(this, 1500);
      if (target!=null) {
        angle=angleAgainst(int(x), int(y), int(target.x), int(target.y));
      }
      pushForce(0.3, angle);
      break;
    default:
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
    }
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