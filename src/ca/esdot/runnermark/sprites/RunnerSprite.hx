package ca.esdot.runnermark.sprites;

import aze.display.TileLayer;

class RunnerSprite extends GenericSprite
{
	public var enemyList:Array<GenericSprite>;

	public function new(layer:TileLayer,type:String) 
	{
		super(layer,type);
		//mirror = 1;
		//scale = 2;
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
		
		if(enemyList == null || isJumping) return;

		var w = width;
		for (enemy in enemyList) 
		{
			if (enemy.x > x && enemy.x - x < w * 1.5) {
				velY = -22;
				isJumping = true;
				break;
			}
		}
		
	}
}