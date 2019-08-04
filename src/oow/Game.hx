package oow;

import h2d.Scene;
import h2d.Object;
import h2d.RenderContext;
import hxd.Event;
import hxd.Key;

import oow.*;

class Game extends Scene {
  public var world : World;
  public var player : Character;
  public var wizard : Wizard;
  var textBox : TextBox;

  public var freeze : Bool = false;

  public function dialogue(text : Array<String>) {
    freeze = true;
    textBox.play(text, () -> freeze = false);
  }

  public function new() {
    super();
    world = new World(this);
    player = new Character(this);
    wizard = new Wizard(this);
    textBox = new TextBox(this);

    addEventListener(onEvent);

    world.loadMapInstant('0-0', World.FORWARD, this);
  }

  function onEvent(e : Event) {
    switch e.kind {
      case EKeyDown: {
        switch e.keyCode {
          case Key.T: dialogue(["This is a dialogue.", "It is skippable if you do not want to endure very long sentences.", "!bye", "test"]);
          case Key.SPACE: textBox.next();
          case Key.P: dialogue(["!ONLY ONE WAY"]);
          case _:
        }
      }
      case _:
    }

  }

  override function sync(ctx : h2d.RenderContext) {
    super.sync(ctx);
  }
}
