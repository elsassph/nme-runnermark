package aze.display;

import haxe.Public;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObject;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.geom.Rectangle;
import nme.Lib;

/**
 * A little wrapper of NME's Tilesheet rendering (for native platform)
 * and using Bitmaps for Flash platform.
 * Features basic containers (TileGroup) and spritesheets animations.
 * @author Philippe / http://philippe.elsass.me
 */
class TileLayer extends Sprite
{
	public static inline var TILE_SCALE = 0x0001;
	public static inline var TILE_ROTATION = 0x0002;
	public static inline var TILE_RGB = 0x0004;
	public static inline var TILE_ALPHA = 0x0008;

	public var dom:TileGroup;

	var smooth:Bool;
	var flags:Int;
	var tilesheet:TilesheetEx;
	var drawList:DrawList;

	public function new(tilesheet:TilesheetEx, smooth:Bool, flags:Int = 0)
	{
		super();
		this.tilesheet = tilesheet;
		this.smooth = smooth;
		this.flags = flags;
		dom = new TileGroup();
		dom.tilesheet = tilesheet;
		drawList = new DrawList(flags);
		mouseChildren = false;
	}

	public function render()
	{
		drawList.begin();
		renderGroup(dom, 0, 0, 0);
		drawList.end();
		#if flash
		addChild(dom.view);
		#else
		graphics.clear();
		tilesheet.drawTiles(graphics, drawList.list, true, flags);
		#end
	}

	function renderGroup(group:TileGroup, index:Int, gx:Float, gy:Float)
	{
		var list = drawList.list;
		var fields = drawList.fields;
		var offsetScale = drawList.offsetScale;
		var offsetRotation = drawList.offsetRotation;
		var offsetRGB = drawList.offsetRGB;
		var offsetAlpha = drawList.offsetAlpha;
		var elapsed = drawList.elapsed;
		gx += group.x;
		gy += group.y;
		#if flash
		group.view.x = gx;
		group.view.y = gy;
		var rad2deg = 180 / Math.PI;
		#end

		for(child in group)
		{
			if (Std.is(child, TileGroup)) 
			{
				index = renderGroup(cast child, index, gx, gy);
			}
			else 
			{
				if (Std.is(child, TileClip)) 
				{
					var clip:TileClip = cast child;
					clip.step(elapsed);
					#if flash
					cast(clip.view, Bitmap).bitmapData = tilesheet.getBitmap(clip.indice);
					#end
				}

				var sprite:TileSprite = cast child;
				
				#if flash
				sprite.view.scaleX = sprite.view.scaleY = sprite.scale;
				sprite.view.alpha = sprite.alpha;
				var tileWidth = sprite.size.width * sprite.scale / 2;
				var tileHeight = sprite.size.height * sprite.scale / 2;
				if (offsetRotation > 0)
				{
					if (sprite.rotation == 0)
					{
						sprite.view.x = sprite.x - tileWidth + gx;
						sprite.view.y = sprite.y - tileHeight + gy;
						sprite.view.rotation = 0;
					}
					else 
					{
						var ca = Math.cos(-sprite.rotation);
						var sa = Math.sin(-sprite.rotation);
						var xc = tileWidth * ca, xs = tileWidth * sa, 
							yc = tileHeight * ca, ys = tileHeight * sa;
						sprite.view.x = sprite.x - (xc + ys) + gx;
						sprite.view.y = sprite.y - (-xs + yc) + gy;
						sprite.view.rotation = sprite.rotation * rad2deg;
					}
				}
				else 
				{
					sprite.view.x = sprite.x - tileWidth + gx;
					sprite.view.y = sprite.y - tileHeight + gy;
				}
				#else
				list[index] = sprite.x + gx;
				list[index+1] = sprite.y + gy;
				list[index+2] = sprite.indice;
				if (offsetScale > 0) list[index+offsetScale] = sprite.scale;
				if (offsetRotation > 0) list[index+offsetRotation] = sprite.rotation;
				if (offsetRGB > 0) {
					list[index+offsetRGB] = sprite.r;
					list[index+offsetRGB+1] = sprite.g;
					list[index+offsetRGB+2] = sprite.b;
				}
				if (offsetAlpha > 0) list[index+offsetAlpha] = sprite.alpha;
				index += fields;
				#end
			}
		}
		drawList.index = index;
		return index;
	}
}

class TileBase implements Public
{
	var tilesheet:TilesheetEx;
	var parent:TileGroup;
	var x:Float;
	var y:Float;
	#if flash
	var view:DisplayObject;
	#end

	function new()
	{
		x = y = 0;
	}
}

class TileGroup extends TileBase, implements Public
{
	var children:Array<TileBase>;

	function new()
	{
		super();
		children = new Array<TileBase>();
		#if flash
		view = new Sprite();
		#end
	}

	function initChild(item:TileBase)
	{
		item.parent = this;
		if (tilesheet != null && item.tilesheet == null) 
		{
			item.tilesheet = tilesheet;
			if (Std.is(item, TileSprite))
			{
				var sprite:TileSprite = cast item;
				var indices = tilesheet.getAnim(sprite.tile);
				if (Std.is(item, TileClip))
					cast(sprite, TileClip).indices = indices;
				sprite.indice = indices[0];
				sprite.size = tilesheet.getSize(sprite.indice);
				#if flash
				cast(sprite.view, Bitmap).bitmapData = tilesheet.getBitmap(sprite.indice);
				#end
			}
			else cast(item, TileGroup).initChildren();
		}
	}

