//-----------------------------------------------------------------------------
// wxD - KeyEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - KeyEvent.cs
//
/// The wxKeyEvent wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: KeyEvent.d,v 1.10 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.KeyEvent;
public import wx.common;
public import wx.Event;

		//! \cond EXTERN
        static extern (C) IntPtr wxKeyEvent_ctor(int type);

        static extern (C) bool   wxKeyEvent_ControlDown(IntPtr self);
        static extern (C) bool   wxKeyEvent_ShiftDown(IntPtr self);
        static extern (C) bool   wxKeyEvent_AltDown(IntPtr self);
        static extern (C) bool   wxKeyEvent_MetaDown(IntPtr self);

        static extern (C) uint   wxKeyEvent_GetRawKeyCode(IntPtr self);
        static extern (C) int    wxKeyEvent_GetKeyCode(IntPtr self);

        static extern (C) uint   wxKeyEvent_GetRawKeyFlags(IntPtr self);
        static extern (C) bool   wxKeyEvent_HasModifiers(IntPtr self);

        static extern (C) void   wxKeyEvent_GetPosition(IntPtr self, ref Point pt);
        static extern (C) int    wxKeyEvent_GetX(IntPtr self);
        static extern (C) int    wxKeyEvent_GetY(IntPtr self);
	
	static extern (C) bool   wxKeyEvent_CmdDown(IntPtr self);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias KeyEvent wxKeyEvent;
    public class KeyEvent : Event
    {
        public this(IntPtr wxobj) 
            { super(wxobj); }

        public this(EventType type = wxEVT_NULL)
            { this(wxKeyEvent_ctor(type)); }

        //-----------------------------------------------------------------------------

        public bool ControlDown() { return wxKeyEvent_ControlDown(wxobj); }

        public bool MetaDown() { return wxKeyEvent_MetaDown(wxobj); }

        public bool ShiftDown() { return wxKeyEvent_ShiftDown(wxobj); }

        public bool AltDown() { return wxKeyEvent_AltDown(wxobj); }

        //-----------------------------------------------------------------------------

        /*public KeyCode KeyCode
        {
            get { return (KeyCode)wxKeyEvent_GetKeyCode(wxobj); }
        }*/
	
	public int KeyCode() { return wxKeyEvent_GetKeyCode(wxobj); }

        public int RawKeyCode() { return wxKeyEvent_GetRawKeyCode(wxobj); }

        //-----------------------------------------------------------------------------

        public int RawKeyFlags() { return wxKeyEvent_GetRawKeyFlags(wxobj); }

        //-----------------------------------------------------------------------------

        public bool HasModifiers() { return wxKeyEvent_HasModifiers(wxobj); }

        //-----------------------------------------------------------------------------

        public Point Position() {
                Point pt;
                wxKeyEvent_GetPosition(wxobj, pt);
                return pt;
            }

        //-----------------------------------------------------------------------------

        public int X() { return wxKeyEvent_GetX(wxobj); }

        public int Y() { return wxKeyEvent_GetY(wxobj); }

        //-----------------------------------------------------------------------------
	
	public bool CmdDown() { return wxKeyEvent_CmdDown(wxobj); }

		private static Event New(IntPtr obj) { return new KeyEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_KEY_DOWN,                        &KeyEvent.New);
			AddEventType(wxEVT_KEY_UP,                          &KeyEvent.New);
			AddEventType(wxEVT_CHAR,                            &KeyEvent.New);
			AddEventType(wxEVT_CHAR_HOOK,                       &KeyEvent.New);
		}
    }
