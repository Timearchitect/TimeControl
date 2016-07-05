interface Reflectable{
  Boolean reflectable=true;
  void reflect(float angle,Player owner);
}

interface Destroyable{
  Boolean destroyable=true;
  void destroy();
}

interface Reflector{
  Boolean reflectable=true;
  void reflecting();
}

interface Destroyer{
  Boolean destroyable=true;
  void destroying();
}