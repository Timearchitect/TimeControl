class NoPassive extends Ability {//---------------------------------------------------       ---------------------------------

  NoPassive() {
    super();
    icon=icons[31];
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlocked=true;
    sellable=false;
    // deactivatable=false;
  } 
  /* @Override
   void action() {
   }
   @Override
   void press() {
   }
   @Override
   void passive() {
   }
   @Override
   void reset() {
   }*/
}
class HpRegen extends Ability {//---------------------------------------------------    HpRegen   ---------------------------------
  float regenRate = 1;
  int count, interval=15;
  HpRegen() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=1500;
  } 
  HpRegen(float _rate, int _interval) {
    super();
    regenRate=_rate;
    interval=_interval;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
  }
  @Override
    void passive() {
    if (!owner.stealth) {

      count++;
      noFill();
      stroke(owner.playerColor);
      strokeWeight(1);


      if (count%interval==0 && owner.maxHealth>owner.health ) {
        //if (existInList(Poison.class, owner.buffList)) {
        if (!existInList(owner.buffList, Poison.class)) { //poison
          owner.health += regenRate;
          ellipse(owner.cx, owner.cy, 200, 200);
        }
      }
    }
  }
  @Override
    void reset() {
    // super.reset();
  }
}
class Suicide extends Ability {//---------------------------------------------------    HpRegen   ---------------------------------
  int damage=50;
  Suicide() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=250;
  } 
  /*@Override
   void action() {
   }
   @Override
   void press() {
   }
   @Override
   void passive() {
   }
   @Override
   void reset() {
   super.reset();
   }*/
  @Override
    void onDeath() {
    if ((!reverse || owner.reverseImmunity)&&  owner.health<=0 && (!freeze || owner.freezeImmunity)) {
      projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 160, owner.playerColor, 1000, owner.angle, owner.vx, owner.vy, damage, false));
    }
  }
}
class Reward extends Ability {//---------------------------------------------------    HpRegen   ---------------------------------
  //int damage=50;
  int bonus=1;
  boolean drop;
  Reward(int _bonus, boolean  drop) {
    super();
    bonus=_bonus;
    type=AbilityType.NATIVE;
    name=getClassName(this);
    unlockCost=500;
  } 
  /*@Override
   void action() {
   }
   @Override
   void press() {
   }
   @Override
   void passive() {
   }
   @Override
   void reset() {
   super.reset();
   }*/
  @Override
    void onDeath() {
    if ((!reverse || owner.reverseImmunity)&&  owner.health<=0 && (!freeze || owner.freezeImmunity)) {
      // projectiles.add( new Bomb(owner, int( owner.cx), int(owner.cy), 160, owner.playerColor, 1000, owner.angle, owner.vx, owner.vy, damage, false));
      //if (drop) projectiles.add(new CoinBall(AI, owner.cx, owner.cy, 60, GOLD, 10000, 0, 0, 0, 50, true));
      //else coins+=bonus;
      particles.add( new Text("+"+bonus, int( owner.cx), int(owner.cy), 0, 0, 100, 0, 2000, WHITE, 1));
      particles.add( new Text("+"+bonus, int( owner.cx), int(owner.cy), 0, 0, 140, 0, 2000, color(50, 255, 255), 0));
    }
  }
}

class MpRegen extends Ability {//---------------------------------------------------    MpRegen   ---------------------------------
  float regenRate = 1;
  int count;
  MpRegen() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=1500;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
  }
  @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(1);
      ellipse(owner.cx, owner.cy, 200, 200);
      count++;
      if (count%10==0 && owner.abilityList.get(0).maxEnergy>owner.abilityList.get(0).energy)owner.abilityList.get(0).energy += regenRate;
    }
  }
  @Override
    void reset() {
    // super.reset();
  }
}

class Armor extends Ability {//---------------------------------------------------    HpRegen   ---------------------------------
  // float regenRate = 1;
  int armorAmount=3, stillBonusArmor=1;
  Armor() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=1500;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
  }
  @Override
    void hold() {
    hold=true;
  }
  @Override
    void release() {
    hold=false;
  }
  @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      rect(owner.x, owner.y, owner.w, owner.h);

      if (hold) {
        owner.armor=int(armorAmount*.5);
      } else {
        owner.armor=armorAmount;
        rect(owner.x-10, owner.y-10, owner.w+20, owner.h+20);
      }
      if (abs(owner.ax)+abs(owner.ay)<1) {
        owner.armor=armorAmount+stillBonusArmor;
        rect(owner.x-20, owner.y-20, owner.w+40, owner.h+40);
      }
    }
  }
  @Override
    void reset() {
    owner.armor= int(owner.DEFAULT_ARMOR);
  }
}

