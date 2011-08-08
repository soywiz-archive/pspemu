//-----------------------------------------------------------------------------
// wxD - Gauge.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Gauge.cs
//
/// The wxGauge wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Gauge.d,v 1.11 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.Gauge;
public import wx.common;
public import wx.Control;

		//! \cond EXTERN
		static extern (C) IntPtr wxGauge_ctor();
		static extern (C) void   wxGauge_dtor(IntPtr self);
		static extern (C) bool   wxGauge_Create(IntPtr self, IntPtr parent, int id, int range, ref Point pos, ref Size size, uint style, IntPtr validator, string name);
		static extern (C) void   wxGauge_SetRange(IntPtr self, int range);
		static extern (C) int    wxGauge_GetRange(IntPtr self);
		static extern (C) void   wxGauge_SetValue(IntPtr self, int pos);
		static extern (C) int    wxGauge_GetValue(IntPtr self);
		static extern (C) void   wxGauge_SetShadowWidth(IntPtr self, int w);
		static extern (C) int    wxGauge_GetShadowWidth(IntPtr self);
		static extern (C) void   wxGauge_SetBezelFace(IntPtr self, int w);
		static extern (C) int    wxGauge_GetBezelFace(IntPtr self);
		static extern (C) bool   wxGauge_AcceptsFocus(IntPtr self);
		static extern (C) bool   wxGauge_IsVertical(IntPtr self);
		//! \endcond
	
		//---------------------------------------------------------------------
		
	alias Gauge wxGauge;
	public class Gauge :  Control
	{
		enum {
			wxGA_HORIZONTAL       = Orientation.wxHORIZONTAL,
			wxGA_VERTICAL         = Orientation.wxVERTICAL,
			wxGA_PROGRESSBAR      = 0x0010,
		}
	
		// Windows only
		public const int wxGA_SMOOTH           = 0x0020;
	
		public const string wxGaugeNameStr = "gauge";
		//---------------------------------------------------------------------
		
		public this(IntPtr wxobj) 
			{ super(wxobj);}

		public this()
			{ super(wxGauge_ctor()); }

		public this(Window parent, int id, int range, Point pos = wxDefaultPosition, Size size = wxDefaultSize, 
				int style = wxGA_HORIZONTAL, Validator validator = null, string name = wxGaugeNameStr)
		{	
			super(wxGauge_ctor());
			if (!Create(parent, id, range, pos, size, style, validator, name)) 
			{
				throw new InvalidOperationException("Failed to create Gauge");
			}
		}
		
		public static wxObject New(IntPtr wxobj) { return new Gauge(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, int range, Point pos = wxDefaultPosition, Size size = wxDefaultSize, 
				int style = wxGA_HORIZONTAL, Validator validator = null, string name = wxGaugeNameStr)
			{ this(parent, Window.UniqueID, range, pos, size, style, validator, name);}
		
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, int range, ref Point pos, 
				ref Size size, int style, Validator validator, 
				string name)
		{
			return wxGauge_Create(wxobj, wxObject.SafePtr(parent), id, range, 
					pos, size, cast(uint)style, 
					wxObject.SafePtr(validator), name);
		}

		//---------------------------------------------------------------------

		public int Range() { return wxGauge_GetRange(wxobj); }
		public void Range(int value) { wxGauge_SetRange(wxobj, value); }

		//---------------------------------------------------------------------
        
		public int Value() { return wxGauge_GetValue(wxobj); }
		public void Value(int value) { wxGauge_SetValue(wxobj, value); }

		//---------------------------------------------------------------------

		public int ShadowWidth() { return wxGauge_GetShadowWidth(wxobj); }
		public void ShadowWidth(int value) { wxGauge_SetShadowWidth(wxobj, value); }

		//---------------------------------------------------------------------

		public int BezelFace() { return wxGauge_GetBezelFace(wxobj); }
		public void BezelFace(int value) { wxGauge_SetBezelFace(wxobj, value); }

		//---------------------------------------------------------------------

		public override bool AcceptsFocus()
		{
			return wxGauge_AcceptsFocus(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public bool IsVertical() { return wxGauge_IsVertical(wxobj); }
	}
