

class Projectile  implements Cloneable {
  //PVector coord;
  //PVector speed;
  int  size, ally=-1, blastRadius;
  float x, y, vx, vy, angle, force, damage;
  long deathTime, spawnTime;
  color projectileColor;
  boolean dead, deathAnimation, melee, meta;
  int  playerIndex=-1, time;
  ArrayList<Buff> buffList= new ArrayList<Buff>();
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
    if ( hitBox) { 
      strokeWeight(1);
      noFill();
      ellipse(x, y, size, size);
    }
  }
  void displayHitBox(float range) {
    if ( hitBox) { 
      strokeWeight(1);
      noFill();
      ellipse(x, y, range, range);
    }
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
    for (Buff b : buffList) {
      b.onFizzle();
    }
  }
  void hit(Player enemy) {// collide death
    // ArrayList<Buff> bcList= new ArrayList<Buff>();
    /* bcList=(ArrayList<Buff>)buffList.clone();
     for (Buff b : bcList) {
     b=b.clone();
     b.transfer(owner, enemy);//b.enemy=enemy;
     }*/

    //print(enemy.index);
    //enemy.buffList.add(buffList.get(0).clone());
    //enemy.buffList.addAll(bcList);

    if (buffList.size()>0) { 
      //println("test");
      for (Buff b : buffList) {
        Buff clone = b;

        clone.transfer(owner, enemy);
        if (b.type==BuffType.ONCE &&   existInList(enemy.buffList, b.getClass())) {
        } else  enemy.buffList.add(clone.clone());
      }
      /*  Buff clone = buffList.get(0);
       clone.transfer(owner, enemy);
       if(buffList.get(0).type==BuffType.ONCE &&   existInList(enemy.buffList, buffList.get(0).getClass())){}
       else  enemy.buffList.add(clone.clone());
       */
    }
  }
  void pushForce(float amount, float angle) {
    //  stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
    vx+=cos(radians(angle))*amount;
    vy+=sin(radians(angle))*amount;
    // stamps.add( new ControlStamp(index, int(x), int(y), vx, vy, ax, ay));
  }
  public Projectile clone() {  
    try {
      return (Projectile)super.clone();
    }
    catch( CloneNotSupportedException e) {
      println(e+" 1");
      return null;
    }
  }

  /*Player seek(int senseRange) {
   for (int sense = 0; sense < senseRange; sense++) {
   for ( Player p : players) {
   if (p!= owner && !p.dead && p.ally!=owner.ally) {
   if (dist(p.x, p.y, x, y)<sense*0.5) {  
   return p;
   }
   }
   }
   }
   return owner;
   }*/

  void resetDuration() {
    spawnTime=stampTime;
    deathTime=stampTime+time;
  }

  Projectile addBuff( Buff ...bA ) {
    //buffList=new ArrayList<Buff>();
    for (Buff b : bA) { 
      buffList.add( b); 
      b.parent=this;
    }
    return this;
  }
  void changeColor(int newColor) {
    this.projectileColor=newColor;
  }
}

class Ball extends Projectile implements Reflectable { //----------------------------------------- ball objects ----------------------------------------------------
  int speedX, speedY, dirX, dirY;
  int [] allies;
  int up, down, left, right;
  //float vx, vy;
  Ball( int _x, int _y, int _speedX, int _speedY, int _size, color _color) {
    super( _x, _y, _size, _color, 999999);
    projectileColor=_color;
    damage=1;
    //coord= new PVector(_x, _y);
    //speed= new PVector(_speedX, _speedY);
    vx=_speedX;
    vy=_speedY;
    //angle=degrees( PVector.angleBetween(coord, speed));
  }
  /*void playerBounds() {
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
   }*/
  void checkBounds() {

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
      super.display();
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
      if (debug) line(x, y, x +(vx)*10, y+(vy)*10);
    }
  }

  void move() {
    //   s =(slow)?slowFactor:1;
    //      f =(fastForward)?speedFactor:1;
    if (stampTime%1==0) {
      if (!dead && !freeze) { 
        if (reverse) {
          //angle=degrees( PVector.angleBetween(speed, coord));
          //coord.set(coord.x-speed.x*timeBend, coord.y-speed.y*timeBend);
          x-=vx*timeBend;
          y-=vy*timeBend;
        } else {
          //coord.set(coord.x+speed.x*timeBend, coord.y+speed.y*timeBend);
          //angle=degrees( PVector.angleBetween(coord, speed));
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
    super.hit(enemy);
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
    if (owner!=null) { 
      owner.ally=_player.ally;
      owner=_player;
    }
    projectileColor=_player.playerColor;
    //particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*15;
    vy= sin(radians(angle))*15;
    x+= cos(radians(angle))*10;
    y+=sin(radians(angle))*10;
  }
}

class IceDagger extends Projectile implements Reflectable, Destroyable, Containable {//----------------------------------------- IceDagger objects ----------------------------------------------------
  PShape  sh, c ;
  Projectile parent;
  float smoke;
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
    c.vertex(int (0), int (-size*.33) );
    c.vertex(int (+size), int (0));
    c.vertex(int (0), int (+size*.33));
    c.vertex(int (-size*0.5), int (0));
    c.endShape(CLOSE);
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        if (smoke>1) {
          smoke=0;
          particles.add(new Particle(int(x), int(y), vx*0.2, vy*0.2, int(random(10)+5), 900, projectileColor));
        }
        smoke+=1*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
    }
  }
  void display() {
    if (!dead) { 
      super.display();  
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      // rect(-(size*.5), -(size*.5), (size), (size));
      shape(sh, sh.width*.5, sh.height*.5);
      shape(c, c.width*.5, c.height*.5);
      popMatrix();
    }
  }
  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {      
      super.fizzle();
      for (int i=0; i<4; i++) {
        particles.add(new Particle(int(x), int(y), random(10)-5+vx, random(10)-5+vy, int(random(20)+5), 800, 255));
      }
    }
  }
  @Override
    void hit(Player enemy) {
    super.hit(enemy);
    enemy.hit(damage);
    enemy.ax*=.3;
    enemy.ay*=.3;
    enemy.vx*=.3;
    enemy.vy*=.3;
    deathTime=stampTime;   // dead on collision
    dead=true;
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x), int(y), random(20)-10, random(20)-10, int(random(20)+5), 800, 255));
    }
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
    }
    //particles.add(new Flash(200, 32, 255));  
    particles.add(new LineWave(int(enemy.cx), int(enemy.cy), 10, 300, projectileColor, angle));
  }
  void changeColor(int newColor) {
    super.changeColor(newColor); 
    c = createShape();

    c.beginShape();
    c.fill(projectileColor);
    c.stroke(projectileColor, 50);
    c.vertex(int (0), int (-size*.33) );
    c.vertex(int (+size), int (0));
    c.vertex(int (0), int (+size*.33));
    c.vertex(int (-size*0.5), int (0));
    c.endShape(CLOSE);
  }
  public void reflect(float _angle, Player _player) {
    angle=_angle;
    playerIndex=_player.index;
    owner=_player;
    changeColor(owner.playerColor);
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
  void destroy(Projectile destroyerP) {
    dead=true;
    deathTime=stampTime;   // projectile is dead on collision
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x), int(y), random(20)-10, random(20)-10, int(random(20)+5), 800, 255));
    }
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
    }
    //particles.add(new Flash(200, 32, 255));  
    particles.add(new LineWave(int(x), int(y), 10, 300, projectileColor, angle+90));
  }
  Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  void unWrap() {
    resetDuration();
    x=parent.x;
    y=parent.y;
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
        if (smoke>1) {
          smoke=0;
          particles.add(new Particle(int(x), int(y), vx*0.2, vy*0.2, int(random(10)+5), 900, projectileColor));
        }
        smoke+=1*timeBend;
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
      super.display();
      // rect(x-(size*.5), y-(size*.5), (size), (size));
      // fill(0);
      //  text("s: "+ angleCurve, x, y-100);
      //  text("e: "+ startCurveAngle, x, y-75);
      //  text("c: "+ currentAngle, x, y-50);
      pushMatrix();
      translate(x, y);

      rotate(radians(angle));

      // rect(-(size*.5), -(size*.5), (size), (size));
      shape(sh, sh.width*.5, sh.height*0.5);
      shape(c, c.width*.5, c.height*0.5);
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


class ForceBall extends Projectile implements Reflectable { //----------------------------------------- forceBall objects ----------------------------------------------------
  //scaled object by velocity
  float vx, vy, v, ax, ay, angleV, shakeness;
  //boolean charging;
  ForceBall(Player _owner, int _x, int _y, float _v, int _size, color _projectileColor, int  _time, float _angle, float _damage) {
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
    shakeness=int(force*0.5);
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
      super.display();
      // rect(x-(size*.5), y-(size*.5), (size), (size));
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      // rect(-(size*.5), -(size*.5), (size), (size));
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
      super.fizzle();
      for (int i=0; i<4*force; i++) {
        particles.add(new Particle(int(x), int(y), random(10)-5+vx, random(10)-5+vy, int(random(20)+5), 800, 255));
      }
    }
  }
  @Override
    void hit(Player enemy) {
    super.hit(enemy);
    if (damage>100 && damage<=250) { 
      particles.add(new TempSlow(700, 0.1, 1.05));
      particles.add( new TempZoom(enemy, 200, 1.2, DEFAULT_ZOOMRATE, true) );
    }
    if (damage>250) {
      particles.add( new TempFreeze(500));
      particles.add( new TempZoom(enemy, 500, 2, 1, true) );
    }
    for (int i=0; i<2*v; i++) {
      particles.add(new Particle(int(x), int(y), random(-v, v)+vx, random(-v, v)+vy, int(random(30)+10), 800, 255));
    }
    enemy.hit(damage);
    deathTime=stampTime;   // projectile is dead on collision
    dead=true;

    for (int i=0; i<int (v*0.1); i++) { // particles
      particles.add(new Particle(int(x), int(y), random(-int(v*0.2), int(v*0.2)), random(-int(v*0.2), int(v*0.2)), int(random(5, 30)), 800, 255));
    }

    for (int i=0; i<int (v*0.2); i++) { // particles
      particles.add(new Particle(int(x), int(y), random(-int(v*0.4), int(v*0.4)), random(-int(v*0.4), int(v*0.4)), int(random(10, 50)), 800, projectileColor));
    }


    particles.add(new Flash(int(v*4), 32, 255));  
    particles.add(new ShockWave(int(enemy.cx), int(enemy.cy), 20, 16, 200, projectileColor));
    particles.add(new ShockWave(int(x), int(y), int(v*4), 16, int(v*4), projectileColor));
    particles.add(new ShockWave(int(x), int(y), int( v*2), 16, int(v*5), color(255, 0, 255)));
    shakeTimer+=shakeness;
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
class RevolverBullet extends Projectile implements Reflectable, Destroyable { //----------------------------------------- RevolverBullet objects ----------------------------------------------------
  //scaled object by velocity
  float  v, ax, ay, angleV, spray=30, halfSize;
  RevolverBullet(Player _owner, int _x, int _y, float _v, int _size, color _projectileColor, int  _time, float _angle, float _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    angleV=10;
    damage=int(_damage);
    v=_v;
    force=5;
    halfSize=size*.5;
    vx= cos(radians(angle))*_v;
    vy= sin(radians(angle))*_v;
    /* for (int i=0; i<4; i++) {
     particles.add(new Particle(int(x), int(y), vx/(2-0.12*i), vy/(2-0.12*i), 10+i*4, _time, _projectileColor));
     }
     for (int i=0; i<2; i++) {
     particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
     }*/
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
    }
  }
  void display() {
    if (!dead) { 
      // rect(x-(size*.5), y-(size*.5), (size), (size));
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      // rect(-(size*.5), -(size*.5), (size), (size));
      fill(255);
      strokeWeight(5);
      stroke(projectileColor);
      ellipse(0, 0, size*v*0.2, halfSize);
      popMatrix();
    }
  }
  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      super.fizzle();
      for (int i=0; i<4; i++) {
        particles.add(new Particle(int(x), int(y), random(10)-5+vx, random(10)-5+vy, int(random(20)+5), 800, 255));
      }
    }
  }
  @Override
    void hit(Player enemy) {
    super.hit( enemy);

    enemy.hit(damage);
    deathTime=stampTime;   // projectile is dead on collision
    dead=true;
    for (int i=0; i<12; i++) {
      float sprayAngle=random(-spray, spray)+angle;
      float sprayVelocity=random(v*0.75);
      particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    }

    //particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle))*random(10), sin(radians(angle))*random(10), 6, angle, projectileColor));
    enemy.pushForce(damage*.5, angle);
    particles.add(new ShockWave(int(x), int(y), int(v*4), 22, 100, projectileColor));
    shakeTimer+=int(force*0.2);
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
  void destroy(Projectile destroyerP) {

    deathTime=stampTime;   // projectile is dead on collision
    dead=true;
    for (int i=0; i<12; i++) {
      float sprayAngle=random(-spray, spray)+angle+180;
      float sprayVelocity=random(v*0.2);
      particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, destroyerP.owner.playerColor));
    }
    if (destroyerP.melee) destroyerP.owner.pushForce(damage*.5, angle);
    particles.add(new ShockWave(int(x), int(y), int(v*4), 22, 100, destroyerP.owner.playerColor));
    shakeTimer+=int(force*0.1);
  }
}
class Blast extends Projectile implements Containable { //----------------------------------------- Blast objects ----------------------------------------------------
  //scaled object by velocity
  Projectile parent;
  float  v, ax, ay, angleV, spray=30, opacity, speed;
  Blast(Player _owner, int _x, int _y, float _v, int _size, color _projectileColor, int  _time, float _angle, float _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    angleV=10;
    damage=_damage;
    v=_v;
    force=5;
    opacity=255;
    speed=20;
    vx= cos(radians(angle))*_v;
    vy= sin(radians(angle))*_v;
  }
  Blast(Player _owner, int _x, int _y, float _v, int _size, color _projectileColor, int  _time, float _angle, float _damage, float _angleV, float _speed) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    angleV=_angleV;
    damage=_damage;
    v=_v;
    force=5;
    opacity=255;
    speed=_speed;
    vx= cos(radians(angle))*_v;
    vy= sin(radians(angle))*_v;
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        opacity+=speed*timeBend;
        //if (charging) angle+=angleV*timeBend;
        angleV+=speed*timeBend;
        size-=speed*timeBend*0.75;
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        opacity-=speed*timeBend;

