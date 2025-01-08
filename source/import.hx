// haxe and flixel imports
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxCamera;
import flixel.input.FlxInput.FlxInputState;
import flixel.util.FlxTimer;
import flixel.util.FlxSort;
import flixel.math.FlxMath;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.FlxTextExt;
import flixel.math.FlxPoint;
// basic backend stuff :D
import backend.Paths;
import backend.RainUtil;
import backend.Cache;
import backend.transition.*;
import backend.Utils;
// rain backend
import rain.backend.modding.*;
import rain.backend.Controls;
import rain.SaveManager;
// Rain Engine Game Stuff
import rain.game.Conductor;
import rain.game.Section;
import rain.game.Song;
import rain.game.Character;
import rain.game.Note;
import rain.RainState;
import rain.RainSubstate;
import rain.game.SongData;
import rain.game.StageManager;
import rain.game.CoolUtil;
import rain.game.Highscore;
// Rain Engine UI Stuff
import rain.ui.Alphabet;
import rain.ui.StrumNote;
import rain.ui.HealthIcon;
import rain.ui.HUD;
// Rain Engine States
import rain.states.AlphaState;
import rain.states.PlayState;
import rain.states.legacy.FreeplayStateL;
import rain.states.InitState;
import rain.states.OptionsState;
import rain.states.options.ControlsOptionsState;
import rain.states.options.DisplayOptionsState;
import rain.states.options.GeneralOptionsState;
import rain.states.legacy.StoryMenuStateL;
import rain.states.legacy.MainMenuStateL;
import rain.states.MainMenuState;
import rain.states.FreeplayState;
// Rain Engine Substates
import rain.substates.PauseSubstate;
import rain.substates.DifficultySelectSubstate;
import rain.substates.GameOverSS;
// Rain Engine Freeplay Stuff
import rain.freeplay.ScrollingText;
import rain.freeplay.ScrollingText.ScrollingTextInfo;
import rain.freeplay.DigitDisplay;
import rain.freeplay.Capsule;
