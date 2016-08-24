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
    this(_x, _y, _size, _color, _time);
    playerIndex=_playerIndex;
    ally=players.get(_playerIndex).ally;
  }
  Projectile(Player _owner, int _x, int _y, int _size, color _color, int  _time) {
    this(_x, _y, _size, _color, _time);
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
  Player seek(int senseRange) {
    for (int sense = 0; sense < senseRange; sense++) {
      for ( int i=0; players.size () > i; i++) {
        if (players.get(i)!= owner && !players.get(i).dead && players.get(i).ally!=owner.ally) {
          if (dist(players.get(i).x, players.get(i).y, x, y)<sense*0.5) {  
            return players.get(i);
          }
        }
      }
    }
    return owner;
  }
}

class Ball extends Projectile implements Reflectable { //----------------------------------------- ball objects ----------------------------------------------------
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
    /*
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
     */
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
    if (!dead) { 
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
      if (cheatEnabled) line(x, y, x +(vx)*10, y+(vy)*10);
    }
  }

  void move() {
    //   s =(slow)?slowFactor:1;
    //      f =(fastForward)?speedFactor:1;
    if (stampTime%1==0) {
      if (!dead && !freeze) { 
        if (reverse) {
          angle=degrees( PVector.angleBetween(speed, coord));
          coord.set(coord.x-speed.x*timeBend, coord.y-speed.y*timeBend);
          x-=vx*timeBend;
          y-=vy*timeBend;
        } else {
          coord.set(coord.x+speed.x*timeBend, coord.y+speed.y*timeBend);
          angle=degrees( PVector.angleBetween(coord, speed));
          x+=vx*timeBend;
          y+=vy*timeBend;
        }
      }
    }
  }


  void update() {
    move();
    checkBounds();
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

  @Override
    public void reflect(float _angle, Player _player) {
    //playerIndex=_player.index;
    //owner=_player;
    //projectileColor=owner.playerColor;
    //ally=owner.ally;

    angle=degrees(atan2(vy, vx));
    float diff=_angle;
    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;
    for (int i=0; i<3; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5, random(10)-5, int(random(20)+5), 800, 0));
    }
    owner.ally=_player.ally;
    owner=_player;
    projectileColor=_player.playerColor;
    //particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*15;
    vy= sin(radians(angle))*15;
    x+= cos(radians(angle))*10;
    y+=sin(radians(angle))*10;
  }
}

class IceDagger extends Projectile implements Reflectable {//----------------------------------------- IceDagger objects ----------------------------------------------------
  PShape  sh, c ;
  float vx, vy;
  int smoke;
  IceDagger(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);

    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;

    /*for (int i=0; i<7; i++) {
     particles.add(new Particle(int(x), int(y), vx/(2-0.12*i), vy/(2-0.12*i), 10+i*4, _time, _projectileColor));
     }
     for (int i=0; i<2; i++) {
     particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
     }*/
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
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        if (smoke%1==0)particles.add(new Particle(int(x), int(y), vx*0.2, vy*0.2, int(random(10)+5), 900, projectileColor));
        smoke++;
        x+=vx*timeBend;
        y+=vy*timeBend;
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
    //particles.add(new Flash(200, 32, 255));  
    particles.add(new LineWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 10, 300, projectileColor, angle));
  }
  public void reflect(float _angle, Player _player) {
    angle=_angle;
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;
    c = createShape();

    c.beginShape();
    c.fill(projectileColor);
    c.stroke(projectileColor, 50);
    c.vertex(int (0), int (-size/3) );
    c.vertex(int (+size), int (0));
    c.vertex(int (0), int (+size/3));
    c.vertex(int (-size*0.5), int (0));
    c.endShape(CLOSE);

    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy));
    vy= sin(radians(angle))*(abs(vx)+abs(vy));
  }
}

class ArchingIceDagger extends IceDagger {//----------------------------------------- IceDagger objects ----------------------------------------------------
  float startCurveAngle, angleCurve, currentAngle, transition, eVx, eVy, sVx, sVy;
  final int arch =24;
  ArchingIceDagger(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _angleCurve, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time*2, _angle, _vx, _vy, _damage);
    float totalVelocity= (abs(_vx)+abs(_vy));
    eVx=sin(radians(_angleCurve))*totalVelocity;
    eVy=-cos(radians(_angleCurve))*totalVelocity;
    sVx=_vx;
    sVy=_vy;
    angleCurve= _angleCurve;
    startCurveAngle=_angle;
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        angleCurve();
        if (transition>0)transition-=0.01*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
        angle-=arch*timeBend;
      } else {
        if (smoke%2==0)particles.add(new Particle(int(x), int(y), -vx*0.1, -vy*0.1, int(random(10)+5), 900, projectileColor));
        smoke++;
        angle+=arch*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
        if (transition<1)transition+=0.01*timeBend;
        angleCurve();
      }
    }
  }
  void display() {
    if (!dead) { 
      // rect(x-(size/2), y-(size/2), (size), (size));
      // fill(0);
      //  text("s: "+ angleCurve, x, y-100);
      //  text("e: "+ startCurveAngle, x, y-75);
      //  text("c: "+ currentAngle, x, y-50);
      pushMatrix();
      translate(x, y);

      rotate(radians(angle));

      // rect(-(size/2), -(size/2), (size), (size));
      shape(sh, sh.width*0.5, sh.height*0.5);
      shape(c, c.width*0.5, c.height*0.5);
      popMatrix();
    }
  }

  void angleCurve() {
    vx=sVx*(1-transition) + eVx*transition;
    vy=sVy*(1-transition) + eVy*transition;
    /*
    float totalVelocity= (abs(vx)+abs(vy))/1.2;
     currentAngle= startCurveAngle*(1-transition) + angleCurve*transition;
     vx = sin(currentAngle)*totalVelocity;
     vy = cos(currentAngle)*totalVelocity;
     */
  }
}


