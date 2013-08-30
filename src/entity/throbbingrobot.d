module entity.throbbingrobot;

import interfaces.thinker;
import interfaces.entity;
import interfaces.renderable;
import interfaces.collider;

class ThrobbingRobot : ISheeple, IEntity, IRenderable, ICollider
{
	///ISheeple
	override void OnMove(MFVector direction)
	{
	}

	override @property bool CanMove()		{ return true; }
	override @property bool IsRunning()		{ return false; }

	///IEntity
	void OnCreate(ElementParser element)
	{
	}

	void OnResolve(IEntity[string] loadedEntities)
	{
	}

	void OnReset()
	{
	}
	
	void OnDestroy()
	{
	}

	// Do movement and other type logic in this one
	void OnUpdate()
	{
	}

	// Need to resolve post-movement collisions, such as punching someone? Here's the place to do it.
	void OnPostUpdate()
	{
	}

	@property bool CanUpdate()					{ return true; }
	@property MFMatrix Transform()				{ return MFMatrix.identity; }
	@property MFMatrix Transform(MFMatrix t)	{ return MFMatrix.identity; }
	@property string Name()						{ return "Holy crap it's a throbbing robot!!!"; }

	///IRenderable
	void OnRenderWorld()
	{
	}

	void OnRenderGUI(MFRect orthoRect)
	{
	}

	@property bool CanRenderWorld()		{ return true; }
	@property bool CanRenderGUI()		{ return true; }

	///ICollider
	void OnAddCollision(CollisionManager owner)
	{
	}

	@property MFVector CollisionPosition()					{ return MFVector.zero; }
	@property MFVector CollisionPosition(MFVector pos)		{ return MFVector.zero; }

	@property MFVector CollisionPrevPosition()				{ return MFVector.zero; }

	@property CollisionType CollisionTypeEnum()				{ return CollisionType.Sphere; }
	@property CollisionClass CollisionClassEnum()			{ return CollisionClass.Robot; }
	@property MFVector CollisionParameters()				{ return MFVector.zero; }

}
