module interfaces.thinker;

import fuji.vector;

interface ISheeple
{
	enum Moves
	{
		None	= 0,
		Run		= 0x1,
	}

	void OnMove(MFVector direction);

	@property bool CanMove();

	@property bool IsRunning();
}

interface IThinker
{
	bool OnAssign(ISheeple sheeple);
	void OnThink();

	@property bool Valid();
}
