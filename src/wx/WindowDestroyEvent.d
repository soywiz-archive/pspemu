//-----------------------------------------------------------------------------
// wxD - WindowDestroyEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - WindowDestroyEvent.cs
//
/// The wxWindowDestroyEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: WindowDestroyEvent.d,v 1.9 2006/11/17 15:21:01 afb Exp $
//-----------------------------------------------------------------------------

module wx.WindowDestroyEvent;
public import wx.common;

public import wx.CommandEvent;

public import wx.Window;

		//! \cond EXTERN
		static extern (C) IntPtr wxWindowDestroyEvent_ctor(IntPtr type);
		static extern (C) IntPtr wxWindowDestroyEvent_GetWindow(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias WindowDestroyEvent wxWindowDestroyEvent;
	public class WindowDestroyEvent : CommandEvent
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(Window win = null)
			{ this(wxWindowDestroyEvent_ctor(wxObject.SafePtr(win))); }

		//-----------------------------------------------------------------------------	
		
		public Window Active() { return cast(Window)FindObject(wxWindowDestroyEvent_GetWindow(wxobj), &Window.New); }

		private static Event New(IntPtr obj) { return new WindowDestroyEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_DESTROY,				&WindowDestroyEvent.New);
		}
	}
