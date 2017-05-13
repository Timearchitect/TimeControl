class Buff implements Cloneable {
  long spawnTime, deathTime, duration, timer;
  boolean dead, effectAll;
  String name="??";
  BuffType type= BuffType.MULTIPLE;
  Player owner, enemy;
  Projectile parent;
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
  Buff apply(BuffType b) {
    type=b;
    return this;
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
    for (int i=0; i<360; i+=30) {
      if (parent!=null)particles.add(  new  Particle(int(formerEnemy.cx), int(formerEnemy.cy), cos(radians(i))*5, sin(radians(i))*5, int(random(50)+10), 500, BLACK));
      else particles.add(  new  Particle(int(parent.x), int(parent.y), cos(radians(i))*5, sin(radians(i))*5, int(random(50)+10), 500, BLACK));
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
  Cold(Player p, int _duration) {
    super(p, _duration);
    name=getClassName(this);
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
  Stun(Player p, int _duration) {
    super(p, _duration);
    name=getClassName(this);
  }
  void update() {
    owner.stunned=true;
    super.update();
    if (owner.textParticle!=null)particles.remove( owner.textParticle );
    owner.textParticle = new Text(owner, "STUNNED", 0, -75, 30, 0, 100, enemy.playerColor, 0);
    particles.add( owner.textParticle );
    if (!freeze || owner.freezeImmunity)count+=.4;
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
    owner.holdTrigg=false;
    owner.holdUp=false;
    owner.holdDown=false;
    owner.holdLeft=false;
    owner.holdRight=false;
  }
}


class Steady extends Buff {
  // float damage = 2;
  float count;

  Steady(Player p, Player e, int _duration) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
  }
  Steady(Player p, int _duration) {
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

class Paralysis extends Buff {
  // float damage = 2;
  float count;
  float randomLimit;
  Paralysis(Player p, Player e, int _duration) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
  }
  Paralysis(Player p, int _duration) {
    super(p, _duration);
    name=getClassName(this);
  }
  void update() {
    //owner.stunned=true;
    super.update();
    if (owner.textParticle!=null)particles.remove( owner.textParticle );
    owner.textParticle = new Text(owner, "Paralyzed", 0, -75, 30, 0, 100, enemy.playerColor, 0);
    particles.add( owner.textParticle );
    count+=1*timeBend;
    strokeWeight(50);
    stroke(enemy.playerColor);
    noFill();
    if (count>randomLimit) {
      randomLimit=random(10, 180);
      count=0;
      owner.stop();
      owner.angle+=random(-180, 180);
      owner.keyAngle=owner.angle;
      particles.add(new  Tesla( int(owner.cx), int(owner.cy), 250, 400, enemy.playerColor));
    }
    for (float i =0; i<=PI*2; i+=PI/2) {
      arc(int( owner.cx), int(owner.cy), owner.w+sin(count)*30+15, owner.h+sin(count)*30+15, i+count, i+PI*.03+count);
    }
  }

  void kill() {
    dead=true;
    // owner.stunned=false;
  }
}

class ArmorPiercing extends Buff {
  // float damage = 2;
  float count;
  float amount=0;
  ArmorPiercing(Player p, Player e, int _duration, int _amount) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
    amount=_amount;
  }
  ArmorPiercing(Player p, int _duration, int _amount) {
    super(p, _duration);
    name=getClassName(this);
    amount=_amount;
  }
  ArmorPiercing(Player p, int _duration) {
    super(p, _duration);
    name=getClassName(this);
  }
  void update() {
    super.update();
    if (owner.textParticle!=null)particles.remove( owner.textParticle );
    owner.textParticle = new Text(owner, "ARMOR DOWN", 0, -75, 30, 0, 100, owner.playerColor, 0);
    particles.add( owner.textParticle );
    owner.armor=-amount;
    count += 0.1*timeBend;
    stroke(enemy.playerColor);
    for (int i=0; i< 360; i+=36) {
      line(owner.cx+cos(radians(i+count))*(70*sin(count+i)+70), owner.cy+sin(radians(i+count))*(70*sin(count+i)+70), owner.cx+cos(radians(i+count))*150, owner.cy+sin(radians(i+count))*150);
    }
  }
  void kill() {
    dead=true;
    owner.armor=int(owner.DEFAULT_ARMOR);
  }
}
class Enlarge extends Buff {
  // float damage = 2;
  float count;
  float amount;
  Enlarge(Player p, int _duration, int _amount) {
    super(p, _duration);
    name=getClassName(this);
    amount=_amount;
  }
  Enlarge(Player p, Player e, int _duration, int _amount) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
    amount=_amount;
  }
  void transfer(Player formerOwner, Player formerEnemy) {
    super.transfer(formerOwner, formerEnemy);
    owner.radius+=int(amount);
    owner.x-=amount;
    owner.y-=amount;
    owner.w=owner.radius*2;
    owner.h=owner.radius*2;
    owner.outlineDiameter=int(owner.radius*2.2);
  }
  void update() {
    super.update();
    if (owner.textParticle!=null)particles.remove( owner.textParticle );
    owner.textParticle = new Text(owner, "Enlarge", 0, -75, 30, 0, 100, owner.playerColor, 0);
    particles.add( owner.textParticle );
  }
  void kill() {
    dead=true;
    owner.x+=amount;
    owner.y+=amount;
    owner.radius-=amount;
    owner.w=owner.radius*2;
    owner.h=owner.radius*2;
    owner.outlineDiameter=int(owner.radius*2.2);
  }
}

class Shrink extends Buff {
  // float damage = 2;
  float count;
  float amount;
  Shrink(Player p, int _duration, int _amount) {
    super(p, _duration);
    name=getClassName(this);
    amount=_amount;
  }
  Shrink(Player p, Player e, int _duration, int _amount) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
    amount=_amount;
  }
  void transfer(Player formerOwner, Player formerEnemy) {
    super.transfer(formerOwner, formerEnemy);
    owner.radius-=int(amount);
    owner.x+=amount;
    owner.y+=amount;
    owner.w=owner.radius*2;
    owner.h=owner.radius*2;
    owner.outlineDiameter=int(owner.radius*2.2);
  }
  void update() {
    super.update();
    if (owner.textParticle!=null)particles.remove( owner.textParticle );
    owner.textParticle = new Text(owner, "Shrink", 0, -75, 30, 0, 100, owner.playerColor, 0);
    particles.add( owner.textParticle );
  }
  void kill() {
    dead=true;
    owner.x-=amount;
    owner.y-=amount;
    owner.radius+=amount;
    owner.w=owner.radius*2;
    owner.h=owner.radius*2;
    owner.outlineDiameter=int(owner.radius*2.2);
  }
}

