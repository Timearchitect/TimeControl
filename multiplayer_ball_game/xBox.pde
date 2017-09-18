
Controller controller;
ControllerListener cl;
ControllerEnvironment ce;
Component components[]= new Component[20];
Event event=new Event();
EventQueue queue;
Rumbler[] rumb;
Player xBoxPlayer; 
int inputSize=4,xboxIndex=2;
float threshhold=0.3;
boolean xBoxInput[]=new boolean [5];
void xBoxSetup() {
  try {
    ce= ControllerEnvironment.getEnvironment();
    for (Controller c : ce.getControllers()) {
      println(c.getType(),c.getName());
      if (c.getType()== Controller.Type.GAMEPAD) {
        controller=c;
        println(c.getName());
      }
    }
    for (Component c : controller.getComponents()) {
      println(c.getName());
    }
    println("selected:"+controller);
    controller.setEventQueueSize(inputSize);
    components=controller.getComponents();
    queue = controller.getEventQueue();
    controller.poll();
    rumb=controller.getRumblers();
    println("rumbles : ", rumb.length);
 
  }
  catch(Exception e) {
    println(e);
  }
  println(players.size(),xboxIndex);
}

void getXboxInput() {
  if (controller!=null && players.size()>=xboxIndex) {
    controller.poll();
   xBoxPlayer=players.get(xboxIndex);
    while (queue.getNextEvent(event)) {
      println(event.getComponent().getName());
      //if(queue.getNextEvent(event)){
      // println(event.getComponent().getName(), event.getValue());
      switch(event.getComponent().getName()) {
      case "X-axeln":
        if (event.getValue()<-threshhold) // left
          xBoxInput[0]=true;
        else xBoxInput[0]=false;
        if (event.getValue()>threshhold) //right
          xBoxInput[1]=true;
        else xBoxInput[1]=false;
        break ;
      case "Y-axeln":
        if (event.getValue()<-threshhold) // up
          xBoxInput[3]=true;
        else xBoxInput[3]=false;
        if (event.getValue()>threshhold) //down
          xBoxInput[2]=true;
        else xBoxInput[2]=false;
        break ;
      case "Knapp 1":
        if (event.getValue()==1) {
          xBoxInput[4]=true;
        } else {
          xBoxInput[4]=false;
        }
        break ;
      case "Knapp 0":
        if (event.getValue()==1) {
          xBoxInput[4]=true;
        } else {
          xBoxInput[4]=false;
        }
        break ;
      case "Styrknapp":
        switch(int(event.getValue()*1000)) {

        case 1000:
          xBoxInput[3]=false;//up
          xBoxInput[0]=true;
          xBoxInput[1]=false;//down
          println("left");
          break;
        case 125:
          xBoxInput[3]=true;//up
          xBoxInput[0]=true;
          println("leftup");
          break;
        case 250:
          xBoxInput[0]=false;//left
          xBoxInput[3]=true;
          xBoxInput[1]=false;//right
          println("up");
          break;
        case 375:
          xBoxInput[3]=true;
          xBoxInput[1]=true;//right
          println("upright");
          break;
        case 500:
          xBoxInput[3]=false;//up
          xBoxInput[1]=true;
          xBoxInput[2]=false;//down
          println("right");
          break;
        case 625:
          xBoxInput[1]=true;
          xBoxInput[2]=true;//down
          println("rightdown");
          break;
        case 750:
          xBoxInput[0]=false;//left
          xBoxInput[2]=true;
          xBoxInput[1]=false;//right
          println("down");
          break;
        case 875:
          xBoxInput[0]=true;//left
          xBoxInput[2]=true;
          println("downleft");
          break;
        default:
          xBoxInput[0]=false;
          xBoxInput[1]=false;
          xBoxInput[2]=false;
          xBoxInput[3]=false;
          break;
        }
        println(event.getValue());
        break;
      case "Knapp 2":
        if (event.getValue()==1) {
          if (cheatEnabled )generateRandomAbilities(1, passiveList, true);
        }
        break ;
      case "Knapp 3":
        if (event.getValue()==1) {
          if (cheatEnabled )generateRandomAbilities(0, abilityList, true);
        }
        break ;
      case "Knapp 4":
        if (cheatEnabled && event.getValue()==1) {
          xBoxPlayer.abilityList.get(0).reset();
          for (  int i=0; i<abilityList.length; i++) {
            if (xBoxPlayer.abilityList.get(0).getClass()==abilityList[i].getClass()) {
              if (i<=0)i=abilityList.length;
              try {
                xBoxPlayer.abilityList.set(0, abilityList[i-1].clone());
                xBoxPlayer.abilityList.get(0).setOwner(xBoxPlayer);
                announceAbility( xBoxPlayer, 0);
              }
              catch(CloneNotSupportedException e) {
                println("not cloned from Random");
              }
            } //else println("not player"+ i);
          }
        }
        break;
      case "Knapp 5":
        if (cheatEnabled && event.getValue()==1) {
          xBoxPlayer.abilityList.get(0).reset();
          for (  int i=0; i<abilityList.length; i++) {
            if (xBoxPlayer.abilityList.get(0).getClass()==abilityList[i].getClass()) {
              if (i>=abilityList.length-1)i=-1;
              try {
                xBoxPlayer.abilityList.set(0, abilityList[i+1].clone());
                xBoxPlayer.abilityList.get(0).setOwner(xBoxPlayer);
                announceAbility( xBoxPlayer, 0);
              }
              catch(CloneNotSupportedException e) {
                println("not cloned from Random");
              }
              break;
            }
          }
        }
        break;
      case "Knapp 7":
        if (event.getValue()==1) {
          if (cheatEnabled||playersAlive<=1) {

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
        }
        break ;
      case "Knapp 6":
        if (gameMode==GameType.MENU) {
          exit();
        } else { 
          cheatEnabled=false;
          gameMode=GameType.MENU;        
          clearGame();
        }
        break;
      }
    }


    if (xBoxPlayer.hit) {
      for (Rumbler r : rumb) {
        r.rumble(1);
        println("rumble");
      }
    }

    if (xBoxInput[4] && !xBoxPlayer.holdTrigg) {// ability trigg key
      //p.ability.press();
      for (Ability a : xBoxPlayer.abilityList)  a.press();
      xBoxPlayer.holdTrigg=true;
    } else if ( !xBoxInput[4] &&  xBoxPlayer.holdTrigg) {    
      for (Ability a : xBoxPlayer.abilityList)  a.release();
      xBoxPlayer.holdTrigg=false;
    }


    if (xBoxInput[3]) {//up
      if ((!reverse || xBoxPlayer.reverseImmunity))xBoxPlayer.control(1);
      xBoxPlayer.holdUp=true;
    }
    if (xBoxInput[2]) {//down
      if ((!reverse || xBoxPlayer.reverseImmunity)) xBoxPlayer.control(0);
      xBoxPlayer.holdDown=true;
    }
    if (xBoxInput[0]) {//left
      if ((!reverse || xBoxPlayer.reverseImmunity)) xBoxPlayer.control(4);
      xBoxPlayer.holdLeft=true;
    }
    if (xBoxInput[1]) {//right
      if ((!reverse || xBoxPlayer.reverseImmunity)) xBoxPlayer.control(5);
      xBoxPlayer.holdRight=true;
    }






  
  }
}