module pspemu.hle.kd.utility.Types;

public import pspemu.hle.kd.Types;

union netData {
	u32 asUint;
	char asString[128];
}

enum PspModule : uint {
	PSP_MODULE_NET_COMMON		= 0x0100,
	PSP_MODULE_NET_ADHOC		= 0x0101,
	PSP_MODULE_NET_INET			= 0x0102,
	PSP_MODULE_NET_PARSEURI		= 0x0103,
	PSP_MODULE_NET_PARSEHTTP	= 0x0104,
	PSP_MODULE_NET_HTTP			= 0x0105,
	PSP_MODULE_NET_SSL			= 0x0106,
	
	// USB Modules
	PSP_MODULE_USB_PSPCM		= 0x0200,
	PSP_MODULE_USB_MIC			= 0x0201,
	PSP_MODULE_USB_CAM			= 0x0202,
	PSP_MODULE_USB_GPS			= 0x0203,
	
	// Audio/video Modules
	PSP_MODULE_AV_AVCODEC		= 0x0300,
	PSP_MODULE_AV_SASCORE		= 0x0301,
	PSP_MODULE_AV_ATRAC3PLUS	= 0x0302,
	PSP_MODULE_AV_MPEGBASE		= 0x0303,
	PSP_MODULE_AV_MP3			= 0x0304,
	PSP_MODULE_AV_VAUDIO		= 0x0305,
	PSP_MODULE_AV_AAC			= 0x0306,
	PSP_MODULE_AV_G729			= 0x0307,
	
	// NP
	PSP_MODULE_NP_COMMON		= 0x0400,
	PSP_MODULE_NP_SERVICE		= 0x0401,
	PSP_MODULE_NP_MATCHING2		= 0x0402,
	
	PSP_MODULE_NP_DRM			= 0x0500,
	
	// IrDA
	PSP_MODULE_IRDA				= 0x0600,
}

enum {
	PSP_NET_MODULE_COMMON    = 1,
	PSP_NET_MODULE_ADHOC     = 2,
	PSP_NET_MODULE_INET      = 3,
	PSP_NET_MODULE_PARSEURI  = 4,
	PSP_NET_MODULE_PARSEHTTP = 5,
	PSP_NET_MODULE_HTTP      = 6,
	PSP_NET_MODULE_SSL       = 7,
}

enum {
	PSP_AV_MODULE_AVCODEC    = 0,
	PSP_AV_MODULE_SASCORE    = 1,
	PSP_AV_MODULE_ATRAC3PLUS = 2, // Requires PSP_AV_MODULE_AVCODEC loading first
	PSP_AV_MODULE_MPEGBASE   = 3, // Requires PSP_AV_MODULE_AVCODEC loading first
	PSP_AV_MODULE_MP3        = 4,
	PSP_AV_MODULE_VAUDIO     = 5,
	PSP_AV_MODULE_AAC        = 6,
	PSP_AV_MODULE_G729       = 7,
}

/// Save data utility modes
enum PspUtilitySavedataMode : uint {
	PSP_UTILITY_SAVEDATA_AUTOLOAD       = 0,
	PSP_UTILITY_SAVEDATA_AUTOSAVE       = 1,
	PSP_UTILITY_SAVEDATA_LOAD           = 2,
	PSP_UTILITY_SAVEDATA_SAVE           = 3,
	PSP_UTILITY_SAVEDATA_LISTLOAD       = 4,
	PSP_UTILITY_SAVEDATA_LISTSAVE       = 5,
	PSP_UTILITY_SAVEDATA_LISTDELETE     = 6,
	PSP_UTILITY_SAVEDATA_DELETE         = 7,
	PSP_UTILITY_SAVEDATA_SIZES          = 8,
	PSP_UTILITY_SAVEDATA_AUTODELETE     = 9,
	PSP_UTILITY_SAVEDATA_SINGLEDELETE   = 10,
	PSP_UTILITY_SAVEDATA_LIST           = 11,
	PSP_UTILITY_SAVEDATA_FILES          = 12,
	PSP_UTILITY_SAVEDATA_MAKEDATASECURE = 13,
	PSP_UTILITY_SAVEDATA_MAKEDATA       = 14,
	PSP_UTILITY_SAVEDATA_READSECURE     = 15,
	PSP_UTILITY_SAVEDATA_READ           = 16,
	PSP_UTILITY_SAVEDATA_WRITESECURE    = 17,
	PSP_UTILITY_SAVEDATA_WRITE          = 18,
	PSP_UTILITY_SAVEDATA_ERASESECURE    = 19,
	PSP_UTILITY_SAVEDATA_ERASE          = 20,
	PSP_UTILITY_SAVEDATA_DELETEDATA     = 21,
	PSP_UTILITY_SAVEDATA_GETSIZE        = 22,
}


