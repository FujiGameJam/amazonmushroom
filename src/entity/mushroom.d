module entity.mushroom;

import interfaces.thinker;
import interfaces.entity;
import interfaces.renderable;
import interfaces.collider;

import camera.camera;

import fuji.model;
import fuji.render;
import fuji.view;
import fuji.system;

import config;

import std.random;
import std.conv;
import std.string;


class Mushroom : IEntity, IRenderable, ICollider
{
	struct ObjectState
	{
		MFMatrix		transform		= MFMatrix.identity;
		MFMatrix		prevTransform	= MFMatrix.identity;
	}

	private MFVector			moveDirection;
	private MFVector			facingDirection;

	private ObjectState			currentState,
		initialState;

	private CollisionManager	collision = null;

	private MFModel*			pModel;

	private Config.Mushroom		config;

	private string				name = "mushroom";

	bool						beingCarried = false;

	this()
	{
		facingDirection = MFVector(0,0,1,0);
	}

	///IEntity
	override void OnCreate(ElementParser element)
	{
		pModel = MFModel_Create("mushroom.x");
		initialState.transform.t.x = uniform(0.0, 8.0);
		initialState.transform.t.z = uniform(0.0, 8.0);
	}

	void SetInitialPos(MFVector v)
	{
		initialState.transform.t = v;
		SetPos(v);
	}

	void SetPos(MFVector v)
	{
		currentState.transform.t = v;
	}

	void SetConfig(Config.Mushroom conf)
	{
		config = conf;
		MFModel_Destroy(pModel);
		pModel = MFModel_Create(config.modelName.toStringz);
	}

	override void OnResolve(IEntity[string] loadedEntities)
	{
	}

	override void OnReset()
	{
		currentState = initialState;

		moveDirection = MFVector.zero;
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
		MFMatrix modelTransform = MFMatrix.identity;
		modelTransform.x = facingDirection * ModelScale;
		modelTransform.y *= ModelScale;
		modelTransform.z = facingDirection.cross3(MFVector.up) * ModelScale;
		modelTransform.t = currentState.transform.t;

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
		return true;
	}

	override @property MFVector CollisionPosition()					{ return currentState.transform.t; }
	override @property MFVector CollisionPosition(MFVector pos)		{ currentState.transform.t = pos; return pos; }

	override @property MFVector CollisionPrevPosition()				{ return currentState.prevTransform.t; }

	override @property CollisionType CollisionTypeEnum()			{ return CollisionType.Sphere; }
	override @property CollisionClass CollisionClassEnum()			{ return CollisionClass.Mushroom; }
	override @property MFVector CollisionParameters()				{ return MFVector(0.5, 0.0, 0.0, 0.0); }


	final @property MovementSpeed()									{ return WalkSpeed; } // Update this when running is implemented
	final @property MovementSpeedThisFrame()						{ return MovementSpeed * MFSystem_GetTimeDelta(); }


	final @property Config.Mushroom GetConfig()						{ return config; }

	enum WalkSpeed = 4.0;
	enum RunSpeed = 11.0;

	enum ModelScale = 1.0 / 1.0; // To convert the model to meters, and then halve it
}
