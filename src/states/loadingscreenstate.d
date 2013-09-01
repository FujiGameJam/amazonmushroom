module states.loadingscreenstate;

import interfaces.statemachine;
import interfaces.renderable;

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

class LoadingScreenState : IState, IRenderable
{
	void OnAdd(StateMachine statemachine)
	{
		owner = statemachine;
	}

	void OnEnter()
	{
		chinese = MFFont_Create("ChineseRocks");
		mattDamon = MFMaterial_Create("MattDamon");
		dattMamon = MFSound_Create("datt_mamon");

		halfMessageWidth = MFFont_GetStringWidth(chinese, message, messageHeight, 0, -1, null) * 0.5;

		elapsedTime = 0;

		MFSound_Play(dattMamon, 0);
	}

	void OnExit()
	{
		MFSound_Destroy(dattMamon);

		MFFont_Destroy(chinese);
		chinese = null;

		MFMaterial_Release(mattDamon);
		mattDamon = null;
	}

	void OnUpdate()
	{
		elapsedTime += MFSystem_GetTimeDelta();

		if (elapsedTime > 0.5)
		{
			owner.SwitchState("InGame");
		}
	}

	@property StateMachine Owner() { return owner; }

	///IRenderable
	void OnRenderWorld()
	{
		MFRenderer_ClearScreen(MFRenderClearFlags.All, MFVector.black, cast(float)1.0, 0);

		MFView_Push();
		{
			float x = MFDeg2Rad!60;
			MFView_ConfigureProjection(x, 0.01, 100000);
			// TODO: Nasty singletonses
			float ratio = Game.Instance.mfInitParams.display.displayRect.width / Game.Instance.mfInitParams.display.displayRect.height;
			MFView_SetAspectRatio(ratio);
			MFView_SetProjection();

			MFView_SetCameraMatrix(MFMatrix.identity);

			MFMaterial_SetMaterial(mattDamon);

			MFPrimitive(PrimType.TriStrip | PrimType.Prelit, 0);
			MFBegin(4);
			{
				MFSetTexCoord1(0, 1);
				MFSetPosition(-1, -1, ratio);

				MFSetTexCoord1(0, 0);
				MFSetPosition(-1, 1, ratio);

				MFSetTexCoord1(1, 1);
				MFSetPosition(1, -1, ratio);

				MFSetTexCoord1(1, 0);
				MFSetPosition(1, 1, ratio);
			}
			MFEnd();

		}
		MFView_Pop();

	}

	void OnRenderGUI(MFRect orthoRect)
	{
		MFFont_DrawText2f(chinese, orthoRect.width * 0.5 - halfMessageWidth - 1, 600, messageHeight, MFVector.white, message);
	}

	@property bool CanRenderWorld() { return true; }
	@property bool CanRenderGUI() { return true; }


private:
	StateMachine owner;

	MFMaterial* mattDamon;
	float elapsedTime;
	MFFont* chinese;
	MFSound* dattMamon;

	float halfMessageWidth;

	static const(char*) message = "Powered by MATT DAMON!";
	static const(float) messageHeight = 45;
}