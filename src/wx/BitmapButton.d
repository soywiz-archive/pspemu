//-----------------------------------------------------------------------------
// wxD - BitmapButton.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - BitMapButton.cs
//
/// The wxBitmapButton wrapper class.
//
// Written by Robert Roebling
// (C) 2003 Robert Roebling
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: BitmapButton.d,v 1.12 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.BitmapButton;
public import wx.common;
public import wx.Bitmap;
public import wx.Button;
public import wx.Control;

		//! \cond EXTERN
		extern (C) {
		alias void function(BitmapButton obj) Virtual_OnSetBitmap;
		}
		
		static extern (C) IntPtr wxBitmapButton_ctor();
		static extern (C) void   wxBitmapButton_RegisterVirtual(IntPtr self, BitmapButton obj,Virtual_OnSetBitmap onSetBitmap);
		//static extern (C) void   wxBitmapButton_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) bool   wxBitmapButton_Create(IntPtr self, IntPtr parent, int id, IntPtr label, ref Point pos, ref Size size, uint style, IntPtr validator, string name);
		static extern (C) void   wxBitmapButton_SetDefault(IntPtr self);
		
		static extern (C) void wxBitmapButton_SetLabel(IntPtr self, string label);
		static extern (C) IntPtr wxBitmapButton_GetLabel(IntPtr self);
		
		static extern (C) bool wxBitmapButton_Enable(IntPtr self, bool enable);

		static extern (C) void   wxBitmapButton_SetBitmapLabel(IntPtr self, IntPtr bitmap);
		static extern (C) IntPtr wxBitmapButton_GetBitmapLabel(IntPtr self);
		
		static extern (C) void wxBitmapButton_SetBitmapSelected(IntPtr self, IntPtr bitmap);
		static extern (C) IntPtr wxBitmapButton_GetBitmapSelected(IntPtr self);

		static extern (C) void wxBitmapButton_SetBitmapFocus(IntPtr self, IntPtr bitmap);
		static extern (C) IntPtr wxBitmapButton_GetBitmapFocus(IntPtr self);

		static extern (C) void wxBitmapButton_SetBitmapDisabled(IntPtr self, IntPtr bitmap);
		static extern (C) IntPtr wxBitmapButton_GetBitmapDisabled(IntPtr self);
		
		static extern (C) void wxBitmapButton_OnSetBitmap(IntPtr self);
		
		//static extern (C) void wxBitmapButton_ApplyParentThemeBackground(IntPtr self, IntPtr colour);
		//! \endcond

		//---------------------------------------------------------------------
		
		public const int wxBU_AUTODRAW      =  0x0004;
		
		//---------------------------------------------------------------------
		
	alias BitmapButton wxBitmapButton;
	public class BitmapButton : Control
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
		{
			this(wxBitmapButton_ctor());
			wxBitmapButton_RegisterVirtual(wxobj, this, &staticOnSetBitmap);
		}

		public this(Window parent, int id, Bitmap label)
			{ this(parent, id, label, wxDefaultPosition, wxDefaultSize, 0, null, null); }

		public this(Window parent, int id, Bitmap label, Point pos)
			{ this(parent, id, label, pos, wxDefaultSize, 0, null, null); }

		public this(Window parent, int id, Bitmap label, Point pos, Size size)
			{ this(parent, id, label, pos, size, 0, null, null); }

		public this(Window parent, int id, Bitmap label, Point pos, Size size, int style)
			{ this(parent, id, label, pos, size, style, null, null); }

		public this(Window parent, int id, Bitmap label, Point pos, Size size, int style, Validator validator)
			{ this(parent, id, label, pos, size, style, validator, null); }

		public this(Window parent, int id, Bitmap label, Point pos, Size size, int style, Validator validator, string name)
		{
			this();
			
			if (!Create(parent, id, label, pos, size, style, validator, name))
			{
				throw new InvalidOperationException("Failed to create BitmapButton");
			}
		}
			
		public static wxObject New(IntPtr wxobj) { return new BitmapButton(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
			
		public this(Window parent, Bitmap label)
			{ this(parent, Window.UniqueID, label, wxDefaultPosition, wxDefaultSize, 0, null, null); }

		public this(Window parent, Bitmap label, Point pos)
			{ this(parent, Window.UniqueID, label, pos, wxDefaultSize, 0, null, null); }

		public this(Window parent, Bitmap label, Point pos, Size size)
			{ this(parent, Window.UniqueID, label, pos, size, 0, null, null); }

		public this(Window parent, Bitmap label, Point pos, Size size, int style)
			{ this(parent, Window.UniqueID, label, pos, size, style, null, null); }

		public this(Window parent, Bitmap label, Point pos, Size size, int style, Validator validator)
			{ this(parent, Window.UniqueID, label, pos, size, style, validator, null); }

		public this(Window parent, Bitmap label, Point pos, Size size, int style, Validator validator, string name)
			{ this(parent, Window.UniqueID, label, pos, size, style, validator, name);}

		//---------------------------------------------------------------------
		
		public bool Create(Window parent, int id, Bitmap label, Point pos, Size size, uint style, Validator validator, string name)
		{
			return wxBitmapButton_Create(wxobj, wxObject.SafePtr(parent), id, wxObject.SafePtr(label), pos, size, style, wxObject.SafePtr(validator), name);
		}

		//---------------------------------------------------------------------		

		public void SetDefault()
		{
			wxBitmapButton_SetDefault(wxobj);
		}
		
		//---------------------------------------------------------------------		
		
		public string StringLabel() { return cast(string) new wxString(wxBitmapButton_GetLabel(wxobj), true); }
		public void StringLabel(string value) { wxBitmapButton_SetLabel(wxobj, value); }
		
		public void SetLabel(string label)
		{
			wxBitmapButton_SetLabel(wxobj, label);
		}
		
		public string GetLabel()
		{
			return cast(string) new wxString(wxBitmapButton_GetLabel(wxobj), true);
		}
		
		//---------------------------------------------------------------------
		
		public bool Enable()
		{
			return Enable(true);
		}
		
		public bool Enable(bool enable)
		{
			return wxBitmapButton_Enable(wxobj, enable);
		}

		//---------------------------------------------------------------------

		public Bitmap BitmapLabel() { return cast(Bitmap)FindObject(wxBitmapButton_GetBitmapLabel(wxobj), &Bitmap.New); }
		public void BitmapLabel(Bitmap value) { wxBitmapButton_SetBitmapLabel(wxobj, wxObject.SafePtr(value)); }
/+
		public Bitmap Label() { return cast(Bitmap)FindObject(wxBitmapButton_GetBitmapLabel(wxobj), &Bitmap.New); }
		public void Label(Bitmap value) { wxBitmapButton_SetBitmapLabel(wxobj, wxObject.SafePtr(value)); }
+/
		
		//---------------------------------------------------------------------
		
		public Bitmap BitmapSelected() { return cast(Bitmap)FindObject(wxBitmapButton_GetBitmapSelected(wxobj), &Bitmap.New); }
		public void BitmapSelected(Bitmap value) { wxBitmapButton_SetBitmapSelected(wxobj, wxObject.SafePtr(value)); }
		
		public Bitmap BitmapFocus() { return cast(Bitmap)FindObject(wxBitmapButton_GetBitmapFocus(wxobj), &Bitmap.New); }
		public void BitmapFocus(Bitmap value) { wxBitmapButton_SetBitmapFocus(wxobj, wxObject.SafePtr(value)); }

		public Bitmap BitmapDisabled() { return cast(Bitmap)FindObject(wxBitmapButton_GetBitmapDisabled(wxobj), &Bitmap.New); }
		public void BitmapDisabled(Bitmap value) { wxBitmapButton_SetBitmapDisabled(wxobj, wxObject.SafePtr(value)); }

		//---------------------------------------------------------------------
		//! \cond EXTERN
		extern(C) private static void staticOnSetBitmap(BitmapButton obj) { return obj.OnSetBitmap(); }
		//! \endcond
		protected /+virtual+/ void OnSetBitmap()
		{
			wxBitmapButton_OnSetBitmap(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		/*public /+virtual+/ void ApplyParentThemeBackground(Colour bg)
		{
			wxBitmapButton_ApplyParentThemeBackground(wxobj, wxObject.SafePtr(bg));
		}*/
	}