class forceBall extends Projectile implements Reflectable { //----------------------------------------- forceBall objects ----------------------------------------------------
  //scaled object by velocity
  float vx, vy, v, ax, ay, angleV;
  //boolean charging;
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
        //if (charging) angle+=angleV*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        //  opacity-=8*F;
        // if (charging) angle-=angleV*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
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
    if (damage>100)     particles.add(new TempSlow(1000, 0.05, 1.05));
    if(damage>300) particles.add( new TempFreeze(500));
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
    particles.add(new ShockWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 20, 16, 200, projectileColor));
    particles.add(new ShockWave(int(x), int(y), int(v*4), 16, int(v*4), projectileColor));
    particles.add(new ShockWave(int(x), int(y), int( v*2), 16, int(v*5), color(255, 0, 255)));
    shakeTimer=int(force*0.8);
  }

  public void reflect(float _angle, Player _player) {
    // angle=angle+180;
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;
    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy));
    vy= sin(radians(angle))*(abs(vx)+abs(vy));
  }
}
class RevolverBullet extends Projectile implements Reflectable { //----------------------------------------- forceBall objects ----------------------------------------------------
  //scaled object by velocity
  float vx, vy, v, ax, ay, angleV, spray=30;
  RevolverBullet(Player _owner, int _x, int _y, float _v, int _size, color _projectileColor, int  _time, float _angle, float _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    angleV=10;
    damage=int(_damage);
    v=_v;
    force=5;
    vx= cos(radians(angle))*_v;
    vy= sin(radians(angle))*_v;

    for (int i=0; i<4; i++) {
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
        //if (charging) angle+=angleV*timeBend;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        //  opacity-=8*F;
        // if (charging) angle-=angleV*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
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
      ellipse(0, 0, size+size*v*0.1, size*.5);
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
    /*for (int i=0; i<int (v*0.4); i++) { // particles
     particles.add(new Particle(int(x), int(y), random(-int(v*0.2), int(v*0.2)), random(-int(v*0.2), int(v*0.2)), int(random(5, 30)), 800, 255));
     }*/
    for (int i=0; i<15; i++) {
      float sprayAngle=random(-spray, spray)+angle;
      float sprayVelocity=random(v*0.75);
      particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    }
    //enemy.pushForce(0.6, angle);
    //particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle))*random(10), sin(radians(angle))*random(10), 6, angle, projectileColor));

    particles.add(new ShockWave(int(x), int(y), int(v*4), 22, 100, projectileColor));
    shakeTimer=int(force*0.2);
  }

  public void reflect(float _angle, Player _player) {
    // angle=angle+180;
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;
    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy));
    vy= sin(radians(angle))*(abs(vx)+abs(vy));
  }
}
class ChargeLaser extends Projectile { //----------------------------------------- forceBall objects ----------------------------------------------------
  long chargeTime;
  final long MaxChargeTime=500;
  final int laserLength=2500;
  float maxLaserWidth, laserWidth, laserChange;

  /* ChargeLaser( int _playerIndex, int _x, int _y, int _maxLaserWidth, color _projectileColor, int  _time, float _angle, float _damage  ) {
   super(_playerIndex, _x, _y, 1, _projectileColor, _time);
   damage= int(_damage);
   maxLaserWidth=_maxLaserWidth;
   angle=_angle;
   owner=players.get(_playerIndex);
   }*/
  ChargeLaser( Player _owner, int _x, int _y, int _maxLaserWidth, color _projectileColor, int  _time, float _angle, float _damage  ) {
    super(_owner, _x, _y, 1, _projectileColor, _time);
    damage= int(_damage);
    maxLaserWidth=_maxLaserWidth;
    angle=_angle;
  }


  void display() {
    if (!dead ) { 

      strokeWeight(int(laserWidth));
      stroke(projectileColor);
      line(int(x), int(y), cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y));
      //arc(int(x),int(y),1,1,radians(angle+90),radians(angle+275));
      ellipse(x, y, int(laserWidth*0.1), int(laserWidth*0.1));

      stroke(255);
      strokeWeight(int(laserWidth*0.6));
      ellipse(x, y, int(laserWidth*0.1), int(laserWidth*0.1));

      //arc(int(x),int(y),1,1,radians(angle+90),radians(angle-275));
      line(int(x), int(y), cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y));
    }
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        laserChange-=2*timeBend;
        laserWidth= sin(radians(laserChange))*maxLaserWidth;
        angle=owner.angle;
        x=owner.x+50;
        y=owner.y+50;
      } else {
        laserChange+=2*timeBend;
        laserWidth= sin(radians(laserChange))*maxLaserWidth;
        angle=owner.angle;
        x=owner.x+50;
        y=owner.y+50;
        //   particles.add( new  Particle(int(x+random(-laserWidth*1.5,laserWidth*1.5)-50), int(y+random(-laserWidth*1.5,laserWidth*1.5)-50), int( cos(radians(angle))*60), int(sin(radians(angle))*60), int(random(-laserWidth*0.5,laserWidth*0.5)), 400, projectileColor));
        //particles.add( new  Particle(int(x), int(y), 0, 0, int(125), 0, color(255, 0, 255)));
        if (laserWidth<0) {
          fizzle(); 
          dead=true;
          deathTime=stampTime;
        }
        owner.pushForce(-0.2, angle);
        shakeTimer=int(laserWidth*0.1);
        particles.add(new  gradient(1000, int(x+size*0.5 +cos(radians(angle))*owner.w*0.5), int(y+size*0.5+sin(radians(angle))*owner.w*0.5), 0, 0, int(laserWidth), 4, angle, projectileColor));

        for (int i= 0; players.size () > i; i++)
          if (playerIndex!=i  && !players.get(i).dead && players.get(i).ally != owner.ally ) lineVsCircleCollision(x, y, cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y), players.get(i));
      }
    }
  }
  public void lineVsCircleCollision(float x, float y, float x2, float y2, Player enemy) {
    float cx= enemy.x+enemy.w*0.5, cy=enemy.y+enemy.w*0.5, cr= enemy.w*0.5;
    // float segV = dist(x2, y2, x, y);
    // float segVAngle = degrees(atan2((y2-y), (x2-x)));
    // float segC = dist(cx, cy, x, y);
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
    enemy.hit(damage);
    enemy.pushForce(0.6, angle);
    particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle))*random(10), sin(radians(angle))*random(10), 6, angle, projectileColor));
    particles.add( new  Particle(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), cos(radians(angle))*12, sin(radians(angle))*12, 120, 100, color(255, 0, 255)));
  }

  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<10; i++) {
        int temp= int(random(laserLength));
        int tempVel= int(random(12));
        particles.add(new Spark( 1200, int(x+cos(radians(angle))*temp), int(y+sin(radians(angle))*temp), cos(radians(angle))*tempVel, sin(radians(angle))*tempVel, 4, angle, projectileColor));
      }
    }
  }
}

class SniperBullet extends ChargeLaser { //----------------------------------------- SniperBullet objects ----------------------------------------------------

  /*
  SniperBullet( int _playerIndex, int _x, int _y, int _maxLaserWidth, color _projectileColor, int  _time, float _angle, float _damage  ) {
   super( _playerIndex, _x, _y, _maxLaserWidth, _projectileColor, _time, _angle, _damage  );
   particles.add(new Flash(50, 50, color(0)));
   particles.add(new ShockWave(int(x), int(y), int(size*0.25),40, 80, color(255)));
   }*/
  SniperBullet( Player _owner, int _x, int _y, int _maxLaserWidth, color _projectileColor, int  _time, float _angle, float _damage  ) {
    super( _owner, _x, _y, _maxLaserWidth, _projectileColor, _time, _angle, _damage  );
    particles.add(new Flash(50, 50, color(0)));
    particles.add(new ShockWave(int(x), int(y), int(size*0.25), 40, 80, color(255)));
    force=3;
    //particles.add( new TempFreeze(100));

  }


