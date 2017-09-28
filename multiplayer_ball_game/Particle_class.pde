
class Particle  implements Cloneable {
  int  size, opacity=255;
  float x, y, vx, vy, angle;
  long spawnTime, deathTime, time;
  color particleColor;
  boolean dead, meta;
  //  int f;
  Particle(int _x, int _y, float _vx, float _vy, int _size, int _time, color _particleColor) {
    time=_time;
    size=_size;
    spawnTime=stampTime;
    deathTime=stampTime + _time;
    particleColor= _particleColor;
    // opacity=255;
    x= _x;
    y= _y;
    vx= _vx;
    vy= _vy;
  }

  void update() {
    if (!dead && !freeze) { 
      // f =(fastForward)?speedFactor:1;
      if (reverse) {
        opacity+=8*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        opacity-=8*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
    }
  }

  void display() {
    if (!dead ) {
      fill(particleColor, opacity);
      noStroke();
      ellipse(x, y, size, size);
    }
  }
  void revert() {
    if (reverse && stampTime<spawnTime) {
      particles.remove(this);
    } else if (stampTime>deathTime) {
      dead=true;
    } else if (stampTime<deathTime) {
      dead=false;
    }
  }
  public Particle clone() {  
    try {
      return (Particle)super.clone();
    }
    catch(CloneNotSupportedException e) {
      println(e+" particle");
      return null;
    }
  }
}

//-------------------------------------------------------------//    RParticles    //-------------------------------------------------------------------------

class RParticles extends Particle {
  RParticles(int _x, int _y, float _vx, float _vy, int _size, int _time, color _particleColor) {
    super( _x, _y, _vx, _vy, _size, _time, _particleColor);
    opacity=0;
    x=_vx*_time*.06+_x;
    y=_vy*_time*.06+_y;
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        opacity-=8*F;
        x+=vx*timeBend;
        y+=vy*timeBend;
      } else {
        opacity+=8*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      }
    }
  }
  /* void display() {
   if (!dead ) {  
   noFill();
   stroke(hue(particleColor), saturation(particleColor), brightness(particleColor)*S, opacity);
   strokeWeight(int(0.1*opacity));
   ellipse(x, y, size, size);
   }
   }*/
}
//-------------------------------------------------------------//    ShockWave    //-------------------------------------------------------------------------

class ShockWave extends Particle {
  int sizeRate, halfSizeRate;
  ShockWave(int _x, int _y, int _size, int _sizeRate, int _time, color _particleColor) {
    super( _x, _y, 0, 0, _size, _time, _particleColor);
    sizeRate=_sizeRate;
    halfSizeRate=int(sizeRate*0.5);
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        size-=sizeRate*timeBend;
        opacity+=halfSizeRate*timeBend;
      } else {
        size+=sizeRate*timeBend;
        opacity-=halfSizeRate*timeBend;
        if (opacity<=0) {
          dead=true;
          deathTime=stampTime;
        }
      }
    }
  }
  void display() {
    if (!dead ) {  
      noFill();
      stroke(hue(particleColor), saturation(particleColor), brightness(particleColor)*S, opacity);
      strokeWeight(int(0.1*opacity));
      ellipse(x, y, size, size);
    }
  }
}

class RShockWave extends ShockWave {

  RShockWave(int _x, int _y, int _size, int _sizeRate, int _time, color _particleColor) {
    super( _x, _y, _size, _sizeRate, _time, _particleColor);
    opacity=0;
    halfSizeRate=int(sizeRate*0.5);
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        size+=sizeRate*timeBend;
        opacity-=halfSizeRate*timeBend;
      } else {
        size-=sizeRate*timeBend;
        opacity+=halfSizeRate*timeBend;
        if (size<=0)dead=true;
      }
    }
  }
}
class MShockWave extends ShockWave {
  int vx, vy;
  MShockWave(int _x, int _y, int _size, int _sizeRate, int _time, color _particleColor, int _vx, int _vy) {
    super( _x, _y, _size, _sizeRate, _time, _particleColor);
    opacity=0;
    vx=_vx;
    vy=_vy;
  }
  void update() {
    super.update();
    if (!dead && !freeze) { 
      if (reverse) {
        x-=vx;
        y-=vy;
      } else {
        x+=vx;
        y+=vy;
      }
    }
  }
}

//-------------------------------------------------------------//    ShockWave    //-------------------------------------------------------------------------

