//-----------------------------------------------------------------------------
// wxD - wxString.d
// (C) 2005 bero <berobero.sourceforge.net>
// (C) 2006 afb <afb@users.sourceforge.net>
// based on
// wx.NET - wxString.cs
//
/// The wxString wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: wxString.d,v 1.18 2010/10/11 09:41:07 afb Exp $
//-----------------------------------------------------------------------------

module wx.wxString;
public import wx.common;

//! \cond STD
version (Tango)
{
import tango.core.Version;
static if (Tango.Major == 0 && Tango.Minor < 994)
alias Object.toUtf8 toString;
}
else // Phobos
{
private import std.string;
private import std.utf;
}
//! \endcond

		//! \cond EXTERN
		static extern (C) IntPtr  wxString_ctor(string str);
		static extern (C) IntPtr  wxString_ctor2(wxChar* str, size_t len);
		static extern (C) void    wxString_dtor(IntPtr self);
		static extern (C) size_t  wxString_Length(IntPtr self);
		static extern (C) wxChar* wxString_Data(IntPtr self);
		static extern (C) wxChar  wxString_GetChar(IntPtr self, size_t i);
		static extern (C) void    wxString_SetChar(IntPtr self, size_t i, wxChar c);

		static extern (C) size_t  wxString_ansi_len(IntPtr self);
		static extern (C) size_t  wxString_ansi_str(IntPtr self, ubyte *buffer, size_t buflen);
		static extern (C) size_t  wxString_wide_len(IntPtr self);
		static extern (C) size_t  wxString_wide_str(IntPtr self, wchar_t *buffer, size_t buflen);
		static extern (C) size_t  wxString_utf8_len(IntPtr self);
		static extern (C) size_t  wxString_utf8_str(IntPtr self, char *buffer, size_t buflen);
		//! \endcond
		
		//---------------------------------------------------------------------

	/// wxString is a class representing a character string.
	public class wxString : wxObject
	{
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
			
		package this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}

		public this()
			{ this(""); }

		public this(string str)
			{ this(wxString_ctor(str), true); }

		public this(wxChar* wxstr, size_t wxlen)
			{ this(wxString_ctor2(wxstr, wxlen), true); }
		
		//---------------------------------------------------------------------
		override protected void dtor() { wxString_dtor(wxobj); }				
		//---------------------------------------------------------------------

		public size_t length() { return wxString_Length(wxobj); }
		public wxChar* data() { return wxString_Data(wxobj); }
		public wxChar opIndex(size_t i) { return wxString_GetChar(wxobj, i); }
		public void opIndexAssign(wxChar c, size_t i) { wxString_SetChar(wxobj, i, c); }
		public string opCast() { return this.toString(); }
		public ubyte[] toAnsi()
		{
			size_t len = wxString_ansi_len(wxobj);
			ubyte[] buffer = new ubyte[len + 1]; // include NUL
			len = wxString_ansi_str(wxobj, buffer.ptr, buffer.length);
			buffer.length = len;
			return buffer;
		}
		public wchar_t[] toWide()
		{
			size_t len = wxString_wide_len(wxobj);
			wchar_t[] buffer = new wchar_t[len + 1]; // include NUL
			len = wxString_wide_str(wxobj, buffer.ptr, buffer.length);
			buffer.length = len;
			return buffer;
		}
version (D_Version2)
{
		public override string toString()
		{
			size_t len = wxString_utf8_len(wxobj);
			char[] buffer = new char[len + 1]; // include NUL
			len = wxString_utf8_str(wxobj, buffer.ptr, buffer.length);
			buffer.length = len;
			return cast(string) buffer;
		}
}
else // D_Version1
{
		public string toString()
		{
			size_t len = wxString_utf8_len(wxobj);
			char[] buffer = new char[len + 1]; // include NUL
			len = wxString_utf8_str(wxobj, buffer.ptr, buffer.length);
			buffer.length = len;
			return cast(string) buffer;
		}
}
	}