class Speed extends Ability {//---------------------------------------------------    Speed   ---------------------------------
  float speedLimit = 0.25;
  Speed() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=1000;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
  }
  @Override
    void hold() {
  }
  @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      triangle(owner.cx+sin(0)*100, owner.cy+cos(0)*100, owner.cx+sin(radians(120))*100, owner.cy+cos(radians(120))*100, owner.cx+sin(radians(240))*100, owner.cy+cos(radians(240))*100);
      if (owner.MAX_ACCEL<speedLimit)owner.MAX_ACCEL+=0.02;
    }
  }
  @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}
class Gravitation extends Ability {//---------------------------------------------------    Gravitation   ---------------------------------
  float dragForce =-0.4;  
  int range=300;
  Gravitation() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=500;
  } 
  Gravitation(int _range, float _force) {
    super();
    range=_range;
    dragForce=_force;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
  }
  @Override
    void hold() {
  }
  @Override
    void passive() {
    dragPlayersInRadius(range, false);
  }
  @Override
    void reset() {
  }
  float calcAngleFromBlastZone(float x, float y, float px, float py) {
    double deltaY = py - y;
    double deltaX = px - x;
    return (float)Math.atan2(deltaY, deltaX) * 180 / PI;
  }

  void dragPlayersInRadius(int range, boolean friendlyFire) {
    if (!freeze &&!reverse) { 
      for (Player p : players) { 
        if (!p.dead &&(p!= owner && p.ally!=owner.ally || friendlyFire)) {
          if (dist(owner.cx, owner.cy, p.cx, p.cy)<range) {
            p.pushForce(dragForce*timeBend, calcAngleFromBlastZone(owner.cx, owner.cy, p.cx, p.cy));
            // if (count%10==0)players.get(i).hit(damage);
          }
        }
      }
    }
  }
}
class Repel extends Ability {//---------------------------------------------------    Gravitation   ---------------------------------
  float dragForce =0.5;  
  int range=300;
  Repel() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=500;
  } 
  Repel(int _range, float _force) {
    super();
    range=_range;
    dragForce=_force;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
  }
  @Override
    void hold() {
  }
  @Override
    void passive() {
    dragPlayersInRadius(range, false);
  }
  @Override
    void reset() {
  }
  float calcAngleFromBlastZone(float x, float y, float px, float py) {
    double deltaY = py - y;
    double deltaX = px - x;
    return (float)Math.atan2(deltaY, deltaX) * 180 / PI;
  }

  void dragPlayersInRadius(int range, boolean friendlyFire) {
    if (!freeze &&!reverse) { 
      /*for (int i=0; i<players.size (); i++) { 
       if (!players.get(i).dead &&(players.get(i)!= owner || friendlyFire)) {
       if (dist(owner.cx, owner.cy, players.get(i).cx, players.get(i).cy)<range) {
       players.get(i).pushForce(dragForce*timeBend, calcAngleFromBlastZone(owner.cx, owner.cy, players.get(i).cx, players.get(i).cy));
       // if (count%10==0)players.get(i).hit(damage);
       }
       }
       }
       }*/
      for (Player p : players) { 
        if (!p.dead &&(p!= owner && p.ally!=owner.ally || friendlyFire)) {
          if (dist(owner.cx, owner.cy, p.cx, p.cy)<range) {
            p.pushForce(dragForce*timeBend, calcAngleFromBlastZone(owner.cx, owner.cy, p.cx, p.cy));
            // if (count%10==0)players.get(i).hit(damage);
          }
        }
      }
    }
  }
}
class Static extends Ability {//---------------------------------------------------    Static   ---------------------------------
  int count;
  Static() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=1500;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
  }
  @Override
    void hold() {
  }
  @Override
    void passive() {
    if (!owner.stealth) {
      beginShape();
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      for (int i=0; i<360; i+=60) {
        vertex(owner.cx+sin(radians(i))*175, owner.cy+cos(radians(i))*175);
      }
      endShape(CLOSE);
    }
    count++;
    if (count%100==0)projectiles.add( new CurrentLine(owner, int( owner.cx), int(owner.cy), int( random(300, 700)), owner.playerColor, 50, owner.angle, cos(radians(owner.angle)), sin(radians(owner.angle)), 15));
  }
  @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class SuppressFire extends Ability {//---------------------------------------------------    SuppressFire   ---------------------------------
  int count, cooldown;
  SuppressFire() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=1750;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
    if (cooldown>40) {
      noStroke();
      fill(255);
      ellipse(owner.cx+cos(radians(owner.angle))*100, owner.cy+sin(radians(owner.angle))*100, 50, 50);
      projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 7));
      cooldown=0;
    }
  }
  @Override
    void hold() {
  }
  @Override
    void passive() {
    if (!owner.stealth) {
      beginShape();
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);

      for (int i=0; i<360; i+=72.5) {
        vertex(owner.cx+sin(radians(i))*150, owner.cy+cos(radians(i))*150);
      }

      endShape(CLOSE);
      cooldown++;
      //count++;
      //  if (count%30==0)   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 3));
    }
  }
  @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class Gloss extends Ability {//---------------------------------------------------    Gloss   ---------------------------------
  int count;
  Gloss() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=2000;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
  }
  @Override
    void hold() {
  }
  @Override
    void passive() {
    if (!owner.stealth) {

      cooldown+=1;
      for (int i=0; i<360; i+=30) {
        if (cooldown%360==i) {
          projectiles.add( new Shield( owner, int( owner.cx+cos(radians(i))*180), int(owner.cy+sin(radians(i))*180), owner.playerColor, 1000, i+90, 1, int( cos(radians(i))*180), int(sin(radians(i))*180)));
          projectiles.add( new Shield( owner, int( owner.cx+cos(radians(i+180))*180), int(owner.cy+sin(radians(i+180))*180), owner.playerColor, 1000, i+270, 1, int( cos(radians(i+180))*180), int(sin(radians(i+180))*180)));
        }
      }
      //count++;
      //  if (count%30==0)   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 3));
    }
  }
  @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}
