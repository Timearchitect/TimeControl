class Projectile  implements Cloneable {
  PVector coord;
  PVector speed;
  int  size, damage, ally=-1;
  float x, y, angle, force;
  long deathTime, spawnTime;
  color projectileColor;
  boolean dead, deathAnimation;
  int  playerIndex=-1, time;
  Player owner;
  Projectile( ) { // nothing
  }
  Projectile(Projectile _p ) { // copy
    this(_p.playerIndex, int(_p.x), int(_p.y), _p.size, _p.projectileColor, _p.time) ;
    this.spawnTime=_p.spawnTime;
    this.deathTime=_p.deathTime;
  }

  Projectile( int _x, int _y, int _size, color _color, int  _time) { // no playerIndex
    x= _x;
    y= _y;
    size=_size;
    projectileColor=_color;
    spawnTime=stampTime;
    deathTime=stampTime + _time;
    time=_time;
  }
  Projectile(int _playerIndex, int _x, int _y, int _size, color _color, int  _time) {
    this(_x,  _y,  _size,  _color,   _time);
    playerIndex=_playerIndex;
    ally=players.get(_playerIndex).ally;

  }
  Projectile(Player _owner, int _x, int _y, int _size, color _color, int  _time) {
    this(_x,  _y,  _size,  _color,   _time);
    owner=_owner;
    playerIndex=owner.index;
    ally=owner.ally;

  }
  void update() {
  }
  void display() {
  }
  void revert() {
    if (reverse && stampTime<spawnTime) {
      projectiles.remove(this);
    } 
    if (reverse && stampTime>deathTime) {
      if (deathAnimation) {
        deathAnimation=false;
      }
    } else if (stampTime<deathTime) {
      dead=false;
    } else if (stampTime>deathTime) {
      if (!deathAnimation) {
        fizzle();
        deathAnimation=true;
        dead=true;
      }
    }
  }
  void fizzle() { // timed out death
  }
  void hit(Player enemy) {// collide death
  }

  public Projectile clone()throws CloneNotSupportedException {  
    return (Projectile)super.clone();
  }
}

class Ball extends Projectile { //----------------------------------------- ball objects ----------------------------------------------------
  int speedX, speedY, dirX, dirY;
  int [] allies;
  int up, down, left, right;
  float vx, vy;
  Ball( int _x, int _y, int _speedX, int _speedY, int _size, color _color) {
    super( _x, _y, _size, _color, 999999);
    projectileColor=_color;
    damage=1;
    coord= new PVector(_x, _y);
    speed= new PVector(_speedX, _speedY);
    vx=_speedX;
    vy=_speedY;
    angle=degrees( PVector.angleBetween(coord, speed));
  }


  void playerBounds() {
    if (!reverse) {
      for (int i=0; i<players.size (); i++) {
        if (coord.y-size*0.5+speedY<players.get(i).y+players.get(i).h+10+players.get(i).vy && coord.y+size*0.5+speedY>players.get(i).y-10+players.get(i).vy) {
          if (coord.x+size*0.5+speedX> players.get(i).x+20 && coord.x-size*0.5+speedX< players.get(i).x + players.get(i).w-20 ) {
            // speed.set( speed.x, speed.y*(-1));
            // coord.set( coord.x+speed.x, coord.y+speed.y);
            // y-=players.get(i).vy;
          }
        }
        if (coord.y-size*0.5+speedY<players.get(i).y+players.get(i).h-20+players.get(i).vy && coord.y+size*0.5+speedY>players.get(i).y+20+players.get(i).vy) {
          if (coord.x+size*0.5+speedX> players.get(i).x-10 && coord.x-size*0.5+speedX< players.get(i).x + players.get(i).w +10 ) {
            //  speed.set( speed.x*(-1), speed.y);
            //  coord.set( coord.x+speed.x+players.get(i).vx, coord.y+speed.y+players.get(i).vy);
            //  x-=players.get(i).vx;
          }
        }
      }
    }
  }
  void checkBounds() {

    if (coord.y-size*0.5<0 ) { // walls
      speed.set( speed.x, speed.y*(-1));
    } else if (coord.y+size*0.5>height) {
      speed.set( speed.x, speed.y*(-1));
    }
    if (coord.x-size*0.5<0 ) {
      speed.set( speed.x*(-1), speed.y);
    } else if (coord.x+size*0.5>width ) {
      speed.set( speed.x*(-1), speed.y);
    }

    if (y-size*0.5<0 ) { // walls
      vy*=(-1);
    } else if (y+size*0.5>height) {
      vy*=(-1);
    }
    if (x-size*0.5<0 ) {
      vx*=(-1);
    } else if (x+size*0.5>width ) {
      vx*=(-1);
    }
  }

  void display() {
    strokeWeight(1);
    if (freeze) {
      stroke(100);
      fill(255);
    } else {
      stroke(projectileColor);
      fill(projectileColor);
    }
    //ellipse(coord.x, coord.y, size, size);
    // line(coord.x, coord.y, coord.x +(speed.x)*10, coord.y+(speed.y)*10);
    ellipse(x, y, size, size);
    line(x, y, x +(vx)*10, y+(vy)*10);
  }

  void move() {
    //   s =(slow)?slowFactor:1;
    //      f =(fastForward)?speedFactor:1;
    if (stampTime%1==0) {
      if (!freeze) {
        if (reverse) {
          angle=degrees( PVector.angleBetween(speed, coord));
          coord.set(coord.x-speed.x*F*S, coord.y-speed.y*F*S);
          x-=vx*F*S;
          y-=vy*F*S;
        } else {
          coord.set(coord.x+speed.x*F*S, coord.y+speed.y*F*S);
          angle=degrees( PVector.angleBetween(coord, speed));
          x+=vx*F*S;
          y+=vy*F*S;
        }
      }
    }
  }


