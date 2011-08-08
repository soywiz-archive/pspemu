//-----------------------------------------------------------------------------
// wxD - ActivateEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - ActivateEvent.cs
//
/// The wxActivateEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: GdiCommon.d,v 1.11 2007/02/01 00:09:34 afb Exp $
//-----------------------------------------------------------------------------

module wx.GdiCommon;
public import wx.common;
public import wx.Bitmap;
public import wx.Cursor;
public import wx.Icon;
public import wx.Pen;
public import wx.Brush;
public import wx.Font;
public import wx.Colour;

		//! \cond EXTERN
		static extern (C) IntPtr wxSTANDARD_CURSOR_Get();
		static extern (C) IntPtr wxHOURGLASS_CURSOR_Get();
		static extern (C) IntPtr wxCROSS_CURSOR_Get();
		
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

		static extern (C) IntPtr wxNullBitmap_Get();
		static extern (C) IntPtr wxNullIcon_Get();
		static extern (C) IntPtr wxNullCursor_Get();
		static extern (C) IntPtr wxNullPen_Get();
		static extern (C) IntPtr wxNullBrush_Get();
		static extern (C) IntPtr wxNullPalette_Get();
		static extern (C) IntPtr wxNullFont_Get();
		static extern (C) IntPtr wxNullColour_Get();
		//! \endcond
		

	void InitializeStockObjects()
	{
			Cursor.wxSTANDARD_CURSOR = new Cursor(wxSTANDARD_CURSOR_Get());
			Cursor.wxHOURGLASS_CURSOR = new Cursor(wxHOURGLASS_CURSOR_Get());
			Cursor.wxCROSS_CURSOR = new Cursor(wxCROSS_CURSOR_Get());

			Pen.wxRED_PEN = new Pen(wxGDIObj_GetRedPen());
			Pen.wxCYAN_PEN = new Pen(wxGDIObj_GetCyanPen());
			Pen.wxGREEN_PEN = new Pen(wxGDIObj_GetGreenPen());
			Pen.wxBLACK_PEN = new Pen(wxGDIObj_GetBlackPen());
			Pen.wxWHITE_PEN = new Pen(wxGDIObj_GetWhitePen());
			Pen.wxTRANSPARENT_PEN = new Pen(wxGDIObj_GetTransparentPen());
			Pen.wxBLACK_DASHED_PEN = new Pen(wxGDIObj_GetBlackDashedPen());
			Pen.wxGREY_PEN = new Pen(wxGDIObj_GetGreyPen());
			Pen.wxMEDIUM_GREY_PEN = new Pen(wxGDIObj_GetMediumGreyPen());
			Pen.wxLIGHT_GREY_PEN = new Pen(wxGDIObj_GetLightGreyPen());

			Brush.wxBLUE_BRUSH = new Brush(wxBLUE_BRUSH_Get());
			Brush.wxGREEN_BRUSH = new Brush(wxGREEN_BRUSH_Get());
			Brush.wxWHITE_BRUSH = new Brush(wxWHITE_BRUSH_Get());
			Brush.wxBLACK_BRUSH = new Brush(wxBLACK_BRUSH_Get());
			Brush.wxGREY_BRUSH = new Brush(wxGREY_BRUSH_Get());
			Brush.wxMEDIUM_GREY_BRUSH = new Brush(wxMEDIUM_GREY_BRUSH_Get());
			Brush.wxLIGHT_GREY_BRUSH = new Brush(wxLIGHT_GREY_BRUSH_Get());
			Brush.wxTRANSPARENT_BRUSH = new Brush(wxTRANSPARENT_BRUSH_Get());
			Brush.wxCYAN_BRUSH = new Brush(wxCYAN_BRUSH_Get());
			Brush.wxRED_BRUSH = new Brush(wxRED_BRUSH_Get());

			Colour.wxBLACK       = new Colour("Black");
			Colour.wxWHITE       = new Colour("White");
			Colour.wxRED         = new Colour("Red");
			Colour.wxBLUE        = new Colour("Blue");
			Colour.wxGREEN       = new Colour("Green");
			Colour.wxCYAN        = new Colour("Cyan");
			Colour.wxLIGHT_GREY  = new Colour("Light Gray");

			Bitmap.wxNullBitmap = new Bitmap(wxNullBitmap_Get());
			Icon.wxNullIcon = new Icon(wxNullIcon_Get());
			Cursor.wxNullCursor = new Cursor(wxNullCursor_Get());
			Pen.wxNullPen = new Pen(wxNullPen_Get());
			Brush.wxNullBrush = new Brush(wxNullBrush_Get());
			Palette.wxNullPalette = new Palette(wxNullPalette_Get());
			Font.wxNullFont = new Font(wxNullFont_Get());
			Colour.wxNullColour = new Colour(wxNullColour_Get());
	}

	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxColourDatabase_ctor();
		static extern (C) void wxColourDataBase_dtor(IntPtr self);
		static extern (C) IntPtr wxColourDatabase_Find(IntPtr self, string name);
		static extern (C) IntPtr wxColourDatabase_FindName(IntPtr self, IntPtr colour);
		static extern (C) void wxColourDatabase_AddColour(IntPtr self, string name, IntPtr colour);
		//! \endcond
		
		//-----------------------------------------------------------------------------
	
	alias ColourDatabase wxColourDatabase;
	public class ColourDatabase : wxObject
	{
		public this(IntPtr wxobj)
		{
			super(wxobj);
		}
		
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}
			
		public this()
			{ this(wxColourDatabase_ctor(), true);}
			
		//---------------------------------------------------------------------
				
		override protected void dtor() { wxColourDataBase_dtor(wxobj); }
			
		//-----------------------------------------------------------------------------
			
		public Colour Find(string name)
		{
			return new Colour(wxColourDatabase_Find(wxobj, name), true);
		}
		
		//-----------------------------------------------------------------------------
		
		public string FindName(Colour colour)
		{
			return cast(string) new wxString(wxColourDatabase_FindName(wxobj, wxObject.SafePtr(colour)), true);
		}
		
		//-----------------------------------------------------------------------------
		
		public void AddColour(string name, Colour colour)
		{
			wxColourDatabase_AddColour(wxobj, name, wxObject.SafePtr(colour));
		}
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxPenList_ctor();
		static extern (C) void wxPenList_AddPen(IntPtr self, IntPtr pen);
		static extern (C) void wxPenList_RemovePen(IntPtr self, IntPtr pen);
		static extern (C) IntPtr wxPenList_FindOrCreatePen(IntPtr self, IntPtr colour, int width, int style);
		//! \endcond
		
		//-----------------------------------------------------------------------------
	
	alias PenList wxPenList;
	public class PenList : wxObject
	{
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this()
			{ super(wxPenList_ctor());}
			
		//-----------------------------------------------------------------------------
			
		public void AddPen(Pen pen)
		{
			wxPenList_AddPen(wxobj, wxObject.SafePtr(pen));
		}
		
		//-----------------------------------------------------------------------------
		
		public void RemovePen(Pen pen)
		{
			wxPenList_RemovePen(wxobj, wxObject.SafePtr(pen));
		}
		
		//-----------------------------------------------------------------------------
		
		public Pen FindOrCreatePen(Colour colour, int width, int style)
		{
			return new Pen(wxPenList_FindOrCreatePen(wxobj, wxObject.SafePtr(colour), width, style));
		}
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxBrushList_ctor();
		static extern (C) void wxBrushList_AddBrush(IntPtr self, IntPtr brush);
		static extern (C) void wxBrushList_RemoveBrush(IntPtr self, IntPtr brush);
		static extern (C) IntPtr wxBrushList_FindOrCreateBrush(IntPtr self, IntPtr colour, int style);
		//! \endcond
		
		//-----------------------------------------------------------------------------
	
	alias BrushList wxBrushList;
	public class BrushList : wxObject
	{
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this()
			{ super(wxBrushList_ctor());}
			
		//-----------------------------------------------------------------------------
			
		public void AddBrush(Brush brush)
		{
			wxBrushList_AddBrush(wxobj, wxObject.SafePtr(brush));
		}
		
		//-----------------------------------------------------------------------------
		
		public void RemoveBrush(Brush brush)
		{
			wxBrushList_RemoveBrush(wxobj, wxObject.SafePtr(brush));
		}
		
		//-----------------------------------------------------------------------------
		
		public Brush FindOrCreateBrush(Colour colour, int style)
		{
			return new Brush(wxBrushList_FindOrCreateBrush(wxobj, wxObject.SafePtr(colour), style));
		}
	}	
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxFontList_ctor();
		static extern (C) void wxFontList_AddFont(IntPtr self, IntPtr font);
		static extern (C) void wxFontList_RemoveFont(IntPtr self, IntPtr font);
		static extern (C) IntPtr wxFontList_FindOrCreateFont(IntPtr self, 
			int pointSize, 
			int family, 
			int style, 
			int weight,
			bool underline,
			string face,
			FontEncoding encoding);
		//! \endcond
		
		//-----------------------------------------------------------------------------
	
	alias FontList wxFontList;
	public class FontList : wxObject
	{
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this()
			{ super(wxFontList_ctor());}
			
		//-----------------------------------------------------------------------------
			
		public void AddFont(Font font)
		{
			wxFontList_AddFont(wxobj, wxObject.SafePtr(font));
		}
		
		//-----------------------------------------------------------------------------
		
		public void RemoveFont(Font font)
		{
			wxFontList_RemoveFont(wxobj, wxObject.SafePtr(font));
		}
		
		//-----------------------------------------------------------------------------
		
		public Font FindOrCreateFont(int pointSize, int family, int style, int weight)
		{
			return FindOrCreateFont(pointSize, family, style, weight, false, "", FontEncoding.wxFONTENCODING_DEFAULT);
		}
		
		public Font FindOrCreateFont(int pointSize, int family, int style, int weight, bool underline)
		{
			return FindOrCreateFont(pointSize, family, style, weight, underline, "", FontEncoding.wxFONTENCODING_DEFAULT);
		}

		public Font FindOrCreateFont(int pointSize, int family, int style, int weight, bool underline, string face)
		{
			return FindOrCreateFont(pointSize, family, style, weight, underline, face, FontEncoding.wxFONTENCODING_DEFAULT);
		}
		
		
		public Font FindOrCreateFont(int pointSize, int family, int style, int weight, bool underline, string face, FontEncoding encoding)
		{
			return new Font(wxFontList_FindOrCreateFont(wxobj, pointSize, family, style, weight, underline, face, encoding));
		}
	}		
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxBitmapList_ctor();
		static extern (C) void   wxBitmapList_AddBitmap(IntPtr self, IntPtr bitmap);
		static extern (C) void   wxBitmapList_RemoveBitmap(IntPtr self, IntPtr bitmap);
		//! \endcond
		
		//-----------------------------------------------------------------------------
		
	alias BitmapList wxBitmapList;
	public class BitmapList : wxObject
	{
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this()
			{ super(wxBitmapList_ctor());}
			
		//-----------------------------------------------------------------------------
		
		public void AddBitmap(Bitmap bitmap)
		{
			wxBitmapList_AddBitmap(wxobj, wxObject.SafePtr(bitmap));
		}
		
		//-----------------------------------------------------------------------------
		
		public void RemoveBitmap(Bitmap bitmap)
		{
			wxBitmapList_RemoveBitmap(wxobj, wxObject.SafePtr(bitmap));
		}
	}
	
	//-----------------------------------------------------------------------------