class SnakeShield extends Ability {//---------------------------------------------------    Gloss   ---------------------------------
  int count, x, y;
  SnakeShield() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=2000;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
  }
  @Override
    void hold() {
  }
  @Override
    void passive() {
    if (!owner.stealth && !owner.stationary) {

      // cooldown+=1;
      //for (int i=0; i<360; i+=30) {
      //if (cooldown%360==i) {
      if (dist(owner.cx, owner.cy, x, y)>60) {
        float ang=degrees(atan2(y-owner.cy, x-owner.cx));
        Shield s=new Shield( owner, int( owner.cx+cos(radians(ang))*60), int(owner.cy+sin(radians(ang))*60), owner.playerColor, 1500, ang, 0);
        s.size=45;
        projectiles.add( s);
        x=int(owner.cx);
        y=int(owner.cy);
      }
      //  projectiles.add( new Shield( owner, int( owner.cx+cos(radians(i+180))*180), int(owner.cy+sin(radians(i+180))*180), owner.playerColor, 1000, i+270, 1, int( cos(radians(i+180))*180), int(sin(radians(i+180))*180)));
      //}
      // }
      //count++;
      //  if (count%30==0)   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 3));
    }
  }
  @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class BackShield extends Ability {//---------------------------------------------------    BackShield   ---------------------------------
  int count;
  Shield shield;

  BackShield() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=2000;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
  }
  @Override
    void hold() {
  }
  @Override
    void onDeath() {
    if (shield!=null && !shield.dead) { 
      shield.size=100;
      shield.fizzle();
      shield.deathTime=stampTime;
      shield.dead=true;
    }
  }
  @Override
    void passive() {
    if (!owner.stealth) {
      if (shield==null||shield.dead) { 
        shield=new Shield( owner, int( owner.cx+cos(radians(owner.angle))*100), int(owner.cy+sin(radians(owner.angle))*100), owner.playerColor, 100000, owner.angle+90, 1, int( cos(radians(owner.angle))*100), int(sin(radians(owner.angle))*100));
        shield.size=100;
        projectiles.add(shield );
      }
      shield.angle=owner.angle+90;
      shield.offsetX=int(cos(radians(owner.angle+180))*100);
      shield.offsetY=int(sin(radians(owner.angle+180))*100);
    } else {
      //shield.dead=true;
      if (shield!=null ) {       
        shield.fizzle();
        shield.deathTime=stampTime;
        shield.dead=true;
        shield=null;
      }
    }
  }
  @Override
    void reset() {
    try {
      if (shield!=null||!shield.dead) { 
        shield.size=100;
        shield.fizzle();
        shield.deathTime=stampTime;
        shield.dead=true;
      }
    }
    catch(Exception e) {
      println(e+" shield");
    }
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}