  void update() {
    checkBounds();
    move();
  }

  @Override
    void revert() {
  }
  @Override
    void hit(Player enemy) {
    // super.hit();
    enemy.hit(damage);
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(-5, 5), random(-5, 5), int(random(20)+5), 500, 255));
    }
    /* for (int i=0; i<1; i++) {
     particles.add(new Particle(int(x), int(y), random(-10, 10), random(-10, 10), int(random(30)+10), 500, projectileColor));
     }*/
    //w particles.add(new LineWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 10, 300, projectileColor));
  }
}

class IceDagger extends Projectile {//----------------------------------------- IceDagger objects ----------------------------------------------------
  PShape  sh, c ;
  float vx, vy;
  IceDagger(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);

    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;

    for (int i=0; i<8; i++) {
      particles.add(new Particle(int(x), int(y), vx/(2-0.12*i), vy/(2-0.12*i), 10+i*4, _time, _projectileColor));
    }
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
    sh = createShape();
    c = createShape();
    sh.beginShape();
    sh.fill(255);
    sh.stroke(255, 50);
    sh.vertex(int (0), int (-size*0.5) );
    sh.vertex(int (+size*2), int (0));
    sh.vertex(int (0), int (+size*0.5));
    sh.vertex(int (-size), int (0));
    sh.endShape(CLOSE);

    c.beginShape();
    c.fill(projectileColor);
    c.stroke(projectileColor, 50);
    c.vertex(int (0), int (-size/3) );
    c.vertex(int (+size), int (0));
    c.vertex(int (0), int (+size/3));
    c.vertex(int (-size*0.5), int (0));
    c.endShape(CLOSE);
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*F*S;
        y-=vy*F*S;
      } else {

        x+=vx*F*S;
        y+=vy*F*S;
      }
    }
  }
  void display() {
    if (!dead) { 
      // rect(x-(size/2), y-(size/2), (size), (size));
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      // rect(-(size/2), -(size/2), (size), (size));
      shape(sh, sh.width*0.5, sh.height*0.5);
      shape(c, c.width*0.5, c.height*0.5);
      popMatrix();
    }
  }
  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<4; i++) {
        particles.add(new Particle(int(x), int(y), random(10)-5+vx, random(10)-5+vy, int(random(20)+5), 800, 255));
      }
    }
  }
  @Override
    void hit(Player enemy) {
    // super.hit();
    enemy.hit(damage);
    deathTime=stampTime;   // dead on collision
    dead=true;
    for (int i=0; i<8; i++) {
      particles.add(new Particle(int(x), int(y), random(20)-10, random(20)-10, int(random(20)+5), 800, 255));
    }
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
    }
    particles.add(new Flash(200, 32, 255));  
    particles.add(new LineWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 10, 300, projectileColor, angle));
  }
}

class ArchingIceDagger extends IceDagger {//----------------------------------------- IceDagger objects ----------------------------------------------------

  ArchingIceDagger(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage);
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*F*S;
        y-=vy*F*S;
        angle-=12*F*S;
      } else {
        angle+=12*F*S;
        x+=vx*F*S;
        y+=vy*F*S;
      }
    }
  }
  void display() {
    if (!dead) { 
      // rect(x-(size/2), y-(size/2), (size), (size));
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));

      // rect(-(size/2), -(size/2), (size), (size));
      shape(sh, sh.width*0.5, sh.height*0.5);
      shape(c, c.width*0.5, c.height*0.5);
      popMatrix();
    }
  }
}


class forceBall extends Projectile { //----------------------------------------- forceBall objects ----------------------------------------------------
  //scaled object by velocity
  float vx, vy, v, ax, ay, angleV;
  boolean charging;
  forceBall(Player _owner, int _x, int _y, float _v, int _size, color _projectileColor, int  _time, float _angle, float _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    angleV=10;
    damage=int(_damage);
    v=_v;
    force=_v;
    vx= cos(radians(angle))*_v;
    vy= sin(radians(angle))*_v;

    for (int i=0; i<8; i++) {
      particles.add(new Particle(int(x), int(y), vx/(2-0.12*i), vy/(2-0.12*i), 10+i*4, _time, _projectileColor));
    }
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        //  opacity+=8*F;
        //if (charging) angle+=angleV*F*S;
        x-=vx*F*S;
        y-=vy*F*S;
      } else {
        //  opacity-=8*F;
        // if (charging) angle-=angleV*F*S;
        x+=vx*F*S;
        y+=vy*F*S;
      }
    }
  }
  void display() {
    if (!dead) { 
      // rect(x-(size/2), y-(size/2), (size), (size));
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      // rect(-(size/2), -(size/2), (size), (size));
      fill(255);
      strokeWeight(5);
      stroke(projectileColor);
      ellipse(0, 0, size+size*v*0.1, size);
      popMatrix();
    }
  }
  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<4; i++) {
        particles.add(new Particle(int(x), int(y), random(10)-5+vx, random(10)-5+vy, int(random(20)+5), 800, 255));
      }
    }
  }
  @Override
    void hit(Player enemy) {
    // super.hit();
    enemy.hit(damage);
    deathTime=stampTime;   // projectile is dead on collision
    dead=true;
    for (int i=0; i<int (v*0.4); i++) { // particles
      particles.add(new Particle(int(x), int(y), random(-int(v*0.2), int(v*0.2)), random(-int(v*0.2), int(v*0.2)), int(random(5, 30)), 800, 255));
    }
    for (int i=0; i<int (v*0.6); i++) {
      particles.add(new Particle(int(x), int(y), random(-int(v*0.4), int(v*0.4)), random(-int(v*0.4), int(v*0.4)), int(random(10, 50)), 800, projectileColor));
    }
    particles.add(new Flash(int(v*4), 32, 255));  
    particles.add(new ShockWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 20, 200, projectileColor));
    particles.add(new ShockWave(int(x), int(y), int(v*4), int(v*4), projectileColor));
    particles.add(new ShockWave(int(x), int(y), int( v*2), int(v*5), color(255, 0, 255)));
    shakeTimer=int(damage*0.8);
  }
}

