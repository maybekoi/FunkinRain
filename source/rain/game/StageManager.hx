package rain.game;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.Json;
import openfl.utils.Assets;

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
        var path = 'assets/data/stages/$stageName.json';
        if (!Assets.exists(path)) return null;

        var jsonContent = Assets.getText(path);
        return Json.parse(jsonContent);
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