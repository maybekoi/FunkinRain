package rain.charselect;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class Nametag extends FlxSprite
{
    public var midpointY:Float;
    public var midpointX:Float;

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);
        this.midpointY = 100;
        this.midpointX = 1008;
        
        switchChar("bf");
    }

    public function updatePosition()
    {
        var offsetX = this.getMidpoint().x - this.midpointX;
        var offsetY = this.getMidpoint().y - this.midpointY;
        this.x -= offsetX;
        this.y -= offsetY;
    }

    public function switchChar(str:String)
    {
        new FlxTimer().start(0.133333333333333331, function(_) {
            var path = (str == "bf") ? "boyfriend" : str;
            loadGraphic(Paths.image('charSelect/${path}Nametag'));
            updateHitbox();
            scale.set(0.77, 0.77);
            updatePosition();
        });
    }

    public function setBlockTimer(frame:Int, ?forceX:Float, ?forceY:Float)
    {
    }

    public function set_midpointX(val:Float):Float
    {
        midpointX = val;
        updatePosition();
        return val;
    }

    public function set_midpointY(val:Float):Float
    {
        midpointY = val;
        updatePosition();
        return val;
    }
}