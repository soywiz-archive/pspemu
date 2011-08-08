//-----------------------------------------------------------------------------
// wxD - MouseEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - MouseEvent.cs
//
/// The wxMouseEvent wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: MouseEvent.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.MouseEvent;
public import wx.common;
public import wx.Event;

public import wx.DC;

		//! \cond EXTERN
        static extern (C) IntPtr wxMouseEvent_ctor(int mouseType);
        static extern (C) bool   wxMouseEvent_IsButton(IntPtr self);
        static extern (C) bool   wxMouseEvent_ButtonDown(IntPtr self);
	static extern (C) bool   wxMouseEvent_ButtonDown2(IntPtr self, int button);
        static extern (C) bool   wxMouseEvent_ButtonDClick(IntPtr self, int but);
        static extern (C) bool   wxMouseEvent_ButtonUp(IntPtr self, int but);
        static extern (C) bool   wxMouseEvent_Button(IntPtr self, int but);
        static extern (C) bool   wxMouseEvent_ButtonIsDown(IntPtr self, int but);
        static extern (C) int    wxMouseEvent_GetButton(IntPtr self);
        static extern (C) bool   wxMouseEvent_ControlDown(IntPtr self);
        static extern (C) bool   wxMouseEvent_MetaDown(IntPtr self);
        static extern (C) bool   wxMouseEvent_AltDown(IntPtr self);
        static extern (C) bool   wxMouseEvent_ShiftDown(IntPtr self);
        static extern (C) bool   wxMouseEvent_LeftDown(IntPtr self);
        static extern (C) bool   wxMouseEvent_MiddleDown(IntPtr self);
        static extern (C) bool   wxMouseEvent_RightDown(IntPtr self);
        static extern (C) bool   wxMouseEvent_LeftUp(IntPtr self);
        static extern (C) bool   wxMouseEvent_MiddleUp(IntPtr self);
        static extern (C) bool   wxMouseEvent_RightUp(IntPtr self);
        static extern (C) bool   wxMouseEvent_LeftDClick(IntPtr self);
        static extern (C) bool   wxMouseEvent_MiddleDClick(IntPtr self);
        static extern (C) bool   wxMouseEvent_RightDClick(IntPtr self);
        static extern (C) bool   wxMouseEvent_LeftIsDown(IntPtr self);
        static extern (C) bool   wxMouseEvent_MiddleIsDown(IntPtr self);
        static extern (C) bool   wxMouseEvent_RightIsDown(IntPtr self);
        static extern (C) bool   wxMouseEvent_Dragging(IntPtr self);
        static extern (C) bool   wxMouseEvent_Moving(IntPtr self);
        static extern (C) bool   wxMouseEvent_Entering(IntPtr self);
        static extern (C) bool   wxMouseEvent_Leaving(IntPtr self);
        static extern (C) void   wxMouseEvent_GetPosition(IntPtr self, ref Point pos);
        static extern (C) void   wxMouseEvent_LogicalPosition(IntPtr self, IntPtr dc, ref Point pos);
        static extern (C) int    wxMouseEvent_GetWheelRotation(IntPtr self);
        static extern (C) int    wxMouseEvent_GetWheelDelta(IntPtr self);
        static extern (C) int    wxMouseEvent_GetLinesPerAction(IntPtr self);
        static extern (C) bool   wxMouseEvent_IsPageScroll(IntPtr self);
		//! \endcond

		//----------------------------------------------------------------------------

    alias MouseEvent wxMouseEvent;
    public class MouseEvent : Event
    {
		public this(IntPtr wxobj) 
            { super(wxobj); }

        public this(EventType mouseType)
            { super(wxMouseEvent_ctor(mouseType)); }

		//----------------------------------------------------------------------------

        public bool IsButton() { return wxMouseEvent_IsButton(wxobj); }
	
	//----------------------------------------------------------------------------

        public bool ButtonDown()
        {
            //get { return wxMouseEvent_ButtonDown(wxobj); }
	    return ButtonDown(MouseButton.wxMOUSE_BTN_ANY);
        }
	
	public bool ButtonDown(MouseButton but)
	{
		return wxMouseEvent_ButtonDown2(wxobj, cast(int)but);
	}
	
	//----------------------------------------------------------------------------
	
	public bool ButtonDClick()
	{
		return ButtonDClick(MouseButton.wxMOUSE_BTN_ANY);
	}

        public bool ButtonDClick(MouseButton but)
        {
            return wxMouseEvent_ButtonDClick(wxobj, cast(int)but);
        }
	
	//----------------------------------------------------------------------------
	
	public bool ButtonUp()
	{
		return ButtonUp(MouseButton.wxMOUSE_BTN_ANY);
	}

        public bool ButtonUp(MouseButton but)
        {
            return wxMouseEvent_ButtonUp(wxobj, cast(int)but);
        }
	
	//----------------------------------------------------------------------------

        public bool Button(int but)
        {
            return wxMouseEvent_Button(wxobj, but);
        }

        public bool ButtonIsDown(int but)
        {
            return wxMouseEvent_ButtonIsDown(wxobj, but);
        }

        public int Button()
        {
            return wxMouseEvent_GetButton(wxobj);
        }

		//----------------------------------------------------------------------------

        public bool ControlDown() { return wxMouseEvent_ControlDown(wxobj); }

        public bool MetaDown() { return wxMouseEvent_MetaDown(wxobj); }

        public bool AltDown() { return wxMouseEvent_AltDown(wxobj); }

        public bool ShiftDown() { return wxMouseEvent_ShiftDown(wxobj); }

		//----------------------------------------------------------------------------

        public bool LeftDown() { return wxMouseEvent_LeftDown(wxobj); }

        public bool MiddleDown() { return wxMouseEvent_MiddleDown(wxobj); }

        public bool RightDown() { return wxMouseEvent_RightDown(wxobj); }

		//----------------------------------------------------------------------------

        public bool LeftUp() { return wxMouseEvent_LeftUp(wxobj); }

        public bool MiddleUp() { return wxMouseEvent_MiddleUp(wxobj); }

        public bool RightUp() { return wxMouseEvent_RightUp(wxobj); }

		//----------------------------------------------------------------------------

        public bool LeftDClick() { return wxMouseEvent_LeftDClick(wxobj); }

        public bool MiddleDClick() { return wxMouseEvent_MiddleDClick(wxobj); }

        public bool RightDClick() { return wxMouseEvent_RightDClick(wxobj); }

		//----------------------------------------------------------------------------

        public bool LeftIsDown() { return wxMouseEvent_LeftIsDown(wxobj); }

        public bool MiddleIsDown() { return wxMouseEvent_MiddleIsDown(wxobj); }

        public bool RightIsDown() { return wxMouseEvent_RightIsDown(wxobj); }

		//----------------------------------------------------------------------------

        public bool Dragging() { return wxMouseEvent_Dragging(wxobj); }

        public bool Moving() { return wxMouseEvent_Moving(wxobj); }

        public bool Entering() { return wxMouseEvent_Entering(wxobj); }

        public bool Leaving() { return wxMouseEvent_Leaving(wxobj); }

		//----------------------------------------------------------------------------

        public Point Position() { 
                Point pos;
                wxMouseEvent_GetPosition(wxobj, pos);
                return pos;
            }

        public Point LogicalPosition(DC dc)
        {
			Point pos;
            wxMouseEvent_LogicalPosition(wxobj, wxObject.SafePtr(dc), pos);
			return pos;
        }

		//----------------------------------------------------------------------------

        public int WheelRotation() { return wxMouseEvent_GetWheelRotation(wxobj); }

        public int WheelDelta() { return wxMouseEvent_GetWheelDelta(wxobj); }

        public int LinesPerAction() { return wxMouseEvent_GetLinesPerAction(wxobj); }

        public bool IsPageScroll() { return wxMouseEvent_IsPageScroll(wxobj); }

		//----------------------------------------------------------------------------
		private static Event New(IntPtr obj) { return new MouseEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_LEFT_UP,                         &MouseEvent.New);
			AddEventType(wxEVT_RIGHT_UP,                        &MouseEvent.New);
			AddEventType(wxEVT_MIDDLE_UP,                       &MouseEvent.New);
			AddEventType(wxEVT_ENTER_WINDOW,                    &MouseEvent.New);
			AddEventType(wxEVT_LEAVE_WINDOW,                    &MouseEvent.New);
			AddEventType(wxEVT_LEFT_DOWN,                       &MouseEvent.New);
			AddEventType(wxEVT_MIDDLE_DOWN,                     &MouseEvent.New);
			AddEventType(wxEVT_RIGHT_DOWN,                      &MouseEvent.New);
			AddEventType(wxEVT_LEFT_DCLICK,                     &MouseEvent.New);
			AddEventType(wxEVT_RIGHT_DCLICK,                    &MouseEvent.New);
			AddEventType(wxEVT_MIDDLE_DCLICK,                   &MouseEvent.New);
			AddEventType(wxEVT_MOUSEWHEEL,                      &MouseEvent.New);
			AddEventType(wxEVT_MOTION,                              &MouseEvent.New);   		}
    }

