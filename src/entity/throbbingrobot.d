module entity.throbbingrobot;

import interfaces.thinker;
import interfaces.entity;
import interfaces.renderable;
import interfaces.collider;

import camera.camera;

import fuji.model;
import fuji.render;
import fuji.view;

class ThrobbingRobot : ISheeple, IEntity, IRenderable, ICollider
{
	struct ObjectState
	{
		MFMatrix		transform;
		MFMatrix		prevTransform;

		ISheeple.Moves	activeMoves = ISheeple.Moves.None;
	}

	private	Camera				camera = new Camera();
	private ObjectState			currentState,
								initialState;

	private CollisionManager	collision = null;

	private MFModel*			pModel;

	@property Camera TrailingCamera()		{ return camera; }

	///ISheeple
	override void OnMove(MFVector direction)
	{
		currentState.prevTransform = currentState.transform;
		currentState.transform.t += direction;
	}

	override @property bool CanMove()		{ return true; }
	override @property bool IsRunning()		{ return (currentState.activeMoves & ISheeple.Moves.Run) != 0; }

	///IEntity
	override void OnCreate(ElementParser element)
	{
		pModel = MFModel_Create("astro");
	}

	override void OnResolve(IEntity[string] loadedEntities)
	{
	}

	override void OnReset()
	{
		currentState = initialState;
		UpdateCamera();
	}
	
	override void OnDestroy()
	{
		MFModel_Destroy(pModel);
	}

	// Do movement and other type logic in this one
	override void OnUpdate()
	{
		UpdateCamera();
	}

	// Need to resolve post-movement collisions, such as punching someone? Here's the place to do it.
	override void OnPostUpdate()
	{
		MFModel_SetWorldMatrix(pModel, currentState.transform);
	}

	override @property bool CanUpdate()					{ return true; }
	override @property MFMatrix Transform()				{ return currentState.transform; }
	override @property MFMatrix Transform(MFMatrix t)	{ currentState.transform = t; return t; }
	override @property string Name()					{ return "player1"; } // TODO: This is rather hacky - the entity creator expects the name to be player<X> with <X> being the correct number

	///IRenderable
	override void OnRenderWorld()
	{
		MFRenderer_AddModel(pModel, null, MFView_GetViewState());
	}

	override void OnRenderGUI(MFRect orthoRect)
	{
	}

	override @property bool CanRenderWorld()		{ return true; }
	override @property bool CanRenderGUI()		{ return false; }

	///ICollider
	override void OnAddCollision(CollisionManager owner)
	{
		collision = owner;
	}

	override @property MFVector CollisionPosition()					{ return MFVector.zero; }
	override @property MFVector CollisionPosition(MFVector pos)		{ return MFVector.zero; }

	override @property MFVector CollisionPrevPosition()				{ return MFVector.zero; }

	override @property CollisionType CollisionTypeEnum()			{ return CollisionType.Sphere; }
	override @property CollisionClass CollisionClassEnum()			{ return CollisionClass.Robot; }
	override @property MFVector CollisionParameters()				{ return MFVector.zero; }

	// Robot specific stuff
	void UpdateCamera()
	{
		camera.Position = MFVector(0.0, 0.5, -100.5);
	}
}
