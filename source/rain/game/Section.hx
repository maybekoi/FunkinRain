package rain.game;

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var sectionBeats:Float;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Int;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class Section
{
	public var sectionNotes:Array<Dynamic> = [];

	public var lengthInSteps:Int = 16;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;
	public var sectionBeats:Float = 4;

	public static var COPYCAT:Int = 0;

	public function new(lengthInSteps:Int = 16, sectionBeats:Float = 4)
	{
		this.lengthInSteps = lengthInSteps;
		this.sectionBeats = sectionBeats;
	}
}
