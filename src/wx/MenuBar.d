//-----------------------------------------------------------------------------
// wxD - MenuBar.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - MenuBar.cs
//
/// The wxMenuBar wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: MenuBar.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.MenuBar;
public import wx.common;
public import wx.EvtHandler;
public import wx.Menu;

		//! \cond EXTERN
		static extern (C) IntPtr wxMenuBar_ctor();
		static extern (C) IntPtr wxMenuBar_ctor2(uint style);
		static extern (C) bool   wxMenuBar_Append(IntPtr self, IntPtr menu, string title);
		static extern (C) void   wxMenuBar_Check(IntPtr self, int id, bool check);
		static extern (C) bool   wxMenuBar_IsChecked(IntPtr self, int id);
        	static extern (C) bool   wxMenuBar_Insert(IntPtr self, int pos, IntPtr menu, string title);
        	static extern (C) IntPtr wxMenuBar_FindItem(IntPtr self, int id, ref IntPtr menu);
		
		static extern (C) int    wxMenuBar_GetMenuCount(IntPtr self);
		static extern (C) IntPtr wxMenuBar_GetMenu(IntPtr self, int pos);
		
		static extern (C) IntPtr wxMenuBar_Replace(IntPtr self, int pos, IntPtr menu, string title);
		static extern (C) IntPtr wxMenuBar_Remove(IntPtr self, int pos);
		
		static extern (C) void   wxMenuBar_EnableTop(IntPtr self, int pos, bool enable);
		
		static extern (C) void   wxMenuBar_Enable(IntPtr self, int id, bool enable);
		
		static extern (C) int    wxMenuBar_FindMenu(IntPtr self, string title);
		static extern (C) int    wxMenuBar_FindMenuItem(IntPtr self, string menustring, string itemString);
		
		static extern (C) IntPtr wxMenuBar_GetHelpString(IntPtr self, int id);
		static extern (C) IntPtr wxMenuBar_GetLabel(IntPtr self, int id);
		static extern (C) IntPtr wxMenuBar_GetLabelTop(IntPtr self, int pos);
		
		static extern (C) bool   wxMenuBar_IsEnabled(IntPtr self, int id);
		
		static extern (C) void   wxMenuBar_Refresh(IntPtr self);
		
		static extern (C) void   wxMenuBar_SetHelpString(IntPtr self, int id, string helpstring);
		static extern (C) void   wxMenuBar_SetLabel(IntPtr self, int id, string label);
		static extern (C) void   wxMenuBar_SetLabelTop(IntPtr self, int pos, string label);
		//! \endcond

	alias MenuBar wxMenuBar;
	public class MenuBar : EvtHandler
	{
		//---------------------------------------------------------------------

		public this()
			{ this(wxMenuBar_ctor()); }
			
		public this(int style)
			{ this(wxMenuBar_ctor2(cast(uint)style));}

		public this(IntPtr wxobj)
			{ super(wxobj); }

		public static wxObject New(IntPtr wxobj)
		{
			return new MenuBar(wxobj);
		}

		//---------------------------------------------------------------------

		public bool Append(Menu menu, string title)
		{
			return wxMenuBar_Append(wxobj, menu.wxobj, title);
		}

		//---------------------------------------------------------------------

		public void Check(int id, bool check)
		{
			wxMenuBar_Check(wxobj, id, check);
		}

		//---------------------------------------------------------------------

		public bool IsChecked(int id)
		{
			return wxMenuBar_IsChecked(wxobj, id); 
		}

		public bool Insert(int pos, Menu menu, string title)
		{
			return wxMenuBar_Insert(wxobj, pos, wxObject.SafePtr(menu), title);
		}
		
		//-----------------------------------------------------------------------------
		
		public MenuItem FindItem(int id)
		{ 
			Menu menu = null;
			return FindItem(id, menu); 
		}
		
		public MenuItem FindItem(int id, ref Menu menu)
		{
			IntPtr menuRef = IntPtr.init;
			if (menu) 
			{
				menuRef = wxObject.SafePtr(menu);
			}
		
			return cast(MenuItem)FindObject(wxMenuBar_FindItem(wxobj, id, menuRef), &MenuItem.New2);
		}
		
		//-----------------------------------------------------------------------------
		
		public int MenuCount() { return wxMenuBar_GetMenuCount(wxobj); }
		
		//-----------------------------------------------------------------------------
		
		public Menu GetMenu(int pos)
		{
			return cast(Menu)FindObject(wxMenuBar_GetMenu(wxobj, pos), &Menu.New);
		}
		
		//-----------------------------------------------------------------------------
		
		public Menu Replace(int pos, Menu menu, string title)
		{
			return cast(Menu)FindObject(wxMenuBar_Replace(wxobj, pos, wxObject.SafePtr(menu), title), &Menu.New);
		}
		
		//-----------------------------------------------------------------------------
		
		public Menu Remove(int pos)
		{
			return cast(Menu)FindObject(wxMenuBar_Remove(wxobj, pos), &Menu.New);
		}
		
		//-----------------------------------------------------------------------------
		
		public void EnableTop(int pos, bool enable)
		{
			wxMenuBar_EnableTop(wxobj, pos, enable);
		}
		
		//-----------------------------------------------------------------------------
		
		public void Enable(int id, bool enable)
		{
			wxMenuBar_Enable(wxobj, id, enable);
		}
		
		//-----------------------------------------------------------------------------
		
		public int FindMenu(string title)
		{
			return wxMenuBar_FindMenu(wxobj, title);
		}
		
		//-----------------------------------------------------------------------------
		
		public int FindMenuItem(string menustring, string itemString)
		{
			return wxMenuBar_FindMenuItem(wxobj, menustring, itemString);
		}
		
		//-----------------------------------------------------------------------------
		
		public string GetHelpString(int id)
		{
			return cast(string) new wxString(wxMenuBar_GetHelpString(wxobj, id), true);
		}
		
		//-----------------------------------------------------------------------------
		
		public string GetLabel(int id)
		{
			return cast(string) new wxString(wxMenuBar_GetLabel(wxobj, id), true);
		}
		
		//-----------------------------------------------------------------------------
		
		public string GetLabelTop(int pos)
		{
			return cast(string) new wxString(wxMenuBar_GetLabelTop(wxobj, pos), true);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool IsEnabled(int id)
		{
			return wxMenuBar_IsEnabled(wxobj, id);
		}
		
		//-----------------------------------------------------------------------------
		
		public void Refresh()
		{
			wxMenuBar_Refresh(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public void SetHelpString(int id, string helpstring)
		{
			wxMenuBar_SetHelpString(wxobj, id, helpstring);
		}
		
		//-----------------------------------------------------------------------------
		
		public void SetLabel(int id, string label)
		{
			wxMenuBar_SetLabel(wxobj, id, label);
		}
		
		//-----------------------------------------------------------------------------
		
		public void SetLabelTop(int pos, string label)
		{
			wxMenuBar_SetLabelTop(wxobj, pos, label);
		}
	}
