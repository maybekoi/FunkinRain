package rain.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;

class DifficultySelectSubstate extends FlxSubState
{
	var difficulties:Array<String>;
	var currentDifficulty:Int = 1;
	var difficultyGroup:FlxTypedGroup<FlxText>;
	var bg:FlxSprite;
	var selectedWeek:StoryWeekData;

	public function new(weekData:StoryWeekData)
	{
		super();
		this.selectedWeek = weekData;
		this.difficulties = weekData.difficulties;
	}

	override public function create():Void
	{
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		add(bg);

		var title = new FlxText(0, 50, FlxG.width, "Select Difficulty", 32);
		title.setFormat(Paths.font("Phantomuff Difficult Font.ttf"), 32, FlxColor.WHITE, CENTER);
		add(title);

		difficultyGroup = new FlxTypedGroup<FlxText>();
		add(difficultyGroup);

		for (i in 0...difficulties.length)
		{
			var diffText = new FlxText(0, 150 + (i * 60), FlxG.width, difficulties[i], 24);
			diffText.setFormat(Paths.font("Phantomuff Difficult Font.ttf"), 24, FlxColor.WHITE, CENTER);
			diffText.ID = i;
			difficultyGroup.add(diffText);
		}

		updateSelection();
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
			selectDifficulty();
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			close();
		}
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		currentDifficulty += change;

		if (currentDifficulty < 0)
			currentDifficulty = difficulties.length - 1;
		if (currentDifficulty >= difficulties.length)
			currentDifficulty = 0;

		updateSelection();
	}

	function updateSelection():Void
	{
		for (i in 0...difficultyGroup.length)
		{
			var text = difficultyGroup.members[i];
			text.color = i == currentDifficulty ? FlxColor.YELLOW : FlxColor.WHITE;
			text.size = i == currentDifficulty ? 28 : 24;
		}
	}

	function selectDifficulty():Void
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		var selectedDifficulty = difficulties[currentDifficulty];
		trace('Selected difficulty: $selectedDifficulty');
		trace('Current week: ${selectedWeek.weekName}');
		trace('Week song index: ${SongData.weekSongIndex}');
		SongData.currentDifficulty = selectedDifficulty;
		close();
		FlxG.switchState(new PlayState());
	}
}
