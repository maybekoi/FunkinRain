package rain.game;

typedef Song =
{
	var song:String;
	var notes:Array<Section>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;

	var stage:String;

	var gf:String;

	var gfVersion:String;
	var player3:String;
}