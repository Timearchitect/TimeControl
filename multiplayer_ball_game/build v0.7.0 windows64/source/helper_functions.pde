 enum AbilityType {
  ACTIVE, PASSIVE,NATIVE,GLOBAL
}
 enum GameType {
  BRAWL, SURVIVAL,PUZZLE
}

void targetHommingVarning(Player target) {
  final int r=130;
  float tcx=target.cx, tcy=target.cy;
  strokeWeight(2);
  stroke(255);
  noFill();
  ellipse(tcx, tcy, r, r);
  line(tcx+r, tcy, tcx-r, tcy);
  // line(tcx, tcy, tcx+r, tcy);
  line(tcx, tcy+r, tcx, tcy-r);
  // line(tcx, tcy, tcx, tcy+r);
}


void crossVarning(int x, int y) {
  final int r=40;
  // float tcx=target.cx, tcy=target.cy;
  strokeWeight(3);
  stroke(255);
  noFill();
  //ellipse(tcx, tcy, r, r);
  line(x+r, y+r, x-r, y-r);
  //line(tcx, tcy, tcx+r, tcy);
  line(x+r, y-r, x-r, y+r);
  //line(tcx, tcy, tcx, tcy+r);
  strokeWeight(6);
  ellipse(x, y, r*4, r*4);
  strokeWeight(3);
  ellipse(x, y, r*5, r*5);
}

static float angleAgainst(int x, int y, int x2, int y2) {
  //return  degrees(-( atan((y2-y)/(x2-x))));
  return  degrees(atan2(y2-y, x2-x));
}

Player seek(Player m, int senseRange) {
  for (int sense = 0; sense < senseRange; sense++) {
    for (   Player p : players) {
      if (p!= m && !p.dead && p.ally!=m.ally) {
        if (dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
          return p;
        }
      }
    }
  }
  return null;
}  
static float  calcAngleBetween(Player target, Player from) {
  return degrees(atan2((target.cy-from.cy), (target.cx-from.cx)))%360;
}
static float  calcAngleBetween(Projectile target, Projectile from) {
  return degrees(atan2((target.y-from.y), (target.x-from.x)))%360;
}

static float  calcAngleBetween(Projectile target, Player from) {
  return degrees(atan2((target.y-from.cy), (target.x-from.cx)))%360;
}

static float  calcAngleBetween(Player target, Projectile from) {
  return degrees(atan2((target.cy-from.y), (target.cx-from.x)))%360;
}


void generateRandomAbilities(int index, AbilityType _abilityType) {
  for (Player p : players) {      
    if (p!=AI && !p.clone &&  !p.turret) {  // no turret or clone weapon switch
      p.abilityList.get(index).reset();
      p.abilityList.set(index, (_abilityType==AbilityType.ACTIVE)?new Random().randomize():new RandomPassive().randomize());

      //abilities[i].owner=players.get(i);
      p.abilityList.get(index).setOwner(p);
      //p.ability= p.abilityList.get(0);
      announceAbility( p, index);
    }
  }
}