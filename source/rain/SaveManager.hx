package rain;

import flixel.FlxG;

class SaveManager
{
    private static inline var SAVE_NAME:String = "rainengine";

    public static var antialiasEnabled(get, set):Bool;
    public static var flashingLightsEnabled(get, set):Bool;
    public static var brightness(get, set):Float;
    public static var downscroll(get, set):Bool;
    public static var middleScroll(get, set):Bool;
    public static var botPlay(get, set):Bool;
    public static var opponentNotes(get, set):Bool;
    public static var ghostTapping(get, set):Bool;

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

    private static function get_downscroll():Bool
    {
        return FlxG.save.data.downscroll == true;
    }

    private static function set_downscroll(value:Bool):Bool
    {
        FlxG.save.data.downscroll = value;
        FlxG.save.flush();
        return value;
    }

    private static function get_middleScroll():Bool
    {
        return FlxG.save.data.middleScroll == true;
    }

    private static function set_middleScroll(value:Bool):Bool
    {
        FlxG.save.data.middleScroll = value;
        FlxG.save.flush();
        return value;
    }

    private static function get_botPlay():Bool
    {
        return FlxG.save.data.botPlay == true;
    }

    private static function set_botPlay(value:Bool):Bool
    {
        FlxG.save.data.botPlay = value;
        FlxG.save.flush();
        return value;
    }

    private static function get_opponentNotes():Bool
    {
        return FlxG.save.data.opponentNotes != false;
    }

    private static function set_opponentNotes(value:Bool):Bool
    {
        FlxG.save.data.opponentNotes = value;
        FlxG.save.flush();
        return value;
    }

    private static function get_ghostTapping():Bool
    {
        return FlxG.save.data.ghostTapping == true;
    }

    private static function set_ghostTapping(value:Bool):Bool
    {
        FlxG.save.data.ghostTapping = value;
        FlxG.save.flush();
        return value;
    }

    public static function getOption(option:String):Bool
    {
        return switch (option.toLowerCase())
        {
            case "downscroll": downscroll;
            case "middle scroll": middleScroll;
            case "botplay": botPlay;
            case "opponent notes": opponentNotes;
            case "ghost tapping": ghostTapping;
            default: false;
        }
    }

    public static function setOption(option:String, value:Bool):Void
    {
        switch (option.toLowerCase())
        {
            case "downscroll": downscroll = value;
            case "middle scroll": middleScroll = value;
            case "botplay": botPlay = value;
            case "opponent notes": opponentNotes = value;
            case "ghost tapping": ghostTapping = value;
        }
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
            set_downscroll(false);
            set_middleScroll(false);
            set_botPlay(false);
            set_opponentNotes(true);
            set_ghostTapping(false);
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