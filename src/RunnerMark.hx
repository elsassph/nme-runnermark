package;

import ca.esdot.runnermark.RunnerEngine;
import nme.display.Shape;
import nme.geom.Point;

import aze.display.TileLayer;
import aze.display.SparrowTilesheet;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.Lib;
import nme.net.URLLoader;
import nme.net.URLRequest;
import nme.text.TextField;
import nme.text.TextFormat;

class RunnerMark extends Sprite
{
	var prevTime:Int;
	var engine:RunnerEngine;

	var sheetData:String;
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
		stageWidth = stage.stageWidth;
		stageHeight = stage.stageHeight;
		#if iphone
		if (stageWidth < 960) { // iPhone classic
			stageWidth *= 2;
			stageHeight *= 2;
			Lib.current.scaleX = Lib.current.scaleY = 0.5;
		}
		if (stageWidth > 1024) { // iPad retina
			stageWidth = cast stageWidth / 2;
			stageHeight = cast stageHeight / 2;
			Lib.current.scaleX = Lib.current.scaleY = 2;
		}
		#elseif flash
		stage.quality = nme.display.StageQuality.LOW;
		#end

		#if js
		// workaround for binary data loading bug in html5
		var ul = new URLLoader(new URLRequest("assets/RunnerMark.xml")); 
		ul.addEventListener(Event.COMPLETE, ul_complete);
		#else
		sheetData = Assets.getText("assets/RunnerMark.xml");
		createScene();
		#end
	}

	function ul_complete(e)
	{
		sheetData = e.target.data;
		createScene();
	}

	function createScene()
	{
		/* 
		 * Uncomment the Assets.getBitmapData(... line to switch the texture quality.
		 * You would decide this depending on the device resolution.
		 * 
		 * Notes:
		 * - when using texture scaling, make sure (TexturePackate allows it) to place elements at coordinates 
		 * 	 which are multiples of 1/scale factor (ie. a x0.5 factor means even coordinates)
		 */
		var tilesheet:SparrowTilesheet = new SparrowTilesheet(
			//Assets.getBitmapData("assets/RunnerMark-high.png"), sheetData, 2);
			//Assets.getBitmapData("assets/RunnerMark-low.png"), sheetData, 0.5);
			Assets.getBitmapData("assets/RunnerMark.png"), sheetData);
		
		RunnerEngine.targetFPS = 58; // score = FPS*10 + ennemies.length
		
		layer = new TileLayer(tilesheet);
		
		engine = new RunnerEngine(layer, stageWidth, stageHeight);
		engine.onComplete = onEngineComplete;
		addChild(engine);
		
		prevTime = Lib.getTimer();
		createStats();
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
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
		createScene();
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
		
		var tf:TextFormat = new TextFormat("_sans", 48, 0xFFFFFF, true);
		var score:TextField = new TextField();
		score.defaultTextFormat = tf;
		score.text = ""+engine.runnerScore;
		score.width = 300;
		score.height = 50;
		score.x = Std.int(bg.x + (bg.width - score.textWidth) / 2);
		score.y = Std.int(bg.y + (bg.height - score.textHeight) / 2);
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
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;

		Lib.current.addChild(new RunnerMark());
	}
}
