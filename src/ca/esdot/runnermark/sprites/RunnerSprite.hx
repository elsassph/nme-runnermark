package ca.esdot.runnermark.sprites;

class RunnerSprite extends GenericSprite
{
	public var enemyList:Array<GenericSprite>;

	public function new(type:String) 
	{
		super(type);
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