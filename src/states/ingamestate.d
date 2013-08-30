module states.ingamestate;

import interfaces.statemachine;
import interfaces.renderable;

import game;

import fuji.render;
import fuji.material;
import fuji.primitive;
import fuji.view;
import fuji.matrix;
import fuji.system;
import fuji.font;
import fuji.sound;

class InGameState : IState, IRenderable
{
	///IState
	void OnAdd(StateMachine statemachine)
	{
		owner = statemachine;
	}

	void OnEnter()
	{
	}

	void OnExit()
	{
	}

	void OnUpdate()
	{
	}

	@property StateMachine Owner() { return owner; }
	private StateMachine owner;

	///IRenderable
	void OnRenderWorld()
	{
		MFRenderer_ClearScreen(MFRenderClearFlags.All, MFVector.black, cast(float)1.0, 0);

	}

	void OnRenderGUI(MFRect orthoRect)
	{
	}

	@property bool CanRenderWorld() { return true; }
	@property bool CanRenderGUI() { return true; }

}
