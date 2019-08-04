// Copyright (c) 2013 Nicolas Cannasse (MIT license) --- Modified by vypxl to allow custom properties for objects
package oow;

import haxe.xml.Access;

typedef TiledMapLayer = {
  var data : Array<Int>;
  var name : String;
  var opacity : Float;
  var objects : Array<{ x: Int, y : Int, name : String, type : String, width: Int, height: Int, props : std.Map<String, String> }>;
}

typedef TiledMapData = {
  var width : Int;
  var height : Int;
  var layers : Array<TiledMapLayer>;
}

class TiledMap extends hxd.res.Resource {

  public function toMap() : TiledMapData {
    var data = entry.getBytes().toString();
    var base = new haxe.crypto.BaseCode(haxe.io.Bytes.ofString("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"));
    var x = new Access(Xml.parse(data).firstElement());
    var layers = [];

    for( l in x.nodes.layer ) {
      var data = StringTools.trim(l.node.data.innerData);
      while( data.charCodeAt(data.length-1) == "=".code )
        data = data.substr(0, data.length - 1);
      var bytes = haxe.io.Bytes.ofString(data);
      var bytes = base.decodeBytes(bytes);
      bytes = format.tools.Inflate.run(bytes);
      var input = new haxe.io.BytesInput(bytes);
      var data = [];
      for( i in 0...bytes.length >> 2 )
        data.push(input.readInt32());

      layers.push( {
        name : l.att.name,
        opacity : l.has.opacity ? Std.parseFloat(l.att.opacity) : 1.,
        objects : [],
        data : data,
      });
    }

    for( l in x.nodes.objectgroup ) {
      var objs = [];

      for( o in l.nodes.object )
        if( o.has.name ) {
          var props : std.Map<String, String> = new Map();
          if ( o.hasNode.properties )
            for ( p in o.node.properties.nodes.property )
              if ( p.has.name ) props.set(p.att.name, p.att.value);

          objs.push({
            name : o.att.name, 
            type : o.has.type ? o.att.type : null, 
            x : Std.parseInt(o.att.x), 
            y : Std.parseInt(o.att.y),
            width : o.has.width ? Std.parseInt(o.att.width) : 0,
            height : o.has.height ? Std.parseInt(o.att.height) : 0,
            props : props
          });
        }

      layers.push( {
        name : l.att.name,
        opacity : 1.,
        objects : objs,
        data : null,
      });
    }

    return {
      width : Std.parseInt(x.att.width),
      height : Std.parseInt(x.att.height),
      layers : layers,
    };
  }
}

