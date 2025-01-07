package rain.states;

import rain.RainState;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;

class MainMenuState extends RainState
{
	var optionsArray:Array<String> = ["story mode", "freeplay", "options"];
	var selected:Int = 0;
	var menuItems:FlxTypedGroup<FlxSprite>;
	var camFollow:FlxObject;
	var bitchCounter:Int = 0;

	override public function create():Void
	{
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		persistentUpdate = persistentDraw = true;

		Modding.reload();

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menus/bgs/menuBG'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = SaveManager.antialiasEnabled;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		var magenta:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menus/bgs/menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('menus/mainmenu/FNF_main_menu_assets');

		for (i in 0...optionsArray.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionsArray[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionsArray[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.06);

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
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
	
	var selsumn:Bool = false;

	override public function update(elapsed:Float):Void
	{
		if (!selsumn)
		{
			if(FlxG.keys.justPressed.UP)
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
				switch (bitchCounter)
				{
					case 0:
						RainState.switchState(new StoryMenuStateL());
					case 1:
						RainState.switchState(new FreeplayStateL());
					case 2:
						RainState.switchState(new OptionsState());
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
