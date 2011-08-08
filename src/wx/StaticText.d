//-----------------------------------------------------------------------------
// wxD - StaticText.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - StaticText.cs
//
/// The wxStaticText wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: StaticText.d,v 1.12 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.StaticText;
public import wx.common;
public import wx.Control;

		//! \cond EXTERN
		static extern (C) IntPtr wxStaticText_ctor();
		static extern (C) bool   wxStaticText_Create(IntPtr self, IntPtr parent, int id, string label, ref Point pos, ref Size size, uint style, string name);
		static extern (C) void   wxStaticText_Wrap(IntPtr self, int width);
		//! \endcond

		//---------------------------------------------------------------------
		
	alias StaticText wxStaticText;
	public class StaticText : Control
	{
		public const int wxST_NO_AUTORESIZE = 0x0001;
	
		public const string wxStaticTextNameStr = "message";
	
		public this(IntPtr wxobj) 
			{ super(wxobj);}

		public this()
			{ super(wxStaticText_ctor()); }

		public this(Window parent, int id, string label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name = wxStaticTextNameStr)
		{
			super(wxStaticText_ctor());
			if (!Create(parent, id, label, pos, size, style, name))
			{
				throw new InvalidOperationException("Failed to create StaticText");
			}
		}

		public static wxObject New(IntPtr wxobj) { return new StaticText(wxobj); }
		
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, string label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name = wxStaticTextNameStr)
			{ this(parent, Window.UniqueID, label, pos, size, style, name);}
		
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, string label, ref Point pos, ref Size size, int style, string name)
		{
			return wxStaticText_Create(wxobj, wxObject.SafePtr(parent), id, label, pos, size, cast(uint)style, name);
		}
	
		//---------------------------------------------------------------------

		public void Wrap(int width)
		{
			wxStaticText_Wrap(wxobj, width);
		}
	}
