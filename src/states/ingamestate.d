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
import fuji.renderstate;

import entity.throbbingrobot;
import entity.mushroom;
import entity.arena;

import std.string;
import std.conv;
import std.random;

class InGameState : IState, IRenderable
{
	///IState
	void OnAdd(StateMachine statemachine)
	{
		owner = statemachine;
	}

	void OnEnter()
	{
		const int numMushrooms = 20;

		collision = new CollisionManager;
		collision.PlaneDimensions = Arena.bounds;

		ThrobbingRobot robot = CreateEntity!ThrobbingRobot();
		ThrobbingRobot robot2 = CreateEntity!ThrobbingRobot();

		// IEntity robot = CreateEntity("ThrobbingRobot");
		arena = CreateEntity!Arena();

		for (int i = 0; i <= numMushrooms; i++)
		{
			MFVector pos = getEmptyLocation();
			if ((pos - MFVector(0,0,0,1)).mag3 < 0.01)  // if it's essentially the same vector, ie: the getEmptyLocation failed
			{
				continue; // don't spawn
			}

			auto newMushroom = CreateEntity!Mushroom();
			newMushroom.SetInitialPos(pos);
		}

		resetEvent();
	}

	MFVector getEmptyLocation()
	{
		const float spacing = 10.0;
		
		MFVector retvect = MFVector(0,0,0,1.0);

		bool success = false;
		int loop = 0;

		while (!success)
		{
			++loop;
			retvect.x = uniform(0.0, arena.bounds.x);
			retvect.z = uniform(0.0, arena.bounds.z);
			/*
			string debugline = "bounds: "~to!string(arena.bounds.x)~","~to!string(arena.bounds.y)~","~to!string(arena.bounds.z)~","~to!string(arena.bounds.w);
			MFDebug_Message(debugline.toStringz);
			debugline = "retvect: "~to!string(retvect.x)~","~to!string(retvect.y)~","~to!string(retvect.z)~","~to!string(retvect.w);
			MFDebug_Message(debugline.toStringz);
			*/

			success = true;

			// check against mushroom positions
			foreach (i, mushroom; mushrooms)
			{
				auto temp = (retvect - mushroom.CollisionPosition).mag3;
				if (temp < spacing)
				{
					success = false;
					break;
				}
			}

			// check against player positions
			if (success)
			{
				foreach (i, robot; robots)
				{
					auto temp = (retvect - robot.CollisionPosition).mag3;
					if (temp < spacing)
					{
						success = false;
						break;
					}
				}
			}

			if (loop > 1000)
			{
				return MFVector(0,0,0,1); // returns (0,0,0,1) -- can test for this and abort the move/spawn/whatever
			}
			
		}

		return retvect;
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
		foreach(index, robot; robots)
		{
			Renderer.Instance.SetPlayerLayer(index);

			MFView_Push();
			{
				MFView_SetAspectRatio(1);
				MFView_SetProjection();

				foreach(i; 0..3)
				{
					foreach(j; 0..3)
					{
						MFVector offset = MFVector((i - 1) * arena.bounds.x, 0, (j - 1) * arena.bounds.z);
						robot.TrailingCamera.Apply(offset);

						renderWorldEvent();
					}
				}
			}
			MFView_Pop();
		}
	}

	void ComposeScene()
	{
		Renderer.Instance.SetCompositeLayer();

		MFView_Push();
		MFRect rect = MFRect(0, 0, 1280, 720);
		auto width = 1280 / 2;
		auto height = 720 / 2;
		MFView_SetOrtho(&rect);
		{
			foreach(i, robot; robots)
			{
				MFMaterial_SetMaterial(Renderer.Instance.GetPlayerRT(i));
				MFPrimitive_DrawQuad((i&1) * width, (i>>1) * height, width, height);
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
			if (cast(Mushroom) entity !is null)
			{
				AddMushroom(cast(Mushroom) entity);
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

	void AddMushroom(Mushroom mushroom)
	{
		mushrooms ~= mushroom;
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
	private Mushroom[] mushrooms;
	private Arena arena;
}
