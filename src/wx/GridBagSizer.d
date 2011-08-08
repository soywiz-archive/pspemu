//-----------------------------------------------------------------------------
// wxD - GridBadSizer.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - gbsizer.h
//
/// The wxGridBagSizer wrapper classes
//
// Licensed under the wxWidgets license, see LICENSE.txt for details.
// $Id: GridBagSizer.d,v 1.11 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.GridBagSizer;
public import wx.common;
public import wx.SizerItem;
public import wx.FlexGridSizer;

//version(LDC) { pragma(ldc, "verbose") }

		//! \cond EXTERN
        static extern (C) IntPtr wxGBSizerItem_ctor(int width, int height, IntPtr pos, IntPtr span, int flag, int border, IntPtr userData);
        static extern (C) IntPtr wxGBSizerItem_ctorWindow(IntPtr window, IntPtr pos, IntPtr span, int flag, int border, IntPtr userData);
        static extern (C) IntPtr wxGBSizerItem_ctorSizer(IntPtr sizer, IntPtr pos, IntPtr span, int flag, int border, IntPtr userData);
        static extern (C) IntPtr wxGBSizerItem_ctorDefault();

        static extern (C) IntPtr wxGBSizerItem_GetPos(IntPtr self);

        static extern (C) IntPtr wxGBSizerItem_GetSpan(IntPtr self);
        //static extern (C) void   wxGBSizerItem_GetSpan(IntPtr self, IntPtr rowspan, IntPtr colspan);

        static extern (C) bool   wxGBSizerItem_SetPos(IntPtr self, IntPtr pos);
        static extern (C) bool   wxGBSizerItem_SetSpan(IntPtr self, IntPtr span);

        static extern (C) bool   wxGBSizerItem_IntersectsSizer(IntPtr self, IntPtr other);
        static extern (C) bool   wxGBSizerItem_IntersectsSpan(IntPtr self, IntPtr pos, IntPtr span);

        static extern (C) void   wxGBSizerItem_GetEndPos(IntPtr self, ref int row, ref int col);
        static extern (C) IntPtr wxGBSizerItem_GetGBSizer(IntPtr self);
        static extern (C) void   wxGBSizerItem_SetGBSizer(IntPtr self, IntPtr sizer);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias GBSizerItem wxGBSizerItem;
    public class GBSizerItem : SizerItem
    {
        public this(int width, int height, GBPosition pos, GBSpan span, int flag, int border, wxObject userData)
            { this(wxGBSizerItem_ctor(width, height, wxObject.SafePtr(pos), wxObject.SafePtr(span), flag, border, wxObject.SafePtr(userData))); }

        public this(Window window, GBPosition pos, GBSpan span, int flag, int border, wxObject userData)
            { this(wxGBSizerItem_ctorWindow(wxObject.SafePtr(window), wxObject.SafePtr(pos), wxObject.SafePtr(span), flag, border, wxObject.SafePtr(userData))); }

        public this(Sizer sizer, GBPosition pos, GBSpan span, int flag, int border, wxObject userData)
            { this(wxGBSizerItem_ctorSizer(wxObject.SafePtr(sizer), wxObject.SafePtr(pos), wxObject.SafePtr(span), flag, border, wxObject.SafePtr(userData))); }

        public this()
            { this(wxGBSizerItem_ctorDefault()); }

        public this(IntPtr wxobj) 
            { super(wxobj); }

        //-----------------------------------------------------------------------------

        public GBPosition Pos() { return cast(GBPosition)FindObject(wxGBSizerItem_GetPos(wxobj), &GBPosition.New); }
        public void Pos(GBPosition value) { wxGBSizerItem_SetPos(wxobj, wxObject.SafePtr(value)); }

        //-----------------------------------------------------------------------------

        public GBSpan Span() { return cast(GBSpan)FindObject(wxGBSizerItem_GetSpan(wxobj), &GBSpan.New); }
        public void Span(GBSpan value) { wxGBSizerItem_SetSpan(wxobj, wxObject.SafePtr(value)); }

        //-----------------------------------------------------------------------------

        public bool Intersects(GBSizerItem other)
        {
            return wxGBSizerItem_IntersectsSizer(wxobj, wxObject.SafePtr(other));
        }

        public bool Intersects(GBPosition pos, GBSpan span)
        {
            return wxGBSizerItem_IntersectsSpan(wxobj, wxObject.SafePtr(pos), wxObject.SafePtr(span));
        }

        //-----------------------------------------------------------------------------

        public void GetEndPos(ref int row, ref int col)
        {
            wxGBSizerItem_GetEndPos(wxobj, row, col);
        }

        //-----------------------------------------------------------------------------

        public GridBagSizer GBSizer() { return cast(GridBagSizer)FindObject(wxGBSizerItem_GetGBSizer(wxobj), &GridBagSizer.New); }
        public void GBSizer(GridBagSizer value) { wxGBSizerItem_SetGBSizer(wxobj, wxObject.SafePtr(value)); }

	public static wxObject New(IntPtr ptr) { return new GBSizerItem(ptr); }
    }

		//! \cond EXTERN
        static extern (C) IntPtr wxGBSpan_ctorDefault();
        static extern (C) IntPtr wxGBSpan_ctor(int rowspan, int colspan);

        static extern (C) void   wxGBSpan_SetRowspan(IntPtr self, int rowspan);
        static extern (C) int    wxGBSpan_GetRowspan(IntPtr self);
        static extern (C) int    wxGBSpan_GetColspan(IntPtr self);
        static extern (C) void   wxGBSpan_SetColspan(IntPtr self, int colspan);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias GBSpan wxGBSpan;
    public class GBSpan : wxObject
    {
        public this()
            { super(wxGBSpan_ctorDefault()); }

        public this(int rowspan, int colspan)
            { super(wxGBSpan_ctor(rowspan, colspan)); }

        private this(IntPtr ptr)
            { super(ptr); }
	public static wxObject New(IntPtr ptr) { return new GBSpan(ptr); }

        //-----------------------------------------------------------------------------

        public int Rowspan() { return wxGBSpan_GetRowspan(wxobj); }
        public void Rowspan(int value) { wxGBSpan_SetRowspan(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int Colspan() { return wxGBSpan_GetColspan(wxobj); }
        public void Colspan(int value) { wxGBSpan_SetColspan(wxobj, value); }
    }

		//! \cond EXTERN
        static extern (C) IntPtr wxGridBagSizer_ctor(int vgap, int hgap);
        static extern (C) bool   wxGridBagSizer_AddWindow(IntPtr self, IntPtr window, IntPtr pos, IntPtr span, int flag, int border, IntPtr userData);
        static extern (C) bool   wxGridBagSizer_AddSizer(IntPtr self, IntPtr sizer, IntPtr pos, IntPtr span, int flag, int border, IntPtr userData);
        static extern (C) bool   wxGridBagSizer_Add(IntPtr self, int width, int height, IntPtr pos, IntPtr span, int flag, int border, IntPtr userData);
        static extern (C) bool   wxGridBagSizer_AddItem(IntPtr self, IntPtr item);

        static extern (C) void   wxGridBagSizer_GetEmptyCellSize(IntPtr self, ref Size size);
        static extern (C) void   wxGridBagSizer_SetEmptyCellSize(IntPtr self, ref Size sz);
        static extern (C) void   wxGridBagSizer_GetCellSize(IntPtr self, int row, int col, ref Size size);

        static extern (C) IntPtr wxGridBagSizer_GetItemPositionWindow(IntPtr self, IntPtr window);
        static extern (C) IntPtr wxGridBagSizer_GetItemPositionSizer(IntPtr self, IntPtr sizer);
        static extern (C) IntPtr wxGridBagSizer_GetItemPositionIndex(IntPtr self, int index);
        static extern (C) bool   wxGridBagSizer_SetItemPositionWindow(IntPtr self, IntPtr window, IntPtr pos);
        static extern (C) bool   wxGridBagSizer_SetItemPositionSizer(IntPtr self, IntPtr sizer, IntPtr pos);
        static extern (C) bool   wxGridBagSizer_SetItemPositionIndex(IntPtr self, int index, IntPtr pos);

        static extern (C) IntPtr wxGridBagSizer_GetItemSpanWindow(IntPtr self, IntPtr window);
        static extern (C) IntPtr wxGridBagSizer_GetItemSpanSizer(IntPtr self, IntPtr sizer);
        static extern (C) IntPtr wxGridBagSizer_GetItemSpanIndex(IntPtr self, int index);
        static extern (C) bool   wxGridBagSizer_SetItemSpanWindow(IntPtr self, IntPtr window, IntPtr span);
        static extern (C) bool   wxGridBagSizer_SetItemSpanSizer(IntPtr self, IntPtr sizer, IntPtr span);
        static extern (C) bool   wxGridBagSizer_SetItemSpanIndex(IntPtr self, int index, IntPtr span);

        static extern (C) IntPtr wxGridBagSizer_FindItemWindow(IntPtr self, IntPtr window);
        static extern (C) IntPtr wxGridBagSizer_FindItemSizer(IntPtr self, IntPtr sizer);
        static extern (C) IntPtr wxGridBagSizer_FindItemAtPosition(IntPtr self, IntPtr pos);
        static extern (C) IntPtr wxGridBagSizer_FindItemAtPoint(IntPtr self, ref Point pt);
        static extern (C) IntPtr wxGridBagSizer_FindItemWithData(IntPtr self, IntPtr userData);

        static extern (C) bool   wxGridBagSizer_CheckForIntersectionItem(IntPtr self, IntPtr item, IntPtr excludeItem);
        static extern (C) bool   wxGridBagSizer_CheckForIntersectionPos(IntPtr self, IntPtr pos, IntPtr span, IntPtr excludeItem);
		//! \endcond

    alias GridBagSizer wxGridBagSizer;
    public class GridBagSizer : FlexGridSizer
    {
        //-----------------------------------------------------------------------------

        public this(int vgap, int hgap)
            { super(wxGridBagSizer_ctor(vgap, hgap)); }

	private this(IntPtr ptr)
	    { super(ptr); }
	public static wxObject New(IntPtr ptr) { return new GridBagSizer(ptr); }

        //-----------------------------------------------------------------------------

        public bool Add(Window window, GBPosition pos, GBSpan span, int flag, int border, wxObject userData)
        {
            return wxGridBagSizer_AddWindow(wxobj, wxObject.SafePtr(window), wxObject.SafePtr(pos), wxObject.SafePtr(span), flag, border, wxObject.SafePtr(userData));
        }

        public bool Add(Sizer sizer, GBPosition pos, GBSpan span, int flag, int border, wxObject userData)
        {
            return wxGridBagSizer_AddSizer(wxobj, wxObject.SafePtr(sizer), wxObject.SafePtr(pos), wxObject.SafePtr(span), flag, border, wxObject.SafePtr(userData));
        }

        public bool Add(int width, int height, GBPosition pos, GBSpan span, int flag, int border, wxObject userData)
        {
            return wxGridBagSizer_Add(wxobj, width, height, wxObject.SafePtr(pos), wxObject.SafePtr(span), flag, border, wxObject.SafePtr(userData));
        }

        public bool Add(GBSizerItem item)
        {
            return wxGridBagSizer_AddItem(wxobj, wxObject.SafePtr(item));
        }

        //-----------------------------------------------------------------------------

        public Size EmptyCellSize() { 
                Size size;
                wxGridBagSizer_GetEmptyCellSize(wxobj, size);
                return size;
            }
        public void EmptyCellSize(Size value) { wxGridBagSizer_SetEmptyCellSize(wxobj, value); }

        //-----------------------------------------------------------------------------

        public Size GetCellSize(int row, int col)
        {
            Size size;
            wxGridBagSizer_GetCellSize(wxobj, row, col, size);
            return size;
        }

        //-----------------------------------------------------------------------------

        public GBPosition GetItemPosition(Window window)
        {
            return cast(GBPosition)FindObject(wxGridBagSizer_GetItemPositionWindow(wxobj, wxObject.SafePtr(window)), &GBPosition.New);
        }

        public GBPosition GetItemPosition(Sizer sizer)
        {
            return cast(GBPosition)FindObject(wxGridBagSizer_GetItemPositionSizer(wxobj, wxObject.SafePtr(sizer)), &GBPosition.New);
        }

        public GBPosition GetItemPosition(int index)
        {
            return cast(GBPosition)FindObject(wxGridBagSizer_GetItemPositionIndex(wxobj, index), &GBPosition.New);
        }

        //-----------------------------------------------------------------------------

        public bool SetItemPosition(Window window, GBPosition pos)
        {
            return wxGridBagSizer_SetItemPositionWindow(wxobj, wxObject.SafePtr(window), wxObject.SafePtr(pos));
        }

        public bool SetItemPosition(Sizer sizer, GBPosition pos)
        {
            return wxGridBagSizer_SetItemPositionSizer(wxobj, wxObject.SafePtr(sizer), wxObject.SafePtr(pos));
        }

        public bool SetItemPosition(int index, GBPosition pos)
        {
            return wxGridBagSizer_SetItemPositionIndex(wxobj, index, wxObject.SafePtr(pos));
        }

        //-----------------------------------------------------------------------------

        public GBSpan GetItemSpan(Window window)
        {
            return cast(GBSpan)FindObject(wxGridBagSizer_GetItemSpanWindow(wxobj, wxObject.SafePtr(window)), &GBSpan.New);
        }

        public GBSpan GetItemSpan(Sizer sizer)
        {
            return cast(GBSpan)FindObject(wxGridBagSizer_GetItemSpanSizer(wxobj, wxObject.SafePtr(sizer)), &GBSpan.New);
        }

        public GBSpan GetItemSpan(int index)
        {
            return cast(GBSpan)FindObject(wxGridBagSizer_GetItemSpanIndex(wxobj, index), &GBSpan.New);
        }

        //-----------------------------------------------------------------------------

        public bool SetItemSpan(Window window, GBSpan span)
        {
            return wxGridBagSizer_SetItemSpanWindow(wxobj, wxObject.SafePtr(window), wxObject.SafePtr(span));
        }

        public bool SetItemSpan(Sizer sizer, GBSpan span)
        {
            return wxGridBagSizer_SetItemSpanSizer(wxobj, wxObject.SafePtr(sizer), wxObject.SafePtr(span));
        }

        public bool SetItemSpan(int index, GBSpan span)
        {
            return wxGridBagSizer_SetItemSpanIndex(wxobj, index, wxObject.SafePtr(span));
        }

        //-----------------------------------------------------------------------------

        public GBSizerItem FindItem(Window window)
        {
            return cast(GBSizerItem)FindObject(wxGridBagSizer_FindItemWindow(wxobj, wxObject.SafePtr(window)), &GBSizerItem.New);
        }

        public GBSizerItem FindItem(Sizer sizer)
        {
            return cast(GBSizerItem)FindObject(wxGridBagSizer_FindItemSizer(wxobj, wxObject.SafePtr(sizer)), &GBSizerItem.New);
        }

        public GBSizerItem FindItemAtPosition(GBPosition pos)
        {
            return cast(GBSizerItem)FindObject(wxGridBagSizer_FindItemAtPosition(wxobj, wxObject.SafePtr(pos)), &GBSizerItem.New);
        }

        public GBSizerItem FindItemAtPoint(Point pt)
        {
            return cast(GBSizerItem)FindObject(wxGridBagSizer_FindItemAtPoint(wxobj, pt), &GBSizerItem.New);
        }

        public GBSizerItem FindItemWithData(wxObject userData)
        {
            return cast(GBSizerItem)FindObject(wxGridBagSizer_FindItemWithData(wxobj, wxObject.SafePtr(userData)), &GBSizerItem.New);
        }

        //-----------------------------------------------------------------------------

        public bool CheckForIntersection(GBSizerItem item, GBSizerItem excludeItem)
        {
            return wxGridBagSizer_CheckForIntersectionItem(wxobj, wxObject.SafePtr(item), wxObject.SafePtr(excludeItem));
        }

        public bool CheckForIntersection(GBPosition pos, GBSpan span, GBSizerItem excludeItem)
        {
            return wxGridBagSizer_CheckForIntersectionPos(wxobj, wxObject.SafePtr(pos), wxObject.SafePtr(span), wxObject.SafePtr(excludeItem));
        }

    }

		//! \cond EXTERN
        static extern (C) IntPtr wxGBPosition_ctor();
        static extern (C) IntPtr wxGBPosition_ctorPos(int row, int col);
        static extern (C) int    wxGBPosition_GetRow(IntPtr self);
        static extern (C) int    wxGBPosition_GetCol(IntPtr self);
        static extern (C) void   wxGBPosition_SetRow(IntPtr self, int row);
        static extern (C) void   wxGBPosition_SetCol(IntPtr self, int col);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias GBPosition wxGBPosition;
    public class GBPosition : wxObject
    {
	private this(IntPtr ptr)
	    { super(ptr); }

        public this()
            { super(wxGBPosition_ctor()); }

        //-----------------------------------------------------------------------------

        //public this(int row, int col)
        //    { super(wxGBPosition_ctorPos(row, col)); }

        //-----------------------------------------------------------------------------

        public int GetRow()
        {
            return wxGBPosition_GetRow(wxobj);
        }

        //-----------------------------------------------------------------------------

        public int GetCol()
        {
            return wxGBPosition_GetCol(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void SetRow(int row)
        {
            wxGBPosition_SetRow(wxobj, row);
        }

        //-----------------------------------------------------------------------------

        public void SetCol(int col)
        {
            wxGBPosition_SetCol(wxobj, col);
        }

	public static wxObject New(IntPtr ptr) { return new GBPosition(ptr); }
    }

