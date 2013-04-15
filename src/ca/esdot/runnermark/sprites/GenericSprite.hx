package ca.esdot.runnermark.sprites;

import aze.display.TileClip;
import aze.display.TileLayer;

class GenericSprite extends TileClip
{
	public var groundY:Int;
	var gravity:Float;
	var isJumping:Bool;
	var velY:Float;

	public function new(layer:TileLayer, type:String) 
	{
		super(layer,type);
		gravity = 1;
		velY = 0;
	}
}
