//-----------------------------------------------------------------------------
// wxD - Colour.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - Colour.cs
//
/// The wxColour wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Colour.d,v 1.10 2007/04/17 15:24:20 afb Exp $
//-----------------------------------------------------------------------------

module wx.Colour;
public import wx.common;

//! \cond STD
version (Tango)
{
}
else // Phobos
{
private import std.string;
private import std.utf;
}
//! \endcond

		//! \cond EXTERN
		static extern (C) IntPtr wxColour_ctor();
		static extern (C) IntPtr wxColour_ctorByName(string name);
		static extern (C) IntPtr wxColour_ctorByParts(ubyte red, ubyte green, ubyte blue);
		static extern (C) void   wxColour_dtor(IntPtr self);
		//static extern (C) void   wxColour_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);

		static extern (C) ubyte   wxColour_Red(IntPtr self);
		static extern (C) ubyte   wxColour_Blue(IntPtr self);
		static extern (C) ubyte   wxColour_Green(IntPtr self);

		static extern (C) bool   wxColour_Ok(IntPtr self);
		static extern (C) void   wxColour_Set(IntPtr self, ubyte red, ubyte green, ubyte blue);
		
		static extern (C) IntPtr wxColour_CreateByName(string name);
		//! \endcond

		//---------------------------------------------------------------------

	alias Colour wxColour;
	public class Colour : wxObject
	{
		public static Colour wxBLACK;
		public static Colour wxWHITE;
		public static Colour wxRED;
		public static Colour wxBLUE;
		public static Colour wxGREEN;
		public static Colour wxCYAN;
		public static Colour wxLIGHT_GREY;
		public static Colour wxNullColour;

		//---------------------------------------------------------------------

		public this(IntPtr wxobj)
		{
			super(wxobj);
		}
			
		public this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}

		public this() 
		{ 
			this(wxColour_ctor(), true);
			//wxColour_RegisterDisposable(wxobj, &VirtualDispose);
		}

		public this(string name)
		{ 
			this(wxColour_ctorByName(name), true); // toupper
			//wxColour_RegisterDisposable(wxobj, &VirtualDispose);
		}

		public this(ubyte red, ubyte green, ubyte blue)
		{ 
			this(wxColour_ctorByParts(red, green, blue), true);
			//wxColour_RegisterDisposable(wxobj, &VirtualDispose);
		}

		//---------------------------------------------------------------------

		public override void Dispose()
		{
			if ((this != Colour.wxBLACK) && (this != Colour.wxWHITE) &&
				(this != Colour.wxRED) && (this != Colour.wxBLUE) &&
					(this != Colour.wxGREEN) && (this != Colour.wxCYAN) &&
						(this != Colour.wxLIGHT_GREY)) 
			{
				super.Dispose(/*true*/);
			}
		}

		//---------------------------------------------------------------------

		public ubyte Red() { return wxColour_Red(wxobj); }

		public ubyte Green() { return wxColour_Green(wxobj); }

		public ubyte Blue() { return wxColour_Blue(wxobj); }

		//---------------------------------------------------------------------

		public bool Ok()
		{
			return wxColour_Ok(wxobj);
		}

		public void Set(ubyte red, ubyte green, ubyte blue)
		{
			wxColour_Set(wxobj, red, green, blue);
		}

		//---------------------------------------------------------------------
		
		version(__WXGTK__){
		public static Colour CreateByName(string name)
		{
			return new Colour(wxColour_CreateByName(name), true);
		}
		} // version(__WXGTK__)

		public static wxObject New(IntPtr ptr) { return new Colour(ptr); }
	}