enum pspUtilityMsgDialogMode {
	PSP_UTILITY_MSGDIALOG_MODE_ERROR = 0, // Error message
	PSP_UTILITY_MSGDIALOG_MODE_TEXT  = 1, // String message
}

enum pspUtilityMsgDialogOption {
	PSP_UTILITY_MSGDIALOG_OPTION_ERROR         = 0x00000000, // Error message (why two flags?)
	PSP_UTILITY_MSGDIALOG_OPTION_TEXT          = 0x00000001, // Text message (why two flags?)
	PSP_UTILITY_MSGDIALOG_OPTION_YESNO_BUTTONS = 0x00000010, // Yes/No buttons instead of 'Cancel'
	PSP_UTILITY_MSGDIALOG_OPTION_DEFAULT_NO    = 0x00000100, // Default position 'No', if not set will default to 'Yes'
}

enum pspUtilityMsgDialogPressed {
	PSP_UTILITY_MSGDIALOG_RESULT_UNKNOWN1 = 0,
	PSP_UTILITY_MSGDIALOG_RESULT_YES      = 1,
	PSP_UTILITY_MSGDIALOG_RESULT_NO       = 2,
	PSP_UTILITY_MSGDIALOG_RESULT_BACK     = 3,
}

enum PspUtilitySavedataFocus {
	PSP_UTILITY_SAVEDATA_FOCUS_UNKNOWN    = 0, // 
	PSP_UTILITY_SAVEDATA_FOCUS_FIRSTLIST  = 1, // First in list
	PSP_UTILITY_SAVEDATA_FOCUS_LASTLIST   = 2, // Last in list
	PSP_UTILITY_SAVEDATA_FOCUS_LATEST     = 3, //  Most recent date
	PSP_UTILITY_SAVEDATA_FOCUS_OLDEST     = 4, // Oldest date
	PSP_UTILITY_SAVEDATA_FOCUS_UNKNOWN2   = 5, //
	PSP_UTILITY_SAVEDATA_FOCUS_UNKNOWN3   = 6, //
	PSP_UTILITY_SAVEDATA_FOCUS_FIRSTEMPTY = 7, // First empty slot
	PSP_UTILITY_SAVEDATA_FOCUS_LASTEMPTY  = 8, // Last empty slot
}

struct PspUtilitySavedataSFOParam {
	char  title[0x80];
	char  savedataTitle[0x80];
	char  detail[0x400];
	ubyte parentalLevel;
	ubyte unknown[3];
}

struct PspUtilitySavedataFileData {
	void *buf;
	SceSize bufSize;
	SceSize size;	/* ??? - why are there two sizes? */
	int unknown;
}

struct PspUtilitySavedataListSaveNewData {
	PspUtilitySavedataFileData icon0;
	char *title;
}


/**
 * Structure to hold the parameters for a message dialog
**/
struct pspUtilityMsgDialogParams {
    pspUtilityDialogCommon base;
    int unknown;
	pspUtilityMsgDialogMode mode;
	uint errorValue;
    ///The message to display (may contain embedded linefeeds)
    char message[512];
	pspUtilityMsgDialogOption options;
	pspUtilityMsgDialogPressed buttonPressed;
}

