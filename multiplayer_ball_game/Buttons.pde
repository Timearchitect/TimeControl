class Button {
  Ability a;
  int x, y, size, minSize=70, maxSize=90, textYMargin=65, nameYMargin=55, tooltipDelay=500;
  color pcolor=  color(255);
  Boolean selected=false, hover, strokeless=false, deactivatable=true, resizeable=true;
  long timer;
  Button(Ability _ability, int _x, int _y, int _size) {
    a= _ability;
    size=_size;
    x=_x;
    y=_y;
    //print(a.name+" ");
  }

  void update() {
    if (mouseX>x-size*.5&&x+size*.5>mouseX&&mouseY>y-size*.5&&y+size*.5>mouseY) {
      pcolor=color(170, 100, 255);
      try { 
        if (!hover)timer=stampTime;
      }
      catch(Exception e) {
        print(e+" button");
      }
      hover=true; 

      if (mousePressed && !pMousePressed) {
        for (Button b : bList) {
          b.selected=false;
        }
        selected=true;
        selectedAbility=a;
        if (a.unlocked && a.deactivatable) {
          if (deactivatable)a.deactivated=!a.deactivated;
          int active=0;
          for (Ability as : abilityList) {
            if (!as.deactivated && as.unlocked )active++;
          }
          if (active<1) {
            abilityList[0].deactivated=false;
            abilityList[0].unlocked=true;
          }
          active=0;
          for (Ability as : passiveList) {
            if (!as.deactivated  && as.unlocked )active++;
          }
          if (active<1) {
            passiveList[0].deactivated=false;
            passiveList[0].unlocked=true;
          }
        }
      }
    } else {
      hover=false; 
      pcolor=color( 255);
    }
    if (selected) {
      pcolor=color( 170, 255, 255);
    }

    if (hover && resizeable) {
      if (size<maxSize)size+=10;
    } else {
      if (size>minSize)size-=5;
    }
  }

  void display() {
    rectMode(CENTER);      

    if (strokeless)  strokeWeight(0);
    else   strokeWeight(4);

    if (!a.unlocked) {
      fill(pcolor);
      stroke(pcolor);
      rect(x, y, size, size);
      tint(255, (a.unlockCost>coins)?40:255);
      image(a.icon, x, y, size, size);
      fill((a.unlockCost>coins)?240:0);
      text(a.unlockCost, x, y+textYMargin);
    } else if (a.deactivated) {
      fill(0, 100, 255);
      stroke(0, 255, 255);
      rect(x, y, size, size);
      tint(0, 255, 255);
      image(a.icon, x, y, size, size);
      fill(0, 255, 255);
      text("[DEACTIVATED]", x, y+textYMargin);
    } else {
      stroke(80, 255, 255);
      fill(80, 150, 255);
      rect(x, y, size, size);
      tint(80, 255, 255);

      image(a.icon, x, y, size, size);
      fill(80, 255, 255);
      text("[UNLOCKED]", x, y+textYMargin);
    }
    text(a.name, x, y+nameYMargin);
    rectMode(CORNER);
  }
  void displayTooltips() {  // tooltips box in shop
    if ( hover && timer+tooltipDelay<stampTime) {
      pushStyle();
      //blendMode(MULTIPLY);
      int mode, mouseXOffset=mouseX+20, mouseYOffset=mouseY+20, frameWidth=(a.tooltip.length()>50)? 400:int(a.tooltip.length()*10)+40, frameHeight=int(a.tooltip.length()*.45)+20;
      stroke(BLACK);
      fill(WHITE);
      if (mouseXOffset<width-frameWidth) {
        textAlign(LEFT);
        rect(mouseX, mouseY, frameWidth, frameHeight, 10);
      } else {
        textAlign(RIGHT); 
        mouseXOffset=mouseX-20;
        rect(mouseX, mouseY, -frameWidth, frameHeight, 10);
      }


      fill(BLACK);
      textSize(10);
      text(a.tooltip, mouseXOffset, mouseYOffset);
      popStyle();
    }
  }
}
class UpgradebleButton extends Button {
  boolean plusHover, minusHover;
  float minPlusSize, plusSize, maxPlusSize, minMinusSize, minusSize, maxMinusSize;
  color plusColor, minusColor;
  UpgradebleButton(Ability _ability, int _x, int _y, int _size) {
    super(_ability, _x, _y, _size);
    strokeless=true;
    deactivatable=false;
    resizeable=false;
    minSize=70; 
    maxSize=90;
    plusSize=minSize;
    minusSize=minSize;
    minPlusSize=plusSize;
    minMinusSize=minusSize;
    maxPlusSize=plusSize+20;
    maxMinusSize=minusSize+20;
  }
  void update() {
    super.update();
    if (a.unlocked ) {
      if ( mouseX>x-size*.5&&x+size*.5>mouseX&&mouseY>y-size*.5-plusSize*.2*.5&&y-size*.5+plusSize*.2*.5>mouseY) { // plus
        //background(WHITE);
        plusHover=true;
        plusColor=GREEN;
        if (mousePressed && !pMousePressed) {
          a.buy();
          a.updateTooltips();
        }
      } else {
        plusHover=false;
        plusColor=WHITE;
      }
      if (mouseX>x-size*.5&&x+size*.5>mouseX&&mouseY>y+size*.5-minusSize*.2*.5&&y+size*.5+minusSize*.2*.5>mouseY) { // minus
        //background(WHITE);
        minusHover=true;
        minusColor=RED;
        if (mousePressed && !pMousePressed) {
          a.sell();
          a.updateTooltips();
        }
      } else {
        minusHover=false;
        minusColor=WHITE;
      }
    }
    if (plusHover ) {
      if (plusSize<maxPlusSize)plusSize+=5;
    } else {
      if (plusSize>minPlusSize)plusSize-=1;
    }
    if (minusHover ) {
      if (minusSize<maxMinusSize)minusSize+=5;
    } else {
      if (minusSize>minMinusSize)minusSize-=1;
    }
  }
  void display() {
    super.display();
    if (a.unlocked) { 
      resizeable=false;
      textSize(20);
      rectMode(CENTER);
      stroke(0);
      strokeWeight(4);
      fill(plusColor);
      rect(x, y-size*.5, plusSize, plusSize*.25);
      fill(minusColor);
      rect(x, y+size*.5, minusSize, minusSize*.25);
      fill(BLACK);
      text("+", x, y-size*.48);
      text("-", x, y+size*.52);
      textSize(24);
      if(!hover) fill(BLACK,100);
      text(a.getLevel(), x, y);
      rectMode(CORNER);
    }else    resizeable=true;
  }
}
/*class StatButton extends Button {
 Ability a;
 int x, y, size, minSize=70, maxSize=90, textYMargin=65, nameYMargin=55;
 color pcolor=  color(255);
 Boolean selected=false, hover;
 PImage image;
 String name;
 StatButton(PImage _image, int _x, int _y, int _size, String _name) {
 super( null, _x, _y, _size);
 image=_image;
 size=_size;
 x=_x;
 y=_y;
 name=_name;
 //print(a.name+" ");
 }
 
 void update() {
 if (mouseX>x-size*.5&&x+size*.5>mouseX&&mouseY>y-size*.5&&y+size*.5>mouseY) {
 pcolor=color(170, 100, 255);
 hover=true; 
 if (mousePressed && !pMousePressed) {
 for (Button b : bList) {
 b.selected=false;
 }
 selected=true;
 selectedAbility=a;
 if (a.unlocked && a.deactivatable) {
 a.deactivated=!a.deactivated;
 int active=0;
 for (Ability as : abilityList) {
 if (!as.deactivated && as.unlocked )active++;
 }
 if (active<1) {
 abilityList[0].deactivated=false;
 abilityList[0].unlocked=true;
 }
 active=0;
 for (Ability as : passiveList) {
 if (!as.deactivated  && as.unlocked )active++;
 }
 if (active<1) {
 passiveList[0].deactivated=false;
 passiveList[0].unlocked=true;
 }
 }
 }
 } else {
 hover=false; 
 pcolor=color( 255);
 }
 if (selected) {
 pcolor=color( 170, 255, 255);
 }
 if (hover) {
 if (size<maxSize)size+=10;
 } else {
 if (size>minSize)size-=5;
 }
 }
 
 void display() {
 rectMode(CENTER);      
 strokeWeight(4);
 if (!a.unlocked) {
 fill(pcolor);
 stroke(pcolor);
 rect(x, y, size, size);
 tint(255, (a.unlockCost>coins)?40:255);
 image(a.icon, x, y, size, size);
 fill((a.unlockCost>coins)?240:0);
 text(a.unlockCost, x, y+textYMargin);
 } else if (a.deactivated) {
 fill(0, 100, 255);
 stroke(0, 255, 255);
 rect(x, y, size, size);
 tint(0, 255, 255);
 image(a.icon, x, y, size, size);
 fill(0, 255, 255);
 text("[DEACTIVATED]", x, y+textYMargin);
 } else {
 stroke(80, 255, 255);
 fill(80, 150, 255);
 rect(x, y, size, size);
 tint(80, 255, 255);
 
 image(a.icon, x, y, size, size);
 fill(80, 255, 255);
 text("[UNLOCKED]", x, y+textYMargin);
 }
 text(name, x, y+nameYMargin);
 rectMode(CORNER);
 }
 }
 */

