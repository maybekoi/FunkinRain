package rain.states;

import flixel.text.FlxText;
import flixel.FlxState;
import rain.backend.Controls;
using StringTools;
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
    var GameMode:Modes;

    // Note Stuff
    var spawnNotes:Array<Note> = [];
	var notes:FlxTypedGroup<Note>;

    // Camera
    private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

    // ETC
    static public var instance:PlayState;

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

        strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
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
        if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
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
        inputShit();
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
            note.y = strum.y - ((Conductor.songPosition - note.strum) * speed);
        
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

			switch (player)
			{
				case 0: // Dad's strums (left)
					if (middleStrum.members.length > 0) {
						xPos = (i * laneOffset) + (FlxG.width / 4) - (laneOffset * keyCount / 2);
					} else {
						xPos = (i * laneOffset) + (FlxG.width / 4) - (laneOffset * keyCount / 2);
					}
				case 1: // BF's strums (right)
					if (middleStrum.members.length > 0) {
						xPos = (i * laneOffset) + (3 * FlxG.width / 4) - (laneOffset * keyCount / 2);
					} else {
						xPos = (i * laneOffset) + (3 * FlxG.width / 4) - (laneOffset * keyCount / 2);
					}
				case 2: // GF or ur p3's strums (mid)
					xPos = (i * laneOffset) + (FlxG.width / 2) - (laneOffset * keyCount / 2);
				default:
					xPos = 0;
			}

			var daStrum:StrumNote = new StrumNote(xPos, strumLine.y, i);
			daStrum.ID = i;
			daStrum.alpha = 0;

			FlxTween.tween(daStrum, {y: daStrum.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			switch (player)
			{
				case 0:
					opponentStrum.add(daStrum);
				case 1:
					playerStrum.add(daStrum);
				case 2:
					middleStrum.add(daStrum);
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
        FlxG.switchState(new FreeplayState());
    }

    function inputShit():Void
    {
        var actions:Array<String> = ["left", "down", "up", "right"];
        var animations:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

        for (i in 0...actions.length)
        {
            if (Controls.getPressEvent(actions[i], 'justPressed'))
            {
                playerStrum.members[i].playAnim("press", true);
                
                var hitNote:Note = null;
                var closestTime:Float = Math.POSITIVE_INFINITY;

                for (note in notes)
                {
                    if (note.mustPress && note.direction == i && !note.wasGoodHit)
                    {
                        var timeDiff:Float = Math.abs(Conductor.songPosition - note.strum);
                        if (timeDiff < Conductor.safeZoneOffset && timeDiff < closestTime)
                        {
                            hitNote = note;
                            closestTime = timeDiff;
                        }
                    }
                }

                if (hitNote != null)
                {
                    hitNote.wasGoodHit = true;
                    playerStrum.members[hitNote.direction].playAnim("confirm", true);
                    
                    p1.playAnim('sing${animations[i]}', true);
                    p1.animation.finishCallback = function(name:String) {
                        if (name.startsWith("sing")) p1.dance();
                    };
                    
                    notes.remove(hitNote);
                    hitNote.kill();
                    hitNote.destroy();
                    //trace("Player hit note!");
                }
            }
            else if (Controls.getPressEvent(actions[i], 'justReleased'))
            {
                playerStrum.members[i].playAnim("static");
            }
        }
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