class Trail extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int count, cooldown;
  Trail() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=500;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
  }
  @Override
    void hold() {
    if (cooldown>6) {
      cooldown=0;
      Blast b =new  Blast(owner, int( owner.cx), int(owner.cy), 0, 30, owner.playerColor, 2700, owner.angle, 1, 8, 2);
      projectiles.add(b);
    }
  }
  @Override
    void release() {
  }
  @Override
    void passive() {
    if (!owner.stealth) {
      beginShape();
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      for (int i=0; i<360; i+=20) {
        vertex(owner.cx+sin(radians(i))*150, owner.cy+cos(radians(i))*150);
      }
      endShape(CLOSE);
      cooldown++;
    }
  }
  @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}
class PainPulse extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int count, cooldown;
  PainPulse() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=500;
  } 
  @Override
    void action() {
  }
  @Override
    void onHit() {
    if (cooldown>200) {
      cooldown=0;
      for (int i=0; i<360; i+=45) {
        projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 15, 40, owner.playerColor, 350, i, 1, 30, 12));
      }
    }
  }
  @Override
    void hold() {
  }
  @Override
    void release() {
  }
  @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      beginShape();
      for (int i=0; i<360; i+=10) {
        vertex(owner.cx+sin(radians(i))*100, owner.cy+cos(radians(i))*100);
      }
      endShape(CLOSE);
      cooldown++;
    }
  }
  @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}
