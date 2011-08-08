//-----------------------------------------------------------------------------
// wxD - IdleEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - IdleEvent.cs
//
/// The wxIdleEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: IdleEvent.d,v 1.9 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.IdleEvent;
public import wx.common;

public import wx.Event;
public import wx.Window;

	public enum IdleMode
	{
		wxIDLE_PROCESS_ALL,
		wxIDLE_PROCESS_SPECIFIED
	}
	
	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxIdleEvent_ctor();
		static extern (C) void   wxIdleEvent_RequestMore(IntPtr self, bool needMore);
		static extern (C) bool   wxIdleEvent_MoreRequested(IntPtr self);
		
		static extern (C) void   wxIdleEvent_SetMode(IdleMode mode);
		static extern (C) IdleMode wxIdleEvent_GetMode();
		static extern (C) bool   wxIdleEvent_CanSend(IntPtr win);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias IdleEvent wxIdleEvent;
	public class IdleEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ this(wxIdleEvent_ctor()); }

		//-----------------------------------------------------------------------------	
		
		public void RequestMore()
		{
			RequestMore(true);
		}
		
		public void RequestMore(bool needMore)
		{
			wxIdleEvent_RequestMore(wxobj, needMore);
		}
		
		//-----------------------------------------------------------------------------	
		
		public bool MoreRequested()
		{
			return wxIdleEvent_MoreRequested(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		static IdleMode Mode() { return wxIdleEvent_GetMode(); }
		static void Mode(IdleMode value) { wxIdleEvent_SetMode(value); }
		
		//-----------------------------------------------------------------------------
		
		public static bool CanSend(Window win)
		{
			return wxIdleEvent_CanSend(wxObject.SafePtr(win));
		}

		private static Event New(IntPtr obj) { return new IdleEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_IDLE, 				&IdleEvent.New);
		}
	}
