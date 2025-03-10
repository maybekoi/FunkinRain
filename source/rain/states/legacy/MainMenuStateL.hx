package rain.states.legacy;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class MainMenuStateL extends RainState
{
	private var title:FlxSprite;
	private var storyButton:FlxText;
	private var freeplayButton:FlxText;
	private var optionButton:FlxText;
	private var transitionTimer:FlxTimer;
	private var transitionSpeed:Float = 4000;
	private var modsButton:FlxText;

	override public function create():Void
	{
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('klaskiiLoop'));

		Modding.reload();

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menus/bgs/menuBG'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = SaveManager.antialiasEnabled;
		add(bg);

		title = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/funkin logo'));
		title.scale.set(0.5, 0.5);
		title.screenCenter(X);
		title.updateHitbox();
		title.setPosition(0, -title.height);
		add(title);

		FlxTween.tween(title, {y: 0}, 1.5, {ease: FlxEase.bounceOut});

		storyButton = createButton("Story Mode", 0);
		freeplayButton = createButton("Freeplay", 1);
		optionButton = createButton("Options", 2);
		modsButton = createButton("Mods", 3);

		super.create();

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "Rain [ALPHA] BUILD", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		animateButtons();
	}

	private function createButton(text:String, index:Int):FlxText
	{
		var button = new FlxText(0, FlxG.height + 50, FlxG.width, text);
		button.setFormat(null, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		button.y = FlxG.height / 2 + index * 60;
		button.alpha = 0;
		add(button);
		return button;
	}

	private function animateButtons():Void
	{
		FlxTween.tween(storyButton, {alpha: 1}, 0.5, {startDelay: 0.5});
		FlxTween.tween(freeplayButton, {alpha: 1}, 0.5, {startDelay: 0.7});
		FlxTween.tween(optionButton, {alpha: 1}, 0.5, {startDelay: 0.9});
		FlxTween.tween(modsButton, {alpha: 1, y: modsButton.y - 20}, 0.8, {startDelay: 1.1, ease: FlxEase.elasticOut});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			if (storyButton.overlapsPoint(FlxG.mouse.getWorldPosition()))
			{
				transtoStory();
			}
			else if (freeplayButton.overlapsPoint(FlxG.mouse.getWorldPosition()))
			{
				transtoFreeplay();
			}
			else if (optionButton.overlapsPoint(FlxG.mouse.getWorldPosition()))
			{
				transtoOptions();
			}
			else if (modsButton.overlapsPoint(FlxG.mouse.getWorldPosition()))
			{
				transtoMods();
			}
		}
	}

	private function transtoStory():Void
	{
		FlxTween.tween(title, {y: -title.height, alpha: 0}, 0.5, {ease: FlxEase.backIn});
		FlxTween.tween(storyButton, {x: -FlxG.width}, 0.5, {ease: FlxEase.backIn});
		FlxTween.tween(freeplayButton, {x: FlxG.width}, 0.5, {ease: FlxEase.backIn});
		FlxTween.tween(optionButton, {x: FlxG.width}, 0.5, {ease: FlxEase.backIn});
		FlxTween.tween(optionButton, {y: FlxG.height}, 0.5, {
			ease: FlxEase.backIn,
			onComplete: function(_)
			{
				RainState.switchState(new StoryMenuStateL());
			}
		});
	}

	private function transtoFreeplay():Void
	{
		transitionTimer = new FlxTimer().start(0.016, updateTransition, 0);
	}

	private function updateTransition(timer:FlxTimer):Void
	{
		var moveAmount = transitionSpeed * timer.elapsedTime;

		title.x -= moveAmount;

		storyButton.x -= moveAmount;
		freeplayButton.x -= moveAmount;
		optionButton.x -= moveAmount;

		if (title.x <= -FlxG.width)
		{
			transitionTimer.cancel();
			RainState.switchState(new FreeplayStateL());
		}
	}

	private function transtoOptions():Void
	{
		FlxTween.tween(title, {alpha: 0}, 0.5);
		FlxTween.tween(storyButton, {alpha: 0}, 0.5);
		FlxTween.tween(freeplayButton, {alpha: 0}, 0.5);
		FlxTween.tween(optionButton, {alpha: 0}, 0.5, {
			onComplete: function(_)
			{
				RainState.switchState(new OptionsState());
			}
		});
	}

	private function transtoMods():Void
	{
		FlxTween.tween(title, {y: FlxG.height, alpha: 0}, 0.5, {ease: FlxEase.backIn});
		FlxTween.tween(storyButton, {x: -FlxG.width}, 0.5, {ease: FlxEase.backIn});
		FlxTween.tween(freeplayButton, {x: FlxG.width}, 0.5, {ease: FlxEase.backIn});
		FlxTween.tween(optionButton, {x: -FlxG.width}, 0.5, {ease: FlxEase.backIn});
		FlxTween.tween(modsButton, {y: FlxG.height * 2, angle: 360, alpha: 0}, 0.8, {
			ease: FlxEase.quartInOut,
			onComplete: function(_)
			{
				RainState.switchState(new ModsMenuState());
			}
		});
	}
}
