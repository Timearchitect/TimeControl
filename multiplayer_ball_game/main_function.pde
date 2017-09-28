/*void stop() {
 ac.stop();
 super.stop();
 } */
void dispose() {
  ac.stop();
  an.stop();
  super.dispose();
}

void displayInfo() {
  fill(0);
  textSize(18);
  text("add Time: "+addMillis+" freezeTime: " + freezeTime+" reversed: " + reversedTime+" forward: " + forwardTime+ " current: "+  stampTime +" fallenTime: "+fallenTime, halfWidth, 50);
  text("version: "+version, halfWidth, 20);
  text("players: "+players.size()+" projectiles: "+projectiles.size()+" particles: "+particles.size()+" stamps: "+stamps.size(), halfWidth, 75);
  text(int(frameRate), width-80, 100);
}
void displayClock() {
  fill(0);
  textSize(40);
  text(" Time: "+  int(stampTime*0.001), halfWidth, 60);
  textSize(18);
  text("version: "+version, halfWidth, 20);
}
void screenShake() {
  if (shakeTimer>0) 
    shake(shakeTimer);
  else 
  shakeTimer=0;
  // shake screen
}
void shake(int amount) {
  if (!noShake) {
    // int shakeX=0, shakeY=0;
    if (!freeze) {
      shakeX=int(random(amount)-amount*.5);
      shakeY=int(random(amount)-amount*.5);
      if (shakeTimer>maxShake)shakeTimer=maxShake;
      shakeTimer--;
    }
    translate( shakeX*shakeAmount, shakeY*shakeAmount);
  }
}

void checkPlayerVSPlayerColloision() {
  if (!freeze &&!reverse) {
    for (Player p1 : players) {       
      for (Player p2 : players) {       
        if (   p1!=p2 &&  !p1.dead && !p2.dead  &&!p1.phase &&!p2.phase) { //  && p1!=p2
          //    if (dist(p1.x, p1.y, p2.x, p2.y)<playerSize) { // old collision
          if (dist(p1.cx, p1.cy, p2.cx, p2.cy)<p1.radius+p2.radius) {
            if (p1.allyCollision || p2.allyCollision|| p1.ally!=p2.ally) {  
              p1.collide(p2);
              //if (!p1.allyCollision || !p1.allyCollision)p1.hit(p2.damage);
              if(p1.ally!=p2.ally)p1.hit(p2.damage);
              //float  deltaX = p1.cx -  p2.cx , deltaY =  p1.cy -  p2.cy;
              //p1.pushForce( (p1.radius+p2.radius-dist(p2.cx, p2.cy, p1.cx, p1.cy)), atan2(p1.cy -  p2.cy, p1.cx -  p2.cx) * 180 / PI);
              p1.pushForce( (p1.radius+p2.radius-dist(p2.cx, p2.cy, p1.cx, p1.cy)), degrees(atan2(p1.cy -  p2.cy, p1.cx -  p2.cx)) );
            }
          }
        }
      }
    }
  }
}

void checkPlayerVSProjectileColloision() {
  if (!freeze &&!reverse) {

    try {
      for (Projectile o : projectiles) {    
        for (Player p : players) {      
          if ( !p.dead && !o.dead &&p.ally!=o.ally &&!p.phase ) { // && o.playerIndex!=p.ally
            //if (dist(o.x, o.y, p.cx, p.cy)<playerSize) { //old collision
            if (dist(o.x, o.y, p.cx, p.cy)<p.radius+o.size*.5) {
              //  players.get(j).hit(projectiles.get(i).damage);
              p.pushForce(o.force, o.angle);
              o.hit(p);
            }
          }
        }
      }
    }
    catch(Exception e) {
      println(e +" onmain projectile ");
      //background(255,0,0);
    }
  }
}
void checkProjectileVSProjectileColloision() {
  if (!freeze &&!reverse) {
    for (Projectile p1 : projectiles) {    
      for (Projectile p2 : projectiles) {      
        if ( !p2.dead && !p1.dead &&p2.ally!=p1.ally ) { //  && p1!=p2
          if (p1 instanceof  Reflectable  && p2 instanceof Reflector) {
            //if (dist(p1.x, p1.y, p2.x, p2.y)<p1.size*.5+p2.size*.5) {
            if (dist(p1.x, p1.y, p2.x, p2.y)<(p1.size+p2.size)*.5) {
              ((Reflectable)p1).reflect(p2.angle, p2.owner);
              ((Reflector)p2).reflecting();
            }
          }
          if (p1 instanceof  Destroyable  && p2 instanceof Destroyer) {
            // if (dist(p1.x, p1.y, p2.x, p2.y)<p1.size*.5+p2.size*.5) {
            if (dist(p1.x, p1.y, p2.x, p2.y)<(p1.size+p2.size)*.5) {
              ((Destroyable)p1).destroy(p2);
              ((Destroyer)p2).destroying(p1);
            }
          }
        }
      }
    }
  }
}


