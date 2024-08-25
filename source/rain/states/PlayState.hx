package rain.states;

import flixel.text.FlxText;
import flixel.FlxState;
import rain.backend.Controls;
using StringTools;
import openfl.Lib;

class PlayState extends RainState
{
    // Characters
    public var p1:Character; // bf
    public var p2:Character; // dad
    public var p3:Character; // gf

    // Song-related stuff
    public var SONG:SwagSong;
    public var curSong:String = "";
	private var vocals:FlxSound;
    private var inst:String;
    public var difficulty:String = "";

    // Strum-related stuff
    private var strumLine:FlxSprite;
    private var strumLineNotes:FlxTypedGroup<FlxSprite>;
    var playerStrum:FlxTypedGroup<StrumNote>;
    var opponentStrum:FlxTypedGroup<StrumNote>;
    var middleStrum:FlxTypedGroup<StrumNote>;
    var laneOffset:Int = 100;
    var keyCount:Int = 4;

    // Gameplay stuff
    private var generatedMusic:Bool = false;
    private var startingSong:Bool = false;
    private var paused:Bool = false;
    private var startedCountdown:Bool = false;
	public var speed:Float;
    public var GameMode:Modes;

    // Note Stuff
    var spawnNotes:Array<Note> = [];
	var notes:FlxTypedGroup<Note>;

    // Camera
    private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

    // ETC
    public var instance:PlayState;

    private var windowFocused:Bool = true;

    private var inputActions:Array<String> = ["left", "down", "up", "right"];
    private var inputAnimations:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    private var downscroll:Bool;
    private var middleScroll:Bool;
    private var botPlay:Bool;

    override public function create()
    {
        instance = this;

        if (SongData.currentSong != null) {
            SONG = SongData.currentSong;
            difficulty = SongData.currentDifficulty;
            GameMode = SongData.gameMode;

            if (SongData.opponent != null) {
                SONG.player2 = SongData.opponent;
            }
            
            SongData.currentSong = null;
            SongData.currentDifficulty = null;
            SongData.gameMode = null;
            SongData.opponent = null;
        }

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

        trace("Creating p1 (player) with character: " + SONG.player1);
        p1 = new Character(true);
        p1.setCharacter(770, 450, SONG.player1);
        trace("p1 created, position: " + p1.x + ", " + p1.y);
        add(p1);
        trace("p1 added to stage");
        
        trace("Creating p2 (opponent) with character: " + SONG.player2);
        p2 = new Character(false);
        p2.setCharacter(100, 100, SONG.player2);
        trace("p2 created, position: " + p2.x + ", " + p2.y);
        add(p2);
        trace("p2 added to stage");

        p3 = new Character(false);
        p3.setCharacter(400, 130, 'gf');
        add(p3);

        Controls.init(); // controls init

        strumLineNotes.cameras = [camHUD];
        playerStrum.cameras = [camHUD];
        opponentStrum.cameras = [camHUD];
        notes.cameras = [camHUD];

        super.create();

        startCountdown();
        generateNotes(SONG.song);

        startingSong = true;
    }

	var canPause:Bool = true;
    override public function update(elapsed:Float)
    {
        // pause shiz
        if (FlxG.keys.justPressed.ENTER && canPause)
        {
            persistentUpdate = false;
			paused = true;
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

        if (spawnNotes[0] != null) {
            while (spawnNotes.length > 0 && spawnNotes[0].strum - Conductor.songPosition < (1500 * 1)) {
                var dunceNote:Note = spawnNotes[0];
                notes.add(dunceNote);

                var index:Int = spawnNotes.indexOf(dunceNote);
                spawnNotes.splice(index, 1);
            }
        }

        for (note in notes) {
            var strum:StrumNote;
            if (note.mustPress) {
                strum = playerStrum.members[note.direction % keyCount];
            } else {
                strum = opponentStrum.members[note.direction % keyCount];
            }
            
            if (downscroll) {
                note.y = strum.y + ((Conductor.songPosition - note.strum) * speed / 2);
            } else {
                note.y = strum.y - ((Conductor.songPosition - note.strum) * speed / 2);
            }
        
            if (!note.mustPress && Conductor.songPosition >= note.strum && note != null) {
                opponentNoteHit(note);
                notes.remove(note);
                note.kill();
                note.destroy();
            }
        
            if (Conductor.songPosition > note.strum + (120 * 1) && note != null) {
                notes.remove(note);
                note.kill();
                note.destroy();
                trace("miss!");
            }
        }        
    }

    function startCountdown():Void
    {
        genArrows(0); // Dad's strums
        genArrows(1); // BF's strums
		//genArrows(2);

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

    function generateNotes(dataPath:String):Void {
        for (section in SONG.notes) {
            var mustHitSection:Bool = section.mustHitSection;
            
            for (note in section.sectionNotes) {
                var strumTime:Float = note[0];
                var noteData:Int = Std.int(note[1] % keyCount);
                var sustainLength:Float = note[2];
    
                var isPlayerNote:Bool = mustHitSection;
                if (note[1] > 3) isPlayerNote = !mustHitSection;
    
                var strum:StrumNote = isPlayerNote ? playerStrum.members[noteData] : opponentStrum.members[noteData];
    
                var swagNote:Note = new Note(strum.x, strum.y, noteData, strumTime, false, !isPlayerNote, keyCount);
                swagNote.scrollFactor.set();
                swagNote.mustPress = isPlayerNote;
    
                var oldNote:Note = spawnNotes.length > 0 ? spawnNotes[spawnNotes.length - 1] : null;
                swagNote.lastNote = oldNote;
    
                swagNote.playAnim('note');
    
                spawnNotes.push(swagNote);
    
                if (sustainLength > 0) {
                    var sustainNote:Note = new Note(strum.x, strum.y, noteData, strumTime + sustainLength, true, !isPlayerNote, keyCount);
                    sustainNote.scrollFactor.set();
                    sustainNote.lastNote = swagNote;
                    sustainNote.mustPress = isPlayerNote;
                    spawnNotes.push(sustainNote);
                }
            }
        }
    
        spawnNotes.sort(sortByShit);
    }

	function sortByShit(Obj1:Note, Obj2:Note):Int {
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
						if (i < 2) {
							xPos = (i * laneOffset) + (FlxG.width / 6) - (laneOffset * 2 / 2);
						} else {
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
        RainState.switchState(new FreeplayState());
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
                checkNoteHit(i, animation);
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
                new FlxTimer().start(0.15, function(tmr:FlxTimer) {
                    strum.playAnim("static");
                });
            }
        }
    }

    function checkNoteHit(direction:Int, animation:String):Void
    {
        var hitNote = getNearestHittableNote(direction);

        if (hitNote != null)
        {
            hitNote.wasGoodHit = true;
            playerStrum.members[hitNote.direction].playAnim("confirm", true);
            
            p1.playAnim('sing$animation', true);
            p1.animation.finishCallback = function(name:String) {
                if (name.startsWith("sing")) p1.dance();
            };
            
            notes.remove(hitNote);
            hitNote.kill();
            hitNote.destroy();
        }
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
            p2.animation.finishCallback = function(name:String) {
                if (name.startsWith("sing")) p2.dance();
            };
            
            opponentStrum.members[note.direction % 4].playAnim("confirm", true);
            //trace("Opponent hit note!");
            new FlxTimer().start(0.15, function(tmr:FlxTimer) {
                opponentStrum.members[note.direction % 4].playAnim("static");
            });
        }
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

    override public function destroy():Void
    {
        super.destroy();
        Controls.destroy();
    }
}