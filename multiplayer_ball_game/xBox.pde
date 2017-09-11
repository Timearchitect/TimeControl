
Controller controller;
ControllerListener cl;
ControllerEnvironment ce;
Component components[]= new Component[20];
Event event=new Event();
EventQueue queue;
Rumbler[] rumb;
int inputSize=6;
float threshhold=0.3;
boolean xBoxInput[]=new boolean [5];
void xBoxSetup() {
  try {
    ce= ControllerEnvironment.getEnvironment();
    for (Controller c : ce.getControllers()) {
      println(c.getType());
      if (c.getType()== Controller.Type.GAMEPAD) {
        controller=c;
        println(c.getName());
      }
    }
    for (Component c : controller.getComponents()) {
      println(c.getName());
    }
    controller.setEventQueueSize(inputSize);
    components=controller.getComponents();
    queue = controller.getEventQueue();
    rumb=controller.getRumblers();
  }
  catch(Exception e) {
    println(e);
  }
}

void getXboxInput() {
  if (controller!=null && players.size()>=5) {
    controller.poll();

    while (queue.getNextEvent(event)) {
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
        if (event.getValue()>threshhold)
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


    if (players.get(5).hit) {
      for (Rumbler r : rumb) {
        r.rumble(1);
        println("rumble");
      }
    }

    if (xBoxInput[4]) {// ability trigg key
      //p.ability.press();
      for (Ability a : players.get(5).abilityList)  a.press();
      players.get(5).holdTrigg=true;
    } else if ( players.get(5).holdTrigg) {    
      for (Ability a : players.get(5).abilityList)  a.release();
      players.get(5).holdTrigg=false;
    }


    if (xBoxInput[3]) {//up
      if ((!reverse || players.get(5).reverseImmunity))players.get(5).control(1);
      players.get(5).holdUp=true;
    }
    if (xBoxInput[2]) {//down
      if ((!reverse || players.get(5).reverseImmunity)) players.get(5).control(0);
      players.get(5).holdDown=true;
    }
    if (xBoxInput[0]) {//left
      if ((!reverse || players.get(5).reverseImmunity)) players.get(5).control(4);
      players.get(5).holdLeft=true;
    }
    if (xBoxInput[1]) {//right
      if ((!reverse || players.get(5).reverseImmunity)) players.get(5).control(5);
      players.get(5).holdRight=true;
    }






    /*
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
     */
    /*
    if (xBoxInput[0])players.get(5).control(4); 
     if (xBoxInput[1])players.get(5).control(5); 
     if (xBoxInput[2])players.get(5).control(0); 
     if (xBoxInput[3])players.get(5).control(1); 
     if (xBoxInput[4])players.get(5).control(8);*/
  }
}