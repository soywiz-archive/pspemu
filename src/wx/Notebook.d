//-----------------------------------------------------------------------------
// wxD - Notebook.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Notebook.cs
//
/// The wxNotebook wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Notebook.d,v 1.12 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.Notebook;
public import wx.common;
public import wx.Event;
public import wx.Control;
public import wx.ImageList;

		//! \cond EXTERN
		static extern (C) IntPtr wxNotebookEvent_ctor(int commandType, int id, int nSel, int nOldSel);
		static extern (C) int    wxNotebookEvent_GetSelection(IntPtr self);
		static extern (C) void   wxNotebookEvent_SetSelection(IntPtr self, int nSel);
		static extern (C) int    wxNotebookEvent_GetOldSelection(IntPtr self);
		static extern (C) void   wxNotebookEvent_SetOldSelection(IntPtr self, int nOldSel);
		static extern (C) void wxNotebookEvent_Veto(IntPtr self);
		static extern (C) void wxNotebookEvent_Allow(IntPtr self);
		static extern (C) bool wxNotebookEvent_IsAllowed(IntPtr self);		
		//! \endcond

		//-----------------------------------------------------------------------------

	alias NotebookEvent wxNotebookEvent;
	public class NotebookEvent : Event
	{
		public this(IntPtr wxobj)
			{ super(wxobj); }

		public this(int commandType, int id, int nSel, int nOldSel)
			{ super(wxNotebookEvent_ctor(commandType, id, nSel, nOldSel)); }

		//-----------------------------------------------------------------------------

		public int Selection() { return wxNotebookEvent_GetSelection(wxobj); }
		public void Selection(int value) { wxNotebookEvent_SetSelection(wxobj, value); }

		//-----------------------------------------------------------------------------

		public int OldSelection() { return wxNotebookEvent_GetOldSelection(wxobj); }
		public void OldSelection(int value) { wxNotebookEvent_SetOldSelection(wxobj, value); }
		
		//-----------------------------------------------------------------------------		
		
		public void Veto()
		{
			wxNotebookEvent_Veto(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public void Allow()
		{
			wxNotebookEvent_Allow(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool Allowed() { return wxNotebookEvent_IsAllowed(wxobj); }

		private static Event New(IntPtr obj) { return new NotebookEvent(obj); }

		static this()
		{
			wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED = wxEvent_EVT_COMMAND_NOTEBOOK_PAGE_CHANGED();
			wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGING = wxEvent_EVT_COMMAND_NOTEBOOK_PAGE_CHANGING();

			AddEventType(wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED,   &NotebookEvent.New);
			AddEventType(wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGING,  &NotebookEvent.New);
		}
	}

		//! \cond EXTERN
		static extern (C) IntPtr wxNotebook_ctor();
		static extern (C) bool   wxNotebook_AddPage(IntPtr self, IntPtr page, string text, bool select, int imageId);
		static extern (C) bool   wxNotebook_Create(IntPtr self, IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) int    wxNotebook_GetPageCount(IntPtr self);
		static extern (C) IntPtr wxNotebook_GetPage(IntPtr self, int nPage);
		static extern (C) int    wxNotebook_GetSelection(IntPtr self);
		static extern (C) bool   wxNotebook_SetPageText(IntPtr self, int nPage, string strText);
		static extern (C) IntPtr wxNotebook_GetPageText(IntPtr self, int nPage);
		static extern (C) void   wxNotebook_SetImageList(IntPtr self, IntPtr imageList);
		static extern (C) void   wxNotebook_AssignImageList(IntPtr self, IntPtr imageList);
		static extern (C) IntPtr wxNotebook_GetImageList(IntPtr self);
		static extern (C) int    wxNotebook_GetPageImage(IntPtr self, int nPage);
		static extern (C) bool   wxNotebook_SetPageImage(IntPtr self, int nPage, int nImage);
		static extern (C) int    wxNotebook_GetRowCount(IntPtr self);
		static extern (C) void   wxNotebook_SetPageSize(IntPtr self, ref Size size);
		static extern (C) void   wxNotebook_SetPadding(IntPtr self, ref Size padding);
		static extern (C) void   wxNotebook_SetTabSize(IntPtr self, ref Size sz);
		static extern (C) bool   wxNotebook_DeletePage(IntPtr self, int nPage);
		static extern (C) bool   wxNotebook_RemovePage(IntPtr self, int nPage);
		static extern (C) bool   wxNotebook_DeleteAllPages(IntPtr self);
		static extern (C) bool   wxNotebook_InsertPage(IntPtr self, int nPage, IntPtr pPage, string strText, bool bSelect, int imageId);
		static extern (C) int    wxNotebook_SetSelection(IntPtr self, int nPage);
		static extern (C) void   wxNotebook_AdvanceSelection(IntPtr self, bool forward);
		//! \endcond

		//---------------------------------------------------------------------
		
	alias Notebook wxNotebook;
	public class Notebook : Control
	{
		public const int wxNB_FIXEDWIDTH       = 0x0010;
		public const int wxNB_TOP              = 0x0000;
		public const int wxNB_LEFT             = 0x0020;
		public const int wxNB_RIGHT            = 0x0040;
		public const int wxNB_BOTTOM           = 0x0080;
		public const int wxNB_MULTILINE        = 0x0100;
	
		public const string wxNOTEBOOK_NAME = "notebook";
		//-----------------------------------------------------------------------------

		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ super(wxNotebook_ctor()); }

		public this(Window parent, int id, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name = wxNOTEBOOK_NAME)
		{
			super(wxNotebook_ctor());
			if (!wxNotebook_Create(wxobj, wxObject.SafePtr(parent), id, pos, size, style, name)) 
			{
				throw new InvalidOperationException("Failed to create Notebook");
			}
		}

		public static wxObject New(IntPtr wxobj) { return new Notebook(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
			
		public this(Window parent, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name = wxNOTEBOOK_NAME)
			{ this(parent, Window.UniqueID, pos, size, style, name);}
        
		//---------------------------------------------------------------------

		// TODO: Switch window with NotebookPage

		public bool AddPage(Window page, string text)
		{ return AddPage(page, text, false, -1); }
		
		public bool AddPage(Window page, string text, bool select)
		{ return AddPage(page, text, select, -1); }
		
		public bool AddPage(Window page, string text, bool select, int imageId)
		{
			return wxNotebook_AddPage(wxobj, wxObject.SafePtr(page), text, select, imageId);
		}

		//---------------------------------------------------------------------

		public void Images(ImageList value) { wxNotebook_SetImageList(wxobj, wxObject.SafePtr(value)); }
		public ImageList Images() { return cast(ImageList)FindObject(wxNotebook_GetImageList(wxobj)); }

		//---------------------------------------------------------------------

		public int PageCount() { return wxNotebook_GetPageCount(wxobj); }

		// TODO: Switch window with NotebookPage
		public Window GetPage(int page)
		{
			return cast(Window)FindObject(wxNotebook_GetPage(wxobj, page));
		}

		//---------------------------------------------------------------------

		public int Selection() { return wxNotebook_GetSelection(wxobj); }
		public void Selection(int value) { wxNotebook_SetSelection(wxobj, value); }

		public void AdvanceSelection(bool forward)
		{
			wxNotebook_AdvanceSelection(wxobj, forward);
		}

		//---------------------------------------------------------------------

		public bool SetPageText(int page, string text)
		{
			return wxNotebook_SetPageText(wxobj, page, text);
		}

		public string GetPageText(int page)
		{
			return cast(string) new wxString(wxNotebook_GetPageText(wxobj, page), true);
		}

		//---------------------------------------------------------------------

		public void AssignImageList(ImageList imageList)
		{
			wxNotebook_AssignImageList(wxobj, wxObject.SafePtr(imageList));
		}

		//---------------------------------------------------------------------

		public int GetPageImage(int page)
		{
			return wxNotebook_GetPageImage(wxobj, page);
		}

		public bool SetPageImage(int page, int image)
		{
			return wxNotebook_SetPageImage(wxobj, page, image);
		}

		//---------------------------------------------------------------------

		public int RowCount() { return wxNotebook_GetRowCount(wxobj); }

		//---------------------------------------------------------------------

		public void PageSize(Size value) { wxNotebook_SetPageSize(wxobj, value); }

		public void Padding(Size value) { wxNotebook_SetPadding(wxobj, value); }

		public void TabSize(Size value) { wxNotebook_SetTabSize(wxobj, value); }

		//---------------------------------------------------------------------

		public bool DeletePage(int page)
		{
			return wxNotebook_DeletePage(wxobj, page);
		}

		public bool RemovePage(int page)
		{
			return wxNotebook_RemovePage(wxobj, page);
		}

		public bool DeleteAllPages()
		{
			return wxNotebook_DeleteAllPages(wxobj);
		}

		//---------------------------------------------------------------------

		// TODO: Switch window with NotebookPage
		public bool InsertPage(int page, Window window, string text,
							   bool select, int image)
		{
			return wxNotebook_InsertPage(wxobj, page,
										 wxObject.SafePtr(window), text, select,
										 image);
		}

		//---------------------------------------------------------------------

		public void PageChange_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED, ID, value, this); }
		public void PageChange_Remove(EventListener value) { RemoveHandler(value, this); }

		public void PageChanging_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGING, ID, value, this); }
		public void PageChanging_Remove(EventListener value) { RemoveHandler(value, this); }
	}