struct pspUtilityDialogCommon {
	uint size;	        /// Size of the structure
	int  language;		/// Language
	int  buttonSwap;	/// Set to 1 for X/O button swap
	int  graphicsThread;/// Graphics thread priority
	int  accessThread;	/// Access/fileio thread priority (SceJobThread)
	int  fontThread;	/// Font thread priority (ScePafThread)
	int  soundThread;	/// Sound thread priority
	int  result;		/// Result
	int  reserved[4];	/// Set to 0
}

align(1) struct SceUtilitySavedataParam {
	pspUtilityDialogCommon base;

	PspUtilitySavedataMode mode;
	
	int unknown1;
	
	int overwrite;

	/** gameName: name used from the game for saves, equal for all saves */
	char gameName[13];
	char reserved[3];
	/** saveName: name of the particular save, normally a number */
	char saveName[20];

	/** saveNameList: used by multiple modes */
	char *saveNameList; // char[20]

	/** fileName: name of the data file of the game for example DATA.BIN */
	char fileName[13];
	char reserved1[3];
	
	static assert (gameName.offsetof == 0x3C);
	static assert (fileName.offsetof == 0x64);

	/** pointer to a buffer that will contain data file unencrypted data */
	void *dataBuf;
	/** size of allocated space to dataBuf */
	SceSize dataBufSize;
	SceSize dataSize;

	PspUtilitySavedataSFOParam sfoParam;

	PspUtilitySavedataFileData icon0FileData;
	PspUtilitySavedataFileData icon1FileData;
	PspUtilitySavedataFileData pic1FileData;
	PspUtilitySavedataFileData snd0FileData;

	/** Pointer to an PspUtilitySavedataListSaveNewData structure */
	PspUtilitySavedataListSaveNewData *newData;

	/** Initial focus for lists */
	PspUtilitySavedataFocus focus;

	/** unknown2: ? */
	int unknown2[4];

//#if _PSP_FW_VERSION >= 200

	/** key: encrypt/decrypt key for save with firmware >= 2.00 */
	char key[16];

	/** unknown3: ? */
	char unknown3[20];

//#endif

}

enum pspUtilityNetconfActions {
	PSP_NETCONF_ACTION_CONNECTAP,
	PSP_NETCONF_ACTION_DISPLAYSTATUS,
	PSP_NETCONF_ACTION_CONNECT_ADHOC,
    PSP_NETCONF_ACTION_CONNECTAP_LASTUSED,
}

struct pspUtilityNetconfAdhoc {
	char name[8];
	uint timeout;
}

struct pspUtilityNetconfData {
	pspUtilityDialogCommon base;
	int action; /** One of pspUtilityNetconfActions */
	pspUtilityNetconfAdhoc *adhocparam; //* Adhoc connection params */
	int hotspot; /** Set to 1 to allow connections with the 'Internet Browser' option set to 'Start' (ie. hotspot connection) */
	int hotspot_connected; /** Will be set to 1 when connected to a hotspot style connection */
	int wifisp; /** Set to 1 to allow connections to Wifi service providers (WISP) */
}




/**
 * Enumeration for input language
 */
enum SceUtilityOskInputLanguage {
	PSP_UTILITY_OSK_LANGUAGE_DEFAULT   = 0x00,
	PSP_UTILITY_OSK_LANGUAGE_JAPANESE  = 0x01,
	PSP_UTILITY_OSK_LANGUAGE_ENGLISH   = 0x02,
	PSP_UTILITY_OSK_LANGUAGE_FRENCH    = 0x03,
	PSP_UTILITY_OSK_LANGUAGE_SPANISH   = 0x04,
	PSP_UTILITY_OSK_LANGUAGE_GERMAN    = 0x05,
	PSP_UTILITY_OSK_LANGUAGE_ITALIAN   = 0x06,
	PSP_UTILITY_OSK_LANGUAGE_DUTCH     = 0x07,
	PSP_UTILITY_OSK_LANGUAGE_PORTUGESE = 0x08,
	PSP_UTILITY_OSK_LANGUAGE_RUSSIAN   = 0x09,
	PSP_UTILITY_OSK_LANGUAGE_KOREAN    = 0x0a,
};

