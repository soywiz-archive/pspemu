//-----------------------------------------------------------------------------
// wxD - ImageList.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - ImageList.cs
//
/// The wxImageList wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: ImageList.d,v 1.10 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.ImageList;
public import wx.common;
public import wx.Bitmap;
public import wx.DC;

	// Flag values for Set/GetImageList
	enum
	{
		wxIMAGE_LIST_NORMAL, // Normal icons
		wxIMAGE_LIST_SMALL,  // Small icons
		wxIMAGE_LIST_STATE   // State icons: unimplemented (see WIN32 documentation)
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxImageList_ctor(int width, int height, bool mask, int initialCount);
		static extern (C) IntPtr wxImageList_ctor2();
		static extern (C) int    wxImageList_AddBitmap1(IntPtr self, IntPtr bmp, IntPtr mask);
		static extern (C) int    wxImageList_AddBitmap(IntPtr self, IntPtr bmp, IntPtr maskColour);
		static extern (C) int    wxImageList_AddIcon(IntPtr self, IntPtr icon);
		static extern (C) int    wxImageList_GetImageCount(IntPtr self);
		
		static extern (C) bool   wxImageList_Draw(IntPtr self, int index, IntPtr dc, int x, int y, int flags, bool solidBackground);
		
		static extern (C) bool   wxImageList_Create(IntPtr self, int width, int height, bool mask, int initialCount);
		
		static extern (C) bool   wxImageList_Replace(IntPtr self, int index, IntPtr bitmap);
		
		static extern (C) bool   wxImageList_Remove(IntPtr self, int index);
		static extern (C) bool   wxImageList_RemoveAll(IntPtr self);
		
		//static extern (C) IntPtr wxImageList_GetBitmap(IntPtr self, int index);
		
		static extern (C) bool   wxImageList_GetSize(IntPtr self, int index, ref int width, ref int height);
		//! \endcond

		//---------------------------------------------------------------------

	alias ImageList wxImageList;
	public class ImageList : wxObject
	{
		public const int wxIMAGELIST_DRAW_NORMAL	= 0x0001;
		public const int wxIMAGELIST_DRAW_TRANSPARENT	= 0x0002;
		public const int wxIMAGELIST_DRAW_SELECTED	= 0x0004;
		public const int wxIMAGELIST_DRAW_FOCUSED	= 0x0008;
		
		//---------------------------------------------------------------------
	
		public this(int width, int height, bool mask = true, int initialCount=1)
			{ super(wxImageList_ctor(width, height, mask, initialCount));}

		public this(IntPtr wxobj) 
			{ super(wxobj);}
			
		public this()
			{ super(wxImageList_ctor2());}

		public static wxObject New(IntPtr ptr) { return new ImageList(ptr); }
		//---------------------------------------------------------------------

		public int Add(Bitmap bitmap)
		{
			return wxImageList_AddBitmap1(wxobj, wxObject.SafePtr(bitmap), IntPtr.init);
		}
		
		public int Add(Bitmap bitmap, Bitmap mask)
		{
			return wxImageList_AddBitmap1(wxobj, wxObject.SafePtr(bitmap), wxObject.SafePtr(mask));
		}

		public int Add(Icon icon)
		{
			return wxImageList_AddIcon(wxobj, wxObject.SafePtr(icon));
		}
		
		public int Add(Bitmap bmp, Colour maskColour)
		{
			return wxImageList_AddBitmap(wxobj, wxObject.SafePtr(bmp), wxObject.SafePtr(maskColour));
		}

		//---------------------------------------------------------------------
		
		public bool Create(int width, int height)
		{
			return Create(width, height, true, 1);
		}
		
		public bool Create(int width, int height, bool mask)
		{
			return Create(width, height, mask, 1);
		}
		
		public bool Create(int width, int height, bool mask, int initialCount)
		{
			return wxImageList_Create(wxobj, width, height, mask, initialCount);
		}
		
		//---------------------------------------------------------------------
		
		public int ImageCount() { return wxImageList_GetImageCount(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool Draw(int index, DC dc, int x, int y)
		{
			return Draw(index, dc, x, y, wxIMAGELIST_DRAW_NORMAL, false);
		}
		
		public bool Draw(int index, DC dc, int x, int y, int flags)
		{
			return Draw(index, dc, x, y, flags, false);
		}
		
		public bool Draw(int index, DC dc, int x, int y, int flags, bool solidBackground)
		{
			return wxImageList_Draw(wxobj, index, wxObject.SafePtr(dc), x, y, flags, solidBackground);
		}
		
		//---------------------------------------------------------------------
		
		public bool Replace(int index, Bitmap bitmap)
		{
			return wxImageList_Replace(wxobj, index, wxObject.SafePtr(bitmap));
		}
		
		//---------------------------------------------------------------------
		
		public bool Remove(int index)
		{
			return wxImageList_Remove(wxobj, index);
		}
		
		//---------------------------------------------------------------------
		
		public bool RemoveAll()
		{
			return wxImageList_RemoveAll(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		/*public Bitmap GetBitmap(int index)
		{
			return cast(Bitmap)FindObject(wxImageList_GetBitmap(wxobj, index), &Bitmap.New);
		}*/
		
		//---------------------------------------------------------------------
		
		public bool GetSize(int index, ref int width, ref int height)
		{
			return wxImageList_GetSize(wxobj, index, width, height);
		}
	}
