package rain.charselect;

import backend.animate.FlxAtlasSprite;
import flixel.util.FlxColor;
import flxanimate.animate.FlxSymbol;

class Lock extends FlxAtlasSprite
{
    public var colors:Array<FlxColor>;

    public function new(x:Float = 0, y:Float = 0, index:Int = 0)
    {
        super(x, y, Paths.animateAtlas("charSelect/lock"));

        // Initialize colors array with cyan to blue gradient
        this.colors = [
            FlxColor.fromRGB(49, 229, 229),  // Light cyan
            FlxColor.fromRGB(32, 229, 237),  // Cyan
            FlxColor.fromRGB(32, 197, 244),  // Light blue
            FlxColor.fromRGB(32, 165, 250),  // Blue
            FlxColor.fromRGB(35, 101, 249),  // Darker blue
            FlxColor.fromRGB(36, 79, 249)    // Even darker blue
        ];

        // Ensure index is within bounds
        index = Std.int(Math.min(Math.max(index, 0), this.colors.length - 1));

        // Apply color to the entire sprite
        this.color = this.colors[index];

        this.playAnimation("idle");
    }
}