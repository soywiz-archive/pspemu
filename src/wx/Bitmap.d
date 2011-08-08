//-----------------------------------------------------------------------------
// wxD - Bitmap.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - Bitmap.cs
//
/// The wxBitmap wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Bitmap.d,v 1.10 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.Bitmap;
public import wx.common;
public import wx.GDIObject;
public import wx.Colour;
public import wx.Palette;
public import wx.Image;
public import wx.Icon;

		//! \cond EXTERN
		static extern (C) IntPtr wxBitmap_ctor();
		static extern (C) IntPtr wxBitmap_ctorByImage(IntPtr image, int depth);
		static extern (C) IntPtr wxBitmap_ctorByName(string name, BitmapType type);
		static extern (C) IntPtr wxBitmap_ctorBySize(int width, int height, int depth);
		static extern (C) IntPtr wxBitmap_ctorByBitmap(IntPtr bitmap);
		//static extern (C) void   wxBitmap_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		
		static extern (C) IntPtr wxBitmap_ConvertToImage(IntPtr self);
		static extern (C) bool   wxBitmap_LoadFile(IntPtr self, string name, BitmapType type);
		static extern (C) bool   wxBitmap_SaveFile(IntPtr self, string name, BitmapType type, IntPtr palette);
		static extern (C) bool   wxBitmap_Ok(IntPtr self);
	
		static extern (C) int    wxBitmap_GetHeight(IntPtr self);
		static extern (C) void   wxBitmap_SetHeight(IntPtr self, int height);
	
		static extern (C) int    wxBitmap_GetWidth(IntPtr self);
		static extern (C) void   wxBitmap_SetWidth(IntPtr self, int width);
		
		static extern (C) int    wxBitmap_GetDepth(IntPtr self);
		static extern (C) void   wxBitmap_SetDepth(IntPtr self, int depth);
		
		static extern (C) IntPtr wxBitmap_GetSubBitmap(IntPtr self, ref Rectangle rect);
		
		static extern (C) IntPtr wxBitmap_GetMask(IntPtr self);
		static extern (C) IntPtr wxBitmap_SetMask(IntPtr self, IntPtr mask);
		
		static extern (C) IntPtr wxBitmap_GetPalette(IntPtr self);
		static extern (C) bool   wxBitmap_CopyFromIcon(IntPtr self, IntPtr icon);
		
		static extern (C) IntPtr wxBitmap_GetColourMap(IntPtr self);
		//! \endcond
	
		//---------------------------------------------------------------------

	alias Bitmap wxBitmap;
	public class Bitmap : GDIObject
	{
		public static Bitmap wxNullBitmap;
/*
		static this()
		{
			Image.InitAllHandlers();
		}
*/
		public this()
			{ this(wxBitmap_ctor()); }

		public this(Image image)
			{ this(image, -1); }

		public this(Image image, int depth)
			{ this(wxBitmap_ctorByImage(image.wxobj, depth)); }

		public this(string name)
			{ this(wxBitmap_ctorByName(name, BitmapType.wxBITMAP_TYPE_ANY)); }

		public this(string name, BitmapType type)
			{ this(wxBitmap_ctorByName(name, type)); }

		public this(int width, int height)
			{ this(width, height, -1); }

		public this(int width, int height, int depth)
			{ this(wxBitmap_ctorBySize(width, height, depth));}
	    
		public this(Bitmap bitmap)
			{ this(wxBitmap_ctorByBitmap(wxObject.SafePtr(bitmap)));}

		public this(IntPtr wxobj) 
			{ super(wxobj); }
			
		//---------------------------------------------------------------------

		public Image ConvertToImage()
		{
			return new Image(wxBitmap_ConvertToImage(wxobj));
		}

		//---------------------------------------------------------------------

		public int Height() { return wxBitmap_GetHeight(wxobj); }
		public void Height(int value) { wxBitmap_SetHeight(wxobj, value); }

		//---------------------------------------------------------------------

		public bool LoadFile(string name, BitmapType type)
		{
			return wxBitmap_LoadFile(wxobj, name, type);
		}
	
		//---------------------------------------------------------------------
	
		public bool SaveFile(string name, BitmapType type)
		{
			return SaveFile(name, type, null);
		}
	
		public bool SaveFile(string name, BitmapType type, Palette palette)
		{
			return wxBitmap_SaveFile(wxobj, name, type, wxObject.SafePtr(palette));
		}

		//---------------------------------------------------------------------

		public int Width() { return wxBitmap_GetWidth(wxobj); }
		public void Width(int value) { wxBitmap_SetWidth(wxobj, value); }

		//---------------------------------------------------------------------

		public /+virtual+/ bool Ok()
		{
			return wxBitmap_Ok(wxobj);
		}

		//---------------------------------------------------------------------
	
		public int Depth() { return wxBitmap_GetDepth(wxobj); }
		public void Depth(int value) { wxBitmap_SetDepth(wxobj, value); }
	
		//---------------------------------------------------------------------
	
		public Bitmap GetSubBitmap(Rectangle rect)
		{
			return new Bitmap(wxBitmap_GetSubBitmap(wxobj, rect));
		}
	
		//---------------------------------------------------------------------
	
		public Mask mask() { return new Mask(wxBitmap_GetMask(wxobj)); }
		public void mask(Mask value) { wxBitmap_SetMask(wxobj, wxObject.SafePtr(value)); }
	
		//---------------------------------------------------------------------
	
		public Palette palette() { return new Palette(wxBitmap_GetPalette(wxobj)); }
	
		//---------------------------------------------------------------------
	
		public Palette ColourMap() { return new Palette(wxBitmap_GetColourMap(wxobj)); }
	
		//---------------------------------------------------------------------
		
		public bool CopyFromIcon(Icon icon)
		{
			return wxBitmap_CopyFromIcon(wxobj, wxObject.SafePtr(icon));
		}
		
		public static wxObject New(IntPtr ptr) { return new Bitmap(ptr); }
	}

	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxMask_ctor();
		static extern (C) IntPtr wxMask_ctorByBitmpaColour(IntPtr bitmap, IntPtr colour);
		static extern (C) IntPtr wxMask_ctorByBitmapIndex(IntPtr bitmap, int paletteIndex);
		static extern (C) IntPtr wxMask_ctorByBitmap(IntPtr bitmap);
		
		static extern (C) bool wxMask_CreateByBitmapColour(IntPtr self, IntPtr bitmap, IntPtr colour);
		static extern (C) bool wxMask_CreateByBitmapIndex(IntPtr self, IntPtr bitmap, int paletteIndex);
		static extern (C) bool wxMask_CreateByBitmap(IntPtr self, IntPtr bitmap);
		//! \endcond
		
		//---------------------------------------------------------------------
	alias Mask wxMask;
	public class Mask : wxObject
	{
		
		public this()
			{ this(wxMask_ctor());}
			
		public this(Bitmap bitmap, Colour colour)
			{ this(wxMask_ctorByBitmpaColour(wxObject.SafePtr(bitmap), wxObject.SafePtr(colour)));}
			
		public this(Bitmap bitmap, int paletteIndex)
			{ this(wxMask_ctorByBitmapIndex(wxObject.SafePtr(bitmap), paletteIndex));}
			
		public this(Bitmap bitmap)
			{ this(wxMask_ctorByBitmap(wxObject.SafePtr(bitmap)));}
		
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		//---------------------------------------------------------------------
			
		public bool Create(Bitmap bitmap, Colour colour)
		{
			return wxMask_CreateByBitmapColour(wxobj, wxObject.SafePtr(bitmap), wxObject.SafePtr(colour));
		}
		
		public bool Create(Bitmap bitmap, int paletteIndex)
		{
			return wxMask_CreateByBitmapIndex(wxobj, wxObject.SafePtr(bitmap), paletteIndex);
		}
		
		public bool Create(Bitmap bitmap)
		{
			return wxMask_CreateByBitmap(wxobj, wxObject.SafePtr(bitmap));
		}
	}