void checkPlayerVSProjectileColloisionLine() {
}

void checkWinner() {
  //playerAliveIndex=0;
  playersAlive=0;
  for (Player p : players) {      
    if (!p.dead && !p.turret && !p.clone) {
      playersAlive++;
      playerAliveIndex=p.index;
    }
  }

  if (playersAlive<=1) {
    textSize(80);
    switch(gameMode) {
    case BRAWL:
      if (!gameOver) {
        reward=int(stamps.size()*0.003); 
        coins+=reward;
        stamps.clear();
        saveProgress();
      }
      gameOver=true;
      text(" Winner is player "+(playerAliveIndex+1), halfWidth, halfHeight);
      text(" Press ["+ResetKey+"] to restart", halfWidth, height*0.6);
      text( reward+" coins earned!!!]", halfWidth, height*0.7);
      break;
    case HORDE:
      if (playersAlive==0) {
        if (survivalTime<=0)survivalTime=int(stampTime*.001);
        if (!gameOver) {
          reward=survivalTime; 
          coins+=reward;
          saveProgress();
        }
        gameOver=true;

        text(" Survived for "+survivalTime+ "  sek", halfWidth, halfHeight);
        text(" Press ["+ResetKey+"] to restart", halfWidth, height*0.6);
        text( reward +" coins earned!!!]", halfWidth, height*0.7);
      }
      break;
    case SURVIVAL:
      if (playersAlive==0) {
        if (survivalTime<=0)survivalTime=int(stampTime*.001);
        if (!gameOver) {
          reward=survivalTime; 
          coins+=reward;
          saveProgress();
        }
        gameOver=true;

        text(" Survived for "+survivalTime+ "  sek", halfWidth, halfHeight);
        text(" Press ["+ResetKey+"] to restart", halfWidth, height*0.6);
        text( reward +" coins earned!!!]", halfWidth, height*0.7);
      }
      break;

    case PUZZLE:
      if (playersAlive<1) {
        gameOver=true;
        text(" The survivor is player "+(playerAliveIndex+1), halfWidth, halfHeight);
        text(" Press ["+ResetKey+"] to restart", halfWidth, height*0.6);
        saveProgress();
      }
      break;

    case WILDWEST:
      if (playersAlive<2) {
        if (!gameOver) {
          reward=int(stamps.size()*0.005); 
          coins+=reward;
          stamps.clear();
          saveProgress();
        }
        gameOver=true;
        text(" The survivor is player "+(playerAliveIndex+1), halfWidth, halfHeight);
        text(" Press ["+ResetKey+"] to restart", halfWidth, height*0.6);
        text( reward+" coins earned!!!]", halfWidth, height*0.7);
      }
      break;
    default:
      break;
    }

    textSize(18);
  }
}

