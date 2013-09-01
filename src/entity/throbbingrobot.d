module entity.throbbingrobot;

import renderer;

import interfaces.thinker;
import interfaces.entity;
import interfaces.renderable;
import interfaces.collider;

import camera.camera;

import fuji.model;
import fuji.animation;
import fuji.render;
import fuji.view;
import fuji.system;
import fuji.material;
import fuji.primitive;

import entity.mushroom;

import states.ingamestate;

import game;

import std.random;
import std.conv;
import std.math;

class ThrobbingRobot : ISheeple, IEntity, IRenderable, ICollider
{
	struct Psych
	{
		float toxicity = 0;
		@property int Level() { return cast(int)toxicity; }

		float time = 0;
		float tempo = 1;
		float prestige = 1;
		float spin = 0;
		float sway = 0;
		float sheer = 0;
		float warp = 0;
		float wonkey = 0;
	}

	struct ObjectState
	{
		MFMatrix		transform		= MFMatrix.identity;
		MFMatrix		prevTransform	= MFMatrix.identity;

		ISheeple.Moves	activeMoves		= ISheeple.Moves.None;
	}

	private	Camera				camera = null;
	private MFVector			moveDirection;
	private MFVector			facingDirection;
	private MFVector			modelOffset = MFVector(0.0, 0.5, 0.0);

	private ObjectState			currentState,
								initialState;

	private CollisionManager	collision = null;

	private MFModel*			pModel;

	private string				name;

	Psych psych;

	Mushroom					carrying = null;

	void RenderViewport(size_t i)
	{
		MFVector[4] corners =
		[
			MFVector(-320, -180, 0, 0),
			MFVector(320, -180, 0, 0),
			MFVector(-320, 180, 0, 0),
			MFVector(320, 180, 0, 0)
		];

		float phase = (i * 2) * (3.14 / 2 / 5);

		MFVector pos = corners[i] / psych.prestige;
		pos.x += psych.sway * sin(phase + psych.time) + sin(psych.time * (1.0/7.0));
		pos.y += psych.sway * sin(phase + (psych.time + 0.5) * (1.0/3.0)) + sin(phase + psych.time * (1.0/11.0));

		MFVector[4] vp;
		vp[0] = pos + corners[0] * psych.prestige;
		vp[1] = pos + corners[1] * psych.prestige;
		vp[2] = pos + corners[2] * psych.prestige;
		vp[3] = pos + corners[3] * psych.prestige;

		vp[0].x += psych.wonkey * sin(phase + psych.time * 0.97);
		vp[0].y += psych.wonkey * sin(phase + psych.time * 0.86);
		vp[1].x += psych.wonkey * sin(phase + psych.time * 0.78);
		vp[1].y += psych.wonkey * sin(phase + psych.time * 0.58);
		vp[2].x += psych.wonkey * sin(phase + psych.time * 0.93);
		vp[2].y += psych.wonkey * sin(phase + psych.time * 0.77);
		vp[3].x += psych.wonkey * sin(phase + psych.time * 0.69);
		vp[3].y += psych.wonkey * sin(phase + psych.time * 1.17);

		MFVector _min = min(min(vp[0], vp[1]), min(vp[2], vp[3]));
		MFVector _max = max(max(vp[0], vp[1]), max(vp[2], vp[3]));
		MFVector mag = _max - _min;
		float aspect = (_max.y - _min.y) / (_max.x - _min.x);
		float yOffset = aspect * 0.5;

		MFVector[4] uv;
		uv[0] = (vp[0] - _min) / mag;
		uv[1] = (vp[1] - _min) / mag;
		uv[2] = (vp[2] - _min) / mag;
		uv[3] = (vp[3] - _min) / mag;

		float rot = psych.spin * sin(phase + psych.time);
		MFMatrix rm;
		rm.x = MFVector(cos(rot), sin(rot), 0, 0);
		rm.y = MFVector(-sin(rot), cos(rot), 0, 0);
		vp[0] = rm.mul(vp[0] - pos) + pos;
		vp[1] = rm.mul(vp[1] - pos) + pos;
		vp[2] = rm.mul(vp[2] - pos) + pos;
		vp[3] = rm.mul(vp[3] - pos) + pos;

		MFMaterial_SetMaterial(Renderer.Instance.GetPlayerRT(i));
		MFPrimitive(PrimType.TriStrip, 0);
		MFBegin(4);
		MFSetTexCoord1(uv[0].x, uv[0].y*(0.5 - yOffset));
		MFSetPosition(vp[0].x, vp[0].y, 0.5 + psych.prestige*0.3);
		MFSetTexCoord1(uv[1].x, uv[1].y*(0.5 - yOffset));
		MFSetPosition(vp[1].x, vp[1].y, 0.5 + psych.prestige*0.3);
		MFSetTexCoord1(uv[2].x, uv[2].y*(0.5 + yOffset));
		MFSetPosition(vp[2].x, vp[2].y, 0.5 + psych.prestige*0.3);
		MFSetTexCoord1(uv[3].x, uv[3].y*(0.5 + yOffset));
		MFSetPosition(vp[3].x, vp[3].y, 0.5 + psych.prestige*0.3);
		MFEnd();

		//MFPrimitive_DrawQuad((i&1) * width, (i>>1) * height, width, height);
	}

