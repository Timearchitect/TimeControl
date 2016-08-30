
void targetHommingVarning(Player target) {
  int r=130;
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
  int r=40;
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