class PanicBlink extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int count, cooldown;
  PanicBlink() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=500;
  } 
  @Override
    void action() {
  }
  @Override
    void onHit() {
    if (cooldown>300) {
      cooldown=0;
      particles.add(new Flash(100, 8, BLACK));  
      particles.add( new TempFreeze(400));
      particles.add(new ShockWave(int(owner.cx), int(owner.cy), 20, 16, 200, owner.playerColor));
      particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 800, color(255, 0, 255)));
      owner.stop();
      for (int i =0; i<3; i++) {
        particles.add( new Feather(300, int(owner.cx), int(owner.cy), random(-2, 2), random(-2, 2), 15, owner.playerColor));
      }
      owner.x=random(width);
      owner.y=random(height);
    }
  }
  @Override
    void hold() {
  }
  @Override
    void release() {
  }
  @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      beginShape();
      for (int i=0; i<360; i+=10) {
        vertex(owner.cx+sin(radians(i))*100, owner.cy+cos(radians(i))*100);
      }
      endShape(CLOSE);
      cooldown++;
    }
  }
  @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class Nova extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int count, cooldown;
  Nova() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=1250;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
    // if (cooldown>100) {
    //   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 5));
    // }
  }
  @Override
    void hold() {
  }
  @Override
    void release() {
    if (cooldown>50) {
      cooldown=0;

      projectiles.add( new Slash(owner, int( owner.cx+sin(owner.keyAngle)*60), int(owner.cy+cos(owner.keyAngle)*60), 40, owner.playerColor, 180, owner.angle-100, -24, 110, sin(owner.keyAngle)*10, cos(owner.keyAngle)*10, 4, true));
      projectiles.add( new Slash(owner, int( owner.cx+sin(owner.keyAngle)*60), int(owner.cy+cos(owner.keyAngle)*60), 40, owner.playerColor, 180, owner.angle-280, -24, 110, sin(owner.keyAngle)*10, cos(owner.keyAngle)*10, 4, true));
    }
  }
  @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      strokeWeight(2);
      beginShape();
      for (int i=0; i<360; i+=40) {
        vertex(owner.cx+sin(radians(i))*150, owner.cy+cos(radians(i))*150);
      }

      endShape(CLOSE);
      cooldown++;
      // count++;
      //  if (count%30==0)   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 3));
    }
  }
  @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class BulletCutter extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int window=12, count, cooldown, range=450;
  float a=0, randX, randY;
  boolean alternate;
  BulletCutter() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=2250;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
    // if (cooldown>100) {
    //   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 5));
    // }
  }
  @Override
    void hold() {
    if (!owner.dead ) {
      float tempA=0, distance=0, velocity=0;
      boolean trigger=false;

      if (cooldown>window) {
        if ( !freeze || owner.freezeImmunity) {

          randX=random(range);
          randY=random(range);

          a+=30*timeBend;

          for (Projectile p : projectiles) {
            if (!p.dead && p.ally!=owner.ally && p instanceof Destroyable && dist(p.x, p.y, owner.cx, owner.cy)<range*.5) {
              //background(owner.playerColor);
              cooldown=0;
              trigger=true;

              if (p instanceof RevolverBullet )velocity=((RevolverBullet)p).v*timeBend;
              if (p instanceof Needle )velocity=((Needle)p).v*timeBend;
              if (p instanceof HomingMissile )velocity=(abs(((HomingMissile)p).vx)+abs(((HomingMissile)p).vy)*timeBend);
              distance=dist(owner.cx, owner.cy, p.x, p.y);
              tempA=calcAngleBetween(p, owner)+180;
            }
          }
        }
        noFill();
        stroke(owner.playerColor, 50);
        strokeWeight(60);
        arc(owner.cx, owner.cy, randX, randY, radians(owner.angle+a), radians(owner.angle+a)+PI*.1);
        stroke(hue(owner.playerColor), saturation(owner.playerColor), brightness(owner.playerColor)+50, 100);
        strokeWeight(50);
        arc(owner.cx, owner.cy, randX, randY, radians(owner.angle+a+20), radians(owner.angle+a+20)+PI*.05);
        stroke(WHITE, 150);
        strokeWeight(40);
        arc(owner.cx, owner.cy, randX, randY, radians(owner.angle+a+30), radians(owner.angle+a+30)+PI*.03);
      }

      if (trigger) {          
        alternate=!alternate;
        if (alternate)projectiles.add( new Slash(owner, int( owner.cx+sin(tempA)*range), int(owner.cy+cos(tempA)*range), 60, owner.playerColor, 140, tempA+5, -15, distance-velocity, sin(tempA)*distance, cos(tempA)*distance, 0, true));
        else      projectiles.add( new Slash(owner, int( owner.cx+sin(tempA)*range), int(owner.cy+cos(tempA)*range), 60, owner.playerColor, 140, tempA-5, +15, distance-velocity, sin(tempA)*distance, cos(tempA)*distance, 0, true));
      }
    }
  }

  @Override
    void release() {
  }
  @Override
    void passive() {
    if (!owner.dead && !freeze || owner.freezeImmunity) {
      cooldown++;
    }
  }
  @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}
