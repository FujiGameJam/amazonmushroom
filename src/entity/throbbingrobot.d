module entity.throbbingrobot;

import interfaces.thinker;
import interfaces.entity;
import interfaces.renderable;
import interfaces.collider;

import camera.camera;

import fuji.model;
import fuji.render;
import fuji.view;
import fuji.system;

import std.random;
import std.conv;

class ThrobbingRobot : ISheeple, IEntity, IRenderable, ICollider
{
	struct ObjectState
	{
		MFMatrix		transform		= MFMatrix.identity;
		MFMatrix		prevTransform	= MFMatrix.identity;

		ISheeple.Moves	activeMoves		= ISheeple.Moves.None;
	}

	private	Camera				camera = null;
	private MFVector			moveDirection;
	private MFVector			modelOffset = MFVector(0.0, 0.5, 0.0);

	private ObjectState			currentState,
								initialState;

	private CollisionManager	collision = null;

	private MFModel*			pModel;

	private string				name = "player1";

	final @property Camera TrailingCamera()	{ return camera; }

	static int currPlayer = 1;

	this()
	{
		camera = new Camera();
		name = "player" ~ to!string(currPlayer++);
	}

	///ISheeple
	override void OnMove(MFVector direction)
	{
		moveDirection = direction;
	}

	override @property bool CanMove()		{ return true; }
	override @property bool IsRunning()		{ return (currentState.activeMoves & ISheeple.Moves.Run) != 0; }

	///IEntity
	override void OnCreate(ElementParser element)
	{
		pModel = MFModel_Create("astro");

		initialState.transform.t.x = uniform(0.0, 8.0);
		initialState.transform.t.z = uniform(0.0, 8.0);
	}

	override void OnResolve(IEntity[string] loadedEntities)
	{
	}

	override void OnReset()
	{
		currentState = initialState;

		moveDirection = MFVector.zero;
		UpdateCamera();
	}
	
	override void OnDestroy()
	{
		MFModel_Destroy(pModel);
	}

	// Do movement and other type logic in this one
	override void OnUpdate()
	{
		currentState.prevTransform = currentState.transform;
		currentState.transform.t += (moveDirection * MovementSpeedThisFrame);
	}

	// Need to resolve post-movement collisions, such as punching someone? Here's the place to do it.
	override void OnPostUpdate()
	{
		UpdateCamera();

		MFMatrix modelTransform = MFMatrix.identity;
		modelTransform.x *= ModelScale;
		modelTransform.y *= ModelScale;
		modelTransform.z *= ModelScale;
		modelTransform.t = currentState.transform.t + modelOffset;

		MFModel_SetWorldMatrix(pModel, modelTransform);
	}

	override @property bool CanUpdate()					{ return true; }
	override @property MFMatrix Transform()				{ return currentState.transform; }
	override @property MFMatrix Transform(MFMatrix t)	{ currentState.transform = t; return t; }
	override @property string Name()					{ return name; } // TODO: This is rather hacky - the entity creator expects the name to be player<X> with <X> being the correct number

	///IRenderable
	override void OnRenderWorld()
	{
		MFRenderer_AddModel(pModel, null, MFView_GetViewState());
	}

	override void OnRenderGUI(MFRect orthoRect)
	{
	}

	override @property bool CanRenderWorld()		{ return true; }
	override @property bool CanRenderGUI()			{ return false; }

	///ICollider
	override void OnAddCollision(CollisionManager owner)
	{
		collision = owner;
	}

	override bool OnCollision(ICollider other)
	{
		switch (other.CollisionClassEnum())
		{
		case CollisionClass.Mushroom:
			// pickup?
			return false;
		//case CollisionClass.Obstacle:
		//    break;
		//case CollisionClass.Robot:
		//    break;
		default:
			return true;
		}
	}

	override @property MFVector CollisionPosition()					{ return currentState.transform.t; }
	override @property MFVector CollisionPosition(MFVector pos)		{ currentState.transform.t = pos; return pos; }

	override @property MFVector CollisionPrevPosition()				{ return currentState.prevTransform.t; }

	override @property CollisionType CollisionTypeEnum()			{ return CollisionType.Sphere; }
	override @property CollisionClass CollisionClassEnum()			{ return CollisionClass.Robot; }
	override @property MFVector CollisionParameters()				{ return MFVector(0.5, 0.0, 0.0, 0.0); }

	// Robot specific stuff
	void UpdateCamera()
	{
		MFMatrix transform;

		transform.t = currentState.transform.t + MFVector(1.5, 2.5, -5.5);

		transform.z = normalise( currentState.transform.t - transform.t );
		transform.x = cross3( MFVector(0, 1, 0), transform.z );
		transform.y = cross3( transform.z, transform.x );
		camera.transform = transform;
	}

	final @property MovementSpeed()									{ return WalkSpeed; } // Update this when running is implemented
	final @property MovementSpeedThisFrame()						{ return MovementSpeed * MFSystem_GetTimeDelta(); }

	enum WalkSpeed = 4.0;
	enum RunSpeed = 11.0;

	enum ModelScale = 1.0 / 20.0; // To convert the model to meters, and then halve it
}