        angleV-=speed*timeBend;
        size+=speed*timeBend*0.75;
        x+=vx*timeBend;
        y+=vy*timeBend;
      }
      if (opacity<=0) {
        dead=true; 
        deathTime=stampTime;
      }
    }
  }
  void display() {
    if (!dead) { 
      super.display();
      pushMatrix();
      translate(x, y);
      rotate(radians(angleV));
      // rect(-(size*.5), -(size*.5), (size), (size));
      fill(255, opacity);
      strokeWeight(10);
      stroke(projectileColor, opacity);
      rect(-size*0.5, -size*0.5, size, size);
      popMatrix();
    }
  }
  @Override
    void fizzle() {    // when fizzle
    super.fizzle();
  }
  @Override
    void hit(Player enemy) {
    //if (damage!=0) {
    super.hit(enemy);
    enemy.hit(damage);
    enemy.pushForce(v*0.05, angle);
    float sprayAngle=random(-spray, spray)+angle;
    float sprayVelocity=random(v*0.75);
    particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    //}
  }

  Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  void unWrap() {
    resetDuration();
    //float tempX=parent.x, tempY=parent.y;
    x+=parent.x;
    y+=parent.y;
    //PVector vel=new PVector(vx, vy);
    //PVector pVel=new PVector(parent.vx, parent.vy);
    // vel.rotate(radians(parent.angle));
    // vel.add(pVel);
    // float deltaX = 0 - vx;
    // float deltaY = 0 - vy;

    //angle+= atan2(deltaY, deltaX); // In radians
    //angle=90;
    //vx=vel.x;
    //vy=vel.y;
  }
}
class ChargeLaser extends Projectile implements Containable { //----------------------------------------- ChargeLaser objects ----------------------------------------------------
  long chargeTime;
  final long MaxChargeTime=500;
  int laserLength=2500;
  float maxLaserWidth, laserWidth, laserChange, offsetAngle, angleV, smoke;
  boolean follow;
  Projectile parent;
  /* ChargeLaser( int _playerIndex, int _x, int _y, int _maxLaserWidth, color _projectileColor, int  _time, float _angle, float _damage  ) {
   super(_playerIndex, _x, _y, 1, _projectileColor, _time);
   damage= int(_damage);
   maxLaserWidth=_maxLaserWidth;
   angle=_angle;
   owner=players.get(_playerIndex);
   }*/
  ChargeLaser( Player _owner, int _x, int _y, int _maxLaserWidth, color _projectileColor, int  _time, float _angle, float _angleV, float _damage, boolean _follow ) {
    super(_owner, _x, _y, 1, _projectileColor, _time);
    follow=_follow;
    damage= int(_damage);
    maxLaserWidth=_maxLaserWidth;
    angle=_angle;
    angleV=_angleV;
  }
  ChargeLaser( Player _owner, int _x, int _y, int _maxLaserWidth, color _projectileColor, int  _time, float _angle, float _angleV, float _damage  ) {
    super(_owner, _x, _y, 1, _projectileColor, _time);
    damage= int(_damage);
    maxLaserWidth=_maxLaserWidth;
    angle=_angle;
    angleV=_angleV;
  }


  void display() {
    if (!dead ) { 
      super.display();
      strokeWeight(int(laserWidth));
      stroke(projectileColor);
      line(int(x), int(y), cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y));
      //arc(int(x),int(y),1,1,radians(angle+90),radians(angle+275));
      ellipse(x, y, int(laserWidth*0.05), int(laserWidth*0.05));

      stroke(255);
      strokeWeight(int(laserWidth*0.6));
      ellipse(x, y, int(laserWidth*0.05), int(laserWidth*0.05));

      //arc(int(x),int(y),1,1,radians(angle+90),radians(angle-275));
      line(int(x), int(y), cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y));
    }
  }
  void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        laserChange-=2*timeBend;
        laserWidth= sin(radians(laserChange))*maxLaserWidth;
        angle-= angleV*timeBend;

        if (follow) {
          angle=owner.angle;
          x=owner.cx;
          y=owner.cy;
        }
      } else {
        laserChange+=2*timeBend;
        laserWidth= sin(radians(laserChange))*maxLaserWidth;
        angle+= angleV*timeBend;
        if (follow) {
          owner.pushForce(-0.2, angle);
          angle=owner.angle;
          x=owner.cx;
          y=owner.cy;
        } else {    
          x+=vx*timeBend;
          y+=vy*timeBend;
        }
        if (laserWidth<0) {
          fizzle(); 
          dead=true;
          deathTime=stampTime;
        }

        shakeTimer=int(laserWidth*0.1);
        if (smoke>1) {
          smoke=0;
          particles.add(new  Gradient(  1000, int(x+size*0.5 +cos(radians(angle))*owner.radius), int(y+size*0.5+sin(radians(angle))*owner.radius), 0, 0, laserLength, int(laserWidth), 4, angle, projectileColor));
        }
        smoke+=2*timeBend;
        // for (int i= 0; players.size () > i; i++)
        //  if (playerIndex!=i  && !players.get(i).dead && players.get(i).ally != owner.ally ) lineVsCircleCollision(x, y, cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y), players.get(i));
        for (Player p : players)
          if (!p.dead && p.ally != owner.ally ) lineVsCircleCollision(x, y, cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y), p);
      }
    }
  }
  public void lineVsCircleCollision(float x, float y, float x2, float y2, Player enemy) {
    float cx= enemy.cx, cy=enemy.cy, cr= enemy.w*0.5;
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
    //float mY = (-y+cy)*ca + ( x-cx)*sa;
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
    super.hit(enemy);
    //  particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    enemy.hit(damage);
    enemy.pushForce(0.6, angle);
    particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle))*random(10), sin(radians(angle))*random(10), 6, angle, projectileColor));
    particles.add( new  Particle(int(enemy.cx), int(enemy.cy), cos(radians(angle))*12, sin(radians(angle))*12, 120, 100, color(255, 0, 255)));
  }

  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {    
      super.fizzle();
      for (int i=0; i<10; i++) {
        int temp= int(random(laserLength));
        int tempVel= int(random(12));
        particles.add(new Spark( 1200, int(x+cos(radians(angle))*temp), int(y+sin(radians(angle))*temp), cos(radians(angle))*tempVel, sin(radians(angle))*tempVel, 4, angle, projectileColor));
      }
    }
  }
  Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  void unWrap() {
    resetDuration();
    x+=parent.x;
    y+=parent.y;
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    vel.rotate(parent.angle);
    vel.add(pVel);
    vx=vel.x;
    vy=vel.y;
  }
}

class SniperBullet extends ChargeLaser { //----------------------------------------- SniperBullet objects ----------------------------------------------------

  /*
  SniperBullet( int _playerIndex, int _x, int _y, int _maxLaserWidth, color _projectileColor, int  _time, float _angle, float _damage  ) {
   super( _playerIndex, _x, _y, _maxLaserWidth, _projectileColor, _time, _angle, _damage  );
   particles.add(new Flash(50, 50, BLACK));
   particles.add(new ShockWave(int(x), int(y), int(size*0.25),40, 80, WHITE));
   }*/
  SniperBullet( Player _owner, int _x, int _y, int _maxLaserWidth, color _projectileColor, int  _time, float _angle, float _damage  ) {
    super( _owner, _x, _y, _maxLaserWidth, _projectileColor, _time, _angle, 0, _damage  );
    particles.add(new Flash(50, 50, BLACK));
    particles.add(new ShockWave(int(x), int(y), int(size*0.25), 40, 80, WHITE));
    force=3;

    //particles.add( new TempFreeze(100));
  }


  void display() {
    if (!dead ) { 
      super.display();
      strokeWeight(int(laserWidth+1));
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
      } else {
        laserChange+=2*timeBend;
        laserWidth= sin(radians(laserChange))*maxLaserWidth;

        if (laserWidth<0) {
          fizzle(); 
          dead=true;
          deathTime=stampTime;
        }

        owner.pushForce(-0.2, angle);
        //shakeTimer=int(laserWidth*0.1);
        particles.add(new  Gradient(1000, int(x+size*0.5 +cos(radians(angle))*owner.radius), int(y+size*0.5+sin(radians(angle))*owner.radius), 0, 0, 40, 6, angle, projectileColor));

        for (int i= 0; players.size () > i; i++)
          if (playerIndex!=i  && !players.get(i).dead && players.get(i).ally != owner.ally ) lineVsCircleCollision(x, y, cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y), players.get(i));
      }
    }
  }
  @Override
    void hit(Player enemy) {
    super.hit(enemy);
    enemy.hit(damage);
    if (damage>100) {
      particles.add( new TempFreeze(100));
      particles.add( new TempSlow(25, 0.1, 1.00));
    }
    //  particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));

    enemy.pushForce(3, angle);
    particles.add(new Flash(100, 24, BLACK));
    particles.add(new LineWave(int(enemy.cx), int(enemy.cy), 10, 200, projectileColor, angle+90));
    particles.add(new Spark( 1000, int(enemy.x+random(enemy.w)), int(enemy.y+random(enemy.w)), cos(radians(angle))*random(10), sin(radians(angle))*random(10), 6, angle, owner.playerColor));

    shakeTimer+=damage*0.3;    
    particles.add( new  Particle(int(enemy.cx), int(enemy.cy), cos(radians(angle))*36, sin(radians(angle))*36, 100, 120, color(255, 0, 255)));
    particles.add( new  Particle(int(enemy.cx), int(enemy.cy), cos(radians(angle))*24, sin(radians(angle))*24, 200, 120, color(255, 0, 255)));
    particles.add( new  Particle(int(enemy.cx), int(enemy.cy), cos(radians(angle))*12, sin(radians(angle))*12, 300, 120, color(255, 0, 255)));
  }
}
class Heal extends Projectile implements Containable {//----------------------------------------- Heal objects ----------------------------------------------------

  float  friction=0.95;
  long timer;
  int blastForce=40, healRadius=200, flick, interval=300;
  boolean friendlyFire;
  Projectile parent;
  Heal(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _heal, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_heal;
    healRadius=_size;
    vx= _vx;
    vy= _vy;
    friendlyFire=_friendlyFire;
  }