  void display() {
    if (!dead ) { 
      println(damage);
      strokeWeight(int(laserWidth));
      stroke(projectileColor);
      line(int(x), int(y), cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y));
      //arc(int(x),int(y),1,1,radians(angle+90),radians(angle+275));
      ellipse(x, y, int(laserWidth*0.1), int(laserWidth*0.1));

      stroke(255);
      strokeWeight(int(laserWidth*0.6));
      ellipse(x, y, int(laserWidth*0.1), int(laserWidth*0.1));

      //arc(int(x),int(y),1,1,radians(angle+90),radians(angle-275));
      line(int(x), int(y), cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y));
    }
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        laserChange-=2*timeBend;
        laserWidth= sin(radians(laserChange))*maxLaserWidth;
        // x=owner.x+50;
        // y=owner.y+50;
      } else {
        laserChange+=2*timeBend;
        laserWidth= sin(radians(laserChange))*maxLaserWidth;
        //x=owner.x+50;
        // y=owner.y+50;
        //   particles.add( new  Particle(int(x+random(-laserWidth*1.5,laserWidth*1.5)-50), int(y+random(-laserWidth*1.5,laserWidth*1.5)-50), int( cos(radians(angle))*60), int(sin(radians(angle))*60), int(random(-laserWidth*0.5,laserWidth*0.5)), 400, projectileColor));
        //particles.add( new  Particle(int(x), int(y), 0, 0, int(125), 0, color(255, 0, 255)));
        if (laserWidth<0) {
          fizzle(); 
          dead=true;
          deathTime=stampTime;
        }
        owner.pushForce(-0.2, angle);
        //shakeTimer=int(laserWidth*0.1);
        particles.add(new  gradient(1000, int(x+size*0.5 +cos(radians(angle))*owner.w*0.5), int(y+size*0.5+sin(radians(angle))*owner.w*0.5), 0, 0, 40, 6, angle, projectileColor));

        for (int i= 0; players.size () > i; i++)
          if (playerIndex!=i  && !players.get(i).dead && players.get(i).ally != owner.ally ) lineVsCircleCollision(x, y, cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y), players.get(i));
      }
    }
  }
  @Override
    void hit(Player enemy) {
          enemy.hit(damage);
          particles.add( new TempFreeze(100));
        particles.add( new TempSlow(25, 0.1, 1.00));
      
    //  particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));

    enemy.pushForce(3, angle);
     particles.add(new Flash(100, 24, color(0)));
    particles.add(new LineWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 10, 200, projectileColor, angle+90));
    particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle))*random(10), sin(radians(angle))*random(10), 6, angle, projectileColor));

     shakeTimer+=damage*0.3;    
    particles.add( new  Particle(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), cos(radians(angle))*36, sin(radians(angle))*36, 100, 120, color(255, 0, 255)));
    particles.add( new  Particle(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), cos(radians(angle))*24, sin(radians(angle))*24, 200, 120, color(255, 0, 255)));
    particles.add( new  Particle(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), cos(radians(angle))*12, sin(radians(angle))*12, 300, 120, color(255, 0, 255)));
  }
}

class Bomb extends Projectile implements Reflectable {//----------------------------------------- Bomb objects ----------------------------------------------------

  float vx, vy, friction=0.95;
  int blastForce=40, blastRadius=200;
  boolean friendlyFire;
  Bomb(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;
    friendlyFire=_friendlyFire;
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
  }

  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
      } else {
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
      }
    }
  }

  void display() {
    if (!dead) { 
      strokeWeight(5);
      stroke((friendlyFire)? color(0):color(owner.playerColor));
      fill((friendlyFire)? color(0):color(owner.playerColor));
      ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      noFill();
      stroke(random(255));
      ellipse(x, y, size, size);
      /*if ((deathTime-stampTime)<=100)size=400;
       else size=50;*/
    }
  }

  float calcAngleFromBlastZone(float x, float y, float px, float py) {
    double deltaY = py - y;
    double deltaX = px - x;
    return (float)Math.atan2(deltaY, deltaX) * 180 / PI;
  }

  void hitPlayersInRadius(int range, boolean _friendlyFire) {
    if (!freeze &&!reverse) { 
      for (int i=0; i<players.size(); i++) { 
        if ( !players.get(i).dead && (players.get(i).ally !=owner.ally || _friendlyFire)) { //players.get(i).index!= playerIndex && 
          if (dist(x, y, players.get(i).x+players.get(i).w*0.5, players.get(i).y+players.get(i).h*0.5)<range) {
            players.get(i).hit(damage);
            players.get(i).pushForce(blastForce, calcAngleFromBlastZone(x, y, players.get(i).x+players.get(i).w*0.5, players.get(i).y+players.get(i).h*0.5));
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

      particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.5), 16, 200, color(255)));
      particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 32, 150, (friendlyFire)? color(0):color(owner.playerColor)));
      particles.add(new Flash(200, 12, color(255)));
      hitPlayersInRadius(blastRadius, friendlyFire);
      shakeTimer=20;
    }
  }

  public void reflect(float _angle, Player _player) {
    angle=_angle;
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;

    particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));

    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy));
    vy= sin(radians(angle))*(abs(vx)+abs(vy));
  }
}

class DetonateBomb extends Bomb {//----------------------------------------- Bomb objects ----------------------------------------------------

  float vx, vy, friction=0.95;
  int blastForce=20, blastRadius=160;
  long originalDeathTime;
  DetonateBomb(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    originalDeathTime=deathTime;
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        if (deathTime>stampTime)deathTime=originalDeathTime; // resetDeathTime if detonated
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
      } else {
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
      }
    }
  }
  void display() {
    if (!dead) { 
      strokeWeight(5);
      stroke(owner.playerColor, 15);
      fill(owner.playerColor, 15);
      ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      noFill();
      stroke(owner.playerColor, 15);
      ellipse(x, y, size, size);
      if ((deathTime-stampTime)<=100)size=400;
      else size=50;
    }
  }
  @Override
    float calcAngleFromBlastZone(float x, float y, float px, float py) {
    double deltaY = py - y;
    double deltaX = px - x;
    return (float)Math.atan2(deltaY, deltaX) * 180 / PI;
  }
  @Override
    void hitPlayersInRadius(int range, boolean _friendlyFire) {
    if (!freeze &&!reverse) { 
      for (int i=0; i<players.size(); i++) { 
        if (!players.get(i).dead &&(players.get(i).index!= playerIndex || _friendlyFire )) {
          if (dist(x, y, players.get(i).x+players.get(i).w*0.5, players.get(i).y+players.get(i).h*0.5)<range) {
            players.get(i).hit(damage);
            players.get(i).pushForce(blastForce, calcAngleFromBlastZone(x, y, players.get(i).x+players.get(i).w*0.5, players.get(i).y+players.get(i).h*0.5));
          }
        }
      }
    }
  }

  void detonate() {
    dead=true;
    fizzle();
  }

  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {    
      for (int i=0; i<360; i+=30) {
        projectiles.add( new Needle(owner, int(x+cos(radians(i+15))*250), int(y+sin(radians(i+15))*250), 60, color(0), 600, i+195, -cos(radians(i+15))*35, -sin(radians(i+15))*35, 25));
        projectiles.add( new Needle(owner, int(x+cos(radians(i))*200), int(y+sin(radians(i))*200), 60, owner.playerColor, 600, i+180, -cos(radians(i))*20, -sin(radians(i))*20, 10));
      }
      for (int i=0; i<8; i++) {
        particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
      }
      particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.5), 16, 175, owner.playerColor));
      particles.add(new ShockWave(int(x), int(y), int(blastRadius), 16, 1000, color(0)));
      //particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 125, owner.playerColor));
      particles.add(new Flash(200, 12, color(255)));
      hitPlayersInRadius(blastRadius, friendlyFire);
      shakeTimer=20;
    }
  }
}

