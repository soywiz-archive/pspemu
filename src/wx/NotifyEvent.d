//-----------------------------------------------------------------------------
// wxD - NotifyEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
//
/// The wxNotifyEvent wrapper class
//
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: NotifyEvent.d,v 1.6 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.NotifyEvent;
public import wx.common;
public import wx.CommandEvent;


		//! \cond EXTERN
		static extern (C) IntPtr wxNotifyEvent_ctor(EventType commandtype,int winid);
		static extern (C) void   wxNotifyEvent_Veto(IntPtr self);
		static extern (C) void   wxNotifyEvent_Allow(IntPtr self);
		static extern (C) bool   wxNotifyEvent_IsAllowed(IntPtr self);
		//! \endcond

		//-----------------------------------------------------------------------------

	alias NotifyEvent wxNotifyEvent;
	public class NotifyEvent : CommandEvent
	{

		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(EventType commandtype = wxEVT_NULL,int winid = 0)
		{
			this(wxNotifyEvent_ctor(commandtype,winid));
		}

		//-----------------------------------------------------------------------------

		public void Veto() { wxNotifyEvent_Veto(wxobj); }
		public void Allow() { wxNotifyEvent_Veto(wxobj); }
		public void IsAllowed() { return wxNotifyEvent_IsAllowed(wxobj); }
	}
