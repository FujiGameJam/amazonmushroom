module thinkers.nullthinker;

public import interfaces.thinker;

class NullThinker : IThinker
{
	bool OnAssign(ISheeple sheeple) { return false; }
	void OnThink() { }

	@property bool Valid() { return false; }
}

