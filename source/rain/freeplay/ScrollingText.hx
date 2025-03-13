package rain.freeplay;

import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;

class ScrollingText
{
	public static function createScrollingText(x:Float, y:Float, text:FlxText):FlxBackdrop
	{
		text.drawFrame(true);
		var backdrop = new FlxBackdrop(text.pixels, X, 0, 0);
		backdrop.x = x;
		backdrop.y = y;
		backdrop.antialiasing = true;
		return backdrop;
	}
}

typedef ScrollingTextInfo =
{
	text:String,
	font:String,
	size:Int,
	color:FlxColor,
	position:FlxPoint,
	velocity:Float
}