
void mousePressed() {
  if(cheatEnabled)if(mouseButton==RIGHT)coins-=100;else coins+=100;
  try {
    for (Player p : players) {
      if (p.mouse &&(!reverse || p.reverseImmunity || p.abilityList.get(0).meta)) { 
        if (mouseButton==LEFT) {
          //p.ability.press();
          for (Ability a : p.abilityList)  a.press();
          p.holdTrigg=true;
        }
      }
    }
  }
  catch(Exception e) {
    println(e);
  }
  if (cheatEnabled) {
    spawn(new HomingMissile(AI, mouseX, mouseY, 70, BLACK, 5000, 0, 0, 0, 10));

    // float X=(mouseX*zoom)+(width*(1-zoom)*mouseX);
    // float Y=(mouseY*zoom)+(height*(1-zoom)*mouseY);
    float X=mouseX;
    float Y=mouseY;
    ellipse(X, Y, 200, 200);
    for (int i=0; i<players.size(); i++) {
      if (!players.get(i).dead && dist(players.get(i).cx, players.get(i).cy, X, Y)<100) {

        mouseSelectedPlayerIndex=i;
        particles.add( new Text("player "+(i+1)+" selected", int(X), int(Y-75), 0, 0, 40, 0, 500, color(players.get(i).playerColor), 1));
      }
    }
  }
}
void mouseHold() {
  /*for (int i=0; i< players.size (); i++) {
   if (players.get(i).mouse &&(!reverse || players.get(i).reverseImmunity || players.get(i).ability.meta)) { 
   
   if (players.get(i).holdTrigg) {// ability trigg key
   players.get(i).ability.hold();
   }
   }
   }*/
  for (Player p : players) {
    if (p.mouse &&(!reverse || p.reverseImmunity || p.abilityList.get(0).meta)) { 
      if (p.holdTrigg) {// ability trigg key
        //p.ability.hold();
        for (Ability a : p.abilityList) a.hold();
      }
    }
  }
}
void mouseReleased() {
  /* for (int i=0; i< players.size (); i++) {
   if (players.get(i).mouse &&(!reverse || players.get(i).reverseImmunity|| players.get(i).ability.meta)) { 
   if (mouseButton==LEFT) {
   players.get(i).holdTrigg=false;
   players.get(i).ability.release();
   }
   }
   }*/
  for (Player p : players) {
    if (p.mouse &&(!reverse || p.reverseImmunity|| p.abilityList.get(0).meta)) { 
      if (mouseButton==LEFT) {
        p.holdTrigg=false;
        // p.ability.release();
        for (Ability a : p.abilityList)  a.release();
      }
    }
  }
}