class Boost extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int count, charge, cooldown, force=60;
  final int radius= 145, maxCharge=50; 
  Boost() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=2000;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
    // if (cooldown>100) {
    //   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 5));
    // }
  }
  @Override
    void hold() {
    if (charge<=maxCharge)charge++;
  }
  @Override
    void release() {
    if (charge>maxCharge && cooldown>60) {
      cooldown=0;
      charge=0;
      projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 0, 60, owner.playerColor, 350, 0, 1, 60, 12));

      owner.pushForce(force, owner.keyAngle);
      projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 10, 20, owner.playerColor, 450, owner.keyAngle, 1, 30, 10));
    }
    charge=int(charge*.5);
  }
  @Override
    void passive() {
    if (!owner.stealth) {
      noFill();
      stroke(owner.playerColor);
      if (charge>=maxCharge) {
        strokeWeight(3);
        ellipse(owner.cx, owner.cy, radius, radius);
      } else {
        strokeWeight(10);
        arc(owner.cx, owner.cy, radius, radius, -HALF_PI, (PI*2/(maxCharge+1-charge))-HALF_PI);
      }
      cooldown++;
      // count++;
      //  if (count%30==0)   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 3));
    }
  }
  @Override
    void reset() {
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class Glide extends Ability {//---------------------------------------------------    Glide   ---------------------------------

  Glide() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=1000;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
    // if (cooldown>100) {
    //   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 5));
    // }
  }
  @Override
    void hold() {
    owner.pushForce(1, owner.keyAngle);
  }
  @Override
    void release() {
  }
  @Override
    void passive() {
    // owner.pushForce(1,owner.keyAngle);
  }
  @Override
    void reset() {
    // owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}

class Guardian extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int cooldown, maxRange=600;
  float range;
  final int interval=5;
  boolean trigger;
  Guardian() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=1500;
  } 
  @Override
    void action() {
  }
  @Override
    void onHit() {
  }
  @Override
    void hold() {
  }
  @Override
    void release() {
  }
  @Override
    void passive() {
    if (range<maxRange)range+= 1*timeBend;
    if (cooldown>interval) {
      if (!owner.stealth) {     
        noFill();
        strokeWeight(1);
        stroke(WHITE);
        ellipse(owner.cx, owner.cy, range, range);
      }
      for (Projectile p : projectiles) {
        if (!p.dead && p.ally!=owner.ally&& !(p instanceof Shield)&& !(p instanceof Boomerang) && p.damage<30&& dist(owner.cx, owner.cy, p.x, p.y)<range*.5) {
          trigger=true;
          break;
        }
      }
      if (trigger) {
        // owner.slowImmunity=true;
        // particles.add(new TempSlow(1500, 0.03, 1.05));
        // background(owner.playerColor);
        //particles.add(new Flash(100, 5, WHITE));
        strokeWeight(20);
        ellipse(owner.cx, owner.cy, range, range);
        for (Projectile p : projectiles) {
          if (!p.dead &&p.ally!=owner.ally&& !p.meta  && p.damage<30 && dist(owner.cx, owner.cy, p.x, p.y)<range*.5) {
            p.fizzle();
            p.deathTime=stampTime;   // dead on collision
            p.dead=true;
            particles.add(new ShockWave(int(p.x), int(p.y), 20, 80, 20, owner.playerColor));
            range-=p.damage*8;
            projectiles.remove(p);
            break;
          }
        }
        trigger=false;
        cooldown=0;
        // range-=50;
      }
    }
    cooldown++;
  }
  @Override
    void reset() {
    owner.slowImmunity=false;
  }
}
class BulletTime extends Ability {//---------------------------------------------------    BulletTime   ---------------------------------
  float  cooldown;
  final int interval=150, distance=300;
  boolean trigger;
  BulletTime() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=2500;
  } 
  @Override
    void action() {
  }
  @Override
    void onHit() {
  }
  @Override
    void hold() {
  }
  @Override
    void release() {
  }
  @Override
    void passive() {

    if (cooldown>interval) {
      for (Projectile p : projectiles) {
        if (!p.dead && p.ally!=owner.ally && !(p instanceof Shield) && dist(owner.cx, owner.cy, p.x, p.y)<distance) {
          trigger=true;
          break;
        }
      }
      if (trigger) {
        fill(owner.playerColor);
        noStroke();
        ellipse(owner.cx, owner.cy, distance*1.5, distance*1.5);
        owner.slowImmunity=true;
        particles.add(new TempSlow(1500, 0.03, 1.05));
        trigger=false;
        cooldown=0;
      }
    }
    cooldown+= 1*timeBend;
  }
  @Override
    void reset() {
    owner.slowImmunity=false;
  }
}
class Adrenaline extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  int cooldown;
  final int interval=300;
  boolean trigger;
  Adrenaline() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=2500;
  } 
  @Override
    void action() {
    if (fastForward||timeBend>1)owner.health++;
  }
  @Override
    void onHit() {
    if (fastForward||timeBend>1) {
      owner.health++;

      for (Ability a : owner.abilityList)a.energy+=2;
    }
  }
  @Override
    void hold() {
  }
  @Override
    void release() {
  }
  @Override
    void passive() {
    if (fastForward)owner.armor=100;
    else owner.armor=int(owner.DEFAULT_ARMOR);

    if (cooldown>interval) {
      /* for (Projectile p : projectiles) {
       if (!p.dead && p.ally!=owner.ally && dist(owner.cx, owner.cy, p.x, p.y)<200) {
       trigger=true;
       break;
       }
       }*/
      for (Player p : players) {
        if (!p.dead && p.ally!=owner.ally && dist(owner.cx, owner.cy, p.cx, p.cy)<200) {
          trigger=true;
          break;
        }
      }
      if (trigger) {
        // owner.fastforwardImmunity=true;
        particles.add(new TempFast(2500, 2, 0.995));
        trigger=false;
        cooldown=0;
      }
    }
    cooldown++;
  }
  @Override
    void reset() {
    // owner.fastforwardImmunity=false;
  }
}

