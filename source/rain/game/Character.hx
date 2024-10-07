package rain.game;

import flixel.math.FlxPoint;
import hscript.Interp;
import hscript.Parser;
import sys.io.File;
import polymod.Polymod;
import sys.FileSystem;
import flixel.FlxG;

class Character extends RainSprite
{
	public var charOffset:FlxPoint;
	public var camOffset:FlxPoint;

	public var character:String;

	public var player:Bool = false;
	public var holdTimer:Float = 0;
	public var singDuration:Float = 4;

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

		var characterData:Dynamic = null;
		var basePath = "assets/data/chars/";
		var modPath = "mods/";
		var files = [];

		// Load base game character
		var baseCharPath = basePath + char + ".hscript";
		if (FileSystem.exists(baseCharPath))
		{
			files.push(baseCharPath);
		}

		// Load mod character
		if (FileSystem.exists(modPath))
		{
			for (modDir in FileSystem.readDirectory(modPath))
			{
				if (!FlxG.save.data.disabledMods.contains(modDir))
				{
					var modCharPath = modPath + modDir + "/data/chars/" + char + ".hscript";
					if (FileSystem.exists(modCharPath))
					{
						files.push(modCharPath);
					}
				}
			}
		}

		if (files.length > 0)
		{
			try
			{
				var content = File.getContent(files[files.length - 1]);
				characterData = executeHScript(content);
			}
			catch (e:Dynamic)
			{
				trace('Failed to load character data: $e');
			}
		}

		if (characterData != null)
		{
			loadCharacterFromHScript(characterData);
		}
		else
		{
			trace("Warning: Character HScript not found for '" + char + "', using default");
			loadDefaultCharacter();
		}

		dance();

		if (player)
			flipX = !flipX;

		setPosition(x, y);

		return this;
	}

	private function executeHScript(script:String):Dynamic
	{
		var parser = new Parser();
		var program = parser.parseString(script);

		var interp = new Interp();
		interp.execute(program);

		return interp.variables;
	}

	private function loadCharacterFromHScript(data:Dynamic)
	{
		if (data.get("asset") != null)
			frames = Paths.getSparrowAtlas(data.get("asset"));

		if (data.get("healthIcon") != null)
			// do nothing for now
			if (data.get("flipX") != null)
				flipX = data.get("flipX");

		if (data.get("singDuration") != null)
			singDuration = data.get("singDuration");

		if (data.get("animations") != null)
		{
			for (anim in cast(data.get("animations"), Array<Dynamic>))
			{
				if (anim.indices != null && anim.indices.length > 0)
				{
					animation.addByIndices(anim.name, anim.prefix, anim.indices, "", anim.fps, anim.loop);
				}
				else
				{
					animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.loop);
				}

				if (anim.offsets != null && anim.offsets.length == 2)
				{
					addOffset(anim.name, anim.offsets[0], anim.offsets[1]);
				}
			}
		}

		playAnim('idle');
	}

	private function loadDefaultCharacter()
	{
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

		if (!player)
			y += 320;

		flipX = true;
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
