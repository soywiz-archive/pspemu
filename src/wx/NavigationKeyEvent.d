//-----------------------------------------------------------------------------
// wxD - NavigationKeyEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - NavigationKeyEvent.cs
//
/// The wxNavigationKeyEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: NavigationKeyEvent.d,v 1.9 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.NavigationKeyEvent;
public import wx.common;

public import wx.Event;
public import wx.Window;

		//! \cond EXTERN
		static extern (C) IntPtr wxNavigationKeyEvent_ctor();
		static extern (C) bool wxNavigationKeyEvent_GetDirection(IntPtr self);
		static extern (C) void wxNavigationKeyEvent_SetDirection(IntPtr self, bool bForward);
		static extern (C) bool wxNavigationKeyEvent_IsWindowChange(IntPtr self);
		static extern (C) void wxNavigationKeyEvent_SetWindowChange(IntPtr self, bool bIs);
		static extern (C) IntPtr wxNavigationKeyEvent_GetCurrentFocus(IntPtr self);
		static extern (C) void wxNavigationKeyEvent_SetCurrentFocus(IntPtr self, IntPtr win);
		static extern (C) void wxNavigationKeyEvent_SetFlags(IntPtr self, uint flags);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias NavigationKeyEvent wxNavigationKeyEvent;
	public class NavigationKeyEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ this(wxNavigationKeyEvent_ctor()); }
			
		//-----------------------------------------------------------------------------
		
		public bool Direction() { return wxNavigationKeyEvent_GetDirection(wxobj); }
		public void Direction(bool value) { wxNavigationKeyEvent_SetDirection(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public bool WindowChange() { return wxNavigationKeyEvent_IsWindowChange(wxobj); }
		public void WindowChange(bool value) { wxNavigationKeyEvent_SetWindowChange(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public Window CurrentFocus() { return cast(Window)FindObject(wxNavigationKeyEvent_GetCurrentFocus(wxobj), &Window.New); }
		public void CurrentFocus(Window value) { wxNavigationKeyEvent_SetCurrentFocus(wxobj, wxObject.SafePtr(value)); }
		
		//-----------------------------------------------------------------------------
		
		public void Flags(int value) { wxNavigationKeyEvent_SetFlags(wxobj, cast(uint)value); }

		private static Event New(IntPtr obj) { return new NavigationKeyEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_NAVIGATION_KEY,			&NavigationKeyEvent.New);
		}
	}