class Rectwave extends Particle {
  int sizeRate, halfSizeRate;
  Rectwave(int _x, int _y, int _size, int _sizeRate, int _time, color _particleColor) {
    super( _x, _y, 0, 0, _size, _time, _particleColor);
    sizeRate=_sizeRate;
    halfSizeRate=int(sizeRate*0.5);
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        size-=sizeRate*timeBend;
        opacity+=halfSizeRate*timeBend;
      } else {
        size+=sizeRate*timeBend;
        opacity-=halfSizeRate*timeBend;
        if (opacity<=0) {
          dead=true;
          deathTime=stampTime;
        }
      }
    }
  }
  void display() {
    if (!dead ) {  
      noFill();
      stroke(hue(particleColor), saturation(particleColor), brightness(particleColor)*S, opacity);
      strokeWeight(int(0.1*opacity));
      rect(x-size*.5, y-size*.5, size, size);
    }
  }
}
//-------------------------------------------------------------//    LineWave    //-------------------------------------------------------------------------

class LineWave extends Particle {
  float angle;
  LineWave(int _x, int _y, int _size, int _time, color _particleColor, float _angle) {
    super( _x, _y, 0, 0, _size, _time, _particleColor);
    angle=_angle;
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        size-=16*timeBend;
        opacity+=8*timeBend;
      } else {
        size+=16*timeBend;
        opacity-=8*timeBend;
      }
    }
  }
  void display() {
    if (!dead ) {
      noFill();
      stroke(hue(particleColor), saturation(particleColor), brightness(particleColor)*S, opacity);
      strokeWeight(int(0.1*opacity));
      line(x-cos(radians(angle))*size, y-sin(radians(angle))*size, x+cos(radians(angle))*size, y+sin(radians(angle))*size);
    }
  }
}

//-------------------------------------------------------------//    TempSlow   //-------------------------------------------------------------------------

class TempSlow extends Particle {
  float  decay;
  TempSlow(int _time, float _rate, float _decayRate) {
    super( 0, 0, 0, 0, 0, _time, 255);
    S=_rate;
    //println("slow! "+ _time+" :"+_rate);
    decay= _decayRate;
    timeBend=S*F;
    slow=true;
    drawTimeSymbol();
  }
  void update() {
    if (!dead && !freeze) { 
      // f =(fastForward)?speedFactor:1;
      if (reverse) {
        if (deathTime>stampTime && S>0 && S<1)S/=decay;
        else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          S=1; 
          timeBend=S*F;
          slow=false;

          // println( "dead");
        }
        if (S<0) {
          S=0;
          //println( "too low");
        } else if (S>1) {
          S=1;
          //println( "too high");
        }
        timeBend=S*F;
        drawTimeSymbol();
        // println( timeBend +" : "+S);
      } else {
        if (deathTime>stampTime && S>0 && S<1)S*=decay;
        else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          S=1; 
          timeBend=S*F;
          slow=false;
          // println( "dead");
        }
        if (S<0) {
          S=0;
          // println( "too low");
        } else if (S>1) {
          S=1;
          //println( "too high");
        }
        timeBend=S*F;
        drawTimeSymbol();
        //  println( timeBend +" : "+S);
      }
    }
  }
  void revert() {
    if (reverse && stampTime<spawnTime) {
      particles.remove(this);
    } else if (stampTime>deathTime && !dead) {
      dead=true;
      S=1; 
      timeBend=S*F; 
      slow=false;
      drawTimeSymbol();
    } else if (stampTime<deathTime) {
      dead=false;
    }
  }
  void display() {
    /*if (!dead && !freeze) {
     noStroke();
     fill(particleColor, opacity);
     rect(0-shakeTimer, 0-shakeTimer, width+shakeTimer, height+shakeTimer);
     }*/
  }
}
//-------------------------------------------------------------//    TempReverse   //-------------------------------------------------------------------------

class TempReverse extends Particle {
  float  decay;
  TempReverse(int _time) {
    super( 0, 0, 0, 0, 0, _time, 255);
    if (stampTime<_time)_time=int(stampTime);
    deathTime= millis()+_time;
    reverse=true;
    drawTimeSymbol();
    meta=true;
  }
  void update() {
    if (!dead ) { 
      /*if (reverse) {
       if (deathTime>millis())reverse=true;
       else {
       // println(deathTime+" : "+stampTime);
       dead=true;
       reverse=false;
       }
       } */
    }
  }
  void revert() {
    if (reverse && deathTime<millis()) {
      dead=true;
      reverse=false;
      drawTimeSymbol();
      particles.remove(this);
    }

    /* if (reverse && stampTime<spawnTime) {
     particles.remove(this);
     } else if (millis()>deathTime && !dead) {
     dead=true;
     reverse=false;
     drawTimeSymbol();
     } else if (millis()<deathTime) {
     reverse=false;
     }*/
  }
  void display() {
    /*if (!dead && !freeze) {
     noStroke();
     fill(particleColor, opacity);
     rect(0-shakeTimer, 0-shakeTimer, width+shakeTimer, height+shakeTimer);
     }*/
  }
}

