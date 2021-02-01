final float PI_QUARTER=PI+QUARTER_PI, PI_HALF=PI+HALF_PI;

enum BuffType {
  ONCE, MULTIPLE
}
enum AbilityType {
  ACTIVE, PASSIVE, NATIVE, GLOBAL
}
enum GameType {
  BRAWL, HORDE, SURVIVAL, PUZZLE, WILDWEST, SHOP, MENU, BOSSRUSH, SETTINGS
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
  line(tcx, tcy+r, tcx, tcy-r);
}
void titleDisplay(GameType _gameMode) {
  particles.add(new Text(_gameMode.toString(), 200, halfHeight, 10, 0, 100, 0, 3000, BLACK, 0) );
  particles.add(new Gradient(8000, -400, 500, 0, 0, 500, 0.5, 0, GREY));
}
float  crit(Player owner, float precent, float damage) {
  if (precent>random(100)) {
    particles.add(new Flash(5, 32, WHITE));  
    fill(WHITE);
    stroke(owner.playerColor);
    strokeWeight(8);
    triangle(owner.cx+random(50)-150, owner.cy+random(50)-25, owner.cx+random(50)+100, owner.cy+random(50)-25, owner.cx+random(50)-50, owner.cy+random(50)+75);
    particles.add(new Fragment(int(owner.cx), int(owner.cy), 0, 0, 40, 10, 500, 100, owner.playerColor) );
    return  damage;
  }
  return 0;
}
float  crit(color c, Player target, float precent, float damage) {
  if (precent>random(100)) {
    particles.add(new Flash(5, 32, WHITE));  
    fill(WHITE);
    stroke(c);
    strokeWeight(8);
    triangle(target.cx+random(50)-150, target.cy+random(50)-25, target.cx+random(50)+100, target.cy+random(50)-25, target.cx+random(50)-50, target.cy+random(50)+75);
    particles.add(new Fragment(int(target.cx), int(target.cy), 0, 0, 40, 10, 500, 100, target.playerColor) );
    return  damage;
  }
  return 0;
}
void crossVarning(int x, int y) {
  final int r=40;
  // float tcx=target.cx, tcy=target.cy;
  strokeWeight(3);
  stroke(255);
  noFill();
  line(x+r, y+r, x-r, y-r);
  line(x+r, y-r, x-r, y+r);
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
  for (int sense = 0; sense < senseRange; sense+=5) { // interval 3
    for (   Player p : players) {
      if (p!= m && !p.dead && p.ally!=m.ally) {
        if (dist(p.x, p.y, m.x, m.y)<sense*.5) {  
          return p;
        }
      }
    }
  }
  return null;
}  
Player seek(Projectile m, int senseRange) {
  for (int sense = 0; sense < senseRange; sense+=5) { // interval 3
    for (   Player p : players) {
      if ( !p.dead && p.ally!=m.ally) {
        if (dist(p.x, p.y, m.x, m.y)<sense*.5) {  
          return p;
        }
      }
    }
  }
  return null;
}  
//final int TARGETABLE=0,STATIONARY=1,INVIS=2,STEALTH=3;
Player seek(Player m, int senseRange, int attributeIndex) {

  for (int sense = 0; sense < senseRange; sense+=5) { //interval 5
    for (   Player p : players) {
      if (p!= m && !p.dead && p.ally!=m.ally) {
        switch (attributeIndex) {
        case 0: //TARGETABLE
          if (p.targetable && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
            return p;
          }
          break;
        case 1: //STATIONARY
          if (p.stationary && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
            return p;
          }
          break;
        case 2: //INVIS
          if (p.invins && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
            return p;
          }
          break;
        case 3://STEALTH
          if (p.stealth && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
            return p;
          }
          break;
        }
      }
    }
  }
  return null;
}  
Player seek(Projectile m, int senseRange, int attributeIndex) {
  switch (attributeIndex) {
  case 0:
    for (int sense = 0; sense < senseRange; sense++) {
      for (   Player p : players) {
        if ( !p.dead && p.ally!=m.ally) {
          switch (attributeIndex) {
          case 0:
            if (p.targetable && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
              return p;
            }
            break;
          case 1:
            if (p.stationary && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
              return p;
            }
            break;
          case 2:
            if (p.invins && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
              return p;
            }
            break;
          case 3:
            if (p.stealth && dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
              return p;
            }
            break;
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

static float  calcAngleBetween(float x, float y, float x2, float y2) {
  return degrees(atan2((y-y2), (x-x2)))%360;
}
static float  calcAngleBetween(Projectile target, Player from) {
  return degrees(atan2((target.y-from.cy), (target.x-from.cx)))%360;
}

static float  calcAngleBetween(Player target, Projectile from) {
  return degrees(atan2((target.cy-from.y), (target.cx-from.x)))%360;
}
static float calcAngleFromBlastZone(float x, float y, float px, float py) {
  //    double deltaY = py - y;
  //   double deltaX = px - x;
  return (float)Math.atan2(py - y, px - x) * 180 / PI;
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
      if (!preSelectedSkills) {               
        generateRandomAbilities(1, passiveList, true);
        generateRandomAbilities(0, abilityList, true);
      } /*else {
       for(int j=0;j<abilityList[i].length; j++){
       players.get(j).abilityList.add(abilities[i][j]);
       }
       }*/
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
public static <C, L> boolean existInList(ArrayList<L> list, Class<C> genericType2) {
  for (L i : (ArrayList<L>)list) {
    if (i.getClass().getSimpleName().equals(genericType2.getSimpleName()))return true;
  }
  return false;
}

Projectile mergePayload( Projectile p, Containable[] c) {
  Container s = (Container)p;
  Containable[] payload = c;
  for (Containable pay : payload)pay.parent((Container)p);
  s.contains(payload);
  return (Projectile)s;
}
void initSound(SamplePlayer sp) {
 // g.addInput(sp);
  gainSoundeffect.addInput(sp);
  // gainSoundeffect.addInput(sp);
  sp.setLoopType(SamplePlayer.LoopType.NO_LOOP_FORWARDS);
  sp.setKillOnEnd(false);
  sp.pause(true);
}
void play(SamplePlayer sp) {
  sp.reTrigger();
  //sp.reset();
  //sp.setPosition(0);
  sp.start(0);
}


class QuadTree {
  int x, y, w, h;
  byte capacity;
  PVector[] points;
  boolean divided;
  QuadTree northWest, northEast, southWest, southEast;

  QuadTree(int _x, int _y, int _w, int _h) {
    x=_x;
    y=_y;
    w=_w;
    h=_h;
  }
  void show() {
    noFill();
    rect(x, y, w, h);
  }
  void subdivide() {
    int hw=int(w*0.5f), hh=int(h*0.5f);
    northWest= new QuadTree(0, 0, hw, hh);
    northEast= new QuadTree(hw, 0, hw, hh);
    southWest= new QuadTree(0, hh, hw, hh);
    southEast= new QuadTree(hw, hh, hw, hh);
  }
  void insert( PVector p) {
    if (p.x>x  && p.x< x+w &&p.y > y&& p.y < y+h ) {
      if (points.length > capacity) {
        subdivide();
      }
    }
  }
}
