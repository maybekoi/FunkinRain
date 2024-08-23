package rain.states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class MainMenuState extends RainState
{
    private var title:FlxSprite;
    private var storyButton:FlxText;
    private var freeplayButton:FlxText;
    private var optionButton:FlxText;
    private var transitionTimer:FlxTimer;
    private var transitionSpeed:Float = 4000;

    override public function create():Void
    {
        if (!FlxG.sound.music.playing)
            FlxG.sound.playMusic(Paths.music('klaskiiLoop'));

        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menus/bg/menuBG'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

        title = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/funkin logo'));
        title.scale.set(0.5, 0.5);
        title.screenCenter(X);
        title.updateHitbox();
        title.setPosition(0, -title.height);
        add(title);

        FlxTween.tween(title, {y: 0}, 1.5, {ease: FlxEase.bounceOut});

        storyButton = createButton("Story Mode", 0);
        freeplayButton = createButton("Freeplay", 1);
        optionButton = createButton("Options", 2);

        super.create();

        animateButtons();
    }

    private function createButton(text:String, index:Int):FlxText
    {
        var button = new FlxText(0, FlxG.height + 50, FlxG.width, text);
        button.setFormat(null, 32, FlxColor.WHITE, CENTER);
        button.y = FlxG.height / 2 + index * 60;
        button.alpha = 0;
        add(button);
        return button;
    }

    private function animateButtons():Void
    {
        FlxTween.tween(storyButton, {alpha: 1}, 0.5, {startDelay: 0.5});
        FlxTween.tween(freeplayButton, {alpha: 1}, 0.5, {startDelay: 0.7});
        FlxTween.tween(optionButton, {alpha: 1}, 0.5, {startDelay: 0.9});
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.mouse.justPressed)
        {
            FlxG.sound.play(Paths.sound('confirmMenu'));
            if (storyButton.overlapsPoint(FlxG.mouse.getWorldPosition()))
            {
                transtoStory();
            }
            else if (freeplayButton.overlapsPoint(FlxG.mouse.getWorldPosition()))
            {
                transtoFreeplay();
            }
            else if (optionButton.overlapsPoint(FlxG.mouse.getWorldPosition()))
            {
                transtoOptions();
            }
        }
    }

    private function transtoStory():Void
    {
        FlxTween.tween(title, {y: -title.height, alpha: 0}, 0.5, {ease: FlxEase.backIn});
        FlxTween.tween(storyButton, {x: -FlxG.width}, 0.5, {ease: FlxEase.backIn});
        FlxTween.tween(freeplayButton, {x: FlxG.width}, 0.5, {ease: FlxEase.backIn});
        FlxTween.tween(optionButton, {x: FlxG.width}, 0.5, {ease: FlxEase.backIn});
        FlxTween.tween(optionButton, {y: FlxG.height}, 0.5, {ease: FlxEase.backIn, onComplete: function(_) {
            FlxG.switchState(new FreeplayState());
        }});
    }

    private function transtoFreeplay():Void
    {
        transitionTimer = new FlxTimer().start(0.016, updateTransition, 0);
    }

    private function updateTransition(timer:FlxTimer):Void
    {
        var moveAmount = transitionSpeed * timer.elapsedTime;
        
        title.x -= moveAmount;
        
        storyButton.x -= moveAmount;
        freeplayButton.x -= moveAmount;
        optionButton.x -= moveAmount;
        
        if (title.x <= -FlxG.width)
        {
            transitionTimer.cancel();
            FlxG.switchState(new FreeplayState());
        }
    }

    private function transtoOptions():Void
    {
        FlxTween.tween(title, {alpha: 0}, 0.5);
        FlxTween.tween(storyButton, {alpha: 0}, 0.5);
        FlxTween.tween(freeplayButton, {alpha: 0}, 0.5);
        FlxTween.tween(optionButton, {alpha: 0}, 0.5, {onComplete: function(_) {
            //FlxG.switchState(new OptionsState());
        }});
    }
}