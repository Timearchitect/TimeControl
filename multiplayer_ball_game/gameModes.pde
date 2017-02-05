
ArrayList<Spawner> spawnList= new ArrayList<Spawner>();
boolean gameOver;
int survivalTime;
//   projectiles.add( new AbilityPack(AI,new Random().randomize(),  int( owner.cx+cos(radians(owner.angle))*owner.w*2), int(owner.cy+sin(radians(owner.angle))*owner.w*2), 100, AI.playerColor, 60000, 0, 0, 0, 0, true));

void spawningSetup() {
  spawnList.add(new Spawner(new Object[]{new HealBall(AI, halfWidth, halfHeight, 60, WHITE, 20000, 0, 0, 0, 50, true)}
    , 8000, 10000*DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 100/DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random().randomize(abilityList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 60000, 0, 0, 0, 0, true)}
    , 5000, 0, true, 1));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random().randomize(abilityList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 60000, 0, 0, 0, 0, true)}
    , 5000, 0, true, 1));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random().randomize(abilityList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 60000, 0, 0, 0, 0, true)}
    , 5000, 0, true, 1));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random().randomize(abilityList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 60000, 0, 0, 0, 0, true)}
    , 5000, 0, true, 1));
  /*  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.5), int(playerSize*0.5), 10, 150, 1, new Bazooka())}
   , 1000));*/
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.5), int(playerSize*0.5), 10, 30, 2, new Suicide())}
    , 1000, 10000/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 20*DIFFICULTY_LEVEL));
  /*  spawnList.add(new Spawner(new Object[]{new HomingMissile(AI, halfWidth, halfHeight, 50, GREY, 2000, 0, 0, 0, 10), new HomingMissile(AI, halfWidth, halfHeight, 50, BLACK, 2000, 0, 0, 0, 10)}
   , 1000, 100, halfWidth, halfHeight, false, 100));*/

  spawnList.add(new Spawner(new Object[]{ new Bomb(AI, halfWidth, halfHeight, 200, BLACK, 1500, 0, 0, 0, 30, false)}
    , 2000, 1500/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 200*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new HomingMissile(AI, halfWidth, halfHeight, 50, BLACK, 2000, 0, 0, 0, 10)}
    , 5000, 800/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 10*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new HomingMissile(AI, halfWidth, halfHeight, 50, BLACK, 2000, 0, 0, 0, 10), new HomingMissile(AI, halfWidth, halfHeight, 50, BLACK, 2000, 0, 0, 0, 10)}
    , 15000, 1000/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 20*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{ new Bomb(AI, halfWidth, halfHeight, 100, BLACK, 5000, 0, 0, 0, 50, false)}
    , 30000, 1200/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 200*DIFFICULTY_LEVEL));
  /*spawnList.add(new Spawner(new Object[]{new  Missle(AI, halfWidth, halfHeight, 50, BLACK, 2000, 1, 1, 1, 40, true)}
   , 30000, 2000, halfWidth, halfHeight, true, 5));
   */
  spawnList.add(new Spawner(new Object[]{new HomingMissile(AI, halfWidth, halfHeight, 50, BLACK, 2000, 0, 0, 0, 10), new HomingMissile(AI, halfWidth, halfHeight, 50, BLACK, 2000, 0, 0, 0, 10)}
    , 15000, 100/DIFFICULTY_LEVEL, halfWidth, halfHeight, false, 50*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.5), int(playerSize*0.5), 10, 100, 1, new AutoGun())}
    , 20000, 4000/DIFFICULTY_LEVEL, true, 10*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new Drone(players.size(), halfWidth, halfHeight, int(playerSize*0.5), int(playerSize*0.5), 10, 200, new AutoGun())}
    , 35000, 12000/DIFFICULTY_LEVEL, true, 3*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new Turret(players.size(), AI, halfWidth, halfHeight, playerSize, playerSize, 50, new TimeBomb())}
    , 55000, 14000/DIFFICULTY_LEVEL, true, 5*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.5), int(playerSize*0.5), 10, 50, 1, new Pistol())}
    , 70000, halfWidth, halfHeight));
  spawnList.add(new Spawner(new Object[]{new Turret(players.size(), AI, halfWidth, halfHeight, playerSize, playerSize, 100, new Bazooka())}
    , 85000, 15000/DIFFICULTY_LEVEL, true, 3*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.5), int(playerSize*0.5), 10, 60, 2, new Suicide())}
    , 90000, 8000/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 30));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.5), int(playerSize*0.5), 10, 150, 1, new SemiAuto())}
    , 120000, 10000/DIFFICULTY_LEVEL, true, 5*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.5), int(playerSize*0.5), 10, 150, 1, new Pistol())}
    , 130000, 10000/DIFFICULTY_LEVEL, true, 3*DIFFICULTY_LEVEL));
}