class Emergency extends Ability {//---------------------------------------------------    Emergency   ---------------------------------

  final int interval=1000;
  int cooldown=interval;
  float percent=0.5;
  boolean trigger;
  Emergency() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=2750;
  } 
  @Override
    void action() {
  }
  @Override
    void onHit() {
  }
  @Override
    void hold() {
  }
  @Override
    void release() {
  }
  @Override
    void passive() {

    if (cooldown>interval && owner.health<owner.maxHealth*percent) {
      if (!owner.stealth) { 
        fill(owner.playerColor);
        noStroke();
        ellipse(owner.cx, owner.cy, 250, 250);
        stroke(1);
      }
      for (Projectile p : projectiles) {
        if (!p.dead && p.ally!=owner.ally && dist(owner.cx, owner.cy, p.x, p.y)<250 && owner.health<=p.damage) {
          trigger=true;
          break;
        }
      }
      if (trigger) {
        owner.freezeImmunity=true;
        particles.add(new Flash(100, 8, WHITE));  

        //particles.add(new TempSlow(1500, 0.03, 1.05));
        for (int i =0; i<3; i++) {
          particles.add( new Feather(300, int(owner.cx), int(owner.cy), random(-2, 2), random(-2, 2), 25, owner.playerColor));
        }
        particles.add( new TempFreeze(4500));
        trigger=false;
        cooldown=0;
      }
    }
    if (!freeze)cooldown++;
  }
  @Override
    void reset() {
    cooldown=interval;
    owner.freezeImmunity=false;
  }
}
class Redemption extends Ability {//---------------------------------------------------    Redemption   ---------------------------------

  final int interval=1000;
  int cooldown=interval;
  float percent=1.0;
  boolean trigger;
  Redemption() {
    super();
    name=getClassName(this);
    unlockCost=2750;
  } 
  @Override
    void action() {
  }
  @Override
    void onHit() {
  }
  @Override
    void hold() {
  }
  @Override
    void release() {
  }
  @Override
    void passive() {

    if (cooldown>interval ) {//&& owner.health<owner.maxHealth*percent

      if (!owner.stealth) { 
        //nofill(owner.playerColor);
        noFill();
        stroke(owner.playerColor);
        ellipse(owner.cx, owner.cy, 250, 250);
        strokeWeight(1);
      }
      for (Projectile p : projectiles) {
        if (!p.dead && p.ally!=owner.ally && dist(owner.cx, owner.cy, p.x, p.y)<250 && owner.health<=p.damage) {
          trigger=true;
          break;
        }
      }
      if (trigger) {
        particles.add(new Flash(100, 8, WHITE));  
        shakeTimer+=20;
        particles.add( new TempReverse(2000));
        trigger=false;
        cooldown=0;
      }
    }
    if (!freeze)cooldown++;
  }
  @Override
    void reset() {
    cooldown=interval;
    //owner.freezeImmunity=false;
  }
}
class Undo extends Ability {//---------------------------------------------------    Undo   ---------------------------------

