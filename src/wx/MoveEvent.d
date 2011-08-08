//-----------------------------------------------------------------------------
// wxD - MoveEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - MoveEvent.cs
//
/// The wxMoveEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: MoveEvent.d,v 1.9 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.MoveEvent;
public import wx.common;
public import wx.Event;

		//! \cond EXTERN
		static extern (C) IntPtr wxMoveEvent_ctor();
		static extern (C) IntPtr wxMoveEvent_GetPosition(IntPtr self, out Point point);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias MoveEvent wxMoveEvent;
	public class MoveEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ this(wxMoveEvent_ctor()); }

		//-----------------------------------------------------------------------------	
		
		public Point Position() {
				Point point;
				wxMoveEvent_GetPosition(wxobj, point);
				return point;
			}

		private static Event New(IntPtr obj) { return new MoveEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_MOVE,                            &MoveEvent.New);
		}
	}
