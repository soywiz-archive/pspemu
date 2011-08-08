//-----------------------------------------------------------------------------
// wxD - MouseCaptureChangedEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - MouseCaptureChangedEvent.cs
//
/// The wxMouseCaptureChangedEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: MouseCaptureChangedEvent.d,v 1.9 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.MouseCaptureChangedEvent;
public import wx.common;

public import wx.Event;

public import wx.Window;

		//! \cond EXTERN
		static extern (C) IntPtr wxMouseCaptureChangedEvent_ctor(int winid,IntPtr gainedCapture);
		static extern (C) IntPtr wxMouseCaptureChangedEvent_GetCapturedWindow(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias MouseCaptureChangedEvent wxMouseCaptureChangedEvent;
	public class MouseCaptureChangedEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(int winid = 0, Window gainedCapture = null)
			{ this(wxMouseCaptureChangedEvent_ctor(winid,wxObject.SafePtr(gainedCapture))); }

		//-----------------------------------------------------------------------------	
		
		public Window CapturedWindow() { return cast(Window)FindObject(wxMouseCaptureChangedEvent_GetCapturedWindow(wxobj), &Window.New); }

		private static Event New(IntPtr obj) { return new MouseCaptureChangedEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_MOUSE_CAPTURE_CHANGED,		&MouseCaptureChangedEvent.New);
		}
	}
