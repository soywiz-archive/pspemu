//-----------------------------------------------------------------------------
// wxD - RadioBox.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - RadioBox.cs
//
/// The wxRadioBox wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: RadioBox.d,v 1.14 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.RadioBox;
public import wx.common;
public import wx.Control;

		//! \cond EXTERN
		static extern (C) IntPtr wxRadioBox_ctor();
		static extern (C) bool   wxRadioBox_Create(IntPtr self, IntPtr parent, int id,
		                                                           string label, ref Point pos, ref Size size,
		                                                           int n, string* choices, int majorDimension,
		                                                           uint style, IntPtr val, string name);

		static extern (C) void   wxRadioBox_SetSelection(IntPtr self, int n);
		static extern (C) int    wxRadioBox_GetSelection(IntPtr self);

		static extern (C) IntPtr wxRadioBox_GetStringSelection(IntPtr self);
		static extern (C) bool   wxRadioBox_SetStringSelection(IntPtr self, string s);

		static extern (C) int    wxRadioBox_GetCount(IntPtr self);
		static extern (C) int    wxRadioBox_FindString(IntPtr self, string s);

		static extern (C) IntPtr wxRadioBox_GetString(IntPtr self, int n);
		static extern (C) void   wxRadioBox_SetString(IntPtr self, int n, string label);

		static extern (C) void   wxRadioBox_Enable(IntPtr self, int n, bool enable);
		static extern (C) void   wxRadioBox_Show(IntPtr self, int n, bool show);
		
		static extern (C) IntPtr wxRadioBox_GetLabel(IntPtr self);
		static extern (C) void   wxRadioBox_SetLabel(IntPtr self, string label);
		//! \endcond

		//---------------------------------------------------------------------
		
	alias RadioBox wxRadioBox;
	public class RadioBox : Control
	{
		enum {
			wxRA_LEFTTORIGHT    = 0x0001,
			wxRA_TOPTOBOTTOM    = 0x0002,
			wxRA_SPECIFY_COLS   = Orientation.wxHORIZONTAL,
			wxRA_SPECIFY_ROWS   = Orientation.wxVERTICAL,
			wxRA_HORIZONTAL     = Orientation.wxHORIZONTAL,
			wxRA_VERTICAL       = Orientation.wxVERTICAL,
		}

		public const string wxRadioBoxNameStr = "radioBox";
		//---------------------------------------------------------------------
        
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this(Window parent, int id, string label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, string[] choices = null, int majorDimension = 0, int style = wxRA_HORIZONTAL, Validator val = null, string name = wxRadioBoxNameStr)
		{
			super(wxRadioBox_ctor());
			if (!wxRadioBox_Create(wxobj, wxObject.SafePtr(parent), id, label, pos, size,
			                       choices.length, choices.ptr, majorDimension, cast(uint)style, wxObject.SafePtr(val), name))
			{
				throw new InvalidOperationException("failed to create checkbox");
			}
		}
		
		public static wxObject New(IntPtr wxobj) { return new RadioBox(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, string label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, string[] choices = null, int majorDimension = 0, int style = wxRA_HORIZONTAL, Validator val = null, string name = wxRadioBoxNameStr)
			{ this(parent, Window.UniqueID, label, pos, size, choices, majorDimension, style, val, name);}

		//---------------------------------------------------------------------

		public void Selection(int value) { wxRadioBox_SetSelection(wxobj, value); }
		public int Selection() { return wxRadioBox_GetSelection(wxobj); }

		public void StringSelection(string value) { wxRadioBox_SetStringSelection(wxobj, value); }
		public string StringSelection() { return cast(string) new wxString(wxRadioBox_GetStringSelection(wxobj), true); }

		//---------------------------------------------------------------------

		public int Count() { return wxRadioBox_GetCount(wxobj); }

		//---------------------------------------------------------------------

		public int FindString(string s)
		{
			return wxRadioBox_FindString(wxobj, s);
		}

		//---------------------------------------------------------------------

		public string GetString(int n)
		{
			return cast(string) new wxString(wxRadioBox_GetString(wxobj, n), true);
		}

		public void SetString(int n, string label)
		{
			wxRadioBox_SetString(wxobj, n, label);
		}

		//---------------------------------------------------------------------

		public void Enable(int n, bool enable)
		{
			wxRadioBox_Enable(wxobj, n, enable);
		}

		public void Show(int n, bool show)
		{
			wxRadioBox_Show(wxobj, n , show);
		}

		//---------------------------------------------------------------------
		
		public override string Label() { return cast(string) new wxString(wxRadioBox_GetLabel(wxobj), true); }
		public override void Label(string value) { wxRadioBox_SetLabel(wxobj, value); }
		
		//---------------------------------------------------------------------

		public void Select_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_RADIOBOX_SELECTED, ID, value, this); }
		public void Select_Remove(EventListener value) { RemoveHandler(value, this); }
	}
