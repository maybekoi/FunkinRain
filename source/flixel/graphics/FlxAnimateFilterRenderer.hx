package flixel.graphics;

import flixel.FlxG;
import openfl.display.DisplayObjectRenderer;
import openfl.geom.Matrix;
import openfl.geom.ColorTransform;

class FlxAnimateFilterRenderer
{
    public var renderer:DisplayObjectRenderer;
    public var worldTransform:Matrix;
    public var worldColorTransform:ColorTransform;

    public function new()
    {
        worldTransform = new Matrix();
        worldColorTransform = new ColorTransform();
    }

    public function setRenderer(newRenderer:DisplayObjectRenderer):Void
    {
        renderer = newRenderer;
    }

    public function updateTransforms(matrix:Matrix, colorTransform:ColorTransform):Void
    {
        worldTransform.copyFrom(matrix);
        
        // Manually copy ColorTransform properties
        worldColorTransform.redMultiplier = colorTransform.redMultiplier;
        worldColorTransform.greenMultiplier = colorTransform.greenMultiplier;
        worldColorTransform.blueMultiplier = colorTransform.blueMultiplier;
        worldColorTransform.alphaMultiplier = colorTransform.alphaMultiplier;
        worldColorTransform.redOffset = colorTransform.redOffset;
        worldColorTransform.greenOffset = colorTransform.greenOffset;
        worldColorTransform.blueOffset = colorTransform.blueOffset;
        worldColorTransform.alphaOffset = colorTransform.alphaOffset;
    }
}