//-------------------------------------------------------------//    TempFreeze   //-------------------------------------------------------------------------

class TempFreeze extends Particle {
  float  decay;
  TempFreeze(int _time) {
    super( 0, 0, 0, 0, 0, _time, 255);
    deathTime= millis()+_time;
    freeze=true;
    drawTimeSymbol();
  }
  void update() {
    if (!dead ) { 
      // f =(fastForward)?speedFactor:1;
      if (reverse) {
        if (deathTime>millis())freeze=true;
        else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          freeze=false;
        }
      } else {

        if (deathTime>millis())freeze=true;
        else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          freeze=false;
        }
      }
    }
  }
  void revert() {
    if (reverse && stampTime<spawnTime) {
      particles.remove(this);
    } else if (millis()>deathTime && !dead) {
      dead=true;
      freeze=false;
      drawTimeSymbol();
    } else if (millis()<deathTime) {
      dead=false;
    }
  }
  void display() {
    /*if (!dead && !freeze) {
     noStroke();
     fill(particleColor, opacity);
     rect(0-shakeTimer, 0-shakeTimer, width+shakeTimer, height+shakeTimer);
     }*/
  }
}

//-------------------------------------------------------------//    TempFast   //-------------------------------------------------------------------------

class TempFast extends Particle {
  float  decay, maxSpeed;
  TempFast(int _time, float _rate, float _decayRate) {
    super( 0, 0, 0, 0, 0, _time, 255);
    F=_rate;
    maxSpeed=F;
    //println("slow! "+ _time+" :"+_rate);
    decay= _decayRate;
    timeBend=S*F;
    fastForward=true;
    drawTimeSymbol();
  }
  void update() {
    if (!dead && !freeze) { 
      // f =(fastForward)?speedFactor:1;
      if (reverse) {
        if (deathTime>stampTime && F>1 && F<=maxSpeed)F/=decay;
        else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          F=1; 
          timeBend=S*F;
          fastForward=false;

          // println( "dead");
        }
        if (F<1) {
          F=1;
          //println( "too low");
        } else if (F>maxSpeed) {
          F=maxSpeed;
          //println( "too high");
        }
        timeBend=S*F;
        drawTimeSymbol();
        // println( timeBend +" : "+S);
      } else {
        if (deathTime>stampTime && F>1 && F<=maxSpeed)F*=decay;
        else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          F=1; 
          timeBend=S*F;
          fastForward=false;
          // println( "dead");
        }
        if (F<1) {
          F=1;
          // println( "too low");
        } else if (F>maxSpeed) {
          F=maxSpeed;
          //println( "too high");
        }
        timeBend=S*F;
        drawTimeSymbol();
        //  println( timeBend +" : "+S);
      }
    }
  }
  void revert() {
    if (reverse && stampTime<spawnTime) {
      particles.remove(this);
    } else if (stampTime>deathTime && !dead) {
      dead=true;
      F=1; 
      timeBend=S*F; 
      fastForward=false;
      drawTimeSymbol();
    } else if (stampTime<deathTime) {
      dead=false;
    }
  }
  void display() {
    /*if (!dead && !freeze) {
     noStroke();
     fill(particleColor, opacity);
     rect(0-shakeTimer, 0-shakeTimer, width+shakeTimer, height+shakeTimer);
     }*/
  }
}
//-------------------------------------------------------------//    TempZoom   //-------------------------------------------------------------------------


