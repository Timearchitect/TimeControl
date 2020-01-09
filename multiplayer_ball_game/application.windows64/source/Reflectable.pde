interface Reflectable {
  Boolean reflectable=true;
  void reflect(float angle, Player owner);
}

interface Destroyable {
  Boolean destroyable=true;
  //void destroy();
  void destroy(Projectile destroyer);
}

interface Reflector {
  Boolean reflectable=true;
  void reflecting();
}

interface Destroyer {
  Boolean destroyable=true;
  // void destroying();
  void destroying(Projectile destroyed);
}

interface Container { 
  Boolean container=true;
//    Containable payload[]= new  Containable[]();
  Container contains(Containable[] payload);
  
}
interface Containable { 
  Boolean containable=true;
  Containable parent(Container parent);
   //<T extends Object & Containable> T parent(Container parent);
  //  public <t extends Containable> t parent(Container parent);
   // public move parent(Container parent);
  void unWrap();
}

interface AmmoBased { 

  void reload();
  void reloadCancel();
}
