//-----------------------------------------------------------------------------
// wxD - StaticBoxSizer.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - StaticBoxSizer.cs
//
/// The wxStaticBoxSizer proxy interface.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
// $Id: StaticBoxSizer.d,v 1.10 2007/08/20 08:39:16 afb Exp $
//-----------------------------------------------------------------------------

module wx.StaticBoxSizer;
public import wx.common;
public import wx.BoxSizer;
public import wx.StaticBox;

		//! \cond EXTERN
		static extern (C) IntPtr wxStaticBoxSizer_ctor(IntPtr box, int orient);
		static extern (C) IntPtr wxStaticBoxSizer_GetStaticBox(IntPtr self);
		//! \endcond

		//---------------------------------------------------------------------

	alias StaticBoxSizer wxStaticBoxSizer;
	public class StaticBoxSizer : BoxSizer
	{
		public this(IntPtr wxobj)
		{
			super(wxobj);
		}

		public this(StaticBox box, int orient)
		{
			super(wxStaticBoxSizer_ctor(wxObject.SafePtr(box), orient));
		}

		public this(int orient, Window parent, string label)
		{
			this(new StaticBox(parent, -1, label), orient);
		}

		//---------------------------------------------------------------------

		public StaticBox staticBox() 
			{
				return cast(StaticBox)FindObject(
                                    wxStaticBoxSizer_GetStaticBox(wxobj)
                                );
			}

		//---------------------------------------------------------------------
	}