  final int interval=300, delay=400;
  int cooldown=interval, triggerDiff=10;
  long timer;
  float percent=1.0, tempHealth;
  boolean trigger;
  Undo() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=2750;
  } 
  @Override
    void action() {
  }

  @Override
    void hold() {
  }
  @Override
    void release() {
  }
  @Override
    void onHit() {
    if (!trigger && cooldown>interval) {//&& owner.health<owner.maxHealth*percent
      if (owner.health+triggerDiff<tempHealth) { 
        trigger=true; 
        timer=stampTime;
        particles.add(new Flash(100, 4, owner.playerColor));  
        // for (int i =0; i<10; i++) {
        particles.add( new Feather(300, int(owner.cx), int(owner.cy), random(-2, 2), random(-2, 2), 200, owner.playerColor));
        //  }
        particles.add( new  Particle(int(owner.cx), int(owner.cy), 0, 0, int(owner.w), 350, color(255, 0, 255)));
      }
    }
  }
  @Override
    void passive() {

    if (trigger) {
      if (timer+delay<stampTime) {
        shakeTimer+=10;
        particles.add( new TempReverse(1200));
        trigger=false;
        cooldown=0;
        timer=millis();
      }
    }

    if (!trigger && cooldown>interval ) { 
      if (!owner.stealth) { 
        fill(owner.playerColor);
        noStroke();
        ellipse(owner.cx, owner.cy, 150, 150);
        stroke(1);
      }
      tempHealth=owner.health;
    } else if (!freeze) cooldown++;
  }
  @Override
    void reset() {
    cooldown=interval;
    //owner.freezeImmunity=false;
  }
}

class Dash extends Ability {//---------------------------------------------------    bullet   ---------------------------------
  //int count;
  final int radius= 125, maxCharge=20; 
  float cooldown, charge;
  long timer;
  Dash() {
    super();
    type=AbilityType.PASSIVE;
    name=getClassName(this);
    unlockCost=2000;
  } 
  @Override
    void action() {
  }
  @Override
    void press() {
    // if (cooldown>100) {
    //   projectiles.add( new Needle(owner, int( owner.cx+cos(radians(owner.angle))*owner.w), int(owner.cy+sin(radians(owner.angle))*owner.w), 60, owner.playerColor, 800, owner.angle, cos(radians(owner.angle))*46, sin(radians(owner.angle))*46, 5));
    // }
  }
  @Override
    void hold() {
    if (charge<=maxCharge)  charge+=1*timeBend;
  }
  @Override
    void release() {
    if (charge>maxCharge && cooldown>20) {
      timer=stampTime;
      cooldown=0;
      charge=0;
      //projectiles.add( new  Blast(owner, int( owner.cx), int(owner.cy), 0, 50, owner.playerColor, 350, 0, 1, 10));
      owner.stealth=true;
      owner.pushForce(50, owner.keyAngle);
    }
    charge=int(charge*.5);
  }
  @Override
    void passive() {
    if (timer+60*timeBend<stampTime) {
      if (owner.stealth) {
        owner.stop(); 
        Player p=seek(owner, 4000, TARGETABLE);
        if (p!=null) {
          owner.angle=calcAngleBetween(p, owner);
        }
        owner.keyAngle=owner.angle;
      }
      owner.stealth=false;
    } else particles.add(new Particle(int(owner.cx), int(owner.cy), owner.vx*.2, owner.vy*.2, 120, 50, WHITE));
    if (timer+60*timeBend<stampTime && timer+300*timeBend>stampTime) {
      owner.ANGLE_FACTOR=0;
    } else {
      owner.ANGLE_FACTOR=owner.DEFAULT_ANGLE_FACTOR;
    }

    if (!owner.stealth) {

      stroke(owner.playerColor);
      if (charge>=maxCharge) {
        strokeWeight(3);
        fill(WHITE);
        ellipse(owner.cx, owner.cy, radius, radius);
      } else {
        strokeWeight(10);
        noFill();
        arc(owner.cx, owner.cy, radius, radius, -HALF_PI, (PI*2/(maxCharge+1-charge))-HALF_PI);
      }
      cooldown+=1*timeBend;
    }
  }
  @Override
    void reset() {
    owner.stealth=false;
    owner.MAX_ACCEL=owner.DEFAULT_MAX_ACCEL;
  }
}
/*class RandomPassive extends Ability {//---------------------------------------------------    RandomPassive   ---------------------------------
 
 RandomPassive() {
 super();
 } 
 Ability randomize() {
 Ability rA=null;
 try {
 rA = passiveList[int(random(passiveList.length))].clone();
 }
 catch(CloneNotSupportedException e) {
 println("not cloned from Random Passive");
 }
 return rA;  // clone it
 }
 }*/