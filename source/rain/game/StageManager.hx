package rain.game;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import hscript.Interp;
import hscript.Parser;
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
        var path = 'data/stages/$stageName.hscript';

        var scriptContent:String = null;
        if (PolymodAssets.exists(path))
        {
            scriptContent = PolymodAssets.getText(path);
        }
        else
        {
            var basePath = 'assets/$path';
            if (Assets.exists(basePath))
            {
                scriptContent = Assets.getText(basePath);
            }
        }

        if (scriptContent != null)
        {
            var parser = new Parser();
            var program = parser.parseString(scriptContent);

            var interp = new Interp();
            interp.execute(program);

            return {
                defaultCamZoom: interp.variables.get("defaultCamZoom"),
                assets: interp.variables.get("assets")
            };
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