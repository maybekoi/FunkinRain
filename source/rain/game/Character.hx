package rain.game;

import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import hscript.Interp;
import hscript.Parser;
import lime.utils.Assets;

using StringTools;

typedef CharacterFile =
{
	var ?position:Array<Float>;
	var ?camera_position:Array<Float>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var iconName:String = null;

	public var hscript:Interp;

	var danced:Bool = false;

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		animOffsets = new Map<String, Array<Dynamic>>();
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		loadCharacterScript(curCharacter);
	}

	private function loadCharacterScript(character:String)
	{
		try
		{
			var parser = new Parser();
			var scriptContent:String = null;
			var scriptPath = 'assets/data/chars/${character}.hscript';

			#if desktop
			for (mod in Modding.trackedMods)
			{
				var modPath = 'mods/${mod.id}/data/chars/${character}.hscript';
				if (Assets.exists(modPath))
				{
					scriptPath = modPath;
					break;
				}
			}
			#end

			if (Assets.exists(scriptPath))
			{
				scriptContent = Assets.getText(scriptPath);
			}
			else
			{
				throw 'Character script not found: ${scriptPath}';
			}

			var program = parser.parseString(scriptContent);

			hscript = new Interp();
			hscript.variables.set("icon", null);
			hscript.variables.set("character", this);
			hscript.variables.set("addByPrefix", function(name:String, prefix:String, frameRate:Int = 24, looped:Bool = false)
			{
				animation.addByPrefix(name, prefix, frameRate, looped);
			});
			hscript.variables.set("addByIndices", function(name:String, prefix:String, indices:Array<Int>, framerate:Int = 24, looped:Bool = false)
			{
				animation.addByIndices(name, prefix, indices, "", framerate, looped);
			});
			hscript.variables.set("addOffset", addOffset);
			hscript.variables.set("playAnim", playAnim);
			hscript.variables.set("loadGraphic", function(path:String)
			{
				var imagePath = 'assets/images/${path}.png';
				var xmlPath = 'assets/images/${path}.xml';

				#if desktop
				for (mod in Modding.trackedMods)
				{
					var modImagePath = 'mods/${mod.id}/images/${path}.png';
					var modXmlPath = 'mods/${mod.id}/images/${path}.xml';
					if (Assets.exists(modImagePath) && Assets.exists(modXmlPath))
					{
						imagePath = modImagePath;
						xmlPath = modXmlPath;
						break;
					}
				}
				#end

				var tex = FlxAtlasFrames.fromSparrow(imagePath, xmlPath);
				frames = tex;
			});

			hscript.execute(program);

			var iconFromScript = hscript.variables.get("icon");
			if (iconFromScript != null)
			{
				iconName = iconFromScript;
			}
			else
			{
				iconName = character;
			}
		}
		catch (e:Dynamic)
		{
			trace('Error loading character script for ${character}: ${e}');
			iconName = character;
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation != null && animation.curAnim != null)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				var dadVar:Float = 4;

				if (curCharacter == 'dad')
					dadVar = 6.1;
				if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
				{
					dance();
					holdTimer = 0;
				}
			}
		}
		super.update(elapsed);
	}

	public function dance()
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				default:
					playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		if (animation != null && animation.curAnim != null)
		{
			var daOffset = animOffsets.get(animation.curAnim.name);
			if (animOffsets.exists(animation.curAnim.name))
			{
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);

			if (curCharacter == 'gf')
			{
				if (AnimName == 'singLEFT')
				{
					danced = true;
				}
				else if (AnimName == 'singRIGHT')
				{
					danced = false;
				}

				if (AnimName == 'singUP' || AnimName == 'singDOWN')
				{
					danced = !danced;
				}
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
