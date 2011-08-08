//-----------------------------------------------------------------------------
// wxD - ContextMenuEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - ContextMenuEvent.cs
//
/// The wxContextMenuEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: ContextMenuEvent.d,v 1.10 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.ContextMenuEvent;
public import wx.common;

public import wx.CommandEvent;
public import wx.Window;

		//! \cond EXTERN
		static extern (C) IntPtr wxContextMenuEvent_ctor(int type,int winid, ref Point pos);
		static extern (C) void   wxContextMenuEvent_GetPosition(IntPtr self, ref Point pos);
		static extern (C) void   wxContextMenuEvent_SetPosition(IntPtr self, ref Point pos);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias ContextMenuEvent wxContextMenuEvent;
	public class ContextMenuEvent : CommandEvent
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(EventType type = wxEVT_NULL, int winid = 0,Point pt = Window.wxDefaultPosition)
			{ this(wxContextMenuEvent_ctor(type,winid,pt)); }

		//-----------------------------------------------------------------------------	
		
		public Point Position() { 
				Point p;
				wxContextMenuEvent_GetPosition(wxobj, p); 
				return p;
			}
			
		public void Position(Point value) { wxContextMenuEvent_SetPosition(wxobj, value); }

		private static Event New(IntPtr obj) { return new ContextMenuEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_CONTEXT_MENU,			&ContextMenuEvent.New);
		}
	}
