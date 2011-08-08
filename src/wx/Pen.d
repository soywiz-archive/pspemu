//-----------------------------------------------------------------------------
// wxD - Pen.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Pen.cs
//
/// The wxPen wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Pen.d,v 1.9 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.Pen;
public import wx.common;
public import wx.Defs;
public import wx.GDIObject;
public import wx.Colour;

		//! \cond EXTERN
		static extern (C) IntPtr wxGDIObj_GetRedPen();
		static extern (C) IntPtr wxGDIObj_GetCyanPen();
		static extern (C) IntPtr wxGDIObj_GetGreenPen();
		static extern (C) IntPtr wxGDIObj_GetBlackPen();
		static extern (C) IntPtr wxGDIObj_GetWhitePen();
		static extern (C) IntPtr wxGDIObj_GetTransparentPen();
		static extern (C) IntPtr wxGDIObj_GetBlackDashedPen();
		static extern (C) IntPtr wxGDIObj_GetGreyPen();
		static extern (C) IntPtr wxGDIObj_GetMediumGreyPen();
		static extern (C) IntPtr wxGDIObj_GetLightGreyPen();

		static extern (C) IntPtr wxPen_ctor(IntPtr col, int width, FillStyle style);
		static extern (C) IntPtr wxPen_ctorByName(string name, int width, FillStyle style);
	
		static extern (C) IntPtr wxPen_GetColour(IntPtr self);
		static extern (C) void   wxPen_SetColour(IntPtr self, IntPtr col);
	
		static extern (C) void   wxPen_SetWidth(IntPtr self, int width);
		static extern (C) int    wxPen_GetWidth(IntPtr self);
		
		static extern (C) int    wxPen_GetCap(IntPtr self);
		static extern (C) int    wxPen_GetJoin(IntPtr self);
		static extern (C) int    wxPen_GetStyle(IntPtr self);
		static extern (C) bool   wxPen_Ok(IntPtr self);
		static extern (C) void   wxPen_SetCap(IntPtr self, int capStyle);
		static extern (C) void   wxPen_SetJoin(IntPtr self, int join_style);
		static extern (C) void   wxPen_SetStyle(IntPtr self, int style);

		//---------------------------------------------------------------------
		static extern (C) IntPtr wxNullPen_Get();
		//! \endcond

	alias Pen wxPen;
	public class Pen : GDIObject
	{
		public static Pen wxRED_PEN;
		public static Pen wxCYAN_PEN;
		public static Pen wxGREEN_PEN;
		public static Pen wxBLACK_PEN;
		public static Pen wxWHITE_PEN;
		public static Pen wxTRANSPARENT_PEN;
		public static Pen wxBLACK_DASHED_PEN;
		public static Pen wxGREY_PEN;
		public static Pen wxMEDIUM_GREY_PEN;
		public static Pen wxLIGHT_GREY_PEN;
		public static Pen wxNullPen;

/+
		override public void Dispose()
		{
			if (this !== wxRED_PEN
			&&  this !== wxCYAN_PEN
			&&  this !== wxGREEN_PEN
			&&  this !== wxBLACK_PEN
			&&  this !== wxWHITE_PEN
			&&  this !== wxTRANSPARENT_PEN
			&&  this !== wxBLACK_DASHED_PEN
			&&  this !== wxGREY_PEN
			&&  this !== wxMEDIUM_GREY_PEN
			&&  this !== wxLIGHT_GREY_PEN) {
				super.Dispose();
			}
		}
+/
		//---------------------------------------------------------------------

		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(string name) 
			{ this(name, 1, FillStyle.wxSOLID); }
			
		public this(string name, int width) 
			{ this(name, width, FillStyle.wxSOLID); }
			
		public this(string name, int width, FillStyle style) 
			{ super(wxPen_ctorByName(name, width, style)); }

		public this(Colour colour) 
			{ this(colour, 1, FillStyle.wxSOLID); }
			
		public this(Colour colour, int width) 
			{ this(colour, width, FillStyle.wxSOLID); }
			
		public this(Colour col, int width, FillStyle style)
			{ super(wxPen_ctor(wxObject.SafePtr(col), width, style)); }


		//---------------------------------------------------------------------
        
		public Colour colour() { return cast(Colour)FindObject(wxPen_GetColour(wxobj), &Colour.New); }
		public void colour(Colour value) { wxPen_SetColour(wxobj, wxObject.SafePtr(value)); }

		//---------------------------------------------------------------------

		public int Width() { return wxPen_GetWidth(wxobj); }
		public void Width(int value) { wxPen_SetWidth(wxobj, value); }
	
		//---------------------------------------------------------------------
	
		public int Cap() { return wxPen_GetCap(wxobj); }
		public void Cap(int value) { wxPen_SetCap(wxobj, value); }
	
		//---------------------------------------------------------------------
	
		public int Join() { return wxPen_GetJoin(wxobj); }
		public void Join(int value) { wxPen_SetJoin(wxobj, value); }
	
		//---------------------------------------------------------------------
	
		public int Style() { return wxPen_GetStyle(wxobj); }
		public void Style(int value) { wxPen_SetStyle(wxobj, value); }
	
		//---------------------------------------------------------------------
	
		public bool Ok() { return wxPen_Ok(wxobj); }

		static wxObject New(IntPtr ptr) { return new Pen(ptr); }
	}