void drawTimeSymbol() {
  if (freeze) {
    GUILayer.beginDraw();
    GUILayer.clear();
    GUILayer.rect(offsetX-50, offsetY, 50, 200);
    GUILayer.rect(offsetX+50, offsetY, 50, 200);
    GUILayer.endDraw();
  } else {
    if (reverse) {
      GUILayer.beginDraw();
      GUILayer.clear();
      GUILayer.beginShape();
      GUILayer.vertex(offsetX, offsetY);
      GUILayer.vertex(offsetX-(75*timeBend), offsetY+100);
      GUILayer.vertex(offsetX, offsetY+200);
      GUILayer.endShape();
      GUILayer.endDraw();
    }
    if (!reverse) {
      GUILayer.beginDraw();
      GUILayer.clear();
      GUILayer.beginShape();
      GUILayer.vertex(offsetX, offsetY);
      GUILayer.vertex(offsetX+(75*timeBend), offsetY+100);
      GUILayer.vertex(offsetX, offsetY+200);
      GUILayer.endShape();
      GUILayer.endDraw();
    }
  }
}

void quitOrigo() {
  origo=false;
  if (stampTime<0) {
    stampTime=0;
    reverse=false;
    musicPlayer.setPosition(1); //resetmusic s
    particles.add(new Flash(1500, 5, WHITE));   // flash
  }
}
void mouseDot() {
  strokeWeight(5);
  //ellipse(pmouseX, pmouseY, 10, 10);
  point(mouseX, mouseY);
}


void resetGame() {
  gameOver=false;

  if (cleanStart) {
    clearGame();
  }

  if ( RandomSkillsOnDeath) {
    generateRandomAbilities(1, passiveList, true);
    generateRandomAbilities(0, abilityList, true);
  }
  switch(gameMode) {
  case BRAWL:
    titleDisplay(gameMode);
    for (Player p : players) {    
      if (p!=AI&&!p.clone &&  !p.turret) {  // no turret or clone respawn
        p.reset();
        announceAbility( p, 0);
      } else {
        p.dead=true;
        p.state=0;
      }
    }

    break;
  case HORDE:
    hordeSpawningReset();
    break;
  case SURVIVAL:
    spawningReset();
    break;
  case BOSSRUSH:
    for (Player p : players) {    
      if (p!=AI&&!p.clone &&  !p.turret) {  // no turret or clone respawn
        p.reset();
        announceAbility( p, 0);
      } else {
        p.dead=true;
        p.state=0;
      }
    }
    bossRushSetup() ;
    break;
  case SETTINGS:
    // for (Player p : players) {
    // text("player "+(p.index+1), 200, p.index*200+200);
    //  sBList.add(p.abilityList//);
    //}

    break;
  case PUZZLE:
    titleDisplay(gameMode);

    break;
  case WILDWEST:
    titleDisplay(gameMode);

    players.add(AI);
    for (Player p : players) {
      if (p!=AI) {
        p.maxHealth=50;
        p.health=50;
        p.reset();
      }
    }

    if (players.size()>0 &&players.get(0)!=null) { 
      players.get(0).x=75;
      players.get(0).y=75;
    }
    if (players.size()>1 &&players.get(1)!=null) { 
      players.get(1).x=width-150;
      players.get(1).y=75;
    }
    if (players.size()>2 &&players.get(2)!=null) { 
      players.get(2).x=width-150;
      players.get(2).y=height-150;
    }
    if (players.size()>3 && players.get(3)!=null) { 
      players.get(3).x=75;
      players.get(3).y=height-150;
    }
    generateRandomAbilities(0, westAbilityList, false);
    generateRandomAbilities(1, westPassiveList, false);



    players.add(new Block(players.size(), AI, 200, 200, 200, 200, 999, new Armor()));
    players.add(new Block(players.size(), AI, width-400, 200, 200, 200, 999, new Armor()));
    players.add(new Block(players.size(), AI, width-400, height-400, 200, 200, 999, new Armor()));
    players.add(new Block(players.size(), AI, 200, height-400, 200, 200, 999, new Armor()));

    players.add(new Block(players.size(), AI, halfWidth-50, 0, 100, 100, 499, new Armor()));
    players.add(new Block(players.size(), AI, halfWidth-50, height-100, 100, 100, 499, new Armor()));

    players.add(new Block(players.size(), AI, 0, halfHeight-25, 50, 50, 99));
    players.add(new Block(players.size(), AI, width-50, halfHeight-25, 50, 50, 99));
    players.add(new Block(players.size(), AI, 50, halfHeight-25, 50, 50, 99));
    players.add(new Block(players.size(), AI, width-100, halfHeight-25, 50, 50, 99));

    break;
  default:
  }
}

