
ArrayList<Spawner> spawnList= new ArrayList<Spawner>();
boolean gameOver;
int reward=0;
int survivalTime;
//   projectiles.add( new AbilityPack(AI,new Random().randomize(),  int( owner.cx+cos(radians(owner.angle))*owner.w*2), int(owner.cy+sin(radians(owner.angle))*owner.w*2), 100, AI.playerColor, 60000, 0, 0, 0, 0, true));

void spawningSetup() {
  spawnList.add(new Spawner(new Object[]{new HealBall(AI, halfWidth, halfHeight, 60, WHITE, 20000, 0, 0, 0, 50, true)}
    , 8000, 10000*DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 100/DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new ManaBall(AI, halfWidth, halfHeight, 60, WHITE, 20000, 0, 0, 0, 50, true)}
    , 13000, 10000*DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 100/DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(abilityList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, false, true)}
    , 3000, 0, true, 1));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(abilityList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, false, true)}
    , 3000, 0, true, 1));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(abilityList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, false, true)}
    , 3000, 0, true, 1));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(abilityList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, false, true)}
    , 3000, 0, true, 1));

  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(passiveList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, false, true)}
    , 3000, 0, true, 1));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(passiveList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, false, true)}
    , 3000, 0, true, 1));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(passiveList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, true, true)}
    , 3000, 0, true, 1));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(passiveList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, true, true)}
    , 3000, 0, true, 1));
  /*  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.5), int(playerSize*0.5), 10, 150, 1, new Bazooka())}
   , 1000));*/

  /* spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(passiveList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, true, true)}
   , 5000, 0, true, 1));
   spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(passiveList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, true, true)}
   , 5000, 0, true, 1));
   spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(abilityList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, true, true)}
   , 5000, 0, true, 1));
   spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(passiveList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, true, true)}
   , 5000, 0, true, 1));*/
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(abilityList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, true, true)}
    , 5000, 0, true, 1));


  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.75), int(playerSize*0.75), 15, 50, 2, new Suicide())}
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
  /*spawnList.add(new Spawner(new Object[]{new  Missile(AI, halfWidth, halfHeight, 50, BLACK, 2000, 1, 1, 1, 40, true)}
   , 30000, 2000, halfWidth, halfHeight, true, 5));
   */
  spawnList.add(new Spawner(new Object[]{new HomingMissile(AI, halfWidth, halfHeight, 50, BLACK, 2000, 0, 0, 0, 10), new HomingMissile(AI, halfWidth, halfHeight, 50, BLACK, 2000, 0, 0, 0, 10)}
    , 15000, 100/DIFFICULTY_LEVEL, halfWidth, halfHeight, false, 50*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.75), int(playerSize*0.75), 10, 100, 1, new AutoGun(), new  Reward(3, false))}
    , 20000, 4000/DIFFICULTY_LEVEL, true, 10*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new Drone(players.size(), halfWidth, halfHeight, int(playerSize*0.75), int(playerSize*0.75), 10, 200, new AutoGun(), new  Reward(3, false))}
    , 35000, 12000/DIFFICULTY_LEVEL, true, 3*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new Turret(players.size(), AI, halfWidth, halfHeight, playerSize, playerSize, 50, new TimeBomb(), new  Reward(3, false))}
    , 55000, 14000/DIFFICULTY_LEVEL, true, 5*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.75), int(playerSize*0.5), 10, 50, 1, new Pistol(), new  Reward(5, false))}
    , 70000, halfWidth, halfHeight));
  spawnList.add(new Spawner(new Object[]{new Turret(players.size(), AI, halfWidth, halfHeight, playerSize, playerSize, 100, new Bazooka(), new  Reward(4, false))}
    , 85000, 15000/DIFFICULTY_LEVEL, true, 3*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.75), int(playerSize*0.75), 30, 150, 2, new Suicide())}
    , 90000, 8000/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 30));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.75), int(playerSize*0.75), 10, 120, 1, new SemiAuto(), new  Reward(8, false))}
    , 130000, 10000/DIFFICULTY_LEVEL, true, 5*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.75), int(playerSize*0.75), 10, 120, 1, new Pistol(), new  Reward(5, false))}
    , 150000, 10000/DIFFICULTY_LEVEL, true, 5*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1.2), 20, 440, 1, new Torpedo(), new MpRegen(), new Torpedo(), new  Reward(10, false))}
    , 220000, 10000/DIFFICULTY_LEVEL, true, 2*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1.2), 20, 440, 1, new MissileLauncher(), new MpRegen(), new  Reward(10, false))}
    , 250000, 10000/DIFFICULTY_LEVEL, true, 2*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1.2), 20, 440, 1, new Torpedo(), new MpRegen(), new Torpedo(), new  Reward(10, false))}
    , 270000, 10000/DIFFICULTY_LEVEL, true, 2*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1.2), 20, 440, 1, new MissileLauncher(), new MpRegen(), new  Reward(10, false))}
    , 290000, 10000/DIFFICULTY_LEVEL, true, 2*DIFFICULTY_LEVEL));

  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1.2), 20, 440, 1, new Torpedo(), new Torpedo(), new MpRegen(), new  Reward(10, false))}
    , 320000, 10000/DIFFICULTY_LEVEL, true, 2*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1.2), 20, 300, 2, new Gloss(), new PhotonicPursuit(), new  Reward(15, false))}
    , 330000, 10000/DIFFICULTY_LEVEL, true, 2*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1.2), 20, 500, 2, new Shotgun(), new MpRegen(), new Blink(), new  Reward(15, false))}
    , 350000, 10000/DIFFICULTY_LEVEL, true, 2*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1.2), 20, 500, 2, new Sluggun(), new MpRegen(), new Blink(), new  Reward(15, false))}
    , 360000, 10000/DIFFICULTY_LEVEL, true, 2*DIFFICULTY_LEVEL));
  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*0.8), 20, 500, 1, new Combo(), new Stealth(), new Combo(), new MpRegen(), new Ram(), new  Reward(15, false)), 
    new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*0.8), 20, 500, 1, new Combo(), new Stealth(), new Combo(), new MpRegen(), new Ram(), new  Reward(15, false))}
    , 380000, 10000/DIFFICULTY_LEVEL, true, 1));

  spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1.75), int(playerSize*1.75), 15, int(1000*DIFFICULTY_LEVEL), 1, new MarbleLauncher(), new HpRegen(), new Torpedo(), new  Reward(25, false))}
    , 400000, 10000/DIFFICULTY_LEVEL, true, 1));
}

