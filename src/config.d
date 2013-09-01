module config;

struct Config
{
	enum MushroomType
	{
		Plain,
	}

	struct Robot
	{
		string modelName;
		string nationality;
	}

	struct Mushroom
	{
		string modelName;
		MushroomType type;
		float toxicity;
	}

	struct GlobalSounds
	{
		string denied;
		string domination;
		string firstShroom;
		string headshot;
		string rampage;
		string ready;
		string spree;
	}

	struct PlayerSounds
	{
		string nationality;
		string[5] snormal; 
		string[5] snew;
		string win;
	}

	static Mushroom[] mushroomType = [
		{ modelName: "mushroom.x", type: MushroomType.Plain, toxicity: 1, },
		{ modelName: "cockshroom.x", type: MushroomType.Plain, toxicity: 10, },
		{ modelName: "skullshroom.x", type: MushroomType.Plain, toxicity: 50, },
		{ modelName: "monkeyshroom.x", type: MushroomType.Plain, toxicity: 100, },
		//{ modelName: "cockshroom.x", type: MushroomType.Plain, toxicity: 10, },
	];


	static Robot[] robotType = [
		{ modelName: "mushroom.x", nationality: "fin", },
		{ modelName: "mushroom.x", nationality: "mex", },
		{ modelName: "mushroom.x", nationality: "rus", },
		{ modelName: "mushroom.x", nationality: "sic", },
	];

	static GlobalSounds globalSounds = {
		begin: "begin.ogg",
		denied: "denied.ogg",
		domination: "domination.ogg",
		firstShroom: "first_shroom.ogg",
		headshot: "headshot.ogg",
		rampage: "mush_rampage.ogg",
		ready: "ready.ogg",
		spree: "trip_spree.ogg",
	};

	static PlayerSounds[4] playerSounds = [
		{
			nationality: "fin",
			snormal: { "fin1.ogg", "fin2.ogg", "fin3.ogg", "fin4.ogg", "fin5.ogg", },
			snew: { "fin1.ogg", "fin2.ogg", "fin3.ogg", "fin4.ogg", "fin5.ogg", },
			win: "fin_wins.ogg",
		},
			{
			nationality: "mex",
			snormal: { "mex1.ogg", "mex2.ogg", "mex3.ogg", "mex4.ogg", "mex5.ogg", },
			snew: { "mex1.ogg", "mex2.ogg", "mex3.ogg", "mex4.ogg", "mex5.ogg", },
			win: "mex_wins.ogg",
		},
			{
			nationality: "rus",
			snormal: { "rus1.ogg", "rus2.ogg", "rus3.ogg", "rus4.ogg", "rus5.ogg", },
			snew: { "rus1.ogg", "rus2.ogg", "rus3.ogg", "rus4.ogg", "rus5.ogg", },
			win: "rus_wins.ogg",
		},
			{
			nationality: "sic",
			snormal: { "sic1.ogg", "sic2.ogg", "sic3.ogg", "sic4.ogg", "sic5.ogg", },
			snew: { "sic1.ogg", "sic2.ogg", "sic3.ogg", "sic4.ogg", "sic5.ogg", },
			win: "sic_wins.ogg",
		},
	];
}