class ModeButton extends Button {
  GameType type;
  PImage cover;
  int w, h, halfW, halfH, offset, defaultTextSize=21;
  ModeButton(GameType _type, int _x, int _y, int _w, int _h, color _color) {
    super(null, _x, _y, 0);
    pcolor=_color;
    w=_w;
    h=_h;
    halfW=int(w*.5);
    halfH=int(h*.5);

    type =_type;
  }
  ModeButton(GameType _type, int _x, int _y, int _w, int _h, color _color, PImage _image) {
    this( _type, _x, _y, _w, _h, _color);
    cover=_image;
  }

  void update() {

    if (mouseX>x&&x+w>mouseX&&mouseY>y&&y+h>mouseY) {
      hover=true; 
      //    for (int i=0; i<6; i++) {
      particles.add( new  Particle(int(x+random(w)), int(y+random(h)), 0, 0, int(random(50)+20), 1000, WHITE));
      // }
      if (offset<30)offset+=5;
      if (mousePressed && !pMousePressed) {
        gameMode=type;
        playerSetup();
        controllerSetup();
        resetGame();
        for (int i=0; i<36; i++) {
          particles.add( new  Particle(int(x+random(w)), int(y+random(h)), 0, 0, int(random(50)+20), 1000, pcolor));
        }
      }
    } else { 
      hover=false;    
      if (offset>0)offset--;
    }
  }