void spawningHordeSetup() {   // HORDE MODE
  spawnList.add(new Spawner(new Object[]{new ManaBall(AI, halfWidth, halfHeight, 60, WHITE, 20000, 0, 0, 0, 50, true)}
    , 13000, 8000*DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 100/DIFFICULTY_LEVEL));
  /*spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.75), int(playerSize*0.75), 10, 200, 1, new AutoGun(), new  Reward(1, false))}
   , 2000, 4000/DIFFICULTY_LEVEL, true, 50*DIFFICULTY_LEVEL));*/
  spawnList.add(new Spawner(new Object[]{new Zombie(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1), 30, 200, 10, new  Reward(3, true))}
    , 1200, 5000/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 50));
  spawnList.add(new Spawner(new Object[]{new Zombie(players.size(), halfWidth, halfHeight, int(playerSize*0.75), int(playerSize*0.75), 30, 150, 10, new  Reward(2, true))}
    , 1000, 5000/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 50));
  spawnList.add(new Spawner(new Object[]{new Zombie(players.size(), halfWidth, halfHeight, int(playerSize*1.25), int(playerSize*1.25), 30, 250, 10, new  Reward(4, true))}
    , 800, 5000/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 50));
  spawnList.add(new Spawner(new Object[]{new Zombie(players.size(), halfWidth, halfHeight, int(playerSize*0.9), int(playerSize*0.9), 30, 170, 10, new  Reward(2, true))}
    , 800, 4000/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 50));
  spawnList.add(new Spawner(new Object[]{new Zombie(players.size(), halfWidth, halfHeight, int(playerSize*0.9), int(playerSize*0.9), 30, 170, 10, new  Reward(1, true))}
    , 500, 2000/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 100));
  /* spawnList.add(new Spawner(new Object[]{new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.75), int(playerSize*0.75), 15, 50, 2, new Suicide())}
   , 500, 10000/DIFFICULTY_LEVEL, halfWidth, halfHeight, true, 50*DIFFICULTY_LEVEL));*/
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

  for (Player p : players) {
    if (!preSelectedSkills) {  
      p.abilityList.clear();
      p.abilityList.add(new Random().randomize(abilityList));
      p.abilityList.get(0).setOwner(p);
    }
    for (Ability a : p.abilityList) {
      a.reset();
    }
    p.ally=0;
  }

  players.add(AI);
  spawningSetup();
  particles.add(new  Text("Survival", 200, halfHeight, 5, 0, 100, 0, 10000, BLACK, 0) );
  particles.add(new Gradient(10000, 0, 500, 0, 0, 500, 0.5, 0, GREY));
  if (!preSelectedSkills) {  
    generateRandomAbilities(1, passiveList, true);
    generateRandomAbilities(0, abilityList, true);
  }
  /*for (Spawner s : spawnList) {
   s.dead=false;
   s.times=s.initTimes;
   }*/
  if (!noFlash) background(255);
}
void survivalSpawning() {
  if (!gameOver) for (Spawner s : spawnList)  s.update();
}
void hordeSpawning() {
  if (!gameOver) for (Spawner s : spawnList)  s.update();
}

