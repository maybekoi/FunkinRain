package backend;

import flixel.FlxSprite;
import lime.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import sys.FileSystem;
import sys.io.File;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;

using StringTools;

class RainUtil
{	static public var soundExt:String = ".ogg";
	inline public static final DEFAULT_FOLDER:String = 'assets';

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = Assets.getText('assets/songs/' + folder + '/' + jsonInput.toLowerCase() + '.json').trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}

	static public function getPath(folder:Null<String>, file:String)
	{
		if (folder == null)
			folder = DEFAULT_FOLDER;
		return folder + '/' + file;
	}

	static public function file(file:String, folder:String = DEFAULT_FOLDER)
	{
		if (#if sys FileSystem.exists(folder) && #end (folder != null && folder != DEFAULT_FOLDER))
		{
			return getPath(folder, file);
		}
		return getPath(null, file);
	}

	inline static public function voices(songPath:String):Any
	{
		return file('$songPath.$soundExt');
	}

	inline static public function inst(songPath:String):Any
	{
		return file('$songPath.$soundExt');
	}

    /**
     * Return the contents of a JSON file in the `assets` folder.
     * @param   jsonPath            Path to the json.
     */
	 static public function getJson(filePath:String) {
        #if web
        if (Assets.exists('assets/$filePath.json')) {
            return Json.parse(Assets.getText('assets/$filePath.json'));
        }
        #else
        if (sys.FileSystem.exists(Sys.getCwd() + 'assets/$filePath.json'))
            return Json.parse(sys.io.File.getContent(Sys.getCwd() + 'assets/$filePath.json'));
        #end

        return null;
    }

	/**
     * Return an animated image from the `assets` folder using a png and xml.
     * Only works if there is a png and xml file with the same directory & name.
     * @param   imagePath            Path to the image.
     */
	 static public function getSparrow(pngName:String, ?xmlName:Null<String>, ?customPath:Bool = false) {
        var png = pngName;
        var xml = xmlName;

        if (xmlName == null)
            xml = png;

        if (customPath) {
            png = 'assets/$png';
            xml = 'assets/$xml';
        } else {
            png = 'assets/images/$png';
            xml = 'assets/images/$xml';
        }

        if (sys.FileSystem.exists(Sys.getCwd() + png + ".png") && sys.FileSystem.exists(Sys.getCwd() + xml + ".xml")) {
            var xmlData = sys.io.File.getContent(Sys.getCwd() + xml + ".xml");

            if (Cache.getFromCache(png, "image") == null) {
                var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(Sys.getCwd() + png + ".png"), false, png, false);
                graphic.destroyOnNoUse = false;

                Cache.addToCache(png, graphic, "image");
            }

            return FlxAtlasFrames.fromSparrow(Cache.getFromCache(png, "image"), xmlData);
        }

        return FlxAtlasFrames.fromSparrow("assets/images/errorSparrow" + ".png", "assets/images/errorSparrow" + ".xml");
    }
}

class RainSprite extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;

	public function new(x:Float, y:Float)
	{
		animOffsets = new Map<String, Array<Dynamic>>();

		super();
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];
}