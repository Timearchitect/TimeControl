
void mousePressed() {
  /*  for (int i=0; i< players.size (); i++) {
   if (players.get(i).mouse &&(!reverse || players.get(i).reverseImmunity || players.get(i).ability.meta)) { 
   if (mouseButton==LEFT) {
   players.get(i).ability.press();
   players.get(i).holdTrigg=true;
   }
   }
   }*/
  try {
    for (Player p : players) {
      if (p.mouse &&(!reverse || p.reverseImmunity || p.ability.meta)) { 
        if (mouseButton==LEFT) {
          p.ability.press();
          p.holdTrigg=true;
        }
      }
    }
  }
  catch(Exception e) {
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
    if (p.mouse &&(!reverse || p.reverseImmunity || p.ability.meta)) { 
      if (p.holdTrigg) {// ability trigg key
        p.ability.hold();
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
    if (p.mouse &&(!reverse || p.reverseImmunity|| p.ability.meta)) { 
      if (mouseButton==LEFT) {
        p.holdTrigg=false;
        p.ability.release();
      }
    }
  }
}