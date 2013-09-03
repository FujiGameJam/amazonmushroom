module thinkers.nullthinker;

public import interfaces.thinker;

class NullThinker : IThinker
{
	override bool OnAssign(ISheeple sheeple) { return false; }
	override void OnThink() { }

	override @property bool Valid() { return false; }
	override @property ISheeple Sheeple() { return null; }
}

