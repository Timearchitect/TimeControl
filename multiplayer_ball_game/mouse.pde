
void mousePressed() {
  for (int i=0; i< players.size (); i++) {
    if (players.get(i).mouse &&(!reverse || players.get(i).reverseImmunity || players.get(i).ability.meta)) { 
      if (mouseButton==LEFT) {
        players.get(i).ability.press();
        players.get(i).holdTrigg=true;
      }
    }
  }

}
void mouseHold() {
  for (int i=0; i< players.size (); i++) {
    if (players.get(i).mouse &&(!reverse || players.get(i).reverseImmunity || players.get(i).ability.meta)) { 

      if (players.get(i).holdTrigg) {// ability trigg key
        players.get(i).ability.hold();
      }
    }
  }
}
void mouseReleased() {
  for (int i=0; i< players.size (); i++) {
    if (players.get(i).mouse &&(!reverse || players.get(i).reverseImmunity|| players.get(i).ability.meta)) { 
      if (mouseButton==LEFT) {
        players.get(i).holdTrigg=false;
        players.get(i).ability.release();
      }
    }
  }
}