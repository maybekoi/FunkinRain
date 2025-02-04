package rain.game;

import rain.game.Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;
import moonchart.formats.fnf.FNFVSlice;

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
	var gfVersion:String;
	var validScore:Bool;
	var noteStyle:String;
	var stage:String;
	var ?isVslice:Bool;
	var ?chartPath:String;
	var ?metadataPath:String;
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
	public var gfVersion:String = 'gf';

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
		var rawJson = "";

		if (jsonInput.startsWith("songs/"))
		{
			trace('Loading V-Slice song from: assets/${jsonInput}');
			if (FileSystem.exists('assets/${jsonInput}'))
			{
				rawJson = File.getContent('assets/${jsonInput}');
				var vsliceData = Json.parse(rawJson);
				var songData = convertVSliceToSwagSong(vsliceData, FreeplayState.curDifficulty);
				songData.isVslice = true;
				songData.chartPath = jsonInput;

				var metadataPath = jsonInput.replace("-chart.json", "-metadata.json");
				if (FileSystem.exists('assets/${metadataPath}'))
				{
					var metadataJson = File.getContent('assets/${metadataPath}');
					var metadata = Json.parse(metadataJson);
					songData.song = metadata.songName;
					songData.metadataPath = metadataPath;
				}
				else
				{
					trace('Metadata file not found at: assets/${metadataPath}');
				}

				return songData;
			}
		}
		else if (FileSystem.exists('assets/data/songs/${jsonInput}.json'))
		{
			trace('Loading regular song from: assets/data/songs/${jsonInput}.json');
			rawJson = File.getContent('assets/data/songs/${jsonInput}.json');
			return parseJSONshit(rawJson);
		}

		trace('Song file not found: ${jsonInput}');
		return null;
	}

	private static function convertVSliceToSwagSong(vsliceData:Dynamic, difficulty:Int):SwagSong
	{
		var swagSong:SwagSong = {
			song: vsliceData.name ?? "Unknown",
			notes: [],
			bpm: vsliceData.bpm,
			sections: 0,
			sectionLengths: [],
			needsVoices: true,
			speed: Reflect.field(Reflect.field(vsliceData, "scrollSpeed"), "normal") ?? 1.0,
			player1: 'bf',
			player2: 'dad',
			gfVersion: 'gf',
			validScore: true,
			noteStyle: "",
			stage: ""
		};

		var currentSection:SwagSection = null;
		var currentTime:Float = 0;
		var sectionLength:Float = 4 * (60000 / vsliceData.bpm);

		var difficultyName = switch (difficulty)
		{
			case 0: "easy";
			case 2: "hard";
			default: "normal";
		}

		trace('Converting V-Slice chart for difficulty: ${difficultyName} (${difficulty})');
		trace('Available difficulties: ${Reflect.fields(vsliceData.notes)}');

		var allNotes:Array<Dynamic> = Reflect.field(vsliceData.notes, difficultyName);
		if (allNotes == null)
		{
			trace('No notes found for difficulty: ${difficultyName}');
			return swagSong;
		}

		trace('Found ${allNotes.length} notes for difficulty: ${difficultyName}');

		allNotes.sort((a, b) -> Std.int(Reflect.field(a, "t") - Reflect.field(b, "t")));

		for (note in allNotes)
		{
			var noteTime:Float = note.t;
			var sectionIndex:Int = Math.floor(noteTime / sectionLength);

			if (currentSection == null || noteTime >= (sectionIndex + 1) * sectionLength)
			{
				if (currentSection != null)
				{
					swagSong.notes.push(currentSection);
				}

				currentSection = {
					lengthInSteps: 16,
					bpm: vsliceData.bpm,
					changeBPM: false,
					mustHitSection: true,
					sectionNotes: [],
					typeOfSection: 0,
					altAnim: false,
					sectionBeats: 4
				};
			}

			currentSection.sectionNotes.push([noteTime, note.d, note.l ?? 0]);
		}

		if (currentSection != null)
		{
			swagSong.notes.push(currentSection);
		}

		return swagSong;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
