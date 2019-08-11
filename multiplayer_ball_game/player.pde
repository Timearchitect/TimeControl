final int TARGETABLE=0, STATIONARY=1, INVIS=2, STEALTH=3;

class Player implements Cloneable {
  PShape arrowSVG = loadShape("arrow.svg");
  int  index, ally, radius, diameter, outlineDiameter, w, h, up, down, left, right, DEFAULT_UP, DEFAULT_DOWN, DEFAULT_LEFT, DEFAULT_RIGHT, triggKey, deColor;
  int  maxHealth=200, health=maxHealth, damage=1, holdTime;
  byte state=1;
  final int  invinsTime=400, buttonHoldTime=300;
  final byte barSize=12, barDiameter=75;
  final byte mouseMargin=60;
  //float MAX_MOUSE_ACCEL=0.0035;
  final float mouseMaxAccel=1.4;
  float  x, y, vx, vy, ax, ay, cx, cy, angle, keyAngle, f, s, bend, barFraction, fraction, armor, weaponDamage=0, weaponEnergy, weaponSpeed, weaponAttackSpeed, weaponRange, weaponCost, weaponRegen, weaponAccuracy=0, weaponCritChance, weaponCritDamage;
  boolean holdTrigg, holdUp, holdDown, holdLeft, holdRight, dead, hit, arduino, arduinoHold, mouse, clone, turret;
  PVector coord, speed, accel, arrow;
  float DEFAULT_DAMAGE=1, DEFAULT_RADIUS, DEFAULT_MAX_ACCEL=0.15, MAX_ACCEL=DEFAULT_MAX_ACCEL, DEFAULT_ANGLE_FACTOR=0.3, ANGLE_FACTOR=DEFAULT_ANGLE_FACTOR, FRICTION_FACTOR, DEFAULT_FRICTION_FACTOR=0.1, DEFAULT_ARMOR=0; 
  long invinsStampTime, invinsAltStampTime;
  boolean allyCollision=false, invins, invinsAlt=true, freezeImmunity=false, reverseImmunity, fastforwardImmunity, slowImmunity, stationary, stunned, stealth, phase, targetable=true;
  //Ability ability;  
  ArrayList<Ability> abilityList= new ArrayList<Ability>();
  ArrayList<Buff> buffList= new ArrayList<Buff>();
  String label;
  color playerColor;
  Particle textParticle, iconParticle;

  Player(int _index, color _playerColor, int _x, int _y, int _w, int _h, int _up, int _down, int _left, int _right, int _triggKey, Ability ..._ability) {
    DEFAULT_FRICTION_FACTOR=DEFAULT_FRICTION;
    FRICTION_FACTOR=DEFAULT_FRICTION;
    index=_index;
    ally=_index;
    // println("player "+index);
    if (_up==888) {  // mouse Handicap
      mouse=true;
      FRICTION_FACTOR=0.045;
      maxHealth=250+int(addStat(_index, 0))*8;
    }
    maxHealth+=int(addStat(index, 0))*8;
    armor+=int(addStat(index, 3))*.2;
    DEFAULT_ARMOR=armor;
    weaponDamage+=int(addStat(index, 6));
    weaponAttackSpeed+=int(addStat(index, 8));
    //weaponCost+=int(addStat(index,3));
    weaponAccuracy+=int(addStat(index, 7))*3;
    weaponCritChance+=int(addStat(index, 4));
    weaponCritDamage+=int(addStat(index, 5));

    //println("reborn acc:"+weaponAccuracy);
    //ability= _ability[0];
    //ability.setOwner(this);
    //if (_ability[0]==null) ability= new Ability();
    for (Ability a : _ability) {
      this.abilityList.add(a);
      this.abilityList.get(0).setOwner(this);
      a.setOwner(this);
      //if (a==null) this.abilityList.add(new Ability());
    }
    playerColor=_playerColor;
    triggKey=_triggKey;
    /* speed= new PVector(0.0, 0.0);
     accel= new PVector(0.0, 0.0);
     coord= new PVector(_x, _y);
     arrow= new PVector(0.0, 0.0);*/
    x=_x;
    y=_y;
    w=_w;
    h=_h;
    radius=int(_w*0.5);
    diameter=w;
    DEFAULT_RADIUS=radius;
    outlineDiameter=int(radius*2.2);
    cx=x+radius;
    cy=y+radius;
    up=_up;
    down= _down;
    left=_left;
    right=_right;
    DEFAULT_UP=_up;
    DEFAULT_DOWN= _down;
    DEFAULT_LEFT=_left;
    DEFAULT_RIGHT=_right;
    // arrowSVG = loadShape("arrow.svg");
    shapeMode(CENTER);
    arrowSVG.disableStyle();
    shape(arrowSVG, -arrowSVG.width*0.5+30, -arrowSVG.height, arrowSVG.width, arrowSVG.height);
    //if(!clone) buffList.add(new Stun(this, AI, 2000));
    label="P"+(index+1);
  }

