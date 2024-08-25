package rain.ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import rain.SaveManager;

class Checkbox extends FlxSprite
{
    public var optionName:String;

    public function new(x:Float, y:Float, option:String)
    {
        super(x, y);

        optionName = option;

        frames = FlxAtlasFrames.fromSparrow('assets/images/menus/checkboxThingie.png', 'assets/images/menus/checkboxThingie.xml');

        animation.addByPrefix('static', 'Check Box Selected Static', 24, false);
        animation.addByPrefix('selecting', 'Check Box selecting animation', 24, false);
        animation.addByPrefix('unselected', 'Check Box unselected', 24, false);

        antialiasing = SaveManager.antialiasEnabled;

        updateHitbox();
        updateCheckboxState();
    }

    public function toggle():Void
    {
        var newValue = !SaveManager.getOption(optionName);
        SaveManager.setOption(optionName, newValue);
        updateCheckboxState();
    }

    public function updateCheckboxState():Void
    {
        var isChecked = SaveManager.getOption(optionName);
        if (isChecked)
        {
            animation.play('static');
        }
        else
        {
            animation.play('unselected');
        }
    }
}