class Mine extends Bomb {//----------------------------------------- Mine objects ----------------------------------------------------
  int vAngle= 6;
  color freezeColor;
  Mine(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    ally=-1;
    owner=_owner;
    //  angle=_angle;
    playerIndex=-1;
    //  owner=_player;
    // projectileColor=owner.playerColor;
    // ally=owner.ally;
  }

  @Override
    void update() {
    super.update();
    if (!dead && !freeze) {
      freezeColor=color(random(255));
      if (reverse) {
        angle-=vAngle*timeBend;
      } else {  
        angle+=vAngle*timeBend;
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
      stroke(freezeColor);
      if (spawnTime+1000<stampTime) rect(-(size/2), -(size/2), (size), (size));
      rotate(radians(angle));
      stroke((friendlyFire)? color(0):color(owner.playerColor));
      rect(-(size/2), -(size/2), (size), (size));
      popMatrix();
    }
  }

  @Override

    void hit(Player enemy) {
    // super.hit();
    // enemy.hit(damage);
    if (spawnTime+1000<stampTime) {
      fizzle();
      deathTime=stampTime;   // projectile is dead on collision
      dead=true;
    }
  }
  public void reflect(float _angle, Player _player) {
    owner=_player;
  }
}
class Rocket extends Bomb implements Reflectable {//----------------------------------------- Bomb objects ----------------------------------------------------

  float timedScale;
  Rocket(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
  }

  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
      } else {
        particles.add(new Particle(int(x), int(y), 0, 0, int(random(25)+8), 800, 255));
        timedScale =size-(size*(deathTime-stampTime)/time);
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
      }
    }
  }

  void display() {
    if (!dead) { 
      strokeWeight(5);
      stroke((friendlyFire)? color(0):color(owner.playerColor));
      fill((friendlyFire)? color(0):color(owner.playerColor));
      //ellipse(x, y, (, (size*(deathTime-stampTime)/time)-size );
      triangle(x+cos(radians(angle-140))*timedScale, y+sin(radians(angle-140))*timedScale, x+cos(radians(angle))*timedScale, y+sin(radians(angle))*timedScale, x+cos(radians(angle+140))*timedScale, y+sin(radians(angle+140))*timedScale  );
      noFill();
      triangle(x+cos(radians(angle-140))*size, y+sin(radians(angle-140))*size, x+cos(radians(angle))*size, y+sin(radians(angle))*size, x+cos(radians(angle+140))*size, y+sin(radians(angle+140))*size  );
      //stroke(random(255));
      // ellipse(x, y, size, size);
    }
  }


  @Override
    void hit(Player enemy) {    // when hit
    super.hit(enemy);
    particles.add( new TempSlow(25, 0.05, 1.05));

    fizzle();
    deathTime=stampTime;   // projectile is dead on collision
    dead=true;
  }
  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      payLoad();
    }
  }
  public void payLoad() {
    for (int i=0; i<8; i++) {
      particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
    }
    for (int i=0; i<360; i+=360/6) {
      projectiles.add( new Bomb(owner, int( x), int(y), 25, owner.playerColor, 400, owner.angle+i, cos(radians(owner.angle+i))*10+vx, sin(radians(owner.angle+i))*10+vy, damage, false));
    }
    fill((friendlyFire)? color(0):color(owner.playerColor));
    ellipse(x, y, size*5, size*5);
    particles.add(new ShockWave(int(x+vx), int(y+vy), int(blastRadius*0.5), 20, 220, color(255)));
    particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 18, 150, (friendlyFire)? color(0):color(owner.playerColor)));
    particles.add(new Flash(200, 12, color(255)));
    hitPlayersInRadius(blastRadius, friendlyFire);
    shakeTimer=20;
  }
  /* public void reflect(float _angle, Player _player) {
   angle=_angle;
   playerIndex=_player.index;
   owner=_player;
   projectileColor=owner.playerColor;
   ally=owner.ally;
   
   particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
   
   vx=-vx;
   vy=-vy;
   }*/
}