void hordeSpawningReset() {

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

  for (Player p : players) {
    if (!preSelectedSkills) {  
      p.abilityList.clear();
      p.abilityList.add(new Random(true).randomize(abilityList));
      p.abilityList.get(0).setOwner(p);
    }
    for (Ability a : p.abilityList) {
      a.reset();
    }
    p.ally=0;
  }

  spawningHordeSetup();
}
ArrayList<Player> bossList= new ArrayList<Player>();
int bossCleared=0;
void bossRushSetup() {
  spawnList.clear();
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(passiveList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, true, true)}
    , 3000, 0, true, 1));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(passiveList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, true, true)}
    , 3000, 0, true, 1));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(abilityList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, true, true)}
    , 3000, 0, true, 1));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(passiveList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, true, true)}
    , 3000, 0, true, 1));
  spawnList.add(new Spawner(new Object[]{new AbilityPack(AI, new Random(true).randomize(abilityList), int( AI.cx+cos(radians(AI.angle))*AI.w*2), int(AI.cy+sin(radians(AI.angle))*AI.w*2), 100, AI.playerColor, 30000, 0, 0, 0, true, true)}
    , 3000, 0, true, 1));

  for (Player p : players) {
    //p.abilityList.clear();
    //p.abilityList.add(new Random().randomize(abilityList));
    //p.abilityList.get(0).setOwner(p);
    p.ally=0;
  }
  bossCleared=0;
  bossList.clear();
  bossList.add(new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1), 15, int(700*DIFFICULTY_LEVEL), 2, new Gravity(), new MpRegen(), new Ram(), new PanicBlink(), new  Reward(10, false)));// shield

  bossList.add(new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1), 15, int(700*DIFFICULTY_LEVEL), 1, new TimeBomb(), new MpRegen(), new Ram(), new TimeBomb(), new PanicBlink(), new  Reward(10, false)));// shield

  bossList.add(new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1), 15, int(700*DIFFICULTY_LEVEL), 4, new ForceShoot(), new MpRegen(), new MpRegen(), new ForceShoot(), new HpRegen(8, 10), new PanicBlink(), new  Reward(10, false)));// shield

  bossList.add(new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1), 15, int(700*DIFFICULTY_LEVEL), 3, new Ram(), new Speed(), new SnakeShield(), new HpRegen(8, 10), new PanicBlink(), new  Reward(10, false)));// shield

  bossList.add(new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1), 15, int(1000*DIFFICULTY_LEVEL), 4, new HpRegen(10, 10), new RapidFire(), new RapidFire(), new MachineGun(), new MachineGun(), new  Reward(25, false))); //, new MissileLauncher()

  bossList.add(new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1), 15, int(1200*DIFFICULTY_LEVEL), 1, new Sluggun(), new MpRegen(), new Sluggun(), new PanicBlink(), new  Reward(25, false))); //, new MissileLauncher()
  bossList.add(new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1.75), int(playerSize*1.75), 15, int(1100*DIFFICULTY_LEVEL), 1, new Bazooka(), new Bazooka(), new Bazooka(), new  Reward(25, false))); //, new MissileLauncher()

  bossList.add(new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*0.8), int(playerSize*0.8), 20, int(500*DIFFICULTY_LEVEL), 1, new Combo(), new Stealth(), new MpRegen(), new Gravitation(600, -0.8), new Ram(), new  Reward(20, false)));
  bossList.add(new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1.75), int(playerSize*1.75), 15, int(600*DIFFICULTY_LEVEL), 1, new MarbleLauncher(), new Torpedo(), new  Reward(25, false))); //, new MissileLauncher()
  bossList.add(new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1.5), int(playerSize*1.5), 15, int(700*DIFFICULTY_LEVEL), 3, new SemiAuto(), new Pistol(), new HpRegen(10, 10), new  Reward(30, false)));
  Sniper  sA= new  Sniper();
  sA.damage=45;
  sA.activeCost=0;
  sA.channelCost=0;
  sA.deactiveCost=0;
  bossList.add(new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*1), int(playerSize*1), 15, int(800*DIFFICULTY_LEVEL), 4, sA, new HpRegen(10, 10), new Repel(500, 0.8), new PanicBlink(), new  Reward(30, false))); //, new DeployShield()
  bossList.add(new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*2), int(playerSize*2), 15, int(900*DIFFICULTY_LEVEL), 4, new HpRegen(10, 10), new DeployBodyguard(), new DeployDrone(), new  Reward(35, false))); //, new DeployShield()
  bossList.add(new FollowDrone(players.size(), halfWidth, halfHeight, int(playerSize*2), int(playerSize*2), 15, int(1000*DIFFICULTY_LEVEL), 4, new Blink(), new Static(), new MpRegen(), new HpRegen(10, 10), new Multiply(), new  Reward(35, false))); //, new DeployShield()

  for (Player b : bossList) {
    b.armor=0;
  }
}  
void bossRushSpawning() {
  if (!gameOver) {
    for (Spawner s : spawnList)s.update();
    if (!players.contains(bossList.get(bossCleared)))players.add(bossList.get(bossCleared));
    if (bossList.get(bossCleared).dead)if (bossCleared<bossList.size()-1)bossCleared++;
  }
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
            println(e+" spawn");
          }
        }
      } else {
        try {
          spawn();
          dead=true;
          //  println("dead");
        }
        catch(Exception e) {
          println(e+ "spawn2");
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
      } else if ( o instanceof Player) {
        particles.add(new ShockWave(x, y, 40, 5, 850, AI.playerColor));
        Player temp = ((Player)o).clone();
        temp.abilityList=(ArrayList<Ability>)((Player)o).abilityList.clone();
        temp.cx=x;
        temp.cy=y;
        temp.x=x-temp.radius;
        temp.y=y-temp.radius;
        players.add(temp);
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
