package rain.states;

import rain.SaveManager;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.math.FlxPoint;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.text.FlxText;

using StringTools;

class FreeplayState extends RainState
{

	var bg:FlxSprite;
	var flash:FlxSprite;
	var cover:FlxSprite;
	var topBar:FlxSprite;
	var freeplayText:FlxText;
	var highscoreSprite:FlxSprite;
	var clearPercentSprite:FlxSprite;
	var scoreDisplay:DigitDisplay;
	var percentDisplay:DigitDisplay;
	var albumTitle:FlxSprite;

	var album:FlxSprite;
	var albumDummy:FlxObject;
	var albumTime:Float = 0;
	final ablumPeriod:Float = 1/24;

	var scrollingText:FlxTypedSpriteGroup<FlxBackdrop> = new FlxTypedSpriteGroup<FlxBackdrop>();

	var dj:FlxSprite;

	var transitionOver:Bool = false;
	var waitForFirstUpdateToStart:Bool = true;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var camFollow:FlxObject;
	var camTarget:FlxPoint = new FlxPoint();
	var versionText:FlxTextExt;

	var transitionFromMenu:Bool;

	private var camMenu:FlxCamera;
	private var camFreeplay:FlxCamera;

	var scrollingTextStuff:Array<ScrollingTextInfo> = [];

	static final freeplaySong:String = "freeplayRandom"; 
	static final freeplaySongBpm:Float = 145; 
	static final freeplaySongVolume:Float = 0.9; 
    var arrowLeft:FlxSprite;
	var arrowRight:FlxSprite;
	var difficulty:FlxSprite;

	public function new(transitionFromMenu:Bool, camFollowPos:FlxPoint) {
		super();
        this.transitionFromMenu = transitionFromMenu;
		if(camFollowPos == null){
			camFollowPos = new FlxPoint();
		}
		camFollow = new FlxObject(camFollowPos.x, camFollowPos.y, 1, 1);
	}

	override function create(){

		persistentUpdate = persistentDraw = true;

		if(transitionFromMenu){
			if(FlxG.sound.music.playing){
				FlxG.sound.music.volume = 0;
			}
			//FlxG.sound.play(Paths.sound("freeplay/recordStop"));
			FlxG.sound.play(Paths.sound('confirmMenu'));
		}

		camMenu = new FlxCamera();

		camFreeplay = new FlxCamera();
		camFreeplay.bgColor.alpha = 0;

		FlxG.cameras.reset(camMenu);
		FlxG.cameras.add(camFreeplay, true);
		FlxG.cameras.setDefaultDrawTarget(camMenu, false);

		setUpScrollingText();

		super.create();
	}



	override function update(elapsed:Float){

		if(waitForFirstUpdateToStart){
			createFreeplayStuff();
			waitForFirstUpdateToStart = false;
		}

		if(transitionOver){
			Conductor.songPosition = FlxG.sound.music.time;
		}

		albumTime += elapsed;
		if(albumTime >= ablumPeriod){
			albumTime = 0;
			album.setPosition(albumDummy.x, albumDummy.y);
			album.angle = albumDummy.angle;
		}

		/*if(FlxG.keys.anyJustPressed([UP])){
			percentDisplay.y -= 1;
		}
		else if(FlxG.keys.anyJustPressed([DOWN])){
			percentDisplay.y += 1;
		}
		else if(FlxG.keys.anyJustPressed([LEFT])){
			percentDisplay.x -= 1;
		}
		else if(FlxG.keys.anyJustPressed([RIGHT])){
			percentDisplay.x += 1;
		}

		trace(percentDisplay.getPosition());*/

		if(FlxG.keys.anyJustPressed([SPACE])){
			scoreDisplay.tweenNumber(FlxG.random.int(0, 9999999), 1);
			percentDisplay.tweenNumber(FlxG.random.int(0, 100), 1);
		}
		else if(FlxG.keys.anyJustPressed([Q])){
			scoreDisplay.tweenNumber(0, 1);
			percentDisplay.tweenNumber(0, 1);
		}
		else if(FlxG.keys.anyJustPressed([E])){
			scoreDisplay.tweenNumber(9999999, 1);
			percentDisplay.tweenNumber(100, 1);
		}

        if(FlxG.keys.anyJustPressed([LEFT])){
			arrowLeft.scale.set(0.75, 0.75);
		}
		else{
			arrowLeft.scale.set(1, 1);
		}
		if(FlxG.keys.anyJustPressed([RIGHT])){
			arrowRight.scale.set(0.75, 0.75);
		}
		else{
			arrowRight.scale.set(1, 1);
		}

		if(FlxG.keys.justPressed.ESCAPE){
			FlxG.switchState(new MainMenuState());
		}
		
		camFollow.x = Utils.fpsAdjsutedLerp(camFollow.x, camTarget.x, 0.1);
		camFollow.y = Utils.fpsAdjsutedLerp(camFollow.y, camTarget.y, 0.1);

		super.update(elapsed);

	}



