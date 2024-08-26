package rain.game;

import flixel.math.FlxPoint;

class Character extends RainSprite
{
	public var charOffset:FlxPoint;
	public var camOffset:FlxPoint;

	public var character:String;

	public var player:Bool = false;
	public var holdTimer:Float = 0;
	public var dadVar:Float = 4;

	public var isQuickDancer:Bool = false;

	public var idleSuffix:String = '';

	public var defaultSingAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var defaultIdle:String = 'idle';

	public function new(player:Bool):Void
	{
		super(x, y);

		this.player = player;
	}

	public function setCharacter(x:Float, y:Float, char:String = '')
	{
		antialiasing = SaveManager.antialiasEnabled;
		character = char;

		charOffset = new FlxPoint(0, 0);
		camOffset = new FlxPoint(0, 0);

		if (isQuickDancer)
			defaultIdle = 'danceRight';

		trace("Setting character: " + character);

		switch (character)
		{
			case 'dad':
				// DAD ANIMATION LOADING CODE
				frames = Paths.getSparrowAtlas("chars/DADDY_DEAREST");
				animation.addByPrefix('idle', 'Dad idle dance', 24);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				playAnim('idle');
			case 'bf':
				frames = Paths.getSparrowAtlas("chars/BOYFRIEND");

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				playAnim('idle');

				if (!player)
					y += 320;

				flipX = true;

			default:
				trace("Warning: Unknown character '" + character + "', using default");
				frames = Paths.getSparrowAtlas("chars/BOYFRIEND");

				animation.addByPrefix('idle', 'BF idle dance', 24, true);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				playAnim('idle');

				if (!player)
					y += 320;

				flipX = true;
		}

		dance();

		if (player)
			flipX = !flipX;

		/*
			x += charOffset.x;
			y += (charOffset.y - (frameHeight * scale.y));

			this.x = x;
			this.y = y;
		 */

		setPosition(x, y);

		return this;
	}

	private var isRight:Bool = false;

	public function dance()
	{
		if (isQuickDancer)
		{
			isRight = !isRight;

			var directionTo:String = (isRight ? "Right" : "Left");

			if (animOffsets.exists("dance" + directionTo + idleSuffix))
				playAnim("dance" + directionTo + idleSuffix);
		}
		else
			playAnim("idle" + idleSuffix);
	}
}