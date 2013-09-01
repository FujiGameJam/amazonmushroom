module renderer;

import fuji.render;
import fuji.vector;
import fuji.texture;
import fuji.material;
import std.string;

class Renderer
{
	this()
	{
		string[] layers = ["Background", "Player0", "Player1", "Player2", "Player3", "Composite", "UI"];

		MFRenderLayerDescription[] l = new MFRenderLayerDescription[layers.length];
		foreach(i; 0..layers.length)
			l[i].pName = layers[i].toStringz();

		pRenderer = MFRenderer_Create(l.ptr, cast(int)l.length, null, null);
		MFRenderer_SetCurrent(pRenderer);

		// background layer
		SetBackgroundLayer();

		MFVector clearColour = MFVector(0, 0, 0.2, 1);
		MFRenderLayer_SetClear(CurrentLayer(), MFRenderClearFlags.All, clearColour);

		// layer for each player
		foreach(i; 0..4)
		{
			SetPlayerLayer(i);

			// set render target
			string name = "Player" ~ std.conv.to!string(i);
			pRT[i] = MFTexture_CreateRenderTarget(name.ptr, 512, 512);
			MFRenderLayer_SetLayerRenderTarget(CurrentLayer, 0, pRT[i]);
			pRTMat[i] = MFMaterial_Create(name.ptr);

			MFRenderLayer_SetClear(CurrentLayer, MFRenderClearFlags.All, clearColour);
		}

		// background layer
		SetCompositeLayer();
		MFRenderLayer_SetClear(CurrentLayer(), MFRenderClearFlags.DepthStencil, clearColour, 1, 0);
	}

	~this()
	{
		MFRenderer_Destroy(pRenderer);
	}

	MFRenderLayer* Layer(size_t i)
	{
		return MFRenderer_GetLayer(pRenderer, cast(int)i);
	}

	MFRenderLayer* PlayerLayer(size_t i)
	{
		return MFRenderer_GetLayer(pRenderer, cast(int)i + 1);
	}

	@property MFRenderLayer* CurrentLayer()
	{
		return Layer(currentLayer);
	}

	void SetBackgroundLayer()
	{
		SetCurrentLayer(0);
	}

	void SetPlayerLayer(size_t player)
	{
		SetCurrentLayer(1 + player);
	}

	void SetCompositeLayer()
	{
		SetCurrentLayer(5);
	}

	void SetUILayer()
	{
		SetCurrentLayer(6);
	}

	void SetCurrentLayer(size_t i)
	{
		MFRenderLayerSet layerSet;
		layerSet.pSolidLayer = Layer(i);
		MFRenderer_SetRenderLayerSet(pRenderer, &layerSet);
		currentLayer = i;
	}

	MFMaterial* GetPlayerRT(size_t i)
	{
		return pRTMat[i];
	}

	@property static Renderer Instance() { if (instance is null) instance = new Renderer; return instance; }

private:
	private static Renderer instance;

	MFRenderer* pRenderer;
	size_t currentLayer;

	MFTexture*[4] pRT;
	MFMaterial*[4] pRTMat;
}
