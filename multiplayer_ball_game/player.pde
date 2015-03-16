class Player {

  PShape arrowSVG = loadShape("arrow.svg");
  int  index, w, h, up, down, left, right, triggKey, deColor;
  int state=1, health=100, maxHealth=100;
  float x, y, vx, vy, ax, ay, angle, f, s;
  boolean holdTrigg, holdUp, holdDown, holdLeft, holdRight, dead, hit, arduino;
  public PVector coord, speed, accel, arrow;
  float DEFALUT_MAX_ACCEL=0.15, MAX_ACCEL=0.15;
  int invinsTime=400;
  long invisStampTime;
  boolean invis, freezeImmunity=true, reverseImmunity, fastforwardImmunity, slowImmunity;
  Ability ability;  
  color playerColor;
  Player(int _index, color _playerColor, int _x, int _y, int _w, int _h, int _up, int _down, int _left, int _right, int _triggKey, Ability _ability) {
    index=_index;
    ability= _ability;
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
    shape(arrowSVG, -arrowSVG.width/2+30, -arrowSVG.height+0, arrowSVG.width, arrowSVG.height);
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
    } else if (x>width-w) {
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      x=width-w;
      vx=0;
      ax=0;
      coord.set(width-w, coord.y);
      accel.set(0.0, accel.y);
      speed.set(0.0, speed.y);
    }
    if (y<0) {
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      y=0;
      vy=0;
      ay=0;
      accel.set(accel.x, 0.0);
      speed.set(speed.x, 0.0);
      coord.set(coord.x, 0.0);
    } else if (y>height-h) {
      stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
      y=height-h;
      vy=0;
      ay=0;
      coord.set(coord.x, height-h);
      speed.set(speed.x, 0.0);
      accel.set(accel.x, 0.0);
    }
    // }
    /*
    if (coord.x<0) {
     coord.set(0, coord.y);
     } else if (coord.x>width-w) {
     coord.set(width-w, coord.y);
     }
     if (coord.y<0) {
     coord.set(coord.x, 0);
     } else if (coord.y>height-h) {
     coord.set(coord.x, height-h);
     }*/
  }

  void display() {

    stroke((freeze && !freezeImmunity)?255:0);
    strokeWeight(2);
    fill(255, 0, 255-deColor/2, 50+deColor);
    textAlign(CENTER, CENTER);
    textMode(CENTER);
    //rect(x, y, w, h);
    ellipse(x+w/2, y+h/2, w, h);
    //line((100)*cos(radians(angle))+x+(50), (100)*sin(radians(angle))+y+(50), x+(50), y+(50)); // lineangle
    // ellipse((100)*cos(radians(angle))+x+w/2, (100)*sin(radians(angle))+y+h/2, 50, 50); 
    //tint(255, 255*S, 255);
    pushMatrix();
    translate(x+w/2, y+h/2);
    rotate(radians(angle+90));
    // shape(arrowSVG,x+w/2- arrowSVG.width/2, y-arrowSVG.height/2, arrowSVG.width, arrowSVG.height); // default render
    fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s, 50+deColor);
    shape(arrowSVG, -arrowSVG.width/2+30, -arrowSVG.height+0, arrowSVG.width, arrowSVG.height);
    popMatrix();
    fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s);
    displayAbilityEnergy();
    displayHealth();
    fill(hue(playerColor), saturation(playerColor)*s, brightness(playerColor)*s);
    text("P"+ (index+1), x+w/2, y+h/2);
    
    if (ability.active)text("A", x+w/2, y+h/2-h*2);
    if (holdTrigg)text("H", x+w/2, y+h/2-h);
    
    if (deColor>0)deColor-=int(10*s*f);
  }

  void update() {
    // println(pow(0.9,f));
    if (!dead) {
      f =(fastforwardImmunity)?1:F;
      s =(slowImmunity)?1:S;
      if (!freeze || freezeImmunity) {
        calcAngle() ;
        if (reverse && !reverseImmunity) {
          vy/=1-FRICTION*f*s;
          vx/=1-FRICTION*f*s;
          speed.set(speed.x/(1-FRICTION*f*s), speed.y/(1-FRICTION*f*s));
          ay/=1-FRICTION*f*s;
          ax/=1-FRICTION*f*s;
          accel.set(accel.x/(1-FRICTION*f*s), accel.y/(1-FRICTION*f*s));
          y-=vy*f*s;
          x-=vx*f*s;
          coord.set(coord.x-(speed.x*f*s), coord.y-(speed.y*f*s));
          vy-=ay*f*s;
          vx-=ax*f*s;
          speed.set(speed.x-(accel.x*f*s), speed.y-(accel.y*f*s));
          ability.regen(this);
        } else {
          ability.regen(this);
          speed.set(speed.x+(accel.x*f*s), speed.y+(accel.y*f*s));
          vx+=ax*f*s;
          vy+=ay*f*s;
          coord.set(coord.x+(speed.x*f*s), coord.y+(speed.y*f*s));
          x+=vx*f*s;
          y+=vy*f*s;
          speed.set(speed.x*(1-FRICTION*f*s), speed.y*(1-FRICTION*f*s));
          vx*=1-FRICTION*f*s;
          vy*=1-FRICTION*f*s;
          accel.set(accel.x*(1-FRICTION*f*s), accel.y*(1-FRICTION*f*s));
          ax*=1-FRICTION*f*s;
          ay*=1-FRICTION*f*s;
        }
      }
    }
    
  
  }


  void control(int dir) {
    if (dir==8) { // ability control
      //background(255);
      ability.press(this); 
      //key=ability.triggKey;
      //keyPressed();
    }
    if ((!freeze || freezeImmunity) && !dead) {
      if (controlable || reverseImmunity) {
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
  }

  void calcAngle() {
    if (((-0.01) <accel.y && accel.y<(0.01)) && ((-0.01) <accel.x && accel.x<(0.01))) {  // volitile low value calc of angle is no alowed
      //  println("ax:"+ax + " ay:"+ay);
    } else {
      angle=degrees( atan2( (accel.y+coord.y) - coord.y, (accel.x+coord.x) -coord.x ));
    }
    if (((-0.01) <ay && ay<(0.01)) && ((-0.01) <ax && ax<(0.01))) {  // volitile low value calc of angle is no alowed
      //  println("ax:"+ax + " ay:"+ay);
    } else {
      angle=degrees( atan2( (ay+y) - y, (ax+x) -x ));
    }
    //arrow.set(sin(radians(angle)),cos(radians(angle)));
  }


  void hit(int damage) {
    stamps.add( new StateStamp(index, int(x), int(y), state, health, dead));
    health-=damage;
    deColor=255;
    state=2;
    hit=true;
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x+w/2), int(y+h/2), random(20)-10+vx/2, random(20)-10+vy/2, int(random(20)+5), 500, playerColor));
    }
  //  println("hit");
    if (health<0) {
      dead=true;
      shakeTimer=50;
      for (int i=0; i<64; i++) {
        particles.add(new Particle(int(x+w/2), int(y+h/2), random(50)-25, random(50)-25, int(random(40)+10), 1500, playerColor));
      }
      particles.add(new ShockWave(int(x+w/2), int(y+h/2), int(random(40)+10), 500, playerColor));
      particles.add(new LineWave(int(x+w/2), int(y+h/2), int(random(40)+10), 500, playerColor));
      particles.add(new Flash(1000, 8, playerColor));  
      state=0;
      invisStampTime=millis()+invinsTime;
      invis=true;
      //stamps.add( new StateStamp(index, int(x), int(y), state, health,dead));
    }
  }

  void displayHealth() {
    int barSize=12, barDiameter=75;
    float fraction=((PI*2)/maxHealth)*health;
    strokeWeight(barSize);
    strokeCap(SQUARE);
    noFill();
    stroke(hue(playerColor), 100*S, (100-deColor)*S);
    ellipse(x+w/2, y+h/2, barDiameter, barDiameter);
    stroke(hue(playerColor), (255-deColor/2)*S, 255*S);
    arc(x+w/2, y+h/2, barDiameter, barDiameter, -HALF_PI +(PI*2)-fraction, PI+HALF_PI);
    strokeWeight(1);
  }
  void displayAbilityEnergy() {
    int  barDiameter=100;
    float fraction=((PI*2)/ability.maxEnergy)*ability.energy;
    fill(255);
    
    if (ability.regen) { 
      noStroke();
    } else {
      strokeWeight(5);
      stroke(hue(playerColor), 255*S, 255*S);
    }
    arc(x+w/2, y+h/2, barDiameter, barDiameter, -HALF_PI +(PI*2)-fraction, PI+HALF_PI);
    strokeWeight(1);
  }
}

