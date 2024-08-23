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

	public function setCharacter(x:Float, y:Float, char:String = 'bf')
	{
		antialiasing = true;

		charOffset = new FlxPoint(0, 0);
		camOffset = new FlxPoint(0, 0);

		if (isQuickDancer)
			defaultIdle = 'danceRight';

		switch (character)
		{
			default:
				frames = Paths.getSparrowAtlas("BOYFRIEND");

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false); // swapped animz lol
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false); // swapped animz lol
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
