package rain.states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class FreeplayState extends RainState
{
    private var songTexts:Array<Alphabet> = [];
    private var weekData:Array<WeekData> = [];
    private var difficulties:Array<String> = [];
    private var currentSelection:Int = 0;
    private var difficultyText:FlxText;
    private var currentDifficulty:Int = 1;
	private var iconArray:Array<HealthIcon> = [];

    override public function create():Void
    {
        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menus/bg/menuBG'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

        var title = new FlxText(0, 20, FlxG.width, "Freeplay", 32);
        title.setFormat(Paths.font("Phantomuff Difficult Font.ttf"), 32, FlxColor.BLACK, CENTER);
        add(title);

        super.create();

        loadWeekData();
        displaySongs();
        createDifficultySelector();
    }

    private function loadWeekData():Void
    {
        var weekPath = "assets/data/weeks/";
        var files = FileSystem.readDirectory(weekPath);

        for (file in files)
        {
            if (file.endsWith(".json"))
            {
                var content = File.getContent(weekPath + file);
                var data:WeekData = Json.parse(content);
                weekData.push(data);
            }
        }
    }

    private function displaySongs():Void
    {
        var yPos:Float = 100;

        for (week in weekData)
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
        difficulties = weekData[0].difficulties;
        difficultyText = new FlxText(FlxG.width - 200, 20, 180, "", 24);
        difficultyText.setFormat(Paths.font("Phantomuff Difficult Font.ttf"), 32, FlxColor.BLACK, RIGHT);
        add(difficultyText);
        updateDifficultyText();
    }

    private function updateDifficultyText():Void
    {
        difficultyText.text = difficulties[currentDifficulty];
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
            FlxG.switchState(new MainMenuState());
        }

    }

    private function loadSelectedSong():Void
    {
        FlxG.sound.play(Paths.sound('confirmMenu'));
        var selectedSong:String = songTexts[currentSelection].text;
        var selectedDifficulty:String = difficulties[currentDifficulty];
        
        var songData:Dynamic = null;
        try {
            songData = Song.loadFromJson(selectedSong.toLowerCase(), selectedSong.toLowerCase());
        } catch (e:Dynamic) {
            trace('Failed to load song data: ${e}');
            return;
        }
    
        if (songData == null) {
            trace('Song data is null');
            return;
        }
    
        SongData.currentSong = songData;
        SongData.currentDifficulty = selectedDifficulty;
        SongData.gameMode = Modes.FREEPLAY;
    
        var weekIndex:Int = getWeekIndexForSong(selectedSong);
        if (weekIndex != -1) {
            SongData.opponent = weekData[weekIndex].opponent;
        }
        FlxG.sound.music.volume = 0;
        FlxG.switchState(new PlayState());
    }

    private function getWeekIndexForSong(song:String):Int
    {
        for (i in 0...weekData.length) {
            if (weekData[i].songs.contains(song)) {
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

typedef WeekData = {
    var weekName:String;
    var songs:Array<String>;
    var difficulties:Array<String>;
    var icon:String;
    var opponent:String;
}