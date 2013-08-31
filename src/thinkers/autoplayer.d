module thinkers.autoplayer;

import std.random;

import interfaces.thinker;

import fuji.vector;
import fuji.input;

class AutoPlayer : IThinker
{
	MFVector direction;

	this(int index)
	{
		playerIndex = index;
		sheeple = null;
	}

	override bool OnAssign(ISheeple sheepWantsToFollow)
	{
		sheeple = sheepWantsToFollow;

		return Valid;
	}

	override void OnThink()
	{
		bool	moving = false;

		if (sheeple.CanMove)
		{
			direction.x += uniform(-1.0, 1.0);
			direction.z += uniform(-1.0, 1.0);

			direction = direction.normalise();

			moving = true;
		}

		if (moving)
			sheeple.OnMove(direction);

	}

	override @property bool Valid() { return true; }

	private ISheeple sheeple;
	private int playerIndex;
}
