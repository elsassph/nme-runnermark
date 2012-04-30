package ca.esdot.runnermark.sprites;

class EnemySprite extends GenericSprite
{
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
		
		if (!isJumping && y == groundY && Math.random() < .02) {
			velY = -height * .25;
			isJumping = true;
		}
		
	}
}