package rain.ui;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

class HUD extends FlxSpriteGroup {
	private var playState:PlayState;
    private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	var scoreTxt:FlxText;
	private var scoreTween:FlxTween;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public function new(playState:PlayState) {
		super();
		this.playState = playState;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('ui/healthBar'));
        if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

        healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), playState,
        'health', 0, 2);
        healthBar.scrollFactor.set();
        healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
        // healthBar
        add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 150, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

        iconP1 = new HealthIcon(PlayState.SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(PlayState.SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
        updateScoreText();
        iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

        var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;
	}

    function formatNumber(number:Int):String
	{
		var result:String = Std.string(number);
		var rgx = ~/(\d+)(\d{3})/;
		while (rgx.match(result))
		{
			result = rgx.matched(1) + ',' + rgx.matched(2);
		}
		return result;
	}

    function updateScoreText():Void
	{
		if (scoreTween != null)
		{
			scoreTween.cancel();
		}

		scoreTween = FlxTween.num(playState.displayedScore, playState.songScore, 0.5, {ease: FlxEase.quartOut}, function(newValue:Float)
		{
			playState.displayedScore = newValue;
			scoreTxt.text = "Score:" + formatNumber(Math.floor(playState.displayedScore));
		});
	}
}