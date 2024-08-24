package rain.states;

import flixel.FlxG;
import flixel.FlxState;

class OptionsState extends RainState
{
    private var options:Array<String> = ["General", "Controls", "Display"];
    private var optionTexts:Array<Alphabet> = [];
    private var currentSelection:Int = 0;

    override public function create():Void
    {
        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menus/bg/menuDesat'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = SaveManager.antialiasEnabled;
		add(bg);

        var title = new Alphabet(0, 20, "Options", true, false);
        title.screenCenter(X);
        add(title);

        for (i in 0...options.length)
        {
            var optionText = new Alphabet(0, 0, options[i], false, false);
            optionText.screenCenter(X);
            optionText.y = FlxG.height * 0.3 + (i * 80);
            optionTexts.push(optionText);
            add(optionText);
        }

        super.create();
        updateSelection();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.UP)
        {
            changeSelection(-1);
        }
        else if (FlxG.keys.justPressed.DOWN)
        {
            changeSelection(1);
        }
        else if (FlxG.keys.justPressed.ENTER)
        {
            selectOption();
        }
        else if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.switchState(new MainMenuState());
        }
    }

    private function changeSelection(change:Int):Void
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
        for (i in 0...optionTexts.length)
        {
            optionTexts[i].alpha = i == currentSelection ? 1 : 0.6;
            optionTexts[i].y = FlxG.height * 0.3 + (i * 80) + (i == currentSelection ? -15 : 0);
        }
    }

    private function selectOption():Void
    {
        switch (options[currentSelection].toLowerCase())
        {
            case "general":
               // RainState.switchState(new GeneralOptionsState());
            case "controls":
                RainState.switchState(new ControlsOptionsState());
            case "display":
               // RainState.switchState(new DisplayOptionsState());
        }
    }
}