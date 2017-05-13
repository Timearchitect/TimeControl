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
  text("add Time: "+addMillis+" freezeTime: " + freezeTime+" reversed: " + reversedTime+" forward: " + forwardTime+ " current: "+  stampTime +" fallenTime: "+fallenTime, halfWidth, 50);
  text("version: "+version, halfWidth, 20);
  text("players: "+players.size()+" projectiles: "+projectiles.size()+" particles: "+particles.size()+" stamps: "+stamps.size(), halfWidth, 75);
  text(frameRate, width-80, 50);
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
      if(shakeTimer>maxShake)shakeTimer=maxShake;
      shakeTimer--;
    }
    translate( shakeX*shakeAmount, shakeY*shakeAmount);
  }
}

void checkPlayerVSPlayerColloision() {
  if (!freeze &&!reverse) {
    for (Player p1 : players) {       
      for (Player p2 : players) {       
        if (p1.ally!=p2.ally && !p1.dead && !p2.dead ) { //  && p1!=p2
          //    if (dist(p1.x, p1.y, p2.x, p2.y)<playerSize) { // old collision
          if (dist(p1.cx, p1.cy, p2.cx, p2.cy)<p1.radius+p2.radius) {
            p1.hit(p2.damage);
            //float  deltaX = p1.cx -  p2.cx , deltaY =  p1.cy -  p2.cy;
            p1.pushForce( ((p1.radius+p2.radius)-dist(p2.cx, p2.cy, p1.cx, p1.cy)), atan2(p1.cy -  p2.cy, p1.cx -  p2.cx) * 180 / PI);
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
          if (p.ally!=o.ally && !p.dead && !o.dead ) { // && o.playerIndex!=p.ally
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
      background(255,0,0);
    }
  }
}
void checkProjectileVSProjectileColloision() {
  if (!freeze &&!reverse) {
    for (Projectile p1 : projectiles) {    
      for (Projectile p2 : projectiles) {      
        if (p2.ally!=p1.ally && !p2.dead && !p1.dead ) { //  && p1!=p2
          if (p1 instanceof  Reflectable  && p2 instanceof Reflector) {
            if (dist(p1.x, p1.y, p2.x, p2.y)<p1.size*.5+p2.size*.5) {
              ((Reflectable)p1).reflect(p2.angle, p2.owner);
              ((Reflector)p2).reflecting();
            }
          }
          if (p1 instanceof  Destroyable  && p2 instanceof Destroyer) {
            if (dist(p1.x, p1.y, p2.x, p2.y)<p1.size*.5+p2.size*.5) {
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
  int playerAliveIndex=0;
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
  if (RandomSkillsOnDeath) {
    generateRandomAbilities(1, passiveList, true);
    generateRandomAbilities(0, abilityList, true);
  }
  switch(gameMode) {
  case BRAWL:

    particles.add(new Text("Brawl", 200, halfHeight, 5, 0, 100, 0, 10000, BLACK, 0) );
    particles.add(new Gradient(8000, 0, 500, 0, 0, 500, 0.5, 0, GREY));

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
  case SURVIVAL:
    spawningReset();
    break;
  case BOSSRUSH:
    bossRushSetup() ;
    break;
  case SETTINGS:
    // for (Player p : players) {
    // text("player "+(p.index+1), 200, p.index*200+200);
    //  sBList.add(p.abilityList//);
    //}

    break;
  case PUZZLE:
    particles.add(new Text("Puzzle", 200, halfHeight, 5, 0, 100, 0, 10000, BLACK, 0) );
    particles.add(new Gradient(8000, 0, 500, 0, 0, 500, 0.5, 0, GREY));
    break;
  case WILDWEST:
    particles.add(new Text("WILD WILD WEST !!!", 200, halfHeight, 5, 0, 100, 0, 10000, BLACK, 0) );
    particles.add(new Gradient(8000, 0, 500, 0, 0, 500, 0.5, 0, GREY));
    players.add(AI);
    for (Player p : players) {
      if (p!=AI) {
        p.maxHealth=50;
        p.health=50;
        p.reset();
      }
    }

    if (players.get(0)!=null) { 
      players.get(0).x=75;
      players.get(0).y=75;
    }
    if (players.get(1)!=null) { 
      players.get(1).x=width-150;
      players.get(1).y=75;
    }
    if (players.get(2)!=null) { 
      players.get(2).x=width-150;
      players.get(2).y=height-150;
    }
    if (players.get(3)!=null) { 
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

  /*
  if (mousePressed&&mouseX>0 && halfWidth>mouseX) {
   if (mouseY>0 && halfHeight>mouseY) {
   gameMode=GameType.SURVIVAL;
   playerSetup();
   controllerSetup();
   resetGame();
   }
   }
   fill(255, 255, 150);
   rect(0, 0, halfWidth, halfHeight);
   if (mousePressed&&mouseX>halfWidth && width>mouseX) {
   if (mouseY>0 && halfHeight>mouseY) {
   gameMode=GameType.BRAWL;
   playerSetup();
   controllerSetup();
   resetGame();
   }
   }
   fill(60, 255, 150);
   rect(halfWidth, 0, halfWidth, halfHeight);
   if (mousePressed&&mouseX>0 && halfWidth>mouseX) {
   if (mouseY>halfHeight && height>mouseY) {
   gameMode=GameType.WILDWEST;
   playerSetup();
   controllerSetup();
   resetGame();
   }
   }
   fill(120, 255, 150);
   rect(0, halfHeight, halfWidth, halfHeight);
   if (mousePressed&&mouseX> halfWidth && width>mouseX) {
   if (mouseY>halfHeight && height>mouseY) {
   gameMode=GameType.SHOP;
   //playerSetup();
   //controllerSetup();
   resetGame();
   }
   }
   fill(180, 255, 150);
   rect( halfWidth, halfHeight, halfWidth, halfHeight);
   */
  /*fill(0, 0, 0);
   text(GameType.SURVIVAL.toString(), width/4, height/4);
   text(GameType.BRAWL.toString(), halfWidth+width/4, height/4);
   text(GameType.WILDWEST.toString(), width/4, halfHeight+height/4);
   text(GameType.SHOP.toString(), halfWidth+width/4, halfHeight+height/4);
   text(coins +" coins", halfWidth+width/4, halfHeight+height/3);*/
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
        text("SELL -50%", halfWidth, height-150);
        if (mousePressed && !pMousePressed) {
          selectedAbility.unlocked=false;
          coins+=int(selectedAbility.unlockCost*.5);
          selectedAbility=null;
          saveProgress();
          background(255);
        }
      } else if ( coins>=selectedAbility.unlockCost) {
        text("BUY", halfWidth, height-150);
        if (mousePressed && !pMousePressed) {
          selectedAbility.unlocked=true;
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
ArrayList<Button> sBList= new ArrayList<Button>();
void settingsUpdate() {
  background(255);
  textSize(50);
  fill(BLACK);
  for (Player p : players) {
    text("player "+(p.index+1), 200, p.index*200+200);
  }
  for (    Button s : sBList) {
    s.update();
    s.display();
  }
}
void loadProgress() throws Exception {
  save.clear();
  bList.clear();
  String[] s =loadStrings("save");
  // println(s);
  int i=0;
  for (Ability a : abilityList) {
    a.unlocked=parseBoolean(parseInt(s[i]));   
     try{
      bList.add(new Button(a, int(120+(i*110)%(width-220)), int(160+int(i*110/(width-220))*140), 80));
      }
    catch(Exception e){
      println(a.name+" not loaded");
    }
    //  println(parseBoolean(parseInt(s[i])));
    i++;
  }

  for (Ability a : passiveList) {
    a.unlocked=parseBoolean(parseInt(s[i]));
    try{
      bList.add(new Button(a, int(120+(i*110)%(width-220)), int(160+int(i*110/(width-220))*140), 80));
    }
    catch(Exception e){
      println(a.name+" not loaded");
    }
    i++;
  }
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

class Button {
  Ability a;
  int x, y, size;
  color pcolor=  color(255);
  Boolean selected=false, hover;

  Button(Ability _ability, int _x, int _y, int _size) {
    a= _ability;
    size=_size;
    x=_x;
    y=_y;
    //print(a.name+" ");
  }

  void update() {
    if (mouseX>x-size*.5&&x+size*.5>mouseX&&mouseY>y-size*.5&&y+size*.5>mouseY) {
      pcolor=color(170, 100, 255);
      if (mousePressed && !pMousePressed) {
        for (Button b : bList) {
          b.selected=false;
        }
        selected=true;
        selectedAbility=a;
        if (a.unlocked && a.deactivatable) {
          a.deactivated=!a.deactivated;
          int active=0;
          for (Ability as : abilityList) {
            if (!as.deactivated && as.unlocked )active++;
          }
          if (active<1) {
            abilityList[0].deactivated=false;
            abilityList[0].unlocked=true;
          }
          active=0;
          for (Ability as : passiveList) {
            if (!as.deactivated  && as.unlocked )active++;
          }
          if (active<1) {
            passiveList[0].deactivated=false;
            passiveList[0].unlocked=true;
          }
        }
      }
    } else {
      pcolor=color( 255);
    }
    if (selected) {
      pcolor=color( 170, 255, 255);
    }
  }

  void display() {
    rectMode(CENTER);
    if (!a.unlocked) {
      fill(pcolor);
      stroke(pcolor);
      rect(x, y, size, size);
      tint(255, (a.unlockCost>coins)?40:255);
      image(a.icon, x, y, size, size);
      fill((a.unlockCost>coins)?240:0);
      text(a.unlockCost, x, y+75);
    } else if (a.deactivated) {
      fill(0, 100, 255);
      stroke(0, 255, 255);
      rect(x, y, size, size);
      tint(0, 255, 255);
      image(a.icon, x, y, size, size);
      fill(0, 255, 255);
      text("[DEACTIVATED]", x, y+75);
    } else {
      tint(80, 255, 255);
      image(a.icon, x, y, size, size);
      fill(80, 255, 255);
      text("[UNLOCKED]", x, y+75);
    }
    text(a.name, x, y+60);
    rectMode(CORNER);
  }
}

class ModeButton extends Button {
  GameType type;

  int w, h, offset;
  ModeButton(GameType _type, int _x, int _y, int _w, int _h, color _color) {
    super(null, _x, _y, 0);
    pcolor=_color;
    w=_w;
    h=_h;
    type =_type;
  }
  void update() {

    if (mouseX>x&&x+w>mouseX&&mouseY>y&&y+h>mouseY) {
      hover=true; 
      //    for (int i=0; i<6; i++) {
      particles.add( new  Particle(int(x+random(w)), int(y+random(h)), 0, 0, int(random(50)+20), 1000, WHITE));
      // }
      if (offset<30)offset+=5;
      if (mousePressed && !pMousePressed) {
        gameMode=type;
        playerSetup();
        controllerSetup();
        resetGame();
        for (int i=0; i<36; i++) {
          particles.add( new  Particle(int(x+random(w)), int(y+random(h)), 0, 0, int(random(50)+20), 1000, pcolor));
        }
      }
    } else { 
      hover=false;    
      if (offset>0)offset--;
    }
  }

  void display() {
    textSize(30+int(offset*.5));
    fill(pcolor, (hover)?255:150);
    stroke(pcolor);
    strokeWeight(int(offset*.7));
    rect(x-offset*.5, y-offset*.5, w+offset, h+offset);
    tint(pcolor);
    //image(a.icon, x, y, size, size);
    //text(a.name, x, y+60);

    fill(0, 0, 0);

    text(type.toString(), x+w*.5, y+h*.5);
  }
}