  void update() {
    if (!dead && !freeze) { 
      flick=int(random(255));
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
        angle-=0.5*timeBend;
      } else {
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
        angle+=0.5*timeBend;
        if (timer+interval<stampTime) {
          timer=stampTime;
          hitPlayersInRadius(int(healRadius*.5), friendlyFire);
        }
      }
    }
  }

  void display() {
    if (!dead) { 
      super.display();
      strokeWeight(int(sin(radians(angle*30))*10+10));
      // stroke((friendlyFire)? BLACK:color(owner.playerColor));
      // fill((friendlyFire)? BLACK:color(owner.playerColor));
      //ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      //noFill();
      // stroke(flick);
      stroke(owner.playerColor);
      fill(owner.playerColor, sin(radians(angle*4))*100+100);
      ellipse(x, y, size, size);
      /*if ((deathTime-stampTime)<=100)size=400;
       else size=50;*/
    }
  }



  void hitPlayersInRadius(int range, boolean _friendlyFire) {
    if (!freeze &&!reverse) { 
      for (Player p : players) { 
        if ( !p.dead && (p.ally !=owner.ally || _friendlyFire)) { //players.get(i).index!= playerIndex && 
          if (dist(x, y, p.cx, p.cy)<range) {
            p.heal(damage);
            for (int i=0; i<3; i++)particles.add( new  Particle(int(p.cx+cos(radians(random(360)))*random(100)), int(p.cy+sin(radians(random(360)))*random(100)), 0, 0, int(random(50)), 1000, WHITE));

            particles.add(new ShockWave(int(p.cx), int(p.cy), int(healRadius*0.5), 40, 40, p.playerColor));
          }
        }
      }
    }
  }


  Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  void unWrap() {
    resetDuration();
    x+=parent.x;
    y+=parent.y;
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    vel.rotate(parent.angle);
    vel.add(pVel);
    vx=vel.x;
    vy=vel.y;
  }
}
class HealBall extends Projectile implements Containable {//----------------------------------------- HealBall objects ----------------------------------------------------

  float  friction=0.95;
  long timer;
  int flick, interval=400;
  boolean friendlyFire;
  Projectile parent;
  HealBall(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _heal, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_heal;
    vx= _vx;
    vy= _vy;
    friendlyFire=_friendlyFire;
  }

  void update() {
    if (!dead && !freeze) { 
      flick=int(random(255));
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
        angle-=0.4*timeBend;
      } else {
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
        angle+=0.4*timeBend;
        if (timer+interval<stampTime) {
          timer=stampTime;
          particles.add( new  Particle(int(x+cos(radians(random(360)))*random(size)), int(y+sin(radians(random(360)))*random(size)), 0, 0, int(random(50)), 1000, WHITE));
        }
      }
    }
  }

  void display() {
    if (!dead) { 
      super.display();
      strokeWeight(int(sin(radians(angle*30))*10+10));
      // stroke((friendlyFire)? BLACK:color(owner.playerColor));
      // fill((friendlyFire)? BLACK:color(owner.playerColor));
      //ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      //noFill();
      // stroke(flick);
      stroke(projectileColor);
      fill(projectileColor, sin(radians(angle*4))*100+100);
      ellipse(x, y, size, size);
      /*if ((deathTime-stampTime)<=100)size=400;
       else size=50;*/
    }
  }


  @Override
    void hit(Player p) {    // when fizzle
    if ( !dead) {         
      p.heal(damage);
      for (int i=0; i<6; i++) {
        particles.add( new  Particle(int(p.cx+cos(radians(random(360)))*random(p.diameter)), int(p.cy+sin(radians(random(360)))*random(p.diameter)), 0, 0, int(random(50)+20), 1000, WHITE));
      }
      particles.add(new ShockWave(int(x), int(y), int(size*0.4), 32, 150, p.playerColor));
      particles.add(new Flash(200, 12, p.playerColor));
      // shakeTimer+=damage*.2;
      dead=true;
      deathTime=stampTime;
    }
  }

  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {      
      super.fizzle();
      for (int i=0; i<6; i++) {
        particles.add( new  Particle(int(x+cos(radians(random(360)))*random(size*2)), int(y+sin(radians(random(360)))*random(size*2)), 0, 0, int(random(50)+20), 1200, WHITE));
      }
    }
  }

  Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  void unWrap() {
    resetDuration();
    x+=parent.x;
    y+=parent.y;
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    vel.rotate(parent.angle);
    vel.add(pVel);
    vx=vel.x;
    vy=vel.y;
  }
}
class ManaBall extends Projectile implements Containable {//----------------------------------------- HealBall objects ----------------------------------------------------

  float  friction=0.95;
  long timer;
  int flick, interval=400;
  boolean friendlyFire;
  Projectile parent;
  ManaBall(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _heal, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_heal;
    vx= _vx;
    vy= _vy;
    friendlyFire=_friendlyFire;
  }

  void update() {
    if (!dead && !freeze) { 
      flick=int(random(255));
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
        angle-=0.4*timeBend;
      } else {
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
        angle+=0.4*timeBend;
        if (timer+interval<stampTime) {
          timer=stampTime;
          particles.add( new  Particle(int(x+cos(radians(random(360)))*random(size)), int(y+sin(radians(random(360)))*random(size)), 0, 0, int(random(50)), 1000, WHITE));
        }
      }
    }
  }

  void display() {
    if (!dead) { 
      super.display();
      strokeWeight(int(sin(radians(angle*30))*10+10));
      // stroke((friendlyFire)? BLACK:color(owner.playerColor));
      // fill((friendlyFire)? BLACK:color(owner.playerColor));
      //ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      //noFill();
      // stroke(flick);
      stroke(projectileColor);
      fill(projectileColor, sin(radians(angle*4))*100+100);
      rect(x-size*.5, y-size*.5, size, size);
      /*if ((deathTime-stampTime)<=100)size=400;
       else size=50;*/
    }
  }


  @Override
    void hit(Player p) {    // when fizzle
    if ( !dead) {         

      for (Ability a : p.abilityList) {
        a.energy=a.maxEnergy;
        a.ammo=a.maxAmmo;
      }
      for (int i=0; i<6; i++) {
        particles.add( new  Particle(int(p.cx+cos(radians(random(360)))*random(p.diameter)), int(p.cy+sin(radians(random(360)))*random(p.diameter)), 0, 0, int(random(50)+20), 1000, WHITE));
      }
      particles.add(new ShockWave(int(x), int(y), int(size*0.4), 32, 150, p.playerColor));
      particles.add(new Flash(200, 12, p.playerColor));
      // shakeTimer+=damage*.2;
      dead=true;
      deathTime=stampTime;
    }
  }

  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {      
      for (int i=0; i<6; i++) {
        particles.add( new  Particle(int(x+cos(radians(random(360)))*random(size*2)), int(y+sin(radians(random(360)))*random(size*2)), 0, 0, int(random(50)+20), 1200, WHITE));
      }
    }
  }

  Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  void unWrap() {
    resetDuration();
    x+=parent.x;
    y+=parent.y;
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    vel.rotate(parent.angle);
    vel.add(pVel);
    vx=vel.x;
    vy=vel.y;
  }
}
class CoinBall extends Projectile implements Containable {//----------------------------------------- HealBall objects ----------------------------------------------------

  float  friction=0.95;
  long timer;
  int flick, interval=400, amount;
  boolean friendlyFire;
  Projectile parent;
  CoinBall(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _amount, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    amount=_amount;
    vx= _vx;
    vy= _vy;
    friendlyFire=_friendlyFire;
    dead=false;
    println("COINS created");
  }

  void update() {
    if (!dead && !freeze) { 
      flick=int(random(255));
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
        angle-=0.4*timeBend;
      } else {
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
        angle+=0.4*timeBend;
        if (timer+interval<stampTime) {
          timer=stampTime;
          particles.add( new  Particle(int(x+cos(radians(random(360)))*random(size)), int(y+sin(radians(random(360)))*random(size)), 0, 0, int(random(30)), 1000, GOLD));
        }
      }
    }
  }

  void display() {
    if (!dead) { 
      super.display();
      strokeWeight(int(sin(radians(angle*30))*5+2));
      // stroke((friendlyFire)? BLACK:color(owner.playerColor));
      // fill((friendlyFire)? BLACK:color(owner.playerColor));
      //ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      //noFill();
      // stroke(flick);
      stroke(30, sin(radians(angle*6))*205+50, sin(radians(angle*20))*45+200);
      fill(35, sin(radians(angle*4))*205+50, sin(radians(angle*6))*45+200);
      ellipse(x, y, sin(radians(angle*4))*size, size);
      /*if ((deathTime-stampTime)<=100)size=400;
       else size=50;*/
    }
  }


  @Override
    void hit(Player p) {    // when fizzle
    if ( !dead) {         
      coins+=amount;
      particles.add( new Text("+"+amount, int( p.cx), int(p.cy), 0, 0, 100, 0, 2000, WHITE, 1));
      particles.add( new Text("+"+amount, int( p.cx), int(p.cy), 0, 0, 140, 0, 2000, color(50, 255, 255), 0));
      for (int i=0; i<6; i++) {
        particles.add( new  Particle(int(p.cx+cos(radians(random(360)))*random(p.diameter)), int(p.cy+sin(radians(random(360)))*random(p.diameter)), 0, 0, int(random(50)+20), 1000, GOLD));
      }
      particles.add(new ShockWave(int(x), int(y), int(size*0.4), 32, 150, p.playerColor));
      particles.add(new Flash(200, 12, p.playerColor));
      // shakeTimer+=damage*.2;
      dead=true;
      deathTime=stampTime;
    }
  }

  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {      
      for (int i=0; i<6; i++) {
        particles.add( new  Particle(int(x+cos(radians(random(360)))*random(size*2)), int(y+sin(radians(random(360)))*random(size*2)), 0, 0, int(random(50)+20), 1200, WHITE));
      }
    }
  }

  Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  void unWrap() {
    resetDuration();
    x+=parent.x;
    y+=parent.y;
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    vel.rotate(parent.angle);
    vel.add(pVel);
    vx=vel.x;
    vy=vel.y;
  }
}

class Bomb extends Projectile implements Reflectable, Containable, Container {//----------------------------------------- Bomb objects ----------------------------------------------------

  float  friction=0.95, shakeness;
  int blastForce=40, flick;
  boolean friendlyFire;
  Projectile parent;
  Containable[] payload;
  Bomb(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_damage;
    blastRadius=200;
    vx= _vx;
    vy= _vy;
    friendlyFire=_friendlyFire;
    /*  for (int i=0; i<2; i++) {
     particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, WHITE));
     }*/
    shakeness=damage*.1;
  }

  void update() {
    if (!dead && !freeze) { 
      flick=int(random(255));
      if (reverse) {  // inverse function
        vx/=1-((1-friction)*timeBend);
        vy/=1-((1-friction)*timeBend);
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=1-((1-friction)*timeBend);
        vy*=1-((1-friction)*timeBend);
      }
    }
  }

  void display() {
    if (!dead) { 
      super.display();
      displayHitBox(blastRadius);
      strokeWeight(5);
      stroke((friendlyFire)? BLACK:color(owner.playerColor));
      fill((friendlyFire)? BLACK:color(owner.playerColor));
      ellipse(x, y, (size*(deathTime-stampTime)/time)-size, (size*(deathTime-stampTime)/time)-size );
      noFill();
      stroke(flick);
      ellipse(x, y, size, size);
      /*if ((deathTime-stampTime)<=100)size=400;
       else size=50;*/
    }
  }

  void hitPlayersInRadius(int range, boolean _friendlyFire) {
    if (!freeze &&!reverse) { 

      for (Player p : players) { 
        if ( !p.dead && (p.ally !=owner.ally || _friendlyFire)) { //players.get(i).index!= playerIndex && 
          if (dist(x, y, p.cx, p.cy)<range) {
            super.hit(p);
            p.hit(damage);
            p.pushForce(blastForce, calcAngleFromBlastZone(x, y, p.cx, p.cy));
          }
        }
      }
    }
  }


  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      super.fizzle();
      for (int i=0; i<5; i++) {
        particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
      }
      if (payload!=null) {
        for (Containable p : payload) {
          if (p!=null) {
            if (p instanceof Particle )particles.add((Particle)p);
            if (p instanceof Player )players.add((Player)p);
            if (p instanceof Projectile ) projectiles.add((Projectile)p);
            p.unWrap();
          }
        }
      } else {
        //   particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.5), 16, 200, WHITE));
        //   particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 32, 150, (friendlyFire)? BLACK:color(owner.playerColor)));
        particles.add(new ShockWave(int(x), int(y), int(blastRadius*1), 16, 200, WHITE));
        particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.8), 32, 150, (friendlyFire)? BLACK:color(owner.playerColor)));
        particles.add(new Flash(200, 12, WHITE));
        hitPlayersInRadius(blastRadius, friendlyFire);
        shakeTimer+=shakeness;
      }
    }
  }

  public void reflect(float _angle, Player _player) {
    //angle=_angle;
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;
    if (payload!=null) {
      for (Containable p : payload) {
        if (p!=null) {

          if (p instanceof Particle )particles.add((Particle)p);
          if (p instanceof Player )players.add((Player)p);
          if (p instanceof Projectile ) {         
            projectiles.add((Projectile)p);
            ((Projectile)p).owner=owner;
            ((Projectile)p).ally=ally;
            ((Projectile)p).projectileColor=projectileColor;
          }

          p.unWrap();
        }
      }
    } 
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
  Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  void unWrap() {
    resetDuration();
    x+=parent.x;
    y+=parent.y;
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    vel.rotate(parent.angle);
    vel.add(pVel);
    vx=vel.x;
    vy=vel.y;
  }
  Container contains(Containable[] _payload) {
    payload=_payload;
    return this;
  }
}