class Confusion extends Buff {
  // float damage = 2;
  float count;
  int defaultUp, defaultDown, defaultLeft, defaultRight;
  Confusion(Player p, int _duration) {
    super(p, _duration);
    name=getClassName(this);
    //amount=_amount;
  }
  Confusion(Player p, Player e, int _duration) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
    //amount=_amount;
  }
  void transfer(Player formerOwner, Player formerEnemy) {
    super.transfer(formerOwner, formerEnemy);
    defaultUp=owner.up;
    defaultDown=owner.down;
    defaultLeft=owner.left;
    defaultRight=owner.right;
    owner.up=defaultDown;
    owner.down=defaultUp;
    owner.left=defaultRight;
    owner.right=defaultLeft;

  }
  void update() {
    super.update();
    if (owner.textParticle!=null)particles.remove( owner.textParticle );
    owner.textParticle = new Text(owner, "Confusion", 0, -75, 30, 0, 100, owner.playerColor, 0);
    particles.add( owner.textParticle );
  }
  void kill() {
    dead=true;
    owner.up=defaultUp;
    owner.down=defaultDown;
    owner.left=defaultLeft;
    owner.right=defaultRight;
  }
}

class MindControlled extends Buff {
  // float damage = 2;
  float count;
  int defaultUp, defaultDown, defaultLeft, defaultRight;

  MindControlled(Player p, int _duration) {
    super(p, _duration);
    name=getClassName(this);
  }
  MindControlled(Player p, Player e, int _duration) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
  }
  void transfer(Player formerOwner, Player formerEnemy) {
    super.transfer(formerOwner, formerEnemy);
    defaultUp=owner.up;
    defaultDown=owner.down;
    defaultLeft=owner.left;
    defaultRight=owner.right;
    owner.up=enemy.down;
    owner.down=enemy.up;
    owner.left=enemy.right;
    owner.right=enemy.left;
  }
  void update() {
    super.update();
    if (owner.textParticle!=null)particles.remove( owner.textParticle );
    owner.textParticle = new Text(owner, "Confusion", 0, -75, 30, 0, 100, owner.playerColor, 0);
    particles.add( owner.textParticle );
  }
  void kill() {
    dead=true;
    owner.up=owner.down;
    owner.down=owner.up;
    owner.left=owner.right;
    owner.right=owner.left;
  }
}