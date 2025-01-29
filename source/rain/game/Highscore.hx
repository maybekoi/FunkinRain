package rain.game;

import flixel.FlxG;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	public static var songAccuracies:Map<String, Float> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songAccuracies:Map<String, Float> = new Map<String, Float>();
	#end

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, accuracy:Float = 0, isVSlice:Bool = false):Void
	{
		var daSong:String = formatSong(song, diff, isVSlice);

		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
			{
				setScore(daSong, score);
			}
		}
		else
		{
			setScore(daSong, score);
		}
		
		if (!songAccuracies.exists(daSong) || songAccuracies.get(daSong) < accuracy)
		{
			setAccuracy(daSong, accuracy);
		}
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0, accuracy:Float = 0, isVSlice:Bool = false):Void
	{
		var daWeek:String = formatSong('week' + week, diff, isVSlice);

		if (songScores.exists(daWeek))
		{
			if (songScores.get(daWeek) < score)
				setScore(daWeek, score);
		}
		else
			setScore(daWeek, score);
	}

	static function setScore(song:String, score:Int):Void
	{
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	static function setAccuracy(song:String, accuracy:Float):Void
	{
		songAccuracies.set(song, accuracy);
		FlxG.save.data.songAccuracies = songAccuracies;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int, isVSlice:Bool = false):String
	{
		var daSong:String = song.toLowerCase();

		if (isVSlice)
		{
			return daSong;
		}
		else
		{
			if (diff == 0)
				daSong += '-easy';
			else if (diff == 2)
				daSong += '-hard';
		}

		return daSong;
	}

	public static function getScore(song:String, diff:Int, isVSlice:Bool = false):Int
	{
		var formattedSong = formatSong(song, diff, isVSlice);
		if (!songScores.exists(formattedSong))
			setScore(formattedSong, 0);
		return songScores.get(formattedSong);
	}

	public static function getAccuracy(song:String, diff:Int, isVSlice:Bool = false):Float
	{
		var formattedSong = formatSong(song, diff, isVSlice);
		if (!songAccuracies.exists(formattedSong))
			setAccuracy(formattedSong, 0);
		return songAccuracies.get(formattedSong);
	}

	public static function getWeekScore(week:Int, diff:Int, isVSlice:Bool = false):Int
	{
		if (!songScores.exists(formatSong('week' + week, diff, isVSlice)))
			setScore(formatSong('week' + week, diff, isVSlice), 0);

		return songScores.get(formatSong('week' + week, diff, isVSlice));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
		if (FlxG.save.data.songAccuracies != null)
		{
			songAccuracies = FlxG.save.data.songAccuracies;
		}
		FlxG.save.flush();
	}
}