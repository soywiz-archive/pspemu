// dmd -run xinput.d
/*
For XBox Controller or PS3 controller using motioninjoy
http://www.motioninjoy.com/help/sixaxis-dualshock-3-connecting-usb
*/

import std.c.stdio;
import std.stdio;

import std.c.windows.windows;

extern (Windows) {
	/**
	 * Bitmasks for the joysticks buttons, determines what has
	 * been pressed on the joystick, these need to be mapped
	 * to whatever device you're using instead of an xbox 360
	 * joystick
	 */
	enum {
		XINPUT_GAMEPAD_DPAD_UP          = 0x00000001,
		XINPUT_GAMEPAD_DPAD_DOWN        = 0x00000002,
		XINPUT_GAMEPAD_DPAD_LEFT        = 0x00000004,
		XINPUT_GAMEPAD_DPAD_RIGHT       = 0x00000008,
		XINPUT_GAMEPAD_START            = 0x00000010,
		XINPUT_GAMEPAD_BACK             = 0x00000020,
		XINPUT_GAMEPAD_LEFT_THUMB       = 0x00000040,
		XINPUT_GAMEPAD_RIGHT_THUMB      = 0x00000080,
		XINPUT_GAMEPAD_LEFT_SHOULDER    = 0x0100,
		XINPUT_GAMEPAD_RIGHT_SHOULDER   = 0x0200,
		XINPUT_GAMEPAD_A                = 0x1000,
		XINPUT_GAMEPAD_B                = 0x2000,
		XINPUT_GAMEPAD_X                = 0x4000,
		XINPUT_GAMEPAD_Y                = 0x8000,
	}

	/**
	 * Defines the flags used to determine if the user is pushing
	 * down on a button, not holding a button, etc
	 */
	enum {
		XINPUT_KEYSTROKE_KEYDOWN        = 0x0001,
		XINPUT_KEYSTROKE_KEYUP          = 0x0002,
		XINPUT_KEYSTROKE_REPEAT         = 0x0004,
	}
	
	/**
	 * Defines the codes which are returned by XInputGetKeystroke
	 */
	enum {
		VK_PAD_A                        = 0x5800,
		VK_PAD_B                        = 0x5801,
		VK_PAD_X                        = 0x5802,
		VK_PAD_Y                        = 0x5803,
		VK_PAD_RSHOULDER                = 0x5804,
		VK_PAD_LSHOULDER                = 0x5805,
		VK_PAD_LTRIGGER                 = 0x5806,
		VK_PAD_RTRIGGER                 = 0x5807,
		VK_PAD_DPAD_UP                  = 0x5810,
		VK_PAD_DPAD_DOWN                = 0x5811,
		VK_PAD_DPAD_LEFT                = 0x5812,
		VK_PAD_DPAD_RIGHT               = 0x5813,
		VK_PAD_START                    = 0x5814,
		VK_PAD_BACK                     = 0x5815,
		VK_PAD_LTHUMB_PRESS             = 0x5816,
		VK_PAD_RTHUMB_PRESS             = 0x5817,
		VK_PAD_LTHUMB_UP                = 0x5820,
		VK_PAD_LTHUMB_DOWN              = 0x5821,
		VK_PAD_LTHUMB_RIGHT             = 0x5822,
		VK_PAD_LTHUMB_LEFT              = 0x5823,
		VK_PAD_LTHUMB_UPLEFT            = 0x5824,
		VK_PAD_LTHUMB_UPRIGHT           = 0x5825,
		VK_PAD_LTHUMB_DOWNRIGHT         = 0x5826,
		VK_PAD_LTHUMB_DOWNLEFT          = 0x5827,
		VK_PAD_RTHUMB_UP                = 0x5830,
		VK_PAD_RTHUMB_DOWN              = 0x5831,
		VK_PAD_RTHUMB_RIGHT             = 0x5832,
		VK_PAD_RTHUMB_LEFT              = 0x5833,
		VK_PAD_RTHUMB_UPLEFT            = 0x5834,
		VK_PAD_RTHUMB_UPRIGHT           = 0x5835,
		VK_PAD_RTHUMB_DOWNRIGHT         = 0x5836,
		VK_PAD_RTHUMB_DOWNLEFT          = 0x5837,
	}
	
	/**
	 * Deadzones are for analogue joystick controls on the joypad
	 * which determine when input should be assumed to be in the
	 * middle of the pad. This is a threshold to stop a joypad
	 * controlling the game when the player isn't touching the
	 * controls.
	 */
	enum {
		XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE  = 7849,
		XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE = 8689,
		XINPUT_GAMEPAD_TRIGGER_THRESHOLD    = 30,
	}

	/**
	 * Defines what type of abilities the type of joystick has
	 * DEVTYPE_GAMEPAD is avaliable for all joysticks, however
	 * there may be more specfic identifiers for other joysticks
	 * which are being used.
	 */
	enum {
		XINPUT_DEVTYPE_GAMEPAD          = 0x01,
		XINPUT_DEVSUBTYPE_GAMEPAD       = 0x01,
		XINPUT_DEVSUBTYPE_WHEEL         = 0x02,
		XINPUT_DEVSUBTYPE_ARCADE_STICK  = 0x03,
		XINPUT_DEVSUBTYPE_FLIGHT_SICK   = 0x04,
		XINPUT_DEVSUBTYPE_DANCE_PAD     = 0x05,
		XINPUT_DEVSUBTYPE_GUITAR        = 0x06,
		XINPUT_DEVSUBTYPE_DRUM_KIT      = 0x08,
	}
	
	/**
	 * These are used with the XInputGetCapabilities function to
	 * determine the abilities to the joystick which has been
	 * plugged in.
	 */
	enum {
		XINPUT_CAPS_VOICE_SUPPORTED     = 0x0004,
		XINPUT_FLAG_GAMEPAD             = 0x00000001,
	}

	/**
	 * Defines the status of the battery if one is used in the
	 * attached joystick. The first two define if the joystick
	 * supports a battery. Disconnected means that the joystick
	 * isn't connected. Wired shows that the joystick is a wired
	 * joystick.
	 */
	enum {
		BATTERY_DEVTYPE_GAMEPAD         = 0x00,
		BATTERY_DEVTYPE_HEADSET         = 0x01,
		BATTERY_TYPE_DISCONNECTED       = 0x00,
		BATTERY_TYPE_WIRED              = 0x01,
		BATTERY_TYPE_ALKALINE           = 0x02,
		BATTERY_TYPE_NIMH               = 0x03,
		BATTERY_TYPE_UNKNOWN            = 0xFF,
		BATTERY_LEVEL_EMPTY             = 0x00,
		BATTERY_LEVEL_LOW               = 0x01,
		BATTERY_LEVEL_MEDIUM            = 0x02,
		BATTERY_LEVEL_FULL              = 0x03,
	}

	/**
	 * How many joysticks can be used with this library. Games that
	 * use the xinput library will not go over this number.
	 */
	enum {
		XUSER_MAX_COUNT                 = 4,
		XUSER_INDEX_ANY                 = 0x000000FF,
	}

	/**
	 * Describes the current state of the Xbox 360 Controller.
	 *
	 * This structure is used by the XINPUT_STATE structure when polling for changes in the state of the controller.
	 * The specific mapping of button to game function varies depending on the game type.
	 * The constant XINPUT_GAMEPAD_TRIGGER_THRESHOLD may be used as the value which bLeftTrigger and bRightTrigger must be greater than to register as pressed. This is optional, but often desirable. Xbox 360 Controller buttons do not manifest crosstalk.
	 */
	struct XINPUT_GAMEPAD {
		WORD wButtons;      /// Bitmask of the device digital buttons, as follows. A set bit indicates that the corresponding button is pressed. Bits that are set but not defined above are reserved, and their state is undefined. XINPUT_GAMEPAD_*
		BYTE bLeftTrigger;  /// The current value of the left  trigger analog control. The value is between 0 and 255.
		BYTE bRightTrigger; /// The current value of the right trigger analog control. The value is between 0 and 255.
		SHORT sThumbLX;     /// Left thumbstick x-axis value. Each of the thumbstick axis members is a signed value between -32768 and 32767 describing the position of the thumbstick. A value of 0 is centered. Negative values signify down or to the left. Positive values signify up or to the right. The constants XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE or XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE can be used as a positive and negative value to filter a thumbstick input.
		SHORT sThumbLY;     /// Left thumbstick y-axis value. The value is between -32768 and 32767.
		SHORT sThumbRX;     /// Right thumbstick x-axis value. The value is between -32768 and 32767.
		SHORT sThumbRY;     /// Right thumbstick y-axis value. The value is between -32768 and 32767.
	}
	
	/**
	 * Represents the state of a controller.
	 *
	 *  The dwPacketNumber member is incremented only if the status of the controller has changed since the controller was last polled.
	 */
	struct XINPUT_STATE {
		DWORD dwPacketNumber;   /// State packet number. The packet number indicates whether there have been any changes in the state of the controller. If the dwPacketNumber member is the same in sequentially returned XINPUT_STATE structures, the controller state has not changed.
		XINPUT_GAMEPAD Gamepad; /// XINPUT_GAMEPAD structure containing the current state of an Xbox 360 Controller.
	}

	/**
	 * Defines the structure of how much vibration is set on both the
	 * right and left motors in a joystick. If you're not using a 360
	 * joystick you will have to map these to your device.
	 */
	struct XINPUT_VIBRATION {
		WORD wLeftMotorSpeed;  /// Speed of the left  motor. Valid values are in the range 0 to 65,535. Zero signifies no motor use; 65,535 signifies 100 percent motor use.
		WORD wRightMotorSpeed; /// Speed of the right motor. Valid values are in the range 0 to 65,535. Zero signifies no motor use; 65,535 signifies 100 percent motor use.
	}

	/**
	 * Defines the structure for what kind of abilities the joystick has
	 * such abilites are things such as if the joystick has the ability
	 * to send and receive audio, if the joystick is infact a driving
	 * wheel or perhaps if the joystick is some kind of dance pad or
	 * guitar.
	 */
	struct XINPUT_CAPABILITIES {
		BYTE Type;
		BYTE SubType;
		WORD Flags;
		XINPUT_GAMEPAD Gamepad;
		XINPUT_VIBRATION Vibration;
	}
	
	/**
	 * Defines the structure for a joystick input event which is
	 * retrieved using the function XInputGetKeystroke
	 */
	struct XINPUT_KEYSTROKE {
		WORD  VirtualKey;
		WCHAR Unicode;
		WORD  Flags;
		BYTE  UserIndex;
		BYTE  HidCode;
	}

	struct XINPUT_BATTERY_INFORMATION {
		BYTE BatteryType;
		BYTE BatteryLevel;
	}

	mixin XInput_Imports;
}

