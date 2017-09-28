void keyPressed() {
  if (key==27) {   // ESC disable to EXIT() show pausescreen instead 
    if (gameMode==GameType.MENU) {
      exit();
    } else { 
      cheatEnabled=false;
      gameMode=GameType.MENU;        
      clearGame();  
      key=0;
    }
  }
  //println(int(keyCode));
  if (keyCode==148) { // PAUSE

    background(255);
  }
  key=Character.toLowerCase(key);// convert key to lower Case
  if (key == '#') {                    // enablecheats
    cheatEnabled=(cheatEnabled==true)?false:true;
  }
  if (key == '"') {                    // enablecheats
    debug=(debug==true)?false:true;
  }

  if (key == '¤') {      
    //ac.setPause(true);
    mute=!mute;
    musicPlayer.pause(mute);
    particles.add(new Flash(3000, 3, 0));
  }

  if ((cheatEnabled||playersAlive<=1 ) && key==ResetKey) {

    if (!noFlash) background(255);
    for (int i =players.size()-1; i>= 0; i--) {
      if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
    }


    //random weapon
    for (Player p : players) {    
      if (p!=AI&&!p.clone &&  !p.turret) {  // no turret or clone respawn
        p.reset();
        announceAbility( p, 1);
      } else {
        p.dead=true;
        p.state=0;
      }
    }

    //random weapon end

    for (Player p : players) {      
      if (p.index!=-1 )
        if (p!=AI &&!p.clone &&  !p.turret) {  // no turret or clone respawn
          p.reset();
          announceAbility( p, 0);
        } else {
          p.dead=true;
          p.state=0;
        }
    }


    resetGame();
  }

  if (cheatEnabled ) {
    if (key == ')') {                    // enablecheats
      coins=999999;
    }
    if (key == '=') {                    // enablecheats
      coins=0;
    }
    if (key=='!') {
      hitBox=!hitBox;
    }
    if (key==Character.toLowerCase('6')) {

      generateRandomAbilities(1, passiveList, true);
    }
    if (key==Character.toLowerCase(RandomKey)) {
      generateRandomAbilities(0, abilityList, true);
    }
    if (key==Character.toLowerCase('9')) {
      for (int i=0; i<players.size()-1; i++) {
        if (!players.get(i).clone &&  !players.get(i).turret) {  // no turret or clone weapon switch
          try {
            abilities[i][0]=new Detonator().clone();
          }
          catch(CloneNotSupportedException e) {
            println("not cloned from Random");
          }
          //abilities[i].owner=players.get(i);
          abilities[i][0].setOwner(players.get(i));
          //players.get(i).ability=abilities[i];
        }
      }
    }
    if (key==Character.toLowerCase('8')) {

      for (Player p : players) {      
        if (!p.clone &&  !p.turret) {  // no turret or clone weapon switch
          p.abilityList.get(0).energy=99999;
        }
      }
      /*
      for (int i=0; i<players.size(); i++) {
       if (!players.get(i).clone &&  !players.get(i).turret) {  //infinate energy
       //abilities[i].owner=players.get(i);
       players.get(i).ability.energy=9999999;
       }
       }*/
    }
    if (key=='/') {
      for(Button b:bList)b.a.unlocked=true;
    }
    if (key=='*') {
      for(Button b:bList)if(b.a.sellable)b.a.unlocked=false;
    }
    if (key==DELETE) {
      clearGame();
    }
    if (key==Character.toLowerCase('-')) {
      //players.get(mouseSelectedPlayerIndex).ability.reset();
      for (int i =players.size()-1; i>= 0; i--) {
        if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
      }
      players.get(mouseSelectedPlayerIndex).abilityList.get(0).reset();
      for (  int i=0; i<abilityList.length; i++) {
        if (players.get(mouseSelectedPlayerIndex).abilityList.get(0).getClass()==abilityList[i].getClass()) {
          if (i<=0)i=abilityList.length;
          try {
            players.get(mouseSelectedPlayerIndex).abilityList.set(0, abilityList[i-1].clone());
            players.get(mouseSelectedPlayerIndex).abilityList.get(0).setOwner(players.get(mouseSelectedPlayerIndex));
            announceAbility( players.get(mouseSelectedPlayerIndex), 0);
          }
          catch(CloneNotSupportedException e) {
            println("not cloned from Random");
          }
        } //else println("not player"+ i);
      }
    }
    if (key==Character.toLowerCase('+')) {
      //players.get(mouseSelectedPlayerIndex).ability.reset();
      for (int i =players.size()-1; i>= 0; i--) {
        if (players.get(i).turret || players.get(i).clone) players.remove( players.get(i));
      }
      players.get(mouseSelectedPlayerIndex).abilityList.get(0).reset();
      for (  int i=0; i<abilityList.length; i++) {
        if (players.get(mouseSelectedPlayerIndex).abilityList.get(0).getClass()==abilityList[i].getClass()) {
          //println("ability match "+i+" "+abilityList[i].getClass());
          if (i>=abilityList.length-1)i=-1;
          try {
            players.get(mouseSelectedPlayerIndex).abilityList.set(0, abilityList[i+1].clone());
            players.get(mouseSelectedPlayerIndex).abilityList.get(0).setOwner(players.get(mouseSelectedPlayerIndex));
            announceAbility( players.get(mouseSelectedPlayerIndex), 0);
          }
          catch(CloneNotSupportedException e) {
            println("not cloned from Random");
          }
          break;
        }
      }
      /* players.get(mouseSelectedPlayerIndex).ability.reset();
       for (  int i=0; i<abilityList.length; i++) {
       if (players.get(mouseSelectedPlayerIndex).ability.getClass()==abilityList[i].getClass()) {
       //println("ability match "+i+" "+abilityList[i].getClass());
       if (i>=abilityList.length-1)i=-1;
       try {
       players.get(mouseSelectedPlayerIndex).ability=abilityList[i+1].clone();
       players.get(mouseSelectedPlayerIndex).ability.setOwner(players.get(mouseSelectedPlayerIndex));
       announceAbility( players.get(mouseSelectedPlayerIndex));
       }
       catch(CloneNotSupportedException e) {
       println("not cloned from Random");
       }
       break;
       }
       }*/
    }
    /*if (key==Character.toLowerCase(keyIceDagger)) {
     projectiles.add( new IceDagger(players.get(1), int( players.get(1).x+players.get(1).w*.5), int(players.get(1).y+players.get(1).h*.5), 30, players.get(1).playerColor, 800, players.get(1).angle, players.get(1).ax*15, players.get(1).ay*15, 8));
     }*/
    if (key==Character.toLowerCase( keySlow)) {
      quitOrigo();
      musicPlayer.pause(false);
      slow=(slow)?false:true;
      S =(slow)?slowFactor:1;
      timeBend=S*F;
      speedControl.clear();
      speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 800); //now slow
      drawTimeSymbol();
    }
    if (key==Character.toLowerCase(keyRewind)) {

      for (int i=0; i< players.size (); i++) {
        if (!reverse || players.get(i).reverseImmunity) { 
          if (key==Character.toLowerCase(players.get(i).triggKey)) {// ability trigg key
            //players.get(i).ability.release();
            for (Ability a : players.get(i).abilityList)  a.release();
            players.get(i).holdTrigg=false;
          }
        }
      }
      musicPlayer.pause(false);
      reverse=(reverse)?false:true;
      speedControl.clear();
      speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 600); //now rewind
      controlable=(controlable)?false:true;
      drawTimeSymbol();
      quitOrigo();
    }
    if (key==Character.toLowerCase(keyFreeze)) {
      quitOrigo();
      /* for (int i=0; i<players.size (); i++) {  
       stamps.add( new ControlStamp(players.get(i).index, int(players.get(i).x), int(players.get(i).y), players.get(i).vx, players.get(i).vy, players.get(i).ax, players.get(i).ay));
       }*/
      for (Player p : players) {  
        stamps.add( new ControlStamp(p.index, int(p.x), int(p.y), p.vx, p.vy, p.ax, p.ay));
      }
      freeze=(freeze)?false:true;
      speedControl.clear();
      speedControl.addSegment((freeze)?0:1, 150); //now stop
      controlable=(controlable)?false:true;
      /*for (int i=0; i< players.size (); i++) {
       //stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
       stamps.add( new ControlStamp(i, int(players.get(i).x), int( players.get(i).y), 0, 0, 0, 0));
       samps.add( new ControlStamp(i, int(players.get(i).x), int( players.get(i).y), players.get(i).vx, players.get(i).vy, players.get(i).ax, players.get(i).ay));
       }*/

      for (Player p : players) { 
        //stamps.add( new AbilityStamp(player.index, int(player.x), int(player.y), energy, active, channeling, cooling, regen, hold));
        stamps.add( new ControlStamp(p.index, int(p.x), int( p.y), 0, 0, 0, 0));
        stamps.add( new ControlStamp(p.index, int(p.x), int( p.y), p.vx, p.vy, p.ax, p.ay));
      }

      controlable=(controlable)?false:true;
      drawTimeSymbol();
    }
    if (key==Character.toLowerCase(keyFastForward)) {
      quitOrigo();
      if (!noFlash)background(0, 255, 255);
      fastForward=(fastForward)?false:true;
      F =(fastForward)?speedFactor:1;
      timeBend=S*F;
      speedControl.clear();
      speedControl.addSegment((reverse)?-1*timeBend:1*timeBend, 400); //now fastforward
      //controlable=(controlable)?false:true;
      drawTimeSymbol();
    }
  }

  //println(" code: "+ keyCode+"  key:"+int(key)+ " char:"+key  );  // test key code
  /* for (int i=0; i< players.size (); i++) {
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
   }*/
  try {
    for (Player p : players) {
      if (!p.turret && !p.stunned) {
        if ((!reverse || p.reverseImmunity)|| p.abilityList.get(0).meta) { 
          if (key==Character.toLowerCase(p.triggKey)) {// ability trigg key
            //p.ability.press();
            for (Ability a : p.abilityList)  a.press();
            p.holdTrigg=true;
          }
        }

        if (keyCode==p.up) {//up
          if ((!reverse || p.reverseImmunity))p.control(1);
          p.holdUp=true;
        }
        if (keyCode==p.down) {//down
          if ((!reverse || p.reverseImmunity)) p.control(0);
          p.holdDown=true;
        }
        if (keyCode==p.left) {//left
          if ((!reverse || p.reverseImmunity)) p.control(4);
          p.holdLeft=true;
        }
        if (keyCode==p.right) {//right
          if ((!reverse || p.reverseImmunity)) p.control(5);
          p.holdRight=true;
        }
      }
    }
  } 
  catch(Exception e) {
    println(e +" keyboard");
  }

  if (gameMode==GameType.SETTINGS) {
    try {
      for (int i=0; i< players.size()-1; i++) {
        if (key==Character.toLowerCase(players.get(i).triggKey)) {// ability trigg key
                    if(abilities[i][abilitySettingsIndex[i]].type==AbilityType.ACTIVE){
                      abilities[i][abilitySettingsIndex[i]]=new NoPassive();
                    }else abilities[i][abilitySettingsIndex[i]]=new NoActive();
        }

        if (keyCode==players.get(i).down) {//down
          for (  int j=0; j<abilityList.length; j++) {
            if (abilities[i][abilitySettingsIndex[i]].getClass()==abilityList[j].getClass()) {
              while ( j==0 || !abilityList[j-1].unlocked ) {
                j--;
               if (j<=0)j=abilityList.length;
              }    
              try {
                abilities[i][abilitySettingsIndex[i]]= abilityList[j-1].clone();
              }
              catch(CloneNotSupportedException e) {
                println("not cloned from Random");
              }
            }
          }
           for (  int j=0; j<passiveList.length; j++) {
            if (abilities[i][abilitySettingsIndex[i]].getClass()==passiveList[j].getClass()) {
              while ( j==0 ||!passiveList[j-1].unlocked) {
                if (j<=0)j=passiveList.length;
                j--;
              }
              try {
                abilities[i][abilitySettingsIndex[i]]= passiveList[j-1].clone();
              }
              catch(CloneNotSupportedException e) {
                println("not cloned from Random");
              }
            }
          }
        }
        if (keyCode==players.get(i).up) {//up
          // print("change Ability down ");
          for (  int j=0; j<abilityList.length; j++) {
            if (abilities[i][abilitySettingsIndex[i]].getClass()==abilityList[j].getClass()) {

              while ( j>=abilityList.length-1 ||!abilityList[j+1].unlocked) {
                if (j>=abilityList.length-1)j=-2;
                j++;
              }
     
              try {
                abilities[i][abilitySettingsIndex[i]]= abilityList[j+1].clone();
              }
              catch(CloneNotSupportedException e) {
                println("not cloned from Random");
              }

              break;
            }
          }
          for (  int j=0; j<passiveList.length; j++) {
            if (abilities[i][abilitySettingsIndex[i]].getClass()==passiveList[j].getClass()) {
              while (j>=passiveList.length-1 ||!passiveList[j+1].unlocked) {
                if (j>=passiveList.length-1)j=-2;
                j++;
              }
              try {
                abilities[i][abilitySettingsIndex[i]]= passiveList[j+1].clone();
              }
              catch(CloneNotSupportedException e) {
                println("not cloned from Random");
              }

              break;
            }
          }
        }
        if (keyCode==players.get(i).left) {//left
          if (abilitySettingsIndex[i]>0) abilitySettingsIndex[i]--;
        }
        if (keyCode==players.get(i).right) {//right
          if (abilitySettingsIndex[i]<players.get(i).abilityList.size()-1) abilitySettingsIndex[i]++;
        }
      }
    } 
    catch(Exception e) {
      println(e +" keyboard");
    }
    /* sBList.clear();
     for (int j=0; j<AmountOfPlayers; j++) {
     for (int i=0; i<2; i++) {
     sBList.add( new SettingButton(i, 600+200*i, 200+200*j, 100, players.get(j)) );
     }
     }*/
  }

  //   keyCooldown[i]=keyResponseDelay;

  // keyCooldown[i]--;
  //  }
}
void checkKeyHold() { // hold keys
  /*for (int i=0; i< players.size (); i++) {
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
   }*/
  for (Player p : players) {
    { 
      if (!p.turret&& !p.stunned) {
        if (p.holdTrigg) {// ability trigg key
          if (!reverse || p.reverseImmunity) {
            //p.ability.hold();
            for (Ability a : p.abilityList)  a.hold();
          }
        }
        if (p.holdUp) {//up
          if (!reverse || p.reverseImmunity) p.control(1);
        }
        if (p.holdDown) {//down
          if (!reverse || p.reverseImmunity)p.control(0);
        }
        if (p.holdLeft) {//left
          if (!reverse || p.reverseImmunity)p.control(4);
        }
        if (p.holdRight) {//right
          if (!reverse || p.reverseImmunity) p.control(5);
        }
      }
    }
  }
}

void keyReleased() {

  key=Character.toLowerCase(key);// convert key to lower Case

  /* for (int i=0; i< players.size (); i++) {
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
   }*/
  for ( Player p : players) {
    if (!p.turret&& !p.stunned) {
      if (key==Character.toLowerCase(p.triggKey)) {// ability trigg key
        if ( p.abilityList.get(0).meta || !reverse)  //p.ability.release();
          for (Ability a : p.abilityList)  a.release();
        p.holdTrigg=false;
      }
      if (keyCode==p.up) {//up
        p.holdUp=false;
      }
      if (keyCode==p.down) {//down
        p.holdDown=false;
      }
      if (keyCode==p.left) {//left
        p.holdLeft=false;
      }
      if (keyCode==p.right) {//right
        p.holdRight=false;
      }
    }
  }
}