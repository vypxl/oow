package oow;

using Lambda;
using StringTools;
import Util.*;
import h2d.Object;
import hxd.Res;
import h2d.Tile;
import h2d.TileGroup;

import oow.TiledMap;
import oow.TiledMap.TiledMapData;
import oow.TiledMap.TiledMapLayer;

enum CollisionResult {
  None;
  Wall(x : Bool, y : Bool);
  WarpTo(dest : String, dir : Int);
  Dialogue;
  Crystal;
}

typedef Warp = {
  public var trigger : Rect;
  public var dir : Int;
  public var dest : String;
}

class Map extends Object {
  var data : TiledMapData;
  var spritesheet : h2d.Tile;
  var tiles : Array<h2d.Tile>;
  var walls : Array<Rect>;
  var warps : Array<Warp>;
  var tileGroup : TileGroup;

  public var playerSpawn1 : Point;
  public var playerSpawn2 : Point;
  public var wizardSpawn  : Point = new Point(-100, -100);
  public var crystalSpawn : Point = new Point(-100, -100);
  var crystalCol : Rect = Rect.xywh(-100, -100, 0, 0);
  public var crystalCollected : Bool = false;
  public var dialogue     : Array<String> = [];
  public var dialogueTrigger : Rect = Rect.xywh(-100, -100, 0, 0);
  public var dialogueDone = false;
  public var boss = false;
  public var bossTiles : Array<Point>;

  public function collide(obj : Object, mov : Point, checkWarp = false) : CollisionResult {
    var bounds  = Rect.fromBounds(obj.getBounds(), mov.x, mov.y);
    var boundsx = Rect.fromBounds(obj.getBounds(), mov.x, 0);
    var boundsy = Rect.fromBounds(obj.getBounds(), 0, mov.y);

    if (checkWarp) for (warp in warps) {
      if (warp.trigger.collide(bounds)) return WarpTo(warp.dest, warp.dir);
    }

    if (!dialogueDone && dialogueTrigger.collide(bounds)) return Dialogue;
    if (!crystalCollected && crystalCol.collide(bounds)) {
      crystalCollected = true;
      return Crystal;
    }

    var colx = false;
    var coly = false;
    for (wall in walls) {
      if (!colx && wall.collide(boundsx)) colx = true;
      if (!coly && wall.collide(boundsy)) coly = true;
      if (colx && coly) break;
    }
    if (colx || coly) return Wall(colx, coly);

    return None;
  }

  public function removeBossWalls() {
    tileGroup.clear();
    walls = [];
    initBackground(true);
  }

  function initBackground(ignoreBossTiles = false) {
    tileGroup = new TileGroup(spritesheet, this);
    walls = [];

    for (layer in data.layers) {
      if(layer.data != null) {
        for (y in 0...data.height) for (x in 0...data.width) {
          var tid = layer.data[x + y * data.width];
          if (
              tid <= 0 || 
              (
               ignoreBossTiles && 
               bossTiles.exists(t -> t.x == x * 32 && t.y == y * 32)
               )
              ) continue;
          if (layer.name == "walls") 
            walls.push(Rect.xywh(x * 32, y * 32,32, 32));
          else
            tileGroup.add(x * 32, y * 32, tiles[tid - 1]);
        }
      }
    }
  }

