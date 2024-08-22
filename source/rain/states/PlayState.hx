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
    public static var SONG:Song;
    private var curSong:String = "";
    private var vocals:FlxSound;
    private var inst:String = Paths.music('songs/test/Inst');

    // Strum-related stuff
    private var strumLine:FlxSprite;
    private var strumLineNotes:FlxTypedGroup<FlxSprite>;
    var playerStrum:FlxTypedGroup<StrumNote>;
    var opponentStrum:FlxTypedGroup<StrumNote>;
    var middleStrum:FlxTypedGroup<StrumNote>; // Group for middle strums
    var laneOffset:Int = 100;
    var Notes:Int = 4;

    // Gameplay stuff
    public static var GameMode:Modes;
    private var generatedMusic:Bool = false;
    private var startingSong:Bool = false;
    private var paused:Bool = false;
    private var startedCountdown:Bool = false;

    override public function create()
    {
        GameMode = Modes.FREEPLAY;

        SONG = RainUtil.loadFromJson('test', 'test');
        curSong = SONG.song;
        trace(curSong);

        strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
        strumLine.scrollFactor.set();

        strumLineNotes = new FlxTypedGroup<FlxSprite>();
        add(strumLineNotes);

        playerStrum = new FlxTypedGroup<StrumNote>();
        add(playerStrum);

        opponentStrum = new FlxTypedGroup<StrumNote>();
        add(opponentStrum);

        middleStrum = new FlxTypedGroup<StrumNote>(); // Initialize middle strums
        add(middleStrum);

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
                startSong();
            }
        }

		p1.dance(); // BF dances
		p2.dance(); // Dad dances
		p3.dance(); // GF dances

        inputShit();
        super.update(elapsed);
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

	public function genArrows(player:Int):Void
	{
		for (i in 0...Notes)
		{
			var xPos:Float;

			switch (player)
			{
				case 0: // Dad's strums (left)
					if (middleStrum.members.length > 0) {
						xPos = (i * laneOffset) + (FlxG.width / 4) - (laneOffset * Notes / 2);
					} else {
						xPos = (i * laneOffset) + (FlxG.width / 4) - (laneOffset * Notes / 2);
					}
				case 1: // BF's strums (right)
					if (middleStrum.members.length > 0) {
						xPos = (i * laneOffset) + (3 * FlxG.width / 4) - (laneOffset * Notes / 2);
					} else {
						xPos = (i * laneOffset) + (3 * FlxG.width / 4) - (laneOffset * Notes / 2);
					}
				case 2: // GF or ur p3's strums (mid)
					xPos = (i * laneOffset) + (FlxG.width / 2) - (laneOffset * Notes / 2);
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
        {
            FlxG.sound.playMusic(inst);
            FlxG.sound.music.onComplete = endSong;
        }
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
    }

    override public function destroy():Void
    {
        super.destroy();
        Controls.destroy();
    }
}
