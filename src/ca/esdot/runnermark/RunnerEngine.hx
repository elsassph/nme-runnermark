package ca.esdot.runnermark;

import ca.esdot.runnermark.sprites.EnemySprite;
import ca.esdot.runnermark.sprites.GenericSprite;
import ca.esdot.runnermark.sprites.RunnerSprite;

import aze.display.TileLayer;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.GradientType;
import nme.display.Sprite;
import nme.geom.Matrix;
import nme.Lib;

class RunnerEngine extends Sprite
{	
	static inline var SPEED:Float = 0.33;
	
	var tilesheet:TilesheetEx;
	var layer:TileLayer;
	var _root:TileGroup;

	// Display Objects
	var sky:Bitmap;
	var bgStrip1:TileGroup;
	var bgStrip2:TileGroup;
	var runner:RunnerSprite;
	
	// pools
	var spritePool:Hash<Array<GenericSprite>>;
	var tilePool:Hash<Array<TileSprite>>;
	var groundList:Array<TileSprite>;
	var particleList:Array<TileSprite>;
	var enemyList:Array<GenericSprite>;
	
	var stageWidth:Int;
	var stageHeight:Int;
	
	var steps:Int;
	var startTime:Int;
	var groundY:Int;
	var lastGroundPiece:TileSprite;
	
	var incrementDelay:Int;
	var maxIncrement:Int;
	var lastIncrement:Int;
	
	public var fps:Int;
	public var targetFPS:Int;
	
	var _runnerScore:Int;

	public var onComplete:Void -> Void;
	
	public function new(layer:TileLayer, stageWidth:Int, stageHeight:Int) 
	{
		super();
		
		this.layer = layer;
		_root = layer.dom;

		lastIncrement = Lib.getTimer() + 2000;
		fps = -1;
		targetFPS = 58;
		runnerScore = 0;
		incrementDelay = 250;
		maxIncrement = 12000;

		spritePool = new Hash<Array<GenericSprite>>();
		tilePool = new Hash<Array<TileSprite>>();
		groundList = new Array<TileSprite>();
		particleList = new Array<TileSprite>();
		enemyList = new Array<GenericSprite>();

		createChildren();
		
		this.stageWidth = stageWidth;
		this.stageHeight = stageHeight;
		
		sky.width = stageWidth;
		sky.height = stageHeight;
		
		bgStrip1.y = stageHeight - Std.int(bgStrip1.height/2) - 50;
		bgStrip2.y = stageHeight - Std.int(bgStrip2.height/2) - 50;
		
		//Create Runner
		groundY = Std.int(stageHeight - 50);
		runner.x = stageWidth * .2;
		runner.y = groundY - 65;
		runner.groundY = Std.int(runner.y);
		runner.enemyList = enemyList;
		
		//Add Ground
		addGround(3);
		
		//Add Particles
		addParticles(32);

		// add tile layer
		addChild(layer);
	}

	public var runnerScore(get_runnerScore, set_runnerScore):Int;
	
	function get_runnerScore():Int
	{
		return _runnerScore;
	}

	function set_runnerScore(value:Int):Int
	{
		_runnerScore = value;
		return _runnerScore;
	}

	/**
	 * CREATE METHODS
	 * Override these to create a new type of testSuite
	 **/
	public function createChildren():Void 
	{
		var skyData:BitmapData = createSkyData();			
		sky = new Bitmap(skyData);
		addChild(sky);
		
		var bitmap1, bitmap2;

		//BG Strip 1
		bgStrip1 = new TileGroup();
		bitmap1 =  new TileSprite("bg1");
		bitmap1.scale = 2;
		bgStrip1.addChild(bitmap1);
		bitmap2 = new TileSprite("bg1");
		bitmap2.scale = 2;
		bgStrip1.addChild(bitmap2);
		_root.addChild(bgStrip1);
		bitmap1.x = bitmap1.width / 2;
		bitmap2.x = bitmap1.x + bitmap1.width;
		
		//BG Strip 2
		bgStrip2 = new TileGroup();
		bitmap1 =  new TileSprite("bg2");
		bitmap1.scale = 2;
		bgStrip2.addChild(bitmap1);
		bitmap2 = new TileSprite("bg2");
		bitmap2.scale = 2;
		bgStrip2.addChild(bitmap2);
		_root.addChild(bgStrip2);
		bitmap1.x = bitmap1.width / 2;
		bitmap2.x = bitmap1.x + bitmap1.width;
		
		//Runner
		runner = new RunnerSprite("Runner");
		_root.addChild(runner);
	}
	