class ChargeLaser extends Projectile { //----------------------------------------- forceBall objects ----------------------------------------------------
  long chargeTime, MaxChargeTime=500;
  float laserWidth, laserLength=2500, laserChange;

  ChargeLaser( int _playerIndex, int _x, int _y, color _projectileColor, int  _time, float _angle, float _damage  ) {
    super(_playerIndex, _x, _y, 1, _projectileColor, _time);
    damage= int(_damage);
    angle=_angle;
  }

  void display() {
    if (!dead ) { 
      strokeWeight(int(laserWidth));
      stroke(projectileColor);
      line(int(x), int(y), cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y));
      stroke(255);
      strokeWeight(int(laserWidth*0.6));
      line(int(x), int(y), cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y));
    }
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        laserChange-=2;
        laserWidth= sin(radians(laserChange))*100;
        angle=players.get(playerIndex).angle;
        x=players.get(playerIndex).x+50;
        y=players.get(playerIndex).y+50;
      } else {
        laserChange+=2;
        laserWidth= sin(radians(laserChange))*100;
        angle=players.get(playerIndex).angle;
        x=players.get(playerIndex).x+50;
        y=players.get(playerIndex).y+50;
        //   particles.add( new  Particle(int(x+random(-laserWidth*1.5,laserWidth*1.5)-50), int(y+random(-laserWidth*1.5,laserWidth*1.5)-50), int( cos(radians(angle))*60), int(sin(radians(angle))*60), int(random(-laserWidth*0.5,laserWidth*0.5)), 400, projectileColor));
        //particles.add( new  Particle(int(x), int(y), 0, 0, int(125), 0, color(255, 0, 255)));
        if (laserWidth<0) {
          dead=true;
          deathTime=stampTime;
        }
        players.get(playerIndex).pushForce(-0.2, angle);
        shakeTimer=int(laserWidth*0.1);
        particles.add(new  gradient(1000, int(x+size*0.5), int(y+size*0.5), 0, 0, 4, angle, projectileColor));

        for (int i= 0; players.size () > i; i++)
          if (playerIndex!=i  && !players.get(i).dead) lineVsCircleCollision(x, y, cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y), players.get(i));
      }
    }
  }
  void lineVsCircleCollision(float x, float y, float x2, float y2, Player enemy) {
    float cx= enemy.x+enemy.w*0.5, cy=enemy.y+enemy.w*0.5, cr= enemy.w*0.5;
    float segV = dist(x2, y2, x, y);
    float segVAngle = degrees(atan2((y2-y), (x2-x)));
    float segC = dist(cx, cy, x, y);
    // float segCAngle = degrees(atan2((cy-y),(c2-x)));
    //  stroke(0);
    // line(x, y, cx, cy);
    //   line(x+cos(radians(segVAngle))*segC, y+sin(radians(segVAngle))*segC, cx, cy);
    //   println(segV+" angle: "+segVAngle+ "      circle:"+ segC);


    float rx, ry;
    float dx = x2 - x;
    float dy = y2 - y;
    float d = sqrt( dx*dx + dy*dy ); 

    //float a = atan2( y2 - y1, x2 - x1 ); 
    //float ca = cos( a ); 
    //float sa = sin( a ); 
    float ca = dx/d;
    float sa = dy/d;
    float mX = (-x+cx)*ca + (-y+cy)*sa; 
    float mY = (-y+cy)*ca + ( x-cx)*sa;
    if ( mX <= 0 ) {
      rx = x; 
      ry = y;
    } else if ( mX >= d ) {
      rx = x2; 
      ry = y2;
    } else {
      rx = x + mX*ca; 
      ry = y + mX*sa;
    }

    //  stroke(255, 255, 56);
    // line(rx, ry, cx, cy);
    if (dist(rx, ry, cx, cy)<laserWidth*0.5+cr) {
      hit(enemy);
    }
  }
  void hit(Player enemy) {
    //  particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    enemy.hit(2);
    enemy.pushForce(0.6, angle);
    particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle))*random(10), sin(radians(angle))*random(10), 6, angle, projectileColor));
    particles.add( new  Particle(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), cos(radians(angle))*12, sin(radians(angle))*12, 120, 100, color(255, 0, 255)));
  }
}

class Bomb extends Projectile {//----------------------------------------- Bomb objects ----------------------------------------------------

