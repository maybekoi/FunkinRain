package rain.states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import rain.SaveManager;
import rain.ui.Alphabet;
import flixel.util.FlxColor;

class InitState extends RainState
{
	private var antialiasOption:FlxText;
	private var flashingLightsOption:FlxText;
	private var startButton:FlxButton;

	private static inline var ANTIALIAS_Y:Float = 100;
	private static inline var FLASHING_LIGHTS_Y:Float = 160;

	override public function create():Void
	{
		super.create();

		var title = new Alphabet(0, 20, "Initial Setup!", true);
		title.screenCenter(X);
		add(title);

		antialiasOption = new FlxText(20, ANTIALIAS_Y, FlxG.width - 40, "", 16);
		antialiasOption.setFormat(null, 16, FlxColor.WHITE, LEFT);
		add(antialiasOption);

		flashingLightsOption = new FlxText(20, FLASHING_LIGHTS_Y, FlxG.width - 40, "", 16);
		flashingLightsOption.setFormat(null, 16, FlxColor.WHITE, LEFT);
		add(flashingLightsOption);

		startButton = new FlxButton(0, FlxG.height - 60, "Start Game", onStartClick);
		startButton.screenCenter(X);
		add(startButton);

		updateOptionsDisplay();
	}

	private function updateOptionsDisplay():Void
	{
		antialiasOption.text = "Antialiasing: " + (SaveManager.antialiasEnabled ? "ON" : "OFF");
		flashingLightsOption.text = "Flashing Lights: " + (SaveManager.flashingLightsEnabled ? "ON" : "OFF");
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed)
		{
			if (antialiasOption.overlapsPoint(FlxG.mouse.getWorldPosition()))
			{
				toggleAntialias();
			}
			else if (flashingLightsOption.overlapsPoint(FlxG.mouse.getWorldPosition()))
			{
				toggleFlashingLights();
			}
		}
	}

	private function toggleAntialias():Void
	{
		SaveManager.antialiasEnabled = !SaveManager.antialiasEnabled;
		updateOptionsDisplay();
		FlxG.stage.quality = SaveManager.antialiasEnabled ? flash.display.StageQuality.HIGH : flash.display.StageQuality.LOW;
	}

	private function toggleFlashingLights():Void
	{
		SaveManager.flashingLightsEnabled = !SaveManager.flashingLightsEnabled;
		updateOptionsDisplay();
	}

	private function onStartClick():Void
	{
		RainState.switchState(new AlphaState());
	}
}