class Granade extends Bomb {
  float count;
  Granade(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super( _owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire) ;
    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;
    friendlyFire=_friendlyFire;
  }

  void checkBounds() {
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
    super.display();
    if (!dead) {
      stroke(owner.playerColor);
      strokeWeight(6);
      arc(x, y, blastRadius*.5, blastRadius*.5, radians(count), radians(count+40));
      arc(x, y, blastRadius*.5, blastRadius*.5, radians(count+180), radians(count+220));
    }
  }
  void fizzle() {
    super.fizzle();
    if (!deathAnimation) particles.add( new Feather(blastRadius, int(x), int(y), random(-2, 2), random(-2, 2), blastRadius*.1, owner.playerColor));
  }
  void  update() {

    super.update();
    if (!freeze)count+=10*timeBend;
    checkBounds();
  }
}

class DetonateBomb extends Bomb {//----------------------------------------- Bomb objects ----------------------------------------------------

  float friction=0.95;
  int blastForce=20;
  long originalDeathTime;
  DetonateBomb(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    originalDeathTime=deathTime;
    blastRadius=160;
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
      // super.display();
      displayHitBox(blastRadius*2);
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
    void hitPlayersInRadius(int range, boolean _friendlyFire) {
    if (!freeze &&!reverse) {
      for (Player p : players) { 
        if ( !p.dead && (p.ally !=owner.ally || _friendlyFire)) { //players.get(i).index!= playerIndex && 
          if (dist(x, y, p.cx, p.cy)<range) {
            particles.add(new TempSlow(1000, 0.05, 1.05));
            p.hit(damage);
            p.pushForce(blastForce, calcAngleFromBlastZone(x, y, p.cx, p.cy));
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
      super.fizzle();
      for (int i=0; i<360; i+=30) {
        Projectile p= new Needle(owner, int(x+cos(radians(i+15))*250), int(y+sin(radians(i+15))*250), 60, BLACK, 600, i+195, -cos(radians(i+15))*35, -sin(radians(i+15))*35, 25);
        p.ally=-1;
        projectiles.add(p);
        projectiles.add( new Needle(owner, int(x+cos(radians(i))*200), int(y+sin(radians(i))*200), 60, owner.playerColor, 600, i+180, -cos(radians(i))*20, -sin(radians(i))*20, 10));
      }
      for (int i=15; i<360; i+=30) {
        projectiles.add( new  Blast(owner, int( x+cos(radians(i))*200), int(y+sin(radians(i))*200), -20, 50, BLACK, 350, i, 2, 50, 12));
      }
      for (int i=0; i<360; i+=30) {
        projectiles.add( new  Blast(owner, int( x+cos(radians(i))*200), int(y+sin(radians(i))*200), 15, 40, owner.playerColor, 350, i, 1, 30, 12));
      }
      for (int i=0; i<8; i++) {
        particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
      }
      particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.5), 16, 175, owner.playerColor));
      particles.add(new ShockWave(int(x), int(y), int(blastRadius), 16, 1000, BLACK));
      //particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 125, owner.playerColor));
      particles.add(new Flash(200, 12, WHITE));
      hitPlayersInRadius(blastRadius, friendlyFire);
      shakeTimer+=20;
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
      if (hitBox)super.display();
      pushMatrix();
      translate(x, y);
      noFill();
      strokeWeight(5);
      stroke(freezeColor);
      if (spawnTime+1000<stampTime) rect(-(size*.5), -(size*.5), (size), (size));
      rotate(radians(angle));
      stroke((friendlyFire)? BLACK:color(owner.playerColor));
      rect(-(size*.5), -(size*.5), (size), (size));
      popMatrix();
    }
  }

  @Override

    void hit(Player enemy) {
    // super.hit();
    // enemy.hit(damage);
    if (spawnTime+1000<stampTime) {
      fizzle();
      particles.add(new TempSlow(100, 0.15, 1.05));
      deathTime=stampTime;   // projectile is dead on collision
      dead=true;
    }
  }
  public void reflect(float _angle, Player _player) {
    owner=_player;
  }
}
class Rocket extends Bomb implements Reflectable, Destroyable, Container {//----------------------------------------- Bomb objects ----------------------------------------------------

  float timedScale, smoke;
  Containable payload[];
  Containable defaultPayload;
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
        if (smoke>1) {
          smoke=0;
          particles.add(new Particle(int(x), int(y), 0, 0, int(random(25)+8), 800, 255));
          // particles.add(new Particle(int(x), int(y), vx*0.2, vy*0.2, int(random(10)+5), 900, projectileColor));
        }        
        smoke+=1*timeBend;


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
      if (hitBox)super.display();
      strokeWeight(5);
      stroke((friendlyFire)? BLACK:color(owner.playerColor));
      fill((friendlyFire)? BLACK:color(owner.playerColor));
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
    particles.add( new TempSlow(10, 0.15, 1.05));
    super.fizzle();
    // fizzle();
    deathTime=stampTime;   // projectile is dead on collision
    dead=true;
  }
  @Override
    void fizzle() {    // when fizzle
    super.fizzle();
    //if ( !dead) {         
    payLoad();
    // }
  }
  public void payLoad() {
    for (int i=0; i<4; i++) {
      particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
    }
    /* for (int i=0; i<360; i+=360/6) {
     projectiles.add( new Bomb(owner, int( x), int(y), 25, owner.playerColor, 400, owner.angle+i, cos(radians(owner.angle+i))*10+vx, sin(radians(owner.angle+i))*10+vy, damage, false));
     }*/

    if (payload!=null) {
      for (Containable p : payload) {
        if (p!=null) {

          if (p instanceof Particle )particles.add((Particle)p);
          if (p instanceof Player )players.add((Player)p);
          if (p instanceof Projectile ) {         

            projectiles.add((Projectile)p);
            ((Projectile)p).owner=owner;
            ((Projectile)p).ally=ally;
            ((Projectile)p).projectileColor=projectileColor;
          }
          p.unWrap();
        }
      }
    } else {
    }
    /* fill((friendlyFire)? BLACK:color(owner.playerColor));
     ellipse(x, y, size*5, size*5);
     particles.add(new ShockWave(int(x+vx), int(y+vy), int(blastRadius*0.5), 20, 220, WHITE));
     particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 18, 150, (friendlyFire)? BLACK:color(owner.playerColor)));
     particles.add(new Flash(200, 12, WHITE));
     hitPlayersInRadius(blastRadius, friendlyFire);
     shakeTimer+=15;*/
  }
  public void reflect(float _angle, Player _player) {
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;

    particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));

    float diff=_angle;
    float oAngle=angle;
    angle-=diff;
    // angle=angle%360;

    angle=-angle;
    angle+=diff;

    particles.add(new Spark( 1000, int(x), int(y), -cos(radians(angle))*5, -sin(radians(angle))*5, 6, angle, projectileColor));
    vx= cos(radians(angle))*(abs(vx)+abs(vy));
    vy= sin(radians(angle))*(abs(vx)+abs(vy));
    reflectPayLoad(angle-oAngle);
    //reflectPayLoad(_angle,_player);
  }

  void reflectPayLoad(float diffAngle) {
    if (payload!=null) {
      for (Containable p : payload) {
        if (p!=null) {
          if (p instanceof Particle ) { 
            Particle P =(Particle)p;
            P.angle+=diffAngle;
            float v=abs(P.vx)+  abs(P.vy);
            P.vx= cos(radians(P.angle))*v;
            P.vy= sin(radians(P.angle))*v;
          }
          if (p instanceof Player ) {  
            ((Player)p).angle+=diffAngle;
          }
          if (p instanceof Projectile ) {  
            Projectile P =(Projectile)p;
            P.angle+=diffAngle;
            P.changeColor(owner.playerColor);
            float v=abs(P.vx)+  abs(P.vy);
            P.vx= cos(radians(P.angle))*v;
            P.vy= sin(radians(P.angle))*v;
          }
        }
      }
    }
  }

  void destroy(Projectile destroyerP) {
    // fizzle();
    deathTime=stampTime;   // projectile is dead on collision
    dead=true;
    //payLoad();
  }

  Container contains(Containable[] _payload) {
    payload=_payload;
    return this;
  }
}

