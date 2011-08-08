//-----------------------------------------------------------------------------
// wxD - Defs.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - Defs.cs
//
/// Symbol definitions that do not belong to any particular class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Defs.d,v 1.12 2007/10/24 07:50:09 afb Exp $
//-----------------------------------------------------------------------------

module wx.Defs;
//public import wx.common;

version(wx25) version = wx26;
version(wx27) version = wx28;

	public enum BitmapType {
		wxBITMAP_TYPE_INVALID               = 0,
		wxBITMAP_TYPE_BMP,
		wxBITMAP_TYPE_BMP_RESOURCE,
		wxBITMAP_TYPE_RESOURCE              = wxBITMAP_TYPE_BMP_RESOURCE,
		wxBITMAP_TYPE_ICO,
		wxBITMAP_TYPE_ICO_RESOURCE,
		wxBITMAP_TYPE_CUR,
		wxBITMAP_TYPE_CUR_RESOURCE,
		wxBITMAP_TYPE_XBM,
		wxBITMAP_TYPE_XBM_DATA,
		wxBITMAP_TYPE_XPM,
		wxBITMAP_TYPE_XPM_DATA,
		wxBITMAP_TYPE_TIF,
		wxBITMAP_TYPE_TIF_RESOURCE,
		wxBITMAP_TYPE_GIF,
		wxBITMAP_TYPE_GIF_RESOURCE,
		wxBITMAP_TYPE_PNG,
		wxBITMAP_TYPE_PNG_RESOURCE,
		wxBITMAP_TYPE_JPEG,
		wxBITMAP_TYPE_JPEG_RESOURCE,
		wxBITMAP_TYPE_PNM,
		wxBITMAP_TYPE_PNM_RESOURCE,
		wxBITMAP_TYPE_PCX,
		wxBITMAP_TYPE_PCX_RESOURCE,
		wxBITMAP_TYPE_PICT,
		wxBITMAP_TYPE_PICT_RESOURCE,
		wxBITMAP_TYPE_ICON,
		wxBITMAP_TYPE_ICON_RESOURCE,
		wxBITMAP_TYPE_ANI,
		wxBITMAP_TYPE_IFF,
		wxBITMAP_TYPE_MACCURSOR,
		wxBITMAP_TYPE_MACCURSOR_RESOURCE,
		wxBITMAP_TYPE_ANY                   = 50
	}

