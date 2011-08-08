//-----------------------------------------------------------------------------
// wxD - Menu.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Menu.cs
//
/// The wxMenu wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Menu.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.Menu;
public import wx.common;
public import wx.Defs;
public import wx.Window;
public import wx.MenuItem;
public import wx.MenuBar;

		//! \cond EXTERN
		static extern (C) IntPtr wxMenuBase_ctor1(string titel, uint style);
		static extern (C) IntPtr wxMenuBase_ctor2(uint style);
		
		static extern (C) IntPtr wxMenuBase_Append(IntPtr self, int id, string item, string help, ItemKind kind);
		static extern (C) IntPtr wxMenuBase_AppendSubMenu(IntPtr self, int id, string item, IntPtr subMenu, string help);
		static extern (C) IntPtr wxMenuBase_AppendItem(IntPtr self, IntPtr item);
		static extern (C) IntPtr wxMenuBase_AppendSeparator(IntPtr self);
		static extern (C) IntPtr wxMenuBase_AppendCheckItem(IntPtr self, int itemid, string text, string help);
		static extern (C) IntPtr wxMenuBase_AppendRadioItem(IntPtr self, int itemid, string text, string help);
		static extern (C) int    wxMenuBase_GetMenuItemCount(IntPtr self);
		static extern (C) IntPtr wxMenuBase_GetMenuItem(IntPtr self, int index);
		static extern (C) void   wxMenuBase_Break(IntPtr self);
		
		static extern (C) IntPtr wxMenuBase_Insert(IntPtr self, int pos, IntPtr item);
		static extern (C) IntPtr wxMenuBase_Insert2(IntPtr self, int pos, int itemid, string text, string help, ItemKind kind);
		static extern (C) IntPtr wxMenuBase_InsertSeparator(IntPtr self, int pos);
		static extern (C) IntPtr wxMenuBase_InsertCheckItem(IntPtr self, int pos, int itemid, string text, string help);
		static extern (C) IntPtr wxMenuBase_InsertRadioItem(IntPtr self, int pos, int itemid, string text, string help);
		static extern (C) IntPtr wxMenuBase_InsertSubMenu(IntPtr self, int pos, int itemid, string text, IntPtr submenu, string help);
		
		static extern (C) IntPtr wxMenuBase_Prepend(IntPtr self, IntPtr item);
		static extern (C) IntPtr wxMenuBase_Prepend2(IntPtr self, int itemid, string text, string help, ItemKind kind);
		static extern (C) IntPtr wxMenuBase_PrependSeparator(IntPtr self);
		static extern (C) IntPtr wxMenuBase_PrependCheckItem(IntPtr self, int itemid, string text, string help);
		static extern (C) IntPtr wxMenuBase_PrependRadioItem(IntPtr self, int itemid, string text, string help);
		static extern (C) IntPtr wxMenuBase_PrependSubMenu(IntPtr self, int itemid, string text, IntPtr submenu, string help);
		
		static extern (C) IntPtr wxMenuBase_Remove(IntPtr self, int itemid);
		static extern (C) IntPtr wxMenuBase_Remove2(IntPtr self, IntPtr item);
		
		static extern (C) bool   wxMenuBase_Delete(IntPtr self, int itemid);
		static extern (C) bool   wxMenuBase_Delete2(IntPtr self, IntPtr item);
		
		static extern (C) bool   wxMenuBase_Destroy(IntPtr self, int itemid);
		static extern (C) bool   wxMenuBase_Destroy2(IntPtr self, IntPtr item);
		
		static extern (C) int    wxMenuBase_FindItem(IntPtr self, string item);
		static extern (C) IntPtr wxMenuBase_FindItem2(IntPtr self, int itemid, ref IntPtr menu); 
		static extern (C) IntPtr wxMenuBase_FindItemByPosition(IntPtr self, int position);
		
		static extern (C) void   wxMenuBase_Enable(IntPtr self, int itemid, bool enable);
		static extern (C) bool   wxMenuBase_IsEnabled(IntPtr self, int itemid);
		
		static extern (C) void   wxMenuBase_Check(IntPtr self, int id, bool check);
		static extern (C) bool   wxMenuBase_IsChecked(IntPtr self, int itemid);
		
		static extern (C) void   wxMenuBase_SetLabel(IntPtr self, int itemid, string label);
		static extern (C) IntPtr wxMenuBase_GetLabel(IntPtr self, int itemid);
		
		static extern (C) void   wxMenuBase_SetHelpString(IntPtr self, int itemid, string helpString);
		static extern (C) IntPtr wxMenuBase_GetHelpString(IntPtr self, int itemid);		
		
		static extern (C) void   wxMenuBase_SetTitle(IntPtr self, string title);
		static extern (C) IntPtr wxMenuBase_GetTitle(IntPtr self);		
		
		static extern (C) void   wxMenuBase_SetInvokingWindow(IntPtr self, IntPtr win);
		static extern (C) IntPtr wxMenuBase_GetInvokingWindow(IntPtr self);
		
		static extern (C) uint   wxMenuBase_GetStyle(IntPtr self);
		
		static extern (C) void   wxMenuBase_SetEventHandler(IntPtr self, IntPtr handler);
		static extern (C) IntPtr wxMenuBase_GetEventHandler(IntPtr self);
		
		static extern (C) void   wxMenuBase_UpdateUI(IntPtr self, IntPtr source);
		
		static extern (C) IntPtr wxMenuBase_GetMenuBar(IntPtr self);
		
		static extern (C) bool   wxMenuBase_IsAttached(IntPtr self);
		
		static extern (C) void   wxMenuBase_SetParent(IntPtr self, IntPtr parent);
		static extern (C) IntPtr wxMenuBase_GetParent(IntPtr self);
		
		static extern (C) IntPtr wxMenuBase_FindChildItem(IntPtr self, int itemid, out int pos);
		static extern (C) IntPtr wxMenuBase_FindChildItem2(IntPtr self, int itemid);
		static extern (C) bool   wxMenuBase_SendEvent(IntPtr self, int itemid, int xchecked);
		//! \endcond
	
	alias MenuBase wxMenuBase;
	public class MenuBase : EvtHandler
	{
		public this(IntPtr wxobj)
			{ super(wxobj); }
			
		public this(int style = 0)
			{ this(wxMenuBase_ctor2(cast(uint)style));}
		
		public this(string titel, int style = 0)
			{ this(wxMenuBase_ctor1(titel, cast(uint)style)); }
			
		//---------------------------------------------------------------------
		
		public MenuItem Append(int id, string item)
		{
			return this.Append(id, item, "");
		}
		
		public MenuItem Append(int id, string item, string help)
		{
			return Append(id, item, help, ItemKind.wxITEM_NORMAL);
		}		

		public MenuItem Append(int id, string item, string help, ItemKind kind)
		{
			return cast(MenuItem)FindObject(wxMenuBase_Append(wxobj, id, item, help, kind), &MenuItem.New2);
		}
		
		public MenuItem Append(int id, string item, Menu subMenu)
		{
			return Append(id, item, subMenu, "");
		}

		public MenuItem Append(int id, string item, Menu subMenu, string help)
		{
			return cast(MenuItem)FindObject(wxMenuBase_AppendSubMenu(wxobj, id, item, wxObject.SafePtr(subMenu), help), &MenuItem.New2);
		}

		public MenuItem Append(MenuItem item) 
		{
			return cast(MenuItem)FindObject(wxMenuBase_AppendItem(wxobj, wxObject.SafePtr(item)), &MenuItem.New2);
		}

		//---------------------------------------------------------------------
		
		public MenuItem AppendCheckItem(int id, string item)
		{
			return AppendCheckItem(id, item, "");
		}

		public MenuItem AppendCheckItem(int id, string item, string help)
		{
			return cast(MenuItem)FindObject(wxMenuBase_AppendCheckItem(wxobj, id, item, help), &MenuItem.New2);
		}

		//---------------------------------------------------------------------

		public MenuItem AppendSeparator()
		{
			return cast(MenuItem)FindObject(wxMenuBase_AppendSeparator(wxobj), &MenuItem.New2);
		}
		
		//---------------------------------------------------------------------
		
		public MenuItem AppendRadioItem(int itemid, string text)
		{
			return AppendRadioItem(itemid, text, "");
		}
		
		public MenuItem AppendRadioItem(int itemid, string text, string help)
		{
			return cast(MenuItem)FindObject(wxMenuBase_AppendRadioItem(wxobj, itemid, text, help), &MenuItem.New2);
		}

		//---------------------------------------------------------------------

		public void Check(int id, bool check)
		{
			wxMenuBase_Check(wxobj, id, check);
		}

		//---------------------------------------------------------------------

		public int GetMenuItemCount()
		{
			return wxMenuBase_GetMenuItemCount(wxobj);
		}

		public MenuItem GetMenuItem(int index)
		{
			return cast(MenuItem)FindObject(wxMenuBase_GetMenuItem(wxobj, index), &MenuItem.New2);
		}

		//---------------------------------------------------------------------
		
		public /+virtual+/ void Break()
		{
			wxMenuBase_Break(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public MenuItem Insert(int pos, MenuItem item)
		{
			return cast(MenuItem)FindObject(wxMenuBase_Insert(wxobj, pos, wxObject.SafePtr(item)), &MenuItem.New2);
		}
		
		//---------------------------------------------------------------------
		
		public MenuItem Insert(int pos, int itemid, string text)
		{
			return Insert(pos, itemid, text, "", ItemKind.wxITEM_NORMAL);
		}
		
		public MenuItem Insert(int pos, int itemid, string text, string help)
		{
			return Insert(pos, itemid, text, help, ItemKind.wxITEM_NORMAL);
		}
		
		public MenuItem Insert(int pos, int itemid, string text, string help, ItemKind kind)
		{
			return cast(MenuItem)FindObject(wxMenuBase_Insert2(wxobj, pos, itemid, text, help, kind), &MenuItem.New2);
		}
		
		//---------------------------------------------------------------------
		
		public MenuItem InsertSeparator(int pos)
		{
			return cast(MenuItem)FindObject(wxMenuBase_InsertSeparator(wxobj, pos), &MenuItem.New2);
		}
		
		//---------------------------------------------------------------------
		
		public MenuItem InsertCheckItem(int pos, int itemid, string text)
		{
			return InsertCheckItem(pos, itemid, text, "");
		}
		
		public MenuItem InsertCheckItem(int pos, int itemid, string text, string help)
		{
			return cast(MenuItem)FindObject(wxMenuBase_InsertCheckItem(wxobj, pos, itemid, text, help), &MenuItem.New2);
		}		
		
		//---------------------------------------------------------------------
		
		public MenuItem InsertRadioItem(int pos, int itemid, string text)
		{
			return InsertCheckItem(pos, itemid, text, "");
		}
		
		public MenuItem InsertRadioItem(int pos, int itemid, string text, string help)
		{
			return cast(MenuItem)FindObject(wxMenuBase_InsertRadioItem(wxobj, pos, itemid, text, help), &MenuItem.New2);
		}				
		
		//---------------------------------------------------------------------

		public MenuItem Insert(int pos, int itemid, string text, Menu submenu)
		{
			return Insert(pos, itemid, text, submenu, "");
		}
		
		public MenuItem Insert(int pos, int itemid, string text, Menu submenu, string help)
		{
			return cast(MenuItem)FindObject(wxMenuBase_InsertSubMenu(wxobj, pos, itemid, text, wxObject.SafePtr(submenu), help), &MenuItem.New2);
		}
		
		//---------------------------------------------------------------------
		
		public MenuItem Prepend(MenuItem item)
		{
			return cast(MenuItem)FindObject(wxMenuBase_Prepend(wxobj, wxObject.SafePtr(item)), &MenuItem.New2);
		}
		
		//---------------------------------------------------------------------
		
		public MenuItem Prepend(int itemid, string text)
		{
			return Prepend(itemid, text, "", ItemKind.wxITEM_NORMAL);
		}
		
		public MenuItem Prepend(int itemid, string text, string help)
		{
			return Prepend(itemid, text, help, ItemKind.wxITEM_NORMAL);
		}
		
		public MenuItem Prepend(int itemid, string text, string help, ItemKind kind)
		{
			return cast(MenuItem)FindObject(wxMenuBase_Prepend2(wxobj, itemid, text, help, kind), &MenuItem.New2);
		}
		
		//---------------------------------------------------------------------
		
		public MenuItem PrependSeparator()
		{
			return cast(MenuItem)FindObject(wxMenuBase_PrependSeparator(wxobj));
		}
		
		//---------------------------------------------------------------------
		
		public MenuItem PrependCheckItem(int itemid, string text)
		{
			return PrependCheckItem(itemid, text, "");
		}
		
		public MenuItem PrependCheckItem(int itemid, string text, string help)
		{
			return cast(MenuItem)FindObject(wxMenuBase_PrependCheckItem(wxobj, itemid, text, help), &MenuItem.New2);
		}
		
		//---------------------------------------------------------------------
		
		public MenuItem PrependRadioItem(int itemid, string text)
		{
			return PrependRadioItem(itemid, text, "");
		}
		
		public MenuItem PrependRadioItem(int itemid, string text, string help)
		{
			return cast(MenuItem)FindObject(wxMenuBase_PrependRadioItem(wxobj, itemid, text, help), &MenuItem.New2);
		}		
		
		//---------------------------------------------------------------------
		
		public MenuItem Prepend(int itemid, string text, Menu submenu)
		{
			return Prepend(itemid, text, submenu, "");
		}
		
		public MenuItem Prepend(int itemid, string text, Menu submenu, string help)
		{
			return cast(MenuItem)FindObject(wxMenuBase_PrependSubMenu(wxobj, itemid, text, wxObject.SafePtr(submenu), help), &MenuItem.New2);
		}
		
		//---------------------------------------------------------------------
		
		public MenuItem Remove(int itemid)
		{
			return cast(MenuItem)FindObject(wxMenuBase_Remove(wxobj, itemid), &MenuItem.New2);
		}
		
		public MenuItem Remove(MenuItem item)
		{
			return cast(MenuItem)FindObject(wxMenuBase_Remove2(wxobj, wxObject.SafePtr(item)), &MenuItem.New2);
		}		
		
		//---------------------------------------------------------------------
		
		public bool Delete(int itemid)
		{
			return wxMenuBase_Delete(wxobj, itemid);
		}
		
		public bool Delete(MenuItem item)
		{
			return wxMenuBase_Delete2(wxobj, wxObject.SafePtr(item));
		}
		
		//---------------------------------------------------------------------
		
		public bool Destroy(int itemid)
		{
			return wxMenuBase_Destroy(wxobj, itemid);
		}
		
		public bool Destroy(MenuItem item)
		{
			return wxMenuBase_Destroy2(wxobj, wxObject.SafePtr(item));
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ int FindItem(string item)
		{
			return wxMenuBase_FindItem(wxobj, item);
		}
		
		//---------------------------------------------------------------------
		
		public MenuItem FindItem(int itemid)
		{
			Menu menuRef = null;
			return FindItem(itemid, menuRef);
		}
		
		public MenuItem FindItem(int itemid, ref Menu menu)
		{
			IntPtr menuRef = IntPtr.init;
			if (menu) 
			{
				menuRef = wxObject.SafePtr(menu);
			}
			return cast(MenuItem)FindObject(wxMenuBase_FindItem2(wxobj, itemid, menuRef), &MenuItem.New2);
		}
		
		//---------------------------------------------------------------------
		 
		public MenuItem FindItemByPosition(int position)
		{
			return cast(MenuItem)FindObject(wxMenuBase_FindItemByPosition(wxobj, position), &MenuItem.New2);
		}
		
		//---------------------------------------------------------------------
		
		public void Enable(int itemid, bool enable)
		{
			wxMenuBase_Enable(wxobj, itemid, enable);
		}
		
		public bool IsEnabled(int itemid)
		{
			return wxMenuBase_IsEnabled(wxobj, itemid);
		}
		
		//---------------------------------------------------------------------
		
		public bool IsChecked(int itemid)
		{
			return wxMenuBase_IsChecked(wxobj, itemid);
		}
		
		//---------------------------------------------------------------------
		
		public void SetLabel(int itemid, string label)
		{
			wxMenuBase_SetLabel(wxobj, itemid, label);
		}
		
		public string GetLabel(int itemid)
		{
			return cast(string) new wxString(wxMenuBase_GetLabel(wxobj, itemid), true);
		}
		
		//---------------------------------------------------------------------
		
		public void SetHelpString(int itemid, string helpString)
		{
			wxMenuBase_SetHelpString(wxobj, itemid, helpString);
		}
		
		public string GetHelpString(int itemid)
		{
			return cast(string) new wxString(wxMenuBase_GetHelpString(wxobj, itemid), true);
		}
		
		//---------------------------------------------------------------------
		
		public string Title() { return cast(string) new wxString(wxMenuBase_GetTitle(wxobj), true); }
		public void Title(string value) { wxMenuBase_SetTitle(wxobj, value); }
		
		//---------------------------------------------------------------------
		
		public EvtHandler EventHandler() {
		//	return cast(EvtHandler)FindObject(wxMenuBase_GetEventHandler(wxobj), &EvtHandler.New);
			IntPtr ptr = wxMenuBase_GetEventHandler(wxobj);
			wxObject o = FindObject(ptr);
			if (o) return cast(EvtHandler)o;
			else return new EvtHandler(ptr);
		}
		public void EventHandler(EvtHandler value) { wxMenuBase_SetEventHandler(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------
		
		public Window InvokingWindow() { return cast(Window)FindObject(wxMenuBase_GetInvokingWindow(wxobj), &Window.New); }
		public void InvokingWindow(Window value) { wxMenuBase_SetInvokingWindow(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------
		
		public int Style() { return cast(int)wxMenuBase_GetStyle(wxobj); }
		
		//---------------------------------------------------------------------
		
		public void UpdateUI()
		{
			UpdateUI(null);
		}
		
		public void UpdateUI(EvtHandler source)
		{
			wxMenuBase_UpdateUI(wxobj, wxObject.SafePtr(source));
		}
		
		//---------------------------------------------------------------------
		
		public MenuBar menuBar() { return cast(MenuBar)FindObject(wxMenuBase_GetMenuBar(wxobj), &MenuBar.New); }
		
		//---------------------------------------------------------------------
		
		public bool Attached() { return wxMenuBase_IsAttached(wxobj); }
		
		//---------------------------------------------------------------------
		
		public Menu Parent() { return cast(Menu)FindObject(wxMenuBase_GetParent(wxobj), &Menu.New); }
		public void Parent(Menu value) { wxMenuBase_SetParent(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------
		
		public MenuItem FindChildItem(int itemid)
		{
			return cast(MenuItem)FindObject(wxMenuBase_FindChildItem2(wxobj, itemid), &MenuItem.New2);
		}
		
		public MenuItem FindChildItem(int itemid, out int pos)
		{
			return cast(MenuItem)FindObject(wxMenuBase_FindChildItem(wxobj, itemid, pos), &MenuItem.New2);
		}
		
		//---------------------------------------------------------------------
		
		public bool SendEvent(int itemid)
		{
			return SendEvent(itemid, -1);
		}
		
		public bool SendEvent(int itemid, int xchecked)
		{
			return wxMenuBase_SendEvent(wxobj, itemid, xchecked);
		}		
	}
	
	//---------------------------------------------------------------------
	// helper struct, stores added EventListeners...
	
	alias MenuListener wxMenuListener;
	public class MenuListener
	{
		public EventListener listener;
		public wxObject owner;
		public int id;
		
		public this( int id, EventListener listener, wxObject owner )
		{
			this.listener = listener;
			this.owner = owner;
			this.id = id;
		}
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxMenu_ctor(string titel, uint style);
		static extern (C) IntPtr wxMenu_ctor2(uint style);
		//! \endcond
		
		//---------------------------------------------------------------------
		
	alias Menu wxMenu;
	public class Menu : MenuBase
	{
		public MenuListener[] eventListeners;

		// InvokingWindow does not work on Windows, so we 
		// need this...
		private Window parent = null;

		// if events were connected with Frame.MenuBar or Window.PopupMenu
		// that means with ConnectEvents(), we have a Invoking Window and can add 
		// the event directly to the EventHandler
		private bool eventsconnected = false; 
		
		//---------------------------------------------------------------------
		 
		public this()
			{ this(0);}
			
		public this(int style)
			{ this(wxMenu_ctor2(cast(uint)style));}
		
		public this(string titel)
			{ this(titel, 0);}
		
		public this(string titel, int style)
			{ this(wxMenu_ctor(titel, cast(uint)style)); }

		public this(IntPtr wxobj)
			{ super(wxobj); }

		public static wxObject New(IntPtr wxobj)
		{
			return new Menu(wxobj);
		}
			
		//---------------------------------------------------------------------
			
		public void AddEvent(int inId, EventListener el, wxObject owner)
		{
			// This is the only way of handling menu selection events (maybe there is an other solution)
			// But for now we have to add the EventListener to the EventHandler of the invoking window,
			// otherwise nothing happens.
			// As int as we do not have an invoking window, which means, that for example the
			// MenuBar of this Menu isn't connected to a Frame, the EventListener gets only
			// added to the ArrayList, otherwise it gets directly added to the EventHandler of
			// the invoking window. When Frame.MenuBar is set, it will call ConnectEvents() 
			// for each Menu ; MenuBar
			eventListeners ~=  new MenuListener( inId, el, owner );
			
			if ( eventsconnected )
				parent.AddCommandListener(Event.wxEVT_COMMAND_MENU_SELECTED, inId, el, owner);
		}	
		
		//---------------------------------------------------------------------
		// ConnectEvents gets only called from Window and Frame
		
		public void ConnectEvents(Window parent)
		{
			this.parent = parent;

			if ( eventListeners.length > 0 )
			{
				foreach( MenuListener ml ; eventListeners )
				{
					parent.AddCommandListener(Event.wxEVT_COMMAND_MENU_SELECTED, ml.id, ml.listener, ml.owner);
				}
			}
			
			eventsconnected = true;
		}
		
		//---------------------------------------------------------------------
		
		// This is for faster coding ;) and closes request on SourceForge ;))))
		// WL stands for with listener
		public MenuItem AppendWL(int id, string item, EventListener listener)
		{
			MenuItem tmpitem = Append(id, item, "");
			
			AddEvent( id, listener, tmpitem );
			
			return tmpitem;
		}
		
		public MenuItem AppendWL(int id, string item, string help, EventListener listener)
		{
			MenuItem tmpitem = Append(id, item, help, ItemKind.wxITEM_NORMAL);
			
			AddEvent( id, listener, tmpitem );
			
			return tmpitem;
		}
		
		public MenuItem AppendWL(int id, string item, string help, ItemKind kind, EventListener listener)
		{
			MenuItem tmpitem = Append(id, item, help, kind);
			
			AddEvent( id, listener, tmpitem );
			
			return tmpitem;
		}
		
		public MenuItem AppendWL(int id, string item, Menu subMenu, EventListener listener)
		{
			MenuItem tmpitem = Append(id, item, subMenu, "");
			
			AddEvent( id, listener, tmpitem );
			
			return tmpitem;
		}

		public MenuItem AppendWL(int id, string item, Menu subMenu, string help, EventListener listener)
		{
			MenuItem tmpitem = Append(id, item, subMenu, help);
			
			AddEvent( id, listener, tmpitem );
			
			return tmpitem;
		}

		public MenuItem AppendWL(MenuItem item, EventListener listener) 
		{
			MenuItem tmpitem = Append(item);
			AddEvent(item.ID, listener, tmpitem);
			return tmpitem;
		}
	}
