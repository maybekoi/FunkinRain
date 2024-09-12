package rain.game;

import rain.game.Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var sections:Int;
	var sectionLengths:Array<Dynamic>;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Int;
	public var sections:Int;
	public var sectionLengths:Array<Dynamic> = [];
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';

	public var validScore:Bool = true;

	public function new(song, notes, bpm, sections)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
		this.sections = sections;

		for (i in 0...notes.length)
		{
			this.sectionLengths.push(notes[i]);
		}
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson:String = null;
		var modPath = "mods/";
		var basePath = 'assets/songs/${folder.toLowerCase()}/${jsonInput.toLowerCase()}.json';

		if (FileSystem.exists(modPath))
		{
			for (modDir in FileSystem.readDirectory(modPath))
			{
				var modFilePath = '${modPath}${modDir}/songs/${folder.toLowerCase()}/${jsonInput.toLowerCase()}.json';
				if (FileSystem.exists(modFilePath))
				{
					rawJson = File.getContent(modFilePath).trim();
					break;
				}
			}
		}

		if (rawJson == null)
		{
			if (Assets.exists(basePath))
			{
				rawJson = Assets.getText(basePath).trim();
			}
			else
			{
				throw 'Song file not found: ${basePath}';
			}
		}

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
}