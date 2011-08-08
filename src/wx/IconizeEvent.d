//-----------------------------------------------------------------------------
// wxD - IconizeEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - IconizeEvent.cs
//
/// The wxIconizeEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: IconizeEvent.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.IconizeEvent;
public import wx.common;

public import wx.Event;

		//! \cond EXTERN
		static extern (C) IntPtr wxIconizeEvent_ctor(int winid,bool iconized);
		static extern (C) bool wxIconizeEvent_Iconized(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias IconizeEvent wxIconizeEvent;
	public class IconizeEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(int winid = 0, bool iconized = true)
			{ this(wxIconizeEvent_ctor(winid,iconized)); }

		//-----------------------------------------------------------------------------	
		
		public bool Iconized() { return wxIconizeEvent_Iconized(wxobj); }


		private static Event New(IntPtr obj) { return new IconizeEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_ICONIZE,				&IconizeEvent.New);
		}
	}
