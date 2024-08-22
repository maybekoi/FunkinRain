package rain.backend;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import lime.app.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

using StringTools;

enum KeyState
{
	PRESSED;
	RELEASED;
}

typedef KeyCall = (Int, KeyState) -> Void;
typedef BindCall = (String, Int, KeyState) -> Void;
typedef Key = Null<Int>;

/**
 * the Controls Class manages the main inputs for the game
 * it can be used by every other class for any type of event
**/
class Controls
{
	//
	public static var keyPressed:Event<KeyCall> = new Event<KeyCall>();
	public static var keyReleased:Event<KeyCall> = new Event<KeyCall>();
	public static var keyTriggered:Event<KeyCall> = new Event<KeyCall>();

	public static var keyEventPress:Event<BindCall> = new Event<BindCall>();
	public static var keyEventRelease:Event<BindCall> = new Event<BindCall>();
	public static var keyEventTrigger:Event<BindCall> = new Event<BindCall>();

	public static var defaultActions:Map<String, Array<Key>> = [
		"left" => [Keyboard.LEFT, Keyboard.A],
		"down" => [Keyboard.DOWN, Keyboard.S],
		"up" => [Keyboard.UP, Keyboard.W],
		"right" => [Keyboard.RIGHT, Keyboard.D],
		"accept" => [Keyboard.ENTER, Keyboard.SPACE],
		"pause" => [Keyboard.ENTER, Keyboard.P],
		"back" => [Keyboard.ESCAPE, Keyboard.BACKSPACE],
	];

	public static var actionSort:Map<String, Int> = [
		"left" => 0,
		"down" => 1,
		"up" => 2,
		"right" => 3,
		"accept" => 5,
		"pause" => 6,
		"back" => 7,
	];

	public static var actions:Map<String, Array<Key>> = [];

	public static var keysHeld:Array<Key> = [];

	public static function init()
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		actions = defaultActions;
	}

	public static function destroy()
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
	}

	public static function onKeyPress(event:KeyboardEvent)
	{

		if (FlxG.keys.enabled && (FlxG.state.active || FlxG.state.persistentUpdate))
		{
			if (!keysHeld.contains(event.keyCode))
			{
				keysHeld.push(event.keyCode);
				keyPressed.dispatch(event.keyCode, PRESSED);
				keyTriggered.dispatch(event.keyCode, PRESSED);

				for (key in catchKeys(event.keyCode))
				{
					keyEventPress.dispatch(key, event.keyCode, PRESSED);
					keyEventTrigger.dispatch(key, event.keyCode, PRESSED);
				}
			}
		}
	}

	public static function onKeyRelease(event:KeyboardEvent)
	{

		if (FlxG.keys.enabled && (FlxG.state.active || FlxG.state.persistentUpdate))
		{
			if (keysHeld.contains(event.keyCode))
			{
				keysHeld.remove(event.keyCode);
				keyReleased.dispatch(event.keyCode, RELEASED);
				keyTriggered.dispatch(event.keyCode, RELEASED);

				for (key in catchKeys(event.keyCode))
				{
					keyEventRelease.dispatch(key, event.keyCode, RELEASED);
					keyEventTrigger.dispatch(key, event.keyCode, RELEASED);
				}
			}
		}
	}

	inline private static function catchKeys(key:Key):Array<String>
	{

		if (key == null)
			return [];

		var gottenKeys:Array<String> = [];
		for (action => keys in actions)
		{
			if (keys.contains(key))
				gottenKeys.push(action);
		}

		return gottenKeys;
	}

	inline public static function getKeyState(key:Key):KeyState
	{

		return keysHeld.contains(key) ? PRESSED : RELEASED;
	}

	public static function getKeyString(action:String, id:Int)
	{
		var keyString = "";

		if (Controls.actions.exists(action))
			keyString = returnStringKey(Controls.actions.get(action)[id]);
		return keyString;
	}

	public static function returnStringKey(arrayThingy:Dynamic):String
	{
		var keyString:String = 'none';
		if (arrayThingy != null)
		{
			var keyDisplay:FlxKey = arrayThingy;
			keyString = keyDisplay.toString();
		}

		keyString = keyString.replace(" ", "");

		return keyString;
	}

	public static function getPressEvent(action:String, type:String = 'justPressed'):Bool
	{
		var lastEvent:String = 'justReleased';

		if (actions.exists(action))
		{
			var keys:Array<Key> = actions.get(action);

			lastEvent = type;

			if (Reflect.field(FlxG.keys, 'any' + type.charAt(0).toUpperCase() + type.substr(1))(keys))
				return true;
		}

		return false;
	}

	inline public static function addActionKey(action:String, keys:Array<Key>)
	{
		if (actions.exists(action))
			actions.set(action, keys);
	}

	inline public static function setActionKey(action:String, id:Int, key:Key)
	{
		if (actions.exists(action))
			actions.get(action)[id] = key;
	}
}
