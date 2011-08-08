//-----------------------------------------------------------------------------
// wxD - StaticLine.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - StaticLine.cs
//
/// The wxStaticLine wrapper class.
//
// Written by Robert Roebling
// (C) 2003 by Robert Roebling
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: StaticLine.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.StaticLine;
public import wx.common;
public import wx.Control;

		//! \cond EXTERN
		static extern (C) IntPtr wxStaticLine_ctor();
		static extern (C) bool wxStaticLine_Create(IntPtr self, IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) bool wxStaticLine_IsVertical(IntPtr self);
		static extern (C) int  wxStaticLine_GetDefaultSize(IntPtr self);
		//! \endcond

		//---------------------------------------------------------------------

	alias StaticLine wxStaticLine;
	public class StaticLine : Control
	{
		enum {
			wxLI_HORIZONTAL	= Orientation.wxHORIZONTAL,
			wxLI_VERTICAL		= Orientation.wxVERTICAL,
		}
		
		public const string wxStaticTextNameStr = "message";
		//---------------------------------------------------------------------
		
		public this(IntPtr wxobj) 
			{ super(wxobj);}
        
		public this()
			{ super(wxStaticLine_ctor()); }

		public this(Window parent, int id, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = wxLI_HORIZONTAL, string name = wxStaticTextNameStr)
		{
			super(wxStaticLine_ctor());
			if (!Create(parent, id, pos, size, style, name))
			{
				throw new InvalidOperationException("Failed to create StaticText");
			}
		}
		
		public static wxObject New(IntPtr wxobj) { return new StaticLine(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = wxLI_HORIZONTAL, string name = wxStaticTextNameStr)
			{ this(parent, Window.UniqueID, pos, size, style, name);}
		
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, ref Point pos, ref Size size, int style, string name)
		{
			return wxStaticLine_Create(wxobj, wxObject.SafePtr(parent), id, pos, size, cast(uint)style, name);
		}
		
		//---------------------------------------------------------------------
		
		public bool IsVertical()
		{
			return wxStaticLine_IsVertical(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public int DefaultSize() { return wxStaticLine_GetDefaultSize(wxobj); }
	}