  Player setClone(boolean b) {
    clone=b;
    if (clone)  label="P"+ (ally+1);
    else      label="P"+(index+1);
    return this;
  }
  void checkBounds() {
    //if (!reverse && reverseImmunity) {

    if (x<0) {
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      x=0;
      vx=0;
      ax=0;
      cx=x+radius;
      cy=y+radius;
      //accel.set(0.0, accel.y);
      //speed.set(0.0, speed.y);
      //coord.set(int(0.0), int(coord.y));
      wallHit(0);
    } else if (x>width-w) {
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      x=width-w;
      vx=0;
      ax=0;
      cx=x+radius;
      cy=y+radius;
      //coord.set(width-w, coord.y);
      //accel.set(0.0, accel.y);
      //speed.set(0.0, speed.y);
      wallHit(0);
    }
    if (y<0) {
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      y=0;
      vy=0;
      ay=0;
      cx=x+radius;
      cy=y+radius;
      //accel.set(accel.x, 0.0);
      //speed.set(speed.x, 0.0);
      //coord.set(coord.x, 0.0);
      wallHit(0);
    } else if (y>height-h) {
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      y=height-h;
      vy=0;
      ay=0;
      cx=x+radius;
      cy=y+radius;
      //coord.set(coord.x, height-h);
      //speed.set(speed.x, 0.0);
      //accel.set(accel.x, 0.0);
      wallHit(0);
    }
  }

