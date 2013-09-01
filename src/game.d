module game;

import fuji.fuji;
import fuji.system;
import fuji.filesystem;
import fuji.fs.native;

import fuji.render;
import fuji.material;
import fuji.primitive;
import fuji.view;
import fuji.matrix;

import interfaces.statemachine;

import states.loadingscreenstate;
import states.ingamestate;

import renderer;

class Game
{
	MFSystemCallbackFunction pInitFujiFS = null;

	MFRenderer *pRenderer = null;

	this()
	{
		instance = this;
		state = new StateMachine;
	}

	void InitFileSystem()
	{
		// mount the sample assets directory
		MFFileSystemHandle hNative = MFFileSystem_GetInternalFileSystemHandle(MFFileSystemHandles.NativeFileSystem);
		MFMountDataNative mountData;
		mountData.flags = MFMountFlags.FlattenDirectoryStructure | MFMountFlags.Recursive;
		mountData.pMountpoint = "game".ptr;
		mountData.pPath = MFFile_SystemPath("data/");
		MFFileSystem_Mount(hNative, mountData);

		if(pInitFujiFS)
			pInitFujiFS();
	}

	void Init()
	{
		Renderer.Instance();
/*
		// create the renderer with a single layer that clears before rendering
		MFRenderLayerDescription[] layers = [ MFRenderLayerDescription("Background".ptr), MFRenderLayerDescription("Player1".ptr), MFRenderLayerDescription("Player2".ptr), MFRenderLayerDescription("Player3".ptr), MFRenderLayerDescription("Player4".ptr), MFRenderLayerDescription("Composite".ptr), MFRenderLayerDescription("UI".ptr) ];
		pRenderer = MFRenderer_Create(layers.ptr, cast(int)layers.length, null, null);
		MFRenderer_SetCurrent(pRenderer);

		MFRenderLayer *pLayer = MFRenderer_GetLayer(pRenderer, 0);
		MFVector clearColour = MFVector(0, 0, 0.2, 1);
		MFRenderLayer_SetClear(pLayer, MFRenderClearFlags.All, clearColour);

		MFRenderLayerSet layerSet;
		layerSet.pSolidLayer = pLayer;
		MFRenderer_SetRenderLayerSet(pRenderer, &layerSet);
*/
		state.AddState("LoadingScreen", new LoadingScreenState());
		state.AddState("InGame", new InGameState());
		state.SwitchState("LoadingScreen");
	}

	void Deinit()
	{
		state.Shutdown();
//		MFRenderer_Destroy(pRenderer);
	}

	void Update()
	{
		state.Update();
	}

	void Draw()
	{
		state.Draw();
	}

	MFInitParams mfInitParams;

	private StateMachine state;

	///
	private static Game instance;

	@property static Game Instance() { if (instance is null) instance = new Game; return instance; }

	static void Static_InitFileSystem()
	{
		Instance.InitFileSystem();
	}

	static void Static_Init()
	{
		Instance.Init();
	}

	static void Static_Deinit()
	{
		Instance.Deinit();
		instance = null;
	}

	static void Static_Update()
	{
		Instance.Update();
	}

	static void Static_Draw()
	{
		Instance.Draw();
	}
}
