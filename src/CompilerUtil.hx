package;

import haxe.macro.Context;
import haxe.macro.Expr.FieldType;

/** Class containing functions to be used as compiler macros **/
class CompilerUtil {
  /**
    Used to replace any static constant integer field on a class
    Usage (in hxml):
    --macro addMetadata('@:build(CompilerUtil.setIntConstField(<name>, <value>))', <class>)

    Example:
    --macro addMetadata('@:build(CompilerUtil.setIntConstField("SDL_WINDOW_RESIZABLE", "0"))', 'sdl.Window')
    # used to disable the resizable flag on hl/sdl
    # in this case you could also specify a value wich contains other sdl flags for window creation as hlsdl automatically or'es this value.
  **/
  public static function setIntConstField(name: String, val : String) {
    var fields = Context.getBuildFields();

    for (field in fields) {
      if (field.name != name) continue;

      switch (field.kind) {
        case FVar(t, e): e.expr = EConst(CInt(val));
        case _:
      }
      break;
    }

    return fields;
  }
}
