module states.ingamestate;

import interfaces.statemachine;
import interfaces.renderable;
import interfaces.entity;
import interfaces.collider;
import interfaces.thinker;

import util.eventtypes;

import thinkers.localplayer;
import thinkers.nullthinker;

import game;
import renderer;

import fuji.render;
import fuji.material;
import fuji.primitive;
import fuji.view;
import fuji.matrix;
import fuji.system;
import fuji.font;
import fuji.sound;

import entity.throbbingrobot;

import std.string;
import std.conv;

class InGameState : IState, IRenderable
{
	///IState
	void OnAdd(StateMachine statemachine)
	{
		owner = statemachine;
	}

	void OnEnter()
	{
		collision = new CollisionManager;
		collision.PlaneDimensions = MFVector(32.0, 10.0, 32.0);

		ThrobbingRobot robot = CreateEntity!ThrobbingRobot();
		ThrobbingRobot robot2 = CreateEntity!ThrobbingRobot();

		// IEntity robot = CreateEntity("ThrobbingRobot");

		resetEvent();
	}

	void OnExit()
	{
	}

	void OnUpdate()
	{
		thinkEvent();
		updateEvent();
		collision.OnUpdate();
		postUpdateEvent();
	}

	@property StateMachine Owner() { return owner; }
	private StateMachine owner;

	void RenderBackground()
	{
		Renderer.Instance.SetBackgroundLayer();

		//...
	}

	void RenderPlayers()
	{
		foreach(i, robot; robots)
		{
			Renderer.Instance.SetPlayerLayer(i);

			MFView_Push();
			{
				// TODO: Jam a viewport in to the robot, set that, then Camera.Apply();
				robot.TrailingCamera.Apply();

				renderWorldEvent();
				// TODO: Reset the viewport here
			}
			MFView_Pop();

			// TODO: Remove once viewports are implemented
			break;
		}
	}

	void ComposeScene()
	{
		Renderer.Instance.SetCompositeLayer();

		MFView_Push();
		MFRect rect = MFRect(0, 0, 1280, 720);
		MFView_SetOrtho(&rect);
		{
			foreach(i, robot; robots)
			{
				MFMaterial_SetMaterial(Renderer.Instance.GetPlayerRT(i));
				MFPrimitive_DrawQuad((i&1) * 300, (i>>1) * 300, 300, 300);
			}
		}
		MFView_Pop();
	}

	///IRenderable
	void OnRenderWorld()
	{
		RenderBackground();
		RenderPlayers();
		ComposeScene();
	}

	void OnRenderGUI(MFRect orthoRect)
	{
		Renderer.Instance.SetUILayer();
		
		renderGUIEvent(orthoRect);
	}

	@property bool CanRenderWorld() { return true; }
	@property bool CanRenderGUI() { return true; }

	// InGameState specific stuff
	T CreateEntity(T = IEntity)(string type = T.stringof, ElementParser parser = null)
	{
		string objectName = "entity." ~ toLower(type) ~ "." ~ type;
		Object entity = Object.factory(objectName);

		if (entity !is null)
		{
			IEntity actualEntity = cast(IEntity) entity;

			if (actualEntity !is null)
			{
				actualEntity.OnCreate(parser);
				AddEntity(actualEntity);
			}
			if (cast(IRenderable) entity !is null)
			{
				AddRenderable(cast(IRenderable) entity);
			}
			if (cast(ThrobbingRobot) entity !is null)
			{
				AddThrobbingRobot(cast(ThrobbingRobot) entity);
			}
			if (cast(ICollider) entity !is null)
			{
				AddCollider(cast(ICollider) entity);
			}

			return cast(T) entity;
		}

		return null;
	}

	void AddEntity(IEntity entity)
	{
		resolveEvent.subscribe(&entity.OnResolve);
		resetEvent.subscribe(&entity.OnReset);

		if (entity.CanUpdate)
		{
			updateEvent.subscribe(&entity.OnUpdate);
			postUpdateEvent.subscribe(&entity.OnPostUpdate);
		}

		entities[entity.Name] = entity;
	}

	void AddRenderable(IRenderable renderable)
	{
		if (renderable.CanRenderWorld)
			renderWorldEvent.subscribe(&renderable.OnRenderWorld);
		if (renderable.CanRenderGUI)
			renderGUIEvent.subscribe(&renderable.OnRenderGUI);
	}

	void AddThrobbingRobot(ThrobbingRobot robot)
	{
		IThinker thinker;

		if (toLower(robot.Name[0 .. 6]) == "player")
		{
			char indexString = robot.Name[6];

			int index = to!int(indexString - 0x31);
			thinker = new LocalPlayer(index);
		}
		else
		{
			thinker = new NullThinker;
		}

		if (thinker.OnAssign(robot))
		{
			thinkEvent.subscribe(&thinker.OnThink);
		}

		thinkers ~= thinker;
		robots ~= robot;
	}

	void AddCollider(ICollider collider)
	{
		colliders ~= collider;
		collision.AddCollider(collider);
	}

	private CollisionManager collision;

	private IEntityMapEvent resolveEvent;

	private VoidEvent resetEvent;

	private VoidEvent thinkEvent;
	private VoidEvent updateEvent;
	private VoidEvent postUpdateEvent;

	private VoidEvent renderWorldEvent;
	private MFRectEvent renderGUIEvent;

	private VoidEvent roundBeginEvent;
	private VoidEvent roundEndEvent;

	private IEntity[string] entities;
	private IThinker[] thinkers;
	private ICollider[] colliders;
	private ThrobbingRobot[] robots;
}
