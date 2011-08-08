//-----------------------------------------------------------------------------
// wxD - DisplayChangedEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - DisplayChangedEvent.cs
//
/// The wxDisplayChangedEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: DisplayChangedEvent.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.DisplayChangedEvent;
public import wx.common;

public import wx.Event;

		//! \cond EXTERN
		static extern (C) IntPtr wxDisplayChangedEvent_ctor();
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias DisplayChangedEvent wxDisplayChangedEvent;
	public class DisplayChangedEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ this(wxDisplayChangedEvent_ctor()); }

		private static Event New(IntPtr obj) { return new DisplayChangedEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_DISPLAY_CHANGED,			&DisplayChangedEvent.New);
		}
	}
