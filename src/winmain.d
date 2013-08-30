module winmain;

import core.runtime;
import core.sys.windows.windows;
import std.stdio;
import fuji.fuji;
import fuji.system;
import fuji.model;
import fuji.render;
import fuji.view;
import fuji.display;
import fuji.filesystem;
import fuji.fs.native;

import game;

/**** Globals ****/
/*
MFSystemCallbackFunction pInitFujiFS = null;

MFRenderer *pRenderer = null;

MFModel *pModel;

void Game_InitFilesystem()
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

void Game_Init()
{
	// create the renderer with a single layer that clears before rendering
	MFRenderLayerDescription[] layers = [ MFRenderLayerDescription("Scene".ptr) ];
	pRenderer = MFRenderer_Create(layers.ptr, 1, null, null);
	MFRenderer_SetCurrent(pRenderer);

	MFRenderLayer *pLayer = MFRenderer_GetLayer(pRenderer, 0);
    MFVector clearColour = MFVector(0, 0, 0.2, 1);
	MFRenderLayer_SetClear(pLayer, MFRenderClearFlags.All, clearColour);

	MFRenderLayerSet layerSet;
	layerSet.pSolidLayer = pLayer;
	MFRenderer_SetRenderLayerSet(pRenderer, &layerSet);

	// load model
	pModel = MFModel_Create("astro");
//	MFDebug_Assert(pModel != null, "Couldn't load mesh!".ptr);
}

void Game_Update()
{
	// calculate a spinning world matrix
	MFMatrix world;
//	world.SetTranslation(MFVector(0, -5, 50));
    world.m[12..16] = [0, -5, 50, 1];

//	static float rotation = 0.0f;
//	rotation += MFSystem_TimeDelta();
//	world.RotateY(rotation);

	// set world matrix to the model
	MFModel_SetWorldMatrix(pModel, world);

	// advance the animation
/+
	MFAnimation *pAnim = MFModel_GetAnimation(pModel);
	if(pAnim)
	{
		float start, end;
		MFAnimation_GetFrameRange(pAnim, &start, &end);

		static float time = 0.f;
		time += MFSystem_TimeDelta();// * 500;
		while(time >= end)
			time -= end;
		MFAnimation_SetFrame(pAnim, time);
	}
+/
}

void Game_Draw()
{
	// set projection
	MFView_SetAspectRatio(MFDisplay_GetNativeAspectRatio());
	MFView_SetProjection();

	// render the mesh
	MFRenderer_AddModel(pModel, null, MFView_GetViewState());
}

void Game_Deinit()
{
	MFModel_Destroy(pModel);

	MFRenderer_Destroy(pRenderer);
}*/

int GameMain(ref MFInitParams initParams)
{
//	MFRand_Seed(cast(uint)(MFSystem_ReadRTC() & 0xFFFFFFFF));

	MFSystem_RegisterSystemCallback(MFCallback.InitDone, &Game.Static_Init);
	MFSystem_RegisterSystemCallback(MFCallback.Update, &Game.Static_Update);
	MFSystem_RegisterSystemCallback(MFCallback.Draw, &Game.Static_Draw);
	MFSystem_RegisterSystemCallback(MFCallback.Deinit, &Game.Static_Deinit);

	Game.Instance.pInitFujiFS = MFSystem_RegisterSystemCallback(MFCallback.FileSystemInit, &Game.Static_InitFileSystem);

	return MFMain(initParams);
}


extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    int result;

    void exceptionHandler(Throwable e)
    {
        throw e;
    }

    try
    {
        Runtime.initialize(&exceptionHandler);

        MFInitParams initParams;
	    initParams.hInstance = hInstance;
	    initParams.pCommandLine = lpCmdLine;

	    result = GameMain(initParams);

        Runtime.terminate(&exceptionHandler);
    }
    catch (Throwable o)		// catch any uncaught exceptions
    {
//        MessageBoxA(null, cast(char *)o.toString(), "Error", MB_OK | MB_ICONEXCLAMATION);
        result = 0;		// failed
    }

    return result;
}


/+


/**** Functions ****/

