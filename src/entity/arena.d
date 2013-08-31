module entity.arena;

import interfaces.thinker;
import interfaces.entity;
import interfaces.renderable;
import interfaces.collider;

import camera.camera;

import fuji.model;
import fuji.render;
import fuji.view;
import fuji.primitive;

class Arena : IEntity, IRenderable
{
	struct ObjectState
	{
		MFMatrix		transform;
	}

	private ObjectState			currentState,
								initialState;

//	private MFModel*			pModel;

	///IEntity
	override void OnCreate(ElementParser element)
	{
//		pModel = MFModel_Create("astro");
	}

	override void OnResolve(IEntity[string] loadedEntities)
	{
	}

	override void OnReset()
	{
		currentState = initialState;
//		UpdateCamera();
	}
	
	override void OnDestroy()
	{
//		MFModel_Destroy(pModel);
	}

	// Do movement and other type logic in this one
	override void OnUpdate()
	{
//		UpdateCamera();
	}

	// Need to resolve post-movement collisions, such as punching someone? Here's the place to do it.
	override void OnPostUpdate()
	{
//		MFModel_SetWorldMatrix(pModel, currentState.transform);
	}

	override @property bool CanUpdate()					{ return true; }
	override @property MFMatrix Transform()				{ return currentState.transform; }
	override @property MFMatrix Transform(MFMatrix t)	{ currentState.transform = t; return t; }
	override @property string Name()					{ return "arena"; } // TODO: This is rather hacky - the entity creator expects the name to be player<X> with <X> being the correct number

	///IRenderable
	override void OnRenderWorld()
	{
		MFPrimitive(PrimType.TriList);
		MFBegin(4);

		MFSetPosition(-100, -10, 100);
		MFSetPosition(100, -10, 100);
		MFSetPosition(-100, -10, -100);
		MFSetPosition(100, -10, -100);

		MFEnd();

//		MFRenderer_AddModel(pModel, null, MFView_GetViewState());
	}

	override void OnRenderGUI(MFRect orthoRect)
	{
	}

	override @property bool CanRenderWorld()		{ return true; }
	override @property bool CanRenderGUI()		{ return false; }

	// Robot specific stuff
	void UpdateCamera()
	{
//		camera.Position = MFVector(0.0, 0.5, -100.5);
	}
}
