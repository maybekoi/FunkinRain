package rain.ui;

import flixel.FlxSprite;
import flixel.animation.FlxAnimation;
import lime.utils.Assets;

class StrumNote extends FlxSprite {
	public var json:Dynamic;
	public var direction:Int = 0;

	public var offsets = [0, 0];

	override public function new(x:Float, y:Float, ?direction:Int = 0, ?keyCount:Int = 4) {
		super(x, y);

		this.direction = direction;
		loadNoteAssets(direction);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false, ?reversed:Bool = false, ?frame:Int = 0) {
		if (animation.getByName(anim) != null) {
			animation.play(anim, force, reversed, frame);
			centerOffsets();
			centerOrigin();

			offset.set(offset.x + offsets[0], offset.y + offsets[1]);
		}
	}

	public function loadNoteAssets(?direction:Null<Int>) {
		if (!Assets.exists('assets/images/ui/game/NoteConfig.json')) {
		}

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

		if (json.antialiasing == true)
			antialiasing = SaveManager.antialiasEnabled;
		else
			antialiasing = false;

		scale.set(json.size, json.size);
		updateHitbox();

		playAnim("static");
	}
}
