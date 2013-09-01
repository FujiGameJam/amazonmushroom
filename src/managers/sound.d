module managers.sound;

import fuji.sound;

import config;

class SoundManager
{
	Config.GlobalSounds globalConfig;;
	Config.PlayerSounds[] playersConfig;

	this()
	{
		globalConfig = Config.globalSounds;
		playersConfig = Config.playerSounds;
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