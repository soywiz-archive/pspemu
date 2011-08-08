//-----------------------------------------------------------------------------
// wxD - Image.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Image.cs
//
/// The wxImage wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Image.d,v 1.12 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.Image;
public import wx.common;
public import wx.Defs;
//public import wx.Bitmap;
public import wx.Palette;
public import wx.Colour;

		//! \cond EXTERN
		static extern (C) IntPtr wxImage_ctor();
		static extern (C) IntPtr wxImage_ctorByName(string name, BitmapType type);
		static extern (C) IntPtr wxImage_ctorintintbool(int width, int height, bool clear);
		static extern (C) IntPtr wxImage_ctorByData(int width, int height, ubyte* data, bool static_data);
		static extern (C) IntPtr wxImage_ctorByDataAlpha(int width, int height, ubyte* data, ubyte* alpha, bool static_data);
		static extern (C) IntPtr wxImage_ctorByImage(IntPtr image);
		static extern (C) IntPtr wxImage_ctorByByteArray(IntPtr data, int length, BitmapType type);
		static extern (C) void   wxImage_dtor(IntPtr self);
		
		static extern (C) void   wxImage_Destroy(IntPtr self);
		
		static extern (C) int    wxImage_GetHeight(IntPtr self);
		static extern (C) int    wxImage_GetWidth(IntPtr self);
		static extern (C) void   wxImage_InitAllHandlers();
		static extern (C) void   wxImage_Rescale(IntPtr self, int width, int height);
		static extern (C) IntPtr wxImage_Scale(IntPtr self, int width, int height);

		static extern (C) void   wxImage_SetMask(IntPtr self, bool mask);
		static extern (C) bool   wxImage_HasMask(IntPtr self);
		static extern (C) void   wxImage_SetMaskColour(IntPtr self, ubyte r, ubyte g, ubyte b);

		static extern (C) bool   wxImage_LoadFileByTypeId(IntPtr self, string name, BitmapType type, int index);
		static extern (C) bool   wxImage_LoadFileByMimeTypeId(IntPtr self, string name, string mimetype, int index);
		static extern (C) bool   wxImage_SaveFileByType(IntPtr self, string name, BitmapType type);
		static extern (C) bool   wxImage_SaveFileByMimeType(IntPtr self, string name, string mimetype);
		
		static extern (C) IntPtr wxImage_Copy(IntPtr self);
		static extern (C) IntPtr wxImage_GetSubImage(IntPtr self, ref Rectangle rect);
		
		static extern (C) void   wxImage_Paste(IntPtr self, IntPtr image, int x, int y);
		
		static extern (C) IntPtr wxImage_ShrinkBy(IntPtr self, int xFactor, int yFactor);
		
		static extern (C) IntPtr wxImage_Rotate(IntPtr self, double angle, ref Point centre_of_rotation, bool interpolating, ref Point offset_after_rotation);
		static extern (C) IntPtr wxImage_Rotate90(IntPtr self, bool clockwise);
		static extern (C) IntPtr wxImage_Mirror(IntPtr self, bool horizontally);
		
		static extern (C) void   wxImage_Replace(IntPtr self, ubyte r1, ubyte g1, ubyte b1, ubyte r2, ubyte g2, ubyte b2);
		
		static extern (C) IntPtr wxImage_ConvertToMono(IntPtr self, ubyte r, ubyte g, ubyte b);
		
		static extern (C) void   wxImage_SetRGB(IntPtr self, int x, int y, ubyte r, ubyte g, ubyte b);
		
		static extern (C) ubyte   wxImage_GetRed(IntPtr self, int x, int y);
		static extern (C) ubyte   wxImage_GetGreen(IntPtr self, int x, int y);
		static extern (C) ubyte   wxImage_GetBlue(IntPtr self, int x, int y);
		
		static extern (C) void   wxImage_SetAlpha(IntPtr self, int x, int y, ubyte alpha);
		static extern (C) ubyte   wxImage_GetAlpha(IntPtr self, int x, int y);
		
		static extern (C) bool   wxImage_FindFirstUnusedColour(IntPtr self, ref ubyte r, ref ubyte g, ref ubyte b, ubyte startR, ubyte startG, ubyte startB);
		static extern (C) bool   wxImage_SetMaskFromImage(IntPtr self, IntPtr mask, ubyte mr, ubyte mg, ubyte mb);
		
		static extern (C) bool   wxImage_ConvertAlphaToMask(IntPtr self, ubyte threshold);
		
		static extern (C) bool   wxImage_CanRead(string name);
		static extern (C) int    wxImage_GetImageCount(string name, int type);
		
		static extern (C) bool   wxImage_Ok(IntPtr self);
		//--Alex
		static extern (C) ubyte   wxImage_GetMaskRed(IntPtr self);
		static extern (C) ubyte   wxImage_GetMaskGreen(IntPtr self);
		static extern (C) ubyte   wxImage_GetMaskBlue(IntPtr self);
		
		static extern (C) bool   wxImage_HasPalette(IntPtr self);
		static extern (C) IntPtr wxImage_GetPalette(IntPtr self);
		static extern (C) void   wxImage_SetPalette(IntPtr self, IntPtr palette);
		
		static extern (C) void   wxImage_SetOption(IntPtr self, string name, string value);
		static extern (C) void   wxImage_SetOption2(IntPtr self, string name, int value);
		static extern (C) IntPtr wxImage_GetOption(IntPtr self, string name);
		static extern (C) int    wxImage_GetOptionInt(IntPtr self, string name);
		static extern (C) bool   wxImage_HasOption(IntPtr self, string name);
		
		static extern (C) uint  wxImage_CountColours(IntPtr self, uint stopafter);
		
		static extern (C) uint  wxImage_ComputeHistogram(IntPtr self, IntPtr h);
		
		static extern (C) IntPtr wxImage_GetHandlers();
		static extern (C) void   wxImage_AddHandler(IntPtr handler);
		static extern (C) void   wxImage_InsertHandler(IntPtr handler);
		static extern (C) bool   wxImage_RemoveHandler(string name);
		static extern (C) IntPtr wxImage_FindHandler(string name);
		static extern (C) IntPtr wxImage_FindHandler2(string name, uint imageType);
		static extern (C) IntPtr wxImage_FindHandler3(uint imageType);
		static extern (C) IntPtr wxImage_FindHandlerMime(string mimetype);
		
		static extern (C) IntPtr wxImage_GetImageExtWildcard();
		
		static extern (C) void   wxImage_CleanUpHandlers();
		
		static extern (C) void   wxImage_InitStandardHandlers();
		//! \endcond

		//---------------------------------------------------------------------

	alias Image wxImage;
	public class Image : wxObject
	{
		private static bool handlersLoaded = false;
		
		public static void InitAllHandlers()
		{
			// We only want to load the image handlers once.
			if (!handlersLoaded) 
			{
				wxImage_InitAllHandlers();
				handlersLoaded = true;
			}
		}

		static this()
		{
			InitAllHandlers();
		}
		
		public this(IntPtr wxobj)
			{ super(wxobj);}

		public this()
			{ this(wxImage_ctor());}

		public this(string name)
			{ this(wxImage_ctorByName(name, BitmapType.wxBITMAP_TYPE_ANY));}
			
		public this(int width, int height)
			{ this(width, height, true);}
		
		public this(byte[] data, BitmapType type)
			{ this(wxImage_ctorByByteArray(cast(IntPtr)data.ptr, data.length, type));}
			
		public this(int width, int height, bool clear)
			{ this(wxImage_ctorintintbool(width, height, clear));}

		public this(int width, int height, ubyte *data, bool static_data)
			{ this(wxImage_ctorByData(width, height, data, static_data));}

		public this(int width, int height, ubyte *data, ubyte *alpha, bool static_data)
			{ this(wxImage_ctorByDataAlpha(width, height, data, alpha, static_data));}

		public this(Image image)
			{ this(wxImage_ctorByImage(wxObject.SafePtr(image)));}
		
		public static wxObject New(IntPtr ptr) { return new Image(ptr); }
		
		//---------------------------------------------------------------------
		
		public void Destroy()
		{
			wxImage_Destroy(wxobj);
		}
		
		//---------------------------------------------------------------------

		public int Width() { return wxImage_GetWidth(wxobj); }
		public int Height() { return wxImage_GetHeight(wxobj); }
		public Size size() { return Size(Width,Height); }

		//---------------------------------------------------------------------
		
		public bool LoadFile(string path)
		{
			return LoadFile(path, BitmapType.wxBITMAP_TYPE_ANY, -1);
		}
		
		public bool LoadFile(string path, BitmapType type)
		{
			return LoadFile(path, type, -1);
		}
		
		public bool LoadFile(string path, BitmapType type, int index)
		{
			return wxImage_LoadFileByTypeId(wxobj, path, type, -1);
		}
		
		//---------------------------------------------------------------------
		
		public bool LoadFile(string name, string mimetype)
		{
			return LoadFile(name, mimetype, -1);
		}
		
		public bool LoadFile(string name, string mimetype, int index)
		{
			return wxImage_LoadFileByMimeTypeId(wxobj, name, mimetype, index);
		}
		
		//---------------------------------------------------------------------

        	public bool SaveFile(string path)
		{ 
			return SaveFile(path, BitmapType.wxBITMAP_TYPE_ANY); 
		}
		
		public bool SaveFile(string path, BitmapType type)
		{
			return wxImage_SaveFileByType(wxobj, path, type);
		}
		
		//---------------------------------------------------------------------
		
		public bool SaveFile(string name, string mimetype)
		{
			return wxImage_SaveFileByMimeType(wxobj, name, mimetype);
		}

		//---------------------------------------------------------------------

		public Image Rescale(int width, int height)
		{
			wxImage_Rescale(wxobj, width, height);
			return this;
		}

		//---------------------------------------------------------------------

		public Image Scale(int width, int height)
		{
			return new Image(wxImage_Scale(wxobj, width, height));
		}

		//---------------------------------------------------------------------

		public void SetMaskColour(ubyte r, ubyte g, ubyte b)
		{
			wxImage_SetMaskColour(wxobj, r, g, b);
		}
		
		//---------------------------------------------------------------------

		public void MaskColour(Colour value) { SetMaskColour(value.Red, value.Green, value.Blue); }
		
		//---------------------------------------------------------------------

		public void Mask(bool value) { wxImage_SetMask(wxobj, value); }
		public bool Mask() { return wxImage_HasMask(wxobj); }
		
		//---------------------------------------------------------------------
		
		public Image Copy()
		{
			return new Image(wxImage_Copy(wxobj));
		}
		
		//---------------------------------------------------------------------
		
		public Image SubImage(Rectangle rect)
		{
			return cast(Image)FindObject(wxImage_GetSubImage(wxobj, rect), &Image.New);
		}
		
		//---------------------------------------------------------------------
		
		public void Paste(Image image, int x, int y)
		{
			wxImage_Paste(wxobj, wxObject.SafePtr(image), x, y);
		}
		
		//---------------------------------------------------------------------
		
		public Image ShrinkBy(int xFactor, int yFactor)
		{
			return new Image(wxImage_ShrinkBy(wxobj, xFactor, yFactor));
		}
		
		//---------------------------------------------------------------------
		
		public Image Rotate(double angle, Point centre_of_rotation)
		{
			Point dummy;
			return Rotate(angle, centre_of_rotation, true, dummy);
		}
		
		public Image Rotate(double angle, Point centre_of_rotation, bool interpolating)
		{
			Point dummy;
			return Rotate(angle, centre_of_rotation, interpolating, dummy);
		}
		
		public Image Rotate(double angle, Point centre_of_rotation, bool interpolating, Point offset_after_rotation)
		{
			return new Image(wxImage_Rotate(wxobj, angle, centre_of_rotation, interpolating, offset_after_rotation));
		}
		
		//---------------------------------------------------------------------
		
		public Image Rotate90()
		{
			return Rotate90(true);
		}
		
		public Image Rotate90(bool clockwise)
		{
			return new Image(wxImage_Rotate90(wxobj, clockwise));
		}
		
		//---------------------------------------------------------------------
		
		public Image Mirror()
		{
			return Mirror(true);
		}
		
		public Image Mirror(bool horizontally)
		{
			return new Image(wxImage_Mirror(wxobj, horizontally));
		}
		
		//---------------------------------------------------------------------
		
		public void Replace(ubyte r1, ubyte g1, ubyte b1, ubyte r2, ubyte g2, ubyte b2)
		{
			wxImage_Replace(wxobj, r1, g1, b1, r2, g2, b2);
		}
		
		//---------------------------------------------------------------------
		
		public void ConvertToMono(ubyte r, ubyte g, ubyte b)
		{
			wxImage_ConvertToMono(wxobj, r, g, b);
		}
		
		//---------------------------------------------------------------------
		
		public void SetRGB(int x, int y, ubyte r, ubyte g, ubyte b)
		{
			wxImage_SetRGB(wxobj, x, y, r, g, b);
		}
		
		//---------------------------------------------------------------------
		
		public ubyte GetRed(int x, int y)
		{
			return wxImage_GetRed(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------
		
		public ubyte GetGreen(int x, int y)
		{
			return wxImage_GetGreen(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------
		
		public ubyte GetBlue(int x, int y)
		{
			return wxImage_GetBlue(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------
		
		public void SetAlpha(int x, int y, ubyte alpha)
		{
			wxImage_SetAlpha(wxobj, x, y, alpha);
		}
		
		//---------------------------------------------------------------------
		
		public ubyte GetAlpha(int x, int y)
		{
			return wxImage_GetAlpha(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------
		
		public bool FindFirstUnusedColour(ref ubyte r, ref ubyte g, ref ubyte b)
		{
			return FindFirstUnusedColour(r, g, b, 1, 0, 0);
		}
		
		public bool FindFirstUnusedColour(ref ubyte r, ref ubyte g, ref ubyte b, ubyte startR)
		{
			return FindFirstUnusedColour(r, g, b, startR, 0, 0);
		}
		
		public bool FindFirstUnusedColour(ref ubyte r, ref ubyte g, ref ubyte b, ubyte startR, ubyte startG)
		{
			return FindFirstUnusedColour(r, g, b, startR, startG, 0);
		}
		
		public bool FindFirstUnusedColour(ref ubyte r, ref ubyte g, ref ubyte b, ubyte startR, ubyte startG, ubyte startB)
		{
			return wxImage_FindFirstUnusedColour(wxobj, r, g, b, startR, startG, startB);
		}
		
		//---------------------------------------------------------------------
		
		public bool SetMaskFromImage(Image mask, ubyte mr, ubyte mg, ubyte mb)
		{
			return wxImage_SetMaskFromImage(wxobj, wxObject.SafePtr(mask), mr, mg, mb);
		}
		
		//---------------------------------------------------------------------
		
		public bool ConvertAlphaToMask()
		{
			return ConvertAlphaToMask(128);
		}
		
		public bool ConvertAlphaToMask(ubyte threshold)
		{
			return wxImage_ConvertAlphaToMask(wxobj, threshold);
		}
		
		//---------------------------------------------------------------------
		
		public static bool CanRead(string name)
		{
			return wxImage_CanRead(name);
		}
		
		//---------------------------------------------------------------------
		
		public static int GetImageCount(string name)
		{
			return GetImageCount(name, BitmapType.wxBITMAP_TYPE_ANY);
		}
		
		public static int GetImageCount(string name, BitmapType type)
		{
			return wxImage_GetImageCount(name, cast(int)type);
		}
		
		//---------------------------------------------------------------------
		
		public bool Ok() { return wxImage_Ok(wxobj); }
		
		//---------------------------------------------------------------------
		
		public ubyte MaskRed() { return wxImage_GetMaskRed(wxobj); }
		
		//---------------------------------------------------------------------
		
		public ubyte MaskGreen() { return wxImage_GetMaskGreen(wxobj); }
		
		//---------------------------------------------------------------------
		
		public ubyte MaskBlue() { return wxImage_GetMaskBlue(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool HasPalette()
		{
			return wxImage_HasPalette(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public Palette palette() { return cast(Palette)FindObject(wxImage_GetPalette(wxobj), &Palette.New); }
		public void palette(Palette value) { wxImage_SetPalette(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------
		
		public void SetOption(string name, string value)
		{
			wxImage_SetOption(wxobj, name, value);
		}
		
		//---------------------------------------------------------------------
		
		public void SetOption(string name, int value)
		{
			wxImage_SetOption2(wxobj, name, value);
		}
		
		//---------------------------------------------------------------------
		
		public string GetOption(string name)
		{
			return cast(string) new wxString(wxImage_GetOption(wxobj, name), true);
		}
		
		//---------------------------------------------------------------------
		
		public int GetOptionInt(string name)
		{
			return wxImage_GetOptionInt(wxobj, name);
		}
		
		//---------------------------------------------------------------------
		
		public bool HasOption(string name)
		{
			return wxImage_HasOption(wxobj, name);
		}
		
		//---------------------------------------------------------------------
		
		public uint CountColours()
		{
			return CountColours(uint.max-1);
		}
		
		//---------------------------------------------------------------------
		
		public uint CountColours(uint stopafter)
		{
			return wxImage_CountColours(wxobj, stopafter);
		}
		
		//---------------------------------------------------------------------
		
		public uint ComputeHistogram(ImageHistogram h)
		{
			return wxImage_ComputeHistogram(wxobj, wxObject.SafePtr(h));
		}
		
		//---------------------------------------------------------------------
		
		/*
		// doesn't work. wxImageHandler is an abstract class...
		static ArrayList Handlers() { 
				wxList wl = new wxList(wxImage_GetHandlers());
				ArrayList al = new ArrayList();
				
				for (int i = 0; i < wl.Count; i++)
                	al.Add(new ImageHandler(wl.Item(i)));
					
				return wl;
			}
		*/
		
		//---------------------------------------------------------------------
		
		public static void AddHandler(ImageHandler handler)
		{
			wxImage_AddHandler(wxObject.SafePtr(handler));
		}
		
		//---------------------------------------------------------------------
		
		public static void InsertHandler(ImageHandler handler)
		{
			wxImage_InsertHandler(wxObject.SafePtr(handler));
		}
		
		//---------------------------------------------------------------------
		
		public static bool RemoveHandler(string name)
		{
			return wxImage_RemoveHandler(name);
		}
		
		//---------------------------------------------------------------------
		
		public static ImageHandler FindHandler(string name)
		{
			return cast(ImageHandler)FindObject(wxImage_FindHandler(name));
		}
		
		//---------------------------------------------------------------------
		
		public static ImageHandler FindHandler(string extension, int imageType)
		{
			return cast(ImageHandler)FindObject(wxImage_FindHandler2(extension, cast(uint)imageType));
		}
		
		//---------------------------------------------------------------------
		
		public static ImageHandler FindHandler(int imageType)
		{
			return cast(ImageHandler)FindObject(wxImage_FindHandler3(cast(uint)imageType));
		}
		
		//---------------------------------------------------------------------
		
		public static ImageHandler FindHandlerMime(string mimetype)
		{
			return cast(ImageHandler)FindObject(wxImage_FindHandlerMime(mimetype));
		}
		
		//---------------------------------------------------------------------
		
		static string ImageExtWildcard() { return cast(string) new wxString(wxImage_GetImageExtWildcard(), true); }
		
		//---------------------------------------------------------------------
		
		public static void CleanUpHandlers()
		{
			wxImage_CleanUpHandlers();
		}
		
		//---------------------------------------------------------------------
		
		public static void InitStandardHandlers()
		{
			wxImage_InitStandardHandlers();
		}
	}
	
	//---------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) void   wxImageHandler_SetName(IntPtr self, string name);
		static extern (C) void   wxImageHandler_SetExtension(IntPtr self, string ext);
		static extern (C) void   wxImageHandler_SetType(IntPtr self, uint type);
		static extern (C) void   wxImageHandler_SetMimeType(IntPtr self, string type);
		static extern (C) IntPtr wxImageHandler_GetName(IntPtr self);
		static extern (C) IntPtr wxImageHandler_GetExtension(IntPtr self);
		static extern (C) uint   wxImageHandler_GetType(IntPtr self);
		static extern (C) IntPtr wxImageHandler_GetMimeType(IntPtr self);
		//! \endcond
		
		//---------------------------------------------------------------------
	
	alias ImageHandler wxImageHandler;
	public class ImageHandler : wxObject
	{
		public this(IntPtr wxobj)
			{ super(wxobj);}
		
		//---------------------------------------------------------------------
		
		public string Name() { return cast(string) new wxString(wxImageHandler_GetName(wxobj), true); }
		public void Name(string value) { wxImageHandler_SetName(wxobj, value); }
		
		//---------------------------------------------------------------------
		
		public string Extension() { return cast(string) new wxString(wxImageHandler_GetExtension(wxobj), true); }
		public void Extension(string value) { wxImageHandler_SetExtension(wxobj, value); }
		
		//---------------------------------------------------------------------
		
		public int Type() { return cast(int)wxImageHandler_GetType(wxobj); }
		public void Type(int value) { wxImageHandler_SetType(wxobj, cast(uint)value); }
		
		//---------------------------------------------------------------------
		
		public string MimeType() { return cast(string) new wxString(wxImageHandler_GetMimeType(wxobj), true); }
		public void MimeType(string value) { wxImageHandler_SetMimeType(wxobj, value); }
	}
	
	//---------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxImageHistogramEntry_ctor();
		static extern (C) void   wxImageHistogramEntry_dtor(IntPtr self);
		static extern (C) uint  wxImageHistogramEntry_index(IntPtr self);
		static extern (C) void   wxImageHistogramEntry_Setindex(IntPtr self, uint v);
		static extern (C) uint  wxImageHistogramEntry_value(IntPtr self);
		static extern (C) void   wxImageHistogramEntry_Setvalue(IntPtr self, uint v);
		//! \endcond
		
		//---------------------------------------------------------------------
		
	alias ImageHistogramEntry wxImageHistogramEntry;
	public class ImageHistogramEntry : wxObject
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
			{ this(wxImageHistogramEntry_ctor(), true);}
			
		//---------------------------------------------------------------------
				
		override protected void dtor() { wxImageHistogramEntry_dtor(wxobj); }
		
		//---------------------------------------------------------------------
		
		public uint index() { return wxImageHistogramEntry_index(wxobj); }
		public void index(uint value) { wxImageHistogramEntry_Setindex(wxobj, value); }
		
		//---------------------------------------------------------------------
		
		public uint value() { return wxImageHistogramEntry_value(wxobj); }
		public void value(uint value) { wxImageHistogramEntry_Setvalue(wxobj, value); }
	}
	
	//---------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxImageHistogram_ctor();	
		static extern (C) void   wxImageHistogram_dtor(IntPtr self);
		static extern (C) uint  wxImageHistogram_MakeKey(ubyte r, ubyte g, ubyte b);
		static extern (C) bool   wxImageHistogram_FindFirstUnusedColour(IntPtr self, ref ubyte r, ref ubyte g, ref ubyte b, ubyte startR, ubyte startG, ubyte startB);
		//! \endcond
				
		//---------------------------------------------------------------------
		
	alias ImageHistogram wxImageHistogram;
	public class ImageHistogram : wxObject
	{
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this()
			{ this(wxImageHistogram_ctor());}
		
		//---------------------------------------------------------------------
		
		public static uint MakeKey(ubyte r, ubyte g, ubyte b)
		{
			return wxImageHistogram_MakeKey(r, g, b);
		}
		
		//---------------------------------------------------------------------
		
		public bool FindFirstUnusedColour(ref ubyte r, ref ubyte g, ref ubyte b)
		{
			return FindFirstUnusedColour(r, g, b, 1, 0, 0);
		}
		
		public bool FindFirstUnusedColour(ref ubyte r, ref ubyte g, ref ubyte b, ubyte startR)
		{
			return FindFirstUnusedColour(r, g, b, startR, 0, 0);
		}
		
		public bool FindFirstUnusedColour(ref ubyte r, ref ubyte g, ref ubyte b, ubyte startR, ubyte startG)
		{
			return FindFirstUnusedColour(r, g, b, startR, startG, 0);
		}
		
		public bool FindFirstUnusedColour(ref ubyte r, ref ubyte g, ref ubyte b, ubyte startR, ubyte startG, ubyte startB)
		{
			return wxImageHistogram_FindFirstUnusedColour(wxobj, r, g, b, startR, startG, startB);
		}
	}