	function initChildren()
	{
		for(child in children)
			initChild(child);
	}

	inline function indexOf(item:TileBase)
	{
		return Lambda.indexOf(children, item);
	}

	function addChild(item:TileBase)
	{
		#if flash
		cast(view, Sprite).addChild(item.view);
		#end
		removeChild(item);
		initChild(item);
		return children.push(item);
	}

	function addChildAt(item:TileBase, index:Int)
	{
		#if flash
		cast(view, Sprite).addChildAt(item.view, index);
		#end
		removeChild(item);
		initChild(item);
		children.insert(index, item);
		return index;
	}

	function removeChild(item:TileBase)
	{
		if (item.parent == null) return item;
		if (item.parent != this) {
			trace("Invalid parent");
			return item;
		}
		var index = indexOf(item);
		if (index >= 0) 
		{
			#if flash
			cast(view, Sprite).removeChild(item.view);
			#end
			children.splice(index, 1);
			item.parent = null;
		}
		return item;
	}

	function removeChildAt(index:Int)
	{
		#if flash
		cast(view, Sprite).removeChildAt(index);
		#end
		var res = children.splice(index, 1);
		res[0].parent = null;
		return res[0];
	}

	function getChildIndex(item:TileBase)
	{
		return indexOf(item);
	}

	inline function iterator() { return children.iterator(); }

	var numChildren(get_numChildren, null):Int;
	inline function get_numChildren() { return children.length; }

	var height(get_height, null):Float; // TOFIX incorrect with sub groups
	function get_height():Float 
	{
		if (numChildren == 0) return 0;
		var ymin = 9999.0, ymax = -9999.0;
		for(child in children)
			if (Std.is(child, TileSprite)) {
				var sprite = cast(child, TileSprite);
				var h = sprite.height;
				var top = sprite.y - h/2;
				var bottom = top + h;
				if (top < ymin) ymin = top;
				if (bottom > ymax) ymax = bottom;
			}
		return ymax - ymin;
	}

	var width(get_width, null):Float; // TOFIX incorrect with sub groups
	function get_width():Float 
	{
		if (numChildren == 0) return 0;
		var xmin = 9999.0, xmax = -9999.0;
		for(child in children)
			if (Std.is(child, TileSprite)) {
				var sprite = cast(child, TileSprite);
				var w = sprite.width;
				var left = sprite.x - w/2;
				var right = left + w;
				if (left < xmin) xmin = left;
				if (right > xmax) xmax = right;
			}
		return xmax - xmin;
	}
}

class TileSprite extends TileBase, implements Public
{
	var tile:String;
	var indice:Int;
	var size:Rectangle;

	var rotation:Float;
	var scale:Float;
	var alpha:Float;
	var r:Float;
	var g:Float;
	var b:Float;

	function new(tile:String) 
	{
		super();
		rotation = 0;
		alpha = scale = 1;
		this.tile = tile;
		#if flash
		view = new Bitmap();
		#end
	}

	var height(get_height, null):Float;
	inline function get_height():Float {
		return size.height * scale;
	}

	var width(get_width, null):Float;
	inline function get_width():Float {
		return size.width * scale;
	}
}

class TileClip extends TileSprite, implements Public
{
	var indices:Array<Int>;
	var fps:Int;
	var time:Int;

	function new(tile:String, fps = 18)
	{
		super(tile);
		this.fps = fps;
	}

	function step(elapsed:Int)
	{
		time += elapsed;
		indice = indices[currentFrame];
	}

	var currentFrame(get_currentFrame, set_currentFrame):Int;

	function get_currentFrame():Int 
	{
		var frame:Int = Math.floor((time / 1000) * fps);
		return frame % indices.length;
	}
	function set_currentFrame(value:Int):Int 
	{
		time = cast 1000 * value / fps;
		return value;
	}
}

class DrawList implements Public
{
	var list:Array<Float>;
	var index:Int;
	var fields:Int;
	var offsetScale:Int;
	var offsetRotation:Int;
	var offsetRGB:Int;
	var offsetAlpha:Int;
	var time:Int;
	var elapsed:Int;

	function new(flags:Int) 
	{
		list = new Array<Float>();
		fields = 3;
		if ((flags & TileLayer.TILE_SCALE) > 0) { offsetScale = fields; fields++; }
		else offsetScale = 0;
		if ((flags & TileLayer.TILE_ROTATION) > 0) { offsetRotation = fields; fields++; }
		else offsetRotation = 0;
		if ((flags & TileLayer.TILE_RGB) > 0) { offsetRGB = fields; fields+=3; }
		else offsetRGB = 0;
		if ((flags & TileLayer.TILE_ALPHA) > 0) { offsetAlpha = fields; fields++; }
		else offsetAlpha = 0;
	}

	function begin() 
	{
		index = 0;
		if (time > 0) {
			var t = Lib.getTimer();
			elapsed = cast Math.min(67, t - time);
			time = t;
		}
		else time = Lib.getTimer();
	}

	function end()
	{
		if (list.length > index) 
			list.splice(index, list.length - index);
	}
}

interface TilesheetEx
{
	function getAnim(name:String):Array<Int>;
	function getSize(indice:Int):nme.geom.Rectangle;
	#if flash
	function getBitmap(indice:Int):BitmapData;
	#end
	function drawTiles(graphics:Graphics, tileData:Array<Float>, smooth:Bool = false, flags:Int = 0):Void;
}

