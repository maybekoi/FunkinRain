package rain.charselect;

import flixel.FlxG;
import rain.backend.Controls;
import rain.states.MainMenuState;
import flxanimate.FlxAnimate;
import openfl.display.BlendMode;
import rain.charselect.*;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;

class CharacterUnlockState extends RainState {
    var playerChill:CharSelectPlayer;
    var gfChill:CharSelectGF;
    var bfTemp:FlxAnimate;
    var barthing:FlxAtlasSprite;
    var dipshitBlur:FlxSprite;
    var dipshitBacking:FlxSprite;
    var chooseDipshit:FlxSprite;
    var nametag:Nametag;
    var Maincursor:FlxSprite;
    var grpCursors:FlxTypedSpriteGroup<FlxSprite>;
    var grpIcons:FlxTypedGroup<FlxSprite>;
    var cursorBlue:FlxSprite;
    var cursorDarkBlue:FlxSprite;
    var cursorConfirmed:FlxSprite;
    var cursorDenied:FlxSprite;
    var availableChars:Map<Int, String>;
    public var nonLocks:Array<Int> = [];
    private var cursorIndex:Int = 0;
    private var cursorPosition:FlxPoint;
    private var currentPlayerChar:String = "";
    private var currentGFChar:String = "";
    private var isAnimating:Bool = false;
    private var preloadedCharacters:Map<String, CharSelectPlayer>;
    private var preloadedGFs:Map<String, CharSelectGF>;
    private var colors:Array<FlxColor>;
    private var lockedChar:FlxSprite;

