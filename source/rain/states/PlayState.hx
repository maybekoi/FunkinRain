package rain.states;

import flixel.text.FlxText;
import flixel.FlxState;
import rain.backend.Controls;

enum Modes
{
    STORYMODE;
    FREEPLAY;
    CHARTING;
}

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

    // Strum-related stuff
    private var strumLine:FlxSprite;
    private var strumLineNotes:FlxTypedGroup<FlxSprite>;
    var playerStrum:FlxTypedGroup<StrumNote>;
    var opponentStrum:FlxTypedGroup<StrumNote>;
    var middleStrum:FlxTypedGroup<StrumNote>;
    var laneOffset:Int = 100;
    var keyCount:Int = 4;

    // Gameplay stuff
    public static var GameMode:Modes;
    private var generatedMusic:Bool = false;
    private var startingSong:Bool = false;
    private var paused:Bool = false;
    private var startedCountdown:Bool = false;
	public var speed:Float;

    // Note Stuff
    var spawnNotes:Array<Note> = [];
	var notes:FlxTypedGroup<Note>;

    public function new() {
        super();
    }

    override public function create()
    {
        GameMode = Modes.FREEPLAY;

        SONG = RainUtil.loadFromJson('bopeebo', 'bopeebo');
        curSong = SONG.song.toLowerCase(); // weird way of doing it but it works lol
        trace(curSong);
        inst = Paths.song(curSong + '/Inst');
        trace(inst);
        speed = SONG.speed;

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

        p1 = new Character(true);
        p1.setCharacter(770, 450, 'bf');
        add(p1);

        p2 = new Character(false);
        p2.setCharacter(100, 100, 'dad');
        add(p2);

        p3 = new Character(false);
        p3.setCharacter(400, 130, 'gf');
        add(p3);

        Controls.init(); // controls init

        super.create();

        startCountdown();
        generateNotes(SONG.song);

        startingSong = true;
    }

	var canPause:Bool = true;
    override public function update(elapsed:Float)
    {
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

		p1.dance(); // BF dances
		p2.dance(); // Dad dances
		p3.dance(); // GF dances

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
			var strum = playerStrum.members[note.direction % keyCount];
			note.y = strum.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));

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
    
                var oldNote:Note = spawnNotes.length > 0 ? spawnNotes[spawnNotes.length - 1] : null;
                swagNote.lastNote = oldNote;
    
                swagNote.playAnim('note');
    
                spawnNotes.push(swagNote);
    
                if (sustainLength > 0) {
                    var sustainNote:Note = new Note(strum.x, strum.y, noteData, strumTime + sustainLength, true, !isPlayerNote, keyCount);
                    sustainNote.scrollFactor.set();
                    sustainNote.lastNote = swagNote;
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
        FlxG.switchState(new AlphaState());
    }

    function inputShit():Void
    {
        var actions:Array<String> = ["left", "down", "up", "right"];

        for (i in 0...actions.length)
        {
            if (Controls.getPressEvent(actions[i], 'justPressed'))
            {
                playerStrum.members[i].playAnim("press", true);
            }
            else if (Controls.getPressEvent(actions[i], 'justReleased'))
            {
                playerStrum.members[i].playAnim("static");
            }
        }

        var possibleNotes:Array<Note> = [];
	
		for (note in notes) {
			note.calculateCanBeHit();
	
			if ((!note.isSustainNote ? note.strum : note.strum - 1) <= Conductor.songPosition)
				possibleNotes.push(note);
		}
	
		possibleNotes.sort((a, b) -> Std.int(a.strum - b.strum));
	
		var doNotHit:Array<Bool> = [false, false, false, false];
		var noteDataTimes:Array<Float> = [-1, -1, -1, -1];
	
		if (possibleNotes.length > 0) {
			for (i in 0...possibleNotes.length) {
				var note = possibleNotes[i];
	
                if (Controls.getPressEvent(actions[note.direction], 'justPressed') && !doNotHit[note.direction])
                {
					var noteMs = (Conductor.songPosition - note.strum) / 1;
	
					noteDataTimes[note.direction] = note.strum;
					doNotHit[note.direction] = true;
	
					playerStrum.members[note.direction].playAnim("confirm", true);
	
					note.active = false;
					notes.remove(note);
					note.kill();
					note.destroy();
				}
			}
	
			if (possibleNotes.length > 0) {
				for (i in 0...possibleNotes.length) {
					var note = possibleNotes[i];
	
					if (note.strum == noteDataTimes[note.direction] && doNotHit[note.direction]) {
						note.active = false;
						notes.remove(note);
						note.kill();
						note.destroy();
					}
				}
			}
		}
    }

    override public function destroy():Void
    {
        super.destroy();
        Controls.destroy();
    }
}
