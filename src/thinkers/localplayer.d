module thinkers.localplayer;

import interfaces.thinker;

import fuji.vector;
import fuji.input;

class LocalPlayer : IThinker
{
	this(int index)
	{
		playerIndex = index;
		sheeple = null;
		joypadDeviceID = -1;
		keyboardDeviceID = -1;
	}

	enum KeyMoves
	{
		Up,
		Down,
		Left,
		Right,

		// TODO: Replace these with whatever's needed
		Light,
		Heavy,
		Special,
		Block,
	}

	immutable MFKey[KeyMoves.max + 1][4] playerKeyboardMappings =
	[
		[ MFKey.W, MFKey.S, MFKey.A, MFKey.D, MFKey.G, MFKey.H, MFKey.J, MFKey.Y ],
		[ MFKey.Up, MFKey.Down, MFKey.Left, MFKey.Right, MFKey.NumPad4, MFKey.NumPad5, MFKey.NumPad6, MFKey.NumPad8 ],
		[ MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None ],
		[ MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None ]
	];

	bool OnAssign(ISheeple sheepWantsToFollow)
	{
		if (padsClaimed[playerIndex] is null && MFInput_IsReady(MFInputDevice.Gamepad, playerIndex))
		{
			padsClaimed[playerIndex] = this;
			joypadDeviceID = playerIndex;
		}
		else
		{
			foreach (devID; 0 .. padsClaimed.length)
			{
				if (padsClaimed[devID] is null && MFInput_IsReady(MFInputDevice.Gamepad, playerIndex))
				{
					padsClaimed[devID] = this;
					joypadDeviceID = cast(int)devID;
					break;
				}
			}
		}

		if (!PadValid)
		{
			foreach(keyID; 0 .. keyboardsClaimed.length)
			{
				if (keyboardsClaimed[keyID] is null)
				{
					keyboardsClaimed[keyID] = this;
					keyboardDeviceID = cast(int)keyID;
					break;
				}
			}
		}

		if (PadValid || KeyboardValid)
		{
			sheeple = sheepWantsToFollow;
		}

		return Valid;
	}

	void OnThink()
	{
		bool	moving = false;

		MFVector direction;

		if (PadReady)
		{
			if (sheeple.CanMove)
			{
				direction.x = MFInput_Read(MFGamepadButton.Axis_LX, MFInputDevice.Gamepad, joypadDeviceID, null);
				direction.z = MFInput_Read(MFGamepadButton.Axis_LY, MFInputDevice.Gamepad, joypadDeviceID, null);

				moving = true;
			}

		}

		// Keyboard input
		if(KeyboardReady)
		{
			if (sheeple.CanMove)
			{
				float positiveX = MFInput_Read(playerKeyboardMappings[keyboardDeviceID][KeyMoves.Right], MFInputDevice.Keyboard, 0, null);
				float negativeX = MFInput_Read(playerKeyboardMappings[keyboardDeviceID][KeyMoves.Left], MFInputDevice.Keyboard, 0, null);

				float positiveZ = MFInput_Read(playerKeyboardMappings[keyboardDeviceID][KeyMoves.Up], MFInputDevice.Keyboard, 0, null);
				float negativeZ = MFInput_Read(playerKeyboardMappings[keyboardDeviceID][KeyMoves.Down], MFInputDevice.Keyboard, 0, null);

				direction.x = positiveX - negativeX;
				direction.z = positiveZ - negativeZ;

				direction.normalise();

				moving = true;
			}

		}

		if(moving)
			sheeple.OnMove(direction);

		if(MFInput_WasPressed(MFGamepadButton.PP_Cross, MFInputDevice.Gamepad, joypadDeviceID) > 0)
			sheeple.OnThrow();

		if(MFInput_WasPressed(MFGamepadButton.PP_Circle, MFInputDevice.Gamepad, joypadDeviceID) > 0)
			sheeple.OnIngest();
	}

	@property bool Valid() { return PadValid || KeyboardValid; }

	@property bool PadValid() { return joypadDeviceID != -1; }
	@property bool KeyboardValid() { return keyboardDeviceID != -1; }

	@property bool PadReady() { return PadValid && MFInput_IsReady(MFInputDevice.Gamepad, joypadDeviceID); }
	@property bool KeyboardReady() { return KeyboardValid; }

	private ISheeple sheeple;
	private int joypadDeviceID;
	private int keyboardDeviceID;
	private int playerIndex;

	private static IThinker[] padsClaimed = [ null, null, null, null ];
	private static IThinker[] keyboardsClaimed = [ null, null, null, null ];
}
