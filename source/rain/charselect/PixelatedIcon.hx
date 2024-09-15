package rain.charselect;

import openfl.utils.Assets;
import flixel.graphics.FlxFilteredSprite;

class PixelatedIcon extends FlxFilteredSprite
{
    public function new(x:Float, y:Float)
    {
        super(x, y);
        makeGraphic(32, 32, 0);
        antialiasing = false;
        active = false;
    }

    public function setCharacter(char:String):Void
    {
        var charPath = "freeplay/icons/";
        charPath += switch (char) {
            case "bf-car" | "bf-christmas" | "bf-holding-gf" | "bf-pixel": "bfpixel";
            case "dad": "dadpixel";
            case "darnell-blazin": "darnellpixel";
            case "gf-car" | "gf-christmas" | "gf-pixel" | "gf-tankmen": "gfpixel";
            case "mom" | "mom-car": "mommypixel";
            case "monster-christmas": "monsterpixel";
            case "pico-blazin" | "pico-playable" | "pico-speaker": "picopixel";
            case "senpai-angry": "senpaipixel";
            case "spooky-dark": "spookypixel";
            case "tankman-atlas": "tankmanpixel";
            default: char + "pixel";
        };

        if (!Assets.exists(Paths.image(charPath))) {
            trace('[WARN] Character $char has no freeplay icon.', {
                fileName: "source/rain/charselect/PixelatedIcon.hx",
                lineNumber: 31,
                className: "rain.charselect.PixelatedIcon",
                methodName: "setCharacter"
            });
            return;
        }

        var isAnimated = Assets.exists(Paths.file('images/$charPath.xml'));
        if (isAnimated) {
            frames = Paths.getSparrowAtlas(charPath);
        } else {
            loadGraphic(Paths.image(charPath));
        }

        scale.set(2, 2);
        origin.x = (char == "parents-christmas") ? 140 : 100;

        if (isAnimated) {
            active = true;
            animation.addByPrefix("idle", "idle0", 10, true);
            animation.addByPrefix("confirm", "confirm0", 10, false);
            animation.addByPrefix("confirm-hold", "confirm-hold0", 10, true);
            animation.finishCallback = name -> {
                if (name == "confirm") {
                    animation.play("confirm-hold");
                }
            };
            animation.play("idle");
        }
    }
}