template XInput_Imports() {
	void  function(BOOL enable) XInputEnable;
	DWORD function(DWORD dwUserIndex, XINPUT_VIBRATION* pVibration) XInputSetState;
	DWORD function(DWORD dwUserIndex, XINPUT_STATE* pState) XInputGetState;
	DWORD function(DWORD dwUserIndex, DWORD dwReserved, XINPUT_KEYSTROKE* pKeystroke) XInputGetKeystroke;
	DWORD function(DWORD dwUserIndex, DWORD dwFlags, XINPUT_CAPABILITIES* pCapabilities) XInputGetCapabilities;
	//DWORD function(DWORD, GUID*, GUID*) XInputGetDSoundAudioDeviceGuids;
	DWORD function(DWORD dwUserIndex, BYTE, XINPUT_BATTERY_INFORMATION*) XInputGetBatteryInformation;
}

static this() {
	BindLibrary!("xinput1_3.dll", XInput_Imports);
}

void BindLibrary(string dll, alias bindTemplate, string prefixTo = "", string prefixFrom = "")() {
	HANDLE lib = LoadLibraryA(dll);
	if (lib is null) throw(new Exception("Can't load library '" ~ dll ~ "'"));
	
	static string ProcessMember(string name) {
		string dname = prefixTo ~ name;
		string importName = prefixFrom ~ name;
		return (
			"{ static if (__traits(compiles, &" ~ dname ~ ")) {"
				"void* addr = cast(void*)GetProcAddress(lib, \"" ~ importName ~ "\");"
				"if (addr is null) throw(new Exception(\"Can't load '" ~ importName ~ "' from '" ~ dll ~ "'\"));"
				"*cast(void**)&" ~ dname ~ " = addr;"
			"} }"
		); 
	}
	
	static string ProcessMembers(alias T)() {
		string s;
		static if (T.length >= 1) {
			s ~= ProcessMember(T[0]);
			static if (T.length > 1) s ~= ProcessMembers!(T[1..$])();
		}
		return s;
	}

	mixin(ProcessMembers!(__traits(derivedMembers, bindTemplate))());
}


void main() {
	XINPUT_STATE state;
	XINPUT_KEYSTROKE keystroke;
	XInputEnable(true);

	while (1) {
		XInputGetState(0, &state);
		XInputGetKeystroke(0, BATTERY_DEVTYPE_GAMEPAD, &keystroke);

		writefln(
			"Packet(%04X) Buttons(%016b) LT(%02X) RT(%02X) "
			"Left(%6d,%6d) "
			"Right(%6d,%6d) "
			"VirtualKey(%08X) "
			, state.dwPacketNumber, state.Gamepad.wButtons, state.Gamepad.bLeftTrigger, state.Gamepad.bRightTrigger
			, state.Gamepad.sThumbLX, state.Gamepad.sThumbLY
			, state.Gamepad.sThumbRX, state.Gamepad.sThumbRY
			, keystroke.VirtualKey
		);

		Sleep(1);
	}
}