class TempZoom extends Particle {
  float  decay, x, y, zoomLvl, diffRate=0.01;
  boolean reset;
  Player followP;
  TempZoom(int _x, int _y, int _time, float _zoomLvl, float _zoomRate, boolean _reset) {
    super( 0, 0, 0, 0, 0, _time, 255);
    deathTime= millis()+_time;
    x=_x;
    y=_y;
    zoomLvl=_zoomLvl;
    reset=_reset;
    diffRate=_zoomRate;
  }
  TempZoom(Player _player, int _time, float _zoomLvl, float _zoomRate, boolean _reset) {
    super( 0, 0, 0, 0, 0, _time, 255);
    deathTime= millis()+_time;
    followP=_player;
    zoomLvl=_zoomLvl;
    reset=_reset;
    diffRate=_zoomRate;
  }
  void update() {
    if (!dead ) { 
      // f =(fastForward)?speedFactor:1;
      if (reverse) {
        if (deathTime>millis()) {
          if (followP!=null) {
            zoomXAim=followP.cx;
            zoomYAim=followP.cy;
            zoomAim=zoomLvl;
            tempZoom+=(zoomAim-tempZoom)*diffRate;
            zoomX+=(zoomXAim-zoomX)*diffRate;
            zoomY+=(zoomYAim-zoomY)*diffRate;
          } else {       
            zoomXAim=x;
            zoomYAim=y;
            zoomAim=zoomLvl;
            tempZoom+=(zoomLvl-tempZoom)*diffRate;
            zoomX+=(x-zoomX)*diffRate;
            zoomY+=(y-zoomY)*diffRate;
          }
        } else {
          dead=true;
          if (reset) {
            zoomAim= 1;         
            zoomXAim=halfWidth;
            zoomYAim=halfHeight;
          }
          // tempZoom=1;
          /*  zoomXAim= 1;
           zoomXAim=halfWidth;
           zoomYAim=halfHeight;*/
          //zoomX=halfWidth;
          //zoomY=halfHeight;
        }
      } else {
        if (deathTime>millis()) {
          if (followP!=null) {
            zoomXAim=followP.cx;
            zoomYAim=followP.cy;
            zoomAim=zoomLvl;
            tempZoom+=(zoomAim-tempZoom)*diffRate;
            zoomX+=(zoomXAim-zoomX)*diffRate;
            zoomY+=(zoomYAim-zoomY)*diffRate;
          } else {       
            zoomXAim=x;
            zoomYAim=y;
            zoomAim=zoomLvl;
            tempZoom+=(zoomLvl-tempZoom)*diffRate;
            zoomX+=(x-zoomX)*diffRate;
            zoomY+=(y-zoomY)*diffRate;
          }
        } else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          if (reset) {
            zoomAim= 1;         
            zoomXAim=halfWidth;
            zoomYAim=halfHeight;
          }
          // tempZoom=1;
          /* zoomXAim= 1;
           zoomXAim=halfWidth;
           zoomYAim=halfHeight;*/
          //zoomX=halfWidth;
          //zoomY=halfHeight;
        }
      }
    }
  }
  void revert() {
    if (reverse && stampTime<spawnTime) {
      particles.remove(this);
    } else if (millis()>deathTime && !dead) {
      dead=true;
      if (reset) {
        zoomAim= 1;         
        zoomXAim=halfWidth;
        zoomYAim=halfHeight;
      }
      // tempZoom=1;
      /* zoomXAim= 1;
       zoomXAim=halfWidth;
       zoomYAim=halfHeight;*/
      //zoomX=halfWidth;
      //zoomY=halfHeight;
    } else if (millis()<deathTime) {
      dead=false;
    }
  }
  void display() {
    /*if (!dead && !freeze) {
     noStroke();
     fill(particleColor, opacity);
     rect(0-shakeTimer, 0-shakeTimer, width+shakeTimer, height+shakeTimer);
     }*/
  }
}
//-------------------------------------------------------------//    Flash    //-------------------------------------------------------------------------

class Flash extends Particle {
  float rate;
  Flash(int _time, float _rate, color _particleColor) {
    super( 0, 0, 0, 0, 0, _time, _particleColor);
    rate=_rate;
  }
  void update() {
    if (!dead && !freeze) { 
      // f =(fastForward)?speedFactor:1;
      if (reverse) {
        opacity+=rate*timeBend;
      } else {
        opacity-=rate*timeBend;
      }
    }
  }

  void display() {
    if (!noFlash && !dead && !freeze) {
      noStroke();
      fill(particleColor, opacity*flashAmount);
      rect(0-shakeTimer, 0-shakeTimer, width+shakeTimer, height+shakeTimer);
    }
  }
}

//-------------------------------------------------------------//    Feather    //-------------------------------------------------------------------------

