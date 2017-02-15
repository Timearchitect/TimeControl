class Buff implements Cloneable {
  long spawnTime, deathTime, duration, timer;
  boolean dead, effectAll;
  String name=" ??";
  Player owner, enemy;
  Buff(Player p, int _duration) {

    owner=p;
    duration=_duration;
    spawnTime=stampTime;
    deathTime=stampTime + _duration;
  }
  void update() {
    if (deathTime<stampTime) {
      kill();
    }
  }
  void kill() {
    dead=true;
  }
  void transfer(Player formerOwner, Player formerEnemy) {
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    enemy=formerOwner;
    owner=formerEnemy;
  }
  public Buff clone() {  
    try {
      return (Buff)super.clone();
    }
    catch( CloneNotSupportedException e) {
      println(e+" clonebuff");
      return null;
    }
  }
}

class Burn extends Buff {
  float damage = 2;
  int interval=200;
  Burn(Player p, Player e, int _duration) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
  }
  Burn(Player p, int _duration, float _damage, int _interval) {
    super(p, _duration);
    interval=_interval;
    damage=_damage;
    name=getClassName(this);
  }
  void update() {
    super.update();
    if (!owner.dead && timer+interval<stampTime) {
      timer=stampTime;
      owner.health-=damage;
      if (owner.health<=0)owner.death();
      projectiles.add(new  Blast(owner, int(owner.x+random(owner.w)), int(owner.y+random(owner.h)), 0, int(random(5, 20)), enemy.playerColor, 100, 0, 0, 2, 10));
    }
  }
}
class Poison extends Buff {
  float percent=.005;
  int interval=350;

  Poison(Player p, Player e, int _duration) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
  }
  Poison(Player p, int _duration) {
    super(p, _duration);
    name=getClassName(this);
    //enemy=e;
  }
  void update() {
    super.update();
    if (!owner.dead &&timer+interval<stampTime) {
      timer=stampTime;
      owner.health-=owner.maxHealth*percent;
      particles.add(  new  Particle(int(owner.x+random(owner.w)), int(owner.y+random(owner.h)), 0, 0, int(random(80)+30), 1500, enemy.playerColor));
      particles.add(  new  Particle(int(owner.x+random(owner.w)), int(owner.y+random(owner.h)), owner.vx, owner.vy, int(random(50)+10), 1000, BLACK));
    }
  }
  void transfer(Player formerOwner, Player formerEnemy) {
    super.transfer( formerOwner, formerEnemy);
    for (int i=0;i<360;i+=30) {
      particles.add(  new  Particle(int(formerEnemy.cx), int(formerEnemy.cy), cos(radians(i))*10,  sin(radians(i))*10, int(random(50)+10), 500, BLACK));
    }
  }
}

class Cold extends Buff {
  // float damage = 2;
  int count;
  float friction= 0.25;

  Cold(Player p, Player e, int _duration) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
  }
  void update() {
    super.update();
    //owner.FRICTION_FACTOR=friction;
    owner.vx*=.92;
    owner.vy*=.92;
    count++;
    if (count%14==0) {
      Blast b=new  Blast(owner, int(owner.x+random(owner.w)), int(owner.y+random(owner.h)), 0, int(random(10, 100)), enemy.playerColor, 1000, 0, 0, 10, 0);
      b.angleV=45;
      b.opacity=30;
      projectiles.add(b);
    }
  }
  void kill() {
    dead=true;
    // owner.FRICTION_FACTOR=owner.DEFAULT_FRICTION_FACTOR;
  }
}

class Stun extends Buff {
  // float damage = 2;
  float count;

  Stun(Player p, Player e, int _duration) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
  }
    Stun(Player p,int _duration) {
    super(p, _duration);
    name=getClassName(this);

  }
  void update() {
    owner.stunned=true;
    super.update();
    if (owner.textParticle!=null)particles.remove( owner.textParticle );
    owner.textParticle = new Text(owner, "STUNNED", 0, -75, 30, 0, 100, enemy.playerColor, 0);
    particles.add( owner.textParticle );
    count+=.4;
    strokeWeight(30);
    stroke(enemy.playerColor);
    noFill();
    for (float i =0; i<=PI*2; i+=PI/10) {
      arc(int( owner.cx), int(owner.cy), owner.w+sin(count)*30+15, owner.h+sin(count)*30+15, i+count, i+PI*.03+count);
    }
  }

  void kill() {
    dead=true;
    owner.stunned=false;
  }
}