void clearGame() {
  shakeTimer=0;
  zoomXAim=halfWidth;
  zoomYAim=halfHeight;
  zoomAim=1;
  freeze=false;
  fastForward=false;
  slow=false;
  reverse=false;
  S=1;
  F=1;
  timeBend=S*F;
  prevMillis=millis(); 
  addMillis=0; 
  forwardTime=0; 
  reversedTime=0; 
  freezeTime=0; 
  //stampTime=millis(); 
  stampTime=0;
  fallenTime=0;
  stamps.clear();
  projectiles.clear();
  particles.clear();
  if (!noFlash)background(255);
  for (int i =players.size()-1; i>= 0; i--) {
    //players.get(i).holdTrigg=true;
    players.get(i).buffList.clear();
    /*for (Ability a: players.get(i).abilityList){
     players.get(i).abilityList.remove(a);
     }*/
    if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
  }
}
void announceAbility(Player p, int index ) {
  if (p.textParticle!=null)particles.remove( p.textParticle );
  if (p.iconParticle!=null)particles.remove( p.iconParticle );
  //p.abilityList.get(index).icon
  if (p.abilityList.size()-1>index) {
    p.iconParticle= new Pic(p, p.abilityList.get(index).icon, int(0), int(-150), 0, 0, 100, 0, 3000, p.playerColor, 1);
    particles.add(new Pic(p, p.abilityList.get(index).icon, int(0), int(-150), 0, 0, 100, -10, 300, p.playerColor, 1));
    particles.add( p.iconParticle);

    p.textParticle = new Text(p, p.abilityList.get(index).name, 0, -75, 30, 0, 3000, BLACK, 0);
    particles.add( p.textParticle );
  }
}

void menuUpdate() {

  players.clear();

  background(0);
  textSize(50);
  for (ModeButton m : mList) {
    m.update();
    m.display();
  }
}

void wildWestUpdate() {
  int x=halfWidth, y=halfHeight;
  for (Player p : players) {
    x+=p.cx;
    y+=p.cy;
  }
  x=x/(players.size());
  y=y/(players.size());
  zoomXAim=x;
  zoomYAim=y;
}


ArrayList<String> save=  new ArrayList<String>();
ArrayList<Button> bList= new ArrayList<Button>();
ArrayList<SettingButton> sList= new ArrayList<SettingButton>();
ArrayList<ModeButton> mList= new ArrayList<ModeButton>();
Ability selectedAbility ; 

