enum AbilityType {
  ACTIVE, PASSIVE, NATIVE, GLOBAL
}
enum GameType {
  BRAWL, SURVIVAL, PUZZLE, WILDWEST, SHOP, MENU, BOSSRUSH, SETTINGS
}
static String getClassName(Object o) {
  return o.getClass().getSimpleName();
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
Player seek(Projectile m, int senseRange) {
  for (int sense = 0; sense < senseRange; sense++) {
    for (   Player p : players) {
      if ( !p.dead && p.ally!=m.ally) {
        if (dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
          return p;
        }
      }
    }
  }
  return null;
}  
//final int TARGETABLE=0,STATIONARY=1,INVIS=2,STEALTH=3;
Player seek(Player m, int senseRange, int attributeIndex) {
  switch (attributeIndex) {
  case 0:
    for (int sense = 0; sense < senseRange; sense++) {
      for (   Player p : players) {
        if (p!= m && !p.dead && p.ally!=m.ally) {
          if (p.targetable && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
            return p;
          }
        }
      }
    }
    break;
  case 1:
    for (int sense = 0; sense < senseRange; sense++) {
      for (   Player p : players) {
        if (p!= m && !p.dead && p.ally!=m.ally) {
          if (p.stationary && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
            return p;
          }
        }
      }
    }
    break;
  case 2:
    for (int sense = 0; sense < senseRange; sense++) {
      for (   Player p : players) {
        if (p!= m && !p.dead && p.ally!=m.ally) {
          if (p.invis && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
            return p;
          }
        }
      }
    }
    break;
  case 3:
    for (int sense = 0; sense < senseRange; sense++) {
      for (   Player p : players) {
        if (p!= m && !p.dead && p.ally!=m.ally) {
          if (p.stealth && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
            return p;
          }
        }
      }
    }
    break;
  }
  return null;
}  
Player seek(Projectile m, int senseRange, int attributeIndex) {
  switch (attributeIndex) {
  case 0:
    for (int sense = 0; sense < senseRange; sense++) {
      for (   Player p : players) {
        if ( !p.dead && p.ally!=m.ally) {
          if (p.targetable && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
            return p;
          }
        }
      }
    }
    break;
  case 1:
    for (int sense = 0; sense < senseRange; sense++) {
      for (   Player p : players) {
        if (!p.dead && p.ally!=m.ally) {
          if (p.stationary && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
            return p;
          }
        }
      }
    }
    break;
  case 2:
    for (int sense = 0; sense < senseRange; sense++) {
      for (   Player p : players) {
        if ( !p.dead && p.ally!=m.ally) {
          if (p.invis && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
            return p;
          }
        }
      }
    }
    break;
  case 3:
    for (int sense = 0; sense < senseRange; sense++) {
      for (   Player p : players) {
        if (  !p.dead && p.ally!=m.ally) {
          if (p.stealth && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
            return p;
          }
        }
      }
    }
    break;
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

void generateRandomAbilities(int index, Ability[] list, boolean noEmpty) {
  for (Player p : players) {      
    if (p!=AI && !p.clone &&  !p.turret) {  // no turret or clone weapon switch
      if (p.abilityList.size()-1>=index) {
        p.abilityList.get(index).reset();
        p.abilityList.set(index, new Random(noEmpty).randomize(list));
        p.abilityList.get(index).setOwner(p);
        announceAbility( p, index);
      }
    }
  }
}
void playerSetup() {
  for (int i=0; i< AmountOfPlayers; i++) {
    try {
      players.add(new Player(i, color((255/AmountOfPlayers)*i, 255, 255), int(random(width-playerSize*1)+playerSize), int(random(height-playerSize*1)+playerSize), playerSize, playerSize, playerControl[i][0], playerControl[i][1], playerControl[i][2], playerControl[i][3], playerControl[i][4], abilities[i]));
      if (!perSelectedSkills) {               
        generateRandomAbilities(1, passiveList, true);
        generateRandomAbilities(0, abilityList, true);
      }
      if (players.get(i).mouse)players.get(i).FRICTION_FACTOR=0.11; //mouse
    }
    catch(Exception e ) {
      println(e +"player setup");
    }
  }
  for (int i=0; i< startBalls; i++) {
    projectiles.add(new Ball(int(random(width-ballSize)+ballSize*0.5), int(random(height-ballSize)+ballSize*0.5), int(random(20)-10), int(random(20)-10), int(random(ballSize)+10), color(random(255), 0, 0)));
  }
}
void controllerSetup() {
  println("amount of serial ports: "+Serial.list().length);
  for (int i=0; i<Serial.list ().length; i++) {
    portName[i] = Serial.list()[i];   // du kan också skriva COM + nummer på porten   
    port[i] = new Serial(this, portName[i], baudRate);   // du måste ha samma baudrate t.ex 9600
    println(" port " +port[i].available(), " avalible");
    println(portName[i]);
    players.get(i).MAX_ACCEL=0.16;
    players.get(i).DEFAULT_MAX_ACCEL=0.16;
    players.get(i).arduino=true;
    players.get(i).FRICTION_FACTOR=0.062;
  }
}

/*static <T extends Object> boolean  existInList(Class<?> compareType, ArrayList<T> list) {
  T temp;
  Class classType=temp.getClass(); 
  for (classType i : (ArrayList<classType>)list) {
    if (i instanceof P) {
      println("have it");
      return true;
    }
  }
  return false;
}
*/

/*public static <T extends Buff> boolean existInList( Class<T> classType,ArrayList<T> list) {

  for (classType i : (ArrayList<classType>)list) {
  }
  return true;
}*/


    public static <T,C,L> boolean existInList(Class<T> genericType,ArrayList<L> list,Class<C> genericType2){
     String s=getClassName(genericType2);
     println(s);
      for(T i:(ArrayList<T>)list){
        if(((Buff)i).name.equals("Poison"))return true;
      }
      return false;
    }