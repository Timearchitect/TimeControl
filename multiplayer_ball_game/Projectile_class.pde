abstract class Projectile {
  PVector coord;
  PVector speed;
  int  size, damage;
  float x, y, angle;
  long deathTime, spawnTime;
  color projectileColor;
  boolean dead, deathAnimation;
  int  playerIndex=-1;
  Projectile( int _x, int _y, int _size, color _color, int  _time) { // no playerIndex
    x= _x;
    y= _y;
    size=_size;
    projectileColor=_color;
    spawnTime=stampTime;
    deathTime=stampTime + _time;
  }
  Projectile(int _playerIndex, int _x, int _y, int _size, color _color, int  _time) {
    playerIndex=_playerIndex;
    x= _x;
    y= _y;
    size=_size;
    projectileColor=_color;
    spawnTime=stampTime;
    deathTime=stampTime + _time;
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
}

class Ball extends Projectile { //----------------------------------------- ball objects ----------------------------------------------------
  int speedX, speedY, dirX, dirY;
  int [] allies;
  int up, down, left, right;

  Ball( int _x, int _y, int _speedX, int _speedY, int _size, color _color) {
    super( _x, _y, _size, _color, 999999);
    projectileColor=_color;
    coord= new PVector(_x, _y);
    speed= new PVector(_speedX, _speedY);
    angle=degrees( PVector.angleBetween(coord, speed));
  }


  void playerBounds() {
    if (!reverse) {
      for (int i=0; i<players.size (); i++) {

        if (coord.y-size/2+speedY<players.get(i).y+players.get(i).h+10+players.get(i).vy && coord.y+size/2+speedY>players.get(i).y-10+players.get(i).vy) {
          if (coord.x+size/2+speedX> players.get(i).x+20 && coord.x-size/2+speedX< players.get(i).x + players.get(i).w-20 ) {
            // speed.set( speed.x, speed.y*(-1));
            // coord.set( coord.x+speed.x, coord.y+speed.y);
            // y-=players.get(i).vy;
          }
        }

        if (coord.y-size/2+speedY<players.get(i).y+players.get(i).h-20+players.get(i).vy && coord.y+size/2+speedY>players.get(i).y+20+players.get(i).vy) {
          if (coord.x+size/2+speedX> players.get(i).x-10 && coord.x-size/2+speedX< players.get(i).x + players.get(i).w +10 ) {
            //  speed.set( speed.x*(-1), speed.y);
            //  coord.set( coord.x+speed.x+players.get(i).vx, coord.y+speed.y+players.get(i).vy);
            //  x-=players.get(i).vx;
          }
        }
      }
    }
  }
  void checkBounds() {

    if (coord.y-size/2<0 ) { // walls
      speed.set( speed.x, speed.y*(-1));
    } else if (coord.y+size/2>height) {
      speed.set( speed.x, speed.y*(-1));
    }
    if (coord.x-size/2<0 ) {
      speed.set( speed.x*(-1), speed.y);
    } else if (coord.x+size/2>width ) {
      speed.set( speed.x*(-1), speed.y);
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
    ellipse(coord.x, coord.y, size, size);
    line(coord.x, coord.y, coord.x +(speed.x)*10, coord.y+(speed.y)*10);
  }

  void move() {
    //   s =(slow)?slowFactor:1;
    //      f =(fastForward)?speedFactor:1;
    if (stampTime%1==0) {
      if (!freeze) {
        if (reverse) {
          angle=degrees( PVector.angleBetween(speed, coord));
          coord.set(coord.x-speed.x*F*S, coord.y-speed.y*F*S);
        } else {
          coord.set(coord.x+speed.x*F*S, coord.y+speed.y*F*S);
          angle=degrees( PVector.angleBetween(coord, speed));
        }
      }
    }
  }
}

class IceDagger extends Projectile {//----------------------------------------- IceDagger objects ----------------------------------------------------
  PShape  sh, c ;
  float vx, vy;
  IceDagger(int _playerIndex, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy) {
    super(_playerIndex, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=6;
    vx= _vx;
    vy= _vy;
    background(150);
    for (int i=0; i<8; i++) {
      particles.add(new Particle(int(x), int(y), vx/(2-0.12*i), vy/(2-0.12*i), 10+i*4, _time, _projectileColor));
    }
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx/2, random(10)-5+vy/2, int(random(20)+5), 800, 255));
    }
    sh = createShape();
    c = createShape();
    sh.beginShape();
    sh.fill(255);
    sh.stroke(255, 50);
    sh.vertex(int (0), int (-size/2) );
    sh.vertex(int (+size*2), int (0));
    sh.vertex(int (0), int (+size/2));
    sh.vertex(int (-size), int (0));
    sh.endShape(CLOSE);

    c.beginShape();
    c.fill(projectileColor);
    c.stroke(projectileColor, 50);
    c.vertex(int (0), int (-size/3) );
    c.vertex(int (+size), int (0));
    c.vertex(int (0), int (+size/3));
    c.vertex(int (-size/2), int (0));
    c.endShape(CLOSE);
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
      // rect(x-(size/2), y-(size/2), (size), (size));
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      // rect(-(size/2), -(size/2), (size), (size));
      shape(sh, sh.width/2, sh.height/2);
      shape(c, c.width/2, c.height/2);
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
    deathTime=stampTime;   // dead on collision
    dead=true;
    for (int i=0; i<8; i++) {
      particles.add(new Particle(int(x), int(y), random(20)-10, random(20)-10, int(random(20)+5), 800, 255));
    }
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
    }
    particles.add(new Flash(200, 32, 255));  
    particles.add(new LineWave(int(enemy.x+enemy.w/2), int(enemy.y+enemy.h/2), 10, 300, projectileColor));
  }
}

class forceBall extends Projectile { //----------------------------------------- forceBall objects ----------------------------------------------------
  float vx, vy,v, ax, ay, angleV;
  boolean charging;
  forceBall(int _playerIndex, int _x, int _y,float _v, int _size, color _projectileColor, int  _time, float _angle ,float _damage) {
    super(_playerIndex, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    angleV=10;
    damage=int(_damage);
    v=_v;
    vx= cos(radians(angle))*_v;
    vy= sin(radians(angle))*_v;
    background(150);
    for (int i=0; i<8; i++) {
      particles.add(new Particle(int(x), int(y), vx/(2-0.12*i), vy/(2-0.12*i), 10+i*4, _time, _projectileColor));
    }
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx/2, random(10)-5+vy/2, int(random(20)+5), 800, 255));
    }
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        //  opacity+=8*F;
        if (charging) angle+=angleV*F*S;
        x-=vx*F*S;
        y-=vy*F*S;
      } else {
        //  opacity-=8*F;
        if (charging) angle-=angleV*F*S;
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
    deathTime=stampTime;   // dead on collision
    dead=true;
    for (int i=0; i<8; i++) {
      particles.add(new Particle(int(x), int(y), random(20)-10, random(20)-10, int(random(20)+5), 800, 255));
    }
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
    }
    particles.add(new Flash(200, 32, 255));  
    particles.add(new ShockWave(int(enemy.x+enemy.w/2), int(enemy.y+enemy.h/2), 20, 200, projectileColor));
    particles.add(new ShockWave(int(x), int(y), 300, 400, projectileColor));
    particles.add(new ShockWave(int(x), int(y), 200, 500, color(255,0,255)));
    shakeTimer=30;
  }
}