	final @property Camera TrailingCamera()	{ return camera; }

	static int currPlayer = 1;

	this()
	{
		camera = new Camera();
		name = "player" ~ to!string(currPlayer++);

		facingDirection = MFVector(0,0,1,0);
	}

	///ISheeple
	override void OnMove(MFVector direction)
	{
		if(direction != MFVector.zero)
			facingDirection = direction.normalise();
		moveDirection = direction;
	}

	override void OnThrow()
	{
		if(carrying !is null)
		{
			carrying.SetPos(currentState.transform.t + facingDirection*5);
			carrying.beingCarried = false;
			carrying = null;
		}
	}

	override void OnIngest()
	{
		if(carrying !is null)
		{
			// receive abilities!
			psych.toxicity += carrying.config.toxicity;
			psych.wonkey += 0.1;
			psych.sway += 0.5;
			psych.spin += 0.05;

			carrying.beingCarried = false;
			InGameState.Instance.DestroyEntity(carrying);
			carrying = null;
		}
	}

	override @property bool CanMove()		{ return true; }
	override @property bool IsRunning()		{ return (currentState.activeMoves & ISheeple.Moves.Run) != 0; }

	///IEntity
	override void OnCreate(ElementParser element)
	{
		pModel = MFModel_CreateWithAnimation("acidbot.x".ptr);

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
		psych.time += MFSystem_GetTimeDelta() * psych.tempo;

		currentState.prevTransform = currentState.transform;
		currentState.transform.t += (moveDirection * MovementSpeedThisFrame);

		// advance the animation
		MFAnimation *pAnim = MFModel_GetAnimation(pModel);
		if(pAnim)
		{
			float start, end;
			MFAnimation_GetFrameRange(pAnim, &start, &end);

			static float time = 0;
			time += MFSystem_GetTimeDelta();// * 500;
			while(time >= end)
				time -= end;
			MFAnimation_SetFrame(pAnim, time);
		}

//		psych.toxicity;

		if(carrying)
			carrying.SetPos(currentState.transform.t + MFVector(0, 2, 0, 0));
	}

	// Need to resolve post-movement collisions, such as punching someone? Here's the place to do it.
	override void OnPostUpdate()
	{
		UpdateCamera();

		MFMatrix modelTransform = MFMatrix.identity;
		modelTransform.x = facingDirection.cross3(MFVector.up) * ModelScale;
		modelTransform.y *= ModelScale;
		modelTransform.z = -facingDirection * ModelScale;
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
		{
			auto mush = cast(Mushroom)other;
			if(!carrying && !mush.beingCarried)
			{
				carrying = mush;
				mush.beingCarried = true;
//				psych.toxicity += mush.GetConfig.toxicity;
//				InGameState.Instance.DestroyEntity(mush);
			}
			return false;
		}
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

		transform.t = currentState.transform.t + MFVector(0, 12.0, -8.0);

		transform.z = normalise( currentState.transform.t - transform.t );
		transform.x = cross3( MFVector(0, 1, 0), transform.z );
		transform.y = cross3( transform.z, transform.x );
		camera.transform = transform;
	}

	final @property MovementSpeed()									{ return WalkSpeed; } // Update this when running is implemented
	final @property MovementSpeedThisFrame()						{ return MovementSpeed * MFSystem_GetTimeDelta(); }

	enum WalkSpeed = 4.0;
	enum RunSpeed = 11.0;

	enum ModelScale = 1.0 / 1.0; // To convert the model to meters, and then halve it
}
