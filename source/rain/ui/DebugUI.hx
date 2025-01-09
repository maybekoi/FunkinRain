package rain.ui;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

class DebugUI extends FlxSpriteGroup {
	private var playState:PlayState;
	public var debugText:FlxText;

	public function new(playState:PlayState) {
		super();
		this.playState = playState;

        debugText = new FlxText(3, 3, 0, "", 20);
		debugText.alpha /= 3;
		//debugText.screenCenter();
		add(debugText);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
        debugText.text = "Funkin' Rain v" + Main.version;
		debugText.text += "\nPosition: " + Math.round(Conductor.songPosition) / 1000;
        debugText.text += "\nHealth: " + playState.health;
        debugText.text += "\nGameMode: " + playState.GameMode;
		debugText.text += "\nMisses: " + playState.misses;
		debugText.text += "\nCombo: " + playState.combo;
		debugText.text += "\nSicks: " + playState.sicks;
		debugText.text += "\nGoods: " + playState.goods;
		debugText.text += "\nBads: " + playState.bads;
		debugText.text += "\nShits: " + playState.shits;
	}
}