class Missle extends Rocket implements Reflectable {//----------------------------------------- Missle objects ----------------------------------------------------
  int angleSpeed=13, seekRange=1200;
  float turnRate=0.15;
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
        vx/=friction*timeBend;
        vy/=friction*timeBend;
      } else {
        if (smoke>1) {
          smoke=0;
          particles.add(new Particle(int(x), int(y), 0, 0, int(random(size*.5)+5), 800, owner.playerColor));

          // particles.add(new Particle(int(x), int(y), vx*0.2, vy*0.2, int(random(10)+5), 900, projectileColor));
        }
        smoke+=1*timeBend;


        //angle+=sin(radians(count))*10;
        // count+=10;
        timedScale =size-(size*(deathTime-stampTime)/time);
        x+=(vx+cos(radians(angle))*angleSpeed)*timeBend;
        y+=(vy+sin(radians(angle))*angleSpeed)*timeBend;

        target= seek(this, seekRange);
        if (target!=null && target!=owner && target.targetable) { 
          float tx=target.cx, ty=target.cy, keyAngle=(atan2(ty-y, tx-x) * 180 / PI);
          keyAngle+= 360; 
          angle+= 360; 
          keyAngle= keyAngle % 360; 
          angle = angle % 360; 


          float relativeAngleToTarget = keyAngle - angle;
          //println(relativeAngleToTarget+"more "+keyAngle+" : " +angle);

          if (relativeAngleToTarget > 180)
            relativeAngleToTarget -= 360;
          else if (relativeAngleToTarget < -180)
            relativeAngleToTarget += 360;
          angle += relativeAngleToTarget * turnRate;
          //stroke(255);
          //line(x, y, tx, ty);
          targetHommingVarning(target);
        }
        //vx+=;
        //vy+=sin(radians(angle))*10;
        //vx=constrain(vx,-10,10);
        //vy=constrain(vy,-10,10);
        vx*=1-friction*timeBend;
        vy*=1-friction*timeBend;
      }
    }
  }

  @Override
    public void payLoad() {
    /*for (int i=0; i<4; i++) {
     particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
     }*/
    /*for (int i=0; i<360; i+=360/6) {
     projectiles.add( new Bomb(owner, int( x), int(y), 25, owner.playerColor, 400, owner.angle+i, cos(radians(owner.angle+i))*10+vx, sin(radians(owner.angle+i))*10+vy, damage, false));
     }*/
    fill((friendlyFire)? BLACK:color(owner.playerColor));
    ellipse(x, y, size*4, size*4);
    particles.add(new ShockWave(int(x+vx), int(y+vy), int(blastRadius*0.5), 20, 220, WHITE));
    particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 18, 150, (friendlyFire)? BLACK:color(owner.playerColor)));
    particles.add(new Flash(200, 12, WHITE));
    hitPlayersInRadius(blastRadius, friendlyFire);
    shakeTimer+=10;
  }
}
class SinRocket extends Rocket implements Reflectable {//----------------------------------------- SinRocket objects ----------------------------------------------------
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
        angle-=sin(radians(count))*10*timeBend;
        count-=10*timeBend;
        timedScale =size-(size*(deathTime-stampTime)/time);
        x-=(vx+cos(radians(angle))*angleSpeed)*timeBend;
        y-=(vy+sin(radians(angle))*angleSpeed)*timeBend;
        vx/=friction;
        vy/=friction;
      } else {
        if (smoke>1) {
          smoke=0;
          particles.add(new Particle(int(x), int(y), 0, 0, int(random(25)+8), 800, WHITE));
          // particles.add(new Particle(int(x), int(y), vx*0.2, vy*0.2, int(random(10)+5), 900, projectileColor));
        }
        smoke+=2F*timeBend;
        angle+=sin(radians(count))*10*timeBend;
        count+=10*timeBend;
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
    super.payLoad();
    if (payload==null) {
      for (int i=0; i<4; i++) {
        particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
      }
      /*for (int i=0; i<360; i+=360/6) {
       projectiles.add( new Bomb(owner, int( x), int(y), 25, owner.playerColor, 400, owner.angle+i, cos(radians(owner.angle+i))*10+vx, sin(radians(owner.angle+i))*10+vy, damage, false));
       }*/
      fill((friendlyFire)? BLACK:color(owner.playerColor));
      ellipse(x, y, size*4, size*4);
      particles.add(new ShockWave(int(x+vx), int(y+vy), int(blastRadius*0.5), 20, 220, WHITE));
      particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 18, 150, (friendlyFire)? BLACK:color(owner.playerColor)));
      particles.add(new Flash(200, 12, WHITE));
      hitPlayersInRadius(blastRadius, friendlyFire);
      shakeTimer+=10;
    }
  }
}
class RCRocket extends Rocket implements Reflectable {//----------------------------------------- RCRocket objects ----------------------------------------------------
  float offsetAngle, acceleration=2;
  boolean controlable;
  RCRocket(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _offsetAngle, float _vx, float _vy, int _damage, boolean _friendlyFire, boolean _controlable) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, _friendlyFire);
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
    offsetAngle=_offsetAngle;
    // friction=0.99;
    controlable=_controlable;
    shakeness=damage*.2;
  }
  @Override
    void update() {
    if (!dead && !freeze) { 
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;

        vx/=friction;
        vy/=friction;
        vx-=cos(radians(angle))*acceleration;
        vy-=sin(radians(angle))*acceleration;
        if (controlable)angle=owner.keyAngle+offsetAngle;
      } else {
        particles.add(new Particle(int(x), int(y), 0, 0, int(random(25)+8), 800, owner.playerColor));
        timedScale =size-(size*(deathTime-stampTime)/time);
        if (controlable)angle=owner.keyAngle+offsetAngle;
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx+=cos(radians(angle))*acceleration;
        vy+=sin(radians(angle))*acceleration;
        vx*=friction;
        vy*=friction;
      }
    }
  }
  @Override
    public void payLoad() {
    for (int i=0; i<6; i++) {
      particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
    }
    /*for (int i=0; i<360; i+=360/6) {
     projectiles.add( new Bomb(owner, int( x), int(y), 25, owner.playerColor, 400, owner.angle+i, cos(radians(owner.angle+i))*10+vx, sin(radians(owner.angle+i))*10+vy, damage, false));
     }*/
    fill((friendlyFire)? BLACK:color(owner.playerColor));
    ellipse(x, y, size*5, size*5);
    particles.add(new ShockWave(int(x+vx), int(y+vy), int(blastRadius*0.5), 20, 220, WHITE));
    particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.4), 18, 150, (friendlyFire)? BLACK:color(owner.playerColor)));
    particles.add(new Flash(200, 12, WHITE));
    hitPlayersInRadius(blastRadius, friendlyFire);
    shakeTimer+=shakeness;
  }
}
class Thunder extends Bomb {//----------------------------------------- Thunder objects ----------------------------------------------------
  int segment=40, arms;
  PShape shockCircle = createShape();       // First create the shape
  float electryfiy, opacity, segmentInterval;
  boolean firstFrozen;
  Thunder(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, int _arms, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time, _angle, _vx, _vy, _damage, true);
    blastRadius=_size;
    friendlyFire=_friendlyFire;
    arms=_arms;
    segmentInterval=360/segment;
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
      // super.display();
      displayHitBox(blastRadius*2);
      if (!freeze) {
        if (!firstFrozen) {
          shockCircle=createShape();
          firstFrozen=true;
        }
        beginShape();
        noFill();
        strokeWeight(4);
        stroke(projectileColor, opacity);

        for (int i=0; i<360; i+= segmentInterval) {
          vertex(x+cos(radians(i))*blastRadius*(1.3-random(electryfiy)), y+sin(radians(i))*blastRadius*(1.3-random(electryfiy)));
        }
        endShape(CLOSE);
        stroke((friendlyFire)?BLACK:WHITE, opacity);
        beginShape();
        for (int i=0; i<360; i+= segmentInterval) {
          vertex(x+cos(radians(i))*blastRadius*(1.2-random(electryfiy)), y+sin(radians(i))*blastRadius*(1.2-random(electryfiy)));
        }
        endShape(CLOSE);
      } else {
        if (firstFrozen) {
          shockCircle.beginShape();
          shockCircle.noFill();
          shockCircle.strokeWeight(4);
          shockCircle.stroke(projectileColor, opacity);

          for (int i=0; i<360; i+= segmentInterval) {
            shockCircle.vertex(x+cos(radians(i))*blastRadius*(1.3-random(electryfiy)), y+sin(radians(i))*blastRadius*(1.3-random(electryfiy)));
          }
          shockCircle.endShape(CLOSE);
          shockCircle.stroke(WHITE);
          shockCircle.beginShape();
          for (int i=0; i<360; i+= segmentInterval) {
            shockCircle.vertex(x+cos(radians(i))*blastRadius*(1.2-random(electryfiy)), y+sin(radians(i))*blastRadius*(1.2-random(electryfiy)));
          }
          shockCircle.endShape(CLOSE);
          firstFrozen=false;
        } 
        shape(shockCircle, shockCircle.X + shockCircle.width*.5, shockCircle.Y+shockCircle.height*.5);
      }
    }
  }

  @Override
    void fizzle() {    // when fizzle
    if ( !dead ) {         
      super.fizzle();
      for (int i=0; i<5; i++) {
        particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
      }
      if (arms>1) {
        for (int i=0; i<360; i+= (360/arms)) {
          particles.add( new Shock(400, int( x), int(y), 0, 0, 2, i, projectileColor)) ;
        }
      }
      particles.add(new ShockWave(int(x), int(y), int(blastRadius*0.5), 20, blastRadius, WHITE));
      particles.add(new Flash(500, 12, WHITE));

      beginShape();
      strokeWeight(16);
      noFill();
      stroke(random(255));
      for (int i=20; i<3000; i*= 1.1) {
        vertex(x+cos(radians(random(360)))*i, y+sin(radians(random(360)))*i);
      }
      endShape(CLOSE);
      hitPlayersInRadius(blastRadius, friendlyFire);
      //shakeTimer=50;
      if (shakeTimer<40)shakeTimer+=int(damage*.2);
    }
  }
  void hit(Player enemy) {
  }
}

class CurrentLine extends Projectile {//----------------------------------------- Current objects ----------------------------------------------------
  float senseRange, tesla, homX, homY;
  int accuracy, brightness, thickness;
  boolean linked, used, follow=true;
  Player target, link;

  CurrentLine(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, float _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    damage=_damage;
  }
  CurrentLine(Player _owner, Player _linked, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, float _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    damage=_damage;
    link=_linked;
  }
  void update() {
    if (!dead && !freeze) { 
      brightness=int(random(150, 250));
      thickness=int(random(10));
      senseRange=size+accuracy*12 - random(accuracy*4);
      target=homingToEnemy(owner.cx, owner.cy); // homing returns 0 if it cant fin any enemy index
      // else target=homingToEnemy(owner.cx, owner.cy);
      if (link!=null)      target=homingToEnemy(link.cx, link.cy); // homing returns 0 if it cant fin any enemy index

      tesla=size+accuracy*10; // tesla effect range
      if (target!=null && !target.dead) target.hit(damage);
      if (linked && !used) {
        projectiles.add( new CurrentLine(owner, target, int( target.cx), int(target.cy), size, owner.playerColor, 300, target.angle, 0, 0, damage)); // link
        used=true;
      }
    }
  }


  void display() {
    if (!dead) {
      super.display();
      stroke(hue(owner.playerColor), 255, brightness);
      strokeWeight(thickness);
      if (link!=null && target!=null) {
        homX=link.cx;
        homY=link.cy;
        noFill();
        ellipse(homX, homY, senseRange, senseRange);
        line(link.cx, link.cy, target.cx, target.cy);
        // if (int(random(10))==0) particles.add(new particle(7, WHITE, target.x+random(tesla)-tesla*.5, target.y+random(tesla)-tesla*.5, random(360), random(20), 50, int(random(100)+50), 8)); // electric Particles
        bezier(target.cx, target.cy, target.cx-100 +random(tesla)-tesla*.5, target.cy+random(tesla)-tesla*.5, target.cx+100+random(tesla)-tesla*.5, target.cy+random(tesla)-tesla*.5, target.cx, target.cy);// crosshier
        bezier(target.cx, target.cy, target.cx+random(tesla)-tesla*.5, target.cy-100+random(tesla)-tesla*.5, target.cx+random(tesla)-tesla*.5, target.cy+100+random(tesla)-tesla*.5, target.cx, target.cy);// crosshier
        // target.force(random(360), this.v/5 );   // force enemy back
        // target.hit(this.damage);
      } else {
        if (target!=null) {
          homX=target.cx;
          homY=target.cy;
          noFill();
          ellipse(homX, homY, senseRange*.5, senseRange*.5);
          line(owner.cx, owner.cy, target.cx, target.cy);
          // if (int(random(10))==0) particles.add(new particle(7, WHITE, target.x+random(tesla)-tesla*.5, target.y+random(tesla)-tesla*.5, random(360), random(20), 50, int(random(100)+50), 8)); // electric Particles
          bezier(target.cx, target.cy, target.cx-100 +random(tesla)-tesla*.5, target.cy+random(tesla)-tesla*.5, target.cx+100+random(tesla)-tesla*.5, target.cy+random(tesla)-tesla*.5, target.cx, target.cy);// crosshier
          bezier(target.cx, target.cy, target.cx+random(tesla)-tesla*.5, target.cy-100+random(tesla)-tesla*.5, target.cx+random(tesla)-tesla*.5, target.cy+100+random(tesla)-tesla*.5, target.cx, target.cy);// crosshier
          // target.force(random(360), this.v/5 );   // force enemy back
          // target.hit(this.damage);
          //   fill(255);
          particles.add(new  Tesla( int(target.cx), int(target.cy), 300, 200, owner.playerColor));
        } else {            // if enemies is not present
          noFill();
          strokeWeight(1);
          // if (int(random(20))==0) particles.add(new particle(7, WHITE, owner.cx+random(tesla)-tesla*.5, owner.cy+random(tesla)-tesla*.5, random(360), random(10), 50, int(random(50)+50), 8)); // electric Particles

          homX=owner.cx; 
          homY= owner.cy;
          ellipse(homX, homY, tesla, tesla);
          bezier(owner.cx, owner.cy, owner.cx-100 +random(tesla)-tesla*.5, owner.cy+random(tesla)-tesla*.5, owner.cx+100+random(tesla)-tesla*.5, owner.cy+random(tesla)-tesla*.5, owner.cx, owner.cy+random(tesla)-tesla*.5);// crosshier
          bezier(owner.cx, owner.cy, owner.cx+random(tesla)-tesla*.5, owner.cy-100+random(tesla)-tesla*.5, owner.cx+random(tesla)-tesla*.5, owner.cy+100+random(tesla)-tesla*.5, owner.cx, owner.cy+random(tesla)-tesla*.5);// crosshier
        }


        stroke(hue(owner.playerColor), 255, random(100)+150);
        noFill();
        bezier(owner.cx, owner.cy, owner.cx+10-random(100), owner.cy+10-random(100), homX+10-random(100), homY+10-random(100), homX, homY);
      }
    }
  }


  Player homingToEnemy(float X, float Y) {  // missile range scan
    for (int sense = 0; sense < senseRange; sense+=5) { // 5 interval
      for (  Player p : players) {
        if (p!=owner && p.ally!=owner.ally && !p.dead && dist(p.cx, p.cy, X, Y)<sense*.5) {
          if (target!=link ||(link!=null && link==owner)) {
            return null;
          }
          linked=true;
          return p;
        }
      }
    }
    return null;
  }
}