	override function beatHit() {
		if(transitionOver && curBeat % 2 == 0 && dj.animation.curAnim.name == "idle"){
			dj.animation.play("idle", true);
		}

		super.beatHit();
	}



	function createFreeplayStuff():Void{
		
		bg = new FlxSprite().loadGraphic(Paths.image('menus/freeplay/bg'));
        bg.antialiasing = SaveManager.antialiasEnabled;


		addScrollingText();
		scrollingText.visible = false;

		flash = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		flash.scale.set(1280, 720);
		flash.updateHitbox();
		flash.alpha = 0;
		flash.visible = false;

		cover = new FlxSprite().loadGraphic(Paths.image('menus/freeplay/sideCover'));
		cover.antialiasing = SaveManager.antialiasEnabled;

		topBar = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		topBar.scale.set(1280, 64);
		topBar.updateHitbox();

		freeplayText = new FlxText(16, 16, 0, "FREEPLAY", 32);
		freeplayText.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE);

		highscoreSprite = new FlxSprite(860, 70);
		highscoreSprite.frames = Paths.getSparrowAtlas("menus/freeplay/highscore");
		highscoreSprite.animation.addByPrefix("loop", "", 24, true);
		highscoreSprite.animation.play("loop");

		clearPercentSprite = new FlxSprite(1165, 65).loadGraphic(Paths.image('menus/freeplay/clearBox'));
		clearPercentSprite.antialiasing = SaveManager.antialiasEnabled;

		scoreDisplay = new DigitDisplay(915, 120, "menus/freeplay/digital_numbers", 7, 0.4, -25);
		scoreDisplay.setDigitOffset(1, 20);
		scoreDisplay.tweenNumber(1234567, 1);

		percentDisplay = new DigitDisplay(1154, 87, "menus/freeplay/clearText", 3, 1, 3, 0, true);
		percentDisplay.setDigitOffset(1, -8);
		percentDisplay.tweenNumber(100, 1);

		albumDummy = new FlxObject(950, 285, 1, 1);
		albumDummy.angle = 10;
		album = new FlxSprite(albumDummy.x, albumDummy.y).loadGraphic(Paths.image("menus/freeplay/album/vol1/album"));
		album.antialiasing = SaveManager.antialiasEnabled;
		album.angle = albumDummy.angle;
		
		albumTitle = new FlxSprite(album.x - 5, album.y + 205).loadGraphic(Paths.image("menus/freeplay/album/vol1/title"));
		albumTitle.antialiasing = SaveManager.antialiasEnabled;

        arrowLeft = new FlxSprite(20, 70);
		arrowLeft.frames = Paths.getSparrowAtlas("menus/freeplay/freeplaySelector");
		arrowLeft.animation.addByPrefix("loop", "arrow pointer loop", 24, true);
		arrowLeft.animation.play("loop");
		arrowLeft.antialiasing = true;
		arrowRight = new FlxSprite(325, 70);
		arrowRight.frames = Paths.getSparrowAtlas("menus/freeplay/freeplaySelector");
		arrowRight.animation.addByPrefix("loop", "arrow pointer loop", 24, true);
		arrowRight.animation.play("loop");
		arrowRight.flipX = true;
		arrowRight.antialiasing = true;
		difficulty = new FlxSprite(197, 115).loadGraphic(Paths.image("menus/freeplay/diff/normal"));
		difficulty.offset.set(difficulty.width/2, difficulty.height/2);
		difficulty.antialiasing = true;

		add(bg);
		add(scrollingText);
		add(flash);
        add(arrowLeft);
		add(arrowRight);
		add(difficulty);
		add(cover);
		add(topBar);
		add(freeplayText);
		add(highscoreSprite);
		add(clearPercentSprite);
		add(scoreDisplay);
		add(percentDisplay);
		add(album);
		add(albumTitle);

		dj = new FlxSprite(-10, 296);
		dj.cameras = [camFreeplay];
		dj.frames = Paths.getSparrowAtlas("menus/freeplay/dj/bf");
		dj.antialiasing = true;

		dj.animation.addByPrefix("idle", "Boyfriend DJ0", 24, false, false, false);
		dj.animation.addByPrefix("intro", "boyfriend dj intro", 24, false, false, false);
        dj.animation.addByPrefix("confirm", "Boyfriend DJ confirm", 24, false, false, false);
		
		dj.animation.callback = function(name, frameNumber, frameIndex) {
			switch(name){
				case "idle":
					dj.offset.set(0, 0);
				case "intro":
					dj.offset.set(5, 427);
				case "confirm":
					dj.offset.set(43, -24);
			}
		}

		dj.animation.finishCallback = function(name) {
			switch(name){
				case "idle":
					dj.animation.play("idle", true, false, dj.animation.curAnim.numFrames - 4);
				case "intro":
					if(transitionFromMenu && !transitionOver){
						djIntroFinish();
						dj.animation.play("idle", true);
					}
			}
		}

		if(transitionFromMenu){
			dj.animation.play("intro", true);
		}
		else {
			dj.animation.play("idle", true);
		}
		

