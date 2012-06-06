package ca.esdot.runnermark.sprites;

import aze.display.TileClip;

class GenericSprite extends TileClip
{
	public var groundY:Int;
	var gravity:Float;
	var isJumping:Bool;
	var velY:Float;

	public function new(type:String) 
	{
		super(type);
		gravity = 1;
		velY = 0;
	}
}
