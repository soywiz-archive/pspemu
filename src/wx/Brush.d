//-----------------------------------------------------------------------------
// wxD - Brush.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - Brush.cs
//
/// The wxBrush wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Brush.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.Brush;
public import wx.common;
public import wx.Bitmap;

		//! \cond EXTERN
		static extern (C) IntPtr wxBLUE_BRUSH_Get();
		static extern (C) IntPtr wxGREEN_BRUSH_Get();
		static extern (C) IntPtr wxWHITE_BRUSH_Get();
		static extern (C) IntPtr wxBLACK_BRUSH_Get();
		static extern (C) IntPtr wxGREY_BRUSH_Get();
		static extern (C) IntPtr wxMEDIUM_GREY_BRUSH_Get();
		static extern (C) IntPtr wxLIGHT_GREY_BRUSH_Get();
		static extern (C) IntPtr wxTRANSPARENT_BRUSH_Get();
		static extern (C) IntPtr wxCYAN_BRUSH_Get();
		static extern (C) IntPtr wxRED_BRUSH_Get();
		
        	static extern (C) IntPtr wxBrush_ctor();
		static extern (C) bool   wxBrush_Ok(IntPtr self);
		static extern (C) FillStyle wxBrush_GetStyle(IntPtr self);
		static extern (C) void   wxBrush_SetStyle(IntPtr self, FillStyle style);
		static extern (C) IntPtr wxBrush_GetStipple(IntPtr self);
		static extern (C) void   wxBrush_SetStipple(IntPtr self, IntPtr stipple);
        	static extern (C) IntPtr wxBrush_GetColour(IntPtr self);
		static extern (C) void   wxBrush_SetColour(IntPtr self, IntPtr col);
		//! \endcond

		//---------------------------------------------------------------------

	alias Brush wxBrush;
	public class Brush : GDIObject
	{
		public static Brush wxBLUE_BRUSH;
		public static Brush wxGREEN_BRUSH;
		public static Brush wxWHITE_BRUSH;
		public static Brush wxBLACK_BRUSH;
		public static Brush wxGREY_BRUSH;
		public static Brush wxMEDIUM_GREY_BRUSH;
		public static Brush wxLIGHT_GREY_BRUSH;
		public static Brush wxTRANSPARENT_BRUSH;
		public static Brush wxCYAN_BRUSH;
		public static Brush wxRED_BRUSH;
		public static Brush wxNullBrush;

/+
		override public void Dispose()
		{
			if (this !== wxBLUE_BRUSH
			&&  this !== wxGREEN_BRUSH
			&&  this !== wxWHITE_BRUSH
			&&  this !== wxBLACK_BRUSH
			&&  this !== wxGREY_BRUSH
			&&  this !== wxMEDIUM_GREY_BRUSH
			&&  this !== wxLIGHT_GREY_BRUSH
			&&  this !== wxTRANSPARENT_BRUSH
			&&  this !== wxCYAN_BRUSH
			&&  this !== wxRED_BRUSH) {
				super.Dispose();
			}
		}
+/
		//---------------------------------------------------------------------
        
		public this()
			{ this(wxBrush_ctor()); }

		public this(IntPtr wxobj)
			{ super(wxobj); }

		public this(Colour colour) 
			{ this(colour, FillStyle.wxSOLID); }
			
		public this(Colour colour, FillStyle style)
		{
			this();
			this.colour = colour;
			Style = style;
		}

		public this(Bitmap stippleBitmap) 
		{
			this();
			Stipple = stippleBitmap;
		}

		public this(string name) 
			{ this(name, FillStyle.wxSOLID); }
			
		public this(string name, FillStyle style) 
		{
			this(); 
			this.colour = new Colour(name);
			Style = style;
		}

		//---------------------------------------------------------------------

		public bool Ok() 
		{
			return wxBrush_Ok(wxobj);
		}

		//---------------------------------------------------------------------

		public FillStyle Style() { return wxBrush_GetStyle(wxobj); }
		public void Style(FillStyle value) { wxBrush_SetStyle(wxobj, value); }

		//---------------------------------------------------------------------

		public Bitmap Stipple() { return cast(Bitmap)FindObject(wxBrush_GetStipple(wxobj), &Bitmap.New); }
		public void Stipple(Bitmap value) { wxBrush_SetStipple(wxobj, wxObject.SafePtr(value)); }

		//---------------------------------------------------------------------

		public Colour colour() { return new Colour(wxBrush_GetColour(wxobj), true); }
		public void colour(Colour value){ wxBrush_SetColour(wxobj, wxObject.SafePtr(value)); }
	}
