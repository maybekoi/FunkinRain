package rain;

import flixel.FlxG;

class SaveManager
{
    private static inline var SAVE_NAME:String = "rainengine";

    public static var antialiasEnabled(get, set):Bool;
    public static var flashingLightsEnabled(get, set):Bool;
    public static var brightness(get, set):Float;

    public static function initializeSave():Void
    {
        FlxG.save.bind(SAVE_NAME);
    }

    public static function hasSaveData():Bool
    {
        return FlxG.save.data.initialized == true;
    }

    private static function get_antialiasEnabled():Bool
    {
        return FlxG.save.data.antialiasEnabled == true;
    }

    private static function set_antialiasEnabled(value:Bool):Bool
    {
        FlxG.save.data.antialiasEnabled = value;
        FlxG.save.flush();
        return value;
    }

    private static function get_flashingLightsEnabled():Bool
    {
        return FlxG.save.data.flashingLightsEnabled == true;
    }

    private static function set_flashingLightsEnabled(value:Bool):Bool
    {
        FlxG.save.data.flashingLightsEnabled = value;
        FlxG.save.flush();
        return value;
    }

    private static function get_brightness():Float
    {
        return FlxG.save.data.brightness != null ? FlxG.save.data.brightness : 1.0;
    }

    private static function set_brightness(value:Float):Float
    {
        FlxG.save.data.brightness = value;
        FlxG.save.flush();
        return value;
    }

    public static function setControls(controls:Map<String, Array<Int>>):Void
    {
        trace('Debug: Saving controls to FlxG.save: ${controls}');
        FlxG.save.data.controls = controls;
        FlxG.save.flush();
    }

    public static function getControls():Map<String, Array<Int>>
    {
        var loadedControls:Map<String, Array<Int>> = FlxG.save.data.controls;
        trace('Debug: Loaded controls from FlxG.save: ${loadedControls}');
        return loadedControls;
    }

    public static function initializeSaveData():Void
    {
        if (!hasSaveData())
        {
            set_antialiasEnabled(true);
            set_flashingLightsEnabled(true);
            set_brightness(1.0);
            FlxG.save.data.initialized = true;
            FlxG.save.data.controls = null;
            FlxG.save.flush();
        }
        
        if (FlxG.save.data.controls == null)
        {
            var defaultControlsMap = new Map<String, Array<Int>>();
            for (action => keys in Controls.defaultActions)
            {
                defaultControlsMap[action] = keys.map(key -> key == null ? -1 : key);
            }
            FlxG.save.data.controls = defaultControlsMap;
            FlxG.save.flush();
        }
    }
}