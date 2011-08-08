//-----------------------------------------------------------------------------
// wxD - PaletteChangedEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - PaletteChangedEvent.cs
//
/// The wxPaletteChangedEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: PaletteChangedEvent.d,v 1.9 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.PaletteChangedEvent;
public import wx.common;

public import wx.Event;

public import wx.Window;

		//! \cond EXTERN
		static extern (C) IntPtr wxPaletteChangedEvent_ctor(int winid);
		static extern (C) void wxPaletteChangedEvent_SetChangedWindow(IntPtr self, IntPtr win);
		static extern (C) IntPtr wxPaletteChangedEvent_GetChangedWindow(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias PaletteChangedEvent wxPaletteChangedEvent;
	public class PaletteChangedEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(int winid=0)
			{ this(wxPaletteChangedEvent_ctor(winid)); }

		//-----------------------------------------------------------------------------	
		
		public Window ChangedWindow() { return cast(Window)FindObject(wxPaletteChangedEvent_GetChangedWindow(wxobj), &Window.New); }
		public void ChangedWindow(Window value) { wxPaletteChangedEvent_SetChangedWindow(wxobj, wxObject.SafePtr(value)); }

		private static Event New(IntPtr obj) { return new PaletteChangedEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_PALETTE_CHANGED,			&PaletteChangedEvent.New);
		}
	}
