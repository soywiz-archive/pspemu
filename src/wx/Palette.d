//-----------------------------------------------------------------------------
// wxD - Palette.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Palette.cs
//
/// The wxPalette wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//-----------------------------------------------------------------------------


module wx.Palette;
public import wx.common;
public import wx.GDIObject;

		//! \cond EXTERN
		static extern (C) IntPtr wxPalette_ctor();
		static extern (C) void wxPalette_dtor(IntPtr self);
		static extern (C) bool wxPalette_Ok(IntPtr self);
		static extern (C) bool wxPalette_Create(IntPtr self, int n, ref ubyte red, ref ubyte green, ref ubyte blue);
		static extern (C) int wxPalette_GetPixel(IntPtr self, ubyte red, ubyte green, ubyte blue);
		static extern (C) bool wxPalette_GetRGB(IntPtr self, int pixel, out ubyte red, out ubyte green, out ubyte blue);
		//! \endcond

	alias Palette wxPalette;
	public class Palette : GDIObject
	{
		public static Palette wxNullPalette;
		//---------------------------------------------------------------------

		public this()
			{ this(wxPalette_ctor());}

		public this(IntPtr wxobj)
			{ super(wxobj);}

		public this(int n, ref ubyte r, ref ubyte g, ref ubyte b)
		{
			this(wxPalette_ctor());
			if (!wxPalette_Create(wxobj, n, r, g, b))
			{
				throw new InvalidOperationException("Failed to create Palette");
			}
		}

		public bool Create(int n, ref ubyte r, ref ubyte g, ref ubyte b)
		{
			return wxPalette_Create(wxobj, n, r, g, b);
		}

		public static wxObject New(IntPtr ptr) { return new Palette(ptr); }
		//---------------------------------------------------------------------

		public bool Ok()
		{
			return wxPalette_Ok(wxobj);
		}

		//---------------------------------------------------------------------

		public int GetPixel(ubyte red, ubyte green, ubyte blue)
		{
			return wxPalette_GetPixel(wxobj, red, green, blue);
		}

		public bool GetRGB(int pixel, out ubyte red, out ubyte green, out ubyte blue)
		{
			return wxPalette_GetRGB(wxobj, pixel, red, green, blue);
		}

		//---------------------------------------------------------------------
	}

