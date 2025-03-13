package rain.game;

import hscript.Interp;
import hscript.Parser;
import sys.FileSystem;
import sys.io.File;

class WeekHandler
{
	private var parser:Parser;
	private var interp:Interp;

	public function new()
	{
		parser = new Parser();
		interp = new Interp();
	}

	public function loadWeeks():Array<Dynamic>
	{
		var weeks:Array<Dynamic> = [];
		var weekPaths:Array<String> = ["assets/data/weeks"];

		if (FileSystem.exists("mods"))
		{
			try
			{
				var mods = FileSystem.readDirectory("mods");
				for (mod in mods)
				{
					var modWeekPath = 'mods/$mod/data/weeks';
					if (FileSystem.exists(modWeekPath) && FileSystem.isDirectory(modWeekPath))
					{
						weekPaths.push(modWeekPath);
					}
				}
			}
			catch (e:Dynamic)
			{
				trace('Error reading mods directory: $e');
			}
		}

		for (weekPath in weekPaths)
		{
			try
			{
				var weekScripts = FileSystem.readDirectory(weekPath);
				for (script in weekScripts)
				{
					if (StringTools.endsWith(script, ".hscript"))
					{
						var weekData = loadWeekScript('$weekPath/$script');
						if (weekData != null)
						{
							weeks.push(weekData);
						}
					}
				}
			}
			catch (e:Dynamic)
			{
				trace('Error reading weeks from $weekPath: $e');
			}
		}

		if (weeks.length == 0)
		{
			trace("No valid week scripts were found.");
		}

		return weeks;
	}

	private function loadWeekScript(scriptPath:String):Dynamic
	{
		var scriptContent = "";

		try
		{
			scriptContent = File.getContent(scriptPath);
		}
		catch (e:Dynamic)
		{
			trace('Error reading script file $scriptPath: $e');
			return null;
		}

		try
		{
			var program = parser.parseString(scriptContent);
			interp.variables.clear();
			interp.variables.set("Paths", Paths);
			interp.execute(program);

			var songs = interp.variables.get("songs");
			var weekCharacters = interp.variables.get("weekCharacters");
			var weekName = interp.variables.get("weekName");
			var stage = interp.variables.get("stage");
			var difficulties = interp.variables.get("difficulties");

			if (songs == null)
				trace('Script $scriptPath is missing "songs" variable.');
			if (weekCharacters == null)
				trace('Script $scriptPath is missing "weekCharacters" variable.');
			if (weekName == null)
				trace('Script $scriptPath is missing "weekName" variable.');
			if (stage == null)
				trace('Script $scriptPath is missing "stage" variable.');

			if (songs == null || weekCharacters == null || weekName == null || stage == null)
			{
				return null;
			}

			if (difficulties == null)
			{
				difficulties = ["easy", "normal", "hard"];
			}

			var lastSlash = scriptPath.lastIndexOf("/");
			var fileName = scriptPath.substr(lastSlash + 1);
			var weekFileName = fileName.substr(0, fileName.length - 8);

			return {
				songs: songs,
				weekCharacters: weekCharacters,
				weekName: weekName,
				weekFile: scriptPath,
				weekFileName: weekFileName,
				stage: stage,
				difficulties: difficulties
			};
		}
		catch (e:Dynamic)
		{
			trace('Error executing week script $scriptPath: $e');
			return null;
		}
	}
}