  void display() {
    textSize(defaultTextSize+int(offset*.4));
    fill(pcolor, (hover)?255:150);
    stroke(pcolor);
    strokeWeight(int(offset*.3));
    rect(x-offset*.5, y-offset*.5, w+offset, h+offset);
    tint(pcolor, 100);
    //image(a.icon, x, y, size, size);
    //text(a.name, x, y+60);

    fill(BLACK);
    if (cover!=null) image(cover, x+halfW, y+halfH, w+offset, h+offset);

    text(type.toString(), x+halfW, y+halfH);
  }
}


class SettingButton extends Button {
  Player player;
  int order;

  SettingButton(int _order, int _x, int _y, int _size, Player _player) {
    super( _player.abilityList.get(_order), _x, _y, _size);
    order=_order;
    player=_player;
    maxSize=110;
    minSize=90;
    textYMargin=105;
    nameYMargin=80;
    //print(a.name+" ");
  }

  void updateSettings() {
    //a = player.abilityList.get(order);
    a= abilities[player.index][order];
    // print(a.getClass().getSimpleName());
  }

  void update() {
    if (mouseX>x-size*.5 && x+size*.5>mouseX && mouseY>y-size*.5 && y+size*.5>mouseY) {
      pcolor=color(170, 100, 255);
      hover=true; 

      if (mouseScroll<0) {
        abilitySettingsIndex[player.index]=order;

        for (  int j=0; j<abilityList.length; j++) {
          if (a.getClass()==abilityList[j].getClass()) {
            while ( j>=abilityList.length-1 ||!abilityList[j+1].unlocked) {
              if (j>=abilityList.length-1)j=-2;
              j++;
            }
            try {
              a= abilityList[j+1].clone();
            }
            catch(CloneNotSupportedException e) {
              println("not cloned from Random");
            }
            break;
          }
        }
        for (  int j=0; j<passiveList.length; j++) {
          if (a.getClass()==passiveList[j].getClass()) {
            while (j>=passiveList.length-1 ||!passiveList[j+1].unlocked) {
              if (j>=passiveList.length-1)j=-2;
              j++;
            }
            try {
              a= passiveList[j+1].clone();
            }
            catch(CloneNotSupportedException e) {
              println("not cloned from Random");
            }
            break;
          }
        }
      }
      if (mouseScroll>0) {
        abilitySettingsIndex[player.index]=order;

        for (  int j=0; j<abilityList.length; j++) {
          if (a.getClass()==abilityList[j].getClass()) {

            while ( j==0 || !abilityList[j-1].unlocked ) {
              j--;
              if (j<=0)j=abilityList.length;
            }    

            try {
              a= abilityList[j-1].clone();
            }
            catch(CloneNotSupportedException e) {
              println("not cloned from Random");
            }
          }
        }
        for (  int j=0; j<passiveList.length; j++) {
          if (a.getClass()==passiveList[j].getClass()) {
            while ( j==0 ||!passiveList[j-1].unlocked) {
              if (j<=0)j=passiveList.length;
              j--;
            }
            try {
              a= passiveList[j-1].clone();
            }
            catch(CloneNotSupportedException e) {
              println("not cloned from Random");
            }
          }
        }
      }



      if (mousePressed && !pMousePressed) {

        if (a.type==AbilityType.ACTIVE) {
          a=new NoPassive();
        } else a=new NoActive();

        for (Button b : bList) {
          b.selected=false;
        }
        selected=true;
        selectedAbility=a;
        if (a.unlocked && a.deactivatable) {
          a.deactivated=!a.deactivated;
          int active=0;
          for (Ability as : abilityList) {
            if (!as.deactivated && as.unlocked )active++;
          }
          if (active<1) {
            abilityList[0].deactivated=false;
            abilityList[0].unlocked=true;
          }
          active=0;
          for (Ability as : passiveList) {
            if (!as.deactivated  && as.unlocked )active++;
          }
          if (active<1) {
            passiveList[0].deactivated=false;
            passiveList[0].unlocked=true;
          }
        }
        abilitySettingsIndex[player.index]=order;
      }
      abilities[player.index][order]=a;
    } else {
      hover=false; 
      pcolor=color( 255);
    }
    if (selected) {
      pcolor=color( 170, 255, 255);
    }
    if (hover) {
      if (size<maxSize)size+=10;
    } else {
      if (size>minSize)size-=5;
    }
  }

