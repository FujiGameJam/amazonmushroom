module thinkers.autoplayer;

import std.random;

import entity.mushroom;

import interfaces.thinker;
import interfaces.collider;

import fuji.vector;
import fuji.input;

import states.ingamestate;

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
		bool moving = false;

		if (sheeple.CanMove)
		{
			moving = false;

			ICollider collider = cast(ICollider)sheeple;
			if (collider !is null)
			{
				Mushroom m = InGameState.Instance.GetClosestMushroom(collider.CollisionPosition());

				direction = m.CollisionPosition() - collider.CollisionPosition();

				direction = direction.normalise();

				moving = true;
			}

			if (!moving)
			{
				direction.x += uniform(-0.2, 0.2);
				direction.z += uniform(-0.2, 0.2);

				direction = direction.normalise();

				moving = true;
			}
		}

		if (moving)
			sheeple.OnMove(direction);

	}

	override @property bool Valid() { return true; }

	private ISheeple sheeple;
	private int playerIndex;
}
