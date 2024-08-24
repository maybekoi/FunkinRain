package rain.states;

import flixel.text.FlxText;
import flixel.FlxState;

class AlphaState extends FlxState
{
	var text:Alphabet;
    var text2:Alphabet;
	override public function create()
	{
		FlxG.sound.playMusic(Paths.music('klaskiiLoop'));
		super.create();

		text = new Alphabet(0, 200, "PROJ RAIN is in Early Alpha!", true);
		text.screenCenter(X);
        add(text);

        text = new Alphabet(0, 400, "Press ENTER to continue.", true);
		text.screenCenter(X);
        add(text);
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			RainState.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
