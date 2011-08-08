//-----------------------------------------------------------------------------
// wxD - CommandEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - CommandEvent.cs
//
/// The wxCommandEvent wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: CommandEvent.d,v 1.10 2007/01/28 23:06:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.CommandEvent;
public import wx.common;
public import wx.Event;

public import wx.ClientData;

		//! \cond EXTERN
		static extern (C) IntPtr wxCommandEvent_ctor(int type,int winid);
		static extern (C) int    wxCommandEvent_GetSelection(IntPtr self);
		static extern (C) IntPtr wxCommandEvent_GetString(IntPtr self);
		static extern (C) void wxCommandEvent_SetString(IntPtr self, string s);
		static extern (C) bool   wxCommandEvent_IsChecked(IntPtr self);
		static extern (C) bool   wxCommandEvent_IsSelection(IntPtr self);
		static extern (C) int    wxCommandEvent_GetInt(IntPtr self);
		static extern (C) void wxCommandEvent_SetInt(IntPtr self, int i);

		static extern (C) IntPtr wxCommandEvent_GetClientObject(IntPtr self);
		static extern (C) void   wxCommandEvent_SetClientObject(IntPtr self, IntPtr data);
		
		static extern (C) void wxCommandEvent_SetExtraLong(IntPtr self, uint extralong);
		static extern (C) uint wxCommandEvent_GetExtraLong(IntPtr self);
		//! \endcond

		//-----------------------------------------------------------------------------

	alias CommandEvent wxCommandEvent;
	public class CommandEvent : Event
	{

		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(EventType commandType = wxEVT_NULL, int winid = 0)
			{ super(wxCommandEvent_ctor(commandType,winid)); }

		//-----------------------------------------------------------------------------

		public int Selection() { return wxCommandEvent_GetSelection(wxobj); }

		//-----------------------------------------------------------------------------

		public string String() { return cast(string) new wxString(wxCommandEvent_GetString(wxobj), true); }
		public void String(string value) { wxCommandEvent_SetString(wxobj, value); }

		//-----------------------------------------------------------------------------

		public bool IsChecked() { return wxCommandEvent_IsChecked(wxobj); }

		//-----------------------------------------------------------------------------

		public bool IsSelection() { return wxCommandEvent_IsSelection(wxobj); }

		//-----------------------------------------------------------------------------

		public int Int() { return wxCommandEvent_GetInt(wxobj); }
		public void Int(int value) { wxCommandEvent_SetInt(wxobj, value); }

		//-----------------------------------------------------------------------------

		public ClientData ClientObject() { return cast(ClientData)FindObject(wxCommandEvent_GetClientObject(wxobj)); }
		public void ClientObject(ClientData value) { wxCommandEvent_SetClientObject(wxobj, wxObject.SafePtr(value)); }
		
		//-----------------------------------------------------------------------------
		
		public int ExtraLong() { return cast(int)wxCommandEvent_GetExtraLong(wxobj); }
		public void ExtraLong(int value) { wxCommandEvent_SetExtraLong(wxobj, cast(uint)value); }

		private static Event New(IntPtr obj) { return new CommandEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_COMMAND_BUTTON_CLICKED,          &CommandEvent.New);
			AddEventType(wxEVT_COMMAND_MENU_SELECTED,           &CommandEvent.New);
		
			AddEventType(wxEVT_COMMAND_CHECKBOX_CLICKED,        &CommandEvent.New);
		
			AddEventType(wxEVT_COMMAND_LISTBOX_SELECTED,        &CommandEvent.New);
			AddEventType(wxEVT_COMMAND_LISTBOX_DOUBLECLICKED,   &CommandEvent.New);
			AddEventType(wxEVT_COMMAND_CHOICE_SELECTED,         &CommandEvent.New);
			AddEventType(wxEVT_COMMAND_COMBOBOX_SELECTED,       &CommandEvent.New);
			AddEventType(wxEVT_COMMAND_TEXT_UPDATED,            &CommandEvent.New);
			AddEventType(wxEVT_COMMAND_TEXT_ENTER,              &CommandEvent.New);
			AddEventType(wxEVT_COMMAND_RADIOBOX_SELECTED,       &CommandEvent.New);
			AddEventType(wxEVT_COMMAND_RADIOBUTTON_SELECTED,    &CommandEvent.New);
			AddEventType(wxEVT_COMMAND_SLIDER_UPDATED,          &CommandEvent.New);
			AddEventType(wxEVT_COMMAND_SPINCTRL_UPDATED,        &CommandEvent.New);

			AddEventType(wxEVT_COMMAND_TOGGLEBUTTON_CLICKED,    &CommandEvent.New);
			
			AddEventType(wxEVT_COMMAND_CHECKLISTBOX_TOGGLED,    &CommandEvent.New);
		}
	}
