class Particle  implements Cloneable {
  int  size, opacity;
  float x, y, vx, vy, angle;
  long spawnTime, deathTime, time;
  color particleColor;
  boolean dead;
  //  int f;
  Particle(int _x, int _y, float _vx, float _vy, int _size, int _time, color _particleColor) {
    size=_size;
    spawnTime=stampTime;
    deathTime=stampTime + _time;
    particleColor= _particleColor;
    opacity=255;
    x= _x;
    y= _y;
    vx= _vx;
    vy= _vy;
  }

  void update() {
    if (!dead && !freeze) { 
      // f =(fastForward)?speedFactor:1;
      if (reverse) {
        opacity+=8*F;
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
  public Particle clone()throws CloneNotSupportedException {  
    return (Particle)super.clone();
  }
}


//-------------------------------------------------------------//    ShockWave    //-------------------------------------------------------------------------

class ShockWave extends Particle {
  int sizeRate;
  ShockWave(int _x, int _y, int _size, int _sizeRate, int _time, color _particleColor) {
    super( _x, _y, 0, 0, _size, _time, _particleColor);
    sizeRate=_sizeRate;
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        size-=sizeRate*timeBend;
        opacity+=sizeRate*0.5*timeBend;
      } else {
        size+=sizeRate*timeBend;
        opacity-=sizeRate*0.5*timeBend;
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
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        size+=sizeRate*timeBend;
        opacity-=sizeRate*0.5*timeBend;
      } else {
        size-=sizeRate*timeBend;
        opacity+=sizeRate*0.5*timeBend;
        if (size<=0)dead=true;
      }
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
  float slow, decay;
  TempSlow(int _time, float _rate, float _decayRate) {
    super( 0, 0, 0, 0, 0, _time, 255);
    S=_rate;
    //println("slow! "+ _time+" :"+_rate);
    decay= _decayRate;
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
          // println( "dead");
        }
        if (S<0) {
          S=0;
          println( "too low");
        }
        if (S>1) {
          S=1;
          println( "too high");
        }
        timeBend=S*F;
        // println( timeBend +" : "+S);
      } else {
        if (deathTime>stampTime && S>0 && S<1)S*=decay;
        else {
          // println(deathTime+" : "+stampTime);
          dead=true;
          S=1; 
          timeBend=S*F;
          // println( "dead");
        }
        if (S<0) {
          S=0;
          println( "too low");
        }
        if (S>1) {
          S=1;
          println( "too high");
        }
        timeBend=S*F;
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
//-------------------------------------------------------------//    TempFreeze   //-------------------------------------------------------------------------

class TempFreeze extends Particle {
  float slow, decay;
  TempFreeze(int _time) {
    super( 0, 0, 0, 0, 0, _time, 255);
   deathTime= millis()+_time;
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
    if (!dead && !freeze) {
      noStroke();
      fill(particleColor, opacity);
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
      if (size<=0)dead=true;
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

class gradient extends Particle {
  float shrinkRate, opacity=200, size=100;
  gradient(int _time, int _x, int _y, float _vx, float _vy, int _maxSize, float _shrinkRate, float _angle, color _particleColor) {
    super( _x, _y, _vx, _vy, _maxSize, _time, _particleColor);
    size=_maxSize;
    angle=_angle;
    shrinkRate=_shrinkRate;
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
      rect(-(size/2), -(size/2), 2000, size);
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
      shape(circle, circle.X + circle.width/2, circle.Y+circle.height/2);
    }
  }
}

class Text extends Particle {
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
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {       
        size+=shrinkRate*timeBend;
        if (follow) {
          x=owner.x+owner.w*.5+offsetX;
          y=owner.y+owner.h*.5+offsetY;
        } else {
          x-=vx*timeBend;
          y-=vy*timeBend;
        }
      } else {
        size-=shrinkRate*timeBend;
        if (follow) {
          x=owner.x+owner.w*.5+offsetX;
          y=owner.y+owner.h*.5+offsetY;
        } else {
          x+=vx*timeBend;
          y+=vy*timeBend;
        }
        //if (size<0) dead=true;
      }
    }
  }

  void display() {
    if (!dead) {
      noStroke();
      switch(type) {
      case 1:
        count++;
        if (count%2==0)fill(particleColor);
        else fill(255);
        break;
      default:
        fill(particleColor);
      }
      //stroke(hue(particleColor), saturation(particleColor)-brightness, brightness(particleColor));
      textSize(size);
      text(text, x, y);
    }
  }
}