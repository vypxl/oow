package;

using Lambda;
import Util.*;
import haxe.Timer;
import hxd.Res;
import hxd.res.Font;
import hxd.App;
import hxd.Event;
import hxd.System;
import hxd.Key;
import h2d.Text;
import h2d.Scene;

class Main extends hxd.App {
  static inline var WIDTH = 1024;
  static inline var HEIGHT = 768;
  var score : h2d.Text;
  var lvl : h2d.Text;


  function mkText(text : String, x : Int, y : Int, scale : Int, font : h2d.Font, ?parent : h2d.Object) : h2d.Text {
    var t = new h2d.Text(font, parent != null ? parent : s2d);
    t.text = text;
    t.x = x;
    t.y = y;
    t.scale(scale);
    return t;
  }

  override function update(dt : Float) {

  }

  override function init() {
    var win = hxd.Window.getInstance();
    win.resize(WIDTH, HEIGHT);
    s2d.scaleMode = Fixed(WIDTH, HEIGHT, 1., Left, Top);
    win.addResizeEvent(() -> {
      var w = hxd.Window.getInstance();
      if(w.width != WIDTH || w.height != HEIGHT) 
        w.resize(WIDTH, HEIGHT); 
    });
    win.addEventTarget(onEvent);

    var font = hxd.res.DefaultFont.get();
    score = mkText("Score: 00000", 16, 16, 4, font);
    lvl = mkText("Lvl 001", WIDTH - 180, 16, 4, font);

  }

  function onEvent(e : hxd.Event) {
    if (e.kind == EKeyDown) switch (e.keyCode) {
      case Key.Q: hxd.System.exit();
    }
  }

  static function main() {
    hxd.Res.initEmbed();
    new Main();
  }
}