  void display() {
    //println(index+" "+health);
    if (!stealth && !phase && invinsAlt) {
      stroke((freeze && !freezeImmunity)?255:0);
      strokeWeight(2);
      fill(255, 0, 255-deColor*0.5, 50+deColor);
      ellipse(cx, cy, w, h);

      pushMatrix();
      translate(cx, cy);
      rotate(radians(angle+90));
      // shape(arrowSVG,x+radius- arrowSVG.width*.5, y-arrowSVG.halfHeight, arrowSVG.width, arrowSVG.height); // default render
      fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s, 50+deColor);
      shape(arrowSVG, -arrowSVG.width*0.5+30, -30-radius, arrowSVG.width, arrowSVG.height);
      popMatrix();

      //s fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s);
      if (abilityList.size()>0)displayAbilityEnergy(0);
      displayHealth();
      displayName();

      if (debug ) {
        if (abilityList.get(0).active) text("A", cx, y-h*2);
        if (holdTrigg)text("H", cx, cy-h);
      }

      if (deColor>0)deColor-=int(10*s*f);
      if (freezeImmunity || reverseImmunity || fastforwardImmunity || slowImmunity) {
        noFill();
        ellipse(cx, cy, outlineDiameter, outlineDiameter);
      }
    } else { //stealth
      if (!phase) {    
        stroke(255, 40);
        noFill();
        strokeWeight(1);
        ellipse(cx, cy, w, h);
      }
    }
  }

  void update() {
    // println(pow(1-FRICTION,timeBend));
    if (!dead) {
      f =(fastforwardImmunity)?1:F;
      s =(slowImmunity)?1:S;
      bend = f*s;
      if (!freeze || freezeImmunity) {
        calcAngle() ;
        if (reverse && !reverseImmunity) {
          if (invins) invinsAlt=!invinsAlt;

          vy/=1-FRICTION_FACTOR*bend;
          vx/=1-FRICTION_FACTOR*bend;
          //speed.set(speed.x/(1-FRICTION_FACTOR*bend), speed.y/(1-FRICTION_FACTOR*bend));
          ay/=1-FRICTION_FACTOR*bend;
          ax/=1-FRICTION_FACTOR*bend;
          //accel.set(accel.x/(1-FRICTION_FACTOR*bend), accel.y/(1-FRICTION_FACTOR*bend));
          y-=vy*bend;
          x-=vx*bend;
          //coord.set(coord.x-(speed.x*bend), coord.y-(speed.y*bend));
          vy-=ay*bend;
          vx-=ax*bend;
          cx=x+radius;
          cy=y+radius;
          //speed.set(speed.x-(accel.x*bend), speed.y-(accel.y*bend));
          for (int i=buffList.size()-1; i>=0; i--) {
            buffList.get(i).update(); 
            if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
          }
          for (Ability a : abilityList) a.regen();
        } else {
          for (Ability a : abilityList) a.regen();
          for (int i=buffList.size()-1; i>=0; i--) {
            buffList.get(i).update(); 
            if ( buffList.get(i).dead)   buffList.remove( buffList.get(i));
          }
          //speed.set(speed.x+(accel.x*bend), speed.y+(accel.y*bend));
          //speed.set(speed.x*(1-FRICTION_FACTOR*bend), speed.y*(1-FRICTION_FACTOR*bend));
          vx*=1-FRICTION_FACTOR*bend;
          vy*=1-FRICTION_FACTOR*bend;
          // accel.set(accel.x*(1-FRICTION_FACTOR*bend), accel.y*(1-FRICTION_FACTOR*bend));
          ax*=1-FRICTION_FACTOR*bend;
          ay*=1-FRICTION_FACTOR*bend;
          vx+=ax*bend;
          vy+=ay*bend;
          //coord.set(coord.x+(speed.x*bend), coord.y+(speed.y*bend));
          x+=vx*bend;
          y+=vy*bend;
          cx=x+radius;
          cy=y+radius;
          if (invins && invinsStampTime+invinsTime>stampTime) {
            if (invinsAltStampTime+40<stampTime) {
              invinsAlt=!invinsAlt;
              invinsAltStampTime=stampTime;
            }
          } else {
            invinsAlt=true;
            invins=false;
          }
          // calcAngle() ;
        }
      }
      //  ability.passive();
      for (Ability a : this.abilityList)a.passive();
    }
  }

  void control(int dir) {

    if (dir==8) { // ability control
      for (Ability a : this.abilityList) a.press();
      //---------------    hold    --------------------
      holdTime =int(prevMillis-millis());
      if (buttonHoldTime< holdTime) {
        //ability.hold();
        for (Ability a : this.abilityList) a.hold();
        //   TimeSpan t = new TimeSpan(DateTime.Now.Ticks);
      }

      //---------------    released    ----------------
      // if(arduinoHold){
      //key=ability.triggKey;
      //keyPressed();
    }
    if ((!freeze || freezeImmunity) && !dead && (!reverse || reverseImmunity)) {
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      switch(dir) {
      case 0: // down
        // vy+=0.0;
        ay+=MAX_ACCEL*bend;
        //accel.set(accel.x, accel.y+MAX_ACCEL*bend);
        break;
      case 1: // up
        // vy+=-0.0;
        ay+=-MAX_ACCEL*bend;
        //accel.set(accel.x, accel.y-MAX_ACCEL*bend);
        break;
      case 2: // hold  / forward
        ax+=cos(radians(angle))*(MAX_ACCEL*bend);
        ay+=sin(radians(angle))*(MAX_ACCEL*bend);
        //ay=0;
        break;
      case 3: // none/ backwards
        ax-=cos(radians(angle))*(MAX_ACCEL*bend);
        ay-=sin(radians(angle))*(MAX_ACCEL*bend);
        break;
      case 4: // left
        // vx+=-0.0;
        ax+=-MAX_ACCEL*bend;
        // accel.set(accel.x-MAX_ACCEL*bend, accel.y);
        break;
      case 5: // right
        //vx+=0.0;
        ax+=MAX_ACCEL*bend;
        //accel.set(accel.x+MAX_ACCEL*bend, accel.y);
        break;
      }
    }
  }

  void mouseControl() {
    if ((!freeze || freezeImmunity) && !dead && (controlable || reverseImmunity) && mouse && !stunned) {


      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      //*MAX_ACCEL*0.017*s*f;
      //*MAX_MOUSE_ACCEL*s*f;
      if (pmouseX-1<mouseX) {
        ax-=(pmouseX-mouseX)*MAX_ACCEL*0.028*bend;
        if (ax<-mouseMaxAccel) {
          ax=-mouseMaxAccel;
        }
        // players.get(0).control(5);
        if (mouseX<mouseMargin) {
          mouseX=mouseMargin;
          pmouseX=mouseMargin;
        }
      }
      if (pmouseX+1>mouseX) {
        ax-=(pmouseX-mouseX)*MAX_ACCEL*0.028*bend;
        if (players.get(0).ax>mouseMaxAccel) {
          players.get(0).ax=mouseMaxAccel;
        }
        //  players.get(0).control(4);
        if (mouseX>(width-mouseMargin)) {
          mouseX=(width-mouseMargin);
          pmouseX=(width-mouseMargin);
        }
      }
      if (pmouseY-1<mouseY) {
        ay-=(pmouseY-mouseY)*MAX_ACCEL*0.028*bend;
        if (ay<-mouseMaxAccel) {
          ay=-mouseMaxAccel;
        }
        // players.get(0).control(0);
        if (mouseY<mouseMargin) {
          mouseY=mouseMargin;
          pmouseY=mouseMargin;
        }
      }
      if (pmouseY+1>mouseY) {
        ay-=(pmouseY-mouseY)*MAX_ACCEL*0.028*bend;
        if (ay>mouseMaxAccel) {
          ay=mouseMaxAccel;
        }
        // players.get(0).control(1);
        if (mouseY>(height-mouseMargin)) {
          mouseY=(height-mouseMargin);
          pmouseY=(height-mouseMargin);
        }
      }
    }
  }


  void calcAngle() {

    /* if (((-0.01) <accel.y && accel.y<(0.01)) && ((-0.02) <accel.x && accel.x<(0.01))) {  // volitile low value calc of angle is no alowed
     //  println("ax:"+ax + " ay:"+ay);
     } else {
     keyAngle=degrees( atan2( (accel.y+coord.y) - coord.y, (accel.x+coord.x) -coord.x ));
     }*/
    if ((-0.01 <ay && ay<0.01) && (-0.02<ax && ax<0.01)) {  // volitile low value calc of angle is no alowed
      //  println("ax:"+ax + " ay:"+ay);
    } else {
      keyAngle=degrees( atan2( (ay+y) - y, (ax+x) -x ));
    }
    keyAngle= keyAngle % 360; 
    angle = angle % 360; 


    if (debug) {
      line(cx, cy, cx+cos(radians(keyAngle))*200, cy+sin(radians(keyAngle))*200);
      fill(0);
      textSize(20);
      text(angle, x, y);
    }
    /*angle-=keyAngle;
     float diff=keyAngle;
     keyAngle=0;
     
     //if(angle<0)angle+=360;
     if (angle < 360-angle) {
     //  angle+= angle*ANGLE_FACTOR;
     // text(angle, x, y);
     } else {
     //text(angle, x, y);
     // angle-=360-angle*ANGLE_FACTOR;
     }
     keyAngle+=diff;
     angle+=diff;*/
    if (angle<0 && (180+angle)+(180-keyAngle)<keyAngle-angle) {
      //text("L", x-50, y-50);
      angle-= (abs(angle+180)-abs(keyAngle-180))*ANGLE_FACTOR;
      angle+= 360;
    } else if (keyAngle<0 && (180+keyAngle)+(180-angle)<angle-keyAngle) {
      // text("H", x-50, y-50);
      angle+= (abs(keyAngle+180)-abs(angle-180))*ANGLE_FACTOR;
      angle-= 360;
    } else    angle+= (keyAngle-angle)*ANGLE_FACTOR;

    if (Float.isNaN(angle))angle=keyAngle; // if bugged out
  }


  void hit(float damage) {
    if (!phase) {
      damage=damage-armor;
      if(damage<=0) damage = MIN_DAMAGE;
      stamps.add( new StateStamp(index, int(x), int(y), state, health, dead));
      if (damage>0) {
        health-=damage;
        deColor=255;
        state=2;
        hit=true;
      }
      for (Ability a : this.abilityList) {
        a.onHit();
      }
      // for (int i=0; i<2; i++) {
      particles.add(new Particle(int(cx), int(cy), random(-10, 10)+vx*0.5, random(-10, 10)+vy*0.5, int(random(5, 20)), 500, playerColor));
      // }
      // if (damage<10) {
      invinsStampTime=stampTime;
      invins=true;
      // }
      if (health<=0) {
        death();
      }
    }
  }
  void heal(float _health) {
    stamps.add( new StateStamp(index, int(x), int(y), state, health, dead));
    if (health<maxHealth) {
      health+=_health;
      deColor=255;
      state=2;
      particles.add(new Particle(int(cx), int(cy), random(-10, 10)+vx*0.5, random(-10, 10)+vy*0.5, int(random(5, 20)), 500, playerColor));
      invinsStampTime=stampTime+invinsTime;
      invins=true;
    }
  }
  void wallHit(int _damage) {
    stamps.add( new StateStamp(index, int(x), int(y), state, health, dead));
    deColor=255;
    state=2;
    hit=true;
    for (Ability a : this.abilityList) {
      a.wallHit();
    }
    if (!stealth) particles.add(new Particle(int(cx), int(cy), random(-10, 10)+vx*0.5, random(-10, 10)+vy*0.5, int(random(5, 20)), 500, playerColor));
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
    shakeTimer+=10;
    for (int i=0; i<14; i++) {
      particles.add(new Particle(int(cx), int(cy), random(50)-25, random(50)-25, int(random(40)+30), 1500, playerColor));
    }
    particles.add(new ShockWave(int(cx), int(cy), int(random(40)+10), 16, 400, playerColor));
    particles.add(new LineWave(int(cx), int(cy), int(random(40)+10), 400, playerColor, random(360)));
    particles.add(new Flash(900, 8, playerColor));  
    state=0;
    //stamps.add( new StateStamp(index, int(x), int(y), state, health,dead));
  }
  void displayName() {
    fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s);
    textSize(20);
    text(label, cx, cy);
    /* if (clone) {
     text("P"+ (ally+1), cx, cy);
     if (debug) text("index:"+ (index), cx+50, cy);
     } else {
     text("P"+ (index+1), cx, cy);
     // if (cheatEnabled) text("                              vx:"+int(vx)+" vy:"+int(vy)+" ax:"+int(ax)+" ay:"+int(ay) + " A:"+ angle, cx, cy);
     // if (cheatEnabled) text("                              left:"+holdLeft+" right:"+holdRight+" up:"+holdUp+" down:"+holdDown, cx, cy-100);
     }*/
  }
  void displayHealth() {

    fraction=(TAU/maxHealth)*health;
    strokeWeight(barSize);
    //strokeCap(SQUARE);
    noFill();
    stroke(hue(playerColor), 80*S, (80-deColor)*S);
    ellipse(cx, cy, barDiameter, barDiameter);
    stroke(hue(playerColor), (255-deColor*0.5)*S, ally==-1?0:255*S);
    // arc(cx, cy, barDiameter, barDiameter, -HALF_PI +(TAU)-fraction, PI+HALF_PI);
    arc(cx, cy, barDiameter, barDiameter, PI_HALF-fraction, PI_HALF);

    //strokeWeight(1);
  }
  void displayAbilityEnergy(int index ) {
    barFraction=(TAU/abilityList.get(index).maxEnergy)*abilityList.get(index).energy;
    fill(255);
    /*  if (abilityList.get(index).regen) { 
     noStroke();
     } else {
     strokeWeight(6);
     stroke(hue(playerColor), 255*S, 255*S);
     }*/
    arc(cx, cy, barDiameter, barDiameter, PI_HALF-barFraction, PI_HALF);

    //arc(cx, cy, barDiameter, barDiameter, -HALF_PI +(TAU)-barFraction, PI_HALF);
    // strokeWeight(1);
  }
  void pushForce(float amount, float angle) {
    if (!phase) {
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      vx+=cos(radians(angle))*amount;
      vy+=sin(radians(angle))*amount;
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
    }
  }
  void teleport(float _angle, float _amount) {
    x+=cos(radians(_angle))*_amount;
    y+=sin(radians(_angle))*_amount;
  }
  /*void pushForce(float _vx, float _vy, float _angle) {
   stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
   vx+=_vx;
   vy+=_vy;
   stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
   }*/
  void collide(Player e) {
    for (Buff b : buffList) {
      b.onCollide(this, e);
    }
  }
  void addBuff(Buff buff) {
    if (buffList.size()>0) {
      // for (Buff b : buffList) {
      // Buff clone = buff;

      if (buff.type==BuffType.ONCE  &&   existInList(buffList, buff.getClass())) {
      } else {  
        buffList.add(buff);
        buff.transfer(this, this);
      }
      //}
    } else {
      buff.transfer(this, this);
      buffList.add(buff);
    }
  }
  void stop() {
    vx=0;
    vy=0;
    ax=0;
    ay=0;
  }
  void halt() {
    vx=0;
    vy=0;
  }
  void halt(float _percent) {
    vx*=_percent;
    vy*=_percent;
  }
  void reset() {
    vx=0;
    vy=0;
    ax=0;
    ay=0;
    up= DEFAULT_UP;
    down= DEFAULT_DOWN;
    left=DEFAULT_LEFT;
    right=DEFAULT_RIGHT;

    health=maxHealth;
    armor=DEFAULT_ARMOR;
    radius=int(DEFAULT_RADIUS);
    diameter=int(DEFAULT_RADIUS*2);
    outlineDiameter=int(radius*2.2);
    w=diameter;
    h=diameter;
    dead=false;
    invinsAlt=true;
    invinsAltStampTime=stampTime;
    invins=false;
    //ability.reset();
    for (Ability a : this.abilityList) a.reset();
    for (Buff b : this.buffList) b.kill();

    buffList.clear();
    //for (Buff b : this.buffList) b.reset();
  }
  public Player clone() {  
    try {
      Player temp=(Player)super.clone();
      temp.index=players.size();
      for (int i=0; i<abilityList.size(); i++) { // clone all abilities
        Ability tempAbility =abilityList.get(i).clone();
        tempAbility.setOwner(temp);
        temp.abilityList.set(i, tempAbility);
      }

      return temp;
    }
    catch(CloneNotSupportedException c) {
      println(c +" player");
      return null;
    }
  }
  public void replaceAbility(Ability discardA, Ability replacementA) {
    //println(discardA.getClass().getSimpleName() +"  to  " +replacementA.getClass().getSimpleName());
    for (int i=0; i< abilityList.size()-1; i++) {
      // println(abilityList.get(i).getClass().getSimpleName());
      if (abilityList.get(i).getClass().getSimpleName().equals(discardA.getClass().getSimpleName())) {
        abilityList.set(i, replacementA);
        //println("replaced to:"+abilityList.get(i).getClass().getSimpleName());
      }
    }
  }
}
