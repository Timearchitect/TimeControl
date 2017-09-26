class Buff implements Cloneable {
  long spawnTime, deathTime, duration, timer;
  boolean dead, effectAll;
 // String name="??";
    String name;

  BuffType type= BuffType.MULTIPLE;
  Player OGowner, owner, enemy;
  Projectile parent;
  Buff(Player p, int _duration) {

    owner=p;
    OGowner=p;
    duration=_duration;
    spawnTime=stampTime;
    deathTime=stampTime + _duration;
  }
  void update() {
    if (deathTime<stampTime) {
      kill();
    }
  }
  void carryUpdate() {
  }
  void kill() {
    dead=true;
  }
  void onOwnerDeath() {
  }
  void onCollide(Player o, Player e) {
  }
  void transfer(Player formerOwner, Player formerEnemy) {
    spawnTime=stampTime;
    deathTime=stampTime + duration;
    enemy=formerOwner;
    owner=formerEnemy;
  }
  void onHit() {
  }
  Buff apply(BuffType b) {
    type=b;
    return this;
  }
  void onFizzle() {
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

  Poison(Player p, int _duration, float _percent) {
    super(p, _duration);
    percent=_percent;
    name=getClassName(this);
  }
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
  float friction= 0.18;

  Cold(Player p, Player e, int _duration) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
  }
  Cold(Player p, int _duration) {
    super(p, _duration);
    name=getClassName(this);
  }
  Cold(Player p, int _duration, float _effect) {
    super(p, _duration);
    name=getClassName(this);
    friction= _effect;
  }
  void update() {
    super.update();
    //owner.FRICTION_FACTOR=friction;
    owner.vx*=1-friction;
    owner.vy*=1-friction;
    count++;
    if (count%14==0) {
      Blast b=new  Blast(owner, int(owner.x+random(owner.w)), int(owner.y+random(owner.h)), 0, int(random(10, 100)), enemy.playerColor, 1000, 0, 0, 10, 0);
      b.angleV=45;
      b.opacity=30;
      projectiles.add(b);
    }
  }

  void onFizzle() {
    if (parent.blastRadius>0) {
      Blast b=new  Blast(OGowner, int(parent.x), int(parent.y), 0, int(parent.blastRadius), OGowner.playerColor, 1000, 0, 0, 10, 0);
      b.angleV=45;
      b.opacity=10;
      projectiles.add(b);
      for (int i=0; i<35; i++) {
        float angle= random(360);
        float range= parent.blastRadius;
        b=new  Blast(owner, int(parent.x+cos(angle)*range), int(parent.y+sin(angle)*range), 0, int(random(10, 120)), OGowner.playerColor, 1500, 0, 0, 10, 0);
        b.angleV=45;
        b.opacity=20;
        projectiles.add(b);
      }
    }
  }
  void onHit() {
    onFizzle();
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
    if (owner.textParticle!=null) particles.remove( owner.textParticle );
    owner.textParticle = new Text(owner, "STUNNED", 0, -75, 30, 0, 100, enemy.playerColor, 0);
    particles.add( owner.textParticle );
    if (!freeze || owner.freezeImmunity) count+=.4;
    strokeWeight(30);
    stroke(enemy.playerColor);
    noFill();
    for (float i =0; i<=TAU; i+=PI/10) {
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
  void onOwnerDeath() {
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
    owner.textParticle = new Text(owner, "Steady", 0, -75, 30, 0, 100, enemy.playerColor, 0);
    particles.add( owner.textParticle );
    count+=.4;
    strokeWeight(30);
    stroke(enemy.playerColor);
    noFill();

    for (float i =0; i<=TAU; i+=PI/10) {
      arc(int( owner.cx), int(owner.cy), owner.w+sin(count)*30+15, owner.h+sin(count)*30+15, i+count, i+PI*.03+count);
    }
  }

  void kill() {
    dead=true;
    owner.stunned=false;
  }
  void onOwnerDeath() {
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
    for (float i =0; i<=TAU; i+=PI/2) {
      arc(int( owner.cx), int(owner.cy), owner.w+sin(count)*30+15, owner.h+sin(count)*30+15, i+count, i+PI*.03+count);
    }
  }
  void onFizzle() {
    particles.add(new  Tesla( int(parent.x), int(parent.y), 200, 500, owner.playerColor));
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
  void onFizzle() {
    strokeWeight(8);
    for (int i=0; i< 360; i+=18) {
      line(parent.x, parent.y, parent.x+cos(radians(i+count))*250, parent.y+sin(radians(i+count))*250);
    }
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
      line(owner.cx+cos(radians(i+count))*(50*sin(count+i)+70), owner.cy+sin(radians(i+count))*(50*sin(count+i)+70), owner.cx+cos(radians(i+count))*100, owner.cy+sin(radians(i+count))*100);
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
    owner.diameter+=int(amount*2);
    owner.x-=amount;
    owner.y-=amount;
    owner.w=owner.diameter;
    owner.h=owner.diameter;
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
    owner.diameter-=int(amount*2);
    owner.w=owner.diameter;
    owner.h=owner.diameter;
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
    owner.diameter-=int(amount*2);

    owner.x+=amount;
    owner.y+=amount;
    owner.w=owner.diameter;
    owner.h=owner.diameter;
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
    owner.diameter+=int(amount*2);
    owner.w=owner.diameter;
    owner.h=owner.diameter;
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
  void onOwnerDeath() {
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
  void onOwnerDeath() {
    owner.up=defaultUp;
    owner.down=defaultDown;
    owner.left=defaultLeft;
    owner.right=defaultRight;
  }
}

class StickyBomb extends Buff {
  // float damage = 2;
  float count, graceTimer, graceDuration=900;
  float amount;
  String type="Projectile";
  Projectile savedParent;
  StickyBomb(Player p, int _duration, int _amount) {
    super(p, _duration);
    name=getClassName(this);
    amount=_amount;
    graceDuration=stampTime;
  }
  StickyBomb(Player p, Player e, int _duration, int _amount) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
    amount=_amount;
    graceDuration=stampTime;
  }
  void onCollide(Player o, Player e) {
    if (graceTimer+graceDuration>stampTime) {
      transfer(e, o);
    }
  }
  void transfer(Player formerOwner, Player formerEnemy) {
    if (!dead) {

      super.transfer(formerOwner, formerEnemy);
      particles.add(new RShockWave(int(owner.cx), int(owner.cy), owner.diameter+300, 30, 500, enemy.playerColor));

      parent.dead=true;
      savedParent=parent.clone();
      type=getClassName(savedParent);
      //savedParent.spawnTime =stampTime;
      //savedParent.time=parent.time;
      parent.deathTime=stampTime;
      parent.dead=true;
      parent.deathAnimation=true;
    }
    // projectiles.remove(parent);
  }
  void display() {
    // ellipse(owner.cx, owner.cy, 50, 50);
    if (!freeze)count+=22*timeBend;
    stroke(enemy.playerColor);
    strokeWeight(8);
    noFill();
    arc(owner.cx, owner.cy, owner.radius*2.8, owner.radius*2.8, radians(count), radians(count+40));
    arc(owner.cx, owner.cy, owner.radius*2.8, owner.radius*2.8, radians(count+180), radians(count+220));
    //line(owner.cx+cos(count)*(graceTimer-stampTime)*.01, owner.cy+sin(count)*(graceTimer-stampTime)*.01, owner.cx, owner.cy);
  }
  void update() {
    if (!dead) {
      super.update();
      display();
      if (owner.textParticle!=null)particles.remove( owner.textParticle );
      owner.textParticle = new Text(owner, type+" Sticked", 0, -75, 30, 0, 100, owner.playerColor, 1);
      particles.add( owner.textParticle );
    }
  }
  void kill() {
    if (!dead && savedParent!=null) {
      dead=true;
      background(0, 0, 0);
      savedParent.buffList.clear();
      savedParent.x=owner.cx;
      savedParent.y=owner.cy;
      savedParent.vx=0;
      savedParent.vy=0;
      savedParent.dead=false;
      savedParent.deathAnimation=false;
      projectiles.add( savedParent);
    }
  }
  void onOwnerDeath() {
    if (savedParent!=null) {
      savedParent.buffList.clear();
      savedParent.x=owner.cx;
      savedParent.y=owner.cy;
      savedParent.vx=random(-2, 2);
      savedParent.vy=random(-2, 2);
      savedParent.dead=false;
      savedParent.deathAnimation=false;
      projectiles.add( savedParent);
    }
  }
  void onFizzle() {
    this.dead=true;
  }
}


class AimLocked extends Buff {
  // float damage = 2;
  float count;

  AimLocked(Player p, int _duration) {
    super(p, _duration);
    name=getClassName(this);
  }
  AimLocked(Player p, Player e, int _duration) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
  }
  void transfer(Player formerOwner, Player formerEnemy) {
    super.transfer(formerOwner, formerEnemy);
  }
  void update() {
    super.update();
    if (owner.textParticle!=null)particles.remove( owner.textParticle );
    owner.textParticle = new Text(owner, "AIMLOCKED", 0, -75, 30, 0, 100, enemy.playerColor, 0);
    enemy.angle=calcAngleBetween(owner, enemy);
    particles.add( owner.textParticle );
    targetHommingVarning(owner);
  }
  void kill() {
    dead=true;
  }
}

class CriticalHit extends Buff {
  // float damage = 2;
  float precent, damage;

  CriticalHit(Player p, Player e, float _precentChance, float _damage) {
    super(p, 50);
    damage=_damage;
    precent= _precentChance;
    name=getClassName(this);
    enemy=e;
  }
  CriticalHit(Player p, float _precentChance, float _damage) {
    super(p, 50);
    damage=_damage;
    precent= _precentChance;
    name=getClassName(this);
  }
  void transfer(Player formerOwner, Player formerEnemy) {
    super.transfer(formerOwner, formerEnemy);
    if (precent>random(100)) {
      owner.hit(damage);
      particles.add(new Flash(5, 32, WHITE));  

      fill(WHITE);
      stroke(enemy.playerColor);
      strokeWeight(8);
      triangle(owner.cx+random(50)-150, owner.cy+random(50)-25, owner.cx+random(50)+100, owner.cy+random(50)-25, owner.cx+random(50)-50, owner.cy+random(50)+75);
      particles.add(new Fragment(int(owner.cx), int(owner.cy), 0, 0, 40, 10, 500, 100, enemy.playerColor) );
    }
  }
  void update() {
  }

  void kill() {
    dead=true;
  }
}

class DamageBuff extends Buff {
  // float damage = 2;
  float count, amount;
  int defaultUp, defaultDown, defaultLeft, defaultRight;
  DamageBuff(Player p, int _duration, int _amount) {
    super(p, _duration);
    name=getClassName(this);
    amount=_amount;
  }
  DamageBuff(Player p, Player e, int _duration, int _amount) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
    amount=_amount;
  }
  void transfer(Player formerOwner, Player formerEnemy) {
    super.transfer(formerOwner, formerEnemy);
    projectiles.add( new CurrentLine(owner, int( owner.cx), int(owner.cy), int( random(300, 700)), owner.playerColor, 50, owner.angle, cos(radians(owner.angle)), sin(radians(owner.angle)), 5));
    owner.weaponDamage+=amount;
    for (Ability a : owner.abilityList)a.setAllMod();
  }
  void update() {
    super.update();
    if (owner.textParticle!=null)particles.remove( owner.textParticle );
    owner.textParticle = new Text(owner, "ATTACK+", 0, -75, 30, 0, 100, owner.playerColor, 0);
    particles.add( owner.textParticle );
  }
  void kill() {
    dead=true;
    owner.weaponDamage-=amount;
    for (Ability a : owner.abilityList)a.setAllMod();
  }
  void onOwnerDeath() {
    kill();
  }
}
class SpeedBuff extends Buff {
  // float damage = 2;
  float count, amount;
  int defaultUp, defaultDown, defaultLeft, defaultRight;
  SpeedBuff(Player p, int _duration, float _amount) {
    super(p, _duration);
    name=getClassName(this);
    amount=_amount;
  }
  SpeedBuff(Player p, Player e, int _duration, float _amount) {
    super(p, _duration);
    name=getClassName(this);
    enemy=e;
    amount=_amount;
  }
  void transfer(Player formerOwner, Player formerEnemy) {
    super.transfer(formerOwner, formerEnemy);
    projectiles.add( new CurrentLine(owner, int( owner.cx), int(owner.cy), int( random(300, 700)), owner.playerColor, 50, owner.angle, cos(radians(owner.angle)), sin(radians(owner.angle)), 0));
    owner.MAX_ACCEL+=amount;
  }
  void update() {
    super.update();
    if (!owner.stealth) {
      if (owner.textParticle!=null)particles.remove( owner.textParticle );
      owner.textParticle = new Text(owner, "SPEED+", 0, -75, 30, 0, 100, owner.playerColor, 0);
      particles.add( owner.textParticle );
      particles.add(new Particle(int(owner.cx), int(owner.cy), owner.vx*.2, owner.vy*.2, 100, 100, owner.playerColor));
    }
  }
  void kill() {
    dead=true;
    owner.MAX_ACCEL-=amount;
  }
  void onOwnerDeath() {
  }
}