class Feather extends Particle {
  float shrinkRate;
  Feather(int _time, int _x, int _y, float _vx, float _vy, float _shrinkRate, color _particleColor) {
    super( _x, _y, _vx, _vy, 100, _time, _particleColor);
    shrinkRate=_shrinkRate;
    angle=random(0, 360);
  }
  void update() {
    if (!dead && !freeze) { 
      //f =(fastForward)?speedFactor:1;
      if (reverse) {
        angle+=16*timeBend;
        size+=shrinkRate*timeBend;
        opacity+=8*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        angle-=16*timeBend;
        size-=shrinkRate*timeBend;
        opacity-=8*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
    }
  }

  void display() {
    if (!dead ) {
      noFill();
      stroke(hue(particleColor), saturation(particleColor), brightness(particleColor)*S, opacity);
      strokeWeight(opacity*0.1);
      arc(x, y, size, size, radians(angle), radians(angle+180));
    }
  }
}

class Spark extends Particle {
  float shrinkRate, maxSize, brightness=255;
  Spark(int _time, int _x, int _y, float _vx, float _vy, float _shrinkRate, float _angle, color _particleColor) {
    super( _x, _y, _vx, _vy, 100, _time, _particleColor);
    angle=_angle;
    maxSize=size;
    shrinkRate=_shrinkRate;
  }
  void update() {
    if (!dead && !freeze) { 
      //f =(fastForward)?speedFactor:1;
      if (reverse) {       
        size+=shrinkRate*timeBend;
        brightness+=16*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        size-=shrinkRate*timeBend;
        brightness-=16*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
      if (size<=0) {
        dead=true;
        deathTime=stampTime;
      }
    }
  }

  void display() {
    if (!dead ) { 

      //noFill();
      stroke(hue(particleColor), saturation(particleColor)-brightness, brightness(particleColor)*S);
      strokeWeight(6);
      line(x+cos(radians(angle))*(maxSize-size), y+sin(radians(angle))*(maxSize-size), x+cos(radians(angle))*(maxSize), y+sin(radians(angle))*(maxSize));
    }
  }
}

class Gradient extends Particle {
  float shrinkRate, opacity=200, size=100, length;
  Gradient(int _time, int _x, int _y, float _vx, float _vy, int _maxSize, float _shrinkRate, float _angle, color _particleColor) {
    super( _x, _y, _vx, _vy, _maxSize, _time, _particleColor);
    size=_maxSize;
    angle=_angle;
    shrinkRate=_shrinkRate;
    length=2800;
  }
  Gradient(int _time, int _x, int _y, float _vx, float _vy, float _length, int _maxSize, float _shrinkRate, float _angle, color _particleColor) {
    super( _x, _y, _vx, _vy, _maxSize, _time, _particleColor);
    size=_maxSize;
    angle=_angle;
    shrinkRate=_shrinkRate;
    length=_length;
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {       
        size+=shrinkRate*timeBend;
        opacity+=shrinkRate*2*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        size-=shrinkRate*timeBend;
        opacity-=shrinkRate*2*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
        if (size<0)dead=true;
      }
    }
  }

  void display() {
    if (!dead) {

      // stroke(hue(particleColor), saturation(particleColor)-brightness, brightness(particleColor)*S);
      noStroke();
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      fill(particleColor, opacity);
      // ellipse(x, y, size*(deathTime-stampTime)/time, size*(deathTime-stampTime)/time );
      //  stroke(projectileColor);
      //ellipse(x, y, size, size);
      rect(-(size*.5), -(size*.5), length, size);
      popMatrix();
      //   strokeWeight(8);
      //     line(x+cos(radians(angle))*(maxSize-size), y+sin(radians(angle))*(maxSize-size), x+cos(radians(angle))*(maxSize), y+sin(radians(angle))*(maxSize));
    }
  }
}

class Shock extends Particle {
  float shrinkRate, brightness=255;
  PShape circle = createShape();       // First create the shape
  // star.beginShape();          // now call beginShape();


  //star.endShape(CLOSE);       // now call endShape(CLOSE);
  Shock(int _time, int _x, int _y, float _vx, float _vy, float _shrinkRate, float _angle, color _particleColor) {
    super( _x, _y, _vx, _vy, 100, _time, _particleColor);
    angle=_angle;
    shrinkRate=_shrinkRate;

    circle.beginShape();
    circle.noFill();
    for (int i=0; i<360; i+= (360/6)) {
      circle.vertex(x+cos(radians(angle+random(-i, i)*0.05))*(size+random(i*2)), y+sin(radians(angle+random(-i, i)*0.05))*(size+random(i*2)));
    }
    circle.endShape(OPEN);
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {       
        size+=shrinkRate*timeBend;
        brightness+=16*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        size-=shrinkRate*timeBend;
        brightness-=16*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
        if (size<0) dead=true;
      }
    }
  }

  void display() {
    if (!dead && !freeze) {
      noFill();

      beginShape();
      stroke(hue(particleColor), saturation(particleColor)-brightness, brightness(particleColor));
      strokeWeight(4);
      for (int i=0; i<360; i+= (360/6)) {
        vertex(x+cos(radians(angle+random(-i, i)*0.05))*(size+random(i*2)), y+sin(radians(angle+random(-i, i)*0.05))*(size+random(i*2)));
      }
      endShape();
    }
    if (!dead && freeze) { 
      shape(circle, circle.X + circle.width*.5, circle.Y+circle.height*.5);
    }
  }
}
class Tesla extends Particle {
  int weight, flick;
  int flux[]=new int[8];

  //Player target;

