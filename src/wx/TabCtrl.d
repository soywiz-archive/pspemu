//-----------------------------------------------------------------------------
// wxD - TabCtrl.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - TabCtrl.cs
//
/// The wxTabCtrl wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: TabCtrl.d,v 1.12 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.TabCtrl;

//! \cond VERSION
version(none) {
//! \endcond

public import wx.common;
public import wx.Event;
public import wx.Control;
public import wx.ImageList;
public import wx.wxString;

		//! \cond EXTERN
		static extern (C) IntPtr wxTabEvent_ctor(int commandType, int id, int nSel, int nOldSel);
		static extern (C) int    wxTabEvent_GetSelection(IntPtr self);
		static extern (C) void   wxTabEvent_SetSelection(IntPtr self, int nSel);
		static extern (C) int    wxTabEvent_GetOldSelection(IntPtr self);
		static extern (C) void   wxTabEvent_SetOldSelection(IntPtr self, int nOldSel);
		static extern (C) void wxTabEvent_Veto(IntPtr self);
		static extern (C) void wxTabEvent_Allow(IntPtr self);
		static extern (C) bool wxTabEvent_IsAllowed(IntPtr self);		
		//! \endcond

		//-----------------------------------------------------------------------------

	alias TabEvent wxTabEvent;
	public class TabEvent : Event
	{
		public this(IntPtr wxobj)
			{ super(wxobj); }

		public this(int commandType, int id, int nSel, int nOldSel)
			{ super(wxTabEvent_ctor(commandType, id, nSel, nOldSel)); }

		//-----------------------------------------------------------------------------

		public int Selection() { return wxTabEvent_GetSelection(wxobj); }
		public void Selection(int value) { wxTabEvent_SetSelection(wxobj, value); }

		//-----------------------------------------------------------------------------

		public int OldSelection() { return wxTabEvent_GetOldSelection(wxobj); }
		public void OldSelection(int value) { wxTabEvent_SetOldSelection(wxobj, value); }
		
		//-----------------------------------------------------------------------------		
		
		public void Veto()
		{
			wxTabEvent_Veto(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public void Allow()
		{
			wxTabEvent_Allow(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool Allowed() { return wxTabEvent_IsAllowed(wxobj); }

		private static Event New(IntPtr obj) { return new TabEvent(obj); }

		static this()
		{
			wxEVT_COMMAND_TAB_SEL_CHANGED = wxEvent_EVT_COMMAND_TAB_SEL_CHANGED();
			wxEVT_COMMAND_TAB_SEL_CHANGING = wxEvent_EVT_COMMAND_TAB_SEL_CHANGING();

			AddEventType(wxEVT_COMMAND_TAB_SEL_CHANGED,   &TabEvent.New);
			AddEventType(wxEVT_COMMAND_TAB_SEL_CHANGING,  &TabEvent.New);
		}
	}

	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxTabCtrl_ctor();
		static extern (C) IntPtr wxTabCtrl_ctor2(IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) int wxTabCtrl_GetSelection(IntPtr self);
		static extern (C) int wxTabCtrl_GetCurFocus(IntPtr self);
		static extern (C) IntPtr wxTabCtrl_GetImageList(IntPtr self);
		static extern (C) int wxTabCtrl_GetItemCount(IntPtr self);
		static extern (C) bool wxTabCtrl_GetItemRect(IntPtr self, int item, out Rectangle rect);
		static extern (C) int wxTabCtrl_GetRowCount(IntPtr self);
		static extern (C) IntPtr wxTabCtrl_GetItemText(IntPtr self, int item);
		static extern (C) int wxTabCtrl_GetItemImage(IntPtr self, int item);
		static extern (C) IntPtr wxTabCtrl_GetItemData(IntPtr self, int item);
		static extern (C) int wxTabCtrl_SetSelection(IntPtr self, int item);
		static extern (C) void wxTabCtrl_SetImageList(IntPtr self, IntPtr imageList);
		static extern (C) bool wxTabCtrl_SetItemText(IntPtr self, int item, string text);
		static extern (C) bool wxTabCtrl_SetItemImage(IntPtr self, int item, int image);
		static extern (C) bool wxTabCtrl_SetItemData(IntPtr self, int item, IntPtr data);
		static extern (C) void wxTabCtrl_SetItemSize(IntPtr self, ref Size size);
		static extern (C) bool wxTabCtrl_Create(IntPtr self, IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) void wxTabCtrl_SetPadding(IntPtr self, ref Size padding);
		static extern (C) bool wxTabCtrl_DeleteAllItems(IntPtr self);
		static extern (C) bool wxTabCtrl_DeleteItem(IntPtr self, int item);
		static extern (C) int wxTabCtrl_HitTest(IntPtr self, ref Point pt, out int flags);
		static extern (C) bool wxTabCtrl_InsertItem(IntPtr self, int item, string text, int imageId, IntPtr data);
		//! \endcond

	alias TabCtrl wxTabCtrl;
	public class TabCtrl : Control
	{
		//-----------------------------------------------------------------------------

		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ super(wxTabCtrl_ctor());}

		public this(Window parent, int id, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style =0, string name = "tabCtrl")
			{ super(wxTabCtrl_ctor2(wxObject.SafePtr(parent), id, pos, size, cast(uint)style, name));}
			
		public static wxObject New(IntPtr wxobj) { return new TabCtrl(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style =0, string name = "tabCtrl")
			{ this(parent, Window.UniqueID, pos, size, style, name);}

		//-----------------------------------------------------------------------------

		public bool Create(Window parent, int id, ref Point pos, ref Size size, int style, string name)
		{
			return wxTabCtrl_Create(wxobj, wxObject.SafePtr(parent), id, pos, size, cast(uint)style, name);
		}
		
		//-----------------------------------------------------------------------------

		public int Selection() { return wxTabCtrl_GetSelection(wxobj); }
		public void Selection(int value) { wxTabCtrl_SetSelection(wxobj, value); }
		
		//-----------------------------------------------------------------------------

		public int CurFocus() { return wxTabCtrl_GetCurFocus(wxobj); }
		
		//-----------------------------------------------------------------------------

		public wxImageList ImageList() { return cast(wxImageList)FindObject(wxTabCtrl_GetImageList(wxobj)); }
		public void ImageList(wxImageList value) { wxTabCtrl_SetImageList(wxobj, wxObject.SafePtr(value)); }
		
		//-----------------------------------------------------------------------------

		public int ItemCount() { return wxTabCtrl_GetItemCount(wxobj); }
		
		//-----------------------------------------------------------------------------

		public bool GetItemRect(int item, out Rectangle rect)
		{
			return wxTabCtrl_GetItemRect(wxobj, item, rect);
		}
		
		//-----------------------------------------------------------------------------

		public int RowCount() { return wxTabCtrl_GetRowCount(wxobj); }
		
		//-----------------------------------------------------------------------------

		public string GetItemText(int item)
		{
			wxString text = new wxString(wxTabCtrl_GetItemText(wxobj, item));
			return text.toString();
		}
		
		//-----------------------------------------------------------------------------

		public int GetItemImage(int item)
		{
			return wxTabCtrl_GetItemImage(wxobj, item);
		}
		
		//-----------------------------------------------------------------------------

		public IntPtr GetItemData(int item)
		{
			return wxTabCtrl_GetItemData(wxobj, item);
		}
		
		//-----------------------------------------------------------------------------

		public bool SetItemText(int item, string text)
		{
			return wxTabCtrl_SetItemText(wxobj, item, text);
		}
		
		//-----------------------------------------------------------------------------

		public bool SetItemImage(int item, int image)
		{
			return wxTabCtrl_SetItemImage(wxobj, item, image);
		}
		
		//-----------------------------------------------------------------------------

		public bool SetItemData(int item, IntPtr data)
		{
			return wxTabCtrl_SetItemData(wxobj, item, data);
		}
		
		//-----------------------------------------------------------------------------

		public void ItemSize(Size value) { wxTabCtrl_SetItemSize(wxobj, value); }
		
		//-----------------------------------------------------------------------------

		public void Padding(Size value) { wxTabCtrl_SetPadding(wxobj, value); }
		
		//-----------------------------------------------------------------------------

		public bool DeleteAllItems()
		{
			return wxTabCtrl_DeleteAllItems(wxobj);
		}
		
		//-----------------------------------------------------------------------------

		public bool DeleteItem(int item)
		{
			return wxTabCtrl_DeleteItem(wxobj, item);
		}
		
		//-----------------------------------------------------------------------------

		public int HitTest(Point pt, out int flags)
		{
			return wxTabCtrl_HitTest(wxobj, pt, flags);
		}
		
		//-----------------------------------------------------------------------------

		public bool InsertItem(int item, string text)
		{
			return InsertItem(item, text, -1, IntPtr.init);
		}
		
		public bool InsertItem(int item, string text, int imageId)
		{
			return InsertItem(item, text, imageId, IntPtr.init);
		}
		
		public bool InsertItem(int item, string text, int imageId, IntPtr data)
		{
			return wxTabCtrl_InsertItem(wxobj, item, text, imageId, data);
		}

		//---------------------------------------------------------------------

		public void SelectionChange_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TAB_SEL_CHANGED, ID, value, this); }
		public void SelectionChange_Remove(EventListener value) { RemoveHandler(value, this); }

		public void SelectionChanging_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TAB_SEL_CHANGING, ID, value, this); }
		public void SelectionChanging_Remove(EventListener value) { RemoveHandler(value, this); }
	}

//! \cond VERSION
} // version(__WXMSW__)
//! \endcond
