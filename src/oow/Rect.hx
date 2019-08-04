package oow;

import oow.Point;

class Rect {
  public var a : Point;
  public var b : Point;

  public inline function new(a, b) {
    this.a = a;
    this.b = b;
  }

  public static inline function fromBounds(bounds : h2d.col.Bounds, dx : Float = 0, dy : Float = 0) : Rect
    return xyxy(bounds.xMin + dx, bounds.yMin + dy, bounds.xMax + dx, bounds.yMax + dy);

  public static inline function xywh(x : Float, y : Float, w : Float, h : Float) : Rect
    return xyxy(x, y, x + w, y + h);

  public static inline function xyxy(x1 : Float, y1 : Float, x2 : Float, y2 : Float) : Rect
    return new Rect(new Point(x1, y1), new Point(x2, y2));

  public inline function collide(other : Rect) : Bool
    return this.a.x < other.b.x && this.b.x > other.a.x && this.a.y < other.b.y && this.b.y > other.a.y;
}

