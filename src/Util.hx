package;

class Util {
  public static inline function let<A, B>(x : A, f : A -> B) {
    return f(x);
  }
}
