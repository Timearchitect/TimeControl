
ArrayList<Spawner> spawnList= new ArrayList<Spawner>();
void spawningSetup() {
  spawnList.add(new Spawner(new Object[]{new HomingMissile(AI, halfWidth, halfHeight, 50, BLACK, 2000, 0, 0, 0, 10)}
    , 5000, 500, halfWidth, halfHeight, true, 5));

  spawnList.add(new Spawner(new Object[]{new HomingMissile(AI, halfWidth, halfHeight, 50, BLACK, 2000, 0, 0, 0, 10)}
    , 15000, 500, halfWidth, halfHeight, true, 5));

  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1.5), int(playerSize*1.5), 10, 200, 1, new AutoGun())}
    , 10000, 2000, true, 10));

  spawnList.add(new Spawner(new Object[]{new Drone(players.size(), halfWidth, halfHeight, int(playerSize*1.5), int(playerSize*1.5), 10, 300, new AutoGun())}
    , 25000, 5000, true, 3));
}
void spawningReset() {
  for (Spawner s : spawnList) {
    s.dead=false;
  }
}
void survivalSpawning() {

  for (Spawner s : spawnList) {
    s.update();
  }
}


class Spawner {

  Object object[];
  long startTime, timer;
  int x, y, interval, times;
  boolean repeat, random, dead;

  <G> Spawner(G _object[], long _startTime, int _interval, int _x, int _y, boolean _random, int _times) {
    object=_object;
    startTime=_startTime;
    interval=_interval;
    timer=stampTime;
    
    random=_random;
    x=_x;
    y=_y;
    times=_times;
    if (times>0)repeat=true;
  }
  <G> Spawner(G _object[], long _startTime, int _interval, boolean _random, int _times) {
    object=_object;
    startTime=_startTime;
    interval=_interval;
    random=_random;
    timer=stampTime;
    times=_times;
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
          println("times"+times);

          if (times<1) {
            dead=true;          
            println("dead");
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
          println("dead");
        }
        catch(Exception e) {
          println(e);
        }
      }
    }
  }

  void  spawn() throws Exception {
    println("SPAWN");
    if (random) {
      x=int(random(width));
      y=int(random(height));
    }


    for (Object o : object) {
      if ( o instanceof Projectile) {
        ((Projectile)o).spawnTime+=startTime;
        ((Projectile)o).deathTime+=startTime;
        ((Projectile)o).x=x;
        ((Projectile)o).y=y;
        projectiles.add(((Projectile)o).clone());
      } else if ( o instanceof Player) {
        ((Player)o).cx=x;
        ((Player)o).cy=y;
        ((Player)o).x=x;
        ((Player)o).y=y;
        players.add(((Player)o).clone());
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