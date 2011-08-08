//-----------------------------------------------------------------------------
// wxD - CloseEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - CloseEvent.cs
//
/// The wxCloseEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: CloseEvent.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.CloseEvent;
public import wx.common;
public import wx.Event;

		//! \cond EXTERN
		static extern (C) IntPtr wxCloseEvent_ctor(int type,int winid);
		static extern (C) void wxCloseEvent_SetLoggingOff(IntPtr self, bool logOff);
		static extern (C) bool wxCloseEvent_GetLoggingOff(IntPtr self);
		static extern (C) void wxCloseEvent_Veto(IntPtr self, bool veto);
		static extern (C) void wxCloseEvent_SetCanVeto(IntPtr self, bool canVeto);
		static extern (C) bool wxCloseEvent_CanVeto(IntPtr self);
		static extern (C) bool wxCloseEvent_GetVeto(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias CloseEvent wxCloseEvent;
	public class CloseEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(EventType type = wxEVT_NULL, int winid = 0)
			{ this(wxCloseEvent_ctor(type,winid)); }

		//-----------------------------------------------------------------------------
		
		public bool LoggingOff() { return wxCloseEvent_GetLoggingOff(wxobj); }
		public void LoggingOff(bool value) { wxCloseEvent_SetLoggingOff(wxobj, value); } 
		
		public void Veto()
		{
			Veto(true);
		}
		
		public void Veto(bool veto)
		{
			wxCloseEvent_Veto(wxobj, veto);
		}
		
		public void CanVeto(bool value) { wxCloseEvent_SetCanVeto(wxobj, value); }
		public bool CanVeto() { return wxCloseEvent_CanVeto(wxobj); }
		
		public bool GetVeto() { return wxCloseEvent_GetVeto(wxobj); }

		private static Event New(IntPtr obj) { return new CloseEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_CLOSE_WINDOW,                    &CloseEvent.New);
			AddEventType(wxEVT_END_SESSION,                     &CloseEvent.New);
			AddEventType(wxEVT_QUERY_END_SESSION,               &CloseEvent.New);
		}
	}
