//-----------------------------------------------------------------------------
// wxD - PaintEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - PaintEvent.cs
//
/// The wxPaintEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: PaintEvent.d,v 1.9 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.PaintEvent;
public import wx.common;

public import wx.Event;

		//! \cond EXTERN
		static extern (C) IntPtr wxPaintEvent_ctor(int Id);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias PaintEvent wxPaintEvent;
	public class PaintEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(int Id=0)
			{ this(wxPaintEvent_ctor(Id)); }
	}
