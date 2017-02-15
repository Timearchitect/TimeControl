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
  Container contains(Containable[] payload);
}
interface Containable { 
  Boolean containable=true;
  Containable parent(Container parent);
  void unWrap();
}

interface AmmoBased { 
  void reload();
  void reloadCancel();
}