    override public function create() {
        colors = [
            FlxColor.fromRGB(49, 229, 229),  // Light cyan
            FlxColor.fromRGB(32, 229, 237),  // Cyan
            FlxColor.fromRGB(32, 197, 244),  // Light blue
            FlxColor.fromRGB(32, 165, 250),  // Blue
            FlxColor.fromRGB(35, 101, 249),  // Darker blue
            FlxColor.fromRGB(36, 79, 249)    // Even darker blue
        ];

        super.create();

        var bg:FlxSprite = new FlxSprite(-153, -140).loadGraphic(Paths.image('charSelect/charSelectBG'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = SaveManager.antialiasEnabled;
		add(bg);

        var crowd = new FlxAtlasSprite(0, 0, Paths.animateAtlas("charSelect/crowd"));        
        var animations = crowd.listAnimations();
        if (animations.length > 0) {
            trace("Available animations: " + animations.join(", "));
        } else {
            trace("No animations found!");
        }
        if (crowd.hasAnimation("Layer_1")) {
            crowd.playAnimation("Layer_1", false, false, true);
        } else {
            trace("'Layer_1' animation not found. Attempting to play default animation.");
            crowd.playAnimation("", false, false, true);
        }
        crowd.scrollFactor.set(0.3, 0.3);
        add(crowd);

        var stageSpr = new FlxSprite(-40, 391);
        stageSpr.frames = (Paths.getSparrowAtlas("charSelect/charSelectStage"));
        stageSpr.animation.addByPrefix("idle", "stage full instance 1", 24, true);
        stageSpr.animation.play("idle");
        this.add(stageSpr);

        var curtains = new FlxSprite(-47, -49);
        curtains.loadGraphic(Paths.image("charSelect/curtains"));
        curtains.scrollFactor.set(1.4, 1.4);
        this.add(curtains);

        this.barthing = new FlxAtlasSprite(0, 0, Paths.animateAtlas("charSelect/barThing"));
        this.barthing.anim.play("Layer_1");
        this.barthing.onAnimationFinish.add(function (name:String) {
          barthing.playAnimation("Layer_1");
        });
        this.barthing.blend = openfl.display.BlendMode.ADD;
        this.barthing.scrollFactor.set(0, 0);
        var darkenAmount = 0; // 0 black, 1 og color
        this.barthing.color = FlxColor.fromRGBFloat(darkenAmount, darkenAmount, darkenAmount);
        this.add(this.barthing);
        this.barthing.y += 80;

        var charLight = new FlxSprite(800, 250);
        charLight.loadGraphic(Paths.image("charSelect/charLight"));
        this.add(charLight);

        var charLightGF = new FlxSprite(180, 240);
        charLightGF.loadGraphic(Paths.image("charLight"));
        this.add(charLightGF);

        preloadedCharacters = new Map<String, CharSelectPlayer>();
        preloadedGFs = new Map<String, CharSelectGF>();
        preloadCharacters();

        playerChill = new CharSelectPlayer(0, 0);
        add(playerChill);

        gfChill = new CharSelectGF(0, 0);
        add(gfChill);
        currentPlayerChar = "bf";
        currentGFChar = "gf";
        playerChill.switchChar(currentPlayerChar);
        gfChill.switchChar(currentGFChar);

        lockedChar = new FlxSprite(770, 175);
        lockedChar.frames = Paths.getSparrowAtlas('charSelect/randomChill');
        lockedChar.animation.addByPrefix('idle', 'LOCKED MAN instance', 24, true);
        lockedChar.animation.play('idle');
        lockedChar.visible = false;
        add(lockedChar);

        var speakers = new FlxAtlasSprite(0, 0, Paths.animateAtlas("charSelect/charSelectSpeakers"));
        
        var animations = speakers.listAnimations();
        if (animations.length > 0) {
            trace("Available animations: " + animations.join(", "));
        } else {
            trace("No animations found!");
        }

        if (speakers.hasAnimation("Layer_1")) {
            speakers.playAnimation("Layer_1", false, false, true);
        } else {
            trace("'Layer_1' animation not found. Attempting to play default animation.");
            speakers.playAnimation("", false, false, true);
        }

        speakers.onAnimationFinish.add(function (name:String) {
            speakers.playAnimation(name, false, false, true);
        });

        speakers.scrollFactor.set(1.8, 1.8);
        this.add(speakers);

        this.dipshitBlur = new FlxSprite(419, -65);
        this.dipshitBlur.frames = (Paths.getSparrowAtlas("charSelect/dipshitBlur"));
        this.dipshitBlur.animation.addByPrefix("idle", "CHOOSE vertical offset instance 1", 24, true);
        this.dipshitBlur.blend = openfl.display.BlendMode.ADD;
        this.dipshitBlur.animation.play("idle");
        this.add(this.dipshitBlur);

        this.dipshitBacking = new FlxSprite(423, -17);
        this.dipshitBacking.frames = (Paths.getSparrowAtlas("charSelect/dipshitBacking"));
        this.dipshitBacking.animation.addByPrefix("idle", "CHOOSE horizontal offset instance 1", 24, true);
        this.dipshitBacking.blend = openfl.display.BlendMode.ADD;
        this.dipshitBacking.animation.play("idle");
        this.add(this.dipshitBacking);

        this.chooseDipshit = new FlxSprite(426, -13);
        this.chooseDipshit.loadGraphic(Paths.image("charSelect/chooseDipshit"));
        this.add(this.chooseDipshit);

        this.nametag = new Nametag();
        this.add(this.nametag);

        this.grpCursors = new FlxTypedSpriteGroup<FlxSprite>();
        this.add(this.grpCursors);

        this.Maincursor = new FlxSprite(0, 0);
        this.Maincursor.loadGraphic(Paths.image("charSelect/charSelector"));

        this.cursorBlue = new FlxSprite(0, 0);
        this.cursorBlue.loadGraphic(Paths.image("charSelect/charSelector"));
        this.cursorBlue.color = FlxColor.fromInt(0xFF3E3FFF); // Light blue color

        this.cursorDarkBlue = new FlxSprite(0, 0);
        this.cursorDarkBlue.loadGraphic(Paths.image("charSelect/charSelector"));
        this.cursorDarkBlue.color = FlxColor.fromInt(0xFF3C3D87); // Dark blue color

        this.cursorBlue.blend = BlendMode.ADD;
        this.cursorDarkBlue.blend = BlendMode.ADD;

        this.cursorConfirmed = new FlxSprite(0, 0);
        this.cursorConfirmed.frames = Paths.getSparrowAtlas("charSelect/charSelectorConfirm");
        this.cursorConfirmed.animation.addByPrefix("idle", "cursor ACCEPTED instance 1", 24, true);
        this.cursorConfirmed.visible = false;

        this.cursorDenied = new FlxSprite(0, 0);
        this.cursorDenied.frames = Paths.getSparrowAtlas("charSelect/charSelectorDenied");
        this.cursorDenied.animation.addByPrefix("idle", "cursor DENIED instance 1", 24, false);
        this.cursorDenied.visible = false;

        this.grpCursors.add(this.cursorDarkBlue);
        this.grpCursors.add(this.cursorBlue);
        this.grpCursors.add(this.Maincursor);
        this.add(this.cursorConfirmed);
        this.add(this.cursorDenied);

        cursorPosition = new FlxPoint(0, 0);
        
        this.initLocks();
        this.updateCursorPosition();
    }

    private function preloadCharacters() {
        var charactersToPreload = ["bf", "pico", "locked"];
        var gfsToPreload = ["gf", "nene"];

        for (char in charactersToPreload) {
            var player = new CharSelectPlayer(0, 0);
            player.switchChar(char);
            player.visible = false;
            preloadedCharacters.set(char, player);
            add(player);
        }

        for (gf in gfsToPreload) {
            var gfChar = new CharSelectGF(0, 0);
            gfChar.switchChar(gf);
            gfChar.visible = false;
            preloadedGFs.set(gf, gfChar);
            add(gfChar);
        }
    }

    override public function update(elapsed:Float) {
        if (FlxG.keys.justPressed.LEFT) moveCursor(-1, 0);
        if (FlxG.keys.justPressed.RIGHT) moveCursor(1, 0);
        if (FlxG.keys.justPressed.UP) moveCursor(0, -1);
        if (FlxG.keys.justPressed.DOWN) moveCursor(0, 1);

        if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT || 
            FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN) {
            updateCursorPosition();
        }

        super.update(elapsed);
    }

    private function initLocks():Void
    {
        availableChars = [
            0 => "null",
            1 => "null",
            2 => "null",
            3 => "pico",
            4 => "bf",
            5 => "null",
            6 => "null",
            7 => "null",
            8 => "null"
        ];

        grpIcons = new FlxTypedGroup<FlxSprite>();
        add(grpIcons);

        for (i in 0...9) {
            if (availableChars.exists(i) && availableChars[i] != "null") {
                var path = availableChars[i];
                var icon = new PixelatedIcon(0, 0);
                icon.setCharacter(path);
                icon.setGraphicSize(128, 128);
                icon.updateHitbox();
                icon.ID = 0;
                grpIcons.add(icon);
                nonLocks.push(i);
            } else {
                var colorIndex = Math.floor((i / (9 - 1)) * (colors.length - 1));
                var lock = new Lock(0, 0, colorIndex);
                lock.ID = i; 
                grpIcons.add(lock);
            }
        }

        updateIconPositions();
    }

    public function updateIconPositions()
    {
        var startX:Float = 450;
        var startY:Float = 120;
        var xSpread:Float = 107;
        var ySpread:Float = 127;
        var iconsPerRow:Int = 3;

        for (i in 0...this.grpIcons.members.length)
        {
            var member = this.grpIcons.members[i];
            var posX = i % iconsPerRow;
            var posY = Math.floor(i / iconsPerRow);
            
            member.x = startX + (posX * xSpread);
            member.y = startY + (posY * ySpread);
        }
    }

    private function moveCursor(dx:Int, dy:Int) {
        var rows = 3;
        var cols = 3;
        var currentRow = Math.floor(cursorIndex / cols);
        var currentCol = cursorIndex % cols;

        // Move horizontally
        currentCol += dx;
        if (currentCol < 0) currentCol = cols - 1;
        if (currentCol >= cols) currentCol = 0;

        // Move vertically
        currentRow += dy;
        if (currentRow < 0) currentRow = rows - 1;
        if (currentRow >= rows) currentRow = 0;

        // Calculate new index
        cursorIndex = (currentRow * cols) + currentCol;

        // Ensure cursorIndex is within bounds
        cursorIndex = Std.int(Math.max(0, Math.min(cursorIndex, grpIcons.length - 1)));
    }

    private function updateCursorPosition() {
        if (grpIcons != null && grpIcons.members.length > cursorIndex) {
            var icon = grpIcons.members[cursorIndex];
            cursorPosition.set(icon.x, icon.y);
            
            if (Maincursor != null) Maincursor.setPosition(cursorPosition.x, cursorPosition.y);
            if (cursorBlue != null) cursorBlue.setPosition(cursorPosition.x, cursorPosition.y);
            if (cursorDarkBlue != null) cursorDarkBlue.setPosition(cursorPosition.x, cursorPosition.y);
            if (cursorConfirmed != null) cursorConfirmed.setPosition(cursorPosition.x, cursorPosition.y);
            if (cursorDenied != null) cursorDenied.setPosition(cursorPosition.x, cursorPosition.y);

            // Update character display based on hovered icon
            updateCharacterDisplay();
        }
    }

    private function updateCharacterDisplay() {
        if (isAnimating) return;

        if (availableChars.exists(cursorIndex)) {
            var hoveredChar = availableChars[cursorIndex];
            var newPlayerChar:String = "bf";
            var newGFChar:String = "gf";

            switch (hoveredChar) {
                case "pico":
                    lockedChar.visible = false;
                    newPlayerChar = "pico";
                    newGFChar = "nene";
                    nametag.switchChar("pico");
                case "bf":
                    lockedChar.visible = false;
                    newPlayerChar = "bf";
                    newGFChar = "gf";
                    nametag.switchChar("bf");
                default:
                    newPlayerChar = "locked";
                    nametag.switchChar("locked");
                    newGFChar = "";
            }

            if (newPlayerChar != currentPlayerChar || newGFChar != currentGFChar) {
                isAnimating = true;
                slideOutCharacters(function() {
                    switchToPreloadedCharacters(newPlayerChar, newGFChar);
                    slideInCharacters(function() {
                        currentPlayerChar = newPlayerChar;
                        currentGFChar = newGFChar;
                        isAnimating = false;
                    });
                });
            }
        }
    }

    private function switchToPreloadedCharacters(newPlayerChar:String, newGFChar:String) {
        for (char in preloadedCharacters.iterator()) {
            char.visible = false;
        }
        for (gf in preloadedGFs.iterator()) {
            gf.visible = false;
        }
    
        if (preloadedCharacters.exists(newPlayerChar)) {
            remove(playerChill);
            playerChill = preloadedCharacters.get(newPlayerChar);
            playerChill.visible = true;
            playerChill.setPosition(0, 0);
            add(playerChill);
        } else {
            trace('Error: Character ${newPlayerChar} not found in preloaded characters.');
        }
    
        if (preloadedGFs.exists(newGFChar)) {
            remove(gfChill);
            gfChill = preloadedGFs.get(newGFChar);
            gfChill.visible = true;
            gfChill.setPosition(0, 0);
            add(gfChill);
        } else if (newGFChar != "") {
            trace('Error: GF ${newGFChar} not found in preloaded characters.');
        }
    
        var visibleCount = 0;
        for (char in preloadedCharacters.iterator()) {
            if (char.visible) visibleCount++;
        }
        if (visibleCount > 1) {
            trace('Error: Multiple player characters visible. Forcing only ${newPlayerChar} to be visible.');
            for (char in preloadedCharacters.iterator()) {
                char.visible = (char == playerChill);
            }
        }
    }

    private function slideOutCharacters(onComplete:Void->Void) {
        playerChill.playAnimation("slideout", true, false, false);
        var slideOutListener = null;
        slideOutListener = function(name:String) {
            if (name == "slideout") {
                playerChill.onAnimationFinish.remove(slideOutListener);
                if (onComplete != null) onComplete();
            }
        };
        playerChill.onAnimationFinish.add(slideOutListener);
    }

    private function slideInCharacters(onComplete:Void->Void) {
        playerChill.playAnimation("slidein", true, false, false);
        var slideInListener = null;
        slideInListener = function(name:String) {
            if (name == "slidein") {
                playerChill.onAnimationFinish.remove(slideInListener);
                playerChill.playAnimation("idle", true, false, true);
                if (onComplete != null) onComplete();
            }
        };
        playerChill.onAnimationFinish.add(slideInListener);
    }
}