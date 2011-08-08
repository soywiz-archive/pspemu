//-----------------------------------------------------------------------------
// wxD - SpinCtrl.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - SpinCtrl.cs
//
/// The wxSpinCtrl wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: SpinCtrl.d,v 1.12 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.SpinCtrl;
public import wx.common;
public import wx.Control;

		//! \cond EXTERN
		static extern (C) IntPtr wxSpinCtrl_ctor();
		static extern (C) bool   wxSpinCtrl_Create(IntPtr self, IntPtr parent, int id, string value, ref Point pos, ref Size size, uint style, int min, int max, int initial, string name);
		static extern (C) int    wxSpinCtrl_GetValue(IntPtr self);
		static extern (C) int    wxSpinCtrl_GetMin(IntPtr self);
		static extern (C) int    wxSpinCtrl_GetMax(IntPtr self);
		static extern (C) void   wxSpinCtrl_SetValueStr(IntPtr self, string value);
		static extern (C) void   wxSpinCtrl_SetValue(IntPtr self, int val);
		static extern (C) void   wxSpinCtrl_SetRange(IntPtr self, int min, int max);
		//! \endcond
	
		//---------------------------------------------------------------------
		
	alias SpinCtrl wxSpinCtrl;
	public class SpinCtrl : Control 
	{
		// These are duplicated in SpinButton.cs (for easier access)
		public const int wxSP_HORIZONTAL       = Orientation.wxHORIZONTAL;
		public const int wxSP_VERTICAL         = Orientation.wxVERTICAL;
		public const int wxSP_ARROW_KEYS       = 0x1000;
		public const int wxSP_WRAP             = 0x2000;
	
		//---------------------------------------------------------------------
		
		public this(IntPtr wxobj) 
			{ super(wxobj);}

		public this()
			{ super(wxSpinCtrl_ctor()); }

		public this(Window parent,
			int id /*= wxID_ANY*/,
			string value = "",
			Point pos = wxDefaultPosition,
			Size size = wxDefaultSize,
			int style = wxSP_ARROW_KEYS,
			int min = 0, int max = 100, int initial = 0,
			string name = "SpinCtrl")
		{
			super(wxSpinCtrl_ctor());
			if(!Create(parent, id, value, pos, size, style, min, max, initial, name))
			{
				throw new InvalidOperationException("Failed to create SpinCtrl");
			}
		}
		
		public static wxObject New(IntPtr wxobj) { return new SpinCtrl(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent,
			string value = "",
			Point pos = wxDefaultPosition,
			Size size = wxDefaultSize,
			int style = wxSP_ARROW_KEYS,
			int min = 0, int max = 100, int initial = 0,
			string name = "SpinCtrl")
			{ this(parent, Window.UniqueID, value, pos, size, style, min, max, initial, name);}
		
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, string value, Point pos, Size size, int style, int min, int max, int initial, string name)
		{
			return wxSpinCtrl_Create(wxobj, wxObject.SafePtr(parent), id, 
					value, pos, size, cast(uint)style, min,
					max, initial, name);
		}

		//---------------------------------------------------------------------

		public int Value() { return wxSpinCtrl_GetValue(wxobj); }
		public void Value(int value) { wxSpinCtrl_SetValue(wxobj, value); }

		public void SetValue(string val)
		{
			wxSpinCtrl_SetValueStr(wxobj, val);
		}

		//---------------------------------------------------------------------
        
		public int Max() { return wxSpinCtrl_GetMax(wxobj); }

		public int Min() { return wxSpinCtrl_GetMin(wxobj); }

		public void SetRange(int min, int max)
		{
			wxSpinCtrl_SetRange(wxobj, min, max);
		}

		//---------------------------------------------------------------------

		public override void UpdateUI_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_SPINCTRL_UPDATED, ID, value, this); }
		public override void UpdateUI_Remove(EventListener value) { RemoveHandler(value, this); }
	}

