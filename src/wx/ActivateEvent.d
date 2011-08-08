//-----------------------------------------------------------------------------
// wxD - ActivateEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - ActivateEvent.cs
//
/// The wxActivateEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: ActivateEvent.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.ActivateEvent;
public import wx.common;
public import wx.Event;

		//! \cond EXTERN
		static extern (C) IntPtr wxActivateEvent_ctor(int type, bool active,int Id);
		static extern (C) bool wxActivateEvent_GetActive(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias ActivateEvent wxActivateEvent;
	public class ActivateEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(EventType type = wxEVT_NULL, bool active = true, int Id = 0)
			{ this(wxActivateEvent_ctor(type,true,Id)); }

		//-----------------------------------------------------------------------------	
		
		public bool Active() { return wxActivateEvent_GetActive(wxobj); }


		private static Event New(IntPtr obj) { return new ActivateEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_ACTIVATE,                        &ActivateEvent.New);
		}
	}
