package rain.states;

import rain.ui.HUD;
import flixel.text.FlxText;
import flixel.FlxState;
import rain.backend.Controls;

using StringTools;

import openfl.Lib;
import rain.substates.DifficultySelectSubstate;
import openfl.events.Event;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import flixel.group.FlxGroup.FlxTypedGroup;

class PlayState extends RainState
{
	// Characters
	public var p1:Character; // bf
	public var p2:Character; // dad
	public var p3:Character; // gf

	// Song-related stuff
	public static var SONG:SwagSong;

	public var curSong:String = "";

	private var vocals:FlxSound;
	private var inst:String;

	public var difficulty:String = "";

	public static var curStage:String = '';

	// Strum-related stuff
	public var strumLine:FlxSprite;
	public var strumLineNotes:FlxTypedGroup<FlxSprite>;
	public var playerStrum:FlxTypedGroup<StrumNote>;
	public var opponentStrum:FlxTypedGroup<StrumNote>;
	public var middleStrum:FlxTypedGroup<StrumNote>;
	public var laneOffset:Int = 100;
	public var keyCount:Int = 4;

	// Gameplay stuff
	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;
	public var paused:Bool = false;
	public var startedCountdown:Bool = false;
	public var speed:Float;
	public var GameMode:Modes;
	public var gfSpeed:Int = 1;
	private var health:Float = 1;
	public var songScore:Int = 0;
	public static var campaignScore:Int = 0;
	private var curSection:Int = 0;
	public var displayedScore:Float = 0;
	public static var isStoryMode:Bool = false;
	public static var storyDifficulty:Int = 1;
	private var combo:Int = 0;

	// Note Stuff
	public var spawnNotes:Array<Note> = [];
	public var notes:FlxTypedGroup<Note>;

	// Camera
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	// ETC
	public var instance:PlayState;

	public var windowFocused:Bool = true;

	public var inputActions:Array<String> = ["left", "down", "up", "right"];
	public var inputAnimations:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

	public var downscroll:Bool;
	public var middleScroll:Bool;
	public var botPlay:Bool;
	public var showOpponentNotes:Bool = true;
	public var ghostTapping:Bool;

	public var storyWeek:StoryWeekData;
	public var storyWeekSongIndex:Int;

	public var weekData:Array<WeekData> = [];

	public var stageGroup:FlxTypedGroup<FlxSprite>;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	var ui:HUD;

	override public function new()
	{
		super();
		Lib.current.stage.addEventListener(Event.DEACTIVATE, onWindowFocusOut);
		Lib.current.stage.addEventListener(Event.ACTIVATE, onWindowFocusIn);
	}

