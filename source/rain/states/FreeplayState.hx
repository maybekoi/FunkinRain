package rain.states;

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
import flixel.FlxTextExt;

using StringTools;

class FreeplayState extends RainState
{

	var bg:FlxSprite;
	var cover:FlxSprite;
	var topBar:FlxSprite;
	
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

	static final freeplaySong:String = "freeplayRandom"; 
	static final freeplaySongBpm:Float = 145; 
	static final freeplaySongVolume:Float = 0.9; 

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

		fakeMainMenuSetup();

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

		if(FlxG.keys.justPressed.ESCAPE){
			FlxG.switchState(new MainMenuState());
		}

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

		cover = new FlxSprite().loadGraphic(Paths.image('menus/freeplay/sideCover'));

		topBar = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		topBar.scale.set(1280, 64);
		topBar.updateHitbox();

		add(bg);
		add(cover);
		add(topBar);

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
						transitionOver = true;
						startFreeplaySong();
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
			var transitionEase:flixel.tweens.EaseFunction = FlxEase.quintOut;
			
			bg.x -= 1280;
			cover.x += 1280;
			topBar.y -= 720;

			FlxTween.tween(bg, {x: 0}, transitionTime, {ease: transitionEase, onComplete: function(t) {
				
			}});
			FlxTween.tween(cover, {x: 0}, transitionTime, {ease: transitionEase});
			FlxTween.tween(topBar, {y: 0}, transitionTime, {ease: transitionEase});

		}
		else{
			transitionOver = true;
			startFreeplaySong();
		}

	}

	function fakeMainMenuSetup():Void{
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menus/bgs/menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.cameras = [camMenu];
		add(bg);

		add(camFollow);

		camMenu.follow(camFollow);
	}
	
	function startFreeplaySong():Void{
		FlxG.sound.playMusic(Paths.music(freeplaySong), freeplaySongVolume);
	}
}