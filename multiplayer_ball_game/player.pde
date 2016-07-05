class Player {
  PShape arrowSVG = loadShape("arrow.svg");
  int  index, ally, w, h, up, down, left, right, triggKey, deColor;
  int state=1, health=300, maxHealth=300, barDiameter=100, damage=1;
  float  x, y, vx, vy, ax, ay, angle, keyAngle, f, s, barFraction;
  boolean holdTrigg, holdUp, holdDown, holdLeft, holdRight, dead, stealth, hit, arduino, arduinoHold, mouse, clone, turret;
  public PVector coord, speed, accel, arrow;
  float DEFAULT_MAX_ACCEL=0.15, MAX_ACCEL=DEFAULT_MAX_ACCEL, DEFAULT_ANGLE_FACTOR=0.3, ANGLE_FACTOR=DEFAULT_ANGLE_FACTOR, friction;
  int invinsTime=400, buttonHoldTime=300;
  long invisStampTime;
  boolean invis, freezeImmunity, reverseImmunity, fastforwardImmunity, slowImmunity;
  Ability ability;  
  color playerColor;
  Player(int _index, color _playerColor, int _x, int _y, int _w, int _h, int _up, int _down, int _left, int _right, int _triggKey, Ability _ability) {
    friction=FRICTION;
    if (_up==888) { 
      mouse=true;
      friction=0.045;
      maxHealth=400;
      health=maxHealth;
    }
    index=_index;
    ally=_index;
    ability= _ability;
    ability.setOwner(this);
    if (_ability==null) ability= new Ability();

    playerColor=_playerColor;
    triggKey=_triggKey;
    speed= new PVector(0.0, 0.0);
    accel= new PVector(0.0, 0.0);
    coord= new PVector(_x, _y);
    arrow= new PVector(0.0, 0.0);
    x=_x;
    y=_y;
    w=_w;
    h=_h;

    up=_up;
    down= _down;
    left=_left;
    right=_right;
    // arrowSVG = loadShape("arrow.svg");
    shapeMode(CENTER);
    arrowSVG.disableStyle();
    shape(arrowSVG, -arrowSVG.width*0.5+30, -arrowSVG.height+0, arrowSVG.width, arrowSVG.height);
  }
  void checkBounds() {
    //if (!reverse && reverseImmunity) {
    if (x<0) {
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      x=0;
      vx=0;
      ax=0;
      accel.set(0.0, accel.y);
      speed.set(0.0, speed.y);
      coord.set(int(0.0), int(coord.y));
      hit(0);
    } else if (x>width-w) {
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      x=width-w;
      vx=0;
      ax=0;
      coord.set(width-w, coord.y);
      accel.set(0.0, accel.y);
      speed.set(0.0, speed.y);
      hit(0);
    }
    if (y<0) {
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      y=0;
      vy=0;
      ay=0;
      accel.set(accel.x, 0.0);
      speed.set(speed.x, 0.0);
      coord.set(coord.x, 0.0);
      hit(0);
    } else if (y>height-h) {
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      y=height-h;
      vy=0;
      ay=0;
      coord.set(coord.x, height-h);
      speed.set(speed.x, 0.0);
      accel.set(accel.x, 0.0);
      hit(0);
    }
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
    // println(pow(1-FRICTION,F*S));
    if (!dead) {
      f =(fastforwardImmunity)?1:F;
      s =(slowImmunity)?1:S;
      if (!freeze || freezeImmunity) {
        calcAngle() ;
        if (reverse && !reverseImmunity) {

          vy/=1-friction*f*s;
          vx/=1-friction*f*s;
          speed.set(speed.x/(1-friction*f*s), speed.y/(1-friction*f*s));
          ay/=1-friction*f*s;
          ax/=1-friction*f*s;
          accel.set(accel.x/(1-friction*f*s), accel.y/(1-friction*f*s));
          y-=vy*f*s;
          x-=vx*f*s;
          coord.set(coord.x-(speed.x*f*s), coord.y-(speed.y*f*s));
          vy-=ay*f*s;
          vx-=ax*f*s;
          speed.set(speed.x-(accel.x*f*s), speed.y-(accel.y*f*s));
          ability.regen();
        } else {
          ability.regen();
          speed.set(speed.x+(accel.x*f*s), speed.y+(accel.y*f*s));
          vx+=ax*f*s;
          vy+=ay*f*s;
          coord.set(coord.x+(speed.x*f*s), coord.y+(speed.y*f*s));
          x+=vx*f*s;
          y+=vy*f*s;
          speed.set(speed.x*(1-friction*f*s), speed.y*(1-friction*f*s));
          vx*=1-friction*f*s;
          vy*=1-friction*f*s;
          accel.set(accel.x*(1-friction*f*s), accel.y*(1-friction*f*s));
          ax*=1-friction*f*s;
          ay*=1-friction*f*s;
          // calcAngle() ;
        }
      }
      ability.passive();
    }
  }

  void control(int dir) {
    if (dir==8) { // ability control
      ability.press(); 

      //---------------    hold    --------------------
      int temp =int(prevMillis-millis());
      if (buttonHoldTime< temp) {

        ability.hold();
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
        ay+=MAX_ACCEL*f*s;
        accel.set(accel.x, accel.y+MAX_ACCEL*f*s);
        break;
      case 1: // up
        // vy+=-0.0;
        ay+=-MAX_ACCEL*f*s;
        accel.set(accel.x, accel.y-MAX_ACCEL*f*s);
        break;
      case 2: // hold
        //ay=0;
        break;
      case 3: // none
        break;
      case 4: // left
        // vx+=-0.0;
        ax+=-MAX_ACCEL*f*s;
        accel.set(accel.x-MAX_ACCEL*f*s, accel.y);
        break;
      case 5: // right
        //vx+=0.0;
        ax+=MAX_ACCEL*f*s;
        accel.set(accel.x+MAX_ACCEL*f*s, accel.y);
        break;
      }
    }
  }

  void mouseControl() {
    if ((!freeze || freezeImmunity) && !dead && (controlable || reverseImmunity) && mouse) {
      int margin=200;
      float MAX_MOUSE_ACCEL=0.0035;
      float maxAccel=1.4;

      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      //*MAX_ACCEL*0.017*s*f;
      //*MAX_MOUSE_ACCEL*s*f;
      if (pmouseX-1<mouseX) {
        ax-=(pmouseX-mouseX)*MAX_ACCEL*0.028*s*f;
        if (ax<-maxAccel) {
          ax=-maxAccel;
        }
        // players.get(0).control(5);
        if (mouseX<margin) {
          mouseX=margin;
          pmouseX=margin;
        }
      }
      if (pmouseX+1>mouseX) {
        ax-=(pmouseX-mouseX)*MAX_ACCEL*0.028*s*f;
        if (players.get(0).ax>maxAccel) {
          players.get(0).ax=maxAccel;
        }
        //  players.get(0).control(4);
        if (mouseX>(width-margin)) {
          mouseX=(width-margin);
          pmouseX=(width-margin);
        }
      }
      if (pmouseY-1<mouseY) {
        ay-=(pmouseY-mouseY)*MAX_ACCEL*0.028*s*f;
        if (ay<-maxAccel) {
          ay=-maxAccel;
        }
        // players.get(0).control(0);
        if (mouseY<margin) {
          mouseY=margin;
          pmouseY=margin;
        }
      }
      if (pmouseY+1>mouseY) {
        ay-=(pmouseY-mouseY)*MAX_ACCEL*0.028*s*f;
        if (ay>maxAccel) {
          ay=maxAccel;
        }
        // players.get(0).control(1);
        if (mouseY>(height-margin)) {
          mouseY=(height-margin);
          pmouseY=(height-margin);
        }
      }
    }
  }


  void calcAngle() {

    if (((-0.01) <accel.y && accel.y<(0.01)) && ((-0.02) <accel.x && accel.x<(0.01))) {  // volitile low value calc of angle is no alowed
      //  println("ax:"+ax + " ay:"+ay);
    } else {
      keyAngle=degrees( atan2( (accel.y+coord.y) - coord.y, (accel.x+coord.x) -coord.x ));
    }
    if (((-0.01) <ay && ay<(0.01)) && ((-0.02) <ax && ax<(0.01))) {  // volitile low value calc of angle is no alowed
      //  println("ax:"+ax + " ay:"+ay);
    } else {
      keyAngle=degrees( atan2( (ay+y) - y, (ax+x) -x ));
    }
    keyAngle= keyAngle % 360; 
    angle = angle % 360; 
    //angle-= (angle-keyAngle)*0.2;
    angle+= (keyAngle-angle)*ANGLE_FACTOR;
    if (Float.isNaN(angle))angle=keyAngle; // if bugged out
  }


  void hit(int damage) {
    stamps.add( new StateStamp(index, int(x), int(y), state, health, dead));
    health-=damage;
    deColor=255;
    state=2;
    hit=true;
    // for (int i=0; i<2; i++) {
    particles.add(new Particle(int(x+w*0.5), int(y+h*0.5), random(-10, 10)+vx*0.5, random(-10, 10)+vy*0.5, int(random(5, 20)), 500, playerColor));
    // }
    invisStampTime=millis()+invinsTime;
    invis=true;
    if (health<0) {
      death();
    }
  }

  void death() {
    dead=true;
    shakeTimer=20;
    for (int i=0; i<64; i++) {
      particles.add(new Particle(int(x+w*0.5), int(y+h*0.5), random(50)-25, random(50)-25, int(random(40)+10), 1500, playerColor));
    }
    particles.add(new ShockWave(int(x+w*0.5), int(y+h*0.5), int(random(40)+10), 400, playerColor));
    particles.add(new LineWave(int(x+w*0.5), int(y+h*0.5), int(random(40)+10), 400, playerColor, random(360)));
    particles.add(new Flash(900, 8, playerColor));  
    state=0;
    //stamps.add( new StateStamp(index, int(x), int(y), state, health,dead));
  }
  void displayName() {
    fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s);
    if (clone) {
      text("P"+ (ally+1), x+w*0.5, y+h*0.5);
    } else {
      text("P"+ (index+1), x+w*0.5, y+h*0.5);
      // if (cheatEnabled) text("                              vx:"+int(vx)+" vy:"+int(vy)+" ax:"+int(ax)+" ay:"+int(ay) + " A:"+ angle, x+w*0.5, y+h*0.5);
      // if (cheatEnabled) text("                              left:"+holdLeft+" right:"+holdRight+" up:"+holdUp+" down:"+holdDown, x+w*0.5, y+h*0.5-100);
    }
  }
  void displayHealth() {
    int barSize=12, barDiameter=75;
    float fraction=((PI*2)/maxHealth)*health;
    strokeWeight(barSize);
    strokeCap(SQUARE);
    noFill();
    stroke(hue(playerColor), 80*S, (80-deColor)*S);
    ellipse(x+w*0.5, y+h*0.5, barDiameter, barDiameter);
    stroke(hue(playerColor), (255-deColor*0.5)*S, 255*S);
    arc(x+w*0.5, y+h*0.5, barDiameter, barDiameter, -HALF_PI +(PI*2)-fraction, PI+HALF_PI);
    strokeWeight(1);
  }
  void displayAbilityEnergy() {
    barFraction=((PI*2)/ability.maxEnergy)*ability.energy;
    fill(255);
    if (ability.regen) { 
      noStroke();
    } else {
      strokeWeight(5);
      stroke(hue(playerColor), 255*S, 255*S);
    }
    arc(x+w*0.5, y+h*0.5, barDiameter, barDiameter, -HALF_PI +(PI*2)-barFraction, PI+HALF_PI);
    strokeWeight(1);
  }
  void pushForce(float amount, float angle) {
    stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
    vx+=cos(radians(angle))*amount;
    vy+=sin(radians(angle))*amount;
    stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
  }
  void pushForce(float _vx, float _vy, float _angle) {
    stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
    vx+=_vx;
    vy+=_vy;
    stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
  }
  void reset() {
    vx=0;
    vy=0;
    ax=0;
    ay=0;
    health=maxHealth;
    dead=false;
    ability.reset();
  }
}