  Tesla( int _x, int _y, int _size, int _time, color _particleColor) {
    super( _x, _y, 0, 0, _size, _time, _particleColor);
    weight=size;
    x=_x;
    y=_y;
    for (int i=0; i<flux.length; i++)flux[i]=int(random(weight)-weight*.5);
  }
  void update() {
    if (!dead && !freeze) {
      flick=int(random(5));
      for (int i=0; i<flux.length; i++)flux[i]=int(random(weight)-weight*.5);
    }
  }

  void display() {
    if (!dead) {
      strokeWeight(flick);
      stroke(hue(particleColor), 255, 255);
      noFill();
      bezier( this.x+flux[0], this.y+flux[1], this.x +flux[2], this.y+flux[3], this.x+flux[4], this.y+flux[5], this.x+flux[6], this.y+flux[7]);// crosshier
    }
  }
}
class Text extends Particle {                 //   TextParticle
  float shrinkRate, brightness=255;
  String text="";
  int  offsetX, offsetY, type, count;
  boolean follow;
  Player owner;
  //star.endShape(CLOSE);       // now call endShape(CLOSE);
  Text(String _text, int _x, int _y, float _vx, float _vy, float _size, float _shrinkRate, int _time, color _particleColor, int _type) {
    super( _x, _y, _vx, _vy, int(_size), _time, _particleColor);
    type= _type;
    shrinkRate=_shrinkRate;
    text=_text;
  }

  Text(Player _owner, String _text, int _offsetX, int _offsetY, float _size, float _shrinkRate, int _time, color _particleColor, int _type) {
    super( 0, 0, 0, 0, int(_size), _time, _particleColor);
    type= _type;
    shrinkRate=_shrinkRate;
    text=_text;
    follow=true;
    offsetX=_offsetX;
    offsetY=_offsetY;
    owner=_owner;
    x=owner.cx+offsetX;
    y=owner.cy+offsetY;
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {       
        size+=shrinkRate*timeBend;
        count-=1*timeBend;
        if (follow) {
          x=owner.cx+offsetX;
          y=owner.cy+offsetY;
        } else {
          x-=vx*timeBend;
          y-=vy*timeBend;
        }
      } else {
        count+=1*timeBend;
        size-=shrinkRate*timeBend;
        if (follow) {
          x=owner.cx+offsetX;
          y=owner.cy+offsetY;
        } else {
          x+=vx*timeBend;
          y+=vy*timeBend;
        }
      }
    }
  }

  void display() {
    if (!dead ) {
      noStroke();
      switch(type) {
      case 1:
        if (count%2<1)fill(particleColor);
        else fill(255);
        break;
      case 2:
        if (count%4<2)fill(particleColor);
        else fill(255);
        break;
      default:
        fill(particleColor);
      }
      textSize(size);
      text(text, x, y);
    }
  }
}
class Pic extends Particle {
  float shrinkRate, brightness=255;
  String text="";
  int  offsetX, offsetY, type, opacity;
  boolean follow;
  PImage pic;
  Player owner;
  //star.endShape(CLOSE);       // now call endShape(CLOSE);
  Pic(Player _owner, PImage _pic, int _x, int _y, float _vx, float _vy, float _size, float _shrinkRate, int _time, color _particleColor, int _type) {
    super( _x, _y, _vx, _vy, int(_size), _time, _particleColor);
    pic=_pic;
    type= _type;
    offsetX=_x;
    offsetY=_y;
    shrinkRate=_shrinkRate;
    owner=_owner;
    if (_type==1)follow=true;
    opacity=255;
    x=owner.cx+offsetX;
    y=owner.cy+offsetY;
  }

  void update() {
    if (!dead && !freeze) { 
      if (reverse) {       
        size+=shrinkRate*timeBend;
        opacity=int((255*(deathTime-stampTime)/time));

        if (follow) {
          x=owner.cx+offsetX;
          y=owner.cy+offsetY;
        } else {
          x-=vx*timeBend;
          y-=vy*timeBend;
        }
      } else { 
        opacity=int((255*(deathTime-stampTime)/time));
        size-=shrinkRate*timeBend;
        if (follow) {
          x=owner.cx+offsetX;
          y=owner.cy+offsetY;
        } else {
          x+=vx*timeBend;
          y+=vy*timeBend;
        }
      }
      if (stampTime>=deathTime) {
        dead=true;
      }
    }
  }

  void display() {
    if (!dead && !owner.stealth) {
      tint(owner.playerColor, opacity);
      image(pic, x, y, size, size);
      noTint();
    }
  }
}


