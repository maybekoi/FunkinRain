package rain.states.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import rain.backend.Controls;
import rain.SaveManager;

class ControlsOptionsState extends RainState
{
    private var options:Array<String> = [];
    private var optionTexts:Array<FlxText> = [];
    private var keyTexts:Array<FlxText> = [];
    private var currentSelection:Int = 0;
    private var isWaitingForKey:Bool = false;
    private var waitingText:FlxText;
    private var debugText:FlxText;

    override public function create():Void
    {
        super.create();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(bg);

        var title = new FlxText(0, 20, FlxG.width, "Controls Options");
        title.setFormat(null, 32, FlxColor.WHITE, CENTER);
        add(title);

        options = [for (action in Controls.actionSort.keys()) action];
        options.sort((a, b) -> Controls.actionSort[a] - Controls.actionSort[b]);
        trace('Debug: Available options: ${options}');

        for (i in 0...options.length)
        {
            var optionText = new FlxText(20, 100 + i * 40, 200, options[i]);
            optionText.setFormat(null, 16, FlxColor.WHITE, LEFT);
            optionTexts.push(optionText);
            add(optionText);

            var keyText = new FlxText(FlxG.width - 220, 100 + i * 40, 200, "");
            keyText.setFormat(null, 16, FlxColor.WHITE, RIGHT);
            keyTexts.push(keyText);
            add(keyText);
        }

        waitingText = new FlxText(0, FlxG.height - 80, FlxG.width, "Press any key...");
        waitingText.setFormat(null, 20, FlxColor.YELLOW, CENTER);
        waitingText.visible = false;
        add(waitingText);

        debugText = new FlxText(10, FlxG.height - 40, FlxG.width - 20, "Debug: ");
        debugText.setFormat(null, 12, FlxColor.LIME, LEFT);
        add(debugText);

        updateKeyTexts();
        updateSelection();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!isWaitingForKey)
        {
            if (FlxG.keys.justPressed.UP)
            {
                changeSelection(-1);
            }
            else if (FlxG.keys.justPressed.DOWN)
            {
                changeSelection(1);
            }
            else if (FlxG.keys.justReleased.ENTER)
            {
                startKeyBinding();
            }
            else if (FlxG.keys.justPressed.ESCAPE)
            {
                FlxG.switchState(new OptionsState());
            }
        }
        else
        {
            var pressedKeys = FlxG.keys.getIsDown();
            if (pressedKeys.length > 0)
            {
                var newKey = pressedKeys[0].ID;
                trace('Debug: Attempting to set key for ${options[currentSelection]} to ${newKey}');
                Controls.setActionKey(options[currentSelection], 0, newKey);
                updateKeyTexts();
                isWaitingForKey = false;
                waitingText.visible = false;
                Controls.saveControls();
                debugText.text = 'Debug: Key set - ${options[currentSelection]} : ${newKey}';
            }
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
            optionTexts[i].color = i == currentSelection ? FlxColor.YELLOW : FlxColor.WHITE;
            keyTexts[i].color = i == currentSelection ? FlxColor.YELLOW : FlxColor.WHITE;
        }
    }

    private function startKeyBinding():Void
    {
        isWaitingForKey = true;
        waitingText.visible = true;
        debugText.text = 'Debug: Waiting for key input...';
    }

    private function updateKeyTexts():Void
    {
        for (i in 0...options.length)
        {
            var keyString = Controls.getKeyString(options[i], 0);
            keyTexts[i].text = keyString;
            debugText.text = 'Debug: Updated ${options[i]} to ${keyString}';
        }
    }
}