class Missle extends Rocket implements Reflectable {//----------------------------------------- Bomb objects ----------------------------------------------------
  int angleSpeed=13;
  Player target;
  Missle(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
    friction=0.9;
  }
  @Override
    void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
      } else {
        particles.add(new Particle(int(x), int(y), 0, 0, int(random(25)+8), 800, owner.playerColor));


        //angle+=sin(radians(count))*10;
        // count+=10;
        timedScale =size-(size*(deathTime-stampTime)/time);
        x+=(vx+cos(radians(angle))*angleSpeed)*timeBend;
        y+=(vy+sin(radians(angle))*angleSpeed)*timeBend;

        target= seek(1200);
        if (target!=owner) { 
          float tx=target.x+target.w*.5, ty=target.y+target.h*.5;
          angle = atan2(ty-y, tx-x) * 180 / PI;
          stroke(255);
          line(x, y, tx, ty);
          targetHommingVarning(target);
        }
        //vx+=;
        //vy+=sin(radians(angle))*10;
        //vx=constrain(vx,-10,10);
        //vy=constrain(vy,-10,10);
        vx*=friction;
        vy*=friction;
      }
    }
  }
  @Override
    public void payLoad() {
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
    }
    /*for (int i=0; i<360; i+=360/6) {
     projectiles.add( new Bomb(owner, int( x), int(y), 25, owner.playerColor, 400, owner.angle+i, cos(radians(owner.angle+i))*10+vx, sin(radians(owner.angle+i))*10+vy, damage, false));
     }*/
    fill((friendlyFire)? color(0):color(owner.playerColor));
    ellipse(x, y, size*4, size*4);
    particles.add(new ShockWave(int(x+vx), int(y+vy), int(blastRadius*0.5), 20, 220, color(255)));
    particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 18, 150, (friendlyFire)? color(0):color(owner.playerColor)));
    particles.add(new Flash(200, 12, color(255)));
    hitPlayersInRadius(blastRadius, friendlyFire);
    shakeTimer=15;
  }
}
class SinRocket extends Rocket implements Reflectable {//----------------------------------------- Bomb objects ----------------------------------------------------
  int count, angleSpeed=16;
  Player target;
  SinRocket(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
    friction=0.9;
  }
  @Override
    void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
      } else {
        particles.add(new Particle(int(x), int(y), 0, 0, int(random(25)+8), 800, color(255)));

        angle+=sin(radians(count))*10;
        count+=10;
        timedScale =size-(size*(deathTime-stampTime)/time);
        x+=(vx+cos(radians(angle))*angleSpeed)*timeBend;
        y+=(vy+sin(radians(angle))*angleSpeed)*timeBend;

        //vx+=;
        //vy+=sin(radians(angle))*10;
        //vx=constrain(vx,-10,10);
        //vy=constrain(vy,-10,10);
        vx*=friction;
        vy*=friction;
      }
    }
  }
  @Override
    public void payLoad() {
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
    }
    /*for (int i=0; i<360; i+=360/6) {
     projectiles.add( new Bomb(owner, int( x), int(y), 25, owner.playerColor, 400, owner.angle+i, cos(radians(owner.angle+i))*10+vx, sin(radians(owner.angle+i))*10+vy, damage, false));
     }*/
    fill((friendlyFire)? color(0):color(owner.playerColor));
    ellipse(x, y, size*4, size*4);
    particles.add(new ShockWave(int(x+vx), int(y+vy), int(blastRadius*0.5), 20, 220, color(255)));
    particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 18, 150, (friendlyFire)? color(0):color(owner.playerColor)));
    particles.add(new Flash(200, 12, color(255)));
    hitPlayersInRadius(blastRadius, friendlyFire);
    shakeTimer=15;
  }
}
class RCRocket extends Rocket implements Reflectable {//----------------------------------------- Bomb objects ----------------------------------------------------
  RCRocket(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
    // friction=0.99;
  }
  @Override
    void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
        angle=owner.keyAngle;
      } else {
        particles.add(new Particle(int(x), int(y), 0, 0, int(random(25)+8), 800, owner.playerColor));
        timedScale =size-(size*(deathTime-stampTime)/time);
        angle=owner.keyAngle;
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx+=cos(radians(angle))*2;
        vy+=sin(radians(angle))*2;
        vx*=friction;
        vy*=friction;
      }
    }
  }
  @Override
    public void payLoad() {
    for (int i=0; i<8; i++) {
      particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
    }
    /*for (int i=0; i<360; i+=360/6) {
     projectiles.add( new Bomb(owner, int( x), int(y), 25, owner.playerColor, 400, owner.angle+i, cos(radians(owner.angle+i))*10+vx, sin(radians(owner.angle+i))*10+vy, damage, false));
     }*/
    fill((friendlyFire)? color(0):color(owner.playerColor));
    ellipse(x, y, size*5, size*5);
    particles.add(new ShockWave(int(x+vx), int(y+vy), int(blastRadius*0.5), 20, 220, color(255)));
    particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 18, 150, (friendlyFire)? color(0):color(owner.playerColor)));
    particles.add(new Flash(200, 12, color(255)));
    hitPlayersInRadius(blastRadius, friendlyFire);
    shakeTimer=15;
  }
}
class Thunder extends Bomb {//----------------------------------------- Thunder objects ----------------------------------------------------
  int segment=40;
  PShape shockCircle = createShape();       // First create the shape
  float electryfiy = 0, opacity;
  boolean firstFrozen;
  Thunder(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, true);
    blastRadius=_size;
  }

  void update() {
    super.update();
    if (!freeze && !dead) {
      if (reverse) {
        electryfiy-=0.006*timeBend;
        opacity-=1.4*timeBend;
      } else {
        electryfiy+=0.006*timeBend;
        opacity+=1.4*timeBend;
      }
    }
  }

  void display() {
    if (!dead) {
      if (!freeze) {
        if (!firstFrozen) {
          shockCircle=createShape();
          firstFrozen=true;
        }
        beginShape();
        noFill();
        strokeWeight(4);
        stroke(projectileColor, opacity);

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
      } else {
        if (firstFrozen) {
          shockCircle.beginShape();
          shockCircle.noFill();
          shockCircle.strokeWeight(4);
          shockCircle.stroke(projectileColor, opacity);

          for (int i=0; i<360; i+= (360/segment)) {
            shockCircle.vertex(x+cos(radians(i))*blastRadius*(1.3-random(electryfiy)), y+sin(radians(i))*blastRadius*(1.3-random(electryfiy)));
          }
          shockCircle.endShape(CLOSE);
          shockCircle.stroke(255);
          shockCircle.beginShape();
          for (int i=0; i<360; i+= (360/segment)) {
            shockCircle.vertex(x+cos(radians(i))*blastRadius*(1.2-random(electryfiy)), y+sin(radians(i))*blastRadius*(1.2-random(electryfiy)));
          }
          shockCircle.endShape(CLOSE);
          firstFrozen=false;
        } 
        shape(shockCircle, shockCircle.X + shockCircle.width/2, shockCircle.Y+shockCircle.height/2);
      }
    }
  }

  @Override
    void fizzle() {    // when fizzle
    if ( !dead ) {         
      for (int i=0; i<8; i++) {
        particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
      }
      for (int i=0; i<360; i+= (360/5)) {
        particles.add( new Shock(400, int( x), int(y), 0, 0, 2, i, projectileColor)) ;
      }
      particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.5), 20, blastRadius, color(255)));
      particles.add(new Flash(500, 12, color(255)));

      beginShape();
      strokeWeight(16);
      noFill();
      stroke(random(255));
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

class Needle extends Projectile implements Reflectable {//----------------------------------------- Needle objects ----------------------------------------------------
  float v, vx, vy, spray=30;
  //boolean friendlyFire;
  /*Needle(int _playerIndex, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
   super(_playerIndex, _x, _y, _size, _projectileColor, _time);
   friendlyFire=_friendlyFire;
   angle=_angle;
   v=abs(_vx)+ abs(_vy); 
   damage=_damage;
   vx= _vx;
   vy= _vy;
   ally=players.get(_playerIndex).ally;
   }*/
  Needle(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    v=abs(_vx)+ abs(_vy); 
    damage=_damage;
    vx= _vx;
    vy= _vy;
    //ally=players.get(_playerIndex).ally;
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        //  opacity+=8*F;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        //  opacity-=8*F;
        //  particles.add(new Particle(int(x), int(y), 0, 0, 10, 200, projectileColor));
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
    }
  }
  void display() {
    if (!dead) { 
      // strokeCap(ROUND);
      strokeWeight(6);
      // strokeJoin(ROUND);
      stroke(255);
      line(x, y, x+cos(radians(angle))*size, y+sin(radians(angle))*size);
      stroke(projectileColor);
      line(x, y, x+cos(radians(angle))*size*0.8, y+sin(radians(angle))*size*0.8);
      // strokeCap(NORMAL);
    }
  }

  @Override
    void hit(Player enemy) {
    // super.hit();
    enemy.hit(damage);
    deathTime=stampTime;   // dead on collision
    dead=true;
    for (int i=0; i<4; i++) {
      // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
      float sprayAngle=random(-spray, spray)+angle;
      float sprayVelocity=random(v*0.75);
      particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    }
    // particles.add(new LineWave(int(x), int(y), 80, 100, color(255), angle+90));
  }
  @Override
    public void reflect(float _angle, Player _player) {
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;

    // angle=degrees(atan2(vy, vx));
    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy));
    vy= sin(radians(angle))*(abs(vx)+abs(vy));
  }
}

class Slash extends Projectile {//----------------------------------------- Slash objects ----------------------------------------------------
  int traceAmount=8;
  float vx, vy, angleV=24, range, lowRange, traceLowRange[]=new float[traceAmount];
  float pCX, pCY, traceAngle[]=new float[traceAmount];
  boolean follow;
  /* Slash(int _playerIndex, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _angleV, float _range, float _vx, float _vy, int _damage) {
   super(_playerIndex, _x, _y, _size, _projectileColor, _time);
   angle=_angle;
   angleV=_angleV;
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
   }*/

