package oow;

using StringTools;
import h2d.Object;
import h2d.Text;
import hxd.res.Font;
import h2d.Graphics;
import h2d.RenderContext;

class TextBox extends Object {
  var popupText : PopupText;

  public var speed = 0.025;
  var txt : Text;
  var border : Graphics;

  var timer = 0.0;
  var currentText : Array<String> = [];
  var currentIdx = 0;
  var currentCharIdx = 0;
  var wait = true;
  var blocked = false;

  var onFinish : Void -> Void = () -> {};

  public function new(parent : Object) {
    super(parent);
    popupText = new PopupText(this);
    txt = new Text(hxd.res.DefaultFont.get());
    txt.text = "";
    txt.x = 140;
    txt.y = 24;
    txt.scale(2);
    txt.maxWidth = 400;

    border = new Graphics();
    border.beginFill(0xffffff);
    border.drawRect(128, 16, Main.WIDTH - 128, 128);
    border.beginFill(0);
    border.drawRect(132, 20, Main.WIDTH - 136, 120);
    border.endFill();
    border.endFill();

    for (c in [border, txt]) addChild(c);
    visible = false;
  }

  override function sync(ctx : RenderContext) {
    super.sync(ctx);
    if (blocked) return;
    timer += ctx.elapsedTime;
    if (timer <= speed || currentIdx >= currentText.length) return;
    timer -= speed;
    if (timer > speed * 3) timer = 0;

    var cidx = currentCharIdx++;
    if (cidx >= currentText[currentIdx].length) {
      if (wait) return;
      else next();
    }

    txt.text += currentText[currentIdx].charAt(cidx);
  }

  public function play(text : Array<String>, ?onfinish : Void -> Void) {
    if (onfinish != null) onFinish = onfinish;
    else onFinish = () -> {};
    timer = 0.0;
    visible = true;
    txt.text = "";
    currentText = text;
    currentIdx = 0;
    currentCharIdx = 0;
  }

  public function next(force = false) {
    if (currentIdx >= currentText.length) return;
    if (blocked || currentText.length <= 0) return;
    if (!force && currentCharIdx < currentText[currentIdx].length)  {
      txt.text = currentText[currentIdx];
      currentCharIdx = currentText[currentIdx].length;
    } else {
      txt.text = "";
      currentCharIdx = 0;
      currentIdx++;

      if (currentIdx >= currentText.length) {
        onFinish();
        visible = false;
        return;
      }

      if (currentText[currentIdx].startsWith("!")) {
        blocked = true;
        popupText.play(currentText[currentIdx].substr(1), () -> { blocked = false; next(true); });
      } else if (currentText[currentIdx].startsWith("~")) {
        wait = false;
        currentText[currentIdx] = currentText[currentIdx].substr(1);
      } else wait = true;
    }
  }
}
