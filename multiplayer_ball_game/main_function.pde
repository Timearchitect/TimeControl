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
  if (shakeTimer>0) {
    shake(2*shakeTimer);
  } else {
    shakeTimer=0;
  } // shake screen
}
void shake(int amount) {
  if (!noShake) {
    // int shakeX=0, shakeY=0;
    if (!freeze) {
      shakeX=int(random(amount)-amount*0.5);
      shakeY=int(random(amount)-amount*0.5);
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
    }
  }
}
void checkProjectileVSProjectileColloision() {
  if (!freeze &&!reverse) {
    for (Projectile p1 : projectiles) {    
      for (Projectile p2 : projectiles) {      
        if (p2.ally!=p1.ally && !p2.dead && !p1.dead ) { //  && p1!=p2
          if (p1 instanceof  Reflectable  && p2 instanceof Reflector) {
            if (dist(p1.x, p1.y, p2.x, p2.y)<p1.size*0.5+p2.size*0.5) {
              ((Reflectable)p1).reflect(p2.angle, p2.owner);
              ((Reflector)p2).reflecting();
            }
          }
          if (p1 instanceof  Destroyable  && p2 instanceof Destroyer) {
            if (dist(p1.x, p1.y, p2.x, p2.y)<p1.size*0.5+p2.size*0.5) {
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

      text(" Winner is player "+(playerAliveIndex+1), halfWidth, halfHeight);
      text(" Press ["+ResetKey+"] to restart", halfWidth, height*0.6);
      break;
    case SURVIVAL:
      if (playersAlive==0) {
        gameOver=true;
        if (survivalTime<=0)survivalTime=int(stampTime*.001);
        text(" Survived for "+survivalTime+ "  sek", halfWidth, halfHeight);
        text(" Press ["+ResetKey+"] to restart", halfWidth, height*0.6);
      }
      break;

    case PUZZLE:
      if (playersAlive<1) {
        text(" The survivor is player "+(playerAliveIndex+1), halfWidth, halfHeight);
        text(" Press ["+ResetKey+"] to restart", halfWidth, height*0.6);
      }
      break;

    case WILDWEST:
      if (playersAlive<2) {
        text(" The survivor is player "+(playerAliveIndex+1), halfWidth, halfHeight);
        text(" Press ["+ResetKey+"] to restart", halfWidth, height*0.6);
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
  if (cleanStart) {
    clearGame();
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
    for (Player p : players) {    
      if (p!=AI&&!p.clone &&  !p.turret) {  // no turret or clone respawn
        p.reset();
        announceAbility( p, 0);
      } else {
        p.dead=true;
        p.state=0;
      }
    }

    spawningReset();
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
    generateRandomAbilities(1, westPassiveList);
    generateRandomAbilities(0, westAbilityList);


    players.add(new Block(players.size(), AI, 200, 200, 200, 200, 999, new Armor()));
    players.add(new Block(players.size(), AI, width-400, 200, 200, 200, 999, new Armor()));
    players.add(new Block(players.size(), AI, width-400, height-400, 200, 200, 999, new Armor()));
    players.add(new Block(players.size(), AI, 200, height-400, 200, 200, 999, new Armor()));

    players.add(new Block(players.size(), AI, width/2-50, 0, 100, 100, 499, new Armor()));
    players.add(new Block(players.size(), AI, width/2-50, height-100, 100, 100, 499, new Armor()));

    players.add(new Block(players.size(), AI, 0, height/2-25, 50, 50, 99));
    players.add(new Block(players.size(), AI, width-50, height/2-25, 50, 50, 99));
    players.add(new Block(players.size(), AI, 50, height/2-25, 50, 50, 99));
    players.add(new Block(players.size(), AI, width-100, height/2-25, 50, 50, 99));

    break;
  default:
  }
}

void clearGame() {
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
    if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
  }
}
void announceAbility(Player p, int index ) {
  if (p.textParticle!=null)particles.remove( p.textParticle );
  if (p.iconParticle!=null)particles.remove( p.iconParticle );
  //p.abilityList.get(index).icon
  p.iconParticle= new Pic(p, p.abilityList.get(index).icon, int(0), int(-150), 0, 0, 100, 0, 3000, p.playerColor, 1);
  particles.add(new Pic(p, p.abilityList.get(index).icon, int(0), int(-150), 0, 0, 100, -10, 300, p.playerColor, 1));
  particles.add( p.iconParticle);

  p.textParticle = new Text(p, p.abilityList.get(index).name, 0, -75, 30, 0, 3000, BLACK, 0);
  particles.add( p.textParticle );
}

void menuUpdate() {

  players.clear();

  background(0);
  textSize(50);
  if (mousePressed&&mouseX>0 && width/2>mouseX) {
    if (mouseY>0 && height/2>mouseY) {
      gameMode=GameType.SURVIVAL;
      playerSetup();
      controllerSetup();
      resetGame();
    }
  }
  fill(255, 255, 150);
  rect(0, 0, width/2, height/2);
  if (mousePressed&&mouseX>width/2 && width>mouseX) {
    if (mouseY>0 && height/2>mouseY) {
      gameMode=GameType.BRAWL;
      playerSetup();
      controllerSetup();
      resetGame();
    }
  }
  fill(60, 255, 150);
  rect(width/2, 0, width/2, height/2);
  if (mousePressed&&mouseX>0 && width/2>mouseX) {
    if (mouseY>height/2 && height>mouseY) {
      gameMode=GameType.WILDWEST;
      playerSetup();
      controllerSetup();
      resetGame();
    }
  }
  fill(120, 255, 150);
  rect(0, height/2, width/2, height/2);
  if (mousePressed&&mouseX> width/2 && width>mouseX) {
    if (mouseY>height/2 && height>mouseY) {
      gameMode=GameType.SHOP;
      //playerSetup();
      //controllerSetup();
      resetGame();
    }
  }
  fill(180, 255, 150);
  rect( width/2, height/2, width/2, height/2);

  fill(0, 0, 0);
  text(GameType.SURVIVAL.toString(), width/4, height/4);
  text(GameType.BRAWL.toString(), width/2+width/4, height/4);
  text(GameType.WILDWEST.toString(), width/4, height/2+height/4);
  text(GameType.SHOP.toString(), width/2+width/4, height/2+height/4);
  text(coins +" coins", width/2+width/4, height/2+height/3);
}

void shopUpdate() {
  background(255);
  int i=0;
  textSize(40);
  text(coins +" coins", width/2, 70);
  textSize(10);
  for (Ability a : abilityList) {

    if (!a.unlocked) {
      tint(255, (a.unlockCost>coins)?40:255);
      image(a.icon, 120+(i*120)%(width-220), 160+int(i*120/(width-220))*140, 80, 80);
      fill((a.unlockCost>coins)?240:0);
      text(a.unlockCost, 120+(i*120)%(width-220), 240+int(i*120/(width-220))*140);
    } else {
      tint(80, 255, 255);
      image(a.icon, 120+(i*120)%(width-220), 160+int(i*120/(width-220))*140, 80, 80);
      fill(80, 255, 255);
      text("[UNLOCKED]", 120+(i*120)%(width-220), 240+int(i*120/(width-220))*140);
    }
    text(a.name, 120+(i*120)%(width-220), 220+int(i*120/(width-220))*140);

    i++;
  }
}
class Button {
}