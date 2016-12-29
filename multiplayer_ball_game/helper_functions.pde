
 void targetHommingVarning(Player target) {
  final int r=130;
  float tcx=target.cx, tcy=target.cy;
  strokeWeight(2);
  stroke(255);
  noFill();
  ellipse(tcx, tcy, r, r);
  line(tcx+r, tcy, tcx-r, tcy);
  // line(tcx, tcy, tcx+r, tcy);
  line(tcx, tcy+r, tcx, tcy-r);
  // line(tcx, tcy, tcx, tcy+r);
}


 void crossVarning(int x, int y) {
  final int r=40;
  // float tcx=target.cx, tcy=target.cy;
  strokeWeight(3);
  stroke(255);
  noFill();
  //ellipse(tcx, tcy, r, r);
  line(x+r, y+r, x-r, y-r);
  //line(tcx, tcy, tcx+r, tcy);
  line(x+r, y-r, x-r, y+r);
  //line(tcx, tcy, tcx, tcy+r);
  strokeWeight(6);
   ellipse(x,y,r*4,r*4);
     strokeWeight(3);
   ellipse(x,y,r*5,r*5);
}

static float angleAgainst(int x,int y,int x2,int y2){
  //return  degrees(-( atan((y2-y)/(x2-x))));
   return  degrees(atan2(y2-y, x2-x)); 
  
}

 Player seek(Player m,int senseRange) {
    for (int sense = 0; sense < senseRange; sense++) {
      for (   Player p: players) {
        if (p!= m && !p.dead && p.ally!=m.ally) {
          if (dist(p.x, p.y, m.x, m.y)<sense*0.5) {  
            return p;
          }
        }
      }
    }
    return null;
  }
  /*
 Player seek(Player m,int senseRange) {
    for (int sense = 0; sense < senseRange; sense++) {
      for ( int i=0; players.size () > i; i++) {
        if (players.get(i)!= m && !players.get(i).dead && players.get(i).ally!=m.ally) {
          if (dist(players.get(i).x, players.get(i).y, m.x, m.y)<sense*0.5) {  
            return players.get(i);
          }
        }
      }
    }
    return null;
  }*/