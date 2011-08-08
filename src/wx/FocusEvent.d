//-----------------------------------------------------------------------------
// wxD - FocusEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - FocusEvent.cs
//
/// The wxFocusEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: FocusEvent.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.FocusEvent;
public import wx.common;

public import wx.Window;
public import wx.Event;

		//! \cond EXTERN
		static extern (C) IntPtr wxFocusEvent_ctor(int type,int winid);
		static extern (C) IntPtr wxFocusEvent_GetWindow(IntPtr self);
		static extern (C) void   wxFocusEvent_SetWindow(IntPtr self, IntPtr win);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias FocusEvent wxFocusEvent;
	public class FocusEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(EventType type = wxEVT_NULL, int winid = 0)
			{ this(wxFocusEvent_ctor(type,winid)); }

		//-----------------------------------------------------------------------------	
		
		public Window window() { return cast(Window)FindObject(wxFocusEvent_GetWindow(wxobj), &Window.New); }
		public void window(Window value) { wxFocusEvent_SetWindow(wxobj, wxObject.SafePtr(value)); }

		private static Event New(IntPtr obj) { return new FocusEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_SET_FOCUS,				&FocusEvent.New);
			AddEventType(wxEVT_KILL_FOCUS,				&FocusEvent.New);
		}
	}
