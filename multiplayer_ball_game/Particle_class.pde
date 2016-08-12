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
        x-=vx*F*S;
        y-=vy*F*S;
      } else {
        opacity-=8*F*S;
        x+=vx*F*S;
        y+=vy*F*S;
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
  ShockWave(int _x, int _y, int _size, int _time, color _particleColor) {
    super( _x, _y, 0, 0, _size, _time, _particleColor);
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        size-=16*F*S;
        opacity+=8*F*S;
      } else {
        size+=16*F*S;
        opacity-=8*F*S;
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

class RShockWave extends Particle {
  RShockWave(int _x, int _y, int _size, int _time, color _particleColor) {
    super( _x, _y, 0, 0, _size, _time, _particleColor);
    opacity=0;
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        size+=16*F*S;
        opacity-=8*F*S;
      } else {
        size-=16*F*S;
        opacity+=8*F*S;
        if (size<=0)dead=true;
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
        size-=16*F*S;
        opacity+=8*F*S;
      } else {
        size+=16*F*S;
        opacity-=8*F*S;
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
        opacity+=rate*F*S;
      } else {
        opacity-=rate*F*S;
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
        angle+=16*F*S;
        size+=shrinkRate*F*S;
        opacity+=8*F*S;
        x-=vx*F*S;
        y-=vy*F*S;
      } else {
        angle-=16*F*S;
        size-=shrinkRate*F*S;
        opacity-=8*F*S;
        x+=vx*F*S;
        y+=vy*F*S;
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
        size+=shrinkRate*F*S;
        brightness+=16*F*S;
        x-=vx*F*S;
        y-=vy*F*S;
      } else {
        size-=shrinkRate*F*S;
        brightness-=16*F*S;
        x+=vx*F*S;
        y+=vy*F*S;
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
  gradient(int _time, int _x, int _y, float _vx, float _vy,int _maxSize, float _shrinkRate, float _angle, color _particleColor) {
    super( _x, _y, _vx, _vy,_maxSize, _time, _particleColor);
    size=_maxSize;
    angle=_angle;
    shrinkRate=_shrinkRate;
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {       
        size+=shrinkRate*F*S;
        opacity+=shrinkRate*2*F*S;
        x-=vx*F*S;
        y-=vy*F*S;
      } else {
        size-=shrinkRate*F*S;
        opacity-=shrinkRate*2*F*S;
        x+=vx*F*S;
        y+=vy*F*S;
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
        size+=shrinkRate*F*S;
        brightness+=16*F*S;
        x-=vx*F*S;
        y-=vy*F*S;
      } else {
        size-=shrinkRate*F*S;
        brightness-=16*F*S;
        x+=vx*F*S;
        y+=vy*F*S;
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
      shape(circle,circle.X + circle.width/2,circle.Y+circle.height/2);
    }
  }
}