	override public function create()
	{
		loadWeekData();

		stageGroup = new FlxTypedGroup<FlxSprite>();
		add(stageGroup);

		instance = this;

		storyWeek = SongData.currentWeek;
		storyWeekSongIndex = SongData.weekSongIndex;
		GameMode = SongData.gameMode;
		difficulty = SongData.currentDifficulty;

		if (GameMode == Modes.FREEPLAY)
		{
			SONG = cast SongData.currentSong;
			var weekIndex:Int = getWeekIndexForSong(SONG.song);
			if (weekIndex != -1)
			{
				curStage = weekData[weekIndex].stage;
			}
		}
		else if (GameMode == Modes.STORYMODE)
		{
			if (storyWeek == null || storyWeekSongIndex < 0 || storyWeekSongIndex >= storyWeek.songs.length)
			{
				trace("Invalid week data or song index. Returning to Story Menu.");
				FlxG.switchState(new StoryMenuStateL());
				return;
			}
			loadSongFromWeek();
			curStage = storyWeek.stage;
		}

		if (SONG == null)
		{
			trace("SONG is null after loading. Returning to Main Menu.");
			FlxG.switchState(new MainMenuState());
			return;
		}

		trace("Song loaded successfully: " + SONG.song);

		curSong = SONG.song.toLowerCase(); // weird way of doing it but it works lol
		trace(curSong);
		inst = Paths.moosic("songs/" + curSong + "/Inst"); // agghfhg
		trace(inst);
		speed = SONG.speed;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		downscroll = SaveManager.downscroll;
		middleScroll = SaveManager.middleScroll;
		botPlay = SaveManager.botPlay;
		showOpponentNotes = SaveManager.opponentNotes;
		ghostTapping = SaveManager.ghostTapping;

		strumLine = new FlxSprite(0, downscroll ? FlxG.height - 150 : 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrum = new FlxTypedGroup<StrumNote>();
		add(playerStrum);

		opponentStrum = new FlxTypedGroup<StrumNote>();
		add(opponentStrum);

		middleStrum = new FlxTypedGroup<StrumNote>();
		add(middleStrum);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		ui = new HUD(this);
		add(ui);

		iconP1 = ui.iconP1;
		iconP2 = ui.iconP2;

		if (curStage != null && curStage != '')
		{
			StageManager.loadStage(curStage, stageGroup);
		}
		else
		{
			trace("No stage specified. Using default stage.");
			curStage = 'stage';
			StageManager.loadStage(curStage, stageGroup);
		}

		trace("Creating p3 (gf) with character: gf");
		p3 = new Character(false);
		p3.setCharacter(400, 130, 'gf');
		add(p3);

		trace("Creating p2 (opponent) with character: " + SONG.player2);
		p2 = new Character(false);
		p2.setCharacter(100, 100, SONG.player2);
		add(p2);

		trace("Creating p1 (player) with character: " + SONG.player1);
		p1 = new Character(true);
		p1.setCharacter(770, 450, SONG.player1);
		add(p1);

		Controls.init(); // controls init

		strumLineNotes.cameras = [camHUD];
		playerStrum.cameras = [camHUD];
		opponentStrum.cameras = [camHUD];
		notes.cameras = [camHUD];
		ui.cameras = [camHUD];

		super.create();

		updateOpponentVisibility();

		startCountdown();
		generateNotes(SONG.song);

		startingSong = true;
	}

	private function updateOpponentVisibility():Void
	{
		opponentStrum.visible = showOpponentNotes;
		notes.forEach(function(note:Note)
		{
			if (!note.mustPress)
			{
				note.visible = showOpponentNotes;
			}
		});
	}

	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		if (!paused && windowFocused)
		{
			// pause shiz
			if (FlxG.keys.justPressed.ENTER && canPause)
			{
				persistentUpdate = false;
				paused = true;
				FlxG.sound.music.pause();
				vocals.pause();
				var pauseSubState = new PauseSubstate();
				openSubState(pauseSubState);
				pauseSubState.camera = camHUD;
			}

			if (startingSong && startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
				{
					vocals = new FlxSound().loadEmbedded("assets/songs/" + curSong + "/Voices" + RainUtil.soundExt);
					FlxG.sound.list.add(vocals);
					startSong();
					vocals.play();
				}
			}
			else
			{
				Conductor.songPosition += FlxG.elapsed * 1000;

				if (!paused)
				{
					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					if (Conductor.lastSongPos != Conductor.songPosition)
					{
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
					}
				}
			}

			if (!botPlay)
			{
				inputShit();
			}
			else
			{
				botPlayUpdate();
			}

			super.update(elapsed);

			updateOpponentVisibility();

			if (spawnNotes[0] != null)
			{
				while (spawnNotes.length > 0 && spawnNotes[0].strum - Conductor.songPosition < (1500 * 1))
				{
					var dunceNote:Note = spawnNotes[0];
					notes.add(dunceNote);

					var index:Int = spawnNotes.indexOf(dunceNote);
					spawnNotes.splice(index, 1);
				}
			}

			if (health > 2)
				health = 2;

			for (note in notes)
			{
				var strum:StrumNote;
				if (note.mustPress)
				{
					strum = playerStrum.members[note.direction % keyCount];
				}
				else
				{
					strum = opponentStrum.members[note.direction % keyCount];
				}

				if (downscroll)
				{
					note.y = strum.y + ((Conductor.songPosition - note.strum) * speed / 2);
				}
				else
				{
					note.y = strum.y - ((Conductor.songPosition - note.strum) * speed / 2);
				}

				if (!note.mustPress && Conductor.songPosition >= note.strum && note != null)
				{
					opponentNoteHit(note);
					notes.remove(note);
					note.kill();
					note.destroy();
				}

				if (Conductor.songPosition > note.strum + (300 * 1) && note != null)
				{
					notes.remove(note);
					note.kill();
					note.destroy();
					noteMiss(note.direction);
					trace("Normal Note Miss (Not cuz of ghost tapping)");
				}
			}

			FlxG.watch.addQuick("beatShit", curBeat);
			FlxG.watch.addQuick("stepShit", curStep);
		}
	}

