void keyPressed() {

  key=Character.toLowerCase(key);// convert key to lower Case
  if (key == '#') {                    // enablecheats
    cheatEnabled=(cheatEnabled==true)?false:true;
    println(cheatEnabled);
  }
  if (key == '¤') {      
    //ac.setPause(true);
    musicPlayer.pause(true);
    particles.add(new Flash(3000, 3, 0));
  }


  if ((cheatEnabled||playersAlive<=1 ) && key==ResetKey) {
    for (int i=0; i<players.size (); i++) {      
      if (!players.get(i).clone &&  !players.get(i).turret) {  // no turret or clone respawn
        players.get(i).reset();
      }
    }
  }

  if (cheatEnabled ) {
    if (key==Character.toLowerCase(RandomKey)) {
      for (int i=0; i<players.size()-1; i++) {
        if (!players.get(i).clone &&  !players.get(i).turret) {  // no turret or clone weapon switch
           abilities[i].reset();
          abilities[i]=new Random().randomize();
          //abilities[i].owner=players.get(i);
          abilities[i].setOwner(players.get(i));
          players.get(i).ability=abilities[i];
        }
      }
    }
    if (key==Character.toLowerCase('9')) {
      for (int i=0; i<players.size()-1; i++) {
        if (!players.get(i).clone &&  !players.get(i).turret) {  // no turret or clone weapon switch
          try {
            abilities[i]=new ThrowDagger().clone();
          }
          catch(CloneNotSupportedException e) {
            println("not cloned from Random");
          }
          //abilities[i].owner=players.get(i);
          abilities[i].setOwner(players.get(i));
          players.get(i).ability=abilities[i];
        }
      }
    }
    if (key==Character.toLowerCase(keyIceDagger)) {
      projectiles.add( new IceDagger(players.get(1), int( players.get(1).x+players.get(1).w/2), int(players.get(1).y+players.get(1).h/2), 30, players.get(1).playerColor, 800, players.get(1).angle, players.get(1).ax*15, players.get(1).ay*15, 8));
    }
    if (key==Character.toLowerCase( keySlow)) {
      quitOrigo();
      musicPlayer.pause(false);
      slow=(slow)?false:true;
      S =(slow)?slowFactor:1;
      speedControl.clear();
      speedControl.addSegment((reverse)?-1*S*F:1*S*F, 800); //now slow
      drawTimeSymbol();
    }
    if (key==Character.toLowerCase(keyRewind)) {

      for (int i=0; i< players.size (); i++) {
        if (!reverse || players.get(i).reverseImmunity) { 
          if (key==Character.toLowerCase(players.get(i).triggKey)) {// ability trigg key
            players.get(i).ability.release();
            players.get(i).holdTrigg=false;
          }
        }
      }
      musicPlayer.pause(false);
      reverse=(reverse)?false:true;
      speedControl.clear();
      speedControl.addSegment((reverse)?-1*S*F:1*S*F, 600); //now rewind
      controlable=(controlable)?false:true;
      drawTimeSymbol();
      quitOrigo();
    }
    if (key==Character.toLowerCase(keyFreeze)) {
      quitOrigo();
      for (int i=0; i<players.size (); i++) {  
        stamps.add( new ControlStamp(players.get(i).index, int(players.get(i).x), int(players.get(i).y), players.get(i).vx, players.get(i).vy, players.get(i).ax, players.get(i).ay));
      }
      freeze=(freeze)?false:true;
      speedControl.clear();
      speedControl.addSegment((freeze)?0:1, 150); //now stop
      controlable=(controlable)?false:true;
      for (int i=0; i< players.size (); i++) {
        //stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new ControlStamp(i, int(players.get(i).x), int( players.get(i).y), 0, 0, 0, 0));
        stamps.add( new ControlStamp(i, int(players.get(i).x), int( players.get(i).y), players.get(i).vx, players.get(i).vy, players.get(i).ax, players.get(i).ay));
      }
      controlable=(controlable)?false:true;
      drawTimeSymbol();
    }
    if (key==Character.toLowerCase(keyFastForward)) {
      quitOrigo();
      background(0, 255, 255);
      fastForward=(fastForward)?false:true;
      F =(fastForward)?speedFactor:1;
      speedControl.clear();
      speedControl.addSegment((reverse)?-1*S*F:1*S*F, 400); //now fastforward
      //controlable=(controlable)?false:true;
      drawTimeSymbol();
    }
  }

  //println(" code: "+ keyCode+"  key:"+int(key)+ " char:"+key  );  // test key code
  for (int i=0; i< players.size (); i++) {
    //if (keyCooldown[i]<=0) {
    if ((!reverse || players.get(i).reverseImmunity)|| players.get(i).ability.meta) { 
      if (key==Character.toLowerCase(players.get(i).triggKey)) {// ability trigg key
        // background(255);
        players.get(i).ability.press();
        players.get(i).holdTrigg=true;
      }
    }

    if (keyCode==players.get(i).up) {//up
      if ((!reverse || players.get(i).reverseImmunity))players.get(i).control(1);
      players.get(i).holdUp=true;
    }
    if (keyCode==players.get(i).down) {//down
      if ((!reverse || players.get(i).reverseImmunity)) players.get(i).control(0);
      players.get(i).holdDown=true;
    }
    if (keyCode==players.get(i).left) {//left
      if ((!reverse || players.get(i).reverseImmunity)) players.get(i).control(4);
      players.get(i).holdLeft=true;
    }
    if (keyCode==players.get(i).right) {//right
      if ((!reverse || players.get(i).reverseImmunity)) players.get(i).control(5);
      players.get(i).holdRight=true;
    }
  }
  //   keyCooldown[i]=keyResponseDelay;

  // keyCooldown[i]--;
  //  }
}
void checkKeyHold() { // hold keys
  for (int i=0; i< players.size (); i++) {
    { 
      if (players.get(i).holdTrigg) {// ability trigg key
        if (!reverse || players.get(i).reverseImmunity)players.get(i).ability.hold();
      }
      if (players.get(i).holdUp) {//up
        if (!reverse || players.get(i).reverseImmunity) players.get(i).control(1);
      }
      if (players.get(i).holdDown) {//down
        if (!reverse || players.get(i).reverseImmunity)players.get(i).control(0);
      }
      if (players.get(i).holdLeft) {//left
        if (!reverse || players.get(i).reverseImmunity)players.get(i).control(4);
      }
      if (players.get(i).holdRight) {//right
        if (!reverse || players.get(i).reverseImmunity) players.get(i).control(5);
      }
    }
  }
}

void keyReleased() {
  for (int i=0; i< players.size (); i++) {

    if (key==Character.toLowerCase(players.get(i).triggKey)) {// ability trigg key
      if ( players.get(i).ability.meta || !reverse)  players.get(i).ability.release();
      players.get(i).holdTrigg=false;
    }

    // if (!reverse || players.get(i).reverseImmunity) { 

    if (keyCode==players.get(i).up) {//up
      players.get(i).holdUp=false;
    }
    if (keyCode==players.get(i).down) {//down
      players.get(i).holdDown=false;
    }
    if (keyCode==players.get(i).left) {//left
      players.get(i).holdLeft=false;
    }
    if (keyCode==players.get(i).right) {//right
      players.get(i).holdRight=false;
    }
  }
}