version(wx28) // -------------------------------------------- wxWidgets 2.8
{
	/*  Standard menu IDs */
	public enum MenuIDs
	{
		wxID_LOWEST = 4999,

		wxID_OPEN,
		wxID_CLOSE,
		wxID_NEW,
		wxID_SAVE,
		wxID_SAVEAS,
		wxID_REVERT,
		wxID_EXIT,
		wxID_UNDO,
		wxID_REDO,
		wxID_HELP,
		wxID_PRINT,
		wxID_PRINT_SETUP,
		wxID_PAGE_SETUP, /* NEW */
		wxID_PREVIEW,
		wxID_ABOUT,
		wxID_HELP_CONTENTS,
		wxID_HELP_INDEX, /* NEW */
		wxID_HELP_SEARCH, /* NEW */
		wxID_HELP_COMMANDS,
		wxID_HELP_PROCEDURES,
		wxID_HELP_CONTEXT,
		wxID_CLOSE_ALL,
		wxID_PREFERENCES,
		
		wxID_EDIT = 5030, /* NEW */
		wxID_CUT, /* NEW */
		wxID_COPY,
		wxID_PASTE,
		wxID_CLEAR,
		wxID_FIND,
		wxID_DUPLICATE,
		wxID_SELECTALL,
		wxID_DELETE,
		wxID_REPLACE,
		wxID_REPLACE_ALL,
		wxID_PROPERTIES,
		
		wxID_VIEW_DETAILS,
		wxID_VIEW_LARGEICONS,
		wxID_VIEW_SMALLICONS,
		wxID_VIEW_LIST,
		wxID_VIEW_SORTDATE,
		wxID_VIEW_SORTNAME,
		wxID_VIEW_SORTSIZE,
		wxID_VIEW_SORTTYPE,
		
		wxID_FILE = 5050,	/* NEW */
		wxID_FILE1,	/* NEW */
		wxID_FILE2,
		wxID_FILE3,
		wxID_FILE4,
		wxID_FILE5,
		wxID_FILE6,
		wxID_FILE7,
		wxID_FILE8,
		wxID_FILE9,
		
		/*  Standard button and menu IDs */
		wxID_OK = 5100,
		wxID_CANCEL,
		wxID_APPLY,
		wxID_YES,
		wxID_NO,
		wxID_STATIC,
		wxID_FORWARD,
		wxID_BACKWARD,
		wxID_DEFAULT,
		wxID_MORE,
		wxID_SETUP,
		wxID_RESET,
		wxID_CONTEXT_HELP,
		wxID_YESTOALL,
		wxID_NOTOALL,
		wxID_ABORT,
		wxID_RETRY,
		wxID_IGNORE,
		wxID_ADD,
		wxID_REMOVE,
		
		wxID_UP,
		wxID_DOWN,
		wxID_HOME,
		wxID_REFRESH,
		wxID_STOP,
		wxID_INDEX,
		
		wxID_BOLD,
		wxID_ITALIC,
		wxID_JUSTIFY_CENTER,
		wxID_JUSTIFY_FILL,
		wxID_JUSTIFY_RIGHT,
		wxID_JUSTIFY_LEFT,
		wxID_UNDERLINE,
		wxID_INDENT,
		wxID_UNINDENT,
		wxID_ZOOM_100,
		wxID_ZOOM_FIT,
		wxID_ZOOM_IN,
		wxID_ZOOM_OUT,
		wxID_UNDELETE,
		wxID_REVERT_TO_SAVED,
		
		/*  System menu IDs (used by wxUniv): */
		wxID_SYSTEM_MENU = 5200,
		wxID_CLOSE_FRAME,
		wxID_MOVE_FRAME,
		wxID_RESIZE_FRAME,
		wxID_MAXIMIZE_FRAME,
		wxID_ICONIZE_FRAME,
		wxID_RESTORE_FRAME,
		
		/*  IDs used by generic file dialog (13 consecutive starting from this value) */
		wxID_FILEDLGG = 5900,
		
		wxID_HIGHEST = 5999
	}
}
else // version (wx26) // ----------------------------------- wxWidgets 2.6
{
	/*  Standard menu IDs */
	public enum MenuIDs
	{
		wxID_LOWEST = 4999,

		wxID_OPEN,
		wxID_CLOSE,
		wxID_NEW,
		wxID_SAVE,
		wxID_SAVEAS,
		wxID_REVERT,
		wxID_EXIT,
		wxID_UNDO,
		wxID_REDO,
		wxID_HELP,
		wxID_PRINT,
		wxID_PRINT_SETUP,
//      wxID_PAGE_SETUP,	/* added in wxWidgets 2.7.1 */
		wxID_PREVIEW,
		wxID_ABOUT,
		wxID_HELP_CONTENTS,
		wxID_HELP_COMMANDS,
		wxID_HELP_PROCEDURES,
		wxID_HELP_CONTEXT,
		wxID_CLOSE_ALL,
		wxID_PREFERENCES ,
		
		wxID_CUT = 5030,
		wxID_COPY,
		wxID_PASTE,
		wxID_CLEAR,
		wxID_FIND,
		wxID_DUPLICATE,
		wxID_SELECTALL,
		wxID_DELETE,
		wxID_REPLACE,
		wxID_REPLACE_ALL,
		wxID_PROPERTIES,
		
		wxID_VIEW_DETAILS,
		wxID_VIEW_LARGEICONS,
		wxID_VIEW_SMALLICONS,
		wxID_VIEW_LIST,
		wxID_VIEW_SORTDATE,
		wxID_VIEW_SORTNAME,
		wxID_VIEW_SORTSIZE,
		wxID_VIEW_SORTTYPE,
		
		wxID_FILE1 = 5050,
		wxID_FILE2,
		wxID_FILE3,
		wxID_FILE4,
		wxID_FILE5,
		wxID_FILE6,
		wxID_FILE7,
		wxID_FILE8,
		wxID_FILE9,
		
		/*  Standard button and menu IDs */
		wxID_OK = 5100,
		wxID_CANCEL,
		wxID_APPLY,
		wxID_YES,
		wxID_NO,
		wxID_STATIC,
		wxID_FORWARD,
		wxID_BACKWARD,
		wxID_DEFAULT,
		wxID_MORE,
		wxID_SETUP,
		wxID_RESET,
		wxID_CONTEXT_HELP,
		wxID_YESTOALL,
		wxID_NOTOALL,
		wxID_ABORT,
		wxID_RETRY,
		wxID_IGNORE,
		wxID_ADD,
		wxID_REMOVE,
		
		wxID_UP,
		wxID_DOWN,
		wxID_HOME,
		wxID_REFRESH,
		wxID_STOP,
		wxID_INDEX,
		
		wxID_BOLD,
		wxID_ITALIC,
		wxID_JUSTIFY_CENTER,
		wxID_JUSTIFY_FILL,
		wxID_JUSTIFY_RIGHT,
		wxID_JUSTIFY_LEFT,
		wxID_UNDERLINE,
		wxID_INDENT,
		wxID_UNINDENT,
		wxID_ZOOM_100,
		wxID_ZOOM_FIT,
		wxID_ZOOM_IN,
		wxID_ZOOM_OUT,
		wxID_UNDELETE,
		wxID_REVERT_TO_SAVED,
		
		/*  System menu IDs (used by wxUniv): */
		wxID_SYSTEM_MENU = 5200,
		wxID_CLOSE_FRAME,
		wxID_MOVE_FRAME,
		wxID_RESIZE_FRAME,
		wxID_MAXIMIZE_FRAME,
		wxID_ICONIZE_FRAME,
		wxID_RESTORE_FRAME,
		
		/*  IDs used by generic file dialog (13 consecutive starting from this value) */
		wxID_FILEDLGG = 5900,
		
		wxID_HIGHEST = 5999
	}
} // -------------------------------------------------------- wxWidgets ABI

