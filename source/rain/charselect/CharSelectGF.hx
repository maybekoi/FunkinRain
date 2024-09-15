package rain.charselect;

import backend.animate.FlxAtlasSprite;
import flixel.FlxG;
import sys.FileSystem;

class CharSelectGF extends FlxAtlasSprite {
    public function new(x:Float, y:Float) {
        var initialCharacter = "gf";
        var initialPath = getCharacterPath(initialCharacter);
        super(x, y, initialPath);
        
        if (!FileSystem.exists(initialPath + '/Animation.json')) {
            throw 'Initial character files not found at ${initialPath}';
        }
        
        loadCharacter(initialCharacter);
    }

    private function getCharacterPath(char:String):String {
        return 'assets/images/charSelect/${char}Chill';
    }

    public function loadCharacter(char:String) {
        var animatePath = getCharacterPath(char);
        if (FileSystem.exists(animatePath + '/Animation.json') && 
            FileSystem.exists(animatePath + '/spritemap1.json') && 
            FileSystem.exists(animatePath + '/spritemap1.png')) {
            
            this.loadAtlas(animatePath);
            this.antialiasing = true;
            
            var animations = this.listAnimations();
            trace('Available animations: ${animations}');
            
            if (this.hasAnimation("idle")) {
                this.playAnimation("idle", true, false, true);
                trace('Playing idle animation for ${char}');
            } else if (animations.length > 0) {
                this.playAnimation(animations[0], true, false, true);
                trace('Playing first available animation: ${animations[0]} for ${char}');
            } else {
                trace('Warning: No animations found for character ${char}');
            }
        } else {
            trace('Error: Animate files not found for character ${char} at path ${animatePath}');
        }
    }

    public function switchChar(str:String) {
        loadCharacter(str);
        updateHitbox();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}