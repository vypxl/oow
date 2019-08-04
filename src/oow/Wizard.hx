package oow;

import h2d.Anim;
import h2d.Object;
import hxd.Res;

class Wizard extends Object {
  var anim : Anim;

  public function new(parent : Object) {
    super(parent);
    var tex = hxd.Res.oow_wizard.toTile();
    anim = new Anim([tex.sub(0, 0, 64, 64), tex.sub(0, 64, 64, 64)], 4, this);
  }
}
