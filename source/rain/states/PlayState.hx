package rain.states;

import rain.ui.DebugUI;
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
	public var laneOffset:Int = 110;

	private var strumYPos:Float = 30;
	private var strumXOffset:Float = -50;

	public var keyCount:Int = 4;

	// Gameplay stuff
	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;
	public var paused:Bool = false;
	public var startedCountdown:Bool = false;
	public var speed:Float;
	public var GameMode:Modes;
	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var songScore:Int = 0;

	public static var campaignScore:Int = 0;

	private var curSection:Int = 0;

	public var displayedScore:Float = 0;

	public static var isStoryMode:Bool = false;
	public static var storyDifficulty:Int = 1;

	public var combo:Int = 0;

	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	public var misses:Int = 0;
	public var endingSong:Bool = false;

	var boyfriendIdled:Bool = false;

	// Camera
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;

	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	private var isCameraOnForcedPos:Bool = false;
	private var cameraTwn:FlxTween;

	// Note Stuff
	public var spawnNotes:Array<Note> = [];
	public var notes:FlxTypedGroup<Note>;

	// Camera
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	var defaultCamZoom:Float = 1.05;

	public var cameraSpeed:Float = 1;
	public var camZooming:Bool = false;

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

	// rank stuff technically.
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	public var accuracy:Float = 0.00;

	// UI
	var ui:HUD;
	var debugUI:DebugUI;

	public var BF_X:Float = 770;
	public var BF_Y:Float = 450;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var up:Bool = false;
	public var down:Bool = false;
	public var left:Bool = false;
	public var right:Bool = false;

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
				FlxG.switchState(new StoryMenuState());
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

		FlxCamera._defaultCameras = [camGame];

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

		notes = new FlxTypedGroup<Note>();
		add(notes);

		ui = new HUD(this);
		add(ui);

		debugUI = new DebugUI(this);
		debugUI.visible = false;
		add(debugUI);

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
		p3 = new Character(GF_X, GF_Y, SONG.gfVersion, false);
		p3.scrollFactor.set(0.95, 0.95);
		add(p3);
		startCharacterPos(p3, true);

		trace("Creating p2 (opponent) with character: " + SONG.player2);
		p2 = new Character(DAD_X, DAD_Y, SONG.player2, false);
		add(p2);
		startCharacterPos(p2);

		var camPos:FlxPoint = new FlxPoint(p2.getGraphicMidpoint().x, p2.getGraphicMidpoint().y);

		if (SONG.player2.startsWith('gf'))
		{
			p2.setPosition(GF_X, GF_Y);
			p3.visible = false;
		}

		trace("Creating p1 (player) with character: " + SONG.player1);
		p1 = new Character(BF_X, BF_Y, SONG.player1, true);
		add(p1);
		startCharacterPos(p1);

		Controls.init(); // controls init

		strumLineNotes.cameras = [camHUD];
		playerStrum.cameras = [camHUD];
		opponentStrum.cameras = [camHUD];
		notes.cameras = [camHUD];
		ui.cameras = [camHUD];
		debugUI.cameras = [camHUD];

		super.create();

		updateOpponentVisibility();

		startCountdown();
		generateNotes(SONG.song);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		startingSong = true;
	}

	function moveCameraSection(?id:Int = 0):Void
	{
		if (SONG.notes[id] == null)
			return;

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
		}
		else
		{
			moveCamera(false);
		}
	}

	function tweenCamIn()
	{
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
		{
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FlxEase.elasticInOut,
				onComplete: function(twn:FlxTween)
				{
					cameraTwn = null;
				}
			});
		}
	}

	public function moveCamera(isDad:Bool)
	{
		if (isDad)
		{
			camFollow.set(p2.getMidpoint().x + 150, p2.getMidpoint().y - 100);
			camFollow.x += p2.positionArray[0];
			camFollow.y += p2.positionArray[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(p1.getMidpoint().x - 100, p1.getMidpoint().y - 100);
			camFollow.x -= p1.positionArray[0];
			camFollow.y += p1.positionArray[1];
		}
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
			if (FlxG.keys.justPressed.ENTER && canPause && !paused)
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
			else if (!startingSong)
			{
				var curTime:Float = FlxG.sound.music.time;
				if (curTime < 0)
					curTime = 0;

				Conductor.songPosition = curTime;

				var vocalsTime:Float = vocals != null ? vocals.time : 0;
				if (Math.abs(curTime - vocalsTime) > 20)
				{
					resyncVocals();
				}

				if (!paused)
				{
					songTime = curTime;
					Conductor.lastSongPos = Conductor.songPosition;
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

			if (FlxG.keys.justPressed.TAB)
			{
				debugUI.visible = !debugUI.visible;
				// ui.visible = !ui.visible;
			}

			var boyfriendIdleTime:Float = 0.0;
			var inCutscene:Bool = false;
			if (!inCutscene)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
				camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
				if (!startingSong && !endingSong && p1.animation.curAnim.name.startsWith('idle'))
				{
					boyfriendIdleTime += elapsed;
					if (boyfriendIdleTime >= 0.15)
					{ // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
						boyfriendIdled = true;
					}
				}
				else
				{
					boyfriendIdleTime = 0;
				}
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
					noteMiss(note.direction, inputAnimations[note.direction]);
					trace("Normal Note Miss (Not cuz of ghost tapping)");
				}
			}

			if (health <= 0)
			{
				callGameOver();
			}

			FlxG.watch.addQuick("beatShit", curBeat);
			FlxG.watch.addQuick("stepShit", curStep);
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		if (p1.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (p1.animation.curAnim.name.startsWith('sing') && !p1.animation.curAnim.name.endsWith('miss'))
			{
				p1.playAnim('idle');
			}
		}
	}

	function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function callGameOver()
	{
		persistentUpdate = false;
		persistentDraw = false;
		paused = true;

		vocals.stop();
		FlxG.sound.music.stop();

		var gameOverSubstate = new GameOverSS(p1.x, p1.y);
		openSubState(gameOverSubstate);
		gameOverSubstate.camera = camHUD;
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
			if (p1 != null)
				p1.dance(); // BF dances
			if (p2 != null)
				p2.dance(); // Dad dances
			if (p3 != null)
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
				swagNote.sustainLength = sustainLength;

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
					var susLength:Float = sustainLength / Conductor.stepCrochet;

					for (susNote in 0...Math.floor(susLength))
					{
						var sustainNote:Note = new Note(strum.x, strum.y, noteData, strumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet,
							true, !isPlayerNote, keyCount);
						sustainNote.scrollFactor.set();
						sustainNote.lastNote = swagNote;
						sustainNote.mustPress = isPlayerNote;
						sustainNote.visible = isPlayerNote || showOpponentNotes;
						sustainNote.isSustainNote = true;
						if (susNote == Math.floor(susLength) - 1)
						{
							sustainNote.isEndNote = true;
							sustainNote.playAnim('holdend');
						}
						else
						{
							sustainNote.playAnim('hold');
						}
						spawnNotes.push(sustainNote);
					}
				}
			}
		}

		spawnNotes.sort(sortByShit);
		generatedMusic = true;
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
							xPos = (i * laneOffset) + (FlxG.width / 6) - (laneOffset * 2 / 2) + strumXOffset;
						}
						else
						{
							xPos = ((i - 2) * laneOffset) + (5 * FlxG.width / 6) - (laneOffset * 2 / 2) + strumXOffset;
						}
					case 1: // BF's strums (middle)
						xPos = (i * laneOffset) + (FlxG.width / 2) - (laneOffset * keyCount / 2) + strumXOffset;
					default:
						xPos = 0;
				}
			}
			else
			{
				switch (player)
				{
					case 0: // Dad's strums (left)
						xPos = (i * laneOffset) + (FlxG.width / 4) - (laneOffset * keyCount / 2) + strumXOffset;
					case 1: // BF's strums (right)
						xPos = (i * laneOffset) + (3 * FlxG.width / 4) - (laneOffset * keyCount / 2) + strumXOffset;
					default:
						xPos = 0;
				}
			}

			var yPos:Float = downscroll ? FlxG.height - 150 : strumYPos;
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

		if (!botPlay)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, accuracy);

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
				RainState.switchState(new StoryMenuState());
			}
		}
		else
		{
			RainState.switchState(new FreeplayState(false, camFollowPos.getPosition()));
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
		var songName = storyWeek.songs[storyWeekSongIndex];

		var formattedSongName = StringTools.replace(songName.toLowerCase(), " ", "-");
		var jsonSuffix = difficulty.toLowerCase() == "normal" ? "" : "-" + difficulty.toLowerCase();

		try
		{
			SONG = Song.loadFromJson(formattedSongName + jsonSuffix, formattedSongName);
		}
		catch (e:Dynamic)
		{
			trace('Failed to load song data: ${e}');
			FlxG.switchState(new StoryMenuState());
			return;
		}

		curSong = SONG.song.toLowerCase();

		if (SONG.isVslice && SONG.chartPath != null)
		{
			trace("Loading VSlice song");
			var basePath = SONG.chartPath.split("/")[1];
			trace("Base path: " + basePath);
			inst = Paths.moosic("songs/" + basePath + "/Inst");
			trace("Inst path: " + inst);

			if (FileSystem.exists('assets/songs/${basePath}/Voices.ogg'))
			{
				vocals = new FlxSound().loadEmbedded(Paths.moosic("songs/" + basePath + "/Voices"));
				trace("Loaded vocals");
			}
		}
		else
		{
			trace("Loading regular song");
			inst = Paths.moosic("songs/" + curSong + "/Inst");
			trace("Inst path: " + inst);
		}
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
		// Update input states
		up = Controls.getPressEvent(inputActions[2], 'pressed');
		down = Controls.getPressEvent(inputActions[1], 'pressed');
		left = Controls.getPressEvent(inputActions[0], 'pressed');
		right = Controls.getPressEvent(inputActions[3], 'pressed');

		for (i in 0...inputActions.length)
		{
			var action = inputActions[i];
			var animation = inputAnimations[i];
			var strum = playerStrum.members[i];

			if (Controls.getPressEvent(action, 'justPressed'))
			{
				p1.holdTimer = 0;
				strum.playAnim("press", true);
				var hitNote = checkNoteHit(i, animation);
				if (!hitNote && !ghostTapping)
				{
					noteMiss(i, inputAnimations[i]);
				}
			}
			else if (Controls.getPressEvent(action, 'pressed'))
			{
				var sustainNote = getNearestHoldNote(i);
				if (sustainNote != null && sustainNote.isSustainNote && sustainNote.lastNote.wasGoodHit)
				{
					sustainNote.isBeingHeld = true;
					sustainNote.wasGoodHit = true;
					if (p1 != null)
					{
						p1.playAnim('sing$animation', true);
						p1.animation.finishCallback = null;
					}
					health += 0.004;
					notes.remove(sustainNote);
					sustainNote.kill();
					sustainNote.destroy();
				}
			}
			else if (Controls.getPressEvent(action, 'justReleased'))
			{
				strum.playAnim("static");
				for (note in notes.members)
				{
					if (note != null && note.isSustainNote && note.direction == i && note.isBeingHeld && note.lastNote.wasGoodHit)
					{
						note.isBeingHeld = false;
						if (p1 != null)
						{
							p1.animation.finishCallback = function(name:String)
							{
								if (name.startsWith("sing"))
									p1.playAnim('idle');
							};
						}
						noteMiss(i, inputAnimations[i]);
						break;
					}
				}
			}
		}

		if (p1.holdTimer > Conductor.stepCrochet * 4 * 0.001)
		{
			if (p1.animation.curAnim.name.startsWith('sing') && !p1.animation.curAnim.name.endsWith('miss'))
			{
				p1.playAnim('idle');
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

			if (!hitNote.isSustainNote)
			{
				if (hitNote.direction >= 0)
					health += 0.023;
				else
					health += 0.004;
				combo += 1;
				totalNotesHit += 1;
				popUpScore(hitNote.strum);
			}
			else
			{
				hitNote.isBeingHeld = true;
				health += 0.004;
			}

			if (p1 != null)
			{
				p1.playAnim('sing$animation', true);
				if (!hitNote.isSustainNote)
				{
					p1.animation.finishCallback = function(name:String)
					{
						if (name.startsWith("sing"))
							p1.playAnim('idle');
					};
				}
				else
				{
					p1.animation.finishCallback = null;
				}
			}

			notes.remove(hitNote);
			hitNote.kill();
			hitNote.destroy();

			if (!hitNote.isSustainNote)
			{
				updateAccuracy();
			}
			return true;
		}
		return false;
	}

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		vocals.volume = 1;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;
		var daRating:String = "sick";
		var hitValue:Float = 0;

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
			hitValue = 0.33;
			ss = false;
			shits++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
			hitValue = 0.66;
			ss = false;
			bads++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
			hitValue = 0.85;
			ss = false;
			goods++;
		}
		else
		{
			daRating = 'sick';
			score = 350;
			hitValue = 1.0;
			sicks++;
		}

		totalNotesHit += hitValue;
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

		if (note != null && p2 != null)
		{
			p2.playAnim('sing${animations[note.direction % 4]}', true);
			p2.holdTimer = 0;
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

	function noteMiss(direction:Int = 1, animation:String):Void
	{
		health -= 0.04;
		if (combo > 5)
		{
			p3.playAnim('sad');
		}
		combo = 0;
		songScore -= 10;
		misses++;
		totalNotesHit -= 1.0;
		if (totalNotesHit < 0)
			totalNotesHit = 0;

		updateAccuracy();

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		p1.playAnim('sing${animation}miss', true);
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
		if (vocals == null)
			return;

		vocals.pause();
		FlxG.sound.music.play();

		var curTime:Float = FlxG.sound.music.time;
		if (curTime < 0)
			curTime = 0;

		vocals.time = curTime;
		vocals.play();

		Conductor.songPosition = curTime;
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

	function updateAccuracy()
	{
		totalPlayed += 1;

		var maxScore = totalPlayed * 1.0;
		var actualScore = totalNotesHit;

		if (misses > 0)
		{
			actualScore = Math.max(0, actualScore - (misses * 1.0));
		}

		accuracy = Math.min(100, (actualScore / maxScore) * 100);
		accuracy = Math.round(accuracy * 100) / 100;
	}

	public function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}

		ui.iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		ui.iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		ui.iconP1.updateHitbox();
		ui.iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			p3.dance();
		}

		if (!p1.animation.curAnim.name.startsWith("sing"))
		{
			p1.playAnim('idle');
		}
	}

	function getNearestHoldNote(direction:Int):Note
	{
		var holdNote:Note = null;
		var closestTime:Float = Math.POSITIVE_INFINITY;

		for (note in notes)
		{
			if (note.mustPress && note.direction == direction && !note.wasGoodHit && note.isSustainNote)
			{
				var timeDiff:Float = Math.abs(Conductor.songPosition - note.strum);
				if (timeDiff < Conductor.safeZoneOffset && timeDiff < closestTime)
				{
					holdNote = note;
					closestTime = timeDiff;
				}
			}
		}

		return holdNote;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		var posArray = [0, 0];

		if (char.hscript != null)
		{
			var scriptPosArray = char.hscript.variables.get("positionArray");
			if (scriptPosArray != null)
			{
				posArray = scriptPosArray;
			}
		}

		if (gfCheck && char.curCharacter.startsWith('gf'))
		{
			char.setPosition(posArray[0] != 0 ? posArray[0] : GF_X, posArray[1] != 0 ? posArray[1] : GF_Y);
		}
		else
		{
			char.setPosition(posArray[0] != 0 ? posArray[0] : (char.isPlayer ? BF_X : DAD_X), posArray[1] != 0 ? posArray[1] : (char.isPlayer ? BF_Y : DAD_Y));
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
