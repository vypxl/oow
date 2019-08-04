package oow;

import h2d.Anim;
import h2d.Object;
import hxd.Res;

class Crystal extends Object {
  var anim : Anim;

  public function new(parent : Object) {
    super(parent);
    var tex = hxd.Res.oow_crystal.toTile();
    anim = new Anim([tex.sub(0, 0, 32, 32), tex.sub(0, 32, 32, 32)], 20, this);
  }
}
