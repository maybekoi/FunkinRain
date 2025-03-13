package rain.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import rain.game.SongData;

class PauseSubstate extends RainSubstate
{
	private var options:Array<String> = ['Resume', 'Restart', 'Quit'];
	private var optionTexts:FlxTypedGroup<FlxText>;
	private var currentSelection:Int = 0;
	private var pauseOverlay:FlxSprite;
	private var titleText:FlxText;
	private var songText:FlxText;
	private var difficultyText:FlxText;
	private var selector:FlxSprite;

	public function new()
	{
		super();

		pauseOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		pauseOverlay.alpha = 0;
		add(pauseOverlay);
		FlxTween.tween(pauseOverlay, {alpha: 0.6}, 0.2);

		titleText = new FlxText(0, 40, FlxG.width, "PAUSED");
		titleText.setFormat("assets/fonts/vcr.ttf", 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleText.borderSize = 2;
		titleText.alpha = 0;
		titleText.y -= 20;
		add(titleText);
		FlxTween.tween(titleText, {alpha: 1, y: titleText.y + 20}, 0.3, {startDelay: 0.1});

		var formattedSongName = PlayState.SONG.song.split("-").map(word -> word.charAt(0).toUpperCase() + word.substr(1).toLowerCase()).join(" ");
		songText = new FlxText(0, 120, FlxG.width, formattedSongName);
		songText.setFormat("assets/fonts/vcr.ttf", 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songText.borderSize = 1.5;
		songText.alpha = 0;
		songText.y -= 20;
		add(songText);
		FlxTween.tween(songText, {alpha: 1, y: songText.y + 20}, 0.3, {startDelay: 0.2});

		difficultyText = new FlxText(0, 160, FlxG.width, '< ${PlayState.storyDifficulty == 0 ? "EASY" : PlayState.storyDifficulty == 1 ? "NORMAL" : "HARD"} >');
		difficultyText.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.GRAY, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		difficultyText.borderSize = 1;
		difficultyText.alpha = 0;
		difficultyText.y -= 20;
		add(difficultyText);
		FlxTween.tween(difficultyText, {alpha: 1, y: difficultyText.y + 20}, 0.3, {startDelay: 0.3});

		optionTexts = new FlxTypedGroup<FlxText>();
		add(optionTexts);

		for (i in 0...options.length)
		{
			var optionText = new FlxText(0, 250 + (i * 60), FlxG.width, options[i]);
			optionText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionText.borderSize = 1;
			optionText.ID = i;
			optionText.alpha = 0;
			optionText.y -= 20;
			optionTexts.add(optionText);
			FlxTween.tween(optionText, {alpha: 1, y: optionText.y + 20}, 0.3, {startDelay: 0.3 + (i * 0.1)});
		}

		selector = new FlxSprite().makeGraphic(20, 30, FlxColor.WHITE);
		selector.alpha = 0;
		add(selector);
		FlxTween.tween(selector, {alpha: 1}, 0.3, {startDelay: 0.6});

		updateSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
		{
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
		{
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
		{
			selectOption();
		}
	}

	private function changeSelection(change:Int = 0):Void
	{
		currentSelection += change;

		if (currentSelection < 0)
			currentSelection = options.length - 1;
		if (currentSelection >= options.length)
			currentSelection = 0;

		updateSelection();
	}

	private function updateSelection():Void
	{
		var i:Int = 0;
		for (text in optionTexts.members)
		{
			text.color = i == currentSelection ? FlxColor.YELLOW : FlxColor.WHITE;
			if (i == currentSelection)
			{
				selector.x = text.x - 20;
				selector.y = text.y + (text.height / 2) - (selector.height / 2);
			}
			i++;
		}
	}

	private function selectOption():Void
	{
		switch (options[currentSelection].toLowerCase())
		{
			case "resume":
				close();
			case "restart":
				SongData.currentSong = PlayState.SONG;
				SongData.currentDifficulty = cast(FlxG.state, PlayState).instance.difficulty;
				SongData.gameMode = cast(FlxG.state, PlayState).instance.GameMode;
				RainState.switchState(new PlayState());
			case "quit":
				RainState.switchState(new MainMenuState());
		}
	}
}
