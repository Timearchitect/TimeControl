boolean pMousePressed;
void mousePressed() {
  if (cheatEnabled)if (mouseButton==RIGHT)coins-=100;
  else coins+=100;
  try {
    for (Player p : players) {
      if (p.mouse && !p.stunned&&(!reverse || p.reverseImmunity || p.abilityList.get(0).meta)) { 
        if (mouseButton==LEFT) {
          //p.ability.press();
          for (Ability a : p.abilityList)  a.press();
          p.holdTrigg=true;
        }
      }
    }
  }
  catch(Exception e) {
    println(e +" mouse");
  }
  if (cheatEnabled) {
    // if (mouseButton==LEFT) particles.add(new TempZoom(mouseX, mouseY, 2000, 1,DEFAULT_ZOOMRATE,false));
    // if (mouseButton==RIGHT)particles.add(new TempZoom(mouseX, mouseY, 2000, 0.5,DEFAULT_ZOOMRATE,false));
    //spawn(new HomingMissile(AI, mouseX, mouseY, 70, BLACK, 5000, 0, 0, 0, 10));

    // float X=(mouseX*zoom)+(width*(1-zoom)*mouseX);
    // float Y=(mouseY*zoom)+(height*(1-zoom)*mouseY);
    ellipse((float)mouseX, (float)mouseY, 200, 200);
    for (int i=0; i<players.size(); i++) {
      if (!players.get(i).dead && dist(players.get(i).cx, players.get(i).cy, mouseX, mouseY)<100) {
        mouseSelectedPlayerIndex=i;
        particles.add( new Text("player "+(i+1)+" selected", int(mouseX), int(mouseY-75), 0, 0, 40, 0, 500, color(players.get(i).playerColor), 1));
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
    if (p.mouse && !p.stunned&&(!reverse || p.reverseImmunity || p.abilityList.get(0).meta)) { 
      if (p.holdTrigg) {// ability trigg key
        //p.ability.hold();
        for (Ability a : p.abilityList) a.hold();
      }
    }
  }
}
void mouseReleased() {
  for (Player p : players) {
    if (p.mouse && !p.stunned &&(!reverse || p.reverseImmunity|| p.abilityList.get(0).meta)) { 
      if (mouseButton==LEFT) {
        p.holdTrigg=false;
        // p.ability.release();
        for (Ability a : p.abilityList)  a.release();
      }
    }
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
    mouseScroll=0;
  if (e>0) {
    mouseScroll=1;
  } else {
      mouseScroll=-1;
  }
  //println(e);
}