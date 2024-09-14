package rain.game;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.Json;
import openfl.utils.Assets;
import polymod.Polymod;
import polymod.backends.PolymodAssets;
import polymod.fs.SysFileSystem;

class StageManager
{
    public static function loadStage(stageName:String, parent:FlxTypedGroup<FlxSprite>):Void
    {
        var stageData:StageData = loadStageData(stageName);
        if (stageData == null) return;

        for (asset in stageData.assets)
        {
            var sprite = new FlxSprite(asset.x, asset.y).loadGraphic(asset.path);
            sprite.antialiasing = asset.antialiasing;
            sprite.scrollFactor.set(asset.scrollFactorX, asset.scrollFactorY);
            sprite.active = asset.active;
            if (asset.scale != null)
            {
                sprite.setGraphicSize(Std.int(sprite.width * asset.scale));
                sprite.updateHitbox();
            }
            parent.add(sprite);
        }
    }

    private static function loadStageData(stageName:String):StageData
    {
        var path = 'data/stages/$stageName.json';

        if (PolymodAssets.exists(path))
        {
            var jsonContent = PolymodAssets.getText(path);
            return Json.parse(jsonContent);
        }
        else
        {
            var basePath = 'assets/$path';
            if (Assets.exists(basePath))
            {
                var jsonContent = Assets.getText(basePath);
                return Json.parse(jsonContent);
            }
        }

        return null;
    }
}

typedef StageData = {
    var ?defaultCamZoom:Float;
    var assets:Array<StageAsset>;
}

typedef StageAsset = {
    var path:String;
    var x:Float;
    var y:Float;
    var antialiasing:Bool;
    var scrollFactorX:Float;
    var scrollFactorY:Float;
    var active:Bool;
    @:optional var scale:Null<Float>;
}