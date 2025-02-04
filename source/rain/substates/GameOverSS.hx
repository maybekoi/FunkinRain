package rain.substates;

import rain.states.FreeplayState;
import rain.RainSubstate;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import rain.game.SongData;

class GameOverSS extends RainSubstate
{
	var bof:Character;
	var camFollow:FlxObject;

	public function new(x:Float, y:Float)
	{
		super();

		bof = new Character(x, y, null, true);
		add(bof);

		camFollow = new FlxObject(bof.getGraphicMidpoint().x, bof.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
		Conductor.changeBPM(100);

		bof.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
		{
			FlxG.sound.music.stop();
			RainState.switchState(new FreeplayState(false, camFollow.getPosition()));
		}
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
		{
			endGO();
		}
		if (bof.animation.curAnim.name == 'firstDeath' && bof.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bof.animation.curAnim.name == 'firstDeath' && bof.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver'));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		super.update(elapsed);
	}

	var isDone:Bool = false;

	function endGO()
	{
		if (!isDone)
		{
			isDone = true;
			bof.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('gameOverEnd'));
			SongData.currentSong = PlayState.SONG;
			SongData.currentDifficulty = cast(FlxG.state, PlayState).instance.difficulty;
			SongData.gameMode = cast(FlxG.state, PlayState).instance.GameMode;
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				RainState.switchState(new PlayState());
			});
		}
	}
}
