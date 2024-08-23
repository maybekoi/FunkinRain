package rain.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;

class PauseSubstate extends RainSubstate
{
    private var options:Array<String> = ['Resume', 'Restart', 'Quit'];
    private var optionTexts:FlxTypedGroup<FlxText>;
    private var currentSelection:Int = 0;
    private var pauseOverlay:FlxSprite;
    private var titleText:FlxText;
    private var selector:FlxSprite;

    public function new()
    {
        super();

        pauseOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        pauseOverlay.alpha = 0;
        add(pauseOverlay);
        FlxTween.tween(pauseOverlay, {alpha: 0.5}, 0.2);

        titleText = new FlxText(0, 50, FlxG.width, "PAUSED");
        titleText.setFormat("assets/fonts/vcr.ttf", 64, FlxColor.WHITE, CENTER);
        titleText.alpha = 0;
        titleText.y -= 20;
        add(titleText);
        FlxTween.tween(titleText, {alpha: 1, y: titleText.y + 20}, 0.3, {startDelay: 0.1});

        optionTexts = new FlxTypedGroup<FlxText>();
        add(optionTexts);

        for (i in 0...options.length)
        {
            var optionText = new FlxText(0, 200 + (i * 60), FlxG.width, options[i]);
            optionText.setFormat(null, 32, FlxColor.WHITE, CENTER);
            optionText.ID = i;
            optionTexts.add(optionText);
        }

        selector = new FlxSprite().makeGraphic(10, 30, FlxColor.WHITE);
        add(selector);

        updateSelection();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
        {
            changeSelection(-1);
        }
        if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
        {
            changeSelection(1);
        }

        if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
        {
            selectOption();
        }
    }

    private function changeSelection(change:Int = 0):Void
    {
        currentSelection += change;

        if (currentSelection < 0)
            currentSelection = options.length - 1;
        if (currentSelection >= options.length)
            currentSelection = 0;

        updateSelection();
    }

    private function updateSelection():Void
    {
        var i:Int = 0;
        for (text in optionTexts.members)
        {
            text.color = i == currentSelection ? FlxColor.YELLOW : FlxColor.WHITE;
            if (i == currentSelection)
            {
                selector.x = text.x - 20;
                selector.y = text.y + (text.height / 2) - (selector.height / 2);
            }
            i++;
        }
    }

    private function selectOption():Void
    {
        switch (options[currentSelection].toLowerCase())
        {
            case "resume":
                close();
            case "restart":
                FlxG.resetState();
            case "quit":
                FlxG.switchState(new FreeplayState());
        }
    }
}