		add(dj);

		if(transitionFromMenu){
			var transitionTime:Float = 1;
			var staggerTime:Float = 0.07;
			var randomVariation:Float = 0.1;
			var transitionEase:flixel.tweens.EaseFunction = FlxEase.quintOut;
			
			bg.x -= 1280;
			flash.visible = true;
			cover.x += 1280;
			topBar.y -= 720;
			freeplayText.y -= 720;
			highscoreSprite.x += 1280;
			clearPercentSprite.x += 1280;
			scoreDisplay.x += 1280;
			percentDisplay.x += 1280;
			albumTitle.x += 1280;
			arrowLeft.y -= 720;
			arrowRight.y -= 720;
			difficulty.y -= 720;

			var albumPos = albumDummy.x;
			albumDummy.x = 1280;
			albumDummy.angle = 70;
			album.x = albumDummy.x;
			album.angle = albumDummy.angle;

			FlxTween.tween(bg, {x: 0}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
			FlxTween.tween(cover, {x: 0}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
			FlxTween.tween(topBar, {y: 0}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
			FlxTween.tween(freeplayText, {y: 16}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
			FlxTween.tween(highscoreSprite, {x: highscoreSprite.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime});
			FlxTween.tween(clearPercentSprite, {x: clearPercentSprite.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime*2});
			FlxTween.tween(scoreDisplay, {x: scoreDisplay.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime*3});
			FlxTween.tween(percentDisplay, {x: percentDisplay.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime*2});
			FlxTween.tween(albumDummy, {x: albumPos, angle: 10}, transitionTime/1.1 + FlxG.random.float(-randomVariation, randomVariation), {ease: albumElasticOut});
			FlxTween.tween(albumTitle, {x: albumTitle.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
            FlxTween.tween(arrowLeft, {y: arrowLeft.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime});
			FlxTween.tween(arrowRight, {y: arrowRight.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime});
			FlxTween.tween(difficulty, {y: difficulty.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime*2});

		}
		else{
			djIntroFinish();
		}

	}
    
	function djIntroFinish():Void{
		transitionOver = true;
		startFreeplaySong();

		flash.alpha = 1;
		scrollingText.visible = true;
		FlxTween.tween(flash, {alpha: 0}, 1, {startDelay: 0.1});
	}
	
	function startFreeplaySong():Void{
		FlxG.sound.playMusic(Paths.music(freeplaySong), freeplaySongVolume);
		Conductor.changeBPM(114);
	}

	function setUpScrollingText():Void{
		scrollingTextStuff.push({
			text: "HOT BLOODED IN MORE WAYS THAN ONE ",
			font: Paths.font("5by7"),
			size: 43,
			color: 0xFFFFF383,
			position: new FlxPoint(0, 168),
			velocity: 6.8
		});

		scrollingTextStuff.push({
			text: "BOYFRIEND ",
			font: Paths.font("5by7"),
			size: 60,
			color: 0xFFFF9963,
			position: new FlxPoint(0, 220),
			velocity: -3.8
		});

		scrollingTextStuff.push({
			text: "PROTECT YO NUTS ",
			font: Paths.font("5by7"),
			size: 43,
			color: 0xFFFFFFFF,
			position: new FlxPoint(0, 285),
			velocity: 3.5
		});

		scrollingTextStuff.push({
			text: "BOYFRIEND ",
			font: Paths.font("5by7"),
			size: 60,
			color: 0xFFFF9963,
			position: new FlxPoint(0, 335),
			velocity: -3.8
		});

		scrollingTextStuff.push({
			text: "HOT BLOODED IN MORE WAYS THAN ONE ",
			font: Paths.font("5by7"),
			size: 43,
			color: 0xFFFFF383,
			position: new FlxPoint(0, 397),
			velocity: 6.8
		});

		scrollingTextStuff.push({
			text: "BOYFRIEND ",
			font: Paths.font("5by7"),
			size: 60,
			color: 0xFFFEA400,
			position: new FlxPoint(0, 455),
			velocity: -3.8
		});
	}

	function addScrollingText():Void{

		for(x in scrollingTextStuff){
			var tempText = new FlxText(0, 0, 0, x.text);
			tempText.setFormat(x.font, x.size, x.color);

			var scrolling:FlxBackdrop = ScrollingText.createScrollingText(x.position.x, x.position.y, tempText);
			scrolling.velocity.x = x.velocity * 60;
			
			scrollingText.add(scrolling);
		}
		
	}

	static inline function albumElasticOut(t:Float):Float{
		var ELASTIC_AMPLITUDE:Float = 1;
		var ELASTIC_PERIOD:Float = 0.6;
		return (ELASTIC_AMPLITUDE * Math.pow(2, -10 * t) * Math.sin((t - (ELASTIC_PERIOD / (2 * Math.PI) * Math.asin(1 / ELASTIC_AMPLITUDE))) * (2 * Math.PI) / ELASTIC_PERIOD) + 1);
	}
}