class Needle extends Projectile implements Reflectable, Destroyable {//----------------------------------------- Needle objects ----------------------------------------------------
  float v, spray=30;
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
      super.display();
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
    super.hit( enemy);
    // super.hit();
    enemy.hit(damage);
    deathTime=stampTime;   // dead on collision
    dead=true;
    for (int i=0; i<4; i++) {
      // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
      float sprayAngle=random(-spray, spray)+angle;
      float sprayVelocity=random(v*0.5);
      particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    }
    // particles.add(new LineWave(int(x), int(y), 80, 100, WHITE, angle+90));
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
  void destroy(Projectile destroyerP) {
    dead=true;
    deathTime=stampTime;   // dead on collision
    for (int i=0; i<4; i++) {
      // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
      float sprayAngle=random(-spray, spray)+angle+180;
      float sprayVelocity=random(v*0.3);
      particles.add(new Spark( 750, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, destroyerP.owner.playerColor));
    }
  }
}
class Spike extends Projectile implements Reflectable, Destroyer, Destroyable {//----------------------------------------- Needle objects ----------------------------------------------------
  float v, spray=30;
  Spike(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
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
      super.display();
      strokeWeight(8);
      // strokeJoin(ROUND);
      // stroke(255);
      //line(x, y, x-cos(radians(angle))*size, y-sin(radians(angle))*size);

      stroke(projectileColor);
      line(x-cos(radians(angle))*size*.2, y-sin(radians(angle))*size*.2, x-cos(radians(angle))*size, y-sin(radians(angle))*size);
      fill(WHITE);
      ellipse(x, y, size*.3, size*.3);
      // strokeCap(NORMAL);
    }
  }

  @Override
    void hit(Player enemy) {
    super.hit( enemy);
    // super.hit();
    enemy.pushForce(2, angle);
    enemy.hit(damage);
    deathTime=stampTime;   // dead on collision
    dead=true;
    for (int i=0; i<4; i++) {
      // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
      float sprayAngle=random(-spray, spray)+angle;
      float sprayVelocity=random(v*0.75);
      particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    }
    // particles.add(new LineWave(int(x), int(y), 80, 100, WHITE, angle+90));
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
  void destroy(Projectile destroyerP) {
    dead=true;
    deathTime=stampTime;   // dead on collision
    for (int i=0; i<4; i++) {
      // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
      float sprayAngle=random(-spray, spray)+angle+180;
      float sprayVelocity=random(v*0.3);
      particles.add(new Spark( 750, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, destroyerP.owner.playerColor));
    }
  }
  void destroying(Projectile destroyed) {
    particles.add(new Particle(int(x), int( y), 0, 0, int(size), 800, WHITE));
    for (int i=0; i<4; i++) {
      // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
      float sprayAngle=random(-spray, spray)+angle+180;
      float sprayVelocity=random(v*0.3);
      particles.add(new Spark( 750, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, destroyed.owner.playerColor));
    }
  }
}
class Slash extends Projectile implements Destroyer {//----------------------------------------- Slash objects ----------------------------------------------------
  int traceAmount=8;
  float  angleV=24, range, lowRange, traceLowRange[]=new float[traceAmount];
  float pCX, pCY, traceAngle[]=new float[traceAmount];
  boolean follow;

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
    pCX=_owner.cx;
    pCY= _owner.cy;
    if (freeze)follow=false;
    melee=true;
    for (int i=0; i<3; i++) {
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
          pCX=owner.cx;
          pCY= owner.cy;
        }
        x=pCX-cos(radians(angle))*range;
        y=pCY-sin(radians(angle))*range;
        pCX-=vx*timeBend;
        pCY-=vy*timeBend;
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
          pCX=owner.cx;
          pCY= owner.cy;
        }
        x=pCX-cos(radians(angle))*range;
        y=pCY-sin(radians(angle))*range;
        pCX+=vx*timeBend;
        pCY+=vy*timeBend;
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
      super.display();
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
      for (int i=0; i<2; i++) {
        particles.add(new Particle(int(x), int(y), cos(radians(random(-15, 15)+angle-120))*10, sin(radians(random(-15, 15)+angle-120))*10, int(random(20)+5), 800, 255));
      }
    }
    dead=true;
  }
  @Override
    void hit(Player enemy) {
    super.hit(enemy);
    enemy.hit(damage);
    for (int i=0; i<3; i++)particles.add(new Particle(int(x), int(y), random(20)-10, random(20)-10, int(random(20)+5), 800, 255));
    for (int i=0; i<2; i++)particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
    particles.add(new LineWave(int(enemy.cx), int(enemy.cy), 15, 300, projectileColor, angle+90));
    particles.add(new LineWave(int(enemy.cx), int(enemy.cy), 10, 200, WHITE, angle+90));
  }

  void destroying(Projectile destroyedP) {
    fill(WHITE);
    stroke(owner.playerColor);
    strokeWeight(8);
    triangle(x+random(50)-150, y+random(50)-25, x+random(50)+100, y+random(50)-25, x+random(50)-50, y+random(50)+75);
    particles.add(new Fragment(int(destroyedP.x), int(destroyedP.y), 0, 0, 40, 10, 500, 100, owner.playerColor) );
  }
}
class Slice extends Projectile implements Destroyer {//----------------------------------------- Slash objects ----------------------------------------------------
  int traceAmount=8;
  float  angleV=24, range, lowRange, traceLowRange[]=new float[traceAmount], xOffset[]=new float[traceAmount], yOffset[]=new float[traceAmount];
  float pCX, pCY, traceAngle[]=new float[traceAmount], defaultSize;
  boolean follow;

  Slice(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _angleV, float _range, float _vx, float _vy, int _damage, boolean _follow) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    follow=_follow;
    angle=_angle;
    angleV=_angleV;
    damage=_damage;
    force=-10;

    vx= _vx;
    vy= _vy;
    range= _range;
    pCX=_owner.cx;
    pCY= _owner.cy;
    pCX=_x;
    pCY=_y;
    defaultSize=_size;
    if (freeze)follow=false;
    melee=true;
    /* for (int i=0; i<3; i++) {
     particles.add(new Particle(int(x), int(y), vx/(2-0.12*i), vy/(2-0.12*i), 10+i*4, _time, _projectileColor));
     }
     for (int i=0; i<2; i++) {
     particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
     }*/
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {

        //pCX=players.get(playerIndex).x+players.get(playerIndex).w*0.5;
        //pCY= players.get(playerIndex).y+players.get(playerIndex).w*0.5;
        if (follow) {
          pCX=owner.cx;
          pCY= owner.cy;
        }
        x=pCX-cos(radians(angle))*(range*1.5+xOffset[0]);
        y=pCY-sin(radians(angle))*(range*1.5+yOffset[0]);
        pCX-=vx*timeBend;
        pCY-=vy*timeBend;
        traceAngle[0]=angle;
        size=int(sin(radians((180*(deathTime-stampTime)/time)))*defaultSize);

        for (int i=1; traceAmount>i; i++) {
          traceLowRange[i]=traceLowRange[i-1];
        }
        lowRange=sin(radians((180*(deathTime-stampTime)/time)))*range*0.5;
        angle-=angleV*timeBend;
        traceLowRange[0]=lowRange;

        xOffset[0] =sin(radians(180*(deathTime-stampTime)/time))*range;
        yOffset[0] =sin(radians(180*(deathTime-stampTime)/time))*range;
        for (int i = traceAmount-1; i >= 1; i--) {                
          xOffset[i]=xOffset[i-1];
          yOffset[i]=yOffset[i-1];
        }
        for (int i=1; traceAmount>i; i++) {
          traceAngle[i]=traceAngle[i-1];
        }


      } else {

        //pCX=players.get(playerIndex).x+players.get(playerIndex).w*0.5;
        //pCY= players.get(playerIndex).y+players.get(playerIndex).w*0.5;
        if (follow) {
          pCX=owner.cx;
          pCY=owner.cy;
        }
        x=pCX-cos(radians(angle))*(range*1.5+xOffset[0]);
        y=pCY-sin(radians(angle))*(range*1.5+yOffset[0]);
        pCX+=vx*timeBend;
        pCY+=vy*timeBend;
        traceLowRange[0]=lowRange;
        size=int(sin(radians((180*(deathTime-stampTime)/time)))*defaultSize);
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
        /* for (int i=0; traceAmount-1>i; i++) {
         //traceAngle[i]=traceAngle[i-1];
         traceAngle[i+1]=traceAngle[i];
         println(traceAngle[i]);
         }*/
        xOffset[0] =sin(radians(180*(deathTime-stampTime)/time))*range;
        yOffset[0] =sin(radians(180*(deathTime-stampTime)/time))*range;
        //println( xOffset[0]);
        for (int i = traceAmount-1; i >= 1; i--) {                
          xOffset[i]=xOffset[i-1];
          yOffset[i]=yOffset[i-1];
        }
        // range= lowRange;

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
      super.display();
      for (int i=0; traceAmount>i; i++) {
        strokeWeight(int(xOffset[i]*(angleV*0.06)));
        stroke(projectileColor, (traceAmount-i)*(255/traceAmount));
        line(pCX -cos(radians(traceAngle[i]))*(range-traceLowRange[i]+xOffset[i]*2), pCY-sin(radians(traceAngle[i]))*(range-traceLowRange[i]+yOffset[i]*2), pCX-cos(radians(traceAngle[i]))*(range+xOffset[i]*3), pCY-sin(radians(traceAngle[i]))*(range+yOffset[i]*3));
      }
      stroke(255);
      line(pCX -cos(radians(traceAngle[0]))*(range-traceLowRange[0]+xOffset[0]*2), pCY-sin(radians(traceAngle[0]))*(range-traceLowRange[0]+yOffset[0]*2), pCX-cos(radians(traceAngle[0]))*(range+xOffset[0]*3), pCY-sin(radians(traceAngle[0]))*(range+yOffset[0]*3));

      // line(pCX -cos(radians(angle))*(range-lowRange+xOffset[i]), pCY-sin(radians(angle))*(range-lowRange+yOffset[i]), pCX-cos(radians(angle))*(range+xOffset[i]), pCY-sin(radians(angle))*(range+yOffset[i]));
    }
  }
  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<2; i++) {
        particles.add(new Particle(int(x), int(y), cos(radians(random(-15, 15)+angle-120))*10, sin(radians(random(-15, 15)+angle-120))*10, int(random(20)+5), 800, 255));
      }
    }
    dead=true;
  }
  @Override
    void hit(Player enemy) {
    super.hit(enemy);
    enemy.hit(damage);
    for (int i=0; i<3; i++)particles.add(new Particle(int(x), int(y), random(20)-10, random(20)-10, int(random(20)+5), 800, 255));
    for (int i=0; i<2; i++)particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
    particles.add(new LineWave(int(enemy.cx), int(enemy.cy), 15, 300, projectileColor, angle+90));
    particles.add(new LineWave(int(enemy.cx), int(enemy.cy), 10, 200, WHITE, angle+90));
  }

  void destroying(Projectile destroyedP) {
    fill(WHITE);
    stroke(owner.playerColor);
    strokeWeight(8);
    triangle(x+random(50)-150, y+random(50)-25, x+random(50)+100, y+random(50)-25, x+random(50)-50, y+random(50)+75);
    particles.add(new Fragment(int(destroyedP.x), int(destroyedP.y), 0, 0, 40, 10, 500, 100, owner.playerColor) );
  }
}

