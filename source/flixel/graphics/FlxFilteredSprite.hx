package flixel.graphics;

import Math;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import openfl.filters.BitmapFilter;
import flixel.math.FlxMatrix;
import flixel.graphics.FlxAnimateFilterRenderer;
import openfl.geom.Rectangle;
import flixel.FlxCamera;
import flixel.math.FlxAngle;

class FlxFilteredSprite extends FlxSprite
{
    public var filterDirty:Bool;
    public var _renderer:FlxAnimateFilterRenderer;
    public var _filterMatrix:FlxMatrix;
    public var filtered:Bool;
    
    public var _blankFrame:FlxFrame;
    public var _filterBmp1:openfl.display.BitmapData;
    public var _filterBmp2:openfl.display.BitmapData;
    
    public var filters(default, set):Array<BitmapFilter>;

    public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:Dynamic)
    {
        super(X, Y, SimpleGraphic);
        filterDirty = false;
        _renderer = new FlxAnimateFilterRenderer();
        _filterMatrix = new FlxMatrix();
        filtered = false;
        filters = null;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (!filterDirty && filters != null) {
            for (filter in filters) {
                filterDirty = true;
                break;
            }
        }
    }

    override public function draw():Void
    {
        checkEmptyFrame();
        if (alpha == 0 || _frame.type == FlxFrameType.EMPTY) {
            return;
        }
        if (dirty) {
            calcFrame(useFramePixels);
        }
        
        for (camera in cameras) {
            if (!camera.visible || !camera.exists || !isOnScreen(camera)) {
                continue;
            }
            
            getScreenPosition(_point, camera).subtract(offset.x, offset.y);
            
            if (isSimpleRender(camera)) {
                drawSimple(camera);
            } else {
                drawComplex(camera);
            }
        }
    }

    override function set_frame(value:FlxFrame):FlxFrame
    {
        if (value != frame) {
            filterDirty = true;
        }
        return super.set_frame(value);
    }

    override public function destroy():Void
    {
        super.destroy();
        _renderer = null;
        _filterMatrix = null;
        _blankFrame = null;
        if (_filterBmp1 != null) {
            _filterBmp1.dispose();
            _filterBmp1 = null;
        }
        if (_filterBmp2 != null) {
            _filterBmp2.dispose();
            _filterBmp2 = null;
        }
        filters = null;
    }

    function set_filters(value:Array<BitmapFilter>):Array<BitmapFilter>
    {
        if (filters != value) {
            filterDirty = true;
        }
        return filters = value;
    }

    override function drawComplex(camera:FlxCamera):Void
    {
        _frame.prepareMatrix(_matrix, 0, checkFlipX(), checkFlipY());
        _matrix.concat(_filterMatrix);
        _matrix.translate(-origin.x, -origin.y);
        _matrix.scale(scale.x, scale.y);

        if (bakedRotationAngle <= 0) {
            updateTrig();
            if (angle != 0) {
                _matrix.rotateWithTrig(_cosAngle, _sinAngle);
            }
        }

        _point.add(origin.x, origin.y);
        _matrix.translate(_point.x, _point.y);

        if (isPixelPerfectRender(camera)) {
            _matrix.tx = Math.floor(_matrix.tx);
            _matrix.ty = Math.floor(_matrix.ty);
        }

        camera.drawPixels(filtered ? _blankFrame : _frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
    }

    // Remove these methods as they're already defined in FlxSprite
    // inline function checkFlipX():Bool
    // inline function checkFlipY():Bool
    // inline function updateTrig():Void
}