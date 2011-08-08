//-----------------------------------------------------------------------------
// wxD - Button.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - Button.cs
//
/// The wxButton wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Button.d,v 1.13 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.Button;
public import wx.common;
public import wx.Control;
public import wx.Bitmap;

		//! \cond EXTERN
		static extern (C) IntPtr wxButton_ctor();
		static extern (C) bool   wxButton_Create(IntPtr self, IntPtr parent, int id, string label, ref Point pos, ref Size size, uint style, IntPtr validator, string name);
		static extern (C) void   wxButton_SetDefault(IntPtr self);
		static extern (C) void   wxButton_GetDefaultSize(out Size size);
		
		static extern (C) void wxButton_SetImageMargins(IntPtr self, int x, int y);
		static extern (C) void wxButton_SetImageLabel(IntPtr self, IntPtr bitmap);
		
		static extern (C) void wxButton_SetLabel(IntPtr self, string label);
		//! \endcond

		//---------------------------------------------------------------------

	alias Button wxButton;
	public class Button : Control
	{
		public const int wxBU_LEFT          =  0x0040;
		public const int wxBU_TOP           =  0x0080;
		public const int wxBU_RIGHT         =  0x0100;
		public const int wxBU_BOTTOM        =  0x0200;
		public const int wxBU_EXACTFIT      =  0x0001;
		
		//---------------------------------------------------------------------
		
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ this(wxButton_ctor()); }

		public this(Window parent, int id, string label = "", Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, Validator validator = null, string name = null)
		{
			this(wxButton_ctor());
			if (!Create(parent, id, label, pos, size, style, validator, name))
			{
				throw new InvalidOperationException("Failed to create Button");
			}
		}
		
		public static wxObject New(IntPtr wxobj) { return new Button(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, string label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, Validator validator = null, string name = null)
			{ this(parent, Window.UniqueID, label, pos, size, style, validator, name);}
			
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, string label, Point pos, Size size, int style, Validator validator, string name)
		{
			return wxButton_Create(wxobj, wxObject.SafePtr(parent), id, label, pos, size, cast(uint)style, wxObject.SafePtr(validator), name);
		}

		//---------------------------------------------------------------------

		public void SetDefault()
		{
			wxButton_SetDefault(wxobj);
		}

		//---------------------------------------------------------------------

		public static Size GetDefaultSize()
		{
			Size size;
			wxButton_GetDefaultSize(size);
			return size;
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ void ImageLabel(Bitmap value)
		{
			wxButton_SetImageLabel(wxobj, wxObject.SafePtr(value));
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ void SetImageMargins(int x, int y)
		{
			wxButton_SetImageMargins(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------
		// Do we need get also ?
		
		public override void Label(string value)
		{
			wxButton_SetLabel(wxobj, value);
		}
		
		//---------------------------------------------------------------------
		
		public void Click_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_BUTTON_CLICKED, ID, value, this); }
		public void Click_Remove(EventListener value) { RemoveHandler(value, this); }
	}

