package rain;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

class RainState extends FlxUIState
{
	public var lastBeat:Float = 0;
	public var lastStep:Float = 0;

	public var totalBeats:Int = 0;
	public var totalSteps:Int = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;

	override function create()
	{
		super.create();
	}

	override function update(elapsed:Float)
	{
		everyStep();
		updateCurStep();
		updateBeat();
		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.round(curStep / 4);
	}

	/**
	 * CHECKS EVERY FRAME
	 */
	private function everyStep():Void
	{
		if (Conductor.songPosition > lastStep + Conductor.stepCrochet - Conductor.safeZoneOffset
			|| Conductor.songPosition < lastStep + Conductor.safeZoneOffset)
		{
			if (Conductor.songPosition > lastStep + Conductor.stepCrochet)
			{
				stepHit();
			}
		}
	}

	private function updateCurStep():Void
	{
		curStep = Math.floor(Conductor.songPosition / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		totalSteps += 1;
		lastStep += Conductor.stepCrochet;

		// If the song is at least 3 steps behind
		if (Conductor.songPosition > lastStep + (Conductor.stepCrochet * 3))
		{
			lastStep = Conductor.songPosition;
			totalSteps = Math.ceil(lastStep / Conductor.stepCrochet);
		}

		if (totalSteps % 4 == 0)
			beatHit();
	}

	public static function switchState(nextState:FlxState)
	{
		var curState:Dynamic = FlxG.state;
		var leState:RainState = curState;
		if (!FlxTransitionableState.skipNextTransIn)
		{
			if (nextState == FlxG.state)
			{
				startCoolTransition(() -> FlxG.resetState());
			}
			else
			{
				startCoolTransition(() -> FlxG.switchState(nextState));
			}
			return;
		}
		if (FlxTransitionableState.skipNextTransIn)
			FlxG.switchState(nextState);
		else
			startTransition(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}

	private static function startCoolTransition(onComplete:() -> Void):Void
	{
		var blackOverlay:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		blackOverlay.alpha = 0;
		FlxG.state.add(blackOverlay);

		FlxTween.tween(blackOverlay, {alpha: 1}, 0.5, {
			ease: FlxEase.quartInOut,
			onComplete: function(_)
			{
				onComplete();
			}
		});
	}

	public static function resetState()
	{
		if (FlxTransitionableState.skipNextTransIn)
			FlxG.resetState();
		else
			startTransition();
		FlxTransitionableState.skipNextTransIn = false;
	}

	// Pulled from psych :skull:
	public static function startTransition(nextState:FlxState = null)
	{
		if (nextState == null)
			nextState = FlxG.state;

		if (nextState == FlxG.state)
			FlxG.resetState();
		else
			FlxG.switchState(nextState);
	}

	public function beatHit():Void
	{
		lastBeat += Conductor.crochet;
		totalBeats += 1;
	}
}
