//-----------------------------------------------------------------------------
// wxD - StaticBitmap.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - StaticBitmap.cs
//
/// The wxStaticBitmap wrapper class.
//
// Written by Robert Roebling
// (C) 2003 Robert Roebling
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: StaticBitmap.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.StaticBitmap;
public import wx.common;
public import wx.Control;

		//! \cond EXTERN
		static extern (C) IntPtr wxStaticBitmap_ctor();
		static extern (C) bool wxStaticBitmap_Create(IntPtr self, IntPtr parent, int id, IntPtr label, ref Point pos, ref Size size, uint style, string name);
		static extern (C) void wxStaticBitmap_SetBitmap(IntPtr self, IntPtr bitmap);
		static extern (C) IntPtr wxStaticBitmap_GetBitmap(IntPtr self);
		//! \endcond

		//---------------------------------------------------------------------

	alias StaticBitmap wxStaticBitmap;
	public class StaticBitmap : Control
	{
		public const string wxStaticBitmapNameStr = "message";

		public this()
			{ super(wxStaticBitmap_ctor()); }

		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(Window parent, int id, Bitmap label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name = wxStaticBitmapNameStr)
		{
			super(wxStaticBitmap_ctor());
			if (!Create(parent, id, label, pos, size, style, name))
			{
				throw new InvalidOperationException("Failed to create StaticBitmap");
			}
		}
		
		public static wxObject New(IntPtr wxobj) { return new StaticBitmap(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, Bitmap label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name = wxStaticBitmapNameStr)
			{ this(parent, Window.UniqueID, label, pos, size, style, name);}
		
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, Bitmap label, ref Point pos, ref Size size, int style, string name)
		{
			return wxStaticBitmap_Create(wxobj, wxObject.SafePtr(parent), id, wxObject.SafePtr(label), pos, size, cast(uint)style, name);
		}

		//---------------------------------------------------------------------

		public void bitmap(Bitmap value) { wxStaticBitmap_SetBitmap(wxobj, wxObject.SafePtr(value)); }
		public Bitmap bitmap() { return cast(Bitmap)FindObject(wxStaticBitmap_GetBitmap(wxobj), &Bitmap.New); }
	}
