package backend;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.FlxSprite;
import sys.FileSystem;
import sys.io.File;
import flash.media.Sound;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	#if (haxe >= "4.0.0")
	public static var customImagesLoaded:Map<String, Bool> = new Map();
	public static var customSoundsLoaded:Map<String, Sound> = new Map();
	#else
	public static var customImagesLoaded:Map<String, Bool> = new Map<String, Bool>();
	public static var customSoundsLoaded:Map<String, Sound> = new Map<String, Sound>();
	#end

	static public var currentModDirectory:String = '';
	static var currentLevel:String;
	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline public static function getPreloadPath(file:String = '')
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/songs/$key.json', TEXT, library);
	}

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	public static function getSongScript(song:String) 
	{
		trace('Loading scripts for: ' + song);
		return 'mods/data/$song/script.hx';
	}

	public static function gettempSongScript(song:String) 
	{
		trace('Loading scripts for: ' + song);
		return 'mods/data/scriptcrashpreventor/script.hx';
	}

	static public function video(key:String)
	{
		return 'assets/videos/$key.$VIDEO_EXT';
	}

	inline public static function directoriesWithFile(path:String, fileToFind:String, mods:Bool = true)
	{
		var foldersToCheck:Array<String> = [];
		#if sys
		if(FileSystem.exists(path + fileToFind))
		#end
			foldersToCheck.push(path + fileToFind);
		return foldersToCheck;
	}

	static public function sound(key:String, ?library:String):Dynamic
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}
	
	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Dynamic
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function moosic(key:String, ?library:String):Dynamic
	{
		return getPath('$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String):Any
	{
		return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String):Any
	{
		return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/Inst.$SOUND_EXT';
	}

	inline static public function loadImage(key:String, ?library:String):Dynamic
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function image(key:String, ?library:String):Dynamic
	{
		return getPath('images/$key.png', IMAGE, library);
	}
	
	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if sys

		if (FileSystem.exists(getPreloadPath(key)))
			return File.getContent(getPreloadPath(key));

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(key, currentLevel);
				if (FileSystem.exists(levelPath))
					return File.getContent(levelPath);
			}

			levelPath = getLibraryPathForce(key, 'shared');
			if (FileSystem.exists(levelPath))
				return File.getContent(levelPath);
		}
		#end
		return Assets.getText(getPath(key, TEXT));
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		if(OpenFlAssets.exists(Paths.getPath(key, type))) {
			return true;
		}
		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function formatToSongPath(path:String) {
		return path.toLowerCase().replace(' ', '-');
	}
}