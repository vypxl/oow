package oow;

using StringTools;

import h2d.Object;
import h2d.Text;
import hxd.res.Font;
import h2d.RenderContext;
import h2d.Graphics;

class PopupText extends Object {
  public var speed = 0.5;
  public var sustain = 2;
  var txt : Text;
  var border : Graphics;

  var done = true;
  var timer = 0.0;
  var currentText : Array<String> = [];
  var currentIdx = -1;

  var onFinish : Void -> Void = () -> {};

  public function new(parent : Object) {
    super(parent);
    x = -parent.x;
    y = -parent.y;

    border = new Graphics(this);
    border.beginFill(0xffffff);
    border.drawRect(128, 256, Main.WIDTH - 128, 512);
    border.beginFill(0);
    border.drawRect(132, 260, Main.WIDTH - 136, 504);
    border.endFill();

    txt = new Text(hxd.res.DefaultFont.get(), this);
    txt.text = "";
    txt.x = 128;
    txt.y = 256;
    txt.scale(6);
    txt.maxWidth = 400;

    visible = false;
  }

  override function sync(ctx : RenderContext) {
    super.sync(ctx);
    if (done) return;
    timer += ctx.elapsedTime;
    if (currentIdx >= currentText.length) {
      if (timer <= sustain) return;
      else {
        onFinish();
        visible = false;
        done = true;
      }
    }

    if (timer <= speed || currentIdx >= currentText.length) return;
    timer -= speed;

    var idx = ++currentIdx;
    if (idx >= currentText.length) return;

    txt.text += "    " + currentText[currentIdx];
  }

  public function play(text : String, ?onfinish : Void -> Void) {
    if (onfinish != null) onFinish = onfinish;
    else onFinish = () -> {};
    done = false;
    timer = 0.0;
    visible = true;
    txt.text = "";
    currentText = text.split(" ");
    currentIdx = -1;
  }
}

