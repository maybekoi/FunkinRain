package rain.states.options;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import rain.SaveManager;
import rain.ui.Alphabet;
import rain.ui.Checkbox;

class GeneralOptionsState extends FlxState
{
	private var options:Array<String> = ["Downscroll", "Middle Scroll", "BotPlay", "Opponent Notes", "Ghost Tapping"];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxes:Array<Checkbox>;
	private var curSelected:Int = 0;

	private static inline var OPTION_SPACING:Float = 120;

	private var optionsCamera:FlxCamera;
	private var camFollow:FlxObject;

	override public function create():Void
	{
		super.create();

		optionsCamera = new FlxCamera();
		optionsCamera.bgColor.alpha = 0;
		FlxG.cameras.add(optionsCamera, false);

		camFollow = new FlxObject(FlxG.width / 2, 0, 1, 1);
		add(camFollow);
		optionsCamera.follow(camFollow, LOCKON, 1);

		grpOptions = new FlxTypedGroup<Alphabet>();
		checkboxes = [];
		add(grpOptions);

		var yOffset:Float = 0;
		if (options.length % 2 == 0)
			yOffset = (OPTION_SPACING / 2);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true, false);
			optionText.screenCenter(X);
			optionText.x -= 200;
			optionText.y = (i * OPTION_SPACING) + (FlxG.height / 2) - ((options.length / 2) * OPTION_SPACING) + yOffset;
			optionText.isMenuItem = true;
			optionText.targetY = i;
			grpOptions.add(optionText);

			var checkbox = new Checkbox(0, optionText.y - 60, options[i]);
			checkbox.x = FlxG.width * 0.75;
			checkboxes.push(checkbox);
			add(checkbox);
		}

		grpOptions.cameras = [optionsCamera];
		for (checkbox in checkboxes)
		{
			checkbox.cameras = [optionsCamera];
		}

		changeSelection();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.UP)
			changeSelection(-1);
		if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);

		if (FlxG.keys.justPressed.ENTER)
			toggleOption();

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
			FlxG.switchState(new OptionsState());
	}

	private function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}

		var newY:Float = (curSelected * OPTION_SPACING) + (FlxG.height / 2) - ((options.length / 2) * OPTION_SPACING);
		FlxTween.tween(camFollow, {y: newY}, 0.2, {ease: FlxEase.quadOut});

		for (i in 0...checkboxes.length)
		{
			checkboxes[i].y = grpOptions.members[i].y - 60;
		}
	}

	private function toggleOption():Void
	{
		checkboxes[curSelected].toggle();
	}
}
