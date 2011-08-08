//-----------------------------------------------------------------------------
// wxD - GDIObject.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - GDIObject.cs
//
/// The wxGDIObject wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: GDIObject.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.GDIObject;
public import wx.common;

		//! \cond EXTERN
		static extern (C) void wxGDIObj_dtor(IntPtr self);
		//! \endcond

		//---------------------------------------------------------------------

	alias GDIObject wxGDIObject;
	public class GDIObject : wxObject
	{
		public this(IntPtr wxobj) 
			{ super(wxobj);}

		/*public override void Dispose()
		{
			wxobj = IntPtr.init;
			Dispose(false);
		}*/		

		//---------------------------------------------------------------------
	}
