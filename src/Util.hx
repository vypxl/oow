package;

class Util {
  public static function let<A, B>(x : A, f : A -> B) {
    return f(x);
  }
}
