//-----------------------------------------------------------------------------
// wxD - SetCursorEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - SetCursorEvent.cs
//
/// The wxSetCursorEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: SetCursorEvent.d,v 1.9 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.SetCursorEvent;
public import wx.common;

public import wx.Event;

public import wx.Cursor;

		//! \cond EXTERN
		static extern (C) IntPtr	wxSetCursorEvent_ctor(int x,int y);
		static extern (C) int		wxSetCursorEvent_GetX(IntPtr self);
		static extern (C) int		wxSetCursorEvent_GetY(IntPtr self);
		static extern (C) void		wxSetCursorEvent_SetCursor(IntPtr self, IntPtr cursor);
		static extern (C) IntPtr	wxSetCursorEvent_GetCursor(IntPtr self);
		static extern (C) bool		wxSetCursorEvent_HasCursor(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias SetCursorEvent wxSetCursorEvent;
	public class SetCursorEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(int x=0,int y=0)
			{ this(wxSetCursorEvent_ctor(x,y)); }

		//-----------------------------------------------------------------------------	
		
		public int X() { return wxSetCursorEvent_GetX(wxobj); }
		
		//-----------------------------------------------------------------------------	
		
		public int Y() { return wxSetCursorEvent_GetY(wxobj); }
		
		//-----------------------------------------------------------------------------	
		
		public Cursor cursor() { return cast(Cursor)FindObject(wxSetCursorEvent_GetCursor(wxobj), &Cursor.New); }
		public void cursor(Cursor value) { wxSetCursorEvent_SetCursor(wxobj, wxObject.SafePtr(value)); }
		
		//-----------------------------------------------------------------------------	
		
		public bool HasCursor() { return wxSetCursorEvent_HasCursor(wxobj); }

		private static Event New(IntPtr obj) { return new SetCursorEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_SET_CURSOR,				&SetCursorEvent.New);
		}
	}
