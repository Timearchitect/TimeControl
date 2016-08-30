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
  text("add Time: "+addMillis+" freezeTime: " + freezeTime+" reversed: " + reversedTime+" forward: " + forwardTime+ " current: "+  stampTime +" fallenTime: "+fallenTime, width*0.5, 50);
  text("version: "+version, width*0.5, 20);
  text("players: "+players.size()+" projectiles: "+projectiles.size()+" particles: "+particles.size()+" stamps: "+stamps.size(), width*0.5, 75);
  text(frameRate, width-80, 50);
}
void displayClock() {
  fill(0);
  textSize(40);
  text(" Time: "+  int(stampTime*0.001), width*0.5, 60);
  textSize(18);
  text("version: "+version, width*0.5, 20);
}
void screenShake() {
  if (shakeTimer>0) {
    shake(2*shakeTimer);
  } else {
    shakeTimer=0;
  } // shake screen
}
void shake(int amount) {
  int shakeX=0, shakeY=0;
  if (!freeze) {
    shakeX=int(random(amount)-amount*0.5);
    shakeY=int(random(amount)-amount*0.5);
    shakeTimer--;
  }
  translate( shakeX, shakeY);
}

void checkPlayerVSPlayerColloision() {
  if (!freeze &&!reverse) {
    /* for (int i=0; i<players.size (); i++) {       
     for (int j=0; j<players.size (); j++) {       
     if (players.get(i).ally!=players.get(j).ally && j!=i && !players.get(i).dead && !players.get(j).dead ) {
     if (dist(players.get(i).x, players.get(i).y, players.get(j).x, players.get(j).y)<playerSize) {
     players.get(i).hit(players.get(j).damage);
     float deltaY =  players.get(i).y -  players.get(j).y;
     float  deltaX =  players.get(i).x -  players.get(j).x;
     players.get(i).pushForce( playerSize-dist(players.get(j).x, players.get(j).y, players.get(i).x, players.get(i).y), atan2(deltaY, deltaX) * 180 / PI);
     }
     }
     }
     }
     }*/
    for (Player p1 : players) {       
      for (Player p2 : players) {       
        if (p1.ally!=p2.ally && !p1.dead && !p2.dead ) { //  && p1!=p2
          if (dist(p1.x, p1.y, p2.x, p2.y)<playerSize) {
            p1.hit(p2.damage);
            float deltaY =  p1.y -  p2.y;
            float  deltaX =  p1.x -  p2.x;
            p1.pushForce( playerSize-dist(p2.x, p2.y, p1.x, p1.y), atan2(deltaY, deltaX) * 180 / PI);
          }
        }
      }
    }
  }
}

void checkPlayerVSProjectileColloision() {
  if (!freeze &&!reverse) {
    /*for (int i=0; i< projectiles.size (); i++) {    
     for (int j=0; j<players.size (); j++) {      
     if (players.get(j).ally!=projectiles.get(i).ally && !players.get(j).dead && !projectiles.get(i).dead && projectiles.get(i).playerIndex!=j  ) {
     if (dist(projectiles.get(i).x, projectiles.get(i).y, players.get(j).cx, players.get(j).cy)<playerSize) {
     //  players.get(j).hit(projectiles.get(i).damage);
     players.get(j).pushForce(projectiles.get(i).force, projectiles.get(i).angle);
     projectiles.get(i).hit(players.get(j));
     }
     }
     }
     }*/
    try {
      for (Projectile o : projectiles) {    
        for (Player p : players) {      
          if (p.ally!=o.ally && !p.dead && !o.dead ) { // && o.playerIndex!=p.ally
            if (dist(o.x, o.y, p.cx, p.cy)<playerSize) {
              //  players.get(j).hit(projectiles.get(i).damage);
              p.pushForce(o.force, o.angle);
              o.hit(p);
            }
          }
        }
      }
    }
    catch(Exception e) {
    }
  }
}
void checkProjectileVSProjectileColloision() {
  if (!freeze &&!reverse) {
    /* for (int i=0; i< projectiles.size (); i++) {    
     for (int j=0; j<projectiles.size (); j++) {      
     if (projectiles.get(j).ally!=projectiles.get(i).ally && !projectiles.get(j).dead && !projectiles.get(i).dead && projectiles.get(i)!=projectiles.get(j)  ) {
     if (dist(projectiles.get(i).x, projectiles.get(i).y, projectiles.get(j).x, projectiles.get(j).y)<projectiles.get(i).size*0.5+projectiles.get(j).size*0.5) {
     if (projectiles.get(i) instanceof  Reflectable  && projectiles.get(j) instanceof Reflector) {
     Reflectable reflectObject = (Reflectable)projectiles.get(i);
     Reflector reflectorObject = (Reflector)projectiles.get(j);
     reflectObject.reflect(projectiles.get(j).angle, projectiles.get(j).owner);
     reflectorObject.reflecting();
     }
     }
     }
     }
     }*/
    for (Projectile p1 : projectiles) {    
      for (Projectile p2 : projectiles) {      
        if (p2.ally!=p1.ally && !p2.dead && !p1.dead ) { //  && p1!=p2
          if (dist(p1.x, p1.y, p2.x, p2.y)<p1.size*0.5+p2.size*0.5) {
            if (p1 instanceof  Reflectable  && p2 instanceof Reflector) {
              Reflectable reflectObject = (Reflectable)p1;
              Reflector reflectorObject = (Reflector)p2;
              reflectObject.reflect(p2.angle, p2.owner);
              reflectorObject.reflecting();
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
  /*for (int i=0; i<players.size (); i++) {      
   if (!players.get(i).dead && !players.get(i).turret && !players.get(i).clone) {
   playersAlive++;
   playerAliveIndex=players.get(i).index;
   }
   }*/
  for (Player p : players) {      
    if (!p.dead && !p.turret && !p.clone) {
      playersAlive++;
      playerAliveIndex=p.index;
    }
  }

  if (playersAlive==1) {
    textSize(80);
    text(" Winner is player "+(playerAliveIndex+1), width*0.5, height*0.5);
    text(" Press ["+ResetKey+"] to restart", width*0.5, height*0.6);
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
    particles.add(new Flash(1500, 5, color(255)));   // flash
  }
}
void mouseDot() {
  strokeWeight(5);
  //ellipse(pmouseX, pmouseY, 10, 10);
  point(mouseX, mouseY);
}

void announceAbility(Player p, int index ) {
  particles.remove( p.textParticle );

  //particles.add( new Text(p.ability.name, int( p.x+p.w*0.5), int(p.y+p.h*0.5)-75, 0, 0, 30, 0, 2000, color(0)));
  //p.textParticle = new Text(p,p.ability.name, 0, -75, 30, 0, 1500, color(0),0);
  p.textParticle = new Text(p, p.abilityList.get(index).name, 0, -75, 30, 0, 1500, color(0), 0);

  particles.add( p.textParticle );
}