  float vx, vy, friction=0.95;
  int blastForce=40, blastRadius=200;
  Bomb(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;

    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*F*S;
        y-=vy*F*S;
        vx/=friction;
        vy/=friction;
      } else {
        x+=vx*F*S;
        y+=vy*F*S;
        vx*=friction;
        vy*=friction;
      }
    }
  }
  void display() {
    if (!dead) { 

      strokeWeight(5);
      stroke(0);
      fill(0);
      ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      noFill();
      stroke(random(255));
      ellipse(x, y, size, size);
      if ((deathTime-stampTime)<=100)size=400;
    }
  }

  float calcAngleFromBlastZone(float x, float y, float px, float py) {
    double deltaY = py - y;
    double deltaX = px - x;
    return (float)Math.atan2(deltaY, deltaX) * 180 / PI;
  }

  void hitPlayersInRadius(int range, boolean friendlyFire) {
    if (!freeze &&!reverse) { 
      for (int i=0; i<players.size (); i++) { 
        if (!players.get(i).dead &&(players.get(i).index!= playerIndex || friendlyFire)) {
          if (dist(x, y, players.get(i).x+players.get(i).w*0.5, players.get(i).y+players.get(i).h*0.5)<range) {
            players.get(i).hit(damage);
            players.get(i).pushForce(blastForce, -calcAngleFromBlastZone(x, y, players.get(i).x+players.get(i).w*0.5, players.get(i).y+players.get(i).h*0.5));
          }
        }
      }
    }
  }


  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<8; i++) {
        particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
      }
      particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.5), 200, color(255)));
      particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 150, color(0)));
      particles.add(new Flash(200, 12, color(255)));
      hitPlayersInRadius(blastRadius, true);
      shakeTimer=20;
    }
  }
}

class Mine extends Bomb {//----------------------------------------- Mine objects ----------------------------------------------------
  int vAngle= 6;

  Mine(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage);
  }

  @Override
  void update(){
     super.update();
     if(!dead && !freeze){
       if(reverse) {
          angle-=vAngle*F*S;
       }else{  
          angle+=vAngle*F*S;
       }
   }  
  }
  
  @Override
  void display() {
    if (!dead) { 
      pushMatrix();
      translate(x, y);
        noFill();
        strokeWeight(5);
        stroke(random(255));
        rect(-(size/2), -(size/2), (size), (size));
        rotate(radians(angle));
        stroke(projectileColor);
        rect(-(size/2), -(size/2), (size), (size));
      popMatrix();
    }
  }

  @Override

  void hit(Player enemy) {
    // super.hit();
    // enemy.hit(damage);
    fizzle();
    deathTime=stampTime;   // projectile is dead on collision
    dead=true;
  }
}

class Thunder extends Bomb {//----------------------------------------- Mine objects ----------------------------------------------------
  int segment=40;
  float electryfiy = 0, opacity;
  Thunder(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage);
    blastRadius=400;
  }

  void update(){
      super.update();
      if(!freeze && !dead){
        if(reverse){
          electryfiy-=0.005*F*S;
          opacity-=1.4*F*S;
        }else{
          electryfiy+=0.005*F*S;
          opacity+=1.4*F*S;
        }  
      }
}
  
  void display() {
    if (!dead) { 
      strokeWeight(4);
      stroke(projectileColor, opacity);
      beginShape();
      for (int i=0; i<360; i+= (360/segment)) {
        vertex(x+cos(radians(i))*blastRadius*(1.3-random(electryfiy)), y+sin(radians(i))*blastRadius*(1.3-random(electryfiy)));
      }
      endShape(CLOSE);
      stroke(0, opacity);
      beginShape();
      for (int i=0; i<360; i+= (360/segment)) {
        vertex(x+cos(radians(i))*blastRadius*(1.2-random(electryfiy)), y+sin(radians(i))*blastRadius*(1.2-random(electryfiy)));
      }
      endShape(CLOSE);
    }
  }

  @Override
    void fizzle() {    // when fizzle
    if ( !dead ) {         
      for (int i=0; i<8; i++) {
        particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
      }
      for (int i=0; i<360; i+= (360/6)) {
        particles.add( new Shock(400, int( x), int(y), 0, 0, 2, i, projectileColor)) ;
      }
      particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.5), blastRadius, color(255)));
      particles.add(new Flash(500, 12, color(255)));
      strokeWeight(16);
      noFill();
      beginShape();
      for (int i=20; i<3000; i*= 1.1) {
        vertex(x+cos(radians(random(360)))*i, y+sin(radians(random(360)))*i);
      }
      endShape(CLOSE);
      hitPlayersInRadius(blastRadius, true);
      shakeTimer=50;
    }
  }
  void hit(Player enemy) {
  }
}

class Needle extends Projectile {//----------------------------------------- Needle objects ----------------------------------------------------
  float v, vx, vy, spray=30;
  Needle(int _playerIndex, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_playerIndex, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    v=abs(_vx)+ abs(_vy); 
    damage=_damage;
    vx= _vx;
    vy= _vy;
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        //  opacity+=8*F;
        x-=vx*F*S;
        y-=vy*F*S;
      } else {
        //  opacity-=8*F;
        //  particles.add(new Particle(int(x), int(y), 0, 0, 10, 200, projectileColor));
        x+=vx*F*S;
        y+=vy*F*S;
      }
    }
  }
  void display() {
    if (!dead) { 
      strokeCap(ROUND);
      strokeWeight(8);
      strokeJoin(ROUND);
      stroke(projectileColor);
      line(x, y, x-cos(radians(angle))*size, y-sin(radians(angle))*size);
      stroke(255);
      line(x, y, x-cos(radians(angle))*size*0.2, y-sin(radians(angle))*size*0.2);
      // strokeCap(NORMAL);
    }
  }
  @Override
    void hit(Player enemy) {
    // super.hit();
    enemy.hit(damage);
    deathTime=stampTime;   // dead on collision
    dead=true;
    for (int i=0; i<6; i++) {
      // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
      float sprayAngle=random(-spray, spray)+angle;
      float sprayVelocity=random(v*0.75);
      particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    }
    // particles.add(new LineWave(int(x), int(y), 80, 100, color(255), angle+90));
  }
}