class Boomerang extends Projectile implements Reflectable {//----------------------------------------- Boomerang objects ----------------------------------------------------
  float v, spray=16, pCX, pCY, graceTime=500, displayAngle, selfHitAngle=80, recoverEnergy, angleSpeed=20;
  Boomerang(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, float _damage, float _recoverEnergy, float _angleSpeed) {
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
        vx += (x-owner.cx)*0.002;
        vy += (y-owner.cy)*0.002;
        x-=vx*timeBend;
        y-=vy*timeBend;
        pCX=owner.cx;
        pCY=owner.cy;
      } else {
        pCX=owner.cx;
        pCY=owner.cy;
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx -= (x-owner.cx)*0.002;
        vy -= (y-owner.cy)*0.002;
        vx*=0.98;
        vy*=0.98;
        displayAngle+=angleSpeed*timeBend;
        angle=degrees(atan2(vy, vx));
        particles.add(new Particle(int(x), int(y), cos(radians(displayAngle*2))*(abs(vy)+abs(vx))*0.5, sin(radians(displayAngle*2))*(abs(vy)+abs(vx))*0.5, int(random(10)+5), 150, BLACK));

        // particles.add(new Particle(int(x), int(y),0, 0, 60, 1000, owner.playerColor));
        particles.add(new Particle(int(x), int(y), 0, 0, 100-int(abs(vx)+abs(vy)), 1000, BLACK));
        if (dist(x, y, pCX, pCY)<50 && (stampTime-spawnTime)>graceTime) retrieve();
      }
    }
  }

  void display() {
    if (!dead) { 
      super.display();
      strokeWeight(8);
      stroke(projectileColor);
      // fill(255);
      line(x+cos(radians(displayAngle))*size, y+sin(radians(displayAngle))*size, x-cos(radians(displayAngle))*size, y-sin(radians(displayAngle))*size);
      line(x+cos(radians(displayAngle+45))*size*0.6, y+sin(radians(displayAngle+45))*size*0.6, x-cos(radians(displayAngle+45))*size*0.6, y-sin(radians(displayAngle+45))*size*0.6);
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
    if (!owner.dead&&owner.angle-selfHitAngle<angle && owner.angle+selfHitAngle>angle) { 
      owner.hit(int(damage*.4*(abs(vx)+abs(vy))));
      particles.add( new TempFreeze(int((abs(vx)+abs(vy))*2)));
      //owner.pushForce(vx, vy, angle);
      owner.pushForce(vx, vy);
      for (int i=0; i<16; i++) {
        particles.add(new Spark( 1000, int(x), int(y), (vx+random(-spray, spray))*random(0, 0.8), (vy+random(-spray, spray))*random(0, 0.8), 6, angle, projectileColor));
      }
    } else {

      // owner.pushForce(vx*0.2, vy*0.2, angle);
      owner.pushForce(vx*0.2, vy*0.2);
      owner.abilityList.get(0).energy+=recoverEnergy;
      particles.add(new RShockWave(int(owner.cx), int(owner.cy), 350, 32, 300, WHITE));
      // particles.add(new ShockWave(int(players.get(playerIndex).x+players.get(playerIndex).w*0.5), int(players.get(playerIndex).y+players.get(playerIndex).h*0.5), 20, 100, projectileColor));
    }
    deathTime=stampTime;   // dead on collision with owner
    dead=true;
  }

  @Override
    void hit(Player enemy) {
    super.hit(enemy);

    enemy.hit(floor(damage*(abs(vx)+abs(vy))*0.08));
    //enemy.pushForce(vx*0.05, vy*0.05, angle);
    enemy.pushForce(vx*0.05, vy*0.05);
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

class HomingMissile extends Projectile implements Reflectable, Destroyable, Containable {//----------------------------------------- HomingMissile objects ----------------------------------------------------

  PShape  sh, c ;
  float  homeRate, gravityRate=0.008, count, smoke;
  int reactionTime=40;
  final int  leapAccel=10, lockRange=300, seekRadius=4000;
  boolean locked, leap;
  Player target;
  Projectile parent;
  HomingMissile(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;
    size=_size;
    /* for (int i=0; i<2; i++) {
     particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
     }*/


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

    target=seek(owner, seekRadius, TARGETABLE); // seek to closest enemy player
    calcAngle();
    //ellipse(target.x+target.w*0.5, target.y+target.w*0.5, 200, 200);
  }
  void setOwner() {
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
      } else {

        if (target!=null && target.dead ||target==owner)target=seek(owner, seekRadius, TARGETABLE); // reseek if target is dead

        if ((locked && !leap)|| (target!=null && target!=owner && !target.dead  && reactionTime>count && dist(x, y, target.x, target.y)<lockRange)) {
          vx=cos(radians(angle))*-0.5*timeBend;
          vy=sin(radians(angle))*-0.5*timeBend;
          // vx=0;
          // vy=0;
          count+=1*timeBend;
          if (!locked)locking();
          if (reactionTime<=count)leaping();
        } else if (leap) {
          vx+=cos(radians(angle))*leapAccel*timeBend;
          vy+=sin(radians(angle))*leapAccel*timeBend;

          if (smoke>1) {
            smoke=0;
            particles.add(new Particle(int(x), int(y), cos(radians(angle+180))*(abs(vx)+abs(vy))*0.1, sin(radians(angle+180))*(abs(vx)+abs(vy))*0.1, 15, 300, WHITE));
            // particles.add(new Particle(int(x), int(y), vx*0.2, vy*0.2, int(random(10)+5), 900, projectileColor));
          }        
          smoke+=1*timeBend;
        } else if (!locked) {
          calcAngle();
          vx+=cos(radians(angle))*homeRate*timeBend;
          vy+=sin(radians(angle))*homeRate*timeBend;
          if (target!=null) {  
            x+=((target.cx)-x)*gravityRate*timeBend;
            y+=((target.cy)-y)*gravityRate*timeBend;
          }
        }
        x+=vx*timeBend;
        y+=vy*timeBend;

        homeRate+=0.015*timeBend;
      }
    }
  }
  void locking() {

    locked=true;
    if (parent==null)particles.add(new LineWave(int(x), int(y), 30, 80, projectileColor, angle));
  }
  void leaping() {
    leap=true;
    fill(255);
    noStroke();
    ellipse(x, y, size*2, size*2);
  }
  void display() {
    if (!dead) { 
      super.display();
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
    if (target!=null) {
      float tcx=target.cx, tcy=target.cy;
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
  }
  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<2; i++) {
        particles.add(new Particle(int(x), int(y), random(10)-5+vx, random(10)-5+vy, int(random(20)+5), 800, 255));
      }
    }
  }

  void destroy(Projectile destroyerP) {
    dead=true;
    deathTime=stampTime;   // dead on collision
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5-vx, random(10)-5-vy, int(random(20)+5), 800, destroyerP.owner.playerColor));
    }
    particles.add(new LineWave(int(x), int(y), 10, 300, destroyerP.owner.playerColor, angle+90));
    fizzle();
  }
  @Override
    void hit(Player enemy) {
    super.hit(enemy);
    enemy.hit(int(leap?damage:(locked?damage*0.25:damage*0.5)));
    deathTime=stampTime;   // dead on collision
    dead=true;
    //enemy.pushForce(vx*0.05, vy*0.05, angle);
    enemy.pushForce(vx*0.05, vy*0.05);

    for (int i=0; i<6; i++) {
      particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
    }
    particles.add(new Flash(50, 64, 255));  
    particles.add(new LineWave(int(x), int(y), 10, 300, WHITE, angle));
  }

  void calcAngle() {
    if (target!=null) angle = degrees(atan2(((target.cy)-y), ((target.cx)-x)));
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
  Containable parent(Container parent) {
    this.parent=(  Projectile)parent;
    return this;
  }
  void unWrap() {
    x+=parent.x;
    y+=parent.y;

    fill(255);
    ellipse(x, y, size*3, size*3);
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
    resetDuration();

    target=seek(owner, seekRadius); // reseek if target is dead
  }
  public Projectile clone() {
    target=seek(owner, seekRadius); // seek to closest enemy player

    return (Projectile)super.clone();
    /*
    catch(Exception e) {
     println(e);
     return null;
     }*/
  }
}

class Shield extends Projectile implements Reflector, Container { //----------------------------------------- Shield objects ----------------------------------------------------
  int brightness=255, offsetX, offsetY;
  boolean follow;
  Containable payload[];

  Shield( Player _owner, int _x, int _y, color _projectileColor, int  _time, float _angle, float _damage) {
    super(_owner, _x, _y, 1, _projectileColor, _time);
    damage= int(_damage);
    size=60;
    angle=_angle;
    //follow=false;
    particles.add(new Particle(int(x), int(y), random(10)-5, random(10)-5, int(random(20)+5), 800, 255));

    /*for (int i=0; i<2; i++) {
     particles.add(new Particle(int(x), int(y), random(10)-5, random(10)-5, int(random(20)+5), 800, 255));
     }*/
  }
  Shield( Player _owner, int _x, int _y, color _projectileColor, int  _time, float _angle, float _damage, int _offsetX, int _offsetY) {
    super(_owner, _x, _y, 1, _projectileColor, _time);
    damage= int(_damage);
    size=60;
    angle=_angle;
    offsetX=_offsetX;
    offsetY=_offsetY;
    follow=true;
    particles.add(new Particle(int(x), int(y), random(10)-5, random(10)-5, int(random(20)+5), 800, 255));

    /*for (int i=0; i<2; i++) {
     particles.add(new Particle(int(x), int(y), random(10)-5, random(10)-5, int(random(20)+5), 800, 255));
     }*/
  }
  void display() {
    if (!dead ) { 
      super.display();

      fill(0);
      //text(angle, x-100, y-100);
      strokeWeight(int(10));
      stroke(color(hue(projectileColor), 255-brightness, brightness(projectileColor)));
      // line(cos(radians(angle-90+90))*size*0.9+int(x), sin(radians(angle-90+90))*size*0.9+int(y), cos(radians(angle+90+90))*size*0.9+int(x), sin(radians(angle+90+90))*size*0.9+int(y));
      line(cos(radians(angle))*size*0.9+int(x), sin(radians(angle))*size*0.9+int(y), cos(radians(angle+90+90))*size*0.9+int(x), sin(radians(angle+90+90))*size*0.9+int(y));
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
          x=owner.cx+offsetX;
          y=owner.cy+offsetY;
        }
      } else {
        if (follow) {
          x=owner.cx+offsetX;
          y=owner.cy+offsetY;
        }
        if (brightness>0)brightness-=10;

        //   shakeTimer=int(laserWidth*0.1);
        // particles.add(new  Gradient(1000, int(x+size*0.5), int(y+size*0.5), 0, 0, 4, angle, projectileColor));

        /* for (int i= 0; players.size () > i; i++)
         if (playerIndex!=i  && !players.get(i).dead) lineVsCircleCollision(x, y, cos(radians(angle))*laserLength+int(x), sin(radians(angle))*laserLength+int(y), players.get(i));
         } */
      }
    }
  }

  @Override
    void fizzle() {    // when fizzle
    if ( !dead && !follow) {        
      if (payload!=null) {
        for (Containable p : payload) {
          if (p!=null) {
            if (p instanceof Particle )particles.add((Particle)p);
            if (p instanceof Player )players.add((Player)p);
            if (p instanceof Projectile ) projectiles.add((Projectile)p);
            p.unWrap();
          }
        }
      }
      // for (int i=0; i<2; i++) {
      // particles.add(new Particle(int(x-cos(radians(angle))*15), int(y-sin(radians(angle))*15), 0, 0, int(random(25)), 500, color(projectileColor)));
      particles.add(new Particle(int(x+cos(radians(angle))*15), int(y+sin(radians(angle))*15), 0, 0, int(random(25)), 500, color(projectileColor)));
      particles.add(new Particle(int(x-cos(radians(angle))*30), int(y-sin(radians(angle))*30), 0, 0, int(random(25)), 500, color(projectileColor)));
      particles.add(new Particle(int(x+cos(radians(angle))*30), int(y+sin(radians(angle))*30), 0, 0, int(random(25)), 500, color(projectileColor)));
      particles.add(new Particle(int(x-cos(radians(angle))*50), int(y-sin(radians(angle))*50), 0, 0, int(random(25)), 500, color(projectileColor)));
      // particles.add(new Particle(int(x+cos(radians(angle))*50), int(y+sin(radians(angle))*50), 0, 0, int(random(25)), 500, color(projectileColor)));
      particles.add(new Particle(int(x), int(y), 0, 0, 10, 1000, color(projectileColor)));
      //  particles.add(new Particle(int(x), int(y), random(10)-5, random(10)-5, int(random(20)+5), 1000, projectileColor));
      //}
    }
  }

  void ProjectilelineVsProjectileCircleCollision(float x, float y, float x2, float y2, Projectile projectile) {
    float cx= projectile.x+projectile.size*0.5, cy=projectile.y+projectile.size*0.5; //cr= projectile.size*0.5;
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
    //float mY = (-y+cy)*ca + ( x-cx)*sa;
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
    super.hit(enemy);
    int offset=20;
    float pushPower=0.5;
    //  particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    //enemy.hit(2);

    if (!enemy.stationary) { 
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
    }
    //  particles.add( new  Particle(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), cos(radians(angle))*12, sin(radians(angle))*12, 120, 100, color(255, 0, 255)));
  } 

  Container contains(Containable[] _payload) {
    payload=_payload;
    return this;
  }

  public void reflecting() {
    brightness=500;
    particles.add(new ShockWave(int(x), int(y), size, 16, 100, WHITE));
  }
}