void shopUpdate() {
  background(255);
  //int i=0;
  textSize(40);
  text(coins +" coins", halfWidth, 70);

  textSize(8);
  for (Button b : bList) {
    b.update();
    b.display();
  }
  for (Button b : bList) {
    b.displayTooltips();
  }

  if (selectedAbility!=null) { 
    image(selectedAbility.icon, width-200, height-200, 300, 300);
    rectMode(CENTER);
    if (mouseX>halfWidth-900*.5&&halfWidth+900*.5>mouseX&&mouseY>height-150-200*.5&&height-150+200*.5>mouseY) {
      fill((selectedAbility.unlocked||coins<selectedAbility.unlockCost)?0:90, 255, 255);
      rect(halfWidth, height-150, 900, 200);
      textSize(100);
      fill(BLACK);
      if ( !selectedAbility.sellable) {
        textSize(60);
        text("cant be sold", halfWidth, height-150);
      } else if (selectedAbility.unlocked) {  
        textSize(70);
        text(selectedAbility.sellText+" -50%", halfWidth, height-150);
        if (mousePressed && !pMousePressed) {
          selectedAbility.unlocked=false;
          selectedAbility.sell();
          coins+=int(selectedAbility.unlockCost*.5);
          selectedAbility=null;
          saveProgress();
          background(255);
        }
      } else if ( coins>=selectedAbility.unlockCost) {
        text(selectedAbility.buyText, halfWidth, height-150);
        if (mousePressed && !pMousePressed) {
          selectedAbility.unlocked=true;
          selectedAbility.buy();
          selectedAbility.updateTooltips();
          coins-=selectedAbility.unlockCost;
          selectedAbility=null;
          saveProgress();
          background(255);
        }
      } else {
        textSize(50);
        text("not enough money", halfWidth, height-150);
      }
    } else {
      if (selectedAbility.unlocked && !selectedAbility.deactivated) fill(150, 150, 255);  
      else if (selectedAbility.unlocked ) fill(150, 50, 255);
      else if (selectedAbility.unlockCost<=coins) fill(90, 150, 255);
      else fill(0, 150, 255);

      textSize(40);
      rect(halfWidth, height-150, 900, 200);
      fill(BLACK);
      text("["+selectedAbility.type.toString().toLowerCase() +"]\n"+selectedAbility.name+"\n"+selectedAbility.unlockCost+" coins", halfWidth, height-150);
    }

    rectMode(CORNER);
  }
}
ArrayList<SettingButton> sBList= new ArrayList<SettingButton>(); 
ArrayList<StatButton> pSBList= new ArrayList<StatButton>(); 
int[] abilitySettingsIndex= new int[AmountOfPlayers];  
int[] statPoints =  new int[AmountOfPlayers];  
int settingSkillXOffset=650, settingSkillYOffset=100, settingSkillInterval=180;
void settingsUpdate() { //----------------------------------------------------   settingsupdate
  background(255);
  textSize(50);

  /* for (Button b: sList){
   b.update();
   b.display();
   }*/

  textSize(46);
  for (Player p : players) {
    fill(p.playerColor, 150);
    text("player "+(p.index+1), 250, p.index*200+settingSkillYOffset);
  }

  fill(WHITE);
  stroke(BLACK);
  for (SettingButton s : sBList) {
    s.update();
    s.display();
    s.updateSettings();
  }
  for (StatButton s : pSBList) {
    s.update();
    s.display();
    //s.updateSettings();
  }
  noFill();
  strokeWeight(8);//
  for (int i=0; i< AmountOfPlayers; i++) {//abilitySettingsIndex.length-1
    stroke(int((255/AmountOfPlayers)*i), 255, 255);
    rect(  abilitySettingsIndex[i]*settingSkillInterval+settingSkillXOffset-55, i*200+settingSkillYOffset-55, 110, 110);
  }
}

int shopXEdgePadding=90, shopYEdgePadding=150;
int shopXInterval=100, shopYInterval=115;
void loadProgress() throws Exception {
  save.clear();
  bList.clear();
  String[] s =loadStrings("save");
  // println(s);
  int i=0;
  for (Ability a : abilityList) {
    a.unlocked=parseBoolean(parseInt(s[i]));   
    try {
      bList.add(new Button(a, int(shopXEdgePadding+(i*shopXInterval)%(width-shopXEdgePadding*2)), int(shopYEdgePadding+int(i*shopXInterval/(width-shopXEdgePadding*2))*shopYInterval), 70));
    }
    catch(Exception e) {
      println(a.name+" not loaded");
    }
    i++;
  }

  for (Ability a : passiveList) {
    a.unlocked=parseBoolean(parseInt(s[i]));
    try {
      bList.add(new Button(a, int(shopXEdgePadding+(i*shopXInterval)%(width-shopXEdgePadding*2)), int(shopYEdgePadding+int(i*shopXInterval/(width-shopXEdgePadding*2))*shopYInterval), 70));
    }
    catch(Exception e) {
      println(a.name+" not loaded");
    }
    i++;
  }
  bList.add(new UpgradebleButton(new SkillPoint(), int(shopXEdgePadding+(i*shopXInterval)%(width-shopXEdgePadding*2)), int(shopYEdgePadding+int(i*shopXInterval/(width-shopXEdgePadding*2))*shopYInterval), 70));

  coins=parseInt(s[i]);
}

void saveProgress() {
  save.clear();
  for (Ability a : abilityList) {
    save.add(String.valueOf(parseInt(a.unlocked)));
  }
  for (Ability a : passiveList) {
    save.add(String.valueOf(parseInt(a.unlocked)));
  }
  save.add(String.valueOf(coins));
  saveStrings("save", save.toArray(new String[0]));
  //println(save);
}