  public function new(name : String, data : TiledMapData, spritesheet : Tile, tiles : Array<Tile>, parent : Object) {
    super(parent);
    this.name = name;
    this.data = data;
    this.spritesheet = spritesheet;
    this.tiles = tiles;
    warps = [];
    bossTiles = [];

    initBackground();
    for (layer in data.layers)
      if (layer.objects != null) {
        for (o in layer.objects) {
          switch (o.name) { case "player1": playerSpawn1 = new Point(o.x, o.y);
            case "player2" : playerSpawn2 = new Point(o.x, o.y);
            case "wizard"  : wizardSpawn  = new Point(o.x, o.y);
            case "crystal" : { crystalSpawn = new Point(o.x, o.y); crystalCol = Rect.xywh(o.x, o.y, 32, 32); };
            case "dialogue": { dialogueTrigger = Rect.xywh(o.x, o.y, o.width, o.height); dialogue = o.props["dialogue"].split(";"); }
            case "warpf"   : warps.push({ trigger: Rect.xywh(o.x, o.y, o.width, o.height), dir: 0, dest: o.props["dest"] });
            case "warpb"   : warps.push({ trigger: Rect.xywh(o.x, o.y, o.width, o.height), dir: 1, dest: o.props["dest"] });
            case "boss"    : {
              boss = true;
              for (pos in o.props["remove_walls"].split(";")) {
                var xy = pos.split("|").map(x -> Std.parseInt(x));
                bossTiles.push(new Point(xy[0], xy[1]));
              }
            }
            case _:
          }
        }
      }
  }

  public function activate() {
    visible = true;
  }
  public function deactivate() {
    visible = false;
  }
}

class World extends Object {
  var maps : std.Map<String, Map>;
  public var map : Map;

  public function new(parent : h2d.Object) {
    super(parent);
    var spritesheet = hxd.Res.oow_wall.toTile();
    var tiles = [spritesheet];
    maps = new std.Map();

    for (entry in hxd.Res.loader.load("maps")) {
      if (!entry.name.startsWith("room-")) continue;
      var name = entry.name.replace("room-", "").replace(".tmx", "");
      var map = new Map(name, entry.to(TiledMap).toMap(), spritesheet, tiles, this);
      maps[name] = map;
      maps[name].visible = false;
    }
  }

  public static inline var FORWARD = 0;
  public static inline var BACKWARD = 1;
  public static inline var FADE_TIME = 200;
  public static inline var FADE_DELAY = 300;

  public function loadMapInstant(name : String, direction : Int = FORWARD, game : Game) {
    if (map != null) map.deactivate();
    map = maps[name];
    map.activate();
    if (direction == FORWARD) {
      game.player.x = map.playerSpawn1.x;
      game.player.y = map.playerSpawn1.y;
    } else {
      game.player.x = map.playerSpawn2.x;
      game.player.y = map.playerSpawn2.y;
    }
    game.wizard.x = map.wizardSpawn.x;
    game.wizard.y = map.wizardSpawn.y;
    game.crystal.x = map.crystalSpawn.x;
    game.crystal.y = map.crystalSpawn.y;
    game.crystal.visible = !map.crystalCollected;
  }

  public function loadMap(name : String, direction : Int, game : Game) {
    var timer = new haxe.Timer(16);
    var elapsed = 0.0;
    timer.run = () -> {
      elapsed += 16;
      game.alpha = 1.0 - elapsed / FADE_TIME;

      if (elapsed >= FADE_TIME) {
        timer.stop();
        game.visible = false;
        game.alpha = 0;
        elapsed = 0.0;
        loadMapInstant(name, direction, game);
        haxe.Timer.delay(() -> {
          game.visible = true;
          timer = new haxe.Timer(16);
          timer.run = () -> {
            elapsed += 16;
            game.alpha = (elapsed / FADE_TIME);
            if (elapsed >= FADE_TIME) {
              game.alpha = 1;
              timer.stop();

              if (name == "0-1") hxd.Res.snd_win.play();
            }
          }
        }, FADE_DELAY);
      }
    }
  }

  public function collidePlayer(game : Game, mov : Point) : Point {
    return switch (map.collide(game.player, mov, true)) {
      case None: mov;
      case Wall(x, y): new Point(x ? 0 : mov.x, y ? 0 : mov.y);
      case WarpTo(dest, dir): { loadMap(dest, dir, game); return new Point(0, 0); }
      case Dialogue: { game.dialogue(map.dialogue); map.dialogueDone = true; return new Point(0, 0); }
      case Crystal: { game.collectCrystal(); return mov; };
    }
  }
}