class Slash extends Projectile {//----------------------------------------- Slash objects ----------------------------------------------------
  int traceAmount=8;
  float vx, vy, angleV=24, range, lowRange, traceLowRange[]=new float[traceAmount];
  float pCX, pCY, traceAngle[]=new float[traceAmount];
  Slash(int _playerIndex, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _range, float _vx, float _vy, int _damage) {
    super(_playerIndex, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;
    range= _range;
    pCX=players.get(playerIndex).x+players.get(playerIndex).w*0.5;
    pCY= players.get(playerIndex).y+players.get(playerIndex).w*0.5;
    for (int i=0; i<8; i++) {
      particles.add(new Particle(int(x), int(y), vx/(2-0.12*i), vy/(2-0.12*i), 10+i*4, _time, _projectileColor));
    }
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {

        pCX=players.get(playerIndex).x+players.get(playerIndex).w*0.5;
        pCY= players.get(playerIndex).y+players.get(playerIndex).w*0.5;
        x=pCX-cos(radians(angle))*range;
        y=pCY-sin(radians(angle))*range;
        traceAngle[0]=angle;
        for (int i=1; traceAmount>i; i++) {
          traceAngle[i]=traceAngle[i-1];
        }
        angle-=angleV*F*S;
        traceLowRange[0]=lowRange;
        for (int i=1; traceAmount>i; i++) {
          traceLowRange[i]=traceLowRange[i-1];
        }
        lowRange=sin(radians((180*(deathTime-stampTime)/time)))*range*0.5;
      } else {

        pCX=players.get(playerIndex).x+players.get(playerIndex).w*0.5;
        pCY= players.get(playerIndex).y+players.get(playerIndex).w*0.5;
        x=pCX-cos(radians(angle))*range;
        y=pCY-sin(radians(angle))*range;
        traceLowRange[0]=lowRange;
        /* for (int i=1; traceAmount>i; i++) {
         traceLowRange[i]=traceLowRange[i-1];
         } */
        for (int i = traceAmount-1; i >= 1; i--) {                
          traceLowRange[i]=traceLowRange[i-1];
        }
        lowRange=sin(radians(180*(deathTime-stampTime)/time))*range*0.5;
        //   println((range*(deathTime-stampTime)/time)-range);
        traceAngle[0]=angle;
        angle+=angleV*F*S;
        /*  for (int i=0; traceAmount-1>i; i++) {
         //traceAngle[i]=traceAngle[i-1];
         traceAngle[i+1]=traceAngle[i];
         println(traceAngle[i]);
         }*/

        for (int i = traceAmount-1; i >= 1; i--) {                
          traceAngle[i]=traceAngle[i-1];
        }

        //    int numElts = traceAmount.length - ( remIndex + 1 ) ;
        //  System.arraycopy( traceAmount, remIndex + 1, traceAmount, remIndex, numElts ) ;

        if (lowRange<0) fizzle();
      }
    }
  }
  void display() {
    if (!dead) { 
      // strokeWeight(84);
      strokeWeight(int(range*(angleV*0.02)));
      for (int i=0; traceAmount>i; i++) {
        stroke(projectileColor, (traceAmount-i)*(255/traceAmount));
        // stroke(random(360), random(360), random(360));
        // line(pCX-cos(radians(angle))*(range-lowRange), pCY-sin(radians(angle))*(range-lowRange), pCX-cos(radians(angle))*range, pCY-sin(radians(angle))*range);
        line(pCX -cos(radians(traceAngle[i]))*(range-traceLowRange[i]), pCY-sin(radians(traceAngle[i]))*(range-traceLowRange[i]), pCX-cos(radians(traceAngle[i]))*range, pCY-sin(radians(traceAngle[i]))*range);
      }

      stroke(255);
      line(pCX -cos(radians(angle))*(range-lowRange), pCY-sin(radians(angle))*(range-lowRange), pCX-cos(radians(angle))*range, pCY-sin(radians(angle))*range);
    }
  }
  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<4; i++) {
        particles.add(new Particle(int(x), int(y), cos(radians(random(-15, 15)+angle-120))*10, sin(radians(random(-15, 15)+angle-120))*10, int(random(20)+5), 800, 255));
      }
    }
    dead=true;
  }
  @Override
    void hit(Player enemy) {

    enemy.hit(damage);
    for (int i=0; i<8; i++) {
      particles.add(new Particle(int(x), int(y), random(20)-10, random(20)-10, int(random(20)+5), 800, 255));
    }
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
    }
    enemy.pushForce(-10, angle);
    // particles.add(new Flash(200, 32, 255));  
    particles.add(new LineWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 10, 300, projectileColor, angle+90));
    particles.add(new LineWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 10, 300, color(255), angle+90));
  }
}


