package oow;

class Point {
  public var x : Float;
  public var y : Float;

  public inline function new (x, y) {
    this.x = x;
    this.y = y;
  }

  public inline function add(other : Point) : Point
    return new Point(this.x + other.x, this.y + other.y);

  public inline function sub(other : Point) : Point
    return new Point(x - other.x, y - other.y);

  public inline function div(divisor : Float) : Point
    return new Point(x / divisor, y / divisor);

  public inline function normalized() : Point
    return div(dist(new Point(0, 0)));

  public inline function dist(other : Point) : Float {
    var diff = sub(other);
    return Math.sqrt(diff.x * diff.x + diff.y * diff.y);
  }

  public inline function equals(b : Point) : Bool return x == b.x && y == b.y;
}

