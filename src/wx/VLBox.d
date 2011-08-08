//-----------------------------------------------------------------------------
// wxD - VLBox.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - VLBox.cs
//
/// The wxVListBox wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: VLBox.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.VLBox;
public import wx.common;
public import wx.VScroll;

		//! \cond EXTERN
		extern (C) {
		alias int function(VListBox obj, int n) Virtual_IntInt;
		alias void function(VListBox obj, IntPtr dc, Rectangle rect, int n) Virtual_VoidDcRectSizeT;
		}

		static extern (C) IntPtr wxVListBox_ctor(IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) void wxVListBox_RegisterVirtual(IntPtr self, VListBox obj, 
			Virtual_VoidDcRectSizeT onDrawItem, 
			Virtual_IntInt onMeasureItem, 
			Virtual_VoidDcRectSizeT onDrawSeparator,
			Virtual_VoidDcRectSizeT onDrawBackground,
			Virtual_IntInt onGetLineHeight);
		static extern (C) bool wxVListBox_Create(IntPtr self,IntPtr parent, int id, ref Point pos, ref Size size, int style, string name);		
		static extern (C) void wxVListBox_OnDrawSeparator(IntPtr self, IntPtr dc, ref Rectangle rect, int n);
		static extern (C) void wxVListBox_OnDrawBackground(IntPtr self, IntPtr dc, ref Rectangle rect, int n);
		static extern (C) int wxVListBox_OnGetLineHeight(IntPtr self, int line);
		static extern (C) int wxVListBox_GetItemCount(IntPtr self);
		static extern (C) bool wxVListBox_HasMultipleSelection(IntPtr self);
		static extern (C) int wxVListBox_GetSelection(IntPtr self);
		static extern (C) bool wxVListBox_IsCurrent(IntPtr self, int item);
		static extern (C) bool wxVListBox_IsSelected(IntPtr self, int item);
		static extern (C) int wxVListBox_GetSelectedCount(IntPtr self);
		static extern (C) int wxVListBox_GetFirstSelected(IntPtr self, out uint cookie);
		static extern (C) int wxVListBox_GetNextSelected(IntPtr self, ref uint cookie);
		static extern (C) void wxVListBox_GetMargins(IntPtr self, out Point pt);
		static extern (C) IntPtr wxVListBox_GetSelectionBackground(IntPtr self);
		static extern (C) void wxVListBox_SetItemCount(IntPtr self, int count);
		static extern (C) void wxVListBox_Clear(IntPtr self);
		static extern (C) void wxVListBox_SetSelection(IntPtr self, int selection);
		static extern (C) bool wxVListBox_Select(IntPtr self, int item, bool select);
		static extern (C) bool wxVListBox_SelectRange(IntPtr self, int from, int to);
		static extern (C) void wxVListBox_Toggle(IntPtr self, int item);
		static extern (C) bool wxVListBox_SelectAll(IntPtr self);
		static extern (C) bool wxVListBox_DeselectAll(IntPtr self);
		static extern (C) void wxVListBox_SetMargins(IntPtr self, ref Point pt);
		static extern (C) void wxVListBox_SetMargins2(IntPtr self, int x, int y);
		static extern (C) void wxVListBox_SetSelectionBackground(IntPtr self, IntPtr col);
		//! \endcond
		
	public abstract class VListBox : VScrolledWindow
	{
		const string wxVListBoxNameStr = "wxVListBox";
	
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this()
			{ this(null, Window.UniqueID, wxDefaultPosition, wxDefaultSize, 0, "");}
			
		public this(Window parent, int id /*= wxID_ANY*/, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name = wxVListBoxNameStr)
		{
			this(wxVListBox_ctor(wxObject.SafePtr(parent), id, pos, size, style, name));
			wxVListBox_RegisterVirtual(wxobj, this,
				&staticDoOnDrawItem,
				&staticOnMeasureItem,
				&staticDoOnDrawSeparator,
				&staticDoOnDrawBackground,
				&staticOnGetLineHeight);
		}
		
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name = wxVListBoxNameStr)
			{ this(parent, Window.UniqueID, pos, size, style, name);}
		
		//-----------------------------------------------------------------------------
		
		public override bool Create(Window parent, int id, ref Point pos, ref Size size, int style, string name)
		{
			return wxVListBox_Create(wxobj, wxObject.SafePtr(parent), id, pos, size, style, name); 
		}
		
		//-----------------------------------------------------------------------------
		
		protected abstract void OnDrawItem(DC dc, Rectangle rect, int n);
		
		static extern(C) private void staticDoOnDrawItem(VListBox obj, IntPtr dc, Rectangle rect, int n)
		{
			obj.OnDrawItem(cast(DC)FindObject(dc, &DC.New), rect, n);
		}
		
		//-----------------------------------------------------------------------------
		
		protected abstract int OnMeasureItem(int n);
		
		static extern(C) private int staticOnMeasureItem(VListBox obj, int n)
		{
			return obj.OnMeasureItem(n);
		}

		//-----------------------------------------------------------------------------
		
		protected /+virtual+/ void OnDrawSeparator(DC dc, Rectangle rect, int n)
		{
			wxVListBox_OnDrawSeparator(wxobj, wxObject.SafePtr(dc), rect, n);
		}
		
		static extern(C) private void staticDoOnDrawSeparator(VListBox obj, IntPtr dc, Rectangle rect, int n)
		{
			obj.OnDrawSeparator(cast(DC)FindObject(dc, &DC.New), rect, n);
		}
		
		//-----------------------------------------------------------------------------
		
		protected /+virtual+/ void OnDrawBackground(DC dc, Rectangle rect, int n)
		{
			wxVListBox_OnDrawBackground(wxobj, wxObject.SafePtr(dc), rect, n);
		}
		
		static extern(C) private void staticDoOnDrawBackground(VListBox obj, IntPtr dc, Rectangle rect, int n)
		{
			obj.OnDrawBackground(cast(DC)FindObject(dc, &DC.New), rect, n);
		}
		
		//-----------------------------------------------------------------------------
		
		protected override int OnGetLineHeight(int line)
		{
			return wxVListBox_OnGetLineHeight(wxobj, line);
		}
		
		static extern(C) private override int staticOnGetLineHeight(VListBox obj, int line)
		{
			return obj.OnGetLineHeight(line);
		}

		//-----------------------------------------------------------------------------
		
		public int ItemCount() { return wxVListBox_GetItemCount(wxobj); }
		public void ItemCount(int value) { wxVListBox_SetItemCount(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public bool HasMultipleSelection() { return wxVListBox_HasMultipleSelection(wxobj); }
		
		//-----------------------------------------------------------------------------
		
		public int Selection() { return wxVListBox_GetSelection(wxobj); }
		public void Selection(int value) { wxVListBox_SetSelection(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public bool IsCurrent(int item)
		{
			return wxVListBox_IsCurrent(wxobj, item);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool IsSelected(int item)
		{
			return wxVListBox_IsSelected(wxobj, item);
		}
		
		//-----------------------------------------------------------------------------
		
		public int SelectedCount() { return wxVListBox_GetSelectedCount(wxobj); }
		
		//-----------------------------------------------------------------------------
		
		public int GetFirstSelected(out uint cookie)
		{
			return wxVListBox_GetFirstSelected(wxobj, cookie);
		}
		
		//-----------------------------------------------------------------------------
		
		public int GetNextSelected(ref uint cookie)
		{
			return wxVListBox_GetNextSelected(wxobj, cookie);
		}
		
		//-----------------------------------------------------------------------------
		
		public Point Margins() { 
				Point pt;
				wxVListBox_GetMargins(wxobj, pt);
				return pt;
			}
			
		public void Margins(Point value) { wxVListBox_SetMargins(wxobj, value); }
		
		public void SetMargins(int x, int y)
		{
			wxVListBox_SetMargins2(wxobj, x, y);
		}
		
		//-----------------------------------------------------------------------------
		
		public Colour SelectionBackground() { return new Colour(wxVListBox_GetSelectionBackground(wxobj), true); }
		public void SelectionBackground(Colour value) { wxVListBox_SetSelectionBackground(wxobj, wxObject.SafePtr(value)); }
		
		//-----------------------------------------------------------------------------
		
		public void Clear()
		{
			wxVListBox_Clear(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool Select(int item)
		{
			return Select(item, true);
		}
		
		public bool Select(int item, bool select)
		{
			return wxVListBox_Select(wxobj, item, select);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool SelectRange(int from, int to)
		{
			return wxVListBox_SelectRange(wxobj, from, to);
		}
		
		//-----------------------------------------------------------------------------
		
		public void Toggle(int item)
		{
			wxVListBox_Toggle(wxobj, item);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool SelectAll()
		{
			return wxVListBox_SelectAll(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool DeselectAll()
		{
			return wxVListBox_DeselectAll(wxobj);
		}
	}
