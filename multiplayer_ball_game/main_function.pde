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
    for (int i=0; i<players.size (); i++) {       
      for (int j=0; j<players.size (); j++) {       
        if (players.get(i).ally!=players.get(j).ally && j!=i && !players.get(i).dead && !players.get(j).dead ) {
          if (dist(players.get(i).x, players.get(i).y, players.get(j).x, players.get(j).y)<playerSize) {
            players.get(i).hit(players.get(j).damage);
            //players.get(i).pushForce( players.get(j).vx,players.get(j).vy, players.get(j).angle+180);
            // players.get(i).ax=players.get(j).ax;
            //  players.get(i).ay=players.get(j).ay;
          }
        }
      }
    }
  }
}

void checkPlayerVSProjectileColloision() {
  if (!freeze &&!reverse) {
    for (int i=0; i< projectiles.size (); i++) {    
      for (int j=0; j<players.size (); j++) {      
        if (players.get(j).ally!=projectiles.get(i).ally && !players.get(j).dead && !projectiles.get(i).dead && projectiles.get(i).playerIndex!=j  ) {
          if (dist(projectiles.get(i).x, projectiles.get(i).y, players.get(j).x+players.get(j).w*0.5, players.get(j).y+players.get(j).h*0.5)<playerSize) {
            //  players.get(j).hit(projectiles.get(i).damage);
            players.get(j).pushForce(projectiles.get(i).force, projectiles.get(i).angle);
            projectiles.get(i).hit(players.get(j));
          }
        }
      }
    }
  }
}
/*void checkProjectileVSProjectileColloision() {
  if (!freeze &&!reverse) {
    for (int i=0; i< projectiles.size (); i++) {    
      for (int j=0; j<projectiles.size (); j++) {      
        if (projectiles.get(j).ally!=projectiles.get(i).ally && !projectiles.get(j).dead && !projectiles.get(i).dead && projectiles.get(i)!=projectiles.get(j)  ) {
          if (dist(projectiles.get(i).x, projectiles.get(i).y, projectiles.get(j).x, projectiles.get(j).y)<projectiles.get(i).size+projectiles.get(j).size) {
            if (projectiles.get(i) instanceof  Reflectable) {
              
              projectiles.get(i).reflect(projectiles.get(j).angle,projectiles.get(j).owner);
            }
          }
        }
      }
    }
  }
}
*/

void checkPlayerVSProjectileColloisionLine() {
}

void checkWinner() {
  int playerAliveIndex=0;
  playersAlive=0;
  for (int i=0; i<players.size (); i++) {      
    if (!players.get(i).dead && !players.get(i).turret && !players.get(i).clone) {
      playersAlive++;
      playerAliveIndex=players.get(i).index;
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
      GUILayer.vertex(offsetX-(75*S*F), offsetY+100);
      GUILayer.vertex(offsetX, offsetY+200);
      GUILayer.endShape();
      GUILayer.endDraw();
    }
    if (!reverse) {
      GUILayer.beginDraw();
      GUILayer.clear();
      GUILayer.beginShape();
      GUILayer.vertex(offsetX, offsetY);
      GUILayer.vertex(offsetX+(75*S*F), offsetY+100);
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
  ellipse(pmouseX, pmouseY, 10, 10);
  point(mouseX, mouseY);
}