package rain.states;

import rain.RainState;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import flixel.FlxCamera.FlxCameraFollowStyle;

class MainMenuState extends RainState
{
	public static var optionsArray:Array<String> = ["storymode", "freeplay", "merch", "options", "credits"];

	var menuItems:FlxTypedGroup<FlxSprite>;
	var camFollow:FlxObject;
	var bitchCounter:Int = 0;
	var magenta:FlxSprite;
	var targetY:Float = 0;
	var lerpVal:Float = 0.16;

	override public function create():Void
	{
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		persistentUpdate = persistentDraw = true;

		Modding.reload();
		Highscore.load();

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menus/bgs/menuBG'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = SaveManager.antialiasEnabled;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menus/bgs/menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = SaveManager.antialiasEnabled;
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('menus/mainmenu/FNF_main_menu_assets');

		var scale:Float = 1;
		for (i in 0...optionsArray.length)
		{
			var offset:Float = 160 - (Math.max(optionsArray.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 160) + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('menus/mainmenu/' + optionsArray[i]);
			menuItem.animation.addByPrefix('idle', optionsArray[i] + " idle", 24);
			menuItem.animation.addByPrefix('selected', optionsArray[i] + " selected", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0, 1);
			menuItem.antialiasing = SaveManager.antialiasEnabled;
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollow, LOCKON, 0.04);

		changeItem();

		super.create();

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "Funkin' Rain ALPHA BUILD | Press 7 to go to the old menus lol", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		bitchCounter += huh;

		if (bitchCounter >= menuItems.length)
			bitchCounter = 0;
		if (bitchCounter < 0)
			bitchCounter = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == bitchCounter)
			{
				spr.animation.play('selected');
				targetY = spr.y + (spr.height / 2);
			}

			spr.updateHitbox();
		});
	}

	var selsumn:Bool = false;

	override public function update(elapsed:Float):Void
	{
		if (camFollow != null && Math.abs(targetY - camFollow.y) > 1)
		{
			camFollow.y = FlxMath.lerp(camFollow.y, targetY, 0.16);
		}

		if (!selsumn)
		{
			if (FlxG.keys.justPressed.UP)
			{
				changeItem(-1);
			}
			if (FlxG.keys.justPressed.DOWN)
			{
				changeItem(1);
			}
			if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
			{
				selsumn = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxFlicker.flicker(magenta, 1.1, 0.15, false);

				if (optionsArray[bitchCounter] == 'merch')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://www.makeship.com/shop/creator/friday-night-funkin", "&"]);
					#else
					FlxG.openURL('https://www.makeship.com/shop/creator/friday-night-funkin');
					#end
				}
				else
				{
					menuItems.forEach(function(spr:FlxSprite)
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							switch (bitchCounter)
							{
								case 0:
									RainState.switchState(new StoryMenuState());
								case 1:
									FlxG.switchState(new FreeplayState(true, camFollow.getPosition()));
								case 3:
									RainState.switchState(new OptionsState());
								case 4:
									// CreditsState
							}
						});
					});
				}
			}
		}

		if (FlxG.keys.justPressed.SEVEN)
			RainState.switchState(new MainMenuStateL());

		if (FlxG.keys.justPressed.TAB)
			RainState.switchState(new ModsMenuState());

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}
}
