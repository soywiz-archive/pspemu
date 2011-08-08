//-----------------------------------------------------------------------------
// wxD - UpdateUIEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - UpdateUIEvent.cs
//
/// The wxUpdateUIEvent wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: UpdateUIEvent.d,v 1.10 2007/01/28 23:06:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.UpdateUIEvent;
public import wx.common;
public import wx.CommandEvent;
public import wx.Window;

		//! \cond EXTERN
		static extern (C) IntPtr wxUpdateUIEvent_ctor(int commandId);
		static extern (C) void   wxUpdUIEvt_Enable(IntPtr self, bool enable);
		static extern (C) void   wxUpdUIEvt_Check(IntPtr self, bool check);
		static extern (C) bool   wxUpdateUIEvent_CanUpdate(IntPtr window);
		static extern (C) bool   wxUpdateUIEvent_GetChecked(IntPtr self);
		static extern (C) bool   wxUpdateUIEvent_GetEnabled(IntPtr self);
		static extern (C) bool   wxUpdateUIEvent_GetSetChecked(IntPtr self);
		static extern (C) bool   wxUpdateUIEvent_GetSetEnabled(IntPtr self);
		static extern (C) bool   wxUpdateUIEvent_GetSetText(IntPtr self);
		static extern (C) IntPtr wxUpdateUIEvent_GetText(IntPtr self);
		static extern (C) int    wxUpdateUIEvent_GetMode();
		static extern (C) uint   wxUpdateUIEvent_GetUpdateInterval();
		static extern (C) void   wxUpdateUIEvent_ResetUpdateTime();
		static extern (C) void   wxUpdateUIEvent_SetMode(int mode);
		static extern (C) void   wxUpdateUIEvent_SetText(IntPtr self, string text);
		static extern (C) void   wxUpdateUIEvent_SetUpdateInterval(uint updateInterval);
		//! \endcond

		//-----------------------------------------------------------------------------

	alias UpdateUIEvent wxUpdateUIEvent;
	public class UpdateUIEvent : CommandEvent
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }
			
		public this(int commandId = 0) 
			{ this(wxUpdateUIEvent_ctor(commandId)); }

		//-----------------------------------------------------------------------------

		public void Enabled(bool value) { wxUpdUIEvt_Enable(wxobj, value); }

		//-----------------------------------------------------------------------------
		
		public void Check(bool value) { wxUpdUIEvt_Check(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public static bool CanUpdate(Window window)
		{
			return wxUpdateUIEvent_CanUpdate(wxObject.SafePtr(window));
		}
		
		//-----------------------------------------------------------------------------
		
		public bool Checked() { return wxUpdateUIEvent_GetChecked(wxobj); }
		
		//-----------------------------------------------------------------------------
		
		public bool GetEnabled()
		{
			return wxUpdateUIEvent_GetEnabled(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool SetChecked() { return wxUpdateUIEvent_GetSetChecked(wxobj); }
		
		//-----------------------------------------------------------------------------
		
		public bool SetEnabled() { return wxUpdateUIEvent_GetSetEnabled(wxobj); }
		
		//-----------------------------------------------------------------------------
		
		public bool SetText() { return wxUpdateUIEvent_GetSetText(wxobj); }
		
		//-----------------------------------------------------------------------------
		
		public string Text() { return cast(string) new wxString(wxUpdateUIEvent_GetText(wxobj), true); }
		public void Text(string value) { wxUpdateUIEvent_SetText(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		static UpdateUIMode Mode() { return cast(UpdateUIMode)wxUpdateUIEvent_GetMode(); }
		static void Mode(UpdateUIMode value) { wxUpdateUIEvent_SetMode(cast(int)value); }
		
		//-----------------------------------------------------------------------------
		
		static int UpdateInterval() { return cast(int)wxUpdateUIEvent_GetUpdateInterval(); }
		static void UpdateInterval(int value) { wxUpdateUIEvent_SetUpdateInterval(cast(uint)value); }
		
		//-----------------------------------------------------------------------------
		
		public static void ResetUpdateTime()
		{
			wxUpdateUIEvent_ResetUpdateTime();
		}

		private static Event New(IntPtr obj) { return new UpdateUIEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_UPDATE_UI,                       &UpdateUIEvent.New);
		}
	}