/**
 * Enumeration for OSK internal state
 */
enum SceUtilityOskState {
	PSP_UTILITY_OSK_DIALOG_NONE      = 0, /// No OSK is currently active
	PSP_UTILITY_OSK_DIALOG_INITING   = 1, /// The OSK is currently being initialized
	PSP_UTILITY_OSK_DIALOG_INITED    = 2, /// The OSK is initialised
	PSP_UTILITY_OSK_DIALOG_VISIBLE   = 3, /// The OSK is visible and ready for use
	PSP_UTILITY_OSK_DIALOG_QUIT      = 4, /// The OSK has been cancelled and should be shut down
	PSP_UTILITY_OSK_DIALOG_FINISHED  = 5, /// The OSK has successfully shut down 
};

/**
 * Enumeration for OSK field results
 */
enum SceUtilityOskResult {
	PSP_UTILITY_OSK_RESULT_UNCHANGED = 0,
	PSP_UTILITY_OSK_RESULT_CANCELLED = 1,
	PSP_UTILITY_OSK_RESULT_CHANGED   = 2,
};

/**
 * Enumeration for input types (these are limited by initial choice of language)
 */
enum SceUtilityOskInputType {
	PSP_UTILITY_OSK_INPUTTYPE_ALL                    = 0x00000000,
	PSP_UTILITY_OSK_INPUTTYPE_LATIN_DIGIT            = 0x00000001,
	PSP_UTILITY_OSK_INPUTTYPE_LATIN_SYMBOL           = 0x00000002,
	PSP_UTILITY_OSK_INPUTTYPE_LATIN_LOWERCASE        = 0x00000004,
	PSP_UTILITY_OSK_INPUTTYPE_LATIN_UPPERCASE        = 0x00000008,
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_DIGIT         = 0x00000100,
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_SYMBOL        = 0x00000200,
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_LOWERCASE     = 0x00000400,
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_UPPERCASE     = 0x00000800,
	// http://en.wikipedia.org/wiki/Hiragana
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_HIRAGANA      = 0x00001000,
	// http://en.wikipedia.org/wiki/Katakana
	// Half-width Katakana
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_HALF_KATAKANA = 0x00002000,
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_KATAKANA      = 0x00004000,
	// http://en.wikipedia.org/wiki/Kanji
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_KANJI         = 0x00008000,
	PSP_UTILITY_OSK_INPUTTYPE_RUSSIAN_LOWERCASE      = 0x00010000,
	PSP_UTILITY_OSK_INPUTTYPE_RUSSIAN_UPPERCASE      = 0x00020000,
	PSP_UTILITY_OSK_INPUTTYPE_KOREAN                 = 0x00040000,
	PSP_UTILITY_OSK_INPUTTYPE_URL                    = 0x00080000,
};

/**
 * OSK Field data
 */
struct SceUtilityOskData {
	int unk_00;                          /// Unknown. Pass 0.
    int unk_04;                          /// Unknown. Pass 0.
    SceUtilityOskInputLanguage language; /// One of ::SceUtilityOskInputLanguage
    int unk_12;                          /// Unknown. Pass 0.
    SceUtilityOskInputType inputtype;    /// One or more of ::SceUtilityOskInputType (types that are selectable by pressing SELECT)
    int     lines;                       /// Number of lines
    int     unk_24;                      /// Unknown. Pass 0.
    ushort* desc;                        /// Description text
    ushort* intext;                      /// Initial text
    int     outtextlength;               /// Length of output text
    ushort* outtext;                     /// Pointer to the output text
    SceUtilityOskResult result;          /// Result.
    int     outtextlimit;                /// The max text that can be input
}

/**
 * OSK parameters
 */
struct SceUtilityOskParams {
	pspUtilityDialogCommon base;      ///
	int                    datacount; /// Number of input fields
	SceUtilityOskData*     data;      /// Pointer to the start of the data for the input fields
	int                    state;     /// The local OSK state, one of ::SceUtilityOskState
	int                    unk_60;    /// Unknown. Pass 0	
}
