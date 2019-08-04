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
  public var sndSpeed = 4; // All 4 chars
  var txt : Text;
  var border : Graphics;

  var timer = 0.0;
  var sndTimer = 0;
  var currentText : Array<String> = [];
  var currentIdx = 0;
  var currentCharIdx = 0;
  var wait = true;
  var blocked = false;

  var speaker = 0;
  var speakers : Array<hxd.res.Sound>;

  var onFinish : Void -> Void = () -> {};

  public function new(parent : Object, x : Float = 128, y : Float = 16, w : Float = Main.WIDTH - 256, h : Float = 128) {
    super(parent);
    popupText = new PopupText(this);
    txt = new Text(hxd.res.DefaultFont.get());
    txt.text = "";
    txt.x = x + 12;
    txt.y = y + 8;
    txt.scale(2);
    txt.maxWidth = w / 2.5;

    border = new Graphics();
    border.beginFill(0xffffff);
    border.drawRect(x, y, w, h);
    border.beginFill(0);
    border.drawRect(x + 4, y + 4, w - 8, h - 8);
    border.endFill();
    border.endFill();

    for (c in [border, txt]) addChild(c);
    visible = false;
    speakers = [hxd.Res.speech2, hxd.Res.speech1];
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
      if (!wait) next();
      return;
    }

    txt.text += currentText[currentIdx].charAt(cidx);
    sndTimer++;
    if (sndTimer >= sndSpeed) {
      speakers[speaker].play();
      sndTimer = 0;
    }
  }

  public function set(text : String) {
    txt.text = text;
    visible = true;
  }

  public function play(text : Array<String>, ?onfinish : Void -> Void) {
    if (onfinish != null) onFinish = onfinish;
    else onFinish = () -> {};
    timer = 0.0;
    speaker = 0;
    visible = true;
    txt.text = "";
    currentText = text;
    currentIdx = -1;
    currentCharIdx = 0;
    next(true);
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

      var ctxt = currentText[currentIdx];
      if (ctxt.startsWith("!")) {
        blocked = true;
        popupText.play(ctxt.substr(1), () -> { blocked = false; next(true); });
      } else if(ctxt.startsWith("\\")) {
        blocked = true;
        visible = false;
        speaker = (speaker + 1) % 2;
        haxe.Timer.delay(() -> { blocked = false; visible = true; next(true); }, 600);
      } else if (ctxt.startsWith("~")) {
        wait = false;
        currentText[currentIdx] = ctxt.substr(1);
      } else wait = true;
    }
  }
}
