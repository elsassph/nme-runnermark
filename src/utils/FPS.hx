package utils;

import nme.Lib;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.events.Event;

class FPS extends TextField
{
	public var fps:Int;
	var prev:Int;
	var prevScore:Int;
	public var score:Int;
	var times:Array<Float>;

	public function new(inX:Float=10.0, inY:Float=10.0, inCol:Int = 0x000000)
	{
		super();
		x = inX;
		y = inY;
		selectable = false;
		defaultTextFormat = new TextFormat("_sans", 20, inCol, true);
		setText("FPS:");
		multiline = true;
		width = 150;
		times = [];
		addEventListener(Event.ENTER_FRAME, onEnter);
	}

	function setText(text:String) 
	{
		#if js
		htmlText = '<span style="font-family:Arial; font-size:20px; color:#' 
			+ StringTools.hex(defaultTextFormat.color, 6) + '">' + text + '</span>';
		#else
		htmlText = text;
		#end
	}

	public function onEnter(_)
	{
		var now = Lib.getTimer () / 1000;
		times.push(now);
		while(times[0]<now-1)
			times.shift();
		fps = times.length;

		if (visible && (prev != fps || prevScore != score))
		{
			prev = fps;
			prevScore = score;
			setText("FPS: " + fps + "<br/>score: " + score);
		}
	}

}
