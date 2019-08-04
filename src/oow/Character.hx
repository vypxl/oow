package oow;

import h2d.Object;
import h2d.Anim;
import hxd.Res;
import h2d.RenderContext;
import hxd.Key;

import oow.*;

enum abstract Char_AnimState(Int) to Int {
  var Idle = 0;
  var Walk = 1;
}

class Character extends Object {
  var animState(default, set) = Idle;
  var anims : Array<Anim>;
  var snd_walk : hxd.snd.Channel;
  var game : Game;

  public function new(game : Game) {
    super(game);
    this.game = game;
    var spritesheet = hxd.Res.oow_character.toTile();
    var anim_idle = new Anim([spritesheet.sub(0, 0, 32, 32), spritesheet.sub(32, 0, 32, 32)], 3, this);
    var anim_walk = new Anim([spritesheet.sub(0, 32, 32, 32), spritesheet.sub(32, 32, 32, 32)], 6, this);
    snd_walk = hxd.Res.walk.play(true);
    anims = [anim_idle, anim_walk];
    for (a in anims) { a.loop = true; }

    animState = Idle;
  }

  override function sync(ctx : h2d.RenderContext) {
    super.sync(ctx);
    if (game.freeze) return;
    var dt = ctx.elapsedTime;

    var mov = new Point(0, 0);
    if (Key.isDown(Key.W)) mov.y -= 256 * dt;
    if (Key.isDown(Key.S)) mov.y += 256 * dt;
    if (Key.isDown(Key.A)) mov.x -= 256 * dt;
    if (Key.isDown(Key.D)) mov.x += 256 * dt;
    mov = game.world.collidePlayer(game, mov);
    x += mov.x;
    y += mov.y;
    if (mov.x != 0 || mov.y != 0) animState = Walk;
    else animState = Idle;
  }

  function set_animState(state : Char_AnimState) {
    for (a in anims) {
      a.pause = true;
      a.visible = false;
    }

    anims[state].pause = false; 
    anims[state].visible = true;
    snd_walk.volume = switch (state) {
      case Idle: 0;
      case Walk: 1;
    }
    return state;
  }
}

