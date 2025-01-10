package rain.states.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import rain.SaveManager;
import rain.ui.Alphabet;

class DisplayOptionsState extends RainState
{
	private var options:Array<String> = ["Fullscreen", "Antialiasing"];
	private var optionTexts:Array<Alphabet> = [];
	private var valueTexts:Array<FlxText> = [];
	private var currentSelection:Int = 0;

	override public function create():Void
	{
		super.create();

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menus/bgs/menuDesat'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = SaveManager.antialiasEnabled;
		add(bg);

		var title = new Alphabet(0, 20, "Display Options", true);
		add(title);

		for (i in 0...options.length)
		{
			var optionText = new Alphabet(20, 100 + i * 80, options[i], false);
			optionTexts.push(optionText);
			add(optionText);

			var valueText = new FlxText(FlxG.width - 220, 100 + i * 80, "", false);
			valueText.setFormat("assets/fonts/Phantomuff Difficult Font.ttf", 32, FlxColor.BLACK, RIGHT);
			valueTexts.push(valueText);
			add(valueText);
		}

		updateOptionValues();
		updateSelection();
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
			changeValue(-1);
		}
		else if (FlxG.keys.justPressed.RIGHT)
		{
			changeValue(1);
		}
		else if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
		{
			FlxG.switchState(new OptionsState());
		}
	}

	private function changeSelection(change:Int):Void
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
		for (i in 0...optionTexts.length)
		{
			optionTexts[i].alpha = i == currentSelection ? 1 : 0.6;
			valueTexts[i].alpha = i == currentSelection ? 1 : 0.6;
		}
	}

	private function changeValue(change:Int):Void
	{
		switch (currentSelection)
		{
			case 0:
				FlxG.fullscreen = !FlxG.fullscreen;
			case 1:
				SaveManager.antialiasEnabled = !SaveManager.antialiasEnabled;
		}

		updateOptionValues();
	}

	private function updateOptionValues():Void
	{
		valueTexts[0].text = FlxG.fullscreen ? "On" : "Off";
		valueTexts[1].text = SaveManager.antialiasEnabled ? "On" : "Off";

		for (i in 0...valueTexts.length)
		{
			valueTexts[i].x = FlxG.width - valueTexts[i].width - 20;
		}
	}
}
