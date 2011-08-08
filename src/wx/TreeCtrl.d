//-----------------------------------------------------------------------------
// wxD - TreeCtrl.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - TreeCtrl.cs
//
/// The wxTreeCtrl wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: TreeCtrl.d,v 1.14 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.TreeCtrl;
public import wx.common;
public import wx.Control;
public import wx.ClientData;
public import wx.ImageList;
public import wx.KeyEvent;

	public enum TreeItemIcon
	{
		wxTreeItemIcon_Normal,
		wxTreeItemIcon_Selected,
		wxTreeItemIcon_Expanded,
		wxTreeItemIcon_SelectedExpanded,
		wxTreeItemIcon_Max
	}
	
	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxTreeItemData_ctor();
		static extern (C) void   wxTreeItemData_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) void   wxTreeItemData_dtor(IntPtr self);
		static extern (C) IntPtr wxTreeItemData_GetId(IntPtr self);
		static extern (C) void   wxTreeItemData_SetId(IntPtr self, IntPtr param);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias TreeItemData wxTreeItemData;
	public class TreeItemData : ClientData
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
			this(wxTreeItemData_ctor(), true);
			wxTreeItemData_RegisterDisposable(wxobj, &VirtualDispose);
		}
		
		//---------------------------------------------------------------------
		override protected void dtor() { wxTreeItemData_dtor(wxobj); }
				
		//-----------------------------------------------------------------------------

		public TreeItemId Id() { return new TreeItemId(wxTreeItemData_GetId(wxobj), true); }
		public void Id(TreeItemId value) { wxTreeItemData_SetId(wxobj, wxObject.SafePtr(value)); }
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxTreeItemAttr_ctor();
		static extern (C) IntPtr wxTreeItemAttr_ctor2(IntPtr colText, IntPtr colBack, IntPtr font);
		static extern (C) void   wxTreeItemAttr_dtor(IntPtr self);
		static extern (C) void   wxTreeItemAttr_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) void   wxTreeItemAttr_SetTextColour(IntPtr self, IntPtr colText);
		static extern (C) void   wxTreeItemAttr_SetBackgroundColour(IntPtr self, IntPtr colBack);
		static extern (C) void   wxTreeItemAttr_SetFont(IntPtr self, IntPtr font);
		static extern (C) bool   wxTreeItemAttr_HasTextColour(IntPtr self);
		static extern (C) bool   wxTreeItemAttr_HasBackgroundColour(IntPtr self);
		static extern (C) bool   wxTreeItemAttr_HasFont(IntPtr self);
		static extern (C) IntPtr wxTreeItemAttr_GetTextColour(IntPtr self);
		static extern (C) IntPtr wxTreeItemAttr_GetBackgroundColour(IntPtr self);
		static extern (C) IntPtr wxTreeItemAttr_GetFont(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias TreeItemAttr wxTreeItemAttr;
	public class TreeItemAttr : wxObject
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
			this(wxTreeItemAttr_ctor(), true);
			wxTreeItemAttr_RegisterDisposable(wxobj, &VirtualDispose);
		}
		
		public this(Colour colText, Colour colBack, Font font)
		{
			this(wxTreeItemAttr_ctor2(wxObject.SafePtr(colText), wxObject.SafePtr(colBack), wxObject.SafePtr(font)), true);
			wxTreeItemAttr_RegisterDisposable(wxobj, &VirtualDispose);
		}
		
		//---------------------------------------------------------------------
				
		override protected void dtor() { wxTreeItemAttr_dtor(wxobj); }
		
		//---------------------------------------------------------------------
		
		public Colour TextColour() { return new Colour(wxTreeItemAttr_GetTextColour(wxobj), true); }
		public void TextColour(Colour value) { wxTreeItemAttr_SetTextColour(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------
		
		public Colour BackgroundColour() { return new Colour(wxTreeItemAttr_GetBackgroundColour(wxobj), true); }
		public void BackgroundColour(Colour value) { wxTreeItemAttr_SetBackgroundColour(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------
		
		public Font font() { return new Font(wxTreeItemAttr_GetFont(wxobj), true); }
		public void font(Font value) { wxTreeItemAttr_SetFont(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------
		
		public bool HasTextColour() { return wxTreeItemAttr_HasTextColour(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool HasBackgroundColour() { return wxTreeItemAttr_HasBackgroundColour(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool HasFont() { return wxTreeItemAttr_HasFont(wxobj); }
	}
	
	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxTreeItemId_ctor();
		static extern (C) IntPtr wxTreeItemId_ctor2(void* pItem);
		static extern (C) void   wxTreeItemId_dtor(IntPtr self);
		static extern (C) void   wxTreeItemId_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) bool   wxTreeItemId_Equal(IntPtr item1, IntPtr item2);
		static extern (C) bool   wxTreeItemId_IsOk(IntPtr self);
		//! \endcond
		
		//---------------------------------------------------------------------

	//[StructLayout(LayoutKind.Sequential)]
	alias TreeItemId wxTreeItemId;
	public class TreeItemId : wxObject
	{
		public this(IntPtr wxobj)
		{
			super(wxobj);
		}
			
		private this(IntPtr wxobj, bool memOwn)
		{
			super(wxobj);
			this.memOwn = memOwn;
			wxTreeItemId_RegisterDisposable(wxobj, &VirtualDispose);
		}

		public this()
		{
			this(wxTreeItemId_ctor(), true);
		}
		
		public this(/*ClientData*/void* pItem)
		{
			this(wxTreeItemId_ctor2(pItem), true);
		}
		
		//---------------------------------------------------------------------

		override protected void dtor() { wxTreeItemId_dtor(wxobj); }
		
		//---------------------------------------------------------------------
		
		//-----------------------------------------------------------------------------

		/*private IntPtr id;

		public this(IntPtr id)
		{ this.id = id; }*/

		//-----------------------------------------------------------------------------

version (D_Version2) // changed in DMD 2.016
{
		public override bool opEquals(Object o)
		{
			if (o is null) return false;
			TreeItemId id = cast(TreeItemId)o;
			if (id is null) return false;
			if (id is this || wxobj == id.wxobj) return true;
			return wxTreeItemId_Equal(wxobj, id.wxobj);
		}
}
else // D_Version1
{
		public override int opEquals(Object o)
		{
			if (o is null) return false;
			TreeItemId id = cast(TreeItemId)o;
			if (id is null) return false;
			if (id is this || wxobj == id.wxobj) return true;
			return wxTreeItemId_Equal(wxobj, id.wxobj);
		}
}
		
		//-----------------------------------------------------------------------------

		public override hash_t toHash()
		{
			return cast(hash_t)wxobj;
		}
		
		//-----------------------------------------------------------------------------

		/*public bool IsValid
		{
			get { return id != IntPtr.init; }
		}*/
		
		//-----------------------------------------------------------------------------
		
		public bool IsOk()
		{
			return wxTreeItemId_IsOk(wxobj);
		}
	}
	
	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		extern (C) {
		alias int function(TreeCtrl obj, IntPtr item1, IntPtr item2) Virtual_OnCompareItems;
		}
		
		static extern (C) uint   wxTreeCtrl_GetDefaultStyle();
		static extern (C) IntPtr wxTreeCtrl_ctor();
		static extern (C) void   wxTreeCtrl_RegisterVirtual(IntPtr self,TreeCtrl obj, Virtual_OnCompareItems onCompareItems);
		static extern (C) int    wxTreeCtrl_OnCompareItems(IntPtr self, IntPtr item1, IntPtr item2);
		static extern (C) IntPtr wxTreeCtrl_AddRoot(IntPtr self, string text, int image, int selImage, IntPtr data);
		static extern (C) IntPtr wxTreeCtrl_AppendItem(IntPtr self, IntPtr parent, string text, int image, int selImage, IntPtr data);
		static extern (C) void   wxTreeCtrl_AssignImageList(IntPtr self, IntPtr imageList);
		static extern (C) void   wxTreeCtrl_AssignStateImageList(IntPtr self, IntPtr imageList);
		//static extern (C) void   wxTreeCtrl_AssignButtonsImageList(IntPtr self, IntPtr imageList);
		static extern (C) bool   wxTreeCtrl_Create(IntPtr self, IntPtr parent, int id, ref Point pos, ref Size size, uint style, IntPtr val, string name);
		static extern (C) IntPtr wxTreeCtrl_GetImageList(IntPtr self);
		static extern (C) IntPtr wxTreeCtrl_GetStateImageList(IntPtr self);
		//static extern (C) IntPtr wxTreeCtrl_GetButtonsImageList(IntPtr self);
		static extern (C) void   wxTreeCtrl_SetImageList(IntPtr self, IntPtr imageList);
		static extern (C) void   wxTreeCtrl_SetStateImageList(IntPtr self, IntPtr imageList);
		//static extern (C) void   wxTreeCtrl_SetButtonsImageList(IntPtr self, IntPtr imageList);
		static extern (C) void   wxTreeCtrl_SetItemImage(IntPtr self, IntPtr item, int image, TreeItemIcon which);
		static extern (C) int    wxTreeCtrl_GetItemImage(IntPtr self, IntPtr item, TreeItemIcon which);

		static extern (C) void   wxTreeCtrl_DeleteAllItems(IntPtr self);
		static extern (C) void   wxTreeCtrl_Delete(IntPtr self, IntPtr item);
		static extern (C) void   wxTreeCtrl_DeleteChildren(IntPtr self, IntPtr item);

		static extern (C) void   wxTreeCtrl_Unselect(IntPtr self);
		static extern (C) void   wxTreeCtrl_UnselectAll(IntPtr self);

		static extern (C) bool   wxTreeCtrl_IsSelected(IntPtr self, IntPtr item);
		static extern (C) IntPtr wxTreeCtrl_GetSelection(IntPtr self);
		static extern (C) void   wxTreeCtrl_SelectItem(IntPtr self, IntPtr item);

		static extern (C) IntPtr wxTreeCtrl_GetItemText(IntPtr self, IntPtr item);
		static extern (C) void   wxTreeCtrl_SetItemText(IntPtr self, IntPtr item, string text);

		static extern (C) IntPtr wxTreeCtrl_HitTest(IntPtr self, ref Point pt, ref int flags);

		static extern (C) void   wxTreeCtrl_SetItemData(IntPtr self, IntPtr item, IntPtr data);
		static extern (C) IntPtr wxTreeCtrl_GetItemData(IntPtr self, IntPtr item);

		static extern (C) IntPtr wxTreeCtrl_GetRootItem(IntPtr self);
		static extern (C) IntPtr wxTreeCtrl_GetItemParent(IntPtr self, IntPtr item);

		static extern (C) IntPtr wxTreeCtrl_GetFirstChild(IntPtr self, IntPtr item);
		static extern (C) IntPtr wxTreeCtrl_GetNextChild(IntPtr self, IntPtr item);
		static extern (C) IntPtr wxTreeCtrl_GetLastChild(IntPtr self, IntPtr item);

		static extern (C) IntPtr wxTreeCtrl_GetNextSibling(IntPtr self, IntPtr item);
		static extern (C) IntPtr wxTreeCtrl_GetPrevSibling(IntPtr self, IntPtr item);

		static extern (C) IntPtr wxTreeCtrl_GetFirstVisibleItem(IntPtr self);
		static extern (C) IntPtr wxTreeCtrl_GetNextVisible(IntPtr self, IntPtr item);
		static extern (C) IntPtr wxTreeCtrl_GetPrevVisible(IntPtr self, IntPtr item);

		static extern (C) void   wxTreeCtrl_Expand(IntPtr self, IntPtr item);

		static extern (C) void   wxTreeCtrl_Collapse(IntPtr self, IntPtr item);
		static extern (C) void   wxTreeCtrl_CollapseAndReset(IntPtr self, IntPtr item);

		static extern (C) void   wxTreeCtrl_Toggle(IntPtr self, IntPtr item);

		static extern (C) void   wxTreeCtrl_EnsureVisible(IntPtr self, IntPtr item);
		static extern (C) void   wxTreeCtrl_ScrollTo(IntPtr self, IntPtr item);

		static extern (C) int    wxTreeCtrl_GetChildrenCount(IntPtr self, IntPtr item, bool recursively);
		static extern (C) int    wxTreeCtrl_GetCount(IntPtr self);

		static extern (C) bool   wxTreeCtrl_IsVisible(IntPtr self, IntPtr item);

		static extern (C) bool   wxTreeCtrl_ItemHasChildren(IntPtr self, IntPtr item);

		static extern (C) bool   wxTreeCtrl_IsExpanded(IntPtr self, IntPtr item);
		
		static extern (C) uint   wxTreeCtrl_GetIndent(IntPtr self);
		static extern (C) void   wxTreeCtrl_SetIndent(IntPtr self, uint indent);
		
		static extern (C) uint   wxTreeCtrl_GetSpacing(IntPtr self);
		static extern (C) void   wxTreeCtrl_SetSpacing(IntPtr self, uint indent);
		
		static extern (C) IntPtr wxTreeCtrl_GetItemTextColour(IntPtr self, IntPtr item);
		static extern (C) IntPtr wxTreeCtrl_GetItemBackgroundColour(IntPtr self, IntPtr item);
		static extern (C) IntPtr wxTreeCtrl_GetItemFont(IntPtr self, IntPtr item);
		
		static extern (C) void   wxTreeCtrl_SetItemHasChildren(IntPtr self, IntPtr item, bool has);
		static extern (C) void   wxTreeCtrl_SetItemBold(IntPtr self, IntPtr item, bool bold);
		static extern (C) void   wxTreeCtrl_SetItemTextColour(IntPtr self, IntPtr item, IntPtr col);
		static extern (C) void   wxTreeCtrl_SetItemBackgroundColour(IntPtr self, IntPtr item, IntPtr col);
		
		static extern (C) void   wxTreeCtrl_EditLabel(IntPtr self, IntPtr item);
		
		static extern (C) bool   wxTreeCtrl_GetBoundingRect(IntPtr self, IntPtr item, ref Rectangle rect, bool textOnly);
		
		static extern (C) IntPtr wxTreeCtrl_InsertItem(IntPtr self, IntPtr parent, IntPtr idPrevious, string text, int image, int selectedImage, IntPtr data);
		static extern (C) IntPtr wxTreeCtrl_InsertItem2(IntPtr self, IntPtr parent, int before, string text, int image, int selectedImage, IntPtr data);
		
		static extern (C) bool   wxTreeCtrl_IsBold(IntPtr self, IntPtr item);
		
		static extern (C) IntPtr wxTreeCtrl_PrependItem(IntPtr self, IntPtr parent, string text, int image, int selectedImage, IntPtr data);
		
		static extern (C) void   wxTreeCtrl_SetItemSelectedImage(IntPtr self, IntPtr item, int selImage);
		
		static extern (C) void   wxTreeCtrl_ToggleItemSelection(IntPtr self, IntPtr item);
		
		static extern (C) void   wxTreeCtrl_UnselectItem(IntPtr self, IntPtr item);
		
		static extern (C) IntPtr wxTreeCtrl_GetMyCookie(IntPtr self);
		static extern (C) void   wxTreeCtrl_SetMyCookie(IntPtr self, IntPtr newval);
		
		static extern (C) IntPtr wxTreeCtrl_GetSelections(IntPtr self);
		
		static extern (C) void   wxTreeCtrl_SetItemFont(IntPtr self, IntPtr item, IntPtr font);
		static extern (C) void   wxTreeCtrl_SortChildren(IntPtr self, IntPtr item);
		//! \endcond

		//---------------------------------------------------------------------

	alias TreeCtrl wxTreeCtrl;
	public class TreeCtrl : Control
	{
		public const int wxTR_NO_BUTTONS                = 0x0000;
		public const int wxTR_HAS_BUTTONS                = 0x0001;
		public const int wxTR_TWIST_BUTTONS            = 0x0010;
		public const int wxTR_NO_LINES                    = 0x0004;
		public const int wxTR_LINES_AT_ROOT             = 0x0008;
		public const int wxTR_MAC_BUTTONS                = 0; // deprecated
		public const int wxTR_AQUA_BUTTONS                = 0; // deprecated

		public const int wxTR_SINGLE                    = 0x0000;
		public const int wxTR_MULTIPLE                    = 0x0020;
		public const int wxTR_EXTENDED                    = 0x0040;
		public const int wxTR_FULL_ROW_HIGHLIGHT         = 0x2000;

		public const int wxTR_EDIT_LABELS                = 0x0200;
		public const int wxTR_ROW_LINES                = 0x0400;
		public const int wxTR_HIDE_ROOT                = 0x0800;
		public const int wxTR_HAS_VARIABLE_ROW_HEIGHT    = 0x0080;

		public static /*readonly*/ int wxTR_DEFAULT_STYLE;

		static this()
		{
			wxTR_DEFAULT_STYLE    = wxTreeCtrl_GetDefaultStyle();
		}

		//-----------------------------------------------------------------------------

		public const int wxTREE_HITTEST_ABOVE           = 0x0001;
		public const int wxTREE_HITTEST_BELOW           = 0x0002;
		public const int wxTREE_HITTEST_NOWHERE         = 0x0004;
		public const int wxTREE_HITTEST_ONITEMBUTTON    = 0x0008;
		public const int wxTREE_HITTEST_ONITEMICON      = 0x0010;
		public const int wxTREE_HITTEST_ONITEMINDENT    = 0x0020;
		public const int wxTREE_HITTEST_ONITEMLABEL     = 0x0040;
		public const int wxTREE_HITTEST_ONITEMRIGHT     = 0x0080;
		public const int wxTREE_HITTEST_ONITEMSTATEICON = 0x0100;
		public const int wxTREE_HITTEST_TOLEFT          = 0x0200;
		public const int wxTREE_HITTEST_TORIGHT         = 0x0400;
		public const int wxTREE_HITTEST_ONITEMUPPERPART = 0x0800;
		public const int wxTREE_HITTEST_ONITEMLOWERPART = 0x1000;

		public const int wxTREE_HITTEST_ONITEM = wxTREE_HITTEST_ONITEMICON | wxTREE_HITTEST_ONITEMLABEL;
		
		public const string wxTreeCtrlNameStr = "treeCtrl";
		//-----------------------------------------------------------------------------
		
		public this(IntPtr wxobj)
			{ super(wxobj); }
			
		public this()
		{ 
			this(wxTreeCtrl_ctor());
			wxTreeCtrl_RegisterVirtual(wxobj, this, &staticDoOnCompareItems);
		}

		public this(Window parent, int id /*= wxID_ANY*/, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = wxTR_HAS_BUTTONS | wxTR_LINES_AT_ROOT, Validator val = null, string name = wxTreeCtrlNameStr)
		{
			this();
			if (!Create(parent, id, pos, size, style, val, name)) 
			{
				throw new InvalidOperationException("Could not create TreeCtrl");
			}
		}
		
		public static wxObject New(IntPtr wxobj)
		{
			return new TreeCtrl(wxobj);
		}

		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = wxTR_HAS_BUTTONS | wxTR_LINES_AT_ROOT, Validator val = null, string name = wxTreeCtrlNameStr)
			{ this(parent, Window.UniqueID, pos, size, style, val, name);}
		
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, ref Point pos, ref Size size, int style, Validator val, string name)
		{
			return wxTreeCtrl_Create(wxobj, wxObject.SafePtr(parent), id, pos, size, cast(uint)style, wxObject.SafePtr(val), name);
		}

		//---------------------------------------------------------------------
		
		static extern (C) private int staticDoOnCompareItems(TreeCtrl obj, IntPtr item1, IntPtr item2)
		{
			return obj.OnCompareItems(new TreeItemId(item1, true), new TreeItemId(item2, true));
		}
		
		public /+virtual+/ int OnCompareItems(TreeItemId item1, TreeItemId item2)
		{
			return wxTreeCtrl_OnCompareItems(wxobj, wxObject.SafePtr(item1), wxObject.SafePtr(item2));
		}
		
		//---------------------------------------------------------------------

		public TreeItemId AddRoot(string text)
		{ 
			return AddRoot(text, -1, -1, null); 
		}
		
		public TreeItemId AddRoot(string text, int image)
		{ 
			return AddRoot(text, image, -1, null); 
		}
		
		public TreeItemId AddRoot(string text, int image, int selImage)
		{ 
			return AddRoot(text, image, selImage, null); 
		}
		
		public TreeItemId AddRoot(string text, int image, int selImage, TreeItemData data)
		{
			return new TreeItemId(wxTreeCtrl_AddRoot(wxobj, text, image, selImage, wxObject.SafePtr(data)), true);
		}

		//---------------------------------------------------------------------

		public TreeItemId AppendItem(TreeItemId parentId, string text)
		{ 
			return AppendItem(parentId, text, -1, -1, null); 
		}
		
		public TreeItemId AppendItem(TreeItemId parentId, string text, int image)
		{ 
			return AppendItem(parentId, text, image, -1, null); 
		}
		
		public TreeItemId AppendItem(TreeItemId parentId, string text, int image, int selImage)
		{ 
			return AppendItem(parentId, text, image, selImage, null); 
		}
		
		public TreeItemId AppendItem(TreeItemId parentId, string text, int image, int selImage, TreeItemData data)
		{
			return new TreeItemId(wxTreeCtrl_AppendItem(wxobj, wxObject.SafePtr(parentId), text, image, selImage, wxObject.SafePtr(data)), true);
		}

		//---------------------------------------------------------------------

		public void AssignImageList(ImageList imageList)
		{
			wxTreeCtrl_AssignImageList(wxobj, wxObject.SafePtr(imageList));
		}
		
		//---------------------------------------------------------------------

		public void AssignStateImageList(ImageList imageList)
		{
			wxTreeCtrl_AssignStateImageList(wxobj, wxObject.SafePtr(imageList));
		}
		
		//---------------------------------------------------------------------

		/*public void AssignButtonsImageList(ImageList imageList)
		{
			wxTreeCtrl_AssignButtonsImageList(wxobj, wxObject.SafePtr(imageList));
		}*/

		//---------------------------------------------------------------------

		public ImageList imageList() { return cast(ImageList)FindObject(wxTreeCtrl_GetImageList(wxobj), &ImageList.New); }
			
		public void imageList(ImageList value) { wxTreeCtrl_SetImageList(wxobj, wxObject.SafePtr(value)); }

		//---------------------------------------------------------------------

		public void SetImageList(ImageList imageList)
		{
			wxTreeCtrl_SetImageList(wxobj, wxObject.SafePtr(imageList));
		}
		
		//---------------------------------------------------------------------
		
		public ImageList StateImageList() { return cast(ImageList)FindObject(wxTreeCtrl_GetStateImageList(wxobj), &ImageList.New); }
			
		public void StateImageList(ImageList value) { wxTreeCtrl_SetStateImageList(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------
		
		/*public ImageList ButtonsImageList
		{
			get { return (ImageList)FindObject(wxTreeCtrl_GetButtonsImageList(wxobj), typeid(ImageList)); }
			
			set { wxTreeCtrl_SetButtonsImageList(wxobj, wxObject.SafePtr(value)); }
		}*/

		//---------------------------------------------------------------------
		
		public void SetItemImage(TreeItemId item, int image)
		{
			SetItemImage(item, image, TreeItemIcon.wxTreeItemIcon_Normal);
		}

		public void SetItemImage(TreeItemId item, int image, TreeItemIcon which)
		{
			wxTreeCtrl_SetItemImage(wxobj, wxObject.SafePtr(item), image, which);
		}

		//---------------------------------------------------------------------
		
		public int GetItemImage(TreeItemId item)
		{
			return GetItemImage(item, TreeItemIcon.wxTreeItemIcon_Normal);
		}

		public int GetItemImage(TreeItemId item, TreeItemIcon which)
		{
			return wxTreeCtrl_GetItemImage(wxobj, wxObject.SafePtr(item), which);
		}

		//---------------------------------------------------------------------

		public void DeleteAllItems()
		{
			wxTreeCtrl_DeleteAllItems(wxobj);
		}

		public void Delete(TreeItemId item)
		{
			wxTreeCtrl_Delete(wxobj, wxObject.SafePtr(item));
		}

		public void DeleteChildren(TreeItemId item)
		{
			wxTreeCtrl_DeleteChildren(wxobj, wxObject.SafePtr(item));
		}

		//---------------------------------------------------------------------

		public void Unselect()
		{
			wxTreeCtrl_Unselect(wxobj);
		}

		public void UnselectAll()
		{
			wxTreeCtrl_UnselectAll(wxobj);
		}

		//---------------------------------------------------------------------

		public bool IsSelected(TreeItemId item)
		{
			return wxTreeCtrl_IsSelected(wxobj, wxObject.SafePtr(item));
		}

		public void SelectItem(TreeItemId item)
		{
			wxTreeCtrl_SelectItem(wxobj, wxObject.SafePtr(item));
		}

		public TreeItemId Selection() { return new TreeItemId(wxTreeCtrl_GetSelection(wxobj), true); }
		public void Selection(TreeItemId value) { SelectItem(value); }

		//---------------------------------------------------------------------

		public void SetItemText(TreeItemId item, string text)
		{
			wxTreeCtrl_SetItemText(wxobj, wxObject.SafePtr(item), text);
		}

		public string GetItemText(TreeItemId item)
		{
			return cast(string) new wxString(wxTreeCtrl_GetItemText(wxobj, wxObject.SafePtr(item)), true);
		}

		//---------------------------------------------------------------------

		public void SetItemData(TreeItemId item, TreeItemData data)
		{
			wxTreeCtrl_SetItemData(wxobj, wxObject.SafePtr(item), wxObject.SafePtr(data));
		}

		public TreeItemData GetItemData(TreeItemId item)
		{
			return cast(TreeItemData)wxObject.FindObject(wxTreeCtrl_GetItemData(wxobj, wxObject.SafePtr(item)));
		}

		//---------------------------------------------------------------------
        
		public TreeItemId HitTest(Point pt, out int flags)
		{
			return new TreeItemId(wxTreeCtrl_HitTest(wxobj, pt, flags), true);
		}

		//---------------------------------------------------------------------

		public TreeItemId RootItem() { return new TreeItemId(wxTreeCtrl_GetRootItem(wxobj), true); }

		public TreeItemId GetItemParent(TreeItemId item)
		{
			return new TreeItemId(wxTreeCtrl_GetItemParent(wxobj, wxObject.SafePtr(item)), true);
		}

		//---------------------------------------------------------------------
        
		public TreeItemId GetFirstChild(TreeItemId item, ref IntPtr cookie)
		{
			TreeItemId id = new TreeItemId(wxTreeCtrl_GetFirstChild(wxobj, wxObject.SafePtr(item)), true);
			
			cookie = wxTreeCtrl_GetMyCookie(wxobj);
			
			return id;
		}

		public TreeItemId GetNextChild(TreeItemId item, ref IntPtr cookie)
		{
			wxTreeCtrl_SetMyCookie(wxobj, cookie);
			
			TreeItemId id = new TreeItemId(wxTreeCtrl_GetNextChild(wxobj, wxObject.SafePtr(item)), true);
			
			cookie =  wxTreeCtrl_GetMyCookie(wxobj);
			
			return id;
		}

		public TreeItemId GetLastChild(TreeItemId item)
		{
			return new TreeItemId(wxTreeCtrl_GetLastChild(wxobj, wxObject.SafePtr(item)), true);
		}

		//---------------------------------------------------------------------

		public TreeItemId GetNextSibling(TreeItemId item)
		{
			return new TreeItemId(wxTreeCtrl_GetNextSibling(wxobj, wxObject.SafePtr(item)), true);
		}

		public TreeItemId GetPrevSibling(TreeItemId item)
		{
			return new TreeItemId(wxTreeCtrl_GetPrevSibling(wxobj, wxObject.SafePtr(item)), true);
		}

		//---------------------------------------------------------------------

		public TreeItemId GetFirstVisibleItem()
		{
			return new TreeItemId(wxTreeCtrl_GetFirstVisibleItem(wxobj), true);
		}

		public TreeItemId GetNextVisible(TreeItemId item)
		{
			return new TreeItemId(wxTreeCtrl_GetNextVisible(wxobj, wxObject.SafePtr(item)), true);
		}

		public TreeItemId GetPrevVisible(TreeItemId item)
		{
			return new TreeItemId(wxTreeCtrl_GetPrevVisible(wxobj, wxObject.SafePtr(item)), true);
		}

		//---------------------------------------------------------------------

		public void Expand(TreeItemId item)
		{
			wxTreeCtrl_Expand(wxobj, wxObject.SafePtr(item));
		}

		//---------------------------------------------------------------------

		public void Collapse(TreeItemId item)
		{
			wxTreeCtrl_Collapse(wxobj, wxObject.SafePtr(item));
		}

		public void CollapseAndReset(TreeItemId item)
		{
			wxTreeCtrl_CollapseAndReset(wxobj, wxObject.SafePtr(item));
		}

		//---------------------------------------------------------------------

		public void Toggle(TreeItemId item)
		{
			wxTreeCtrl_Toggle(wxobj, wxObject.SafePtr(item));
		}

		//---------------------------------------------------------------------

		public void EnsureVisible(TreeItemId item)
		{
			wxTreeCtrl_EnsureVisible(wxobj, wxObject.SafePtr(item));
		}

		public void ScrollTo(TreeItemId item)
		{
			wxTreeCtrl_ScrollTo(wxobj, wxObject.SafePtr(item));
		}

		//---------------------------------------------------------------------
		
		public int GetChildrenCount(TreeItemId item)
		{
			return GetChildrenCount(item, true);
		}

		public int GetChildrenCount(TreeItemId item, bool recursively)
		{
			return wxTreeCtrl_GetChildrenCount(wxobj, wxObject.SafePtr(item), recursively);
		}

		public int Count() { return wxTreeCtrl_GetCount(wxobj); }

		//---------------------------------------------------------------------

		public bool IsVisible(TreeItemId item)
		{
			return wxTreeCtrl_IsVisible(wxobj, wxObject.SafePtr(item));
		}

		//---------------------------------------------------------------------

		public bool ItemHasChildren(TreeItemId item)
		{
			return wxTreeCtrl_ItemHasChildren(wxobj, wxObject.SafePtr(item));
		}

		//---------------------------------------------------------------------

		public bool IsExpanded(TreeItemId item)
		{
			return wxTreeCtrl_IsExpanded(wxobj, wxObject.SafePtr(item));
		}

		//---------------------------------------------------------------------

		public bool HasChildren(TreeItemId item)
		{
			return GetChildrenCount(item, false) > 0;
		}

		// A brute force way to get list of selections (if wxTR_MULTIPLE has been
		// enabled) by inspecting each item. May want to replace with Interop
		// invocation of GetSelections() if it is implemented more efficiently
		// (such as the TreeCtrl has a built-in list of currect selections).
		public TreeItemId[] SelectionsOld()
		{
			return Get_Items(GetItemsMode.Selections, this.RootItem, true);
		}
		
		// This is now interop...
		public TreeItemId[] Selections()
		{
			return (new ArrayTreeItemIds(wxTreeCtrl_GetSelections(wxobj), true)).toArray();
		}

		// This is an addition to the standard API. Limits the selection
		// search to parent_item and below.
		public TreeItemId[] SelectionsAtOrBelow(TreeItemId parent_item)
		{
			return Get_Items(GetItemsMode.Selections, parent_item, false);
		}

		// This is an addition to the standard API. Limits the selection
		// search to those items below parent_item.
		public TreeItemId[] SelectionsBelow(TreeItemId parent_item)
		{
			return Get_Items(GetItemsMode.Selections, parent_item, true);
		}

		// This is an addition to the standard API. Returns all items
		// except for the root node.
		public TreeItemId[] AllItems()
		{
			return Get_Items(GetItemsMode.All, this.RootItem, true);
		}

		// This is an addition to the standard API. Only returns items
		// that are at or below parent_item (i.e. returns parent_item).
		public TreeItemId[] AllItemsAtOrBelow(TreeItemId parent_item)
		{
			return Get_Items(GetItemsMode.All, parent_item, false);
		}

		// This is an addition to the standard API. Only returns items
		// that are below parent_item.
		public TreeItemId[] AllItemsBelow(TreeItemId parent_item)
		{
			return Get_Items(GetItemsMode.All, parent_item, true);
		}

		private enum GetItemsMode
		{
			Selections,
			All,
		}

		private TreeItemId[] Get_Items(GetItemsMode mode, TreeItemId parent_item, 
			bool skip_parent)
		{
			// Console.WriteLine("---");
			TreeItemId[] list;
			Add_Items(mode, parent_item, list, IntPtr.init, skip_parent);
			return list;
		}

		private void Add_Items(GetItemsMode mode, TreeItemId parent, 
			TreeItemId[] list, IntPtr cookie, bool skip_parent)
		{
			TreeItemId id;

			if ( cookie == IntPtr.init)
			{
				if ( (! skip_parent) && 
					((mode == GetItemsMode.All) || (this.IsSelected(parent))))
				{
					// Console.WriteLine(this.GetItemText(parent));
					list ~= parent;
				}
				id = GetFirstChild(parent, cookie);
			}
			else
			{
				id = GetNextChild(parent, cookie);
			}

			if ( ! id.IsOk() )
				return;

			if ((mode == GetItemsMode.All) || (this.IsSelected(id)))
			{
				// Console.WriteLine(this.GetItemText(id));
				list ~= id;
			}

			if (ItemHasChildren(id))
			{
				Add_Items(mode, id, list, IntPtr.init, false);
			}

			Add_Items(mode, parent, list, cookie, false);
		}
		
		//---------------------------------------------------------------------
		
		public uint Indent() { return wxTreeCtrl_GetIndent(wxobj); }
		public void Indent(uint value) { wxTreeCtrl_SetIndent(wxobj, value); }
		
		//---------------------------------------------------------------------
		
		public uint Spacing() { return wxTreeCtrl_GetSpacing(wxobj); }
		public void Spacing(uint value) { wxTreeCtrl_SetSpacing(wxobj, value); }
		
		//---------------------------------------------------------------------
		
		public Colour GetItemTextColour(TreeItemId item)
		{
			return new Colour(wxTreeCtrl_GetItemTextColour(wxobj, wxObject.SafePtr(item)), true);
		}
		
		//---------------------------------------------------------------------
		
		public Colour GetItemBackgroundColour(TreeItemId item)
		{
			return new Colour(wxTreeCtrl_GetItemBackgroundColour(wxobj, wxObject.SafePtr(item)), true);
		}
		
		//---------------------------------------------------------------------
		
		public Font GetItemFont(TreeItemId item)
		{
			return new Font(wxTreeCtrl_GetItemFont(wxobj, wxObject.SafePtr(item)), true);
		}
		
		public void SetItemFont(TreeItemId item, Font font)
		{
			wxTreeCtrl_SetItemFont(wxobj, wxObject.SafePtr(item), wxObject.SafePtr(font));
		}

		//---------------------------------------------------------------------
		
		public void SetItemHasChildren(TreeItemId item)
		{
			SetItemHasChildren(item, true);
		}
		
		public void SetItemHasChildren(TreeItemId item, bool has)
		{
			wxTreeCtrl_SetItemHasChildren(wxobj, wxObject.SafePtr(item), has);
		}
		
		//---------------------------------------------------------------------
		
		public void SetItemBold(TreeItemId item)
		{
			SetItemBold(item, true);
		}
		
		public void SetItemBold(TreeItemId item, bool bold)
		{
			wxTreeCtrl_SetItemBold(wxobj, wxObject.SafePtr(item), bold);
		}
		
		//---------------------------------------------------------------------
		
		public void SetItemTextColour(TreeItemId item, Colour col)
		{
			wxTreeCtrl_SetItemTextColour(wxobj, wxObject.SafePtr(item), wxObject.SafePtr(col));
		}
		
		//---------------------------------------------------------------------
		
		public void SetItemBackgroundColour(TreeItemId item, Colour col)
		{
			wxTreeCtrl_SetItemBackgroundColour(wxobj, wxObject.SafePtr(item), wxObject.SafePtr(col));
		}
		
		//---------------------------------------------------------------------
		
		public void EditLabel(TreeItemId item)
		{
			wxTreeCtrl_EditLabel(wxobj, wxObject.SafePtr(item));
		}
		
		//---------------------------------------------------------------------
		
		public bool GetBoundingRect(TreeItemId item, ref Rectangle rect)
		{
			return GetBoundingRect(item, rect, false);
		}
		
		public bool GetBoundingRect(TreeItemId item, ref Rectangle rect, bool textOnly)
		{
			return wxTreeCtrl_GetBoundingRect(wxobj, wxObject.SafePtr(item), rect, textOnly);
		}
		
		//---------------------------------------------------------------------
		
		public TreeItemId InsertItem(TreeItemId parent, TreeItemId previous, string text)
		{
			return InsertItem(parent, previous, text, -1, -1, null);
		}
		
		public TreeItemId InsertItem(TreeItemId parent, TreeItemId previous, string text, int image)
		{
			return InsertItem(parent, previous, text, image, -1, null);
		}
		
		public TreeItemId InsertItem(TreeItemId parent, TreeItemId previous, string text, int image, int sellimage)
		{
			return InsertItem(parent, previous, text, image, sellimage, null);
		}
		
		public TreeItemId InsertItem(TreeItemId parent, TreeItemId previous, string text, int image, int sellimage, TreeItemData data)
		{
			return new TreeItemId(wxTreeCtrl_InsertItem(wxobj, wxObject.SafePtr(parent), wxObject.SafePtr(previous), text, image, sellimage, wxObject.SafePtr(data)), true);
		}
		
		//---------------------------------------------------------------------
		
		public TreeItemId InsertItem(TreeItemId parent, int before, string text)
		{
			return InsertItem(parent, before, text, -1, -1, null);
		}
		
		public TreeItemId InsertItem(TreeItemId parent, int before, string text, int image)
		{
			return InsertItem(parent, before, text, image, -1, null);
		}
		
		public TreeItemId InsertItem(TreeItemId parent, int before, string text, int image, int sellimage)
		{
			return InsertItem(parent, before, text, image, sellimage, null);
		}
		
		public TreeItemId InsertItem(TreeItemId parent, int before, string text, int image, int sellimage, TreeItemData data)
		{
			return new TreeItemId(wxTreeCtrl_InsertItem2(wxobj, wxObject.SafePtr(parent), before, text, image, sellimage, wxObject.SafePtr(data)), true);
		}
		
		//---------------------------------------------------------------------
		
		public bool IsBold(TreeItemId item)
		{
			return wxTreeCtrl_IsBold(wxobj, wxObject.SafePtr(item));
		}
		
		//---------------------------------------------------------------------
		
		public TreeItemId PrependItem(TreeItemId parent, string text)
		{
			return PrependItem(parent, text, -1, -1, null);
		}
		
		public TreeItemId PrependItem(TreeItemId parent, string text, int image)
		{
			return PrependItem(parent, text, image, -1, null);
		}
		
		public TreeItemId PrependItem(TreeItemId parent, string text, int image, int sellimage)
		{
			return PrependItem(parent, text, image, sellimage, null);
		}
		
		public TreeItemId PrependItem(TreeItemId parent, string text, int image, int sellimage, TreeItemData data)
		{
			return new TreeItemId(wxTreeCtrl_PrependItem(wxobj, wxObject.SafePtr(parent), text, image, sellimage, wxObject.SafePtr(data)), true);
		}
		
		//---------------------------------------------------------------------
		
		public void SetItemSelectedImage(TreeItemId item, int selImage)
		{
			wxTreeCtrl_SetItemSelectedImage(wxobj, wxObject.SafePtr(item), selImage);
		}
		
		//---------------------------------------------------------------------
		
		public void ToggleItemSelection(TreeItemId item)
		{
			wxTreeCtrl_ToggleItemSelection(wxobj, wxObject.SafePtr(item));
		}
		
		//---------------------------------------------------------------------
		
		public void UnselectItem(TreeItemId item)
		{
			wxTreeCtrl_UnselectItem(wxobj, wxObject.SafePtr(item));
		}
		
		//---------------------------------------------------------------------
		
		public void SortChildren(TreeItemId item)
		{
			wxTreeCtrl_SortChildren(wxobj, wxObject.SafePtr(item));
		}
		
		//---------------------------------------------------------------------
		public void BeginDrag_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_BEGIN_DRAG, ID, value, this); }
		public void BeginDrag_Remove(EventListener value) { RemoveHandler(value, this); }

		public void BeginRightDrag_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_BEGIN_RDRAG, ID, value, this); }
		public void BeginRightDrag_Remove(EventListener value) { RemoveHandler(value, this); }

		public void BeginLabelEdit_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_BEGIN_LABEL_EDIT, ID, value, this); }
		public void BeginLabelEdit_Remove(EventListener value) { RemoveHandler(value, this); }

		public void EndLabelEdit_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_END_LABEL_EDIT, ID, value, this); }
		public void EndLabelEdit_Remove(EventListener value) { RemoveHandler(value, this); }

		public void DeleteItem_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_DELETE_ITEM, ID, value, this); }
		public void DeleteItem_Remove(EventListener value) { RemoveHandler(value, this); }

		public void GetInfo_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_GET_INFO, ID, value, this); }
		public void GetInfo_Remove(EventListener value) { RemoveHandler(value, this); }

		public void SetInfo_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_SET_INFO, ID, value, this); }
		public void SetInfo_Remove(EventListener value) { RemoveHandler(value, this); }

		public void ItemExpand_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_ITEM_EXPANDED, ID, value, this); }
		public void ItemExpand_Remove(EventListener value) { RemoveHandler(value, this); }

		public void ItemExpanding_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_ITEM_EXPANDING, ID, value, this); }
		public void ItemExpanding_Remove(EventListener value) { RemoveHandler(value, this); }

		public void ItemCollapse_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_ITEM_COLLAPSED, ID, value, this); }
		public void ItemCollapse_Remove(EventListener value) { RemoveHandler(value, this); }

		public void ItemCollapsing_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_ITEM_COLLAPSING, ID, value, this); }
		public void ItemCollapsing_Remove(EventListener value) { RemoveHandler(value, this); }

		public void SelectionChange_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_SEL_CHANGED, ID, value, this); }
		public void SelectionChange_Remove(EventListener value) { RemoveHandler(value, this); }

		public void SelectionChanging_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_SEL_CHANGING, ID, value, this); }
		public void SelectionChanging_Remove(EventListener value) { RemoveHandler(value, this); }

		public override void KeyDown_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_KEY_DOWN, ID, value, this); }
		public override void KeyDown_Remove(EventListener value) { RemoveHandler(value, this); }

		public void ItemActivate_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_ITEM_ACTIVATED, ID, value, this); }
		public void ItemActivate_Remove(EventListener value) { RemoveHandler(value, this); }

		public void ItemRightClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_ITEM_RIGHT_CLICK, ID, value, this); }
		public void ItemRightClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void ItemMiddleClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_ITEM_MIDDLE_CLICK, ID, value, this); }
		public void ItemMiddleClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void EndDrag_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TREE_END_DRAG, ID, value, this); }
		public void EndDrag_Remove(EventListener value) { RemoveHandler(value, this); }

	}
	
	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxTreeEvent_ctor(int commandType, int id);
		static extern (C) IntPtr wxTreeEvent_GetItem(IntPtr self);
		static extern (C) void   wxTreeEvent_SetItem(IntPtr self, IntPtr item);
		static extern (C) IntPtr wxTreeEvent_GetOldItem(IntPtr self);
		static extern (C) void   wxTreeEvent_SetOldItem(IntPtr self, IntPtr item);
		static extern (C) void   wxTreeEvent_GetPoint(IntPtr self, ref Point pt);
		static extern (C) void   wxTreeEvent_SetPoint(IntPtr self, ref Point pt);
		static extern (C) IntPtr wxTreeEvent_GetKeyEvent(IntPtr self);
		static extern (C) int    wxTreeEvent_GetKeyCode(IntPtr self);
		static extern (C) void   wxTreeEvent_SetKeyEvent(IntPtr self, IntPtr evt);
		static extern (C) IntPtr wxTreeEvent_GetLabel(IntPtr self);
		static extern (C) void   wxTreeEvent_SetLabel(IntPtr self, string label);
		static extern (C) bool   wxTreeEvent_IsEditCancelled(IntPtr self);
		static extern (C) void   wxTreeEvent_SetEditCanceled(IntPtr self, bool editCancelled);
		//static extern (C) int    wxTreeEvent_GetCode(IntPtr self);
		static extern (C) void   wxTreeEvent_Veto(IntPtr self);
		static extern (C) void   wxTreeEvent_Allow(IntPtr self);
		static extern (C) bool   wxTreeEvent_IsAllowed(IntPtr self);       
		
		static extern (C) void   wxTreeEvent_SetToolTip(IntPtr self, string toolTip);
		//! \endcond

		//-----------------------------------------------------------------------------

	alias TreeEvent wxTreeEvent;
	public class TreeEvent : Event
	{
		public this(IntPtr wxobj)
			{ super(wxobj); }
		public this(int commandType, int id)
			{ super(wxTreeEvent_ctor(commandType, id)); }

		//-----------------------------------------------------------------------------

		public TreeItemId Item() { return new TreeItemId(wxTreeEvent_GetItem(wxobj), true); }
		public void Item(TreeItemId value) { wxTreeEvent_SetItem(wxobj, wxObject.SafePtr(value)); }

		public TreeItemId OldItem() { return new TreeItemId(wxTreeEvent_GetOldItem(wxobj), true); }
		public void OldItem(TreeItemId value) { wxTreeEvent_SetOldItem(wxobj, wxObject.SafePtr(value)); }

		//-----------------------------------------------------------------------------

		public Point point() 
			{ 
				Point pt;
				wxTreeEvent_GetPoint(wxobj, pt);
				return pt;
			}
		public void point(Point value) { wxTreeEvent_SetPoint(wxobj, value); }

		//-----------------------------------------------------------------------------

		public KeyEvent keyEvent() { return cast(KeyEvent)FindObject(wxTreeEvent_GetKeyEvent(wxobj), cast(wxObject function(IntPtr ptr))&KeyEvent.New); }
		public void keyEvent(KeyEvent value) { wxTreeEvent_SetKeyEvent(wxobj, wxObject.SafePtr(value)); }

		//-----------------------------------------------------------------------------

		public int KeyCode() { return wxTreeEvent_GetKeyCode(wxobj); }

		//-----------------------------------------------------------------------------

		public string Label() { return cast(string) new wxString(wxTreeEvent_GetLabel(wxobj), true); }
		public void Label(string value) { wxTreeEvent_SetLabel(wxobj, value); }

		//-----------------------------------------------------------------------------

		public bool IsEditCancelled() { return wxTreeEvent_IsEditCancelled(wxobj); } 
		public void IsEditCancelled(bool value) { wxTreeEvent_SetEditCanceled(wxobj, value); }
		
		public void ToolTip(string value) { wxTreeEvent_SetToolTip(wxobj, value); }
		
		//-----------------------------------------------------------------------------        
        
		public void Veto()
		{
			wxTreeEvent_Veto(wxobj);
		}
        
		//-----------------------------------------------------------------------------
        
		public void Allow()
		{
			wxTreeEvent_Allow(wxobj);
		}
        
		//-----------------------------------------------------------------------------
        
		public bool Allowed() { return  wxTreeEvent_IsAllowed(wxobj); }

		private static Event New(IntPtr obj) { return new TreeEvent(obj); }

		static this()
		{
			wxEVT_COMMAND_TREE_BEGIN_DRAG = wxEvent_EVT_COMMAND_TREE_BEGIN_DRAG();
			wxEVT_COMMAND_TREE_BEGIN_RDRAG = wxEvent_EVT_COMMAND_TREE_BEGIN_RDRAG();
			wxEVT_COMMAND_TREE_BEGIN_LABEL_EDIT = wxEvent_EVT_COMMAND_TREE_BEGIN_LABEL_EDIT();
			wxEVT_COMMAND_TREE_END_LABEL_EDIT = wxEvent_EVT_COMMAND_TREE_END_LABEL_EDIT();
			wxEVT_COMMAND_TREE_DELETE_ITEM = wxEvent_EVT_COMMAND_TREE_DELETE_ITEM();
			wxEVT_COMMAND_TREE_GET_INFO = wxEvent_EVT_COMMAND_TREE_GET_INFO();
			wxEVT_COMMAND_TREE_SET_INFO = wxEvent_EVT_COMMAND_TREE_SET_INFO();
			wxEVT_COMMAND_TREE_ITEM_EXPANDED = wxEvent_EVT_COMMAND_TREE_ITEM_EXPANDED();
			wxEVT_COMMAND_TREE_ITEM_EXPANDING = wxEvent_EVT_COMMAND_TREE_ITEM_EXPANDING();
			wxEVT_COMMAND_TREE_ITEM_COLLAPSED = wxEvent_EVT_COMMAND_TREE_ITEM_COLLAPSED();
			wxEVT_COMMAND_TREE_ITEM_COLLAPSING = wxEvent_EVT_COMMAND_TREE_ITEM_COLLAPSING();
			wxEVT_COMMAND_TREE_SEL_CHANGED = wxEvent_EVT_COMMAND_TREE_SEL_CHANGED();
			wxEVT_COMMAND_TREE_SEL_CHANGING = wxEvent_EVT_COMMAND_TREE_SEL_CHANGING();
			wxEVT_COMMAND_TREE_KEY_DOWN = wxEvent_EVT_COMMAND_TREE_KEY_DOWN();
			wxEVT_COMMAND_TREE_ITEM_ACTIVATED = wxEvent_EVT_COMMAND_TREE_ITEM_ACTIVATED();
			wxEVT_COMMAND_TREE_ITEM_RIGHT_CLICK = wxEvent_EVT_COMMAND_TREE_ITEM_RIGHT_CLICK();
			wxEVT_COMMAND_TREE_ITEM_MIDDLE_CLICK = wxEvent_EVT_COMMAND_TREE_ITEM_MIDDLE_CLICK();
			wxEVT_COMMAND_TREE_END_DRAG = wxEvent_EVT_COMMAND_TREE_END_DRAG();

			AddEventType(wxEVT_COMMAND_TREE_BEGIN_DRAG,         &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_BEGIN_RDRAG,        &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_BEGIN_LABEL_EDIT,   &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_END_LABEL_EDIT,     &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_DELETE_ITEM,        &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_GET_INFO,           &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_SET_INFO,           &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_ITEM_EXPANDED,      &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_ITEM_EXPANDING,     &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_ITEM_COLLAPSED,     &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_ITEM_COLLAPSING,    &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_SEL_CHANGED,        &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_SEL_CHANGING,       &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_KEY_DOWN,           &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_ITEM_ACTIVATED,     &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_ITEM_RIGHT_CLICK,   &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_ITEM_MIDDLE_CLICK,  &TreeEvent.New);
			AddEventType(wxEVT_COMMAND_TREE_END_DRAG,           &TreeEvent.New);
		}
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxArrayTreeItemIds_ctor();
		static extern (C) void   wxArrayTreeItemIds_dtor(IntPtr self);
		static extern (C) void   wxArrayTreeItemIds_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) void   wxArrayTreeItemIds_Add(IntPtr self, IntPtr toadd);
		static extern (C) IntPtr wxArrayTreeItemIds_Item(IntPtr self, int num);
		static extern (C) int    wxArrayTreeItemIds_GetCount(IntPtr self);
		//! \endcond
		
		//---------------------------------------------------------------------

	alias ArrayTreeItemIds wxArrayTreeItemIds;
	public class ArrayTreeItemIds : wxObject
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
			this(wxArrayTreeItemIds_ctor(), true);
			wxArrayTreeItemIds_RegisterDisposable(wxobj, &VirtualDispose);
		}
		
		//---------------------------------------------------------------------

		public TreeItemId[] toArray()
		{
			int count = this.Count();
			TreeItemId[] tmps = new TreeItemId[count];
			for (int i = 0; i < count; i++)
				tmps[i] = this.Item(i);
			return tmps;
		}
	
		public TreeItemId Item(int num)
		{
			return new TreeItemId(wxArrayTreeItemIds_Item(wxobj, num), true);
		}	
	
		public void Add(TreeItemId toadd)
		{
			wxArrayTreeItemIds_Add(wxobj, wxObject.SafePtr(toadd));
		}

		public int Count() { return wxArrayTreeItemIds_GetCount(wxobj); }
        
		//---------------------------------------------------------------------

		override protected void dtor() { wxArrayTreeItemIds_dtor(wxobj); }
	}