class Boomerang extends Projectile {//----------------------------------------- Boomerang objects ----------------------------------------------------
  float v, vx, vy, spray=16, pCX, pCY, graceTime=500, displayAngle, selfHitAngle=80, recoverEnergy, angleSpeed=20;
  Boomerang(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, float _recoverEnergy, float _angleSpeed) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    v=abs(_vx)+ abs(_vy); 
    damage=_damage;
    vx= _vx;
    vy= _vy;
    recoverEnergy=_recoverEnergy;
    angleSpeed=_angleSpeed;
  }
  @Override
    void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        angle=degrees(atan2(vy, vx));
        displayAngle-=angleSpeed*F*S;
        vy/=1-0.98*F*S;
        vx/=1-0.98*F*S;
        vx += (x-players.get(playerIndex).x-players.get(playerIndex).w*0.5)*0.002;
        vy += (y-players.get(playerIndex).y-players.get(playerIndex).w*0.5)*0.002;
        x-=vx*F*S;
        y-=vy*F*S;
        pCX=players.get(playerIndex).x+players.get(playerIndex).w*0.5;
        pCY=players.get(playerIndex).y+players.get(playerIndex).w*0.5;
      } else {

        pCX=players.get(playerIndex).x+players.get(playerIndex).w*0.5;
        pCY=players.get(playerIndex).y+players.get(playerIndex).w*0.5;
        x+=vx*F*S;
        y+=vy*F*S;
        vx -= (x-players.get(playerIndex).x-players.get(playerIndex).w*0.5)*0.002;
        vy -= (y-players.get(playerIndex).y-players.get(playerIndex).w*0.5)*0.002;
        vx*=0.98;
        vy*=0.98;
        displayAngle+=angleSpeed*F*S;
        angle=degrees(atan2(vy, vx));
        if (dist(x, y, pCX, pCY)<50 && (stampTime-spawnTime)>graceTime) retrieve();
      }
    }
  }

  void display() {
    if (!dead) { 
      strokeWeight(8);
      stroke(projectileColor);
      fill(255);

      line(x+cos(radians(displayAngle))*size, y+sin(radians(displayAngle))*size, x-cos(radians(displayAngle))*size, y-sin(radians(displayAngle))*size);
      line(x+cos(radians(displayAngle+45))*size*0.6, y+sin(radians(displayAngle+45))*size*0.6, x-cos(radians(displayAngle+45))*size*0.6, y-sin(radians(displayAngle+45))*size*0.6);

      particles.add(new Particle(int(x), int(y), cos(radians(displayAngle*2))*(vy+vx)*0.5, sin(radians(displayAngle*2))*(vy+vx)*0.5, int(random(10)+5), 150, 255));

      line(x+cos(radians(displayAngle))*size, y+sin(radians(displayAngle))*size, x+cos(radians(displayAngle+45))*size*0.6, y+sin(radians(displayAngle+45))*size*0.6);
      line(x-cos(radians(displayAngle))*size, y-sin(radians(displayAngle))*size, x-cos(radians(displayAngle+45))*size*0.6, y-sin(radians(displayAngle+45))*size*0.6);
    }
  }
  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      deathTime=stampTime;   // dead on collision with owner
      dead=true;
    }
  }

  void retrieve() {
    if (owner.angle-selfHitAngle<angle && owner.angle+selfHitAngle>angle) { 
      owner.hit(int(damage*(abs(vx)+abs(vy))));
      owner.pushForce(vx*1, vy*1, angle);
      for (int i=0; i<16; i++) {
        particles.add(new Spark( 1000, int(x), int(y), (vx+random(-spray, spray))*random(0, 0.8), (vy+random(-spray, spray))*random(0, 0.8), 6, angle, projectileColor));
      }
    } else {
      owner.pushForce(vx*0.2, vy*0.2, angle);
      owner.ability.energy+=recoverEnergy;
      particles.add(new ShockWave(int(players.get(playerIndex).x+players.get(playerIndex).w*0.5), int(players.get(playerIndex).y+players.get(playerIndex).h*0.5), 20, 100, projectileColor));
    }
    deathTime=stampTime;   // dead on collision with owner
    dead=true;
  }

  @Override
    void hit(Player enemy) {
    // super.hit();
    enemy.hit(floor(damage*(abs(vx)+abs(vy))*0.08));
    enemy.pushForce(vx*0.05, vy*0.05, angle);
    //dead=true;
    for (int i=0; i<2; i++) {
      // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
      // float sprayAngle=random(-spray, spray)+angle;
      // float sprayVelocity=random(v*0.75);
      particles.add(new Spark( 1000, int(x), int(y), (vx+random(-spray, spray))*0.4, (vy+random(-spray, spray))*0.4, 6, angle, projectileColor));
    }
  }
}

class HomingMissile extends Projectile {//----------------------------------------- HomingMissile objects ----------------------------------------------------
  
