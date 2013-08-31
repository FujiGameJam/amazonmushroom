module config;

struct Config
{
	enum MushroomType
	{
		Plain,
	}


	struct Mushroom
	{
		string modelName;
		MushroomType type;
		float toxicity;
	}

	static Mushroom[] mushroomType = [
		{ modelName: "mushroom.x", type: MushroomType.Plain, toxicity: 1, },
		{ modelName: "cockshroom.x", type: MushroomType.Plain, toxicity: 10, },
		{ modelName: "skullshroom.x", type: MushroomType.Plain, toxicity: 50, },
		{ modelName: "monkeyshroom.x", type: MushroomType.Plain, toxicity: 100, },
		//{ modelName: "cockshroom.x", type: MushroomType.Plain, toxicity: 10, },
	];
}