class Fragment extends Particle {
  float vAngle;
  PVector p1, p2, p3;
  int maxSize;
  Fragment(int _x, int _y, float _vx, float _vy, float _vAngle, int _minSize, int _maxSize, int _time, color _particleColor) {
    super( _x, _y, _vx, _vy, _minSize, _time, _particleColor);
    vAngle=_vAngle;
    // p1=new PVector(random(_minSize-_maxSize)+_minSize, random(_minSize-_maxSize)+_minSize);
    p1=new PVector(random(_minSize-_maxSize)+_minSize, 0);
    p1.rotate(random(radians(280), radians(320)));
    // p2=new PVector(random(_minSize-_maxSize)+_minSize, random(_minSize-_maxSize)+_minSize);
    p2=new PVector(random(_minSize-_maxSize)+_minSize, 0);
    p2.rotate(random(radians(160), radians(200)));
    //p3=new PVector(random(_minSize-_maxSize)+_minSize, random(_minSize-_maxSize)+_minSize);
    p3=new PVector(random(_minSize-_maxSize)+_minSize, 0);
    p3.rotate(random(radians(40), radians(80)));
    // println(p1.x, p1, y);

    opacity=255;
    x=_vx*_time*.06+_x;
    y=_vy*_time*.06+_y;
  }

  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        opacity+=8*F;
        x+=vx*timeBend;
        y+=vy*timeBend;
        angle-=radians(vAngle);
        p1.setMag(sin(radians(angle))*1);
        p2.setMag(sin(radians(angle))*1);
        p3.setMag(sin(radians(angle))*1);
      } else {
        opacity-=8*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
        angle+=radians(vAngle);
        /*  p1.setMag(sin(radians(angle))*1);
         p2.setMag(sin(radians(angle))*1);
         p3.setMag(sin(radians(angle))*1);*/
        p1.setMag((maxSize*(deathTime-stampTime)/time)+size);
        p2.setMag((maxSize*(deathTime-stampTime)/time)+size);
        p3.setMag((maxSize*(deathTime-stampTime)/time)+size);
        p1.rotate(radians(angle));
        p2.rotate(radians(angle));
        p3.rotate(radians(angle));
      }
    }
  }
  void display() {
    if (!dead ) {  
      fill(WHITE, opacity);
      stroke(hue(particleColor), saturation(particleColor), brightness(particleColor)*S, opacity);
      strokeWeight(8);
      triangle(p1.x+x, p1.y+y, p2.x+x, p2.y+y, p3.x+x, p3.y+y);
    }
  }
}

//-------------------------------------------------------------//    Star    //-------------------------------------------------------------------------

class Star extends Particle {
  boolean follow;
  float shrinkRate, size=100, scale=1, shimmer;
  PShape form= createShape();
  Star(int _time, int _x, int _y, float _vx, float _vy, int _size, float _shrinkRate, color _particleColor) {
    super( _x, _y, _vx, _vy, 100, _time, _particleColor);
    size = _size;
    shrinkRate=_shrinkRate;
    // opacity=0;
    //stroke(_particleColor, opacity);
    // fill(WHITE, opacity);
    form.disableStyle();
    form.beginShape();
    // form.stroke(_particleColor, opacity);
    // form.fill(WHITE, opacity);
    // form.strokeWeight(size/10); 
    form.vertex(0, -size );
    form.vertex(size*.5 -size/4, - size*.5+size/4);
    form.vertex(size, 0);
    form.vertex(size*.5-size/4, size*.5-size/4);
    form.vertex(0, size);
    form.vertex(-size*.5+size/4, size*.5-size/4);
    form.vertex(-size, 0);
    form.vertex(-size*.5+size/4, -size*.5+size/4);
    form.endShape(CLOSE);
    // form.translate(form.width*.5, form.height*.5);
    form.translate(size, size);
    //form.setVisible(false);
    opacity=255;
  }
  void update() {


    if (!dead && !freeze) { 
      //f =(fastForward)?speedFactor:1;
      if (reverse) {
        angle+=4*timeBend;
        scale/=shrinkRate*timeBend;

        opacity+=6*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        angle-=4*timeBend;
        scale*=shrinkRate*timeBend;

        opacity-=6*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
        shimmer=random(0.5, 1);
      }
    }
  }

  void display() {

    if (!dead ) {
      // super.display();
      // form.setStroke(color(particleColorparticleColor),blue(particleColor)));  
      strokeWeight(size/10*scale); 
      stroke(particleColor, opacity);
      fill(WHITE, opacity);

      //tint(particleColor, opacity);
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      //tint(255,opacity);
      scale(scale*shimmer);
      // shape(form, form.width*.5, form.height*.5);
      shape(form);
      //strokeWeight(opacity*0.1);
      popMatrix();
    }
  }
}


