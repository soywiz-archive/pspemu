//-----------------------------------------------------------------------------
// wxD - InitDialogEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - InitDialogEvent.cs
//
/// The wxInitDialogEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: InitDialogEvent.d,v 1.9 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.InitDialogEvent;
public import wx.common;
public import wx.Event;

		//! \cond EXTERN
		static extern (C) IntPtr wxInitDialogEvent_ctor(int Id);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias InitDialogEvent wxInitDialogEvent;
	public class InitDialogEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }
			
		public this(int Id = 0)
			{ this(wxInitDialogEvent_ctor(Id)); }

		private static Event New(IntPtr obj) { return new InitDialogEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_INIT_DIALOG,				&InitDialogEvent.New);
		}
	}