void Game_InitFilesystem()
{
	// mount the sample assets directory
	MFFileSystemHandle hNative = MFFileSystem_GetInternalFileSystemHandle(MFFSH_NativeFileSystem);
	MFMountDataNative mountData;
	mountData.cbSize = sizeof(MFMountDataNative);
	mountData.priority = MFMP_Normal;
	mountData.flags = MFMF_FlattenDirectoryStructure | MFMF_Recursive;
	mountData.pMountpoint = "game";
    #if defined(MF_IPHONE)
	mountData.pPath = MFFile_SystemPath();
    #else
	mountData.pPath = MFFile_SystemPath("data/");
    #endif
	MFFileSystem_Mount(hNative, &mountData);

	if(pInitFujiFS)
		pInitFujiFS();
}

void Game_Init()
{
	// create the renderer with a single layer that clears before rendering
	MFRenderLayerDescription layers[] = { { "Scene" } };
	pRenderer = MFRenderer_Create(layers, 1, NULL, NULL);
	MFRenderer_SetCurrent(pRenderer);

	MFRenderLayer *pLayer = MFRenderer_GetLayer(pRenderer, 0);
	MFRenderLayer_SetClear(pLayer, MFRCF_All, MakeVector(0.f, 0.f, 0.2f, 1.f));

	MFRenderLayerSet layerSet;
	MFZeroMemory(&layerSet, sizeof(layerSet));
	layerSet.pSolidLayer = pLayer;
	MFRenderer_SetRenderLayerSet(pRenderer, &layerSet);

	// load model
	pModel = MFModel_CreateWithAnimation("astro");
	MFDebug_Assert(pModel, "Couldn't load mesh!");
}

void Game_Update()
{
	// calculate a spinning world matrix
	MFMatrix world;
	world.SetTranslation(MakeVector(0, -5, 50));

	static float rotation = 0.0f;
	rotation += MFSystem_TimeDelta();
	world.RotateY(rotation);

	// set world matrix to the model
	MFModel_SetWorldMatrix(pModel, world);

	// advance the animation
	MFAnimation *pAnim = MFModel_GetAnimation(pModel);
	if(pAnim)
	{
		float start, end;
		MFAnimation_GetFrameRange(pAnim, &start, &end);

		static float time = 0.f;
		time += MFSystem_TimeDelta();// * 500;
		while(time >= end)
			time -= end;
		MFAnimation_SetFrame(pAnim, time);
	}
}

void Game_Draw()
{
	// set projection
	MFView_SetAspectRatio(MFDisplay_GetNativeAspectRatio());
	MFView_SetProjection();

	// render the mesh
	MFRenderer_AddModel(pModel, NULL, MFView_GetViewState());
}

void Game_Deinit()
{
	MFModel_Destroy(pModel);

	MFRenderer_Destroy(pRenderer);
}


int GameMain(MFInitParams *pInitParams)
{
	MFRand_Seed((uint32)(MFSystem_ReadRTC() & 0xFFFFFFFF));

	MFSystem_RegisterSystemCallback(MFCB_InitDone, Game_Init);
	MFSystem_RegisterSystemCallback(MFCB_Update, Game_Update);
	MFSystem_RegisterSystemCallback(MFCB_Draw, Game_Draw);
	MFSystem_RegisterSystemCallback(MFCB_Deinit, Game_Deinit);

	pInitFujiFS = MFSystem_RegisterSystemCallback(MFCB_FileSystemInit, Game_InitFilesystem);

	return MFMain(pInitParams);
}

#if defined(MF_WINDOWS)
#include <windows.h>

int __stdcall WinMain(HINSTANCE hInstance, HINSTANCE hPrev, LPSTR lpCmdLine, int nCmdShow)
{
	MFInitParams initParams;
	MFZeroMemory(&initParams, sizeof(MFInitParams));
	initParams.hInstance = hInstance;
	initParams.pCommandLine = lpCmdLine;

	return GameMain(&initParams);
}

#elif defined(MF_PSP)
#include <pspkernel.h>

int main(int argc, const char *argv[])
{
	MFInitParams initParams;
	MFZeroMemory(&initParams, sizeof(MFInitParams));
	initParams.argc = argc;
	initParams.argv = argv;

	int r = GameMain(&initParams);

	sceKernelExitGame();
	return r;
}

#else

int main(int argc, const char *argv[])
{
	MFInitParams initParams;
	MFZeroMemory(&initParams, sizeof(MFInitParams));
	initParams.argc = argc;
	initParams.argv = argv;

	return GameMain(&initParams);
}

#endif
+/