	function startCountdown():Void
	{
		genArrows(0); // Dad's strums
		genArrows(1); // BF's strums

		startedCountdown = true;
		Conductor.songPosition = -Conductor.crochet * 5;

		var swagCounter:Int = 0;
		var startTimer:FlxTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			p1.dance(); // BF dances
			p2.dance(); // Dad dances
			p3.dance(); // GF dances

			swagCounter += 1;
		}, 5);
	}

	function generateNotes(dataPath:String):Void
	{
		for (section in SONG.notes)
		{
			var mustHitSection:Bool = section.mustHitSection;

			for (note in section.sectionNotes)
			{
				var strumTime:Float = note[0];
				var noteData:Int = Std.int(note[1] % keyCount);
				var sustainLength:Float = note[2];

				var isPlayerNote:Bool = mustHitSection;
				if (note[1] > 3)
					isPlayerNote = !mustHitSection;

				var strum:StrumNote = isPlayerNote ? playerStrum.members[noteData] : opponentStrum.members[noteData];

				var swagNote:Note = new Note(strum.x, strum.y, noteData, strumTime, false, !isPlayerNote, keyCount);
				swagNote.scrollFactor.set();
				swagNote.mustPress = isPlayerNote;

				if (!isPlayerNote)
				{
					swagNote.visible = showOpponentNotes;
				}

				var oldNote:Note = spawnNotes.length > 0 ? spawnNotes[spawnNotes.length - 1] : null;
				swagNote.lastNote = oldNote;

				swagNote.playAnim('note');

				spawnNotes.push(swagNote);

				if (sustainLength > 0)
				{
					var sustainNote:Note = new Note(strum.x, strum.y, noteData, strumTime + sustainLength, true, !isPlayerNote, keyCount);
					sustainNote.scrollFactor.set();
					sustainNote.lastNote = swagNote;
					sustainNote.mustPress = isPlayerNote;
					sustainNote.visible = isPlayerNote || showOpponentNotes;
					spawnNotes.push(sustainNote);
				}
			}
		}

		spawnNotes.sort(sortByShit);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strum, Obj2.strum);
	}

	public function genArrows(player:Int):Void
	{
		for (i in 0...keyCount)
		{
			var xPos:Float;

			if (middleScroll)
			{
				switch (player)
				{
					case 0: // Dad's strums (split)
						if (i < 2)
						{
							xPos = (i * laneOffset) + (FlxG.width / 6) - (laneOffset * 2 / 2);
						}
						else
						{
							xPos = ((i - 2) * laneOffset) + (5 * FlxG.width / 6) - (laneOffset * 2 / 2);
						}
					case 1: // BF's strums (middle)
						xPos = (i * laneOffset) + (FlxG.width / 2) - (laneOffset * keyCount / 2);
					default:
						xPos = 0;
				}
			}
			else
			{
				switch (player)
				{
					case 0: // Dad's strums (left)
						xPos = (i * laneOffset) + (FlxG.width / 4) - (laneOffset * keyCount / 2);
					case 1: // BF's strums (right)
						xPos = (i * laneOffset) + (3 * FlxG.width / 4) - (laneOffset * keyCount / 2);
					default:
						xPos = 0;
				}
			}

			var yPos:Float = downscroll ? FlxG.height - 150 : strumLine.y;
			var daStrum:StrumNote = new StrumNote(xPos, yPos, i);
			daStrum.ID = i;
			daStrum.alpha = 0;

			var tweenY:Float = downscroll ? daStrum.y - 10 : daStrum.y + 10;
			FlxTween.tween(daStrum, {y: tweenY, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			switch (player)
			{
				case 0:
					opponentStrum.add(daStrum);
				case 1:
					playerStrum.add(daStrum);
				default:
					opponentStrum.add(daStrum);
			}
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		trace("Song Started!");
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(inst);
		FlxG.sound.music.onComplete = endSong;
	}

	function endSong():Void
	{
		trace("Song ended!");
		canPause = false;
		FlxG.sound.music.volume = 0;
		if (vocals != null)
			vocals.volume = 0;

		if (GameMode == Modes.STORYMODE)
		{
			storyWeekSongIndex++;
			if (storyWeek != null && storyWeekSongIndex < storyWeek.songs.length)
			{
				SongData.weekSongIndex = storyWeekSongIndex;
				loadNextSong();
			}
			else
			{
				RainState.switchState(new StoryMenuStateL());
			}
		}
		else
		{
			RainState.switchState(new FreeplayStateL());
		}
	}

	function loadNextSong():Void
	{
		SongData.currentSong = null;
		SongData.currentDifficulty = difficulty;
		SongData.gameMode = GameMode;
		SongData.currentWeek = storyWeek;
		SongData.weekSongIndex = storyWeekSongIndex;
		RainState.switchState(new PlayState());
	}

	function loadSongFromWeek():Void
	{
		trace("loadSongFromWeek() called");
		var songName = storyWeek.songs[storyWeekSongIndex];
		trace("Attempting to load song: " + songName);
		var formattedSongName = StringTools.replace(songName.toLowerCase(), " ", "-");
		var jsonSuffix = difficulty.toLowerCase() == "normal" ? "" : "-" + difficulty.toLowerCase();

		try
		{
			SONG = Song.loadFromJson(formattedSongName + jsonSuffix, formattedSongName);
			trace("Song loaded successfully");
		}
		catch (e:Dynamic)
		{
			trace('Failed to load song data: ${e}');
			FlxG.switchState(new StoryMenuStateL());
			return;
		}

		curSong = SONG.song.toLowerCase();
		inst = Paths.moosic("songs/" + curSong + "/Inst");
		speed = SONG.speed;
	}

	private function loadWeekData():Void
	{
		var weekPath = "assets/data/weeks/";
		var modWeekPath = "mods/";
		var files = [];

		// Load base game weeks
		if (FileSystem.exists(weekPath))
		{
			files = files.concat(FileSystem.readDirectory(weekPath).map(file -> weekPath + file));
		}

		// Load mod weeks
		if (FileSystem.exists(modWeekPath))
		{
			for (modDir in FileSystem.readDirectory(modWeekPath))
			{
				if (!FlxG.save.data.disabledMods.contains(modDir))
				{
					var modWeekDir = modWeekPath + modDir + "/data/weeks/";
					if (FileSystem.exists(modWeekDir))
					{
						files = files.concat(FileSystem.readDirectory(modWeekDir).map(file -> modWeekDir + file));
					}
				}
			}
		}

		for (file in files)
		{
			if (file.endsWith(".json"))
			{
				var content = File.getContent(file);
				var data:WeekData = Json.parse(content);
				data.fileName = file.split("/").pop().substr(0, -5).toLowerCase();
				weekData.push(data);
			}
		}

		// Sort weekData based on a potential 'order' field or fileName
		weekData.sort((a, b) ->
		{
			if (Reflect.hasField(a, "order") && Reflect.hasField(b, "order"))
			{
				return Std.int(Reflect.field(a, "order")) - Std.int(Reflect.field(b, "order"));
			}
			return Reflect.compare(a.fileName, b.fileName);
		});
	}

	function inputShit():Void
	{
		for (i in 0...inputActions.length)
		{
			var action = inputActions[i];
			var animation = inputAnimations[i];
			var strum = playerStrum.members[i];

			if (Controls.getPressEvent(action, 'justPressed'))
			{
				strum.playAnim("press", true);
				var hitNote = checkNoteHit(i, animation);
				if (!hitNote && !ghostTapping)
				{
					noteMiss(i);
				}
			}
			else if (Controls.getPressEvent(action, 'justReleased'))
			{
				strum.playAnim("static");
			}
		}
	}

	function botPlayUpdate():Void
	{
		for (note in notes)
		{
			if (note.mustPress && Conductor.songPosition >= note.strum)
			{
				var strum = playerStrum.members[note.direction % keyCount];
				strum.playAnim("confirm", true);
				checkNoteHit(note.direction, inputAnimations[note.direction]);
				new FlxTimer().start(0.15, function(tmr:FlxTimer)
				{
					strum.playAnim("static");
				});
			}
		}
	}

	function checkNoteHit(direction:Int, animation:String):Bool
	{
		var hitNote = getNearestHittableNote(direction);

		if (hitNote != null)
		{
			hitNote.wasGoodHit = true;
			playerStrum.members[hitNote.direction].playAnim("confirm", true);

			if (hitNote.direction >= 0)
				health += 0.023;
			else
				health += 0.004;
			combo += 1;
			popUpScore(hitNote.strum);
			p1.playAnim('sing$animation', true);
			p1.animation.finishCallback = function(name:String)
			{
				if (name.startsWith("sing"))
					p1.dance();
			};

			notes.remove(hitNote);
			hitNote.kill();
			hitNote.destroy();
			return true;
		}
		return false;
	}

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			score = 200;
		}

		songScore += score;

		curSection += 1;
	}

	function getNearestHittableNote(direction:Int):Note
	{
		var hitNote:Note = null;
		var closestTime:Float = Math.POSITIVE_INFINITY;

		for (note in notes)
		{
			if (note.mustPress && note.direction == direction && !note.wasGoodHit)
			{
				var timeDiff:Float = Math.abs(Conductor.songPosition - note.strum);
				if (timeDiff < Conductor.safeZoneOffset && timeDiff < closestTime)
				{
					hitNote = note;
					closestTime = timeDiff;
				}
			}
		}

		return hitNote;
	}

	function opponentNoteHit(note:Note):Void
	{
		var animations:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

		if (note != null)
		{
			p2.playAnim('sing${animations[note.direction % 4]}', true);
			p2.animation.finishCallback = function(name:String)
			{
				if (name.startsWith("sing"))
					p2.dance();
			};

			if (showOpponentNotes)
			{
				var strum = opponentStrum.members[note.direction % 4];
				strum.playAnim("confirm", true);
				new FlxTimer().start(0.15, function(tmr:FlxTimer)
				{
					strum.playAnim("static");
				});
			}
		}
	}

	function noteMiss(direction:Int):Void
	{
		health -= 0.04;
		songScore -= 10;
		combo = 0;
		// spamming this lags the game for some unknown reason???
		// trace("Missed note in direction: " + direction);
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}
			paused = false;
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private function onWindowFocusOut(_):Void
	{
		if (!paused && persistentUpdate == false)
		{
			windowFocused = false;
			persistentUpdate = false;
			paused = true;
		}
	}

	private function onWindowFocusIn(_):Void
	{
		windowFocused = true;
		persistentUpdate = true;
		paused = false;
	}

	override public function destroy():Void
	{
		Lib.current.stage.removeEventListener(Event.DEACTIVATE, onWindowFocusOut);
		Lib.current.stage.removeEventListener(Event.ACTIVATE, onWindowFocusIn);
		super.destroy();
		Controls.destroy();
	}

	private function getWeekIndexForSong(song:String):Int
	{
		for (i in 0...weekData.length)
		{
			if (weekData[i].songs.contains(song))
			{
				return i;
			}
		}
		return -1;
	}

	override function beatHit()
	{
		super.beatHit();
		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				p2.dance();
		}

		ui.iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		ui.iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		ui.iconP1.updateHitbox();
		ui.iconP2.updateHitbox();

		
		if (!p1.animation.curAnim.name.startsWith("sing"))
		{
			p1.playAnim('idle');
		}
	}
}

typedef WeekData =
{
	var weekName:String;
	var songs:Array<String>;
	var difficulties:Array<String>;
	var icon:String;
	var opponent:String;
	var stage:String;
	var ?fileName:String;
	var ?order:Int;
}