	function createGroundPiece():TileSprite 
	{
		var sprite:TileSprite = getTile("ground");
		if (sprite == null)
			sprite = new TileSprite("ground");
		
		_root.addChildAt(sprite, _root.getChildIndex(bgStrip2) + 1);
		return sprite; 
	}
	
	function createParticle():TileSprite 
	{
		var sprite:TileSprite = getTile("cloud");
		if (sprite == null)
			sprite = new TileSprite("cloud");
		
		_root.addChild(sprite);
		return sprite;
	}
	
	function createEnemy():EnemySprite 
	{
		var sprite:EnemySprite = cast getSprite("Enemy");
		if (sprite == null)
			sprite = new EnemySprite("Enemy");
		
		_root.addChildAt(sprite, _root.getChildIndex(runner) - 1);
		return sprite;
	}
	
	
	/**
	 * UPDATE METHODS
	 * Probably won't need to override any of these, unless you're doing some advanced optimizations.
	 **/
	function updateRunner(elapsed:Float)
	{
		runner.update();
	}
	
	function updateBg(elapsed:Float):Void 
	{
		bgStrip1.x -= elapsed * SPEED * .25;
		if (bgStrip1.x < -bgStrip1.width/2){ bgStrip1.x = 0; }

		bgStrip2.x -= elapsed * SPEED * .5;
		if (bgStrip2.x < -bgStrip2.width/2){ bgStrip2.x = 0; }
	}
	
	function updateGround(elapsed:Float)
	{
		//Add platforms
		if (steps % (fps > 30? 100 : 50) == 0)
			addGround(1, Std.int(stageHeight * .25 + stageHeight * .5 * Math.random()));
		
		//Move Ground
		var ground:TileSprite;
		var i = groundList.length-1;
		while (i >= 0) 
		{
			ground = groundList[i];
			ground.x -= elapsed * SPEED;
			//Remove ground
			if (ground.x < -ground.width/2) {
				groundList.splice(i, 1);
				putTile(ground);
			}
			i--;
		}
		//Add Ground
		var lastX:Float = (lastGroundPiece != null)? lastGroundPiece.x + lastGroundPiece.width/2 : 0;
		if (lastX < stageWidth) 
			addGround(1, 0);
	}
	
	function updateParticles(elapsed:Float):Void 
	{
		if (steps % 3 == 0)
			addParticles(3);
		
		//Move Particls
		var p:TileSprite;
		var i = particleList.length-1;
		while (i >= 0) 
		{
			p = particleList[i];
			p.x -= elapsed * SPEED * .2;
			p.alpha -= .01;
			p.scale -= .01;
			//Remove Particle
			if (p.alpha < 0 || p.scale < 0) {
				particleList.splice(i, 1);
				putTile(p);
			}
			i--;
		}
	}
	
	function updateEnemies(elapsed:Float):Void 
	{ 
		var enemy:EnemySprite;
		var i = enemyList.length-1;
		while (i >= 0) 
		{
			enemy = cast enemyList[i];
			enemy.x -= elapsed * .33;
			enemy.update();
			//Loop to other edge of screen
			if (enemy.x < -enemy.width)
				enemy.x = stageWidth + 20;
			i--;
		}
	}
	
	
	/**
	 * CORE ENGINE
	 * You shouldn't need to override anything below this.
	 **/
	public function step(elapsed:Float):Void 
	{
		steps++;

		if(enemyList.length > 0)
			runnerScore = targetFPS * 10 + enemyList.length;
		else
			runnerScore = fps * 10;
		
		runner.rotation += 0.1;
		updateRunner(elapsed);
		updateBg(elapsed);
		if(enemyList != null) updateEnemies(elapsed);
		if(groundList != null) updateGround(elapsed);
		updateParticles(elapsed);
		
		var increment:Int = Lib.getTimer() - lastIncrement;
		if (fps >= targetFPS && increment > incrementDelay) {
			addEnemies(Std.int(1 + Math.floor(enemyList.length/50)));
			lastIncrement = Lib.getTimer();
		} 
		else if (increment > maxIncrement) {
			//Test is Complete!
			if (onComplete != null) onComplete();
			stopEngine();
		}
	}
	