  Slash(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _angleV, float _range, float _vx, float _vy, int _damage, boolean _follow) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    follow=_follow;
    angle=_angle;
    angleV=_angleV;
    damage=_damage;
    force=-10;
    vx= _vx;
    vy= _vy;
    range= _range;
    pCX=_owner.x+_owner.w*0.5;
    pCY= _owner.y+_owner.w*0.5;
    for (int i=0; i<7; i++) {
      particles.add(new Particle(int(x), int(y), vx/(2-0.12*i), vy/(2-0.12*i), 10+i*4, _time, _projectileColor));
    }
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {

        //pCX=players.get(playerIndex).x+players.get(playerIndex).w*0.5;
        // pCY= players.get(playerIndex).y+players.get(playerIndex).w*0.5;
        if (follow) {
          pCX=owner.x+owner.w*0.5;
          pCY= owner.y+owner.w*0.5;
        }
        x=pCX-cos(radians(angle))*range;
        y=pCY-sin(radians(angle))*range;
        traceAngle[0]=angle;
        for (int i=1; traceAmount>i; i++) {
          traceAngle[i]=traceAngle[i-1];
        }
        angle-=angleV*timeBend;
        traceLowRange[0]=lowRange;
        for (int i=1; traceAmount>i; i++) {
          traceLowRange[i]=traceLowRange[i-1];
        }
        lowRange=sin(radians((180*(deathTime-stampTime)/time)))*range*0.5;
      } else {

        //pCX=players.get(playerIndex).x+players.get(playerIndex).w*0.5;
        //pCY= players.get(playerIndex).y+players.get(playerIndex).w*0.5;
        if (follow) {
          pCX=owner.x+owner.w*0.5;
          pCY= owner.y+owner.w*0.5;
        }
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
        angle+=angleV*timeBend;
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
    for (int i=0; i<6; i++) {
      particles.add(new Particle(int(x), int(y), random(20)-10, random(20)-10, int(random(20)+5), 800, 255));
    }
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
    }
    // enemy.pushForce(-10, angle);
    // particles.add(new Flash(200, 32, 255));  
    particles.add(new LineWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 10, 300, projectileColor, angle+90));
    particles.add(new LineWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 10, 300, color(255), angle+90));
  }
}


class Boomerang extends Projectile implements Reflectable {//----------------------------------------- Boomerang objects ----------------------------------------------------
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
        displayAngle-=angleSpeed*timeBend;
        vy/=1-0.98*timeBend;
        vx/=1-0.98*timeBend;
        vx += (x-owner.x-owner.w*0.5)*0.002;
        vy += (y-owner.y-owner.w*0.5)*0.002;
        x-=vx*timeBend;
        y-=vy*timeBend;
        pCX=owner.x+owner.w*0.5;
        pCY=owner.y+owner.w*0.5;
      } else {
        pCX=owner.x+owner.w*0.5;
        pCY=owner.y+owner.w*0.5;
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx -= (x-owner.x-owner.w*0.5)*0.002;
        vy -= (y-owner.y-owner.w*0.5)*0.002;
        vx*=0.98;
        vy*=0.98;
        displayAngle+=angleSpeed*timeBend;
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
      particles.add(new RShockWave(int(owner.x+owner.w*0.5), int(owner.y+owner.w*0.5), 350, 32, 300, color(255)));
      // particles.add(new ShockWave(int(players.get(playerIndex).x+players.get(playerIndex).w*0.5), int(players.get(playerIndex).y+players.get(playerIndex).h*0.5), 20, 100, projectileColor));
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
  public void reflect(float _angle, Player _player) {
    //angle=_angle;
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;

    particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    // angle=degrees(atan2(vy, vx));
    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    // particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy))*1.5;
    vy= sin(radians(angle))*(abs(vx)+abs(vy))*1.5;
    //vx=-vx*1.5;
    //vy=-vy*1.5;
  }
}

class HomingMissile extends Projectile implements Reflectable {//----------------------------------------- HomingMissile objects ----------------------------------------------------

  PShape  sh, c ;
  float vx, vy, homeRate, gravityRate=0.008, count;
  int ReactionTime=40;
  final int  leapAccel=10, lockRange=300, seekRadius=4000;
  boolean locked, leap;
  Player target;
  HomingMissile(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;
    size=_size;
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
    /* sh = createShape();
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
     c.endShape(CLOSE);*/

    sh = createShape();
    c = createShape();
    sh.beginShape();
    sh.fill(255);
    sh.stroke(255, 50);
    sh.vertex(int (-size*0.25), int (-size*0.25) );
    sh.vertex(int (+size*1.5), int (0));
    sh.vertex(int (-size*0.25), int (+size*0.25));
    sh.vertex(int (+size*0), int (0));
    sh.endShape(CLOSE);

    c.beginShape();
    c.fill(projectileColor);
    c.stroke(projectileColor, 50);
    c.vertex(int (0), int (-size*0.15) );
    c.vertex(int (+size*0.75), int (0));
    c.vertex(int (0), int (+size*0.15));
    c.vertex(int (+size*0.25), int (0));
    c.endShape(CLOSE);

    target=seek(seekRadius); // seek to closest enemy player
    calcAngle();
    //ellipse(target.x+target.w*0.5, target.y+target.w*0.5, 200, 200);
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {

        if (target.dead ||target==owner)target=seek(seekRadius); // reseek if target is dead

        if ((locked && !leap)|| (target!=owner && !target.dead  && ReactionTime>count && dist(x, y, target.x, target.y)<lockRange)) {
          vx=cos(radians(angle))*-0.5*timeBend;
          vy=sin(radians(angle))*-0.5*timeBend;
          // vx=0;
          // vy=0;
          count+=1*timeBend;
          if (!locked)locking();
          if (ReactionTime<=count)leaping();
        } else if (leap) {
          vx+=cos(radians(angle))*leapAccel*timeBend;
          vy+=sin(radians(angle))*leapAccel*timeBend;
          particles.add(new Particle(int(x), int(y), cos(radians(angle+180))*(abs(vx)+abs(vy))*0.05, sin(radians(angle+180))*(abs(vx)+abs(vy))*0.05, 15, 300, color(255)));
        } else if (!locked) {
          calcAngle();
          vx+=cos(radians(angle))*homeRate*timeBend;
          vy+=sin(radians(angle))*homeRate*timeBend;
          x+=((target.x+target.w*0.5)-x)*gravityRate*timeBend;
          y+=((target.y+target.w*0.5)-y)*gravityRate*timeBend;
        }
        x+=vx*timeBend;
        y+=vy*timeBend;

        homeRate+=0.015*timeBend;
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
        ellipse(0, 0, size, size*0.5);
      }
      popMatrix();
      if (target!=owner && !leap ) targetVarning();
    }
  }
  void targetVarning() {
    float tcx=target.x+target.w*0.5, tcy=target.y+target.w*0.5;
    stroke(projectileColor);
    strokeWeight(4);
    if (locked) {
      strokeWeight(1);
      line(x+cos(radians(angle))*2000, y+sin(radians(angle))*2000, x, y);
    } else {
      noFill();
      ellipse(tcx, tcy, target.w*2, target.w*2);
      line(tcx, tcy, tcx-150, tcy);
      line(tcx, tcy, tcx+150, tcy);
      line(tcx, tcy, tcx, tcy-150);
      line(tcx, tcy, tcx, tcy+150);
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
    enemy.hit(int(leap?damage:(locked?damage*0.25:damage*0.5)));
    deathTime=stampTime;   // dead on collision
    dead=true;
    enemy.pushForce(vx*0.05, vy*0.05, angle);
    for (int i=0; i<7; i++) {
      particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
    }
    particles.add(new Flash(50, 64, 255));  
    particles.add(new LineWave(int(x), int(y), 10, 300, color(255), angle));
  }

  void calcAngle() {
    angle = degrees(atan2(((target.y+target.w*0.5)-y), ((target.x+target.w*0.5)-x)));
  }



  @Override
    public void reflect(float _angle, Player _player) {
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;

    // sh = createShape();
    c = createShape();
    /* sh.beginShape();
     sh.fill(255);
     sh.stroke(255, 50);
     sh.vertex(int (-size*0.75), int (-size*0.75) );
     sh.vertex(int (+size*4), int (0));
     sh.vertex(int (-size*0.75), int (+size*0.75));
     sh.vertex(int (+size*0), int (0));
     sh.endShape(CLOSE);*/

    c.beginShape();
    c.fill(projectileColor);
    c.stroke(projectileColor, 50);
    c.vertex(int (0), int (-size*0.15) );
    c.vertex(int (+size*0.75), int (0));
    c.vertex(int (0), int (+size*0.15));
    c.vertex(int (+size*0.25), int (0));
    c.endShape(CLOSE);

    // angle=degrees(atan2(vy, vx));
    float diff=_angle;

    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    // particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy))*0.3;
    vy= sin(radians(angle))*(abs(vx)+abs(vy))*0.3;
  }
}

