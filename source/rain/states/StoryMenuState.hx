package rain.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import polymod.Polymod;
using StringTools;

class StoryMenuState extends RainState
{
    private var weekData:Array<StoryWeekData> = [];
    private var curSelected:Int = 0;
    private var weekGroup:FlxTypedGroup<FlxSprite>;
    private var weekText:FlxText;
    private var leftBox:FlxSprite;
    private var rightBox:FlxSprite;

    override public function create():Void
    {
        super.create();

        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menus/bg/menuBG'));
        bg.scrollFactor.set(0, 0);
        bg.setGraphicSize(Std.int(bg.width * 1.175));
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = SaveManager.antialiasEnabled;
        add(bg);

        leftBox = new FlxSprite(0, 0).makeGraphic(200, FlxG.height, FlxColor.BLACK);
        add(leftBox);

        rightBox = new FlxSprite(FlxG.width - 200, 0).makeGraphic(200, FlxG.height, FlxColor.BLACK);
        add(rightBox);

        weekGroup = new FlxTypedGroup<FlxSprite>();
        add(weekGroup);

        loadWeekData();
        createWeekSprites();

        weekText = new FlxText(20, 20, FlxG.width - 40, "");
        weekText.setFormat(Paths.font("Phantomuff Difficult Font.ttf"), 32, FlxColor.BLACK, CENTER);
        add(weekText);

        updateSelection();
    }

    private function loadWeekData():Void
    {
        var weekPath = "assets/data/weeks/";
        var modWeekPath = "mods/";
        var files = [];

        // Load base game weeks
        if (FileSystem.exists(weekPath)) {
            files = files.concat(FileSystem.readDirectory(weekPath).map(file -> weekPath + file));
        }

        // Load mod weeks
        if (FileSystem.exists(modWeekPath)) {
            for (modDir in FileSystem.readDirectory(modWeekPath)) {
                if (!FlxG.save.data.disabledMods.contains(modDir)) {
                    var modWeekDir = modWeekPath + modDir + "/data/weeks/";
                    if (FileSystem.exists(modWeekDir)) {
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
                var data:StoryWeekData = Json.parse(content);
                data.fileName = file.split("/").pop().substr(0, -5).toLowerCase();
                weekData.push(data);
            }
        }

        // Sort weekData based on a potential 'order' field or fileName
        weekData.sort((a, b) -> {
            if (Reflect.hasField(a, "order") && Reflect.hasField(b, "order")) {
                return Std.int(Reflect.field(a, "order")) - Std.int(Reflect.field(b, "order"));
            }
            return Reflect.compare(a.fileName, b.fileName);
        });
    }

    private function createWeekSprites():Void
    {
        for (i in 0...weekData.length)
        {
            var weekSprite = new FlxSprite(0, 160 + (i * 120));
            var imagePath = 'assets/images/weeks/${weekData[i].fileName}.png';
            
            if (FileSystem.exists(imagePath))
            {
                weekSprite.loadGraphic(Paths.image('weeks/${weekData[i].fileName}'));
            }
            else
            {
                weekSprite.makeGraphic(FlxG.width - 400, 100, FlxColor.fromRGB(50, 50, 50));
            }
            
            weekSprite.updateHitbox();
            weekSprite.screenCenter(X);
            weekGroup.add(weekSprite);
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.UP)
        {
            changeSelection(-1);
        }
        if (FlxG.keys.justPressed.DOWN)
        {
            changeSelection(1);
        }
        if (FlxG.keys.justPressed.ENTER)
        {
            selectWeek();
        }
        if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
        {
            RainState.switchState(new MainMenuState());
        }
    }

    private function changeSelection(change:Int = 0):Void
    {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        curSelected += change;
        if (curSelected < 0)
            curSelected = weekData.length - 1;
        if (curSelected >= weekData.length)
            curSelected = 0;

        updateSelection();
    }

    private function updateSelection():Void
    {
        var selectedWeek = weekData[curSelected];
        weekText.text = selectedWeek.weekName + "\n" + selectedWeek.songs.join(" - ");

        for (i in 0...weekGroup.length)
        {
            var weekSprite = weekGroup.members[i];
            weekSprite.alpha = (i == curSelected) ? 1 : 0.6;
        }
    }

    private function selectWeek():Void
    {
        FlxG.sound.play(Paths.sound('confirmMenu'));
        var selectedWeek = weekData[curSelected];
        
        trace("Selected week: " + selectedWeek.weekName);
        trace("Songs in week: " + selectedWeek.songs.join(", "));
        
        SongData.currentWeek = selectedWeek;
        SongData.weekSongIndex = 0;
        SongData.gameMode = Modes.STORYMODE;
        SongData.currentDifficulty = null;
        SongData.currentSong = null;
        
        openSubState(new DifficultySelectSubstate(selectedWeek));
    }
}

typedef StoryWeekData = {
    var weekName:String;
    var songs:Array<String>;
    var difficulties:Array<String>;
    var icon:String;
    var opponent:String;
    var stage:String;
    var ?fileName:String;
    var ?order:Int;
}