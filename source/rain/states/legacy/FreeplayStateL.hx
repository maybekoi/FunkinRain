package rain.states.legacy;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import polymod.Polymod;

using StringTools;

class FreeplayStateL extends RainState
{
	private var songTexts:Array<Alphabet> = [];
	private var FreeplayWeekD:Array<FreeplayWeekD> = [];
	private var difficulties:Array<String> = [];
	private var currentSelection:Int = 0;
	private var difficultyText:FlxText;
	private var currentDifficulty:Int = 1;
	private var iconArray:Array<HealthIcon> = [];

	override public function create():Void
	{
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menus/bgs/menuBG'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = SaveManager.antialiasEnabled;
		add(bg);

		var title = new FlxText(0, 20, FlxG.width, "Freeplay", 32);
		title.setFormat(Paths.font("Phantomuff Difficult Font.ttf"), 32, FlxColor.BLACK, CENTER);
		add(title);

		super.create();

		loadFreeplayWeekD();
		displaySongs();
		createDifficultySelector();
	}

	private function loadFreeplayWeekD():Void
	{
		var weekPath = "assets/data/weeks/";
		var modWeekPath = "mods/";
		var files = [];

		// Load base game weeks
		if (FileSystem.exists(weekPath))
		{
			files = files.concat(FileSystem.readDirectory(weekPath).map(file -> weekPath + file));
		}

		// Load mod weeks
		if (FileSystem.exists(modWeekPath))
		{
			for (modDir in FileSystem.readDirectory(modWeekPath))
			{
				if (!FlxG.save.data.disabledMods.contains(modDir))
				{
					var modWeekDir = modWeekPath + modDir + "/data/weeks/";
					if (FileSystem.exists(modWeekDir))
					{
						files = files.concat(FileSystem.readDirectory(modWeekDir).map(file -> modWeekDir + file));
					}
				}
			}
		}

		for (file in files)
		{
			if (file.endsWith(".json"))
			{
				var content = File.getContent(file);
				var data:FreeplayWeekD = Json.parse(content);
				data.fileName = file.split("/").pop().substr(0, -5).toLowerCase();
				FreeplayWeekD.push(data);
			}
		}

		// Sort FreeplayWeekD based on a potential 'order' field or fileName
		FreeplayWeekD.sort((a, b) ->
		{
			if (Reflect.hasField(a, "order") && Reflect.hasField(b, "order"))
			{
				return Std.int(Reflect.field(a, "order")) - Std.int(Reflect.field(b, "order"));
			}
			return Reflect.compare(a.fileName, b.fileName);
		});
	}

	private function displaySongs():Void
	{
		var yPos:Float = 100;

		for (week in FreeplayWeekD)
		{
			for (song in week.songs)
			{
				var songText = new Alphabet(0, 0, song, true);
				songText.targetY = songTexts.length;
				songText.y = yPos;
				songText.screenCenter(X);
				add(songText);
				songTexts.push(songText);

				var icon:HealthIcon = new HealthIcon(week.icon);
				icon.sprTracker = songText;
				iconArray.push(icon);
				add(icon);

				yPos += 120;
			}
		}
	}

	private function createDifficultySelector():Void
	{
		difficulties = FreeplayWeekD[0].difficulties;
		difficultyText = new FlxText(20, 20, 180, "", 24);
		difficultyText.setFormat(Paths.font("Phantomuff Difficult Font.ttf"), 32, FlxColor.BLACK, LEFT);
		add(difficultyText);
		updateDifficultyText();
	}

	private function updateDifficultyText():Void
	{
		var difficultyName = difficulties[currentDifficulty];
		difficultyText.text = difficultyName;

		switch (difficultyName.toLowerCase())
		{
			case "easy":
				difficultyText.color = FlxColor.GREEN;
			case "hard":
				difficultyText.color = FlxColor.RED;
			default:
				difficultyText.color = FlxColor.BLACK;
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.UP)
		{
			changeSelection(-1);
		}
		else if (FlxG.keys.justPressed.DOWN)
		{
			changeSelection(1);
		}
		else if (FlxG.keys.justPressed.LEFT)
		{
			changeDifficulty(-1);
		}
		else if (FlxG.keys.justPressed.RIGHT)
		{
			changeDifficulty(1);
		}
		else if (FlxG.keys.justPressed.ENTER)
		{
			loadSelectedSong();
		}
		else if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
		{
			RainState.switchState(new MainMenuState());
		}
	}

	private function loadSelectedSong():Void
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		var selectedSong:String = songTexts[currentSelection].text;
		var selectedDifficulty:String = difficulties[currentDifficulty];

		var jsonSuffix = selectedDifficulty.toLowerCase() == "normal" ? "" : "-" + selectedDifficulty.toLowerCase();
		var songData:Dynamic = null;

		var formattedSongName = StringTools.replace(selectedSong.toLowerCase(), " ", "-");

		try
		{
			songData = Song.loadFromJson(formattedSongName + jsonSuffix, formattedSongName);
		}
		catch (e:Dynamic)
		{
			trace('Failed to load song data with dashes: ${e}');

			formattedSongName = StringTools.replace(selectedSong.toLowerCase(), " ", "");

			try
			{
				songData = Song.loadFromJson(formattedSongName + jsonSuffix, formattedSongName);
			}
			catch (e:Dynamic)
			{
				trace('Failed to load song data without spaces: ${e}');
				return;
			}
		}

		if (songData == null)
		{
			trace('Song data is null');
			return;
		}

		SongData.currentSong = songData;
		SongData.currentDifficulty = selectedDifficulty;
		SongData.gameMode = Modes.FREEPLAY;

		var weekIndex:Int = getWeekIndexForSong(selectedSong);
		if (weekIndex != -1)
		{
			SongData.opponent = FreeplayWeekD[weekIndex].opponent;
			SongData.currentWeek = null;
			SongData.weekSongIndex = -1;
		}
		FlxG.sound.music.volume = 0;
		RainState.switchState(new PlayState());
	}

	private function getWeekIndexForSong(song:String):Int
	{
		for (i in 0...FreeplayWeekD.length)
		{
			if (FreeplayWeekD[i].songs.contains(song))
			{
				return i;
			}
		}
		return -1;
	}

	private function changeDifficulty(change:Int):Void
	{
		currentDifficulty += change;

		if (currentDifficulty < 0)
			currentDifficulty = difficulties.length - 1;
		if (currentDifficulty >= difficulties.length)
			currentDifficulty = 0;

		updateDifficultyText();
	}

	private function changeSelection(change:Int):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		currentSelection += change;

		if (currentSelection < 0)
			currentSelection = songTexts.length - 1;
		if (currentSelection >= songTexts.length)
			currentSelection = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[currentSelection].alpha = 1;
	}
}

typedef FreeplayWeekD =
{
	var weekName:String;
	var songs:Array<String>;
	var difficulties:Array<String>;
	var icon:String;
	var opponent:String;
	var stage:String;
	var ?fileName:String;
	var ?order:Int;
}