  void display() {
    textSize(18);
    rectMode(CENTER);
    fill(WHITE);
    rect(x, y, size, size);
    tint(player.playerColor);


    if (!a.unlocked) {
      // fill(pcolor);
      // stroke(pcolor);
      rect(x, y, size, size);
      //tint(255, (a.unlockCost>coins)?40:255);
      image(a.icon, x, y, size, size);
      // fill((a.unlockCost>coins)?240:0);
      text(a.unlockCost, x, y+75);
    } else if (a.deactivated) {
      // fill(0, 100, 255);
      // stroke(0, 255, 255);
      rect(x, y, size, size);
      //tint(0, 255, 255);
      image(a.icon, x, y, size, size);
      // fill(0, 255, 255);
      //text("[DEACTIVATED]", x, y+75);
    } else {
      // tint(80, 255, 255);
      image(a.icon, x, y, size, size);
      // fill(80, 255, 255);
      //text("[UNLOCKED]", x, y+75);
    }
    fill(BLACK);
    text(a.name, x, y+nameYMargin);
    if (a.type==AbilityType.ACTIVE) text("[ACTIVE]", x, y+textYMargin);
    else text("[PASSIVE]", x, y+textYMargin);
    rectMode(CORNER);
  }
}

class StatButton extends Button {
  Player owner;
  PImage image;
  String label;
  int level, index, playerIndex;
  float multiplyer=1.1;

  StatButton(PImage _image, int _index, String _label, int _x, int _y, int _size, Player _player) {
    super( null, _x, _y, _size);
    index=_index;
    owner=_player;
    playerIndex=_player.index;
    label=_label;
    image= _image;
    maxSize=50;
    minSize=40;
    textYMargin=65;
    nameYMargin=40;
    //print(a.name+" ");
  }

  void update() {
    if (mouseX>x-size*.5 && x+size*.5>mouseX && mouseY>y-size*.5 && y+size*.5>mouseY) {
      pcolor=color(170, 100, 255);
      hover=true; 

      if (mouseScroll<0) {
        if (level<100) {
          level++;
          // change(1);
        }
      }
      if (mouseScroll>0) {
        if (level>0) {
          level--;
          // change(-1);
        }
      }


      if (mousePressed && !pMousePressed) {
      }
    } else {
      hover=false; 
      pcolor=color( WHITE);
      if (selected) {
        pcolor=color( hue(owner.playerColor), 255, 255);
      }
    }
    if (hover) {
      if (size<maxSize)size+=4;
    } else {
      if (size>minSize)size-=2;
    }
  }

  void display() {
    strokeWeight(2);
    textSize(12);
    stroke(owner.playerColor);
    fill(owner.playerColor, hover?150:30);
    rect(x-size*.5, y-size*.5, size, -level*multiplyer);
    fill(hue(owner.playerColor), 255, 80);
    text(level, x, y-level*multiplyer-size*.7);

    strokeWeight(4);
    textSize(8);
    rectMode(CENTER);
    fill(pcolor);
    rect(x, y, size, size);
    tint(owner.playerColor);
    rect(x, y, size, size);
    image(image, x, y, size, size);
    fill(BLACK);
    text(label, x, y+nameYMargin);
    //if (a.type==AbilityType.ACTIVE) text("[ACTIVE]", x, y+textYMargin);
    //else text("[PASSIVE]", x, y+textYMargin);
    rectMode(CORNER);
  }
}
public float addStat(int playerIndex, int stat) {
  for (StatButton p : pSBList) {
    if (p.playerIndex==playerIndex &&  p.index==stat) {
      print(p.label+" : "+p.level+"  ");
      return p.level;
    }
  }
  return 0;
}