  PShape  sh, c ;
  float vx, vy, homeRate, gravityRate=0.008;
  int ReactionTime=40, count, lockRange=300, seekRadius=4000;
  boolean locked, leap;
  Player target;
  HomingMissile(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;

    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
    sh = createShape();
    c = createShape();
    sh.beginShape();
    sh.fill(255);
    sh.stroke(255, 50);
    sh.vertex(int (-size*0.5), int (-size*0.5) );
    sh.vertex(int (+size*3), int (0));
    sh.vertex(int (-size*0.5), int (+size*0.5));
    sh.vertex(int (+size*0.25), int (0));
    sh.endShape(CLOSE);

    c.beginShape();
    c.fill(projectileColor);
    c.stroke(projectileColor, 50);
    c.vertex(int (0), int (-size/3) );
    c.vertex(int (+size), int (0));
    c.vertex(int (0), int (+size/3));
    c.vertex(int (+size*0.5), int (0));
    c.endShape(CLOSE);

    target=seek(seekRadius); // seek to closest enemy player
    calcAngle();
    ellipse(target.x+target.w*0.5, target.y+target.w*0.5, 200, 200);
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*F*S;
        y-=vy*F*S;
      } else {

        if (target.dead ||target==owner)target=seek(seekRadius); // reseek if target is dead

        if ((locked && !leap)|| (target!=owner && !target.dead && ReactionTime>count && dist(x, y, target.x, target.y)<lockRange)) {
          vx=0;
          vy=0;
          count++;
          if (!locked)locking();
          if (ReactionTime<=count)leaping();
        } else if (leap) {
          vx+=cos(radians(angle))*32*F*S;
          vy+=sin(radians(angle))*32*F*S;
        } else if (!locked) {
          calcAngle();
          vx+=cos(radians(angle))*homeRate*F*S;
          vy+=sin(radians(angle))*homeRate*F*S;
          x+=((target.x+target.w*0.5)-x)*gravityRate*F*S;
          y+=((target.y+target.w*0.5)-y)*gravityRate*F*S;
        }
        x+=vx*F*S;
        y+=vy*F*S;

        homeRate+=0.015;
      }
    }
  }
  void locking() {
    locked=true;
    particles.add(new LineWave(int(x), int(y), 30, 80, projectileColor, angle));
  }
  void leaping() {
    leap=true;
    fill(255);
    noStroke();
    ellipse(x, y, size*2, size*2);
  }
  void display() {
    if (!dead) { 
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      if (locked) {
        shape(sh, sh.width*0.5, sh.height*0.5);
        shape(c, c.width*0.5, c.height*0.5);
      } else {
        fill(projectileColor);
        stroke(255);
        strokeWeight(8);
        ellipse(0, 0, size*2, size);
      }
      popMatrix();
      if (target!=owner && !leap) targetVarning();
    }
  }
  void targetVarning() {
    float tcx=target.x+target.w*0.5, tcy=target.y+target.w*0.5;
    stroke(projectileColor);
    strokeWeight(4);
    noFill();
    ellipse(tcx, tcy, target.w*2, target.w*2);
    line(tcx, tcy, tcx-150, tcy);
    line(tcx, tcy, tcx+150, tcy);
    line(tcx, tcy, tcx, tcy-150);
    line(tcx, tcy, tcx, tcy+150);
    if (locked) {
      strokeWeight(1);
      line(x+cos(radians(angle))*2000, y+sin(radians(angle))*2000, x, y);
    }
  }
  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<4; i++) {
        particles.add(new Particle(int(x), int(y), random(10)-5+vx, random(10)-5+vy, int(random(20)+5), 800, 255));
      }
    }
  }
  @Override
    void hit(Player enemy) {
    enemy.hit(int(leap?damage:damage*0.5));
    deathTime=stampTime;   // dead on collision
    dead=true;
    enemy.pushForce(vx*0.05, vy*0.05, angle);
    for (int i=0; i<8; i++) {
      particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
    }
    particles.add(new Flash(100, 32, 255));  
    particles.add(new LineWave(int(x), int(y), 10, 300, color(255), angle));
  }

  void calcAngle() {
    angle = degrees(atan2(((target.y+target.w*0.5)-y), ((target.x+target.w*0.5)-x)));
  }

  Player seek(int senseRange) {
    for (int sense = 0; sense < senseRange; sense++) {
      for ( int i=0; players.size () > i; i++) {
        if (players.get(i)!= owner && !players.get(i).dead) {
          if (dist(players.get(i).x, players.get(i).y, x, y)<sense*0.5) {  
            return players.get(i);
          }
        }
      }
    }
    return owner;
  }
}

class Shield extends Projectile { //----------------------------------------- Shield objects ----------------------------------------------------

  Shield( Player _owner, int _x, int _y, color _projectileColor, int  _time, float _angle, float _damage  ) {
    super(_owner, _x, _y, 1, _projectileColor, _time);
    //  damage= int(_damage);
    size=150;
    angle=_angle;
  }

  void display() {
    if (!dead ) { 
      strokeWeight(int(10));
      stroke(projectileColor);
      line(cos(radians(angle-90))*size+int(x), sin(radians(angle-90))*size+int(y), cos(radians(angle+90))*size+int(x), sin(radians(angle+90))*size+int(y));
    }
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        //  laserChange-=2;
        //  laserWidth= sin(radians(laserChange))*100;
        //   angle=players.get(playerIndex).angle;
        //  x=players.get(playerIndex).x+50;
        // y=players.get(playerIndex).y+50;
      } else {
        //  laserChange+=2;
        //   laserWidth= sin(radians(laserChange))*100;
        //   angle=players.get(playerIndex).angle;
        // x=players.get(playerIndex).x+50;
        //  y=players.get(playerIndex).y+50;
        //   shakeTimer=int(laserWidth*0.1);
        // particles.add(new  gradient(1000, int(x+size*0.5), int(y+size*0.5), 0, 0, 4, angle, projectileColor));

        /* for (int i= 0; players.size () > i; i++)
         if (playerIndex!=i  && !players.get(i).dead) lineVsCircleCollision(x, y, cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y), players.get(i));
         } */
      }
    }
  }

  void ProjectilelineVsProjectileCircleCollision(float x, float y, float x2, float y2, Projectile projectile) {
    float cx= projectile.x+projectile.size*0.5, cy=projectile.y+projectile.size*0.5, cr= projectile.size*0.5;
    float segV = dist(x2, y2, x, y);
    float segVAngle = degrees(atan2((y2-y), (x2-x)));
    float segC = dist(cx, cy, x, y);
    // float segCAngle = degrees(atan2((cy-y),(c2-x)));
    //  stroke(0);
    // line(x, y, cx, cy);
    //   line(x+cos(radians(segVAngle))*segC, y+sin(radians(segVAngle))*segC, cx, cy);
    //   println(segV+" angle: "+segVAngle+ "      circle:"+ segC);


    float rx, ry;
    float dx = x2 - x;
    float dy = y2 - y;
    float d = sqrt( dx*dx + dy*dy ); 

    //float a = atan2( y2 - y1, x2 - x1 ); 
    //float ca = cos( a ); 
    //float sa = sin( a ); 
    float ca = dx/d;
    float sa = dy/d;
    float mX = (-x+cx)*ca + (-y+cy)*sa; 
    float mY = (-y+cy)*ca + ( x-cx)*sa;
    if ( mX <= 0 ) {
      rx = x; 
      ry = y;
    } else if ( mX >= d ) {
      rx = x2; 
      ry = y2;
    } else {
      rx = x + mX*ca; 
      ry = y + mX*sa;
    }

    //  stroke(255, 255, 56);
    // line(rx, ry, cx, cy);
    //  if (dist(rx, ry, cx, cy)<laserWidth*0.5+cr) {
    //  projectile.angle+=180;
    // }
  }
  void hit(Player enemy) {
    //  particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    //enemy.hit(2);
    enemy.ax=0;
    enemy.ay=0;
    enemy.pushForce(abs(enemy.vx)+abs(enemy.vy), enemy.angle+180);
    particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle))*random(10), sin(radians(angle))*random(10), 6, angle, projectileColor));
    //  particles.add( new  Particle(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), cos(radians(angle))*12, sin(radians(angle))*12, 120, 100, color(255, 0, 255)));
  }
}


