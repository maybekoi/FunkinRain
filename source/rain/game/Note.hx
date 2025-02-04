package rain.game;

import flixel.FlxG;
import flixel.FlxSprite;
import lime.utils.Assets;

using StringTools;

class Note extends FlxSprite
{
	public var noteskin:String = 'default';
	public var direction:Int = 0;

	public var strum:Float = 0.0;
	public var isSustainNote:Bool = false;
	public var isEndNote:Bool = false;
	public var shouldHit:Bool = true;
	public var sustainLength:Float = 0;

	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;

	public var keyCount:Int = 4;

	public static var swagWidth:Float = 160 * 0.7;

	public var scaleX:Float = 0;
	public var scaleY:Float = 0;

	public var lastNote:Note;

	public var origPos:Array<Float> = [0, 0];

	public var rawNoteData:Int = 0;

	public var json:Dynamic = null;

	public var offsets = [0, 0];

	public var mustPress:Bool = false;

	public var isBeingHeld:Bool = false;

	public function new(x, y, direction:Int = 0, ?strum:Float, ?isSustainNote:Bool = false, ?isEndNote:Bool = false, ?keyCount:Int = 4)
	{
		super(x, y);

		this.direction = direction;
		this.strum = strum;
		this.isSustainNote = isSustainNote;
		this.isEndNote = isEndNote;
		this.keyCount = keyCount;

		loadNoteSkin(direction);
		setOrigPos();

		if (isSustainNote && lastNote != null)
		{
			alpha = 0.6;

			x += width / 2;

			if (isEndNote)
				playAnim("holdend");
			else
				playAnim("hold");

			updateHitbox();

			x -= width / 2;

			if (lastNote.isSustainNote)
			{
				lastNote.playAnim("hold");
				lastNote.scale.y *= Conductor.stepCrochet / 100 * 1.5;
				lastNote.updateHitbox();
			}
		}
	}

	public function setOrigPos()
	{
		origPos = [x, y];
	}

	public function loadNoteSkin(?direction:Int = 0)
	{
		// ADD MOD SUPPORT TO THIS CHECK
		if (!Assets.exists('assets/images/ui/game/NoteConfig.json')) {}

		if (direction == null)
			direction = this.direction;

		frames = RainUtil.getSparrow('ui/game/notes');
		json = RainUtil.getJson('images/ui/game/NoteConfig');

		if (json.offsets != null)
			offsets = json.offsets;
		else
			offsets = [0, 0];

		animation.addByPrefix("static", json.animations[direction][0], json.framerate, false);
		animation.addByPrefix("press", json.animations[direction][1], json.framerate, false);
		animation.addByPrefix("confirm", json.animations[direction][2], json.framerate, false);
		animation.addByPrefix("note", json.animations[direction][3], json.framerate, false);
		animation.addByPrefix("hold", json.animations[direction][4], json.framerate, false);
		animation.addByPrefix("holdend", json.animations[direction][5], json.framerate, false);

		if (json.antialiasing == true)
			antialiasing = SaveManager.antialiasEnabled;
		else
			antialiasing = false;

		scale.set(json.size, json.size);
		updateHitbox();

		if (isSustainNote)
		{
			scale.y *= Conductor.stepCrochet / 100 * 1.5;
			updateHitbox();

			if (isEndNote)
				playAnim("holdend");
			else
				playAnim("hold");
		}
		else
		{
			playAnim("note");
		}
	}

	public function playAnim(anim:String, ?force:Bool = false)
	{
		animation.play(anim, force);

		centerOffsets();
		centerOrigin();

		offset.set(offset.x + offsets[0], offset.y + offsets[1]);
	}

	override public function update(elapsed:Float)
	{
		scaleX = scale.x;
		scaleY = scale.y;

		super.update(elapsed);
	}

	public function calculateCanBeHit()
	{
		if (this != null)
		{
			if (isSustainNote)
			{
				if (shouldHit)
				{
					if (strum > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
						&& strum < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
						canBeHit = true;
					else
						canBeHit = false;
				}
				else
				{
					if (strum > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
						&& strum < Conductor.songPosition + Conductor.safeZoneOffset * 0.2)
						canBeHit = true;
					else
						canBeHit = false;
				}
			}
			else
			{
				if (shouldHit)
				{
					if (strum > Conductor.songPosition - Conductor.safeZoneOffset
						&& strum < Conductor.songPosition + Conductor.safeZoneOffset)
						canBeHit = true;
					else
						canBeHit = false;
				}
				else
				{
					if (strum > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
						&& strum < Conductor.songPosition + Conductor.safeZoneOffset * 0.2)
						canBeHit = true;
					else
						canBeHit = false;
				}
			}

			if (strum < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
	}
}