class Shield extends Projectile implements Reflector { //----------------------------------------- Shield objects ----------------------------------------------------
  int brightness=255, offsetX, offsetY;
  boolean follow;
  Shield( Player _owner, int _x, int _y, color _projectileColor, int  _time, float _angle, float _damage) {
    super(_owner, _x, _y, 1, _projectileColor, _time);
    damage= int(_damage);
    size=60;
    angle=_angle;
    follow=false;
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5, random(10)-5, int(random(20)+5), 800, 255));
    }
  }
  Shield( Player _owner, int _x, int _y, color _projectileColor, int  _time, float _angle, float _damage, int _offsetX, int _offsetY) {
    super(_owner, _x, _y, 1, _projectileColor, _time);
    damage= int(_damage);
    size=60;
    angle=_angle;
    offsetX=_offsetX;
    offsetY=_offsetY;
    follow=true;
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5, random(10)-5, int(random(20)+5), 800, 255));
    }
  }
  void display() {
    if (!dead ) { 
      fill(0);
      //text(angle, x-100, y-100);
      strokeWeight(int(10));
      stroke(color(hue(projectileColor), 255-brightness, brightness(projectileColor)));
      line(cos(radians(angle-90+90))*size*0.9+int(x), sin(radians(angle-90+90))*size*0.9+int(y), cos(radians(angle+90+90))*size*0.9+int(x), sin(radians(angle+90+90))*size*0.9+int(y));
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
        if (follow) {
          x=owner.x+owner.w*.5+offsetX;
          y=owner.y+owner.h*.5+offsetY;
        }
      } else {
        if (follow) {
          x=owner.x+owner.w*.5+offsetX;
          y=owner.y+owner.h*.5+offsetY;
        }
        if (brightness>0)brightness-=10;
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

  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<2; i++) {
        particles.add(new Particle(int(x-cos(radians(angle))*15), int(y-sin(radians(angle))*15), 0, 0, int(random(25)), 500, color(projectileColor)));
        particles.add(new Particle(int(x+cos(radians(angle))*15), int(y+sin(radians(angle))*15), 0, 0, int(random(25)), 500, color(projectileColor)));
        particles.add(new Particle(int(x-cos(radians(angle))*30), int(y-sin(radians(angle))*30), 0, 0, int(random(25)), 500, color(projectileColor)));
        particles.add(new Particle(int(x+cos(radians(angle))*30), int(y+sin(radians(angle))*30), 0, 0, int(random(25)), 500, color(projectileColor)));
        particles.add(new Particle(int(x-cos(radians(angle))*50), int(y-sin(radians(angle))*50), 0, 0, int(random(25)), 500, color(projectileColor)));
        particles.add(new Particle(int(x+cos(radians(angle))*50), int(y+sin(radians(angle))*50), 0, 0, int(random(25)), 500, color(projectileColor)));
        particles.add(new Particle(int(x), int(y), 0, 0, 10, 1000, color(projectileColor)));

        //  particles.add(new Particle(int(x), int(y), random(10)-5, random(10)-5, int(random(20)+5), 1000, projectileColor));
      }
    }
  }

  void ProjectilelineVsProjectileCircleCollision(float x, float y, float x2, float y2, Projectile projectile) {
    float cx= projectile.x+projectile.size*0.5, cy=projectile.y+projectile.size*0.5, cr= projectile.size*0.5;
    // float segV = dist(x2, y2, x, y);
    //  float segVAngle = degrees(atan2((y2-y), (x2-x)));
    //  float segC = dist(cx, cy, x, y);
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
    int offset=20;
    float pushPower=0.5;
    //  particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    //enemy.hit(2);


    // angle=degrees(atan2(vy, vx));
    float diff=angle;

    enemy.angle-=diff;
    // angle=angle%360;

    enemy.angle=-enemy.angle;
    enemy.angle+=diff;

    // particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    enemy.vx= cos(radians(enemy.angle))*(abs(enemy.vx)+abs(enemy.vy))*pushPower;
    enemy.vy= sin(radians(enemy.angle))*(abs(enemy.vx)+abs(enemy.vy))*pushPower;

    enemy.x+= cos(radians(enemy.angle))*offset;
    enemy.y+= sin(radians(enemy.angle))*offset;

    /*

     text(degrees(atan2(  -enemy.vy,-enemy.vx )), x, y);
     //   if (atan2( enemy.vy, enemy.vx)>0) {
     if(degrees(atan2(  -enemy.vy,-enemy.vx )) <=0){
     // enemy.vx=0;
     // enemy.vy=0;
     enemy.x+=cos(radians(angle-90))*offset;
     enemy.y+=sin(radians(angle-90))*offset;
     // enemy.vx+=cos(radians(angle-90))*offset;
     //enemy.vy+=sin(radians(angle-90))*offset;
     // enemy.pushForce(cos(radians(angle-90))*10,sin(radians(angle-90))*10, angle-90);
     enemy.pushForce(pushPower, angle-90);
     particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle-90))*random(10), sin(radians(angle-90))*random(10), 6, angle-90, projectileColor));
     } else {
     enemy.vx=0;
     enemy.vy=0;
     enemy.x-=cos(radians(angle+90))*offset;
     enemy.y-=sin(radians(angle+90))*offset;
     // enemy.pushForce(cos(radians(angle+90))*10, sin(radians(angle+90))*10, angle+90);
     // enemy.vx+=cos(radians(angle+90))*offset;
     // enemy.vy+=sin(radians(angle+90))*offset;
     enemy.pushForce(-pushPower, angle+90);
     particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle+90))*random(10), sin(radians(angle+90))*random(10), 6, angle+90, projectileColor));
     }*/
    enemy.ax=0;
    enemy.ay=0;
    //  particles.add( new  Particle(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), cos(radians(angle))*12, sin(radians(angle))*12, 120, 100, color(255, 0, 255)));
  }

  public void reflecting() {
    brightness=500;
    particles.add(new ShockWave(int(x), int(y), size, 16, 100, color(255)));
  }
}


