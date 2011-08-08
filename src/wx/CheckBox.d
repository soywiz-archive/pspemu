//-----------------------------------------------------------------------------
// wxD - CheckBox.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - CheckBox.cs
//
/// The wxCheckBox wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: CheckBox.d,v 1.10 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.CheckBox;
public import wx.common;
public import wx.Control;

	public enum CheckBoxState
	{
		wxCHK_UNCHECKED,
		wxCHK_CHECKED,
		wxCHK_UNDETERMINED
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxCheckBox_ctor();
		static extern (C) bool   wxCheckBox_Create(IntPtr self, IntPtr parent, int id, string label, ref Point pos, ref Size size, uint style, IntPtr val, string name);
		static extern (C) bool   wxCheckBox_GetValue(IntPtr self);
		static extern (C) void   wxCheckBox_SetValue(IntPtr self, bool state);
		static extern (C) bool   wxCheckBox_IsChecked(IntPtr self);
		
		static extern (C) CheckBoxState wxCheckBox_Get3StateValue(IntPtr self);
		static extern (C) void wxCheckBox_Set3StateValue(IntPtr self, CheckBoxState state);
		static extern (C) bool wxCheckBox_Is3State(IntPtr self);
		static extern (C) bool wxCheckBox_Is3rdStateAllowedForUser(IntPtr self);
		//! \endcond

		//---------------------------------------------------------------------
		
	alias CheckBox wxCheckBox;
	public class CheckBox : Control
	{
		public const int wxCHK_2STATE           = 0x0000;
		public const int wxCHK_3STATE           = 0x1000;
		public const int wxCHK_ALLOW_3RD_STATE_FOR_USER           = 0x2000;
		public const string wxCheckBoxNameStr = "checkbox";
	
		public this(IntPtr wxobj) 
			{ super(wxobj);}
			
		public this()
			{ this(wxCheckBox_ctor()); }

		public this(Window parent, int id, string label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style =0, Validator val=null, string name = wxCheckBoxNameStr)
		{
			this(wxCheckBox_ctor());
			if (!wxCheckBox_Create(wxobj, wxObject.SafePtr(parent), id,
			                       label, pos, size, cast(uint)style, wxObject.SafePtr(val), name))
			{
				throw new InvalidOperationException("failed to create checkbox");
			}
		}
		
		public static wxObject New(IntPtr wxobj)
		{
			return new CheckBox(wxobj);
		}

		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, string label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style =0, Validator val=null, string name = wxCheckBoxNameStr)
			{ this(parent, Window.UniqueID, label, pos, size, style, val, name);}
		
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, string label, ref Point pos, ref Size size,
			int style, Validator val, string name)
		{
			return wxCheckBox_Create(wxobj, wxObject.SafePtr(parent), id,
			                       label, pos, size, cast(uint)style, wxObject.SafePtr(val), name);
		}

		//---------------------------------------------------------------------

		public bool Value() { return wxCheckBox_GetValue(wxobj); }
		public void Value(bool value) { wxCheckBox_SetValue(wxobj, value); }

		//---------------------------------------------------------------------

		public bool IsChecked() { return wxCheckBox_IsChecked(wxobj); }
		
		//---------------------------------------------------------------------
		
		public CheckBoxState ThreeStateValue() { return wxCheckBox_Get3StateValue(wxobj); }
		public void ThreeStateValue(CheckBoxState value) { wxCheckBox_Set3StateValue(wxobj, value); }
		
		//---------------------------------------------------------------------
		
		public bool Is3State()
		{
			return wxCheckBox_Is3State(wxobj);
		}

		//---------------------------------------------------------------------
		
		public bool Is3rdStateAllowedForUser()
		{
			return wxCheckBox_Is3rdStateAllowedForUser(wxobj);
		}
		
		//---------------------------------------------------------------------
        
		public void Clicked_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_CHECKBOX_CLICKED, ID, value, this); }
		public void Clicked_Remove(EventListener value) { RemoveHandler(value, this); }
	}
