//-----------------------------------------------------------------------------
// wxD - StaticBox.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - StaticBox.cs
//
/// The wxStaticBox wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
// $Id: StaticBox.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.StaticBox;
public import wx.common;
public import wx.Control;

		//! \cond EXTERN
		static extern (C) IntPtr wxStaticBox_ctor();
		static extern (C) bool wxStaticBox_Create(IntPtr self, IntPtr parent, int id, string label, ref Point pos, ref Size size, uint style, string name);
		//! \endcond
	
		//---------------------------------------------------------------------

	alias StaticBox wxStaticBox;
	public class StaticBox : Control
	{
		public const string wxStaticBoxNameStr = "groupBox";

		public this()
			{ super(wxStaticBox_ctor()); }

		public this(IntPtr wxobj)
			{ super(wxobj); }
			
		public this(Window window, int id, string label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name = wxStaticBoxNameStr)
		{
			this();
			if (!Create(window, id, label, pos, size, style, name))
			{
				throw new InvalidOperationException("Failed to create StaticBox");
			}
		}
		
		public static wxObject New(IntPtr wxobj) { return new StaticBox(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window window, string label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name = wxStaticBoxNameStr)
			{ this(window, Window.UniqueID, label, pos, size, style, name);}

		//---------------------------------------------------------------------

		public bool Create(Window window, int id, string label, ref Point pos, ref Size size, int style, string name)
		{
			return wxStaticBox_Create(wxobj, wxObject.SafePtr(window), 
					id, label, pos, size, 
					cast(uint)style, name);
		}
	}