version(wx28) // -------------------------------------------- wxWidgets 2.8
{
	//[Flags]
	public enum KeyCode 
	{
		WXK_BACK    =    8,
		WXK_TAB     =    9,
		WXK_RETURN  =    13,
		WXK_ESCAPE  =    27,
		WXK_SPACE   =    32,
		WXK_DELETE  =    127,

		WXK_START   = 300,
		WXK_LBUTTON,
		WXK_RBUTTON,
		WXK_CANCEL,
		WXK_MBUTTON,
		WXK_CLEAR,
		WXK_SHIFT,
		WXK_ALT,
		WXK_CONTROL,
		WXK_MENU,
		WXK_PAUSE,
		WXK_CAPITAL,
		WXK_END,
		WXK_HOME,
		WXK_LEFT,
		WXK_UP,
		WXK_RIGHT,
		WXK_DOWN,
		WXK_SELECT,
		WXK_PRINT,
		WXK_EXECUTE,
		WXK_SNAPSHOT,
		WXK_INSERT,
		WXK_HELP,
		WXK_NUMPAD0,
		WXK_NUMPAD1,
		WXK_NUMPAD2,
		WXK_NUMPAD3,
		WXK_NUMPAD4,
		WXK_NUMPAD5,
		WXK_NUMPAD6,
		WXK_NUMPAD7,
		WXK_NUMPAD8,
		WXK_NUMPAD9,
		WXK_MULTIPLY,
		WXK_ADD,
		WXK_SEPARATOR,
		WXK_SUBTRACT,
		WXK_DECIMAL,
		WXK_DIVIDE,
		WXK_F1,
		WXK_F2,
		WXK_F3,
		WXK_F4,
		WXK_F5,
		WXK_F6,
		WXK_F7,
		WXK_F8,
		WXK_F9,
		WXK_F10,
		WXK_F11,
		WXK_F12,
		WXK_F13,
		WXK_F14,
		WXK_F15,
		WXK_F16,
		WXK_F17,
		WXK_F18,
		WXK_F19,
		WXK_F20,
		WXK_F21,
		WXK_F22,
		WXK_F23,
		WXK_F24,
		WXK_NUMLOCK,
		WXK_SCROLL,
		WXK_PAGEUP,
		WXK_PAGEDOWN,

		WXK_PRIOR = WXK_PAGEUP,   //WX 2.6 compatibility
		WXK_NEXT  = WXK_PAGEDOWN, //WX 2.6 compatibility

		WXK_NUMPAD_SPACE,
		WXK_NUMPAD_TAB,
		WXK_NUMPAD_ENTER,
		WXK_NUMPAD_F1,
		WXK_NUMPAD_F2,
		WXK_NUMPAD_F3,
		WXK_NUMPAD_F4,
		WXK_NUMPAD_HOME,
		WXK_NUMPAD_LEFT,
		WXK_NUMPAD_UP,
		WXK_NUMPAD_RIGHT,
		WXK_NUMPAD_DOWN,
		WXK_NUMPAD_PAGEUP,
		WXK_NUMPAD_PAGEDOWN,

		WXK_NUMPAD_PRIOR = WXK_NUMPAD_PAGEUP,   //WX 2.6 compatibility
		WXK_NUMPAD_NEXT  = WXK_NUMPAD_PAGEDOWN, //WX 2.6 compatibility

		WXK_NUMPAD_END,
		WXK_NUMPAD_BEGIN,
		WXK_NUMPAD_INSERT,
		WXK_NUMPAD_DELETE,
		WXK_NUMPAD_EQUAL,
		WXK_NUMPAD_MULTIPLY,
		WXK_NUMPAD_ADD,
		WXK_NUMPAD_SEPARATOR,
		WXK_NUMPAD_SUBTRACT,
		WXK_NUMPAD_DECIMAL,
		WXK_NUMPAD_DIVIDE
	}
}
else // version (wx26) // ----------------------------------- wxWidgets 2.6
{
	//[Flags]
	public enum KeyCode 
	{
		WXK_BACK    = 8,
		WXK_TAB     = 9,
		WXK_RETURN  = 13,
		WXK_ESCAPE  = 27,
		WXK_SPACE   = 32,
		WXK_DELETE  = 127,
		
		WXK_START   = 300,
		WXK_LBUTTON,
		WXK_RBUTTON,
		WXK_CANCEL,
		WXK_MBUTTON,
		WXK_CLEAR,
		WXK_SHIFT,
		WXK_ALT,
		WXK_CONTROL,
		WXK_MENU,
		WXK_PAUSE,
		WXK_CAPITAL,
		WXK_PRIOR,  // Page up
		WXK_NEXT,   // Page down
		WXK_END,
		WXK_HOME,
		WXK_LEFT,
		WXK_UP,
		WXK_RIGHT,
		WXK_DOWN,
		WXK_SELECT,
		WXK_PRINT,
		WXK_EXECUTE,
		WXK_SNAPSHOT,
		WXK_INSERT,
		WXK_HELP,
		WXK_NUMPAD0,
		WXK_NUMPAD1,
		WXK_NUMPAD2,
		WXK_NUMPAD3,
		WXK_NUMPAD4,
		WXK_NUMPAD5,
		WXK_NUMPAD6,
		WXK_NUMPAD7,
		WXK_NUMPAD8,
		WXK_NUMPAD9,
		WXK_MULTIPLY,
		WXK_ADD,
		WXK_SEPARATOR,
		WXK_SUBTRACT,
		WXK_DECIMAL,
		WXK_DIVIDE,
		WXK_F1,
		WXK_F2,
		WXK_F3,
		WXK_F4,
		WXK_F5,
		WXK_F6,
		WXK_F7,
		WXK_F8,
		WXK_F9,
		WXK_F10,
		WXK_F11,
		WXK_F12,
		WXK_F13,
		WXK_F14,
		WXK_F15,
		WXK_F16,
		WXK_F17,
		WXK_F18,
		WXK_F19,
		WXK_F20,
		WXK_F21,
		WXK_F22,
		WXK_F23,
		WXK_F24,
		WXK_NUMLOCK,
		WXK_SCROLL,
		WXK_PAGEUP,
		WXK_PAGEDOWN,
		
		WXK_NUMPAD_SPACE,
		WXK_NUMPAD_TAB,
		WXK_NUMPAD_ENTER,
		WXK_NUMPAD_F1,
		WXK_NUMPAD_F2,
		WXK_NUMPAD_F3,
		WXK_NUMPAD_F4,
		WXK_NUMPAD_HOME,
		WXK_NUMPAD_LEFT,
		WXK_NUMPAD_UP,
		WXK_NUMPAD_RIGHT,
		WXK_NUMPAD_DOWN,
		WXK_NUMPAD_PRIOR,
		WXK_NUMPAD_PAGEUP,
		WXK_NUMPAD_NEXT,
		WXK_NUMPAD_PAGEDOWN,
		WXK_NUMPAD_END,
		WXK_NUMPAD_BEGIN,
		WXK_NUMPAD_INSERT,
		WXK_NUMPAD_DELETE,
		WXK_NUMPAD_EQUAL,
		WXK_NUMPAD_MULTIPLY,
		WXK_NUMPAD_ADD,
		WXK_NUMPAD_SEPARATOR,
		WXK_NUMPAD_SUBTRACT,
		WXK_NUMPAD_DECIMAL,
		WXK_NUMPAD_DIVIDE
	}
} // -------------------------------------------------------- wxWidgets ABI

	public enum Direction 
	{
		wxLEFT    = 0x0010,
		wxRIGHT   = 0x0020,
		wxUP      = 0x0040,
		wxDOWN    = 0x0080,
		wxTOP     = wxUP,
		wxBOTTOM  = wxDOWN,
		wxNORTH   = wxUP,
		wxSOUTH   = wxDOWN,
		wxWEST    = wxLEFT,
		wxEAST    = wxRIGHT,
		wxALL     = (wxUP | wxDOWN | wxRIGHT | wxLEFT),
	}

	//[Flags]
	public enum FillStyle
	{
		wxDEFAULT = 70,
		wxDECORATIVE,
		wxROMAN,
		wxSCRIPT,
		wxSWISS,
		wxMODERN,
		wxTELETYPE,
		
		wxVARIABLE = 80,
		wxFIXED,
		
		wxNORMAL = 90,
		wxLIGHT,
		wxBOLD,
		wxITALIC,
		wxSLANT,
		
		wxSOLID = 100,
		wxDOT,
		wxint_DASH,
		wxSHORT_DASH,
		wxDOT_DASH,
		wxUSER_DASH,
		wxTRANSPARENT,
		wxSTIPPLE_MASK_OPAQUE,
		wxSTIPPLE_MASK,
		
		wxSTIPPLE = 110,
		wxBDIAGONAL_HATCH,
		wxCROSSDIAG_HATCH,
		wxFDIAGONAL_HATCH,
		wxCROSS_HATCH,
		wxHORIZONTAL_HATCH,
		wxVERTICAL_HATCH,
		
		wxJOIN_BEVEL = 120,
		wxJOIN_MITER,
		wxJOIN_ROUND,
		
		wxCAP_ROUND = 130,
		wxCAP_PROJECTING,
		wxCAP_BUTT,
		
		// Polygon fill style
		wxODDEVEN_RULE = 1,
		wxWINDING_RULE
	}

	// Logical operations
	//[Flags]
	public enum Logic
	{
		wxCLEAR,        wxROP_BLACK = wxCLEAR,             wxBLIT_BLACKNESS = wxCLEAR,        // 0
		wxXOR,          wxROP_XORPEN = wxXOR,              wxBLIT_SRCINVERT = wxXOR,          // src XOR dst
		wxINVERT,       wxROP_NOT = wxINVERT,              wxBLIT_DSTINVERT = wxINVERT,       // NOT dst
		wxOR_REVERSE,   wxROP_MERGEPENNOT = wxOR_REVERSE,  wxBLIT_00DD0228 = wxOR_REVERSE,    // src OR (NOT dst)
		wxAND_REVERSE,  wxROP_MASKPENNOT = wxAND_REVERSE,  wxBLIT_SRCERASE = wxAND_REVERSE,   // src AND (NOT dst)
		wxCOPY,         wxROP_COPYPEN = wxCOPY,            wxBLIT_SRCCOPY = wxCOPY,           // src
		wxAND,          wxROP_MASKPEN = wxAND,             wxBLIT_SRCAND = wxAND,             // src AND dst
		wxAND_INVERT,   wxROP_MASKNOTPEN = wxAND_INVERT,   wxBLIT_00220326 = wxAND_INVERT,    // (NOT src) AND dst
		wxNO_OP,        wxROP_NOP = wxNO_OP,               wxBLIT_00AA0029 = wxNO_OP,         // dst
		wxNOR,          wxROP_NOTMERGEPEN = wxNOR,         wxBLIT_NOTSRCERASE = wxNOR,        // (NOT src) AND (NOT dst)
		wxEQUIV,        wxROP_NOTXORPEN = wxEQUIV,         wxBLIT_00990066 = wxEQUIV,         // (NOT src) XOR dst
		wxSRC_INVERT,   wxROP_NOTCOPYPEN = wxSRC_INVERT,   wxBLIT_NOTSCRCOPY = wxSRC_INVERT,  // (NOT src)
		wxOR_INVERT,    wxROP_MERGENOTPEN = wxOR_INVERT,   wxBLIT_MERGEPAINT = wxOR_INVERT,   // (NOT src) OR dst
		wxNAND,         wxROP_NOTMASKPEN = wxNAND,         wxBLIT_007700E6 = wxNAND,          // (NOT src) OR (NOT dst)
		wxOR,           wxROP_MERGEPEN = wxOR,             wxBLIT_SRCPAINT = wxOR,            // src OR dst
		wxSET,          wxROP_WHITE = wxSET,               wxBLIT_WHITENESS = wxSET           // 1
	}

	public enum Orientation
	{
		wxVERTICAL     = 0x0008,
		wxHORIZONTAL   = 0x0004,
		
		wxBOTH     = (wxVERTICAL | wxHORIZONTAL),
	}

	public enum Stretch
	{
		wxSTRETCH_NOT     = 0x0000,
		wxSHRINK          = 0x1000,
		wxGROW            = 0x2000,
		wxEXPAND          = wxGROW,
		wxSHAPED          = 0x4000,
		wxFIXED_MINSIZE   = 0x8000,
		wxTILE            = 0xc000,
		
		// changed in wxWidgets 2.5.2, see discussion on wx-dev
		wxADJUST_MINSIZE  = 0x0000,
	}

	public enum Alignment
	{
		wxALIGN_NOT               = 0x0000,
		wxALIGN_CENTER_HORIZONTAL = 0x0100,
		wxALIGN_LEFT              = wxALIGN_NOT,
		wxALIGN_TOP               = wxALIGN_NOT,
		wxALIGN_RIGHT             = 0x0200,
		wxALIGN_BOTTOM            = 0x0400,
		wxALIGN_CENTER_VERTICAL   = 0x0800,
		
		wxALIGN_CENTER            = (wxALIGN_CENTER_HORIZONTAL | wxALIGN_CENTER_VERTICAL),
		
		wxALIGN_MASK              = 0x0f00,
		
		// Alternate spellings
		wxALIGN_CENTRE_VERTICAL   = wxALIGN_CENTER_VERTICAL,
		wxALIGN_CENTRE_HORIZONTAL = wxALIGN_CENTER_HORIZONTAL,
		wxALIGN_CENTRE            = wxALIGN_CENTER,
	}

	//[Flags]
	public enum ItemKind
	{
		wxITEM_SEPARATOR = -1,
		wxITEM_NORMAL,
		wxITEM_CHECK,
		wxITEM_RADIO,
		wxITEM_MAX
	}
    
	public enum FloodStyle
	{
		wxFLOOD_SURFACE = 1,
		wxFLOOD_BORDER = 2,
	}
    
	public enum MouseButton
	{
		wxMOUSE_BTN_ANY     = -1,
		wxMOUSE_BTN_NONE    = 0,
		wxMOUSE_BTN_LEFT    = 1,
		wxMOUSE_BTN_MIDDLE  = 2,
		wxMOUSE_BTN_RIGHT   = 3
	}
	
	public enum HelpSearchMode
	{
		wxHELP_SEARCH_INDEX,
		wxHELP_SEARCH_ALL
	}
	
	public enum UpdateUIMode
	{
		// Send UI update events to all windows
		wxUPDATE_UI_PROCESS_ALL,

		// Send UI update events to windows that have
		// the wxWS_EX_PROCESS_UI_UPDATES flag specified
		wxUPDATE_UI_PROCESS_SPECIFIED
	}

	enum {
    /** no id matches this one when compared to it */
    wxID_NONE = -3,

    /**  id for a separator line in the menu (invalid for normal item) */
    wxID_SEPARATOR = -2,

    /** any id: means that we don't care about the id, whether when installing
      * an event handler or when creating a new window */
    wxID_ANY = -1,

    /** all predefined ids are between wxID_LOWEST and wxID_HIGHEST */
    wxID_LOWEST = 4999,
    wxID_HIGHEST = 5999
	}

