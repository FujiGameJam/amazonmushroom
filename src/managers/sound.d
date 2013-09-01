module managers.sound;

import fuji.sound;

import config;

import std.string;

class SoundManager
{
	enum globalConfig = Config.globalSounds;
	enum playersConfig = Config.playerSounds;


	class PlayerSounds
	{
		MFSound*[5] snormal; 
		MFSound*[5] snew;
		MFSound* win;
	}

	PlayerSounds[string] sounds;

	void Init()
	{
		foreach(x; playersConfig)
		{
			PlayerSounds sounds = new PlayerSounds();
			foreach (i, normal; x.snormal)
			{
				sounds.snormal[i] = MFSound_Create(normal.toStringz());
			}
			foreach (i, neww; x.snew)
			{
				sounds.snew[i] = MFSound_Create(neww.toStringz());
			}

			sounds.win = MFSound_Create(x.win.toStringz());
		}
	}

	void OnUpdate()
	{
		if (winningNationality != winningNationalityPrev)
		{
			MFSound_Stop(pCurrentVoice);

			//pCurrentVoice = MFSound_Play(pSound, 0);
		}
	}

	MFVoice* pCurrentVoice = null;

	string winningNationalityPrev = "";

	string winningNationality = "fin";

	int level = 0;
}
