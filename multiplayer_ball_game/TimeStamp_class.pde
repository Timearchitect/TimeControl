abstract class TimeStamp {
  long time;
  int playerIndex;
  int x, y;
  PVector coord;
  
  TimeStamp(int _playerIndex){
  playerIndex=_playerIndex;
  time=stampTime;
  }
  
  void display() {
    fill(0);
    stroke(0);
    strokeCap(ROUND);
    strokeWeight(2);
  }
  void revert() {
    stamps.remove(this);
  }
  void call(){} // execute timestamp without respect for currenttime
}