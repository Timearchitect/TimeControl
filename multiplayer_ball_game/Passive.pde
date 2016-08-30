class HpRegen extends Ability {//---------------------------------------------------    HpRegen   ---------------------------------
  float regenRate = 1;
  int count;
  HpRegen() {
    super();
    name=getClassName(this);
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
      if (count%10==0 && owner.maxHealth>owner.health)owner.health += regenRate;
    }
  }
  @Override
    void reset() {
    // super.reset();
  }
}

class Armor extends Ability {//---------------------------------------------------    HpRegen   ---------------------------------
  // float regenRate = 1;
  int armorAmount=6;
  Armor() {
    super();
    name=getClassName(this);
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
    name=getClassName(this);
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
  float dragForce =-0.3;
  Gravitation() {
    super();
    name=getClassName(this);
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
    dragPlayersInRadius(300, false);
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
      for (int i=0; i<players.size (); i++) { 
        if (!players.get(i).dead &&(players.get(i)!= owner || friendlyFire)) {
          if (dist(owner.cx, owner.cy, players.get(i).cx, players.get(i).cy)<range) {
            players.get(i).pushForce(dragForce*timeBend, calcAngleFromBlastZone(owner.cx, owner.cy, players.get(i).cx, players.get(i).cy));
            // if (count%10==0)players.get(i).hit(damage);
          }
        }
      }
    }
  }
}
class Repel extends Ability {//---------------------------------------------------    Gravitation   ---------------------------------
  float dragForce =0.5;
  Repel() {
    super();
    name=getClassName(this);
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
    dragPlayersInRadius(300, false);
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
        if (!p.dead &&(p!= owner || friendlyFire)) {
          if (dist(owner.cx, owner.cy, p.cx, p.cy)<range) {
            p.pushForce(dragForce*timeBend, calcAngleFromBlastZone(owner.cx, owner.cy, p.cx, p.cy));
            // if (count%10==0)players.get(i).hit(damage);
          }
        }
      }
    }
  }
}



class RandomPassive extends Ability {//---------------------------------------------------    RandomPassive   ---------------------------------

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
}