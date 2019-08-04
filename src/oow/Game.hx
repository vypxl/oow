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
  public var crystal : Crystal;
  var textBox : TextBox;
  var status : TextBox;

  public var freeze : Bool = false;

  var crystals : Int = 0;

  public function dialogue(text : Array<String>) {
    freeze = true;
    textBox.play(text, () -> freeze = false);
  }

  public function new() {
    super();
    player = new Character(this);
    wizard = new Wizard(this);
    crystal = new Crystal(this);
    world = new World(this);
    textBox = new TextBox(this);
    status = new TextBox(this, 64, Main.HEIGHT - 64, 128, 48);
    status.set("0 / 5");

    addEventListener(onEvent);

    world.loadMapInstant('0-0', World.FORWARD, this);
  }

  public function collectCrystal() {
    status.set('${++crystals} / 5');
    crystal.visible = false;
    hxd.Res.crystal_pickup.play();
  }

  function onEvent(e : Event) {
    switch e.kind {
      case EKeyDown: {
        switch e.keyCode {
          case Key.T: dialogue(["This is a dialogue.", "\\", "It is skippable if you do not want to endure very long sentences.", "!bye", "~test"]);
          case Key.SPACE: textBox.next();
          case Key.P: dialogue(["!ONLY ONE WAY"]);
          case _:
        }
      }
      case _:
    }

  }

  var boss_timer = 0;
  var boss_initialized = false;
  var boss_started = false;
  static inline var BOSS_TIME = 30;
  override function sync(ctx : h2d.RenderContext) {
    super.sync(ctx);
    if (!world.map.boss) return;
    if (!boss_initialized) {
      freeze = true;
      textBox.play(["YOU IDIOT", "Did you really believe what I told you? HA HA HA", "Of course I would only come here, curse the land and THEN try to get friends..","I came here because I LOVE TO TRICK PEOPLE.","But now you know. That means,..","!YOU MUST DIE"], () -> {
        freeze = false;
        var timer = new haxe.Timer(1000);
        boss_started = true;
        timer.run = () -> {
          boss_timer++;
          status.set('${BOSS_TIME - boss_timer}');

          if (boss_timer >= BOSS_TIME) {
            timer.stop();
            status.set('$crystals / 5');
            world.map.boss = false;
            world.map.wizardSpawn = new Point(-100, -100);
            freeze = true;
            textBox.play(["You are good. I cannot defeat you.", "Proceed to the next room with your ban crystals."], () -> {
              freeze = false;
              world.map.removeBossWalls();
              wizard.x = -100;
              wizard.y = -100;
            });
          }
        }
      });
      boss_initialized = true;
    }
    if(!boss_started) return;

     var mov = new Point(player.x, player.y)
      .sub(new Point(wizard.x, wizard.y))
      .normalized();
    this.wizard.x += mov.x * 280 * ctx.elapsedTime;
    this.wizard.y += mov.y * 200 * ctx.elapsedTime;

    if (Rect.fromBounds(player.getBounds()).collide(Rect.fromBounds(wizard.getBounds()))) {
      world.loadMap(world.map.name, World.FORWARD, this);
      boss_timer = 0;
    }
  }
}
