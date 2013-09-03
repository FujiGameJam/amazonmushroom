module thinkers.autoplayer;

import std.random;

import entity.mushroom;
import entity.throbbingrobot;

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

			ThrobbingRobot robot = cast(ThrobbingRobot)sheeple;

			if (robot !is null)
			{
				if (robot.carrying is null)
				{
					Mushroom m = InGameState.Instance.GetClosestMushroom(robot.CollisionPosition());

					direction = m.CollisionPosition() - robot.CollisionPosition();
					direction.y = 0;
					direction = direction.normalise();
				}
				else
				{
					robot.OnIngest();

					direction = MFVector.init;
				}
				//else
				//{
				//    auto enemy = InGameState.Instance.GetClosestRobot(robot);
				//    direction = enemy.CollisionPosition() - robot.CollisionPosition();
				//}

				moving = true;
			}

			if (!moving)
			{
				direction.x += uniform(-0.2, 0.2);
				direction.z += uniform(-0.2, 0.2);
				direction.y = 0;

				direction = direction.normalise();

				moving = true;
			}
		}

		if (moving)
			sheeple.OnMove(direction);

	}

	override @property bool Valid() { return true; }
	override @property ISheeple Sheeple() { return sheeple; }

	private ISheeple sheeple;
	private int playerIndex;
}