	function stopEngine():Void 
	{
		while(_root.numChildren > 0)
			_root.removeChildAt(0);
	}
	
	
	function removeEnemy(enemy:GenericSprite):Void 
	{
		if(enemy.parent != null)
			enemy.parent.removeChild(enemy);
	}
	
	function addGround(numPieces:Int, height:Int = 0):Void 
	{
		var lastX:Float = 0;
		if(lastGroundPiece != null)
			lastX = Std.int(lastGroundPiece.x + lastGroundPiece.width / 2 - 1);
		
		var piece:TileSprite = null;
		for (i in 0...numPieces)
		{
			piece = createGroundPiece(); 
			piece.y = groundY + piece.height/2 - height;
			piece.x = lastX + piece.width/2;
			lastX += Std.int(piece.width/2 - 1);
			groundList.push(piece);
		}
		if (height == 0) lastGroundPiece = piece; 
	}
	
	function addParticles(numParticles:Int):Void 
	{
		var p:TileSprite;
		for (i in 0...numParticles)
		{
			p = createParticle(); 
			p.x = runner.x - 40;
			p.y = runner.y + runner.height / 4 + runner.height * .25 * Math.random() - 10;
			particleList.push(p);
			p.scale = 0.6;
			p.alpha = 0.6;
		}
	}
	
	public function addEnemies(numEnemies:Int = 1):Void 
	{
		var enemy:EnemySprite;
		for (i in 0...numEnemies) 
		{
			enemy = createEnemy(); 
			enemy.y = groundY - enemy.height/2 + 12;
			enemy.x = stageWidth - 50 + Math.random() * 100;
			enemy.groundY = Std.int(enemy.y);
			enemy.y = -enemy.height;
			enemyList.push(enemy);
		}
	}
	
	function createSkyData():BitmapData 
	{
		var m:Matrix = new Matrix();
		m.createGradientBox(64, 64, Math.PI/2);
		var rect:Sprite = new Sprite();
		rect.graphics.beginGradientFill(GradientType.LINEAR, [0x0, 0x1E095E], [1, .5], [0, 255], m);
		rect.graphics.drawRect(0, 0, 128, 128);
		var skyData:BitmapData = new BitmapData(128, 128, false, 0x0);
		skyData.draw(rect);
		return skyData;
	}
	
	public var numEnemies(get_numEnemies, null):Int;
	function get_numEnemies():Int {
		return enemyList.length;
	}
	
	//Simple Pooling Functions
	public function getSprite(type:String):GenericSprite {

		if (spritePool.exists(type))
			return spritePool.get(type).pop();
		return null;
	}
	
	public function putSprite(sprite:GenericSprite):Void 
	{
		if (sprite.parent != null)
			sprite.parent.removeChild(sprite);
		//Rewind before we return ;)
		sprite.x = sprite.y = 0;
		sprite.scale = 1;
		sprite.alpha = 1;
		sprite.rotation = 0;
		
		//Put in pool
		if(!spritePool.exists(sprite.tile))
			spritePool.set(sprite.tile, new Array<GenericSprite>());
		spritePool.get(sprite.tile).push(sprite);
	}

	public function getTile(type:String):TileSprite 
	{
		if (tilePool.exists(type))
			return tilePool.get(type).pop();
		return null;
	}
	
	public function putTile(sprite:TileSprite):Void 
	{
		if (sprite.parent != null)
			sprite.parent.removeChild(sprite);
		//Rewind before we return ;)
		sprite.x = sprite.y = 0;
		sprite.scale = 1;
		sprite.alpha = 1;
		sprite.rotation = 0;
		
		//Put in pool
		if(!tilePool.exists(sprite.tile))
			tilePool.set(sprite.tile, new Array<TileSprite>());
		tilePool.get(sprite.tile).push(sprite);
	}
	
}
