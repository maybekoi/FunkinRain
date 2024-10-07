package rain.game;

enum Modes
{
	STORYMODE;
	FREEPLAY;
	CHARTING;
}

class SongData
{
	public static var currentSong:Dynamic = null;
	public static var currentDifficulty:String = null;
	public static var gameMode:Modes;
	public static var opponent:String = null;
	public static var currentWeek:StoryWeekData = null;
	public static var weekSongIndex:Int = 0;
}