class Electron extends Projectile {//----------------------------------------- IceDagger objects ----------------------------------------------------
  boolean orbit=true;
  float orbitAngle, vx, vy, distance=25, maxDistance=200,orbitAngleSpeed=6;
  Electron(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);

    angle=_angle;
    orbitAngle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;

  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*F*S;
        y-=vy*F*S;
      } else {
        if (orbit) {
          if (distance>maxDistance) {
            distance=distance;
          } else {
            distance*=1.02;
          }
          if(owner.dead)orbit=false;
          x=owner.x+owner.w*0.5+cos(radians(orbitAngle))*distance;
          y=owner.y+owner.w*0.5+sin(radians(orbitAngle))*distance;
          orbitAngle+=orbitAngleSpeed*F*S;
          angle+=12*F*S;
        } else {
          angle+=6*F*S;
          x+=vx*F*S;
          y+=vy*F*S;
        }
      }
    }
  }
  void display() {
    if (!dead) { 
   fill(255);
   strokeWeight(6);
   stroke(projectileColor);
    /*  pushMatrix();
      translate(x, y);
      rotate(radians(angle));
   
      rect(-(size*0.5), -(size*0.5), (size), (size));
      popMatrix();*/
      ellipse(x,y,size,size);
    }
  }
  void derail() {
    orbit=false;
    vx=cos(radians(orbitAngle+90))*0.02*orbitAngleSpeed*distance;
    vy=sin(radians(orbitAngle+90))*0.02*orbitAngleSpeed*distance;
    vx+= owner.ax*5;
    vy+= owner.ay*5;
  }
  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<4; i++) {
        particles.add(new Particle(int(x), int(y), random(10)-5+vx, random(10)-5+vy, int(random(20)+5), 800, 255));
      }
    }
  }
  @Override
    void hit(Player enemy) {
    // super.hit();
    if (orbit) { 
      enemy.hit(int(damage*0.5));
      enemy.pushForce(8*orbitAngleSpeed,orbitAngle+90);
    } else { 
      enemy.hit(damage);
          enemy.pushForce(8*orbitAngleSpeed,angle+90);
    }
    deathTime=stampTime;   // dead on collision
    dead=true;
    for (int i=0; i<16; i++) {
      particles.add(new Particle(int(x), int(y), random(20)-10, random(20)-10, int(random(20)+5), 800, 255));
    }
    for (int i=0; i<8; i++) {
      particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
    }
    // particles.add(new Flash(200, 32, 255));  
    // particles.add(new LineWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 10, 300, projectileColor, angle));
  }
}

class Graviton extends Projectile {//----------------------------------------- Graviton objects ----------------------------------------------------

  float vx, vy, friction=0.95;
  int dragForce=-1, dragRadius=250,count;
  Graviton(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    //damage=_damage;
    vx= _vx;
    vy= _vy;

    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
      particles.add(new ShockWave(int(x), int(y), int(dragRadius*0.5), 200, color(_projectileColor)));
      particles.add(new ShockWave(int(x), int(y), int(dragRadius*0.4), 150, color(255)));
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*F*S;
        y-=vy*F*S;
        vx/=friction;
        vy/=friction;
      } else {
        x+=vx*F*S;
        y+=vy*F*S;
        vx*=friction;
        vy*=friction;
        dragPlayersInRadius(dragRadius, false);
        count++;
        if((count%int(35/(F*S)))==0)particles.add(new RShockWave(int(x), int(y), int(dragRadius*2), 400, color(projectileColor)));
      }
    }
  }
  void display() {
    if (!dead) { 

      strokeWeight(5);
      stroke(255);
      fill(projectileColor);
      ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      //noFill();
     // stroke(projectileColor);
     // ellipse(x, y, size, size);
      //ellipse(x, y, dragRadius*2, dragRadius*2);
      if ((deathTime-stampTime)<=100){
        size=400;
      }else {
        size=50;
      }
    }
  }

  float calcAngleFromBlastZone(float x, float y, float px, float py) {
    double deltaY = py - y;
    double deltaX = px - x;
    return (float)Math.atan2(deltaY, deltaX) * 180 / PI;
  }

  void dragPlayersInRadius(int range, boolean friendlyFire) {
    if (!freeze &&!reverse) { 
      for (int i=0; i<players.size (); i++) { 
        if (!players.get(i).dead &&(players.get(i).index!= playerIndex || friendlyFire)) {
          if (dist(x, y, players.get(i).x+players.get(i).w*0.5, players.get(i).y+players.get(i).h*0.5)<range) {
            players.get(i).pushForce(dragForce*F*S, calcAngleFromBlastZone(x, y, players.get(i).x+players.get(i).w*0.5, players.get(i).y+players.get(i).h*0.5));
          }
        }
      }
    }
  }

  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<8; i++) {
        particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
      }
     // particles.add(new Flash(200, 12, color(255)));
      shakeTimer=5;
    }
  }
}

