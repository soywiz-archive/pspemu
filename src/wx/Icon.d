//-----------------------------------------------------------------------------
// wxD - Icon.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Icon.cs
//
/// The wxIcon wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Icon.d,v 1.13 2011/01/06 00:31:46 afb Exp $
//-----------------------------------------------------------------------------

module wx.Icon;
public import wx.common;
public import wx.Bitmap;

//! \cond STD
version (Tango)
{
import tango.core.Version;
import tango.text.convert.Utf;
static if (Tango.Major == 0 && Tango.Minor >= 994 || Tango.Major >= 1)
alias tango.text.convert.Utf.toString toUtf8;
char[] toUTF8( char[] str) { return str; }
char[] toUTF8(wchar[] str) { return toUtf8(str); }
char[] toUTF8(dchar[] str) { return toUtf8(str); }
}
else // Phobos
{
private import std.string;
private import std.utf;
}
//! \endcond

		//! \cond EXTERN
		static extern (C) IntPtr wxIcon_ctor();
		static extern (C) void   wxIcon_CopyFromBitmap(IntPtr self, IntPtr bitmap);
		static extern (C) bool   wxIcon_LoadFile(IntPtr self, string name, BitmapType type);
		//! \endcond

		//---------------------------------------------------------------------

	alias Icon wxIcon;
	public class Icon : Bitmap
	{
		public static Icon wxNullIcon;
		public this(string name)
		{
			this();
			Image img = new Image();
			if (!img.LoadFile(name))
				throw new ArgumentException("file '" ~ toUTF8(name) ~ "' not found");

			Bitmap bmp = new Bitmap(img);
			wxIcon_CopyFromBitmap(wxobj, bmp.wxobj);
		}

		public this(string name, BitmapType type)
		{
			this();
//			if (type == BitmapType.wxBITMAP_TYPE_RESOURCE)
//			else
			if (!wxIcon_LoadFile(wxobj, name, type))
				throw new ArgumentException("file '" ~ toUTF8(name) ~ "' can't load");
		}

		public this()
		{
			super(wxIcon_ctor());
		}
		
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		//---------------------------------------------------------------------

		public void CopyFromBitmap(Bitmap bitmap)
		{
			wxIcon_CopyFromBitmap(wxobj, wxObject.SafePtr(bitmap));
		}

		//---------------------------------------------------------------------
	}
