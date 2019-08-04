package oow;

class Point {
  public var x : Float;
  public var y : Float;

  public inline function new (x, y) {
    this.x = x;
    this.y = y;
  }

  public inline function add(other : Point)
    return new Point(this.x + other.x, this.y + other.y);
}

