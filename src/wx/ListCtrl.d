//-----------------------------------------------------------------------------
// wxD - ListCtrl.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - ListCtrl.cs
//
/// The wxListCtrl wrapper class
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 by Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: ListCtrl.d,v 1.13 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.ListCtrl;
public import wx.common;
public import wx.Control;
public import wx.ClientData;
public import wx.ImageList;

		//! \cond EXTERN
		static extern (C) IntPtr wxListItem_ctor();
		static extern (C) void   wxListItem_Clear(IntPtr self);
		static extern (C) void   wxListItem_ClearAttributes(IntPtr self);
		static extern (C) int    wxListItem_GetAlign(IntPtr self);
		static extern (C) IntPtr wxListItem_GetBackgroundColour(IntPtr self);
		static extern (C) int    wxListItem_GetColumn(IntPtr self);
		static extern (C) IntPtr wxListItem_GetData(IntPtr self);
		static extern (C) IntPtr wxListItem_GetFont(IntPtr self);
		static extern (C) int    wxListItem_GetId(IntPtr self);
		static extern (C) int    wxListItem_GetImage(IntPtr self);
		static extern (C) int    wxListItem_GetMask(IntPtr self);
		static extern (C) int    wxListItem_GetState(IntPtr self);
		static extern (C) IntPtr wxListItem_GetText(IntPtr self);
		static extern (C) IntPtr wxListItem_GetTextColour(IntPtr self);
		static extern (C) int    wxListItem_GetWidth(IntPtr self);
		static extern (C) void   wxListItem_SetAlign(IntPtr self, int alignment);
		static extern (C) void   wxListItem_SetBackgroundColour(IntPtr self, IntPtr col);
		static extern (C) void   wxListItem_SetColumn(IntPtr self, int col);
		static extern (C) void   wxListItem_SetData(IntPtr self, IntPtr data);
		static extern (C) void   wxListItem_SetFont(IntPtr self, IntPtr font);
		static extern (C) void   wxListItem_SetId(IntPtr self, int id);
		static extern (C) void   wxListItem_SetImage(IntPtr self, int image);
		static extern (C) void   wxListItem_SetMask(IntPtr self, int mask);
		static extern (C) void   wxListItem_SetState(IntPtr self, int state);
		static extern (C) void   wxListItem_SetStateMask(IntPtr self, int stateMask);
		static extern (C) void   wxListItem_SetText(IntPtr self, string text);
		static extern (C) void   wxListItem_SetTextColour(IntPtr self, IntPtr col);
		static extern (C) void   wxListItem_SetWidth(IntPtr self, int width);
		
		static extern (C) IntPtr wxListItem_GetAttributes(IntPtr self);
		static extern (C) bool   wxListItem_HasAttributes(IntPtr self);
		//! \endcond

	alias ListItem wxListItem;
	public class ListItem : wxObject
	{
		//---------------------------------------------------------------------

		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this() 
			{ super(wxListItem_ctor()); }

		public static wxObject New(IntPtr ptr) { return new ListItem(ptr); }

		//---------------------------------------------------------------------
        
		public void Clear()
		{
			wxListItem_Clear(wxobj);
		}
		
		//---------------------------------------------------------------------
        
		public void ClearAttributes()
		{
			wxListItem_ClearAttributes(wxobj);
		}

		//---------------------------------------------------------------------

		public int Align() { return wxListItem_GetAlign(wxobj); }
		public void Align(int value) { wxListItem_SetAlign(wxobj, value); }
        
		//---------------------------------------------------------------------
        
		public Colour BackgroundColour() { return new Colour(wxListItem_GetBackgroundColour(wxobj), true); }
		public void BackgroundColour(Colour value) {  wxListItem_SetBackgroundColour(wxobj, wxObject.SafePtr(value)); } 

		//---------------------------------------------------------------------
        
		public int Column() { return wxListItem_GetColumn(wxobj); }
		public void Column(int value) { wxListItem_SetColumn(wxobj, value); }

		//---------------------------------------------------------------------
        
		public ClientData Data() { return cast(ClientData)FindObject(wxListItem_GetData(wxobj)); }
		public void Data(ClientData value) { wxListItem_SetData(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------
        
		public Font font() { return new Font(wxListItem_GetFont(wxobj)); }
		public void font(Font value) { wxListItem_SetFont(wxobj, wxObject.SafePtr(value)); }

		//---------------------------------------------------------------------
        
		public int Id() { return wxListItem_GetId(wxobj); }
		public void Id(int value) { wxListItem_SetId(wxobj, value); }

		//---------------------------------------------------------------------
        
		public int Image() { return wxListItem_GetImage(wxobj); }
		public void Image(int value) { wxListItem_SetImage(wxobj, value); }

		//---------------------------------------------------------------------
        
		public int Mask() { return wxListItem_GetMask(wxobj); }
		public void Mask(int value) { wxListItem_SetMask(wxobj, value); }

		//---------------------------------------------------------------------
        
		public int State() { return wxListItem_GetState(wxobj); }
		public void State(int value) { wxListItem_SetState(wxobj, value); }

		public void StateMask(int value) { wxListItem_SetStateMask(wxobj, value); }

		//---------------------------------------------------------------------
        
		public string Text() { return cast(string) new wxString(wxListItem_GetText(wxobj), true); }
		public void Text(string value) { wxListItem_SetText(wxobj, value); }

		//---------------------------------------------------------------------
        
		public Colour TextColour() { return new Colour(wxListItem_GetTextColour(wxobj), true); }
		public void TextColour(Colour value) { wxListItem_SetTextColour(wxobj, wxObject.SafePtr(value)); } 

		//---------------------------------------------------------------------
        
		public int Width() { return wxListItem_GetWidth(wxobj); }
		public void Width(int value) { wxListItem_SetWidth(wxobj, value); }
		
		//---------------------------------------------------------------------
		
		public ListItemAttr Attributes() { return cast(ListItemAttr)FindObject(wxListItem_GetAttributes(wxobj), &ListItemAttr.New); }
		
		//---------------------------------------------------------------------
		
		public bool HasAttributes()
		{
			return wxListItem_HasAttributes(wxobj);
		}
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxListItemAttr_ctor();
		static extern (C) IntPtr wxListItemAttr_ctor2(IntPtr colText, IntPtr colBack, IntPtr font);
		static extern (C) void   wxListItemAttr_dtor(IntPtr self);
		static extern (C) void   wxListItemAttr_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) void   wxListItemAttr_SetTextColour(IntPtr self, IntPtr colText);
		static extern (C) void   wxListItemAttr_SetBackgroundColour(IntPtr self, IntPtr colBack);
		static extern (C) void   wxListItemAttr_SetFont(IntPtr self, IntPtr font);
		static extern (C) bool   wxListItemAttr_HasTextColour(IntPtr self);
		static extern (C) bool   wxListItemAttr_HasBackgroundColour(IntPtr self);
		static extern (C) bool   wxListItemAttr_HasFont(IntPtr self);
		static extern (C) IntPtr wxListItemAttr_GetTextColour(IntPtr self);
		static extern (C) IntPtr wxListItemAttr_GetBackgroundColour(IntPtr self);
		static extern (C) IntPtr wxListItemAttr_GetFont(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias ListItemAttr wxListItemAttr;
	public class ListItemAttr : wxObject
	{
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
			
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}

		public this()
		{
			this(wxListItemAttr_ctor(), true);
			wxListItemAttr_RegisterDisposable(wxobj, &VirtualDispose);
		}
		
		public this(Colour colText, Colour colBack, Font font)
		{
			this(wxListItemAttr_ctor2(wxObject.SafePtr(colText), wxObject.SafePtr(colBack), wxObject.SafePtr(font)), true);
			wxListItemAttr_RegisterDisposable(wxobj, &VirtualDispose);
		}
		
		public static wxObject New(IntPtr ptr) { return new ListItemAttr(ptr); }
		//---------------------------------------------------------------------
		
		private override void dtor() { wxListItemAttr_dtor(wxobj); }

		//---------------------------------------------------------------------
		
		public Colour TextColour() { return new Colour(wxListItemAttr_GetTextColour(wxobj), true); }
		public void TextColour(Colour value) { wxListItemAttr_SetTextColour(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------
		
		public Colour BackgroundColour() { return new Colour(wxListItemAttr_GetBackgroundColour(wxobj), true); }
		public void BackgroundColour(Colour value) { wxListItemAttr_SetBackgroundColour(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------
		
		public Font font() { return new Font(wxListItemAttr_GetFont(wxobj), true); }
		public void font(Font value) { wxListItemAttr_SetFont(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------
		
		public bool HasTextColour() { return wxListItemAttr_HasTextColour(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool HasBackgroundColour() { return wxListItemAttr_HasBackgroundColour(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool HasFont() { return wxListItemAttr_HasFont(wxobj); }
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		extern (C) {
		alias IntPtr function (ListCtrl, int) Virtual_OnGetItemAttr;
		alias int function (ListCtrl, int) Virtual_OnGetItemImage;
		alias int function (ListCtrl, int, int) Virtual_OnGetItemColumnImage;
		alias string function (ListCtrl, int, int) Virtual_OnGetItemText;

		alias int function(int item1, int item2, int sortData) wxListCtrlCompare;
		}
	
		static extern (C) IntPtr wxListCtrl_ctor();
		static extern (C) void   wxListCtrl_dtor(IntPtr self);
		static extern (C) void   wxListCtrl_RegisterVirtual(IntPtr self, ListCtrl obj, Virtual_OnGetItemAttr onGetItemAttr,
			Virtual_OnGetItemImage onGetItemImage,
			Virtual_OnGetItemColumnImage onGetItemColumnImage,
			Virtual_OnGetItemText onGetItemText);
		static extern (C) bool   wxListCtrl_Create(IntPtr self, IntPtr parent, int id, ref Point pos, ref Size size, uint style, IntPtr validator, string name);
		static extern (C) bool   wxListCtrl_GetColumn(IntPtr self, int col, ref IntPtr item);
		static extern (C) bool   wxListCtrl_SetColumn(IntPtr self, int col, IntPtr item);
		static extern (C) int    wxListCtrl_GetColumnWidth(IntPtr self, int col);
		static extern (C) bool   wxListCtrl_SetColumnWidth(IntPtr self, int col, int width);
		static extern (C) int    wxListCtrl_GetCountPerPage(IntPtr self);
		static extern (C) IntPtr wxListCtrl_GetItem(IntPtr self, IntPtr info, ref bool retval);
		static extern (C) bool   wxListCtrl_SetItem(IntPtr self, IntPtr info);
		static extern (C) int    wxListCtrl_SetItem_By_Row_Col(IntPtr self, int index, int col, string label, int imageId);
		static extern (C) int    wxListCtrl_GetItemState(IntPtr self, int item, int stateMask);
		static extern (C) bool   wxListCtrl_SetItemState(IntPtr self, int item, int state, int stateMask);
		static extern (C) bool   wxListCtrl_SetItemImage(IntPtr self, int item, int image, int selImage);
		static extern (C) IntPtr wxListCtrl_GetItemText(IntPtr self, int item);
		static extern (C) void   wxListCtrl_SetItemText(IntPtr self, int item, string str);
		static extern (C) IntPtr wxListCtrl_GetItemData(IntPtr self, int item);
		static extern (C) bool   wxListCtrl_SetItemData(IntPtr self, int item, IntPtr data);
		static extern (C) bool   wxListCtrl_SetItemData2(IntPtr self, int item, int data);
		static extern (C) bool   wxListCtrl_GetItemRect(IntPtr self, int item, out Rectangle rect, int code);
		static extern (C) bool   wxListCtrl_GetItemPosition(IntPtr self, int item, out Point pos);
		static extern (C) bool   wxListCtrl_SetItemPosition(IntPtr self, int item, ref Point pos);
		static extern (C) int    wxListCtrl_GetItemCount(IntPtr self);
		static extern (C) int    wxListCtrl_GetColumnCount(IntPtr self);
		static extern (C) void   wxListCtrl_SetItemTextColour(IntPtr self, int item, IntPtr col);
		static extern (C) IntPtr wxListCtrl_GetItemTextColour(IntPtr self, int item);
		static extern (C) void   wxListCtrl_SetItemBackgroundColour(IntPtr self, int item, IntPtr col);
		static extern (C) IntPtr wxListCtrl_GetItemBackgroundColour(IntPtr self, int item);
		static extern (C) int    wxListCtrl_GetSelectedItemCount(IntPtr self);
		static extern (C) IntPtr wxListCtrl_GetTextColour(IntPtr self);
		static extern (C) void   wxListCtrl_SetTextColour(IntPtr self, IntPtr col);
		static extern (C) int    wxListCtrl_GetTopItem(IntPtr self);
		static extern (C) void   wxListCtrl_SetSingleStyle(IntPtr self, uint style, bool add);
		static extern (C) void   wxListCtrl_SetWindowStyleFlag(IntPtr self, uint style);
		static extern (C) int    wxListCtrl_GetNextItem(IntPtr self, int item, int geometry, int state);
		static extern (C) IntPtr wxListCtrl_GetImageList(IntPtr self, int which);
		static extern (C) void   wxListCtrl_SetImageList(IntPtr self, IntPtr imageList, int which);
		static extern (C) void   wxListCtrl_AssignImageList(IntPtr self, IntPtr imageList, int which);
		static extern (C) bool   wxListCtrl_Arrange(IntPtr self, int flag);
		static extern (C) void   wxListCtrl_ClearAll(IntPtr self);
		static extern (C) bool   wxListCtrl_DeleteItem(IntPtr self, int item);
		static extern (C) bool   wxListCtrl_DeleteAllItems(IntPtr self);
		static extern (C) bool   wxListCtrl_DeleteAllColumns(IntPtr self);
		static extern (C) bool   wxListCtrl_DeleteColumn(IntPtr self, int col);
		static extern (C) void   wxListCtrl_SetItemCount(IntPtr self, int count);
		static extern (C) void   wxListCtrl_EditLabel(IntPtr self, int item);
		static extern (C) bool   wxListCtrl_EnsureVisible(IntPtr self, int item);
		static extern (C) int    wxListCtrl_FindItem(IntPtr self, int start, string str, bool partial);
		static extern (C) int    wxListCtrl_FindItemData(IntPtr self, int start, IntPtr data);
		static extern (C) int    wxListCtrl_FindItemPoint(IntPtr self, int start, ref Point pt, int direction);
		static extern (C) int    wxListCtrl_HitTest(IntPtr self, ref Point point, int flags);
		static extern (C) int    wxListCtrl_InsertItem(IntPtr self, IntPtr info);
		static extern (C) int    wxListCtrl_InsertTextItem(IntPtr self, int index, string label);
		static extern (C) int    wxListCtrl_InsertImageItem(IntPtr self, int index, int imageIndex);
		static extern (C) int    wxListCtrl_InsertTextImageItem(IntPtr self, int index, string label, int imageIndex);
		static extern (C) int    wxListCtrl_InsertColumn(IntPtr self, int col, IntPtr info);
		static extern (C) int    wxListCtrl_InsertTextColumn(IntPtr self, int col, string heading, int format, int width);
		static extern (C) bool   wxListCtrl_ScrollList(IntPtr self, int dx, int dy);
		static extern (C) bool   wxListCtrl_SortItems(IntPtr self, wxListCtrlCompare fn, int data);
		
		static extern (C) void   wxListCtrl_GetViewRect(IntPtr self, ref Rectangle rect);
		
		static extern (C) void   wxListCtrl_RefreshItem(IntPtr self, int item);
		static extern (C) void   wxListCtrl_RefreshItems(IntPtr self, int itemFrom, int itemTo);
		//! \endcond
	
	alias ListCtrl wxListCtrl;
	public class ListCtrl : Control
	{
		public const int wxLC_VRULES           = 0x0001;
		public const int wxLC_HRULES           = 0x0002;
	
		public const int wxLC_ICON             = 0x0004;
		public const int wxLC_SMALL_ICON       = 0x0008;
		public const int wxLC_LIST             = 0x0010;
		public const int wxLC_REPORT           = 0x0020;
	
		public const int wxLC_ALIGN_TOP        = 0x0040;
		public const int wxLC_ALIGN_LEFT       = 0x0080;
		public const int wxLC_AUTO_ARRANGE     = 0x0100;
		public const int wxLC_VIRTUAL          = 0x0200;
		public const int wxLC_EDIT_LABELS      = 0x0400;
		public const int wxLC_NO_HEADER        = 0x0800;
		public const int wxLC_NO_SORT_HEADER   = 0x1000;
		public const int wxLC_SINGLE_SEL       = 0x2000;
		public const int wxLC_SORT_ASCENDING   = 0x4000;
		public const int wxLC_SORT_DESCENDING  = 0x8000;
	
		public const int wxLC_MASK_TYPE        = (wxLC_ICON | wxLC_SMALL_ICON | wxLC_LIST | wxLC_REPORT);
		public const int wxLC_MASK_ALIGN       = (wxLC_ALIGN_TOP | wxLC_ALIGN_LEFT);
		public const int wxLC_MASK_SORT        = (wxLC_SORT_ASCENDING | wxLC_SORT_DESCENDING);
	
		public const int wxLIST_FORMAT_LEFT     = 0;
		public const int wxLIST_FORMAT_RIGHT    = 1;
		public const int wxLIST_FORMAT_CENTRE   = 2;
		public const int wxLIST_FORMAT_CENTER   = wxLIST_FORMAT_CENTRE;
	
		public const int wxLIST_MASK_STATE         = 0x0001;
		public const int wxLIST_MASK_TEXT          = 0x0002;
		public const int wxLIST_MASK_IMAGE         = 0x0004;
		public const int wxLIST_MASK_DATA          = 0x0008;
		public const int wxLIST_SET_ITEM           = 0x0010;
		public const int wxLIST_MASK_WIDTH         = 0x0020;
		public const int wxLIST_MASK_FORMAT        = 0x0040;
	
		public const int wxLIST_NEXT_ABOVE     = 1;
		public const int wxLIST_NEXT_ALL       = 2;
		public const int wxLIST_NEXT_BELOW     = 3;
		public const int wxLIST_NEXT_LEFT      = 4;
		public const int wxLIST_NEXT_RIGHT     = 5;
	
		public const int wxLIST_STATE_DONTCARE     = 0x0000;
		public const int wxLIST_STATE_DROPHILITED  = 0x0001;
		public const int wxLIST_STATE_FOCUSED      = 0x0002;
		public const int wxLIST_STATE_SELECTED     = 0x0004;
		public const int wxLIST_STATE_CUT          = 0x0008;
	
		public const int wxLIST_HITTEST_ABOVE          = 0x0001;
		public const int wxLIST_HITTEST_BELOW          = 0x0002;
		public const int wxLIST_HITTEST_NOWHERE        = 0x0004;
		public const int wxLIST_HITTEST_ONITEMICON     = 0x0020;
		public const int wxLIST_HITTEST_ONITEMLABEL    = 0x0080;
		public const int wxLIST_HITTEST_ONITEMRIGHT    = 0x0100;
		public const int wxLIST_HITTEST_ONITEMSTATEICON= 0x0200;
		public const int wxLIST_HITTEST_TOLEFT         = 0x0400;
		public const int wxLIST_HITTEST_TORIGHT        = 0x0800;
	
		public const int wxLIST_AUTOSIZE			= -1;
		public const int wxLIST_AUTOSIZE_USEHEADER	= -2;
		
		//---------------------------------------------------------------------
	
		//---------------------------------------------------------------------
        
		public this(IntPtr wxobj)
			{ super(wxobj); }

		public this()
			{ super(wxListCtrl_ctor()); }

		public this(Window parent, int id /*= wxID_ANY*/, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = wxLC_ICON, Validator validator = null, string name = "ListCtrl")
		{
			super(wxListCtrl_ctor());
			if (!Create(parent, id, pos, size, style, validator, name))
			{
				throw new InvalidOperationException("Failed to create ListCtrl");
			}
			
			wxListCtrl_RegisterVirtual(wxobj, this, &staticOnGetItemAttr, 
				&staticOnGetItemImage, &staticOnGetItemColumnImage, 
				&staticOnGetItemText);
		}
	
		public static wxObject New(IntPtr ptr) { return new ListCtrl(ptr); }
		//---------------------------------------------------------------------
		// ctors with self created id
	
		public this(Window parent, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = wxLC_ICON, Validator validator = null, string name = "ListCtrl")
			{ this(parent, Window.UniqueID, pos, size, style, validator, name);}
	
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, Point pos, Size size, int style, Validator validator, string name)
		{
			return wxListCtrl_Create(wxobj, wxObject.SafePtr(parent), id, pos, size, cast(uint)style, wxObject.SafePtr(validator), name);
		}
		
		//---------------------------------------------------------------------
		
		static extern(C) private IntPtr staticOnGetItemAttr(ListCtrl obj, int item)
		{
			return wxObject.SafePtr(obj.OnGetItemAttr(item));
		}
		protected /+virtual+/ wxListItemAttr OnGetItemAttr(int item)
		{
			return null;
		}
		
		//---------------------------------------------------------------------
		
		static extern(C) private int staticOnGetItemImage(ListCtrl obj, int item)
		{
			return obj.OnGetItemImage(item);
		}
		protected /+virtual+/ int OnGetItemImage(int item)
		{
			return -1;
		}
		
		//---------------------------------------------------------------------
		
		static extern(C) private int staticOnGetItemColumnImage(ListCtrl obj, int item, int column)
		{
			return obj.OnGetItemColumnImage(item, column);
		}
		protected /+virtual+/ int OnGetItemColumnImage(int item, int column)
		{
			return -1;
		}
		
		//---------------------------------------------------------------------
		
		static extern(C) private string staticOnGetItemText(ListCtrl obj, int item, int column)
		{
			return obj.OnGetItemText(item, column);
		}
		protected /+virtual+/ string OnGetItemText(int item, int column)
		{
			assert(0, "Generic OnGetItemText not supposed to be called");
		}
		
		//---------------------------------------------------------------------
		
		public bool GetColumn(int col, out ListItem item)
		{
			item = new ListItem();
			return wxListCtrl_GetColumn(wxobj, col, item.wxobj);
		}
		
		//---------------------------------------------------------------------

		public bool SetColumn(int col, ListItem item)
		{
			return wxListCtrl_SetColumn(wxobj, col, wxObject.SafePtr(item));
		}

		//---------------------------------------------------------------------

		public int GetColumnWidth(int col)
		{
			return wxListCtrl_GetColumnWidth(wxobj, col);
		}
		
		//---------------------------------------------------------------------

		public bool SetColumnWidth(int col, int width)
		{
			return wxListCtrl_SetColumnWidth(wxobj, col, width);
		}

		//---------------------------------------------------------------------

		public int CountPerPage() { return wxListCtrl_GetCountPerPage(wxobj); }

		//---------------------------------------------------------------------

		public bool GetItem(ref ListItem info)
		{
			bool retval = false;
			info  = cast(ListItem)FindObject(wxListCtrl_GetItem(wxobj, wxObject.SafePtr(info), retval), &ListItem.New);
			return retval;
		}
		
		//---------------------------------------------------------------------

		public bool SetItem(ListItem info)
		{
			return wxListCtrl_SetItem(wxobj, wxObject.SafePtr(info));
		}

		public int SetItem(int index, int col, string label)
		{
			return SetItem(index, col, label, -1);
		}

		public int SetItem(int index, int col, string label, int imageId)
		{
			return wxListCtrl_SetItem_By_Row_Col(wxobj, index, col, label, imageId);
		}


		//---------------------------------------------------------------------

		public void SetItemText(int index, string label)
		{
			wxListCtrl_SetItemText(wxobj, index, label);
		}
		
		//---------------------------------------------------------------------

		public string GetItemText(int item)
		{
			return cast(string) new wxString(wxListCtrl_GetItemText(wxobj, item), true);
		}

		//---------------------------------------------------------------------

		public int GetItemState(int item, int stateMask)
		{
			return wxListCtrl_GetItemState(wxobj, item , stateMask);
		}

		public bool SetItemState(int item, int state, int stateMask)
		{
			return wxListCtrl_SetItemState(wxobj, item, state, stateMask);
		}

		//---------------------------------------------------------------------

		public bool SetItemImage(int item, int image, int selImage)
		{
			return wxListCtrl_SetItemImage(wxobj, item, image, selImage);
		}

		//---------------------------------------------------------------------

		public ClientData GetItemData(int item)
		{
			return cast(ClientData)FindObject(wxListCtrl_GetItemData(wxobj, item));
		}
		
		//---------------------------------------------------------------------

		public bool SetItemData(int item, ClientData data)
		{
			return wxListCtrl_SetItemData(wxobj, item, wxObject.SafePtr(data));
		}
		
		//---------------------------------------------------------------------

		public bool SetItemData(int item, int data)
		{
			return wxListCtrl_SetItemData2(wxobj, item, data);
		}

		//---------------------------------------------------------------------

		public bool GetItemRect(int item, out Rectangle rect, int code)
		{
			return wxListCtrl_GetItemRect(wxobj, item, rect, code);
		}

		//---------------------------------------------------------------------

		public bool GetItemPosition(int item, out Point pos)
		{
			return wxListCtrl_GetItemPosition(wxobj, item, pos);
		}
		
		//---------------------------------------------------------------------

		public bool SetItemPosition(int item, Point pos)
		{
			return wxListCtrl_SetItemPosition(wxobj, item, pos);
		}

		//---------------------------------------------------------------------

		public int ItemCount() { return wxListCtrl_GetItemCount(wxobj); }
		public void ItemCount(int value) { wxListCtrl_SetItemCount(wxobj, value); }
		
		//---------------------------------------------------------------------

		public int ColumnCount() { return wxListCtrl_GetColumnCount(wxobj); }
		
		//---------------------------------------------------------------------

		public void SetItemTextColour(int item, Colour col)
		{
			wxListCtrl_SetItemTextColour(wxobj, item, wxObject.SafePtr(col));
		}
		
		//---------------------------------------------------------------------

		public Colour GetItemTextColour(int item)
		{
			return new Colour(wxListCtrl_GetItemTextColour(wxobj, item), true);
		}

		//---------------------------------------------------------------------

		public void SetItemBackgroundColour(int item, Colour col)
		{
			wxListCtrl_SetItemBackgroundColour(wxobj, item, wxObject.SafePtr(col));
		}
		
		//---------------------------------------------------------------------

		public Colour GetItemBackgroundColour(int item)
		{
			return new Colour(wxListCtrl_GetItemBackgroundColour(wxobj, item), true);
		}

		//---------------------------------------------------------------------

		public int SelectedItemCount() { return wxListCtrl_GetSelectedItemCount(wxobj); }

		//---------------------------------------------------------------------

		public Colour TextColour() { return new Colour(wxListCtrl_GetTextColour(wxobj), true); }
		public void TextColour(Colour value) { wxListCtrl_SetTextColour(wxobj, wxObject.SafePtr(value)); }

		//---------------------------------------------------------------------

		public int TopItem() { return wxListCtrl_GetTopItem(wxobj); }

		//---------------------------------------------------------------------

		public void SetSingleStyle(int style, bool add)
		{
			wxListCtrl_SetSingleStyle(wxobj, cast(uint)style, add);
		}
		
		//---------------------------------------------------------------------

		public void WindowStyleFlag(int value) { wxListCtrl_SetWindowStyleFlag(wxobj, cast(uint)value); }

		//---------------------------------------------------------------------

		public int GetNextItem(int item, int geometry, int state)
		{
			return wxListCtrl_GetNextItem(wxobj, item, geometry, state);
		}

		//---------------------------------------------------------------------

		public ImageList GetImageList(int which)
		{
			return cast(ImageList)FindObject(wxListCtrl_GetImageList(wxobj, which), &ImageList.New);
		}
		
		//---------------------------------------------------------------------

		public void SetImageList(ImageList imageList, int which)
		{
			wxListCtrl_SetImageList(wxobj, wxObject.SafePtr(imageList), which);
		}
		
		//---------------------------------------------------------------------

		public void AssignImageList(ImageList imageList, int which)
		{
			wxListCtrl_AssignImageList(wxobj, wxObject.SafePtr(imageList), which);
		}

		//---------------------------------------------------------------------

		public bool Arrange(int flag)
		{
			return wxListCtrl_Arrange(wxobj, flag);
		}

		//---------------------------------------------------------------------

		public void ClearAll()
		{
			wxListCtrl_ClearAll(wxobj);
		}
		
		//---------------------------------------------------------------------

		public bool DeleteItem(int item)
		{
			return wxListCtrl_DeleteItem(wxobj, item);
		}
		
		//---------------------------------------------------------------------

		public bool DeleteAllItems()
		{
			return wxListCtrl_DeleteAllItems(wxobj);
		}
		
		//---------------------------------------------------------------------

		public bool DeleteAllColumns()
		{
			return wxListCtrl_DeleteAllColumns(wxobj);
		}
		
		//---------------------------------------------------------------------

		public bool DeleteColumn(int col)
		{
			return wxListCtrl_DeleteColumn(wxobj, col);
		}

		//---------------------------------------------------------------------

		public void EditLabel(int item)
		{
			wxListCtrl_EditLabel(wxobj, item);
		}

		//---------------------------------------------------------------------

		public bool EnsureVisible(int item)
		{
			return wxListCtrl_EnsureVisible(wxobj, item);
		}

		//---------------------------------------------------------------------

		public int FindItem(int start, string str, bool partial)
		{
			return wxListCtrl_FindItem(wxobj, start, str, partial);
		}

		// TODO: Verify data
		public int FindItem(int start, ClientData data)
		{
			return wxListCtrl_FindItemData(wxobj, start, wxObject.SafePtr(data));
		}

		public int FindItem(int start, Point pt, int direction)
		{
			return wxListCtrl_FindItemPoint(wxobj, start, pt, direction);
		}

		//---------------------------------------------------------------------

		public int HitTest(Point point, int flags)
		{
			return wxListCtrl_HitTest(wxobj, point, flags);
		}

		//---------------------------------------------------------------------

		public int InsertItem(ListItem info)
		{
			return wxListCtrl_InsertItem(wxobj, wxObject.SafePtr(info));
		}

		public int InsertItem(int index, string label)
		{
			return wxListCtrl_InsertTextItem(wxobj, index, label);
		}

		public int InsertItem(int index, int imageIndex)
		{
			return wxListCtrl_InsertImageItem(wxobj, index, imageIndex);
		}

		public int InsertItem(int index, string label, int imageIndex)
		{
			return wxListCtrl_InsertTextImageItem(wxobj, index, label, imageIndex);
		}

		//---------------------------------------------------------------------
        
		public int InsertColumn(int col, ListItem info)
		{
			return wxListCtrl_InsertColumn(wxobj, col, wxObject.SafePtr(info));
		}

		public int InsertColumn(int col, string heading)
		{ 
			return InsertColumn(col, heading, wxLIST_FORMAT_LEFT, -1); 
		}
			
		public int InsertColumn(int col, string heading, int format, int width)
		{
			return wxListCtrl_InsertTextColumn(wxobj, col, heading, format, width);
		}

		//---------------------------------------------------------------------

		public bool ScrollList(int dx, int dy)
		{
			return wxListCtrl_ScrollList(wxobj, dx, dy);
		}
		
		//---------------------------------------------------------------------
		
		public Rectangle ViewRect() {
				Rectangle rect;
				wxListCtrl_GetViewRect(wxobj, rect);
				return rect;
			}
		
		//---------------------------------------------------------------------
		
		public void RefreshItem(int item)
		{
			wxListCtrl_RefreshItem(wxobj, item);
		}
		
		//---------------------------------------------------------------------
		
		public void RefreshItems(int itemFrom, int itemTo)
		{
			wxListCtrl_RefreshItems(wxobj, itemFrom, itemTo);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool SortItems(wxListCtrlCompare fn, int data)
		{
			bool retval = wxListCtrl_SortItems(wxobj, fn, data);
			
			fn = null;
			
			return retval;
		}
		
		//-----------------------------------------------------------------------------

		public void BeginDrag_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_BEGIN_DRAG, ID, value, this); }
		public void BeginDrag_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void BeginRightDrag_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_BEGIN_RDRAG, ID, value, this); }
		public void BeginRightDrag_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void BeginLabelEdit_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_BEGIN_LABEL_EDIT, ID, value, this); }
		public void BeginLabelEdit_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void EndLabelEdit_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_END_LABEL_EDIT, ID, value, this); }
		public void EndLabelEdit_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void ItemDelete_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_DELETE_ITEM, ID, value, this); }
		public void ItemDelete_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void ItemDeleteAll_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_DELETE_ALL_ITEMS, ID, value, this); }
		public void ItemDeleteAll_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------
		
		public void GetInfo_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_GET_INFO, ID, value, this); }
		public void GetInfo_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------
		
		public void SetInfo_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_SET_INFO, ID, value, this); }
		public void SetInfo_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void ItemSelect_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_ITEM_SELECTED, ID, value, this); }
		public void ItemSelect_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void ItemDeselect_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_ITEM_DESELECTED, ID, value, this); }
		public void ItemDeselect_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void ItemActivate_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_ITEM_ACTIVATED, ID, value, this); }
		public void ItemActivate_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void ItemFocus_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_ITEM_FOCUSED, ID, value, this); }
		public void ItemFocus_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void ItemMiddleClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_ITEM_MIDDLE_CLICK, ID, value, this); }
		public void ItemMiddleClick_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void ItemRightClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_ITEM_RIGHT_CLICK, ID, value, this); }
		public void ItemRightClick_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public override void KeyDown_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_KEY_DOWN, ID, value, this); }
		public override void KeyDown_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void Insert_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_INSERT_ITEM, ID, value, this); }
		public void Insert_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void ColumnClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_COL_CLICK, ID, value, this); }
		public void ColumnClick_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void ColumnRightClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_COL_RIGHT_CLICK, ID, value, this); }
		public void ColumnRightClick_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void ColumnBeginDrag_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_COL_BEGIN_DRAG, ID, value, this); }
		public void ColumnBeginDrag_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void ColumnDragging_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_COL_DRAGGING, ID, value, this); }
		public void ColumnDragging_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void ColumnEndDrag_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_COL_END_DRAG, ID, value, this); }
		public void ColumnEndDrag_Remove(EventListener value) { RemoveHandler(value, this); }
		
		//-----------------------------------------------------------------------------

		public void CacheHint_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_LIST_CACHE_HINT, ID, value, this); }
		public void CacheHint_Remove(EventListener value) { RemoveHandler(value, this); }
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxListEvent_ctor(int commandType, int id);
		static extern (C) IntPtr wxListEvent_GetItem(IntPtr self);
		static extern (C) IntPtr wxListEvent_GetLabel(IntPtr self);
		static extern (C) int   wxListEvent_GetIndex(IntPtr self);
		static extern (C) int    wxListEvent_GetKeyCode(IntPtr self);
		static extern (C) int    wxListEvent_GetColumn(IntPtr self);
		static extern (C) void   wxListEvent_GetPoint(IntPtr self, ref Point pt);
		static extern (C) IntPtr wxListEvent_GetText(IntPtr self);
		static extern (C) int wxListEvent_GetImage(IntPtr self);
		static extern (C) int wxListEvent_GetData(IntPtr self);
		static extern (C) int wxListEvent_GetMask(IntPtr self);
		static extern (C) int wxListEvent_GetCacheFrom(IntPtr self);
		static extern (C) int wxListEvent_GetCacheTo(IntPtr self);
		static extern (C) bool wxListEvent_IsEditCancelled(IntPtr self);
		static extern (C) void wxListEvent_SetEditCanceled(IntPtr self, bool editCancelled);
		static extern (C) void wxListEvent_Veto(IntPtr self);
		static extern (C) void wxListEvent_Allow(IntPtr self);
		static extern (C) bool wxListEvent_IsAllowed(IntPtr self);			
		//! \endcond
		
		//---------------------------------------------------------------------
       
	alias ListEvent wxListEvent;
	public class ListEvent : Event 
	{
		public this(IntPtr wxobj)
			{ super(wxobj); }
			
		public this(int commandType, int id)
			{ super(wxListEvent_ctor(commandType, id)); }

		static Event New(IntPtr ptr) { return new ListEvent(ptr); }
		//-----------------------------------------------------------------------------

		public string Label() { return cast(string) new wxString(wxListEvent_GetLabel(wxobj), true); }

		//-----------------------------------------------------------------------------
       
		public int KeyCode() { return wxListEvent_GetKeyCode(wxobj); }
		
		//---------------------------------------------------------------------
	
		public int Index() { return wxListEvent_GetIndex(wxobj); }
		
		//---------------------------------------------------------------------
       
		public ListItem Item() { return new ListItem(wxListEvent_GetItem(wxobj)); }
		
		//---------------------------------------------------------------------
    
		public int Column() { return wxListEvent_GetColumn(wxobj); }
		
		//---------------------------------------------------------------------
    
		public Point point() { 
				Point pt;
				wxListEvent_GetPoint(wxobj, pt);
				return pt;
			}
		
		//---------------------------------------------------------------------
    
		public string Text() { return cast(string) new wxString(wxListEvent_GetText(wxobj), true); }
		
		//---------------------------------------------------------------------
	
		public int Image() { return wxListEvent_GetImage(wxobj); }
		
		//---------------------------------------------------------------------
	
		public int Data() { return wxListEvent_GetData(wxobj); }
		
		//---------------------------------------------------------------------
	
		public int Mask() { return wxListEvent_GetMask(wxobj); }
		
		//---------------------------------------------------------------------
	
		public int CacheFrom() { return wxListEvent_GetCacheFrom(wxobj); }
		
		//---------------------------------------------------------------------
	
		public int CacheTo() { return wxListEvent_GetCacheTo(wxobj); }
		
		//---------------------------------------------------------------------
	
		public bool EditCancelled() { return wxListEvent_IsEditCancelled(wxobj); }
		public void EditCancelled(bool value) { wxListEvent_SetEditCanceled(wxobj, value); }
		
		//-----------------------------------------------------------------------------		
		
		public void Veto()
		{
			wxListEvent_Veto(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public void Allow()
		{
			wxListEvent_Allow(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool Allowed() { return wxListEvent_IsAllowed(wxobj); }

		static this()
		{
			

			wxEVT_COMMAND_LIST_BEGIN_DRAG = wxEvent_EVT_COMMAND_LIST_BEGIN_DRAG();
			wxEVT_COMMAND_LIST_BEGIN_RDRAG = wxEvent_EVT_COMMAND_LIST_BEGIN_RDRAG();
			wxEVT_COMMAND_LIST_BEGIN_LABEL_EDIT = wxEvent_EVT_COMMAND_LIST_BEGIN_LABEL_EDIT();
			wxEVT_COMMAND_LIST_END_LABEL_EDIT = wxEvent_EVT_COMMAND_LIST_END_LABEL_EDIT();
			wxEVT_COMMAND_LIST_DELETE_ITEM = wxEvent_EVT_COMMAND_LIST_DELETE_ITEM();
			wxEVT_COMMAND_LIST_DELETE_ALL_ITEMS = wxEvent_EVT_COMMAND_LIST_DELETE_ALL_ITEMS();
			wxEVT_COMMAND_LIST_GET_INFO = wxEvent_EVT_COMMAND_LIST_GET_INFO();
			wxEVT_COMMAND_LIST_SET_INFO = wxEvent_EVT_COMMAND_LIST_SET_INFO();
			wxEVT_COMMAND_LIST_ITEM_SELECTED = wxEvent_EVT_COMMAND_LIST_ITEM_SELECTED();
			wxEVT_COMMAND_LIST_ITEM_DESELECTED = wxEvent_EVT_COMMAND_LIST_ITEM_DESELECTED();
			wxEVT_COMMAND_LIST_ITEM_ACTIVATED = wxEvent_EVT_COMMAND_LIST_ITEM_ACTIVATED();
			wxEVT_COMMAND_LIST_ITEM_FOCUSED = wxEvent_EVT_COMMAND_LIST_ITEM_FOCUSED();
			wxEVT_COMMAND_LIST_ITEM_MIDDLE_CLICK = wxEvent_EVT_COMMAND_LIST_ITEM_MIDDLE_CLICK();
			wxEVT_COMMAND_LIST_ITEM_RIGHT_CLICK = wxEvent_EVT_COMMAND_LIST_ITEM_RIGHT_CLICK();
			wxEVT_COMMAND_LIST_KEY_DOWN = wxEvent_EVT_COMMAND_LIST_KEY_DOWN();
			wxEVT_COMMAND_LIST_INSERT_ITEM = wxEvent_EVT_COMMAND_LIST_INSERT_ITEM();
			wxEVT_COMMAND_LIST_COL_CLICK = wxEvent_EVT_COMMAND_LIST_COL_CLICK();
			wxEVT_COMMAND_LIST_COL_RIGHT_CLICK = wxEvent_EVT_COMMAND_LIST_COL_RIGHT_CLICK();
			wxEVT_COMMAND_LIST_COL_BEGIN_DRAG = wxEvent_EVT_COMMAND_LIST_COL_BEGIN_DRAG();
			wxEVT_COMMAND_LIST_COL_DRAGGING = wxEvent_EVT_COMMAND_LIST_COL_DRAGGING();
			wxEVT_COMMAND_LIST_COL_END_DRAG = wxEvent_EVT_COMMAND_LIST_COL_END_DRAG();
			wxEVT_COMMAND_LIST_CACHE_HINT = wxEvent_EVT_COMMAND_LIST_CACHE_HINT();
		
			AddEventType(wxEVT_COMMAND_LIST_BEGIN_DRAG,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_BEGIN_RDRAG,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_BEGIN_LABEL_EDIT,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_END_LABEL_EDIT,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_DELETE_ITEM,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_DELETE_ALL_ITEMS,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_GET_INFO,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_SET_INFO,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_ITEM_SELECTED,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_ITEM_DESELECTED,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_ITEM_ACTIVATED,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_ITEM_FOCUSED,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_ITEM_MIDDLE_CLICK,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_ITEM_RIGHT_CLICK,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_KEY_DOWN,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_INSERT_ITEM,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_COL_CLICK,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_COL_RIGHT_CLICK,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_COL_BEGIN_DRAG,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_COL_DRAGGING,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_COL_END_DRAG,	&ListEvent.New);
			AddEventType(wxEVT_COMMAND_LIST_CACHE_HINT,	&ListEvent.New);
		}
	}

	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxListView_ctor();
		static extern (C) bool wxListView_Create(IntPtr self, IntPtr parent, int id, ref Point pos, ref Size size, uint style, IntPtr validator, string name);
		static extern (C) void   wxListView_RegisterVirtual(IntPtr self, ListCtrl obj, Virtual_OnGetItemAttr onGetItemAttr,
			Virtual_OnGetItemImage onGetItemImage,
			Virtual_OnGetItemColumnImage onGetItemColumnImage,
			Virtual_OnGetItemText onGetItemText);
		static extern (C) void wxListView_Select(IntPtr self, uint n, bool on);
		static extern (C) void wxListView_Focus(IntPtr self, uint index);
		static extern (C) uint wxListView_GetFocusedItem(IntPtr self);
		static extern (C) uint wxListView_GetNextSelected(IntPtr self, uint item);
		static extern (C) uint wxListView_GetFirstSelected(IntPtr self);
		static extern (C) bool wxListView_IsSelected(IntPtr self, uint index);
		static extern (C) void wxListView_SetColumnImage(IntPtr self, int col, int image);
		static extern (C) void wxListView_ClearColumnImage(IntPtr self, int col);
		//! \endcond

		//-----------------------------------------------------------------------------

	alias ListView wxListView;
	public class ListView : ListCtrl
	{
		public this(IntPtr wxobj)
			{ super(wxobj); }

		public this()
			{ super(wxListView_ctor()); }

		public this(Window parent)
			{ this(parent, Window.UniqueID, wxDefaultPosition, wxDefaultSize, wxLC_REPORT, null, null); }

		public this(Window parent, int id)
			{ this(parent, id, wxDefaultPosition, wxDefaultSize, wxLC_REPORT, null, null); }

		public this(Window parent, int id, Point pos)
			{ this(parent, id, pos, wxDefaultSize, wxLC_REPORT, null, null); }

		public this(Window parent, int id, Point pos, Size size)
			{ this(parent, id, pos, size, wxLC_REPORT, null, null); }

		public this(Window parent, int id, Point pos, Size size, int style)
			{ this(parent, id, pos, size, style, null, null); }

		public this(Window parent, int id, Point pos, Size size, int style, Validator validator)
			{ this(parent, id, pos, size, style, validator, null); }

		public this(Window parent, int id, Point pos, Size size, int style, Validator validator, string name)
		{
			super(wxListView_ctor());
			if (!Create(parent, id, pos, size, style, validator, name))
			{
				throw new InvalidOperationException("Failed to create ListView");
			}
			
			wxListView_RegisterVirtual(wxobj, this, &staticOnGetItemAttr, 
				&staticOnGetItemImage, &staticOnGetItemColumnImage, 
				&staticOnGetItemText);
		}
		
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, Point pos)
			{ this(parent, Window.UniqueID, pos, wxDefaultSize, wxLC_REPORT, null, null); }

		public this(Window parent, Point pos, Size size)
			{ this(parent, Window.UniqueID, pos, size, wxLC_REPORT, null, null); }

		public this(Window parent, Point pos, Size size, int style)
			{ this(parent, Window.UniqueID, pos, size, style, null, null); }

		public this(Window parent, Point pos, Size size, int style, Validator validator)
			{ this(parent, Window.UniqueID, pos, size, style, validator, null); }

		public this(Window parent, Point pos, Size size, int style, Validator validator, string name)
			{ this(parent, Window.UniqueID, pos, size, style, validator, name);}

		//-----------------------------------------------------------------------------

		public override bool Create(Window parent, int id, Point pos, Size size, int style, Validator validator, string name)
		{
			return wxListView_Create(wxobj, wxObject.SafePtr(parent), id, pos, size, cast(uint)style, wxObject.SafePtr(validator), name);
		}

		//-----------------------------------------------------------------------------

		public void Select(int n)
		{
			Select(n, true);
		}

		public void Select(int n, bool on)
		{
			wxListView_Select(wxobj, cast(uint)n, on);
		}

		//-----------------------------------------------------------------------------

		public void Focus(int index)
		{
			wxListView_Focus(wxobj, cast(uint)index);
		}

		//-----------------------------------------------------------------------------

		public int FocusedItem() { return cast(int)wxListView_GetFocusedItem(wxobj); }

		//-----------------------------------------------------------------------------

		public int GetNextSelected(int item)
		{
			return cast(int)wxListView_GetNextSelected(wxobj, cast(uint)item);
		}

		//-----------------------------------------------------------------------------

		public int FirstSelected() { return cast(int)wxListView_GetFirstSelected(wxobj); }

		//-----------------------------------------------------------------------------

		public bool IsSelected(int index)
		{
			return wxListView_IsSelected(wxobj, cast(uint)index);
		}

		//-----------------------------------------------------------------------------

		public void SetColumnImage(int col, int image)
		{
			wxListView_SetColumnImage(wxobj, col, image);
		}

		//-----------------------------------------------------------------------------

		public void ClearColumnImage(int col)
		{
			wxListView_ClearColumnImage(wxobj, col);
		}
	}
