//-----------------------------------------------------------------------------
// wxD - RadioButton.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - RadioButton.cs
//
/// The wxRadioButton wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//-----------------------------------------------------------------------------

module wx.RadioButton;
public import wx.common;
public import wx.Control;

		//! \cond EXTERN
		static extern (C) IntPtr wxRadioButton_ctor();
		static extern (C) bool   wxRadioButton_Create(IntPtr self, IntPtr parent, int id, string label, ref Point pos, ref Size size, uint style, IntPtr val, string name);
		static extern (C) bool   wxRadioButton_GetValue(IntPtr self);
		static extern (C) void   wxRadioButton_SetValue(IntPtr self, bool state);
		//! \endcond
	
		//---------------------------------------------------------------------
		
	alias RadioButton wxRadioButton;
	public class RadioButton : Control 
	{
		public const int wxRB_GROUP     = 0x0004;
		public const int wxRB_SINGLE    = 0x0008;
		
		public const string wxRadioButtonNameStr = "radioButton";
		//---------------------------------------------------------------------
	
		public this(IntPtr wxobj) 
			{ super(wxobj);}
		
		public this()
			{ super (wxRadioButton_ctor()); }

		public this(Window parent, int id, string label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, Validator val = null, string name = wxRadioButtonNameStr)
		{
			super(wxRadioButton_ctor());
			if (!wxRadioButton_Create(wxobj, wxObject.SafePtr(parent), id,
					label, pos, size, cast(uint)style, wxObject.SafePtr(val), name))
			{
				throw new InvalidOperationException("Failed to create RadioButton");
			}
		}
		
		public static wxObject New(IntPtr wxobj) { return new RadioButton(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, string label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, Validator val = null, string name = wxRadioButtonNameStr)
			{ this(parent, Window.UniqueID, label, pos, size, style, val, name);}

		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, string label, ref Point pos, ref Size size, int style, Validator val, string name)
		{
			return wxRadioButton_Create(wxobj, wxObject.SafePtr(parent), id,
					label, pos, size, cast(uint)style, wxObject.SafePtr(val), name);
		}

		//---------------------------------------------------------------------

		public bool Value() { return wxRadioButton_GetValue(wxobj); }
		public void Value(bool value) { wxRadioButton_SetValue(wxobj, value); }

		//---------------------------------------------------------------------

		public void Select_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_RADIOBUTTON_SELECTED, ID, value, this); }
		public void Select_Remove(EventListener value) { RemoveHandler(value, this); }
	}