class Electron extends Projectile implements Reflectable {//----------------------------------------- Electron objects ----------------------------------------------------
  boolean orbit=true;
  int recoverEnergy=5;
  float orbitAngle, vx, vy, distance=25, maxDistance=200, orbitAngleSpeed=6;
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
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        if (orbit) {
          if (distance>maxDistance) {
            distance=maxDistance;
          } else {
            distance*=1+(0.02*timeBend);
          }
          if (owner.dead)orbit=false;
          x=owner.x+owner.w*0.5+cos(radians(orbitAngle))*distance;
          y=owner.y+owner.w*0.5+sin(radians(orbitAngle))*distance;
          orbitAngle+=orbitAngleSpeed*timeBend;
          angle+=12*timeBend;
        } else {
          angle+=6*timeBend;
          x+=vx*timeBend;
          y+=vy*timeBend;
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
      if (distance<maxDistance) 
        ellipse(x, y, size*.5, size*.5);
      else
        ellipse(x, y, size, size);
    }
  }
  void derail() {
    orbit=false;
    vx=cos(radians(orbitAngle+90))*0.03*orbitAngleSpeed*distance;
    vy=sin(radians(orbitAngle+90))*0.03*orbitAngleSpeed*distance;
    vx+= owner.ax*5;
    vy+= owner.ay*5;
    angle=orbitAngle;
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
      enemy.pushForce(8*orbitAngleSpeed, orbitAngle+90);
      deathTime=stampTime;   // dead on collision
      dead=true;
      for (int i=0; i<16; i++) {
        particles.add(new Particle(int(x), int(y), random(20)-10, random(20)-10, int(random(20)+5), 800, 255));
      }
      for (int i=0; i<8; i++) {
        particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
      }
    } else { 
      enemy.hit(damage*2);
      enemy.pushForce(12*orbitAngleSpeed, angle);
      deathTime+=3000;
      owner.ability.energy+=recoverEnergy;
      orbit=true;
      particles.add(new ShockWave(int(x), int(y), 300, 16, 150, color(255)));

      for (int i=0; i<8; i++) {
        particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
      }
      stroke(projectileColor);
      strokeWeight(size);
      line(x, y, owner.x+owner.w*0.5+cos(radians(orbitAngle))*distance, owner.y+owner.w*0.5+sin(radians(orbitAngle))*distance);
      x=owner.x+owner.w*.5;
      y=owner.y+owner.h*.5;
    }

    // particles.add(new Flash(200, 32, 255));  
    // particles.add(new LineWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 10, 300, projectileColor, angle));
  }

  @Override
    public void reflect(float _angle, Player _player) {

    try {
      DeployElectron tempA=(DeployElectron)owner.ability;
      for (  int i=tempA.stored.size()-1; i>=0; i--) {
        if (tempA.stored.get(i)==this)tempA.stored.remove(i);
      }
    }
    catch(Exception e) {
    }

    vx=cos(radians(orbitAngle+90))*0.02*orbitAngleSpeed*distance;
    vy=sin(radians(orbitAngle+90))*0.02*orbitAngleSpeed*distance;

    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;
    orbit=false;
    // angle=degrees(atan2(vy, vx));
    float diff=_angle;

    orbitAngle-=diff;
    // angle=angle%360;

    orbitAngle=-angle;
    orbitAngle+=diff;

    // particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(orbitAngle))*(abs(vx)+abs(vy))*0.5;
    vy= sin(radians(orbitAngle))*(abs(vx)+abs(vy))*0.5;
  }
}

class Graviton extends Projectile {//----------------------------------------- Graviton objects ----------------------------------------------------

  float vx, vy, friction=0.95;
  int dragForce=-1, dragRadius=250, count, arms=3;
  final int bend=60;
  Graviton(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, int _arms) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;
    arms=_arms;
    dragRadius=_size;
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
    particles.add(new ShockWave(int(x), int(y), int(dragRadius*0.5), 16, 200, color(_projectileColor)));
    particles.add(new ShockWave(int(x), int(y), int(dragRadius*0.4), 16, 150, color(255)));
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
        angle-=8*timeBend;
      } else {
        angle+=8*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
        dragPlayersInRadius(dragRadius, false);
        count++;
        if ((count%int(35/(timeBend)))==0)particles.add(new RShockWave(int(x), int(y), int(dragRadius*2), 16*damage, dragRadius*2, color(projectileColor)));
      }
    }
  }
  void display() {
    if (!dead) { 

      strokeWeight(sin(radians(count*4*timeBend))*10);
      stroke(255);
      fill(projectileColor);
      ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      // line(x,y,x+cos(radians(angle))*dragRadius,y+sin(radians(angle))*dragRadius);
      noFill();
      for (int i=0; i<360; i+=360/arms) {
        bezier(x, y, x, y, x+cos(radians(angle+bend+i))*dragRadius*.5, y+sin(radians(angle+bend+i))*dragRadius*.5, x+cos(radians(angle+i))*dragRadius, y+sin(radians(angle+i))*dragRadius);
      }
      //bezier(x,y,x,y,x+cos(radians(angle+bend+120))*dragRadius*.5,y+sin(radians(angle+bend+120))*dragRadius*.5,x+cos(radians(angle-bend*2+120))*dragRadius,y+sin(radians(angle-bend+120))*dragRadius);
      //bezier(x,y,x,y,x+cos(radians(angle+bend+240))*dragRadius*.5,y+sin(radians(angle+bend+240))*dragRadius*.5,x+cos(radians(angle-bend*2+240))*dragRadius,y+sin(radians(angle-bend+240))*dragRadius);

      //noFill();
      // stroke(projectileColor);
      // ellipse(x, y, size, size);
      //ellipse(x, y, dragRadius*2, dragRadius*2);
      if ((deathTime-stampTime)<=100) {
        size=400;
      } else {
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
            players.get(i).pushForce(dragForce*timeBend, calcAngleFromBlastZone(x, y, players.get(i).x+players.get(i).w*0.5, players.get(i).y+players.get(i).h*0.5));
            if (count%10==0)players.get(i).hit(damage);
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