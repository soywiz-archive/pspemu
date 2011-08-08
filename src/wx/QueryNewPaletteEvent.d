//-----------------------------------------------------------------------------
// wxD - QueryNewPaletteEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - QueryNewPaletteEvent.cs
//
/// The wxQueryNewPaletteEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: QueryNewPaletteEvent.d,v 1.9 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.QueryNewPaletteEvent;
public import wx.common;

public import wx.Event;

		//! \cond EXTERN
		static extern (C) IntPtr wxQueryNewPaletteEvent_ctor(int winid);
		static extern (C) bool wxQueryNewPaletteEvent_GetPaletteRealized(IntPtr self);
		static extern (C) void wxQueryNewPaletteEvent_SetPaletteRealized(IntPtr self, bool realized);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias QueryNewPaletteEvent wxQueryNewPaletteEvent;
	public class QueryNewPaletteEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(int winid=0)
			{ this(wxQueryNewPaletteEvent_ctor(winid)); }

		//-----------------------------------------------------------------------------	
		
		public bool Realized() { return wxQueryNewPaletteEvent_GetPaletteRealized(wxobj); }
		public void Realized(bool value) { wxQueryNewPaletteEvent_SetPaletteRealized(wxobj, value); }

		private static Event New(IntPtr obj) { return new QueryNewPaletteEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_QUERY_NEW_PALETTE,			&QueryNewPaletteEvent.New);
		}
	}
