//-----------------------------------------------------------------------------
// wxD - Listbook.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Listbook.cs
//
/// The wxListbook wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Listbook.d,v 1.12 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.Listbook;
public import wx.common;
public import wx.Control;
public import wx.ImageList;

		//! \cond EXTERN
		static extern (C) IntPtr wxListbookEvent_ctor(int commandType, int id, int nSel, int nOldSel);
		static extern (C) int    wxListbookEvent_GetSelection(IntPtr self);
		static extern (C) void   wxListbookEvent_SetSelection(IntPtr self, int nSel);
		static extern (C) int    wxListbookEvent_GetOldSelection(IntPtr self);
		static extern (C) void   wxListbookEvent_SetOldSelection(IntPtr self, int nOldSel);
		static extern (C) void wxListbookEvent_Veto(IntPtr self);
		static extern (C) void wxListbookEvent_Allow(IntPtr self);
		static extern (C) bool wxListbookEvent_IsAllowed(IntPtr self);		
		//! \endcond

		//-----------------------------------------------------------------------------

	alias ListbookEvent wxListbookEvent;
	public class ListbookEvent : Event
	{
		public this(IntPtr wxobj)
			{ super(wxobj); }

		public this(EventType commandType, int id, int nSel, int nOldSel)
			{ super(wxListbookEvent_ctor(commandType, id, nSel, nOldSel)); }

		static Event New(IntPtr ptr) { return new ListbookEvent(ptr); }
		//-----------------------------------------------------------------------------

		public int Selection() { return wxListbookEvent_GetSelection(wxobj); }
		public void Selection(int value) { wxListbookEvent_SetSelection(wxobj, value); }

		//-----------------------------------------------------------------------------

		public int OldSelection() { return wxListbookEvent_GetOldSelection(wxobj); }
		public void OldSelection(int value) { wxListbookEvent_SetOldSelection(wxobj, value); }
		
		//-----------------------------------------------------------------------------		
		
		public void Veto()
		{
			wxListbookEvent_Veto(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public void Allow()
		{
			wxListbookEvent_Allow(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool Allowed() { return wxListbookEvent_IsAllowed(wxobj); }

		static this()
		{
			wxEVT_COMMAND_LISTBOOK_PAGE_CHANGED = wxEvent_EVT_COMMAND_LISTBOOK_PAGE_CHANGED();
			wxEVT_COMMAND_LISTBOOK_PAGE_CHANGING = wxEvent_EVT_COMMAND_LISTBOOK_PAGE_CHANGING();

			AddEventType(wxEVT_COMMAND_LISTBOOK_PAGE_CHANGED,   &ListbookEvent.New);
			AddEventType(wxEVT_COMMAND_LISTBOOK_PAGE_CHANGING,  &ListbookEvent.New);
		}
	}
	
	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxListbook_ctor();
		static extern (C) bool wxListbook_Create(IntPtr self, IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) int wxListbook_GetSelection(IntPtr self);
		static extern (C) bool wxListbook_SetPageText(IntPtr self, int n, string strText);
		static extern (C) IntPtr wxListbook_GetPageText(IntPtr self, int n);
		static extern (C) int wxListbook_GetPageImage(IntPtr self, int n);
		static extern (C) bool wxListbook_SetPageImage(IntPtr self, int n, int imageId);
		static extern (C) void wxListbook_CalcSizeFromPage(IntPtr self, ref Size sizePage, out Size outSize);
		static extern (C) bool wxListbook_InsertPage(IntPtr self, int n, IntPtr page, string text, bool bSelect, int imageId);
		static extern (C) int wxListbook_SetSelection(IntPtr self, int n);
		static extern (C) void wxListbook_SetImageList(IntPtr self, IntPtr imageList);
		static extern (C) bool wxListbook_IsVertical(IntPtr self);
		static extern (C) int wxListbook_GetPageCount(IntPtr self);
		static extern (C) IntPtr wxListbook_GetPage(IntPtr self, int n);
		static extern (C) void wxListbook_AssignImageList(IntPtr self, IntPtr imageList);
		static extern (C) IntPtr wxListbook_GetImageList(IntPtr self);
		static extern (C) void wxListbook_SetPageSize(IntPtr self, ref Size size);
		static extern (C) bool wxListbook_DeletePage(IntPtr self, int nPage);
		static extern (C) bool wxListbook_RemovePage(IntPtr self, int nPage);
		static extern (C) bool wxListbook_DeleteAllPages(IntPtr self);
		static extern (C) bool wxListbook_AddPage(IntPtr self, IntPtr page, string text, bool bselect, int imageId);
		static extern (C) void wxListbook_AdvanceSelection(IntPtr self, bool forward);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias Listbook wxListbook;
	public class Listbook : Control
	{
		public const int wxLB_DEFAULT		= 0;
		public const int wxLB_TOP		= 0x1;
		public const int wxLB_BOTTOM		= 0x2;
		public const int wxLB_LEFT		= 0x4;
		public const int wxLB_RIGHT		= 0x8;
		public const int wxLB_ALIGN_MASK	= 0xf;
		
		//-----------------------------------------------------------------------------

		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ super(wxListbook_ctor());}

		public this(Window parent, int id, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name = "")
		{
			super(wxListbook_ctor());
			wxListbook_Create(wxobj, wxObject.SafePtr(parent), id, pos, size, cast(uint)style, name);
		}
		
		public static wxObject New(IntPtr wxobj) { return new Listbook(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name = "")
			{ this(parent, Window.UniqueID, pos, size, style, name);}
		
		//-----------------------------------------------------------------------------

		public int Selection() { return wxListbook_GetSelection(wxobj); }
		public void Selection(int value) { wxListbook_SetSelection(wxobj, value); }
		
		//-----------------------------------------------------------------------------

		public bool SetPageText(int n, string strText)
		{
			return wxListbook_SetPageText(wxobj, n, strText);
		}
		
		//-----------------------------------------------------------------------------

		public string GetPageText(int n)
		{
			return cast(string) new wxString(wxListbook_GetPageText(wxobj, n), true);
		}
		
		//-----------------------------------------------------------------------------

		public int GetPageImage(int n)
		{
			return wxListbook_GetPageImage(wxobj, n);
		}
		
		//-----------------------------------------------------------------------------

		public bool SetPageImage(int n, int imageId)
		{
			return wxListbook_SetPageImage(wxobj, n, imageId);
		}
		
		//-----------------------------------------------------------------------------

		public Size CalcSizeFromPage(Size sizePage)
		{
			Size s;
			wxListbook_CalcSizeFromPage(wxobj, sizePage, s);
			return s;
		}
		
		//-----------------------------------------------------------------------------

		
		public bool InsertPage(int n, Window page, string text)
		{
			return InsertPage(n, page, text, false, -1);
		}
		

		public bool InsertPage(int n, Window page, string text, bool bSelect)
		{
			return InsertPage(n, page, text, bSelect, -1);
		}
		
		public bool InsertPage(int n, Window page, string text, bool bSelect, int imageId)
		{
			return wxListbook_InsertPage(wxobj, n, wxObject.SafePtr(page), text, bSelect, imageId);
		}
		
		//-----------------------------------------------------------------------------

		public void imageList(ImageList value) { wxListbook_SetImageList(wxobj, wxObject.SafePtr(value)); }
		public ImageList imageList() { return cast(ImageList)FindObject(wxListbook_GetImageList(wxobj), &ImageList.New); }
		
		//-----------------------------------------------------------------------------

		public bool Vertical() { return wxListbook_IsVertical(wxobj); }
		
		//-----------------------------------------------------------------------------

		public int PageCount() { return wxListbook_GetPageCount(wxobj); }
		
		//-----------------------------------------------------------------------------

		public Window GetPage(int n)
		{
		//	return cast(Window)FindObject(wxListbook_GetPage(wxobj, n), &Window.New);
			IntPtr ptr = wxListbook_GetPage(wxobj, n);
			wxObject o = FindObject(ptr);
			if (o) return cast(Window)o;
			else return new Window(ptr);
		}
		
		//-----------------------------------------------------------------------------

		public void AssignImageList(ImageList imageList)
		{
			wxListbook_AssignImageList(wxobj, wxObject.SafePtr(imageList));
		}
		
		//-----------------------------------------------------------------------------

		public void PageSize(Size value) { wxListbook_SetPageSize(wxobj, value); }
		
		//-----------------------------------------------------------------------------

		public bool DeletePage(int nPage)
		{
			return wxListbook_DeletePage(wxobj, nPage);
		}
		
		//-----------------------------------------------------------------------------

		public bool RemovePage(int nPage)
		{
			return wxListbook_RemovePage(wxobj, nPage);
		}
		
		//-----------------------------------------------------------------------------

		public bool DeleteAllPages()
		{
			return wxListbook_DeleteAllPages(wxobj);
		}
		
		//-----------------------------------------------------------------------------

		public bool AddPage(Window page, string text, bool bSelect, int imageId)
		{
			return wxListbook_AddPage(wxobj, wxObject.SafePtr(page), text, bSelect, imageId);
		}
		
		//-----------------------------------------------------------------------------

		public void AdvanceSelection(bool forward)
		{
			wxListbook_AdvanceSelection(wxobj, forward);
		}

		//-----------------------------------------------------------------------------

		public void PageChange_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LISTBOOK_PAGE_CHANGED, ID, value, this); }
		public void PageChange_Remove(EventListener value) { RemoveHandler(value, this); }

		public void PageChanging_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LISTBOOK_PAGE_CHANGING, ID, value, this); }
		public void PageChanging_Remove(EventListener value) { RemoveHandler(value, this); }
	}
		
