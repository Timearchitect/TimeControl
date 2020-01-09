class Turret extends Player implements Containable { 
  Projectile parent;
  long deathTime, spawnTime, duration=100000;
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
    stationary=true;
    allyCollision=true;
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
    stationary=true;
    allyCollision=true;

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
      // shape(arrowSVG,x+w*.5- arrowSVG.width*.5, y-arrowSVG.halfHeight, arrowSVG.width, arrowSVG.height); // default render
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
        for (int i=buffList.size()-1; i>=0; i--) {
          buffList.get(i).update(); 
          if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
        }
      } else {
        for (int i=buffList.size()-1; i>=0; i--) {
          buffList.get(i).update(); 
          if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
        }
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
  /* void pushForce(float _vx, float _vy, float _angle) {
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
  int lvl;
  float angleSpeed=2;
  Player owner;
  // String abilityShortName;

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
    stationary=true;
    targetable=false;
    allyCollision=true;
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
    stationary=true;
    targetable=false;
    allyCollision=true;
  }

  void displayAbilityEnergy() {
  }
  void displayHealth() {
    fraction=(TAU/maxHealth)*health;
    strokeWeight(barSize);
    //strokeCap(SQUARE);
    noFill();
    stroke(hue(playerColor), 80*S, (80-deColor)*S);
    ellipse(cx, cy, radius*1.8, radius*1.8);
    stroke(hue(playerColor), (255-deColor*0.5)*S, ally==-1?0:255*S);
    arc(cx, cy, radius*1.8, radius*1.8, PI_HALF-fraction, PI_HALF);
    //strokeWeight(1);
  }
  void display() {
    if (!stealth) {
      stroke((freeze && !freezeImmunity)?255:0);
      strokeWeight(2);
      fill(255, 0, 255-deColor*0.5, 50+deColor);
      rect(x, y, w, h);
      //displayHealth();
      displayName();

      if (deColor>0)deColor-=int(10*timeBend);
    } else { //stealth
      stroke(255, 40);
      noFill();
      strokeWeight(1);
      rect(x, y, w, h);
    }
    if (freezeImmunity || reverseImmunity || fastforwardImmunity || slowImmunity) {
      noFill();
      rect(x, y, outlineDiameter, outlineDiameter);
    }
  }
  void update() {
    if (!freeze || freezeImmunity) {

      if (reverse && !reverseImmunity) {
        // if (!stationary) {
        cx=x+radius;
        cy=y+radius;
        // }
        angle+=angleSpeed*timeBend;
        keyAngle+=angleSpeed*timeBend;
        for (int i=buffList.size()-1; i>=0; i--) {
          buffList.get(i).update(); 
          if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
        }
      } else {
        for (int i=buffList.size()-1; i>=0; i--) {
          buffList.get(i).update(); 
          if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
        }
        //if (!stationary) {
        cx=x+radius;
        cy=y+radius;
        // }
        angle-=angleSpeed*timeBend;
        keyAngle-=angleSpeed*timeBend;
      }
    }
    // super.update();
    for (Ability p : abilityList) {
      p.passive();
      p.regen();
      if (random(100)<1) {
        p.press();
      }
    }
  }
  void control(int dir) {
  }
  void pushForce(float amount, float angle) {
    if (!stationary) super.pushForce( amount, angle);
  }
  /*void pushForce(float _vx, float _vy, float _angle) {
   if (!stationary) super.pushForce( _vx, _vy, _angle);
   }*/
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
  void death() {
    //ability.onDeath();
    for (Ability a : this.abilityList) {
      a.onDeath();
      a.reset();
    }
    dead=true;
    for (Buff b : this.buffList) {
      b.onOwnerDeath();
    }
    buffList.clear();
    // ability.reset();
    //shakeTimer+=10;
    for (int i=0; i<10; i++) {
      particles.add(new Particle(int(cx), int(cy), random(50)-25, random(50)-25, int(random(40)+30), 1500, playerColor));
    }
    particles.add(new ShockWave(int(cx), int(cy), int(random(40)+10), 16, 400, playerColor));
    //particles.add(new LineWave(int(cx), int(cy), int(random(40)+10), 400, playerColor, random(360)));
    //particles.add(new Flash(900, 8, playerColor));  
    state=0;
    //stamps.add( new StateStamp(index, int(x), int(y), state, health,dead));
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
    particles.add(new Rectwave( int(cx), int(cy), radius, 20, 500, owner.playerColor) );
  }
}
class Illuminati extends Player implements Containable { 
  Projectile parent;
  long deathTime, spawnTime, duration=100000;
  Boolean stationary=true;
  int lvl;
  int ex, ey, abilityDamage;
  float angleSpeed=radians(0);
  Player owner, target;
  int tpInterval=20000, tpTimer;
  String abilityShortName;
  PVector[] tp= {new PVector(), new PVector(), new PVector()};
  Illuminati(int _index, Player _owner, int _x, int _y, int _w, int _h, int _health, Ability ..._ability) {

    super( _index, _owner.playerColor, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;
    owner=_owner;
    this.ally=_owner.ally;
    damage=0;
    abilityDamage=5;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
    radius=int(_w*.5);
    x-=radius;
    y-=radius;
    cx=x+radius;
    cy=y+radius;
    angle=0;
    freezeImmunity=true;
    slowImmunity=true;
    //abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
    for (int i=0; i<tp.length; i++) {
      tp[i].set(_w*.5, 0);
      tp[i].rotate(radians(120*i+30));
    }
  }
  Illuminati(int _index, int _x, int _y, int _w, int _h, int _health, Ability ..._ability) { // nseutral
    super( _index, BLACK, _x, _y, _w, _h, 999, 999, 999, 999, 999, _ability) ;
    damage=0;
    abilityDamage=8;    
    owner=null;
    this.ally=-1;
    turret=true;
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    maxHealth=_health;
    health=maxHealth;
    radius=int(_w*.5);
    x-=radius;
    y-=radius;
    cx=x+radius;
    cy=y+radius;
    freezeImmunity=true;
    slowImmunity=true;
    // abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
    for (PVector  p : tp) {
      p.set(_w, 0);
      p.rotate(radians(120));
    }
  }

  void displayAbilityEnergy() {
  }
  void displayHealth() {
    /*  fraction=((TAU)/maxHealth)*health;
     strokeWeight(barSize);
     //strokeCap(SQUARE);
     noFill();
     stroke(hue(playerColor), 80*S, (80-deColor)*S);
     ellipse(cx, cy, radius*1.8, radius*1.8);
     stroke(hue(playerColor), (255-deColor*0.5)*S, ally==-1?0:255*S);
     arc(cx, cy, radius*1.8, radius*1.8, -HALF_PI +(TAU)-fraction, PI_HALF);*/
    //strokeWeight(1);
  }
  void display() {
    pushMatrix();
    translate(cx, cy);
    rotate(angle);
    if (!stealth) {
      stroke((freeze && !freezeImmunity)?255:0);
      strokeWeight(2);
      fill(255, 0, 255-deColor*0.5, 50+deColor);
      triangle(tp[0].x, tp[0].y, tp[1].x, tp[1].y, tp[2].x, tp[2].y);
      // eye
      //   int ey = int(sin(radians(angle))*150);

      curve(-100, 150, -40, 0, 40, 0, 100, 150);
      curve(-100, -150, -40, 0, 40, 0, 100, -150);
      strokeWeight(2);

      ellipse(ex, ey, 8, 25);

      //displayHealth();
      // displayName();
      if (deColor>0)deColor-=int(10*timeBend);
    } else { //stealth
      noStroke();
      /*  stroke(255, 40);
       noFill();
       strokeWeight(1);
       triangle(tp[0].x, tp[0].y, tp[1].x, tp[1].y, tp[2].x, tp[2].y);*/
    }
    if (freezeImmunity || reverseImmunity || fastforwardImmunity || slowImmunity) {
      noFill();
      triangle(tp[0].x, tp[0].y, tp[1].x, tp[1].y, tp[2].x, tp[2].y);
    }
    popMatrix();
  }
  void update() {
    if (!freeze || freezeImmunity) {

      if (reverse && !reverseImmunity) {
        // if (!stationary) {
        cx=x+radius;
        cy=y+radius;
        // }
        angle+=angleSpeed*timeBend;
        keyAngle+=angleSpeed*timeBend;
        ex=int(cos(radians(angleAgainst(int(cx), int(cy), int(owner.cx), int(owner.cy))))*10);
        ey=int(sin(radians(angleAgainst(int(cx), int(cy), int(owner.cx), int(owner.cy))))*10);
        for (int i=buffList.size()-1; i>=0; i--) {
          buffList.get(i).update(); 
          if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
        }
      } else {
        //if (!stationary) {
        for (int i=buffList.size()-1; i>=0; i--) {
          buffList.get(i).update(); 
          if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
        }
        cx=x+radius;
        cy=y+radius;
        // }
        if (tpTimer+tpInterval<millis()) {


          //  while(target.ally== this.ally || target==AI ){
          //  target=players.get(int(random(players.size()-1)));
          target=seek(this, 3000);

          //  }
          float tempA=calcAngleBetween(this, target)+90;
          tpTimer=millis()+int(random(10000));

          HomingMissile p=new HomingMissile(this, int( this.cx+cos(radians(random(360)))*250), int(this.cy+sin(radians(random(360))*250)), 60, this.playerColor, 8000, this.angle, cos(radians(tempA+90))*-20, sin(radians(tempA+90))*-20, abilityDamage);
          p.target=target;
          //  p.angle=tempA;
          // p.locking();  
          p.reactionTime=40;
          projectiles.add(p);


          /*
          Electron e =new Electron( this, int( this.cx), int(this.cy), 50, this.playerColor, 10000, tempA, -15, -15, damage);
           e.orbitAngleSpeed=3;
           e.distance=200;
           e.derail();
           projectiles.add( e);*/
        }
        angle-=angleSpeed*timeBend;
        keyAngle-=angleSpeed*timeBend;
        target=seek(this, 2500);
        if (target==null) {
          ex=0;
          ey=0;
        } else {
          ex=int(cos(radians(angleAgainst(int(cx), int(cy), int(target.cx), int(target.cy))))*10);
          ey=int(sin(radians(angleAgainst(int(cx), int(cy), int(target.cx), int(target.cy))))*10);
        }
        if (random(5000)<1) { 
          ChargeLaser l =new ChargeLaser(this, int( this.cx+random(50, -50)), int(this.cy+random(50, -50)), 80, this.playerColor, 1000, random(TWO_PI), 0, damage, true);
          l.angle=calcAngleBetween(this, target)+180;
          l.follow=false;
          l.x=cx;
          l.x=cy;


          projectiles.add(l);
        }
        if (stealth) {
          target=seek(this, 350);
          if (target!=null)for (Ability a : this.abilityList)a.press();
        } else {

          if (random(2000)<1) {
            for (Ability a : this.abilityList)a.press();
            x=random(width);
            y=random(height);
          }
        }
      }
    }
    // super.update();
    //abilityList.get(0).passive();
    abilityList.get(0).regen();
    //if (random(100)<1) {
    //  abilityList.get(0).press();
    // }
  }
  void control(int dir) {
  }
  void pushForce(float amount, float angle) {
    if (!stationary) super.pushForce( amount, angle);
  }
  /*void pushForce(float _vx, float _vy, float _angle) {
   if (!stationary) super.pushForce( _vx, _vy, _angle);
   }*/
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
    armor=-15;
    abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
        play(machineSound);

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
    armor=-15;
    abilityShortName=abilityList.get(0).name.substring(0, 1).toUpperCase();
    play(machineSound);
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
      // shape(arrowSVG,x+w*.5- arrowSVG.width*.5, y-arrowSVG.halfHeight, arrowSVG.width, arrowSVG.height); // default render
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
        for (int i=buffList.size()-1; i>=0; i--) {
          buffList.get(i).update(); 
          if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
        }
      } else {
        for (int i=buffList.size()-1; i>=0; i--) {
          buffList.get(i).update(); 
          if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
        }
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

    if (wait>70) {
      for (Ability a : this.abilityList) { 
        a.press();
        a.hold();
      }
    } else wait++;


    //}
  }
  /* void control(int dir) {
   }*/
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
  boolean degenerate=true;
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
    if (type==2)wait=-30;
  }
  FollowDrone(int _index, int _x, int _y, int _w, int _h, int speed, int _health, int _type, Ability ..._ability) {
    super( _index, _x, _y, _w, _h, speed, _health, _ability) ;
    type=_type;
    damage=5;
    armor=-10;
    if (type==2)wait=-30;
  }
  void displayAbilityEnergy() {
  }
  void display() {
    if (!stealth) {
      //stroke((freeze && !freezeImmunity)?255:0);

      if (type==10) {
        stroke(0);
        strokeWeight(8);
        fill(255, 0, 200);
        ellipse(cx, cy, w, h);
      } else {

        stroke(0);
        strokeWeight(2);
        fill(255, 0, 200);
        ellipse(cx, cy, w, h);
        pushMatrix();
        translate(cx, cy);
        rotate(radians(angle+90));
        // shape(arrowSVG,x+w*.5- arrowSVG.width*.5, y-arrowSVG.halfHeight, arrowSVG.width, arrowSVG.height); // default render
        //fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s, 50+deColor);
        shape(arrowSVG, -arrowSVG.width*0.5+30, -arrowSVG.height+0, arrowSVG.width, arrowSVG.height);
        popMatrix();
        fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s);
        //displayAbilityEnergy();
        displayHealth();
        displayName();
        if (deColor>0)deColor-=int(10*s*f);
      }
      //if (cheatEnabled && ability.active)text("A", x+w*0.5, y-h*2);
      //if (cheatEnabled && holdTrigg)text("H", x+w*0.5, y+h*0.5-h);
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
        for (int i=buffList.size()-1; i>=0; i--) {
          buffList.get(i).update(); 
          if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
        }
      } else {
        for (int i=buffList.size()-1; i>=0; i--) {
          buffList.get(i).update(); 
          if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
        }
        if (  degenerate && wait>50)health--;
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
    if (!gameOver) {
      switch(type) {
      case 2:
        target = seek(this, 2200);
        if (target!=null) {
          angle=angleAgainst(int(x), int(y), int(target.x), int(target.y));
          keyAngle=angle;
        }
        if (wait>1) pushForce(0.15, angle);
        if (wait>100) {
          for (Ability a : this.abilityList) { 
            a.press();
            a.hold();
            wait=1;
          }
          wait+=int(random(35));
          if (random(100)<1)
            for (Ability a : this.abilityList)a.release();
        } else wait++;
        break;
      case 3:  // faster
        target = seek(this, 2500);
        if (target!=null) {
          angle=angleAgainst(int(x), int(y), int(target.x), int(target.y));
          keyAngle=angle;
        }
        pushForce(0.5, angle);
        //control(2);
        if (wait>130) {
          for (Ability a : this.abilityList) { 
            a.press();
            a.hold();
            wait=1;
          }
          wait+=int(random(35));
          if (random(100)<1)
            for (Ability a : this.abilityList)a.release();
        } else wait++;
        break;
      case 4:  // sniper Boss
        target = seek(this, 4000);
        if (target!=null) {
          angle=angleAgainst(int(x), int(y), int(target.x), int(target.y));  
          keyAngle=angle;
        }
        pushForce(-0.05, angle);
        //control(2);
        if (wait>130) {
          for (Ability a : this.abilityList) { 
            if (!a.active)a.press();
            a.hold();
            //wait=1;
          }
          wait+=int(random(10));
          if (random(100)<1)
            for (Ability a : this.abilityList)a.release();
        } else wait++;
        break;
      default:
        target = seek(this, 2000);
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
  }
  void control(int dir) {
  }
  void hit(float damage) {
    stamps.add( new StateStamp(index, int(x), int(y), state, health, dead));
    damage=damage-armor;
    if (damage>0) {
      health-=damage;
      // deColor=255;
      //state=2;
      hit=true;
    }
    for (Ability a : this.abilityList) {
      a.onHit();
    }
    // for (int i=0; i<2; i++) {
    // particles.add(new Particle(int(cx), int(cy), random(-10, 10)+vx*0.5, random(-10, 10)+vy*0.5, int(random(5, 20)), 500, playerColor));
    // }
    // invisStampTime=stampTime+invinsTime;
    //invis=true;
    if (health<=0) {
      death();
    }
  }

  void heal(float _health) {
    if (health<maxHealth) {
      health+=_health;
      // deColor=255;
      state=2;
      particles.add(new Particle(int(cx), int(cy), random(-10, 10)+vx*0.5, random(-10, 10)+vy*0.5, int(random(5, 20)), 500, playerColor));
    }
  }
  void wallHit(int _damage) {
    //deColor=255;
    hit=true;
    for (Ability a : this.abilityList) {
      a.wallHit();
    }
  }
  void pushForce(float amount, float angle) {
    vx+=cos(radians(angle))*amount;
    vy+=sin(radians(angle))*amount;
  }
  void death() {
    //ability.onDeath();
    dead=true;


    for (Ability a : this.abilityList) {
      a.onDeath();
      a.reset();
    }
    for (Buff b : this.buffList) {
      b.onOwnerDeath();
    }
    buffList.clear();

    particles.add(new Particle(int(cx), int(cy), vx, vy, w, 2000, playerColor));
    particles.add(new ShockWave(int(cx), int(cy), int(random(40)+10), 16, 400, playerColor));
    state=0;
    stamps.add( new StateStamp(index, int(x), int(y), state, health,dead));
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
class Zombie extends Drone { 

  Player target;
  boolean degenerate=true;
  Zombie(int _index, Player _owner, int _x, int _y, int _w, int _h, int speed, int _health, int _type, Ability ..._ability) {
    super( _index, _owner, _x, _y, _w, _h, speed, _health, _ability) ;
    owner=_owner;
    type=_type;
    armor=-10;
    allyCollision=true;
    degenerate=false;
    damage=2;
  }
  //angle=owner.angle;

  Zombie(int _index, int _x, int _y, int _w, int _h, int speed, int _health, int _type, Ability ..._ability) {
    super( _index, _x, _y, _w, _h, speed, _health, _ability) ;
    type=_type;
    allyCollision=true;
    degenerate=false;
    damage=2;
    armor=-10;
  }
  void displayAbilityEnergy() {
  }
  void display() {
    if (!stealth) {
      stroke(0);
      strokeWeight(8);
      fill(255, 0, 200);
      ellipse(cx, cy, w, h);
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
        if (  degenerate )  health++;
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
        for (int i=buffList.size()-1; i>=0; i--) {
          buffList.get(i).update(); 
          if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
        }
      } else {
        for (int i=buffList.size()-1; i>=0; i--) {
          buffList.get(i).update(); 
          if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
        }
        if (  degenerate )health--;
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
        // keyAngle-=1*timeBend;
      }
    }

    for (Ability a : this.abilityList) {
      a.passive();
      a.regen();
    }
    if (!gameOver) {

      target = seek(this, 1800);
      if (target!=null) {
        angle=angleAgainst(int(x), int(y), int(target.x), int(target.y));
        // keyAngle=angle;
        pushForce(0.1, angle);
      }
    }
  }
  void control(int dir) {
  }
  void hit(float damage) {
    //stamps.add( new StateStamp(index, int(x), int(y), state, health, dead));
    damage=damage-armor;
    if (damage>0) {
      health-=damage;
      // deColor=255;
      //state=2;
      hit=true;
    }
    for (Ability a : this.abilityList) {
      a.onHit();
    }
    // for (int i=0; i<2; i++) {
    // particles.add(new Particle(int(cx), int(cy), random(-10, 10)+vx*0.5, random(-10, 10)+vy*0.5, int(random(5, 20)), 500, playerColor));
    // }
    // invisStampTime=stampTime+invinsTime;
    //invis=true;
    if (health<=0) {
      death();
    }
  }

  void heal(float _health) {
    if (health<maxHealth) {
      health+=_health;
      // deColor=255;
      state=2;
      particles.add(new Particle(int(cx), int(cy), random(-10, 10)+vx*0.5, random(-10, 10)+vy*0.5, int(random(5, 20)), 500, playerColor));
    }
  }
  void wallHit(int _damage) {
    //deColor=255;
    hit=true;
    for (Ability a : this.abilityList) {
      a.wallHit();
    }
  }
  void pushForce(float amount, float angle) {
    vx+=cos(radians(angle))*amount;
    vy+=sin(radians(angle))*amount;
  }
  void death() {
    //ability.onDeath();
    dead=true;
    for (Ability a : this.abilityList) {
      a.onDeath();
      a.reset();
    }
    for (Buff b : this.buffList) {
      b.onOwnerDeath();
    }
    buffList.clear();

    particles.add(new Particle(int(cx), int(cy), vx, vy, w, 2000, playerColor));
    particles.add(new ShockWave(int(cx), int(cy), int(random(40)+10), 16, 400, playerColor));
    state=0;
    //stamps.add( new StateStamp(index, int(x), int(y), state, health,dead));
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
