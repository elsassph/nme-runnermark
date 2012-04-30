package;

import ca.esdot.runnermark.RunnerEngine;

import aze.display.TileLayer;
import aze.display.SparrowTilesheet;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageQuality;
import nme.display.StageScaleMode;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.Lib;
import nme.text.TextField;
import nme.text.TextFormat;

class RunnerMark extends Sprite
{
	var prevTime:Int;
	var engine:RunnerEngine;

	var layer:TileLayer;

	var isMouseDown:Bool;
	var stats:utils.FPS;
	var lastAdd:Int;

	var stageWidth:Int;
	var stageHeight:Int;
	
	public function new() 
	{
		super();
		haxe.Timer.delay(init, 250);
	}
	
	function init():Void 
	{
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		stageWidth = stage.stageWidth;
		stageHeight = stage.stageHeight;
		#if iphone
		if (stageWidth < 960) {
			stageWidth *= 2;
			stageHeight *= 2;
			Lib.current.scaleX = Lib.current.scaleY = 0.5;
		}
		#elseif flash
		stage.quality = nme.display.StageQuality.LOW;
		#end

		var tilesheet:SparrowTilesheet = new SparrowTilesheet(
			Assets.getBitmapData("assets/RunnerMark.png"), Assets.getText("assets/RunnerMark.xml"));

		layer = new TileLayer(tilesheet, false, TileLayer.TILE_SCALE | TileLayer.TILE_ALPHA);

		engine = new RunnerEngine(layer, stageWidth, stageHeight);
		engine.onComplete = onEngineComplete;
		addChild(engine);

		prevTime = Lib.getTimer();
		createStats();
	}
	
	function onEnterFrame(event:Event):Void 
	{	
		var elapsed:Float = Lib.getTimer() - prevTime;
		prevTime = Lib.getTimer();
		
		if (engine != null) 
		{
			engine.fps = stats.fps;
			engine.step(elapsed);
			stats.score = engine.runnerScore;
			layer.render();
		}
	}
	
	function restartEngine():Void
	{
		while(numChildren > 0) removeChildAt(0);
		init();
	}
	
	function createStats():Void 
	{
		if (stats == null) stats = new utils.FPS(10,10,0xffffff);
		Lib.current.addChild(stats);
	}
	
	function onEngineComplete():Void 
	{
		while(numChildren > 0) removeChildAt(0);
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		var bg:Bitmap = new Bitmap(Assets.getBitmapData("assets/scoreBg.png"));
		bg.x = Std.int((stageWidth - bg.width)/2);
		bg.y = Std.int((stageHeight - bg.height)/2);
		addChild(bg);
		
		var tf:TextFormat = new TextFormat("_sans", 40, 0xFFFFFF, true);
		var score:TextField = new TextField();
		score.defaultTextFormat = tf;
		score.text = ""+engine.runnerScore;
		score.width = 300;
		score.height = 50;
		score.x = Std.int(bg.x + (bg.width - score.textWidth));
		score.y = Std.int(bg.y + (bg.height - score.textHeight));
		addChild(score);
		
		stage.addEventListener(MouseEvent.CLICK, onRestartClicked);
	}
	
	function onRestartClicked(event:MouseEvent):Void 
	{
		stage.removeEventListener(MouseEvent.CLICK, onRestartClicked);
		restartEngine();	
	}

	static public function main()
	{
		var stage = Lib.current.stage;
		stage.quality = StageQuality.LOW;
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;

		Lib.current.addChild(new RunnerMark());
	}
}