class AfterImage extends Particle {
  PGraphics afterImage;
  float angle, angleV, percent;
  int type, count, range=300, xOffset, yOffset;
  Player owner;
  AfterImage(int _x, int _y, float _vx, float _vy, float _angle, float _angleV, int _minSize, int _maxSize, int _time, int  _type, Player _player) {
    super( _x, _y, _vx, _vy, _minSize, _time, _player.playerColor);
    range=_maxSize;
    owner=_player;
    angle=_angle;
    angleV=_angleV;
    xOffset=int(x);
    yOffset=int(y);
    type=_type;
    afterImage = createGraphics(200, 200);
    afterImage.beginDraw();
    afterImage.textFont(font);
    afterImage.shapeMode(CENTER);
    afterImage.ellipseMode(CENTER);
    afterImage.textAlign(CENTER, CENTER);
    afterImage.colorMode(HSB);

    afterImage.stroke((freeze && !(_player.freezeImmunity))?255:0);
    afterImage. strokeWeight(2);
    afterImage.fill(255, 0, 255, 50);
    afterImage.ellipse(afterImage.width*0.5, afterImage.height*0.5, _player.w, _player.h);

    afterImage.pushMatrix();
    afterImage.translate(afterImage.width*0.5, afterImage.height*0.5);
    afterImage.rotate(radians(_player.angle+90));
    afterImage.fill(hue(_player.playerColor), saturation(_player.playerColor)*_player.s, brightness(_player.playerColor)*_player.s, 50+_player.deColor);
    afterImage.shape(_player.arrowSVG, -_player.arrowSVG.width*0.5+30, -30-_player.radius, _player.arrowSVG.width, _player.arrowSVG.height);
    afterImage.popMatrix();



    afterImage.fill(255);
    afterImage.arc(afterImage.width*0.5, afterImage.height*0.5, _player.barDiameter, _player.barDiameter, PI_HALF-_player.barFraction, PI_HALF);
    afterImage.fill(hue(_player.playerColor), saturation(_player.playerColor)*_player.s, brightness(_player.playerColor)*_player.s);
    afterImage.textSize(20);
    afterImage.text(_player.label, afterImage.width*0.5, afterImage.height*0.5);


    afterImage.strokeWeight(_player.barSize);
    //strokeCap(SQUARE);
    afterImage.noFill();
    afterImage.stroke(hue(_player.playerColor), 80*S, (80-_player.deColor)*S);
    afterImage.ellipse(afterImage.width*0.5, afterImage.height*0.5, _player.barDiameter, _player.barDiameter);
    afterImage.stroke(hue(_player.playerColor), (255-_player.deColor*0.5)*S, _player.ally==-1?0:255*S);
    // arc(cx, cy, barDiameter, barDiameter, -HALF_PI +(TAU)-fraction, PI+HALF_PI);
    afterImage.arc(afterImage.width*0.5, afterImage.height*0.5, _player.barDiameter, _player.barDiameter, PI_HALF-_player.fraction, PI_HALF);



    afterImage.endDraw();
  }

  void update() {
    switch(type) {

    case 1:
      if (!dead && !freeze) { 
        if (reverse) {
          opacity=int(sin(radians(count+90))*255);
          x=cos(radians(angle))*range*percent+owner.cx;
          y=sin(radians(angle))*range*percent+owner.cy;
          angle+=angleV*timeBend;
          count-=4*timeBend;
          percent=sin(radians(count));
        } else {
          percent=sin(radians(count));
          count+=4*timeBend;
          angle+=angleV*timeBend;
          x=cos(radians(angle))*range*percent+owner.cx;
          y=sin(radians(angle))*range*percent+owner.cy;
          opacity=int(sin(radians(count+90))*255);
        }
      }
      break;
    case 2:
      if (!dead && !freeze) { 
        if (reverse) {
          opacity=int(sin(radians(count+90))*255);
          x=cos(radians(angle))*range*sin(radians(count*3))+owner.cx;
          y=sin(radians(angle))*range*sin(radians(count*3))+owner.cy;
          //angle+=angleV*timeBend;
          count-=4*timeBend;
          percent=sin(radians(count));
        } else {
          percent=sin(radians(count));
          count+=4*timeBend;
          //angle+=angleV*timeBend;
          x=cos(radians(angle))*range*sin(radians(count*3))+owner.cx;
          y=sin(radians(angle))*range*sin(radians(count*3))+owner.cy;
          opacity=int(sin(radians(count+90))*255);
        }
      }
      break;
    default:
      if (!dead && !freeze) { 
        if (reverse) {
          opacity+=6*timeBend;
          x-=vx*timeBend;
          y-=vy*timeBend;
        } else {
          x+=vx*timeBend;
          y+=vy*timeBend;
          opacity-=6*timeBend;
        }
      }
    }
  }
  void display() {
    if (!dead ) {  
      tint(255, opacity);
      image(afterImage, x, y);
      noTint();
    }
  }
}