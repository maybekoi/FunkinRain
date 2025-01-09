package rain.backend;

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
		var weekScripts:Array<String> = [];

		try
		{
			weekScripts = FileSystem.readDirectory("assets/data/weeks");
		}
		catch (e:Dynamic)
		{
			trace('Error reading weeks directory: $e');
			return [];
		}

		for (script in weekScripts)
		{
			if (StringTools.endsWith(script, ".hscript"))
			{
				var weekData = loadWeekScript(script);
				if (weekData != null)
				{
					weeks.push(weekData);
				}
			}
		}

		if (weeks.length == 0)
		{
			trace("No valid week scripts were found.");
		}

		return weeks;
	}

	private function loadWeekScript(scriptName:String):Dynamic
	{
		var scriptPath = "assets/data/weeks/" + scriptName;
		var scriptContent = "";

		try
		{
			scriptContent = File.getContent(scriptPath);
		}
		catch (e:Dynamic)
		{
			trace('Error reading script file $scriptName: $e');
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

			if (songs == null)
				trace('Script $scriptName is missing "songs" variable.');
			if (weekCharacters == null)
				trace('Script $scriptName is missing "weekCharacters" variable.');
			if (weekName == null)
				trace('Script $scriptName is missing "weekName" variable.');

			if (songs == null || weekCharacters == null || weekName == null)
			{
				return null;
			}

			return {
				songs: songs,
				weekCharacters: weekCharacters,
				weekName: weekName,
				weekFile: scriptName,
				weekFileName: scriptName.substr(0, scriptName.length - 8)
			};
		}
		catch (e:Dynamic)
		{
			trace('Error executing week script $scriptName: $e');
			return null;
		}
	}
}