void spawningReset() {

  stamps.clear();  
  survivalTime=0;
  gameOver=false;

  projectiles.clear();
  particles.clear(); 
  spawnList.clear();
    forwardTime=0;
  reversedTime=0;
  freezeTime=0;
  fallenTime=0;
  stampTime=0;
  for (int i=players.size()-1; i>= AmountOfPlayers; i--) {
    players.remove(i);
  }   
  for (Player p : players)  p.ally=0;
  players.add(AI);

  spawningSetup();
  particles.add(new  Text("Survival", 200, halfHeight, 5, 0, 100, 0, 10000, BLACK, 0) );
  particles.add(new Gradient(10000, 0, 500, 0, 0, 500, 0.5, 0, GREY));
  /*for (Spawner s : spawnList) {
   s.dead=false;
   s.times=s.initTimes;
   }*/
  if (!noFlash) background(255);
}
void survivalSpawning() {
  if (!gameOver) for (Spawner s : spawnList)  s.update();
}


class Spawner {

  Object object[];
  long startTime, timer;
  int x, y;
  float times, interval, initTimes;
  boolean repeat, random, dead;

  <G> Spawner(G _object[], long _startTime, float _interval, int _x, int _y, boolean _random, float _times) {
    object=_object;
    startTime=_startTime;
    interval=_interval;
    timer=stampTime;
    initTimes=int(_times);
    random=_random;
    x=_x;
    y=_y;
    times=int(_times);
    if (times>0)repeat=true;
  }
  <G> Spawner(G _object[], long _startTime, float _interval, boolean _random, float _times) {
    object=_object;
    startTime=_startTime;
    interval=_interval;
    random=_random;
    timer=stampTime;
    initTimes=int(_times);
    times=int(_times);
    if (times>0)repeat=true;
  }
  <G> Spawner(G _object[], long _startTime, int _x, int _y) {
    object=_object;
    startTime=_startTime;
    x=_x;
    y=_y;
  }
  <G> Spawner(G _object[], long _startTime) {
    object=_object;
    startTime=_startTime;
  }

  void update() {
    if (!dead && stampTime>startTime ) {
      if (repeat) {
        if (timer+interval<stampTime) {
          times--;
          timer=stampTime;
          //println("times"+times);

          if (times<1) {
            dead=true;          
            // println("dead");
          }
          try {
            spawn();
          }
          catch(Exception e) {
            println(e);
          }
        }
      } else {
        try {
          spawn();
          dead=true;
          //  println("dead");
        }
        catch(Exception e) {
          println(e);
        }
      }
    }
  }

  void  spawn() throws Exception {
    //println("SPAWN");


    for (Object o : object) {
      if (random) {
        x=int(random(width));
        y=int(random(height));
      }


      if ( o instanceof Projectile) {
        particles.add(new ShockWave(x, y, 20, 16, 150, AI.playerColor));
        Projectile temp=((Projectile)o).clone();
        temp.deathTime=stampTime+(temp.deathTime-temp.spawnTime);
        temp.spawnTime=startTime;
        temp.x=x;
        temp.y=y;
        projectiles.add(temp);
        /*((Projectile)o).spawnTime+=startTime;
         ((Projectile)o).deathTime+=startTime;
         ((Projectile)o).x=x;
         ((Projectile)o).y=y;*/
        //projectiles.add( ((Projectile)o).clone());
      } else if ( o instanceof Player) {
        particles.add(new ShockWave(x, y, 40, 26, 350, AI.playerColor));
        Player temp = ((Player)o).clone();
        temp.cx=x;
        temp.cy=y;
        temp.x=x-temp.radius;
        temp.y=x-temp.radius;
        players.add(temp);
        /*((Player)o).cx=x;
         ((Player)o).cy=y;
         ((Player)o).x=x;
         ((Player)o).y=y;
         players.add(((Player)o).clone());*/
      } else if ( o instanceof Particle) {
        ((Particle)o).x=x;
        ((Particle)o).y=y;
        particles.add(((Particle)o).clone());
      }
    }
  }
}


<G> void  spawn(G object, int x, int y) {
  if ( object instanceof Projectile) {
    ((Projectile)object).x=x;
    ((Projectile)object).y=y;
    projectiles.add((Projectile)object);
  } else if ( object instanceof Player) {
    ((Player)object).cx=x;
    ((Player)object).cy=y;
    players.add((Player)object);
  } else if ( object instanceof Particle) {
    ((Particle)object).x=x;
    ((Particle)object).y=y;
    particles.add(((Particle)object).clone());
  }
}


<G> void  spawn(G object) {
  if ( object instanceof Projectile) {
    projectiles.add((Projectile)object);
  } else if ( object instanceof Player) {
    players.add(((Player)object).clone());
  } else if ( object instanceof Particle) {
    particles.add(((Particle)object).clone());
  }
}