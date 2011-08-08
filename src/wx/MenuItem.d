//-----------------------------------------------------------------------------
// wxD - MenuItem.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - MenuItem.cs
//
/// The wxMenuItem wrapper class.
//
// Written by Achim Breunig(achim.breunig@web.de)
// (C) 2003 
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: MenuItem.d,v 1.10 2007/01/28 23:06:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.MenuItem;
public import wx.common;
public import wx.Accelerator;
public import wx.Menu;
public import wx.Bitmap;
public import wx.EvtHandler;

		//! \cond EXTERN
		static extern (C) IntPtr wxMenuItem_GetMenu(IntPtr self);
		static extern (C) void   wxMenuItem_SetMenu(IntPtr self, IntPtr menu);
		static extern (C) void   wxMenuItem_SetId(IntPtr self, int id);
		static extern (C) int    wxMenuItem_GetId(IntPtr self);
		static extern (C) bool   wxMenuItem_IsSeparator(IntPtr self);
		static extern (C) void   wxMenuItem_SetText(IntPtr self, string str);
		static extern (C) IntPtr wxMenuItem_GetLabel(IntPtr self);
		static extern (C) IntPtr wxMenuItem_GetText(IntPtr self);
		static extern (C) IntPtr wxMenuItem_GetLabelFromText(IntPtr self, string text);
		static extern (C) int    wxMenuItem_GetKind(IntPtr self);
		static extern (C) void   wxMenuItem_SetCheckable(IntPtr self, bool checkable);
		static extern (C) bool   wxMenuItem_IsCheckable(IntPtr self);
		static extern (C) bool   wxMenuItem_IsSubMenu(IntPtr self);
		static extern (C) void   wxMenuItem_SetSubMenu(IntPtr self, IntPtr menu);
		static extern (C) IntPtr wxMenuItem_GetSubMenu(IntPtr self);
		static extern (C) void   wxMenuItem_Enable(IntPtr self, bool enable);
		static extern (C) bool   wxMenuItem_IsEnabled(IntPtr self);
		static extern (C) void   wxMenuItem_Check(IntPtr self, bool check);
		static extern (C) bool   wxMenuItem_IsChecked(IntPtr self);
		static extern (C) void   wxMenuItem_Toggle(IntPtr self);
		static extern (C) void   wxMenuItem_SetHelp(IntPtr self, string str);
		static extern (C) IntPtr wxMenuItem_GetHelp(IntPtr self);
		static extern (C) IntPtr wxMenuItem_GetAccel(IntPtr self);
		static extern (C) void   wxMenuItem_SetAccel(IntPtr self, IntPtr accel);
		static extern (C) void   wxMenuItem_SetName(IntPtr self, string str);
		static extern (C) IntPtr wxMenuItem_GetName(IntPtr self);
		static extern (C) IntPtr wxMenuItem_NewCheck(IntPtr parentMenu, int id, string text, string help, bool isCheckable, IntPtr subMenu);
		static extern (C) IntPtr wxMenuItem_New(IntPtr parentMenu, int id, string text, string help, int kind, IntPtr subMenu);
		static extern (C) void   wxMenuItem_SetBitmap(IntPtr self, IntPtr bitmap);
		static extern (C) IntPtr wxMenuItem_GetBitmap(IntPtr self);
		static extern (C) IntPtr wxMenuItem_ctor(IntPtr parentMenu, int id, string text, string help, int kind, IntPtr subMenu);
		//! \endcond

		//-----------------------------------------------------------------------------

	alias MenuItem wxMenuItem;
	public class MenuItem : wxObject
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public  this(Menu parentMenu = null, int id =  wxID_SEPARATOR, string text = "", string help = "", ItemKind kind = ItemKind.wxITEM_NORMAL, Menu subMenu = null)
			{ this(wxMenuItem_ctor(wxObject.SafePtr(parentMenu), id, text, help, cast(int)kind, wxObject.SafePtr(subMenu))); }
			
		public static wxObject New2(IntPtr ptr) { return new MenuItem(ptr); }
		//-----------------------------------------------------------------------------

		public static MenuItem New(Menu parentMenu = null, int id = wxID_SEPARATOR, string text = "", string help = "", ItemKind kind=ItemKind.wxITEM_NORMAL, Menu subMenu = null)
		{
			return new MenuItem(wxMenuItem_New(wxObject.SafePtr(parentMenu), id, text, help, cast(int)kind, wxObject.SafePtr(subMenu)));
		}
	/* OLD API
		public static MenuItem New(Menu parentMenu, int id, string text, string help, bool isCheckable, Menu subMenu)
		{
			return new MenuItem(wxMenuItem_NewCheck(wxObject.SafePtr(parentMenu), id, text, help, isCheckable, wxObject.SafePtr(subMenu)));
		}

	*/	//-----------------------------------------------------------------------------

		public Menu menu() { return cast(Menu)FindObject(wxMenuItem_GetMenu(wxobj), &Menu.New); }
		public void menu(Menu value) { wxMenuItem_SetMenu(wxobj, wxObject.SafePtr(value)); }

		//-----------------------------------------------------------------------------

		public int ID() { return wxMenuItem_GetId(wxobj); }
		public void ID(int value) { wxMenuItem_SetId(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public bool IsSeparator() { return wxMenuItem_IsSeparator(wxobj); }
		
		//-----------------------------------------------------------------------------
		
		public void Text(string value) { wxMenuItem_SetText(wxobj, value); } 
		public string Text() { return cast(string) new wxString(wxMenuItem_GetText(wxobj), true); }

		//-----------------------------------------------------------------------------

		public string Label() { return cast(string) new wxString(wxMenuItem_GetLabel(wxobj), true); }

		//-----------------------------------------------------------------------------

		public string GetLabelFromText(string text)
		{
			return cast(string) new wxString(wxMenuItem_GetLabelFromText(wxobj, text), true);
		}

		//-----------------------------------------------------------------------------

		public ItemKind Kind() { return cast(ItemKind)wxMenuItem_GetKind(wxobj); }

		//-----------------------------------------------------------------------------

		public void Checkable(bool value) { wxMenuItem_SetCheckable(wxobj, value); }
		public bool Checkable() { return wxMenuItem_IsCheckable(wxobj); }

		//-----------------------------------------------------------------------------

		public bool IsSubMenu() { return wxMenuItem_IsSubMenu(wxobj); }

		public void SubMenu(Menu value) { wxMenuItem_SetSubMenu(wxobj, wxObject.SafePtr(value)); }
		public Menu SubMenu() { return cast(Menu)FindObject(wxMenuItem_GetSubMenu(wxobj), &Menu.New); }

		//-----------------------------------------------------------------------------

		public void Enabled(bool value) { wxMenuItem_Enable(wxobj, value); }
		public bool Enabled() { return wxMenuItem_IsEnabled(wxobj); }

		//-----------------------------------------------------------------------------

		public void Checked(bool value) { wxMenuItem_Check(wxobj, value); }
		public bool Checked() { return wxMenuItem_IsChecked(wxobj); }

		//-----------------------------------------------------------------------------

		public void Toggle()
		{
			wxMenuItem_Toggle(wxobj);
		}

		//-----------------------------------------------------------------------------

		public void Help(string value) { wxMenuItem_SetHelp(wxobj, value); }
		public string Help() { return cast(string) new wxString(wxMenuItem_GetHelp(wxobj), true); }

		//-----------------------------------------------------------------------------

		public AcceleratorEntry Accel() { return cast(AcceleratorEntry)FindObject(wxMenuItem_GetAccel(wxobj), &AcceleratorEntry.New); }
		public void Accel(AcceleratorEntry value) { wxMenuItem_SetAccel(wxobj, wxObject.SafePtr(value)); }

		//-----------------------------------------------------------------------------
		
		public void Name(string value) { wxMenuItem_SetName(wxobj, value); }
		public string Name() { return cast(string) new wxString(wxMenuItem_GetName(wxobj), true); }
		
		//-----------------------------------------------------------------------------
		
		public void bitmap(Bitmap value) { wxMenuItem_SetBitmap(wxobj, wxObject.SafePtr(value)); }
		public Bitmap bitmap() { return cast(Bitmap)FindObject(wxMenuItem_GetBitmap(wxobj), &Bitmap.New); }
		
		//---------------------------------------------------------------------
		
		public void Click_Add(EventListener value) { this.menu.AddEvent(ID, value, this); }
		public void Click_Remove(EventListener value) { }

        public void Select_Add(EventListener value) { this.menu.AddEvent(ID, value, this); }
        public void Select_Remove(EventListener value) { }
	}

