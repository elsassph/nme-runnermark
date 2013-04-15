package ca.esdot.runnermark.sprites;

import aze.display.TileLayer;

class EnemySprite extends GenericSprite
{
	public function new(layer:TileLayer,type:String)
	{
		super(layer,type);
	}
	
	public function update():Void 
	{
		velY += gravity;
		y += velY; 
		if (y > groundY) {
			y = groundY;
			isJumping = false;
			velY = 0;
		}
		
		if (!isJumping && y == groundY && Math.random() < .02) {
			velY = -height * .25;
			isJumping = true;
		}
		
	}
}