class Electron extends Projectile implements Reflectable, Destroyer {//----------------------------------------- Electron objects ----------------------------------------------------
  boolean orbit=true, returning;
  int recoverEnergy=5;
  final float derailMultiplier=2.5;
  float orbitAngle, vx, vy, distance=25, maxDistance=200, orbitAngleSpeed=6;
  Electron(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage, boolean _returning) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    returning=_returning;
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
          x=owner.cx+cos(radians(orbitAngle))*distance;
          y=owner.cy+sin(radians(orbitAngle))*distance;
          orbitAngle+=orbitAngleSpeed*timeBend;
          angle+=12*timeBend;
        } else {
          //angle+=6*timeBend;
          x+=vx*timeBend;
          y+=vy*timeBend;
        }
      }
    }
  }
  void display() {
    if (!dead) { 
      super.display();

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
        particles.add(new Particle(int(x+size*.5), int(y+size*.5), random(10)-5+vx, random(10)-5+vy, int(random(20)+5), 800, 255));
      }
    }
  }
  @Override
    void hit(Player enemy) {
    super.hit(enemy);
    if (orbit) { 
      enemy.hit(int(damage*0.5));
      enemy.pushForce(8*orbitAngleSpeed, orbitAngle+90);
      deathTime=stampTime;   // dead on collision
      dead=true;
      for (int i=0; i<10; i++) {
        particles.add(new Particle(int(x), int(y), random(20)-10, random(20)-10, int(random(20)+5), 800, 255));
      }
      for (int i=0; i<4; i++) {
        particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
      }
    } else { 
      enemy.hit(int(damage*derailMultiplier));
      enemy.pushForce(12*orbitAngleSpeed, angle);

      particles.add(new ShockWave(int(x), int(y), size*2, 16, 150, WHITE));
      for (int i=0; i<4; i++) {
        particles.add(new Particle(int(x), int(y), random(40)-20, random(40)-20, int(random(30)+10), 800, projectileColor));
      }
      if (returning) {
        owner.abilityList.get(0).energy+=recoverEnergy;
        orbit=true;
        projectiles.add( new CurrentLine(owner, int( enemy.cx), int( enemy.cx), 200, owner.playerColor, 200, owner.angle, 0, 0, 2));
        deathTime+=3000;
        stroke(projectileColor);
        strokeWeight(size);
        line(x, y, owner.cx+cos(radians(orbitAngle))*distance, owner.cy+sin(radians(orbitAngle))*distance);
        x=owner.cx;
        y=owner.cy;
      } else { 
        dead=true; 
        deathTime=stampTime;   // dead on collision
      }
    }

    // particles.add(new Flash(200, 32, 255));  
    // particles.add(new LineWave(int(enemy.x+enemy.w*0.5), int(enemy.y+enemy.h*0.5), 10, 300, projectileColor, angle));
  }

  @Override
    public void reflect(float _angle, Player _player) {

    try {
      DeployElectron tempA=(DeployElectron)owner.abilityList.get(0);
      for (  int i=tempA.stored.size()-1; i>=0; i--) {
        if (tempA.stored.get(i)==this)tempA.stored.remove(i);
      }
    }
    catch(Exception e) {
      println(e+"reflect");
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
  void  destroying(Projectile destroyed) {
    //if(orbit){
    particles.add(new ShockWave(int(destroyed.x), int(destroyed.y), size*2, 10, 50, WHITE));

    for (int i=0; i<3; i++) {
      // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
      float sprayAngle=random(-20, 20)+angle;
      float sprayVelocity=random(10*0.75);
      particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    }
    distance -= destroyed.damage*15;
    size-=destroyed.damage*4;
    damage-=destroyed.damage*.5;
    if (distance<=0||size<=0) { 
      deathTime=stampTime;
      dead=true;
    }

    //}
  }
}

class Graviton extends Projectile implements Containable {//----------------------------------------- Graviton objects ----------------------------------------------------

  float  friction=0.95, rotionSpeed=8;
  int dragForce=-1, dragRadius=250, dragDiameter=500, count, arms=3;
  final int bend=60;
  Projectile parent;
  Graviton(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _rotionSpeed, float _vx, float _vy, float _damage, int _arms) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    rotionSpeed=_rotionSpeed;
    angle=_angle;
    damage=_damage;
    vx= _vx;
    vy= _vy;
    arms=_arms;
    dragRadius=_size;
    dragDiameter=_size*2;
    /* for (int i=0; i<2; i++) {
     particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
     }
     particles.add(new ShockWave(int(x), int(y), int(dragRadius*0.5), 16, _size+50, color(_projectileColor)));
     particles.add(new ShockWave(int(x), int(y), int(dragRadius*0.4), 16, _size, WHITE));*/
  }
  void update() {
    if (!dead && !freeze) { 

      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
        angle-=rotionSpeed*timeBend;
      } else {
        angle+=rotionSpeed*timeBend;
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
        dragPlayersInRadius(dragRadius, false);
        count++;
        if ((count%int(35/(timeBend)))==0)particles.add(new RShockWave(int(x), int(y), int(dragDiameter), int(16*damage), dragDiameter, color(projectileColor)));
      }
    }
  }
  void display() {
    if (!dead) { 
      super.display();
      displayHitBox(dragDiameter);
      strokeWeight(sin(radians(count*4*timeBend))*5);
      stroke(WHITE);
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


  void dragPlayersInRadius(int range, boolean friendlyFire) {
    if (!freeze &&!reverse) { 
      /* for (int i=0; i<players.size (); i++) { 
       if (!players.get(i).dead &&players.get(i).ally!=owner.ally&&(players.get(i).index!= playerIndex || friendlyFire)) {
       if (dist(x, y, players.get(i).cx, players.get(i).cy)<range) {
       players.get(i).pushForce(dragForce*timeBend, calcAngleFromBlastZone(x, y, players.get(i).cx, players.get(i).cy));
       if (count%10==0)players.get(i).hit(damage);
       }
       }
       }*/
      for (Player p : players) { 
        if (!p.dead &&p.ally!=owner.ally&&(p.index!= playerIndex || friendlyFire)) {
          if (dist(x, y, p.cx, p.cy)<range) {
            p.pushForce(dragForce*timeBend, calcAngleFromBlastZone(x, y, p.cx, p.cy));
            if (count%10==0)p.hit(damage);
          }
        }
      }
    }
  }

  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {         
      for (int i=0; i<6; i++) {
        particles.add(new Particle(int(x), int(y), random(-80, 80), random(-80, 80), int(random(30)+10), 800, 255));
      }
      // particles.add(new Flash(200, 12, WHITE));
      shakeTimer+=5;
    }
  }
  Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  void unWrap() {
    resetDuration();
    x+=parent.x;
    y+=parent.y;
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    // vel.rotate(parent.angle);
    vel.add(pVel);
    vx=vel.x;
    vy=vel.y;
    for (int i=0; i<2; i++) {
      particles.add(new Particle(int(x), int(y), random(10)-5+vx*0.5, random(10)-5+vy*0.5, int(random(20)+5), 800, 255));
    }
    particles.add(new ShockWave(int(x), int(y), int(dragRadius*0.5), 16, 200, color(projectileColor)));
    particles.add(new ShockWave(int(x), int(y), int(dragRadius*0.4), 16, 150, WHITE));
  }
}

class Slug extends Projectile implements Reflectable, Destroyer, Destroyable {//----------------------------------------- Needle objects ----------------------------------------------------
  float v, spray=50, InpactSlowFactor=0.6, health;
  boolean first=true;
  ArrayList<Player> playerList = new ArrayList<Player>();
  Slug(Player _owner, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, int _damage) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    v=abs(_vx)+ abs(_vy); 
    damage=_damage;
    vx= _vx;
    vy= _vy;
    health=damage*2;
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
      super.display();

      // strokeCap(ROUND);
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      strokeWeight(8);
      // strokeJoin(ROUND);
      fill(255);
      //line(x, y, x+cos(radians(angle))*size, y+sin(radians(angle))*size);
      stroke(projectileColor);
      rect(-size*.5, -size*.5, size*2, size);
      popMatrix();
      //line(x, y, x+cos(radians(angle))*size*0.8, y+sin(radians(angle))*size*0.8);
      // strokeCap(NORMAL);
    }
  }

  @Override
    void hit(Player enemy) {
    super.hit(enemy);

    if (!playerList.contains(enemy)) {
      enemy.hit(damage);
      vx*=InpactSlowFactor;
      vy*=InpactSlowFactor;
      v*=InpactSlowFactor;
      shakeTimer+=4;
      particles.add(new ShockWave(int(enemy.cx), int(enemy.cy), size*2, 30, 150, WHITE));

      for (int i=0; i<10; i++) {
        // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
        float sprayAngle=random(-spray, spray)+angle;
        float sprayVelocity=random(v*0.75);
        particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
      }
      playerList.add(enemy);
    } else {
      // deathTime=stampTime;   // dead on collision
      // dead=true;
      enemy.pushForce(v, angle);
      for (int i=0; i<1; i++) {

        // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
        float sprayAngle=random(-spray, spray)+angle;
        float sprayVelocity=random(v*0.75);
        particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
      }
    }
    // particles.add(new LineWave(int(x), int(y), 80, 100, WHITE, angle+90));
  }
  @Override
    public void reflect(float _angle, Player _player) {
    playerIndex=_player.index;
    owner=_player;
    projectileColor=owner.playerColor;
    ally=owner.ally;
    first=true;
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
  void destroy(Projectile destroyerP) {
    health-=destroyerP.damage;
    if (health<1) {
      dead=true;
      deathTime=stampTime;   // dead on collision
      // particles.add(new ShockWave(int(enemy.cx), int(enemy.cy), size*2, 30, 150, WHITE));

      for (int i=0; i<10; i++) {
        // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
        float sprayAngle=random(-spray, spray)+angle+180;
        float sprayVelocity=random(v*0.3);
        particles.add(new Spark( 750, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, destroyerP.owner.playerColor));
      }
    } else {
      vx*=0.9;
      vy*=0.9;
      v*=0.9;
      size*=.9;
    }
  }
  void  destroying(Projectile destroyed) {

    particles.add(new ShockWave(int(destroyed.x), int(destroyed.y), size*2, 10, 50, WHITE));

    for (int i=0; i<3; i++) {
      // particles.add(new Particle(int(x), int(y), vx, vy, int(random(30)+10), 800, projectileColor));
      float sprayAngle=random(-spray, spray)+angle;
      float sprayVelocity=random(v*0.75);
      particles.add(new Spark( 1000, int(x), int(y), cos(radians(sprayAngle))*sprayVelocity, sin(radians(sprayAngle))*sprayVelocity, 6, sprayAngle, projectileColor));
    }
  }
}
class AbilityPack extends Projectile implements Containable {//----------------------------------------- AbilityPack objects ----------------------------------------------------

  float  friction=0.95, count, rC;
  long timer, graceTimer;
  int flick, interval=400, graceDuration=1500;
  boolean friendlyFire, adding;

  Ability ability;
  Projectile parent;
  AbilityPack(Player _owner, Ability _ability, int _x, int _y, int _size, color _projectileColor, int  _time, float _angle, float _vx, float _vy, boolean _adding, boolean _friendlyFire) {
    super(_owner, _x, _y, _size, _projectileColor, _time);
    angle=_angle;
    adding=_adding;
    ability=_ability;
    vx= _vx;
    vy= _vy;
    friendlyFire=_friendlyFire;
    meta=true;
  }

  void update() {
    if (!dead && !freeze) { 
      flick=int(random(255));
      if (reverse) {
        x-=vx*timeBend;
        y-=vy*timeBend;
        vx/=friction;
        vy/=friction;
        angle-=0.5*timeBend;
      } else {
        x+=vx*timeBend;
        y+=vy*timeBend;
        vx*=friction;
        vy*=friction;
        count+=2*timeBend;
        angle+=0.5*timeBend;
        if (timer+interval<stampTime) {
          timer=stampTime;
          particles.add( new  Particle(int(x+cos(radians(random(360)))*random(size)), int(y+sin(radians(random(360)))*random(size)), 0, 0, int(random(50)), 1000, WHITE));
        }
      }
    }
  }

  void display() {
    if (!dead) { 
      super.display();

      strokeWeight(int(sin(radians(angle*30))*10+10));

      if (adding) {    
        if (!freeze)rC=random(255);
        stroke(rC, 255, 255);
        rect( x-size*.5, y-size*.5, size+20*sin(radians(count)), size+20*cos(radians(count)));
        text(ability.name+"+", x, y+100);
      } else      text(ability.name, x, y+100);
      fill(projectileColor, sin(radians(angle*4))*100+100);
      image(ability.icon, x, y, size+10*sin(radians(count)), size+10*cos(radians(count)));
    }
  }


  @Override
    void hit(Player p) {    // when fizzle
    if ( !dead&& stampTime>spawnTime+graceDuration) {         
      p.heal(damage);
      for (int i=0; i<6; i++) {
        particles.add( new  Particle(int(p.cx+cos(radians(random(360)))*random(p.radius*2)), int(p.cy+sin(radians(random(360)))*random(p.radius*2)), 0, 0, int(random(50)+20), 1000, WHITE));
      }
      particles.add(new ShockWave(int(x), int(y), int(size*0.4), 32, 150, p.playerColor));
      particles.add(new Flash(200, 12, p.playerColor));
      // shakeTimer+=damage*.2;
      dead=true;
      deathTime=stampTime;
      ability.setOwner(p);
      if (adding) {
        p.abilityList.add(ability);
      } else {
        if (ability.type==AbilityType.ACTIVE) {
          p.abilityList.set(0, ability);
          announceAbility( p, 0 );
        }
        if (ability.type==AbilityType.PASSIVE) {
          if (p.abilityList.size()<=1) p.abilityList.add(ability);
          p.abilityList.set(1, ability);
          announceAbility( p, 1 );
        }
      }
    }
  }

  @Override
    void fizzle() {    // when fizzle
    if ( !dead) {      
      for (int i=0; i<6; i++) {
        particles.add( new  Particle(int(x+cos(radians(random(360)))*random(size*2)), int(y+sin(radians(random(360)))*random(size*2)), 0, 0, int(random(50)+20), 1200, WHITE));
      }
    }
  }

  Containable parent(Container _parent) {
    parent=(Projectile)_parent;
    return this;
  }
  void unWrap() {
    resetDuration();
    x+=parent.x;
    y+=parent.y;
    PVector vel=new PVector(vx, vy);
    PVector pVel=new PVector(parent.vx, parent.vy);
    vel.rotate(parent.angle);
    vel.add(pVel);
    vx=vel.x;
    vy=vel.y;
  }
}