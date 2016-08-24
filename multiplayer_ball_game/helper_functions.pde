
  void targetHommingVarning(Player target) {
    int r=130;
    float tcx=target.x+target.w*0.5, tcy=target.y+target.w*0.5;
    stroke(255);
      noFill();
      ellipse(tcx, tcy, r, r);
      line(tcx, tcy, tcx-r, tcy);
      line(tcx, tcy, tcx+r, tcy);
      line(tcx, tcy, tcx, tcy-r);
      line(tcx, tcy, tcx, tcy+r);
    
  }