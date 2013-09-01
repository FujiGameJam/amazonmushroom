module states.ingamestate;

import interfaces.statemachine;
import interfaces.renderable;
import interfaces.entity;
import interfaces.collider;
import interfaces.thinker;

import util.eventtypes;

import thinkers.localplayer;
import thinkers.autoplayer;
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

import config;

import std.string;
import std.conv;
import std.random;
import std.container;
import std.algorithm;

class InGameState : IState, IRenderable
{
	this()
	{
		instance = this;
	}

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
		ThrobbingRobot auto1 = CreateEntity!ThrobbingRobot();
		ThrobbingRobot auto2 = CreateEntity!ThrobbingRobot();

		// IEntity robot = CreateEntity("ThrobbingRobot");
		arena = CreateEntity!Arena();

		for (int i = 0; i <= numMushrooms; i++)
		{
			MFVector pos = getEmptyLocation();
			if ((pos - MFVector(0,0,0,1)).mag3() < 0.01)  // if it's essentially the same vector, ie: the getEmptyLocation failed
			{
				continue; // don't spawn
			}

			auto newMushroom = CreateEntity!Mushroom();
			newMushroom.SetInitialPos(pos);
			auto index = uniform(0, Config.mushroomType.length);
			newMushroom.SetConfig(Config.mushroomType[index]);
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
				auto temp = (retvect - mushroom.CollisionPosition).mag3();
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
					auto temp = (retvect - robot.CollisionPosition).mag3();
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
		MFRect rect = MFRect(-640, -360, 1280, 720);
		MFView_SetOrtho(&rect);
		{
			foreach(i, robot; robots)
				robot.RenderViewport(i);
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

	static InGameState instance;
	static @property InGameState Instance() { return instance; }

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

	void DestroyEntity(IEntity entity)
	{
		if (entity !is null)
		{
			IEntity actualEntity = cast(IEntity) entity;

			if (actualEntity !is null)
			{
				RemoveEntity(actualEntity);
			}
			if (cast(IRenderable) entity !is null)
			{
				RemoveRenderable(cast(IRenderable) entity);
			}
			if (cast(ThrobbingRobot) entity !is null)
			{
				RemoveThrobbingRobot(cast(ThrobbingRobot) entity);
			}
			if (cast(Mushroom) entity !is null)
			{
				RemoveMushroom(cast(Mushroom) entity);
			}
			if (cast(ICollider) entity !is null)
			{
				RemoveCollider(cast(ICollider) entity);
			}
		}
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
	}

	void RemoveEntity(IEntity entity)
	{
		resolveEvent.unsubscribe(&entity.OnResolve);
		resetEvent.unsubscribe(&entity.OnReset);

		if (entity.CanUpdate)
		{
			updateEvent.unsubscribe(&entity.OnUpdate);
			postUpdateEvent.unsubscribe(&entity.OnPostUpdate);
		}
	}

	void AddRenderable(IRenderable renderable)
	{
		if (renderable.CanRenderWorld)
			renderWorldEvent.subscribe(&renderable.OnRenderWorld);
		if (renderable.CanRenderGUI)
			renderGUIEvent.subscribe(&renderable.OnRenderGUI);
	}

	void RemoveRenderable(IRenderable renderable)
	{
		if (renderable.CanRenderWorld)
			renderWorldEvent.unsubscribe(&renderable.OnRenderWorld);
		if (renderable.CanRenderGUI)
			renderGUIEvent.unsubscribe(&renderable.OnRenderGUI);
	}

	void AddThrobbingRobot(ThrobbingRobot robot)
	{
		IThinker thinker;

		//if (toLower(robot.Name[0 .. 6]) == "player")
		if (robots.length < 2)
		{
			char indexString = robot.Name[6];

			int index = to!int(indexString - 0x31);
			thinker = new LocalPlayer(index);
		}
		else
		{
			thinker = new AutoPlayer(-1);
		}

		if (thinker.OnAssign(robot))
		{
			thinkEvent.subscribe(&thinker.OnThink);
		}

		thinkers ~= thinker;
		robots ~= robot;
	}

	void RemoveThrobbingRobot(ThrobbingRobot robot)
	{
		IThinker thinker = null;

		foreach(t; thinkers)
		{
			if (t.Sheeple == robot)
			{
				thinker = t;
				break;
			}
		}

		thinkEvent.unsubscribe(&thinker.OnThink);

		{
			int index = cast(int)countUntil(thinkers, thinker);
			if (index != -1)
				remove(thinkers, index);
		}
		{
			int index = cast(int)countUntil(robots, robot);
			if (index != -1)
				remove(robots, index);
		}
	}

	void AddMushroom(Mushroom mushroom)
	{
		mushrooms ~= mushroom;
	}

	void RemoveMushroom(Mushroom mushroom)
	{
		int index = cast(int)countUntil(mushrooms, mushroom);
		if (index != -1)
			remove(mushrooms, index);
	}

	void AddCollider(ICollider collider)
	{
		colliders ~= collider;
		collision.AddCollider(collider);
	}


	void RemoveCollider(ICollider collider)
	{
		int index = cast(int)countUntil(colliders, collider);
		if (index != -1)
			remove(colliders, index);

		collision.RemoveCollider(collider);
	}


	Mushroom GetClosestMushroom(MFVector pos)
	{
		Mushroom closest = null;

		float closestDistSqr = float.max;

		foreach(m; mushrooms)
		{
			if (!m.beingCarried)
			{
				if (closest is null)
				{
					closest = m;
				}
				else
				{
					float distSqr = distanceSq(m.CollisionPosition(), pos);
					if (distSqr < closestDistSqr)
					{
						closestDistSqr = distSqr;
						closest = m;
					}
				}
			}
		}

		return closest;
	}


	ThrobbingRobot GetClosestRobot(ThrobbingRobot robot)
	{
		ThrobbingRobot closest = null;

		float closestDistSqr = float.max;

		foreach(r; robots)
		{
			if (r != robot)
			{
				if (closest is null)
				{
					closest = r;
				}
				else
				{
					float distSqr = distanceSq(r.CollisionPosition(), robot.CollisionPosition());
					if (distSqr < closestDistSqr)
					{
						closestDistSqr = distSqr;
						closest = r;
					}
				}
			}
		}

		return closest;
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

	private IThinker[] thinkers;
	private ICollider[] colliders;
	private ThrobbingRobot[] robots;
	private Mushroom[] mushrooms;
	private Arena arena;
}
