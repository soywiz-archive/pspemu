//-----------------------------------------------------------------------------
// wxD - HtmlListBox.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - HtmlListBox.cs
//
/// The wxHtmlListBox wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: HtmlListBox.d,v 1.12 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.HtmlListBox;
public import wx.common;
public import wx.VLBox;

		//-----------------------------------------------------------------------------
		
		//! \cond EXTERN
		extern (C) {
		alias void function(HtmlListBox obj) Virtual_VoidNoParams;
		alias void function(HtmlListBox obj, int n) Virtual_VoidSizeT;
		alias string function(HtmlListBox obj, int n) Virtual_wxStringSizeT;
		alias IntPtr function(HtmlListBox obj, IntPtr colour) Virtual_wxColourwxColour;
		alias void function(HtmlListBox obj, IntPtr dc, ref Rectangle rect, int n) Virtual_OnDrawItem;
		alias int function(HtmlListBox obj, int n) Virtual_OnMeasureItem;
		}

		static extern (C) IntPtr wxHtmlListBox_ctor2(IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) void wxHtmlListBox_RegisterVirtual(IntPtr self,HtmlListBox obj,
			Virtual_VoidNoParams refreshAll,
			Virtual_VoidSizeT setItemCount,
			Virtual_wxStringSizeT onGetItem,
			Virtual_wxStringSizeT onGetItemMarkup,
			Virtual_wxColourwxColour getSelectedTextColour,
			Virtual_wxColourwxColour getSelectedTextBgColour,
			Virtual_OnDrawItem onDrawItem,
			Virtual_OnMeasureItem onMeasureItem,
			Virtual_OnDrawItem onDrawSeparator,
			Virtual_OnDrawItem onDrawBackground,
			Virtual_OnMeasureItem onGetLineHeight);
		static extern (C) bool wxHtmlListBox_Create(IntPtr self, IntPtr parent, int id, ref Point pos, ref Size size, int style, string name);
		static extern (C) void wxHtmlListBox_RefreshAll(IntPtr self);
		static extern (C) void wxHtmlListBox_SetItemCount(IntPtr self, int count);
		static extern (C) IntPtr wxHtmlListBox_OnGetItemMarkup(IntPtr self, int n);
		static extern (C) IntPtr wxHtmlListBox_GetSelectedTextColour(IntPtr self, IntPtr colFg);
		static extern (C) IntPtr wxHtmlListBox_GetSelectedTextBgColour(IntPtr self, IntPtr colBg);
		static extern (C) void wxHtmlListBox_OnDrawItem(IntPtr self, IntPtr dc, ref Rectangle rect, int n);
		static extern (C) int wxHtmlListBox_OnMeasureItem(IntPtr self, int n);
		static extern (C) void wxHtmlListBox_OnSize(IntPtr self, IntPtr evt);
		static extern (C) void wxHtmlListBox_Init(IntPtr self);
		static extern (C) void wxHtmlListBox_CacheItem(IntPtr self, int n);
		
		static extern (C) void wxHtmlListBox_OnDrawSeparator(IntPtr self, IntPtr dc, ref Rectangle rect, int n);
		static extern (C) void wxHtmlListBox_OnDrawBackground(IntPtr self, IntPtr dc, ref Rectangle rect, int n);
		static extern (C) int wxHtmlListBox_OnGetLineHeight(IntPtr self, int line);		
		//! \endcond
		
		//-----------------------------------------------------------------------------
		
	public abstract class HtmlListBox : VListBox
	{
		public this(IntPtr wxobj)
			{ super(wxobj); }
            
		public this()
			{ this(null, Window.UniqueID, wxDefaultPosition, wxDefaultSize, 0, "");}
			
		public this(Window parent, int id /*= wxID_ANY*/, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name=wxVListBoxNameStr)
		{
			this(wxHtmlListBox_ctor2(wxObject.SafePtr(parent), id, pos, size, style, name));

			wxHtmlListBox_RegisterVirtual(wxobj, this,
				&staticRefreshAll,
				&staticSetItemCount,
				&staticOnGetItem,
				&staticOnGetItemMarkup,
				&staticDoGetSelectedTextColour,
				&staticDoGetSelectedTextBgColour,
				&staticDoOnDrawItem,
				&staticOnMeasureItem,
				&staticDoOnDrawSeparator,
				&staticDoOnDrawBackground,
				&staticOnGetLineHeight);   
		}
		
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, string name=wxVListBoxNameStr)
			{ this(parent, Window.UniqueID, pos, size, style, name);}
		
		//-----------------------------------------------------------------------------
		
		public override bool Create(Window parent, int id, ref Point pos, ref Size size, int style, string name)
		{
			return wxHtmlListBox_Create(wxobj, wxObject.SafePtr(parent), id, pos, size, style, name);
		}
		
		//-----------------------------------------------------------------------------
		
		static extern(C) private void staticRefreshAll(HtmlListBox obj)
		{
			return obj.RefreshAll();
		}
		public override void RefreshAll()
		{
			wxHtmlListBox_RefreshAll(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		static extern(C) private void staticSetItemCount(HtmlListBox obj,int count)
		{
			obj.SetItemCount(count);
		}
		public /+virtual+/ void SetItemCount(int count)
		{
			wxHtmlListBox_SetItemCount(wxobj, count);
		}
		
		//-----------------------------------------------------------------------------
		
		static extern(C) private string staticOnGetItem(HtmlListBox obj,int n)
		{
			return obj.OnGetItem(n);
		}
		protected abstract string OnGetItem(int n);
		
		//-----------------------------------------------------------------------------
		
		static extern(C) private string staticOnGetItemMarkup(HtmlListBox obj,int n)
		{
			return obj.OnGetItem(n);
		}
		protected /+virtual+/ string OnGetItemMarkup(int n)
		{
			return cast(string) new wxString(wxHtmlListBox_OnGetItemMarkup(wxobj, n), true);
		}
		
		//-----------------------------------------------------------------------------
		
		static extern(C) private IntPtr staticDoGetSelectedTextColour(HtmlListBox obj,IntPtr colFg)
		{
			return wxObject.SafePtr(obj.GetSelectedTextColour(cast(Colour)FindObject(colFg, &Colour.New)));
		}
		
		protected /+virtual+/ Colour GetSelectedTextColour(Colour colFg)
		{
			return new Colour(wxHtmlListBox_GetSelectedTextColour(wxobj, wxObject.SafePtr(colFg)), true);
		}
		
		//-----------------------------------------------------------------------------
		
		static extern(C) private IntPtr staticDoGetSelectedTextBgColour(HtmlListBox obj, IntPtr colBg)
		{
			return wxObject.SafePtr(obj.GetSelectedTextBgColour(cast(Colour)FindObject(colBg, &Colour.New)));
		}
		
		protected /+virtual+/ Colour GetSelectedTextBgColour(Colour colBg)
		{
			return new Colour(wxHtmlListBox_GetSelectedTextBgColour(wxobj, wxObject.SafePtr(colBg)), true);
		}		
		
		//-----------------------------------------------------------------------------
		
		static extern(C) private void staticDoOnDrawItem(HtmlListBox obj, IntPtr dc, ref Rectangle rect, int n)
		{
			obj.OnDrawItem(cast(DC)FindObject(dc, &DC.New), rect, n);
		}
		
		protected override void OnDrawItem(DC dc, Rectangle rect, int n)
		{
			wxHtmlListBox_OnDrawItem(wxobj, wxObject.SafePtr(dc), rect, n);
		}
		
		//-----------------------------------------------------------------------------
		
		static extern(C) private int staticOnMeasureItem(HtmlListBox obj, int n)
		{
			return obj.OnMeasureItem(n);
		}
		protected override int OnMeasureItem(int n)
		{
			return wxHtmlListBox_OnMeasureItem(wxobj, n);
		}
		
		//-----------------------------------------------------------------------------
		
		protected void OnSize(SizeEvent evt)
		{
			wxHtmlListBox_OnSize(wxobj, wxObject.SafePtr(evt));
		}
		
		//-----------------------------------------------------------------------------
		
		protected void Init()
		{
			wxHtmlListBox_Init(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		protected void CacheItem(int n)
		{
			wxHtmlListBox_CacheItem(wxobj, n);
		}
		
		//-----------------------------------------------------------------------------
		
		protected override void OnDrawSeparator(DC dc, Rectangle rect, int n)
		{
			wxHtmlListBox_OnDrawSeparator(wxobj, wxObject.SafePtr(dc), rect, n);
		}
		
		static extern(C) private void staticDoOnDrawSeparator(HtmlListBox obj,IntPtr dc, ref Rectangle rect, int n)
		{
			obj.OnDrawSeparator(cast(DC)FindObject(dc, &DC.New), rect, n);
		}
		
		//-----------------------------------------------------------------------------
		
		protected override void OnDrawBackground(DC dc, Rectangle rect, int n)
		{
			wxHtmlListBox_OnDrawBackground(wxobj, wxObject.SafePtr(dc), rect, n);
		}
		
		static extern(C) private void staticDoOnDrawBackground(HtmlListBox obj,IntPtr dc, ref Rectangle rect, int n)
		{
			obj.OnDrawBackground(cast(DC)FindObject(dc, &DC.New), rect, n);
		}
		
		//-----------------------------------------------------------------------------
		
		protected override int OnGetLineHeight(int line)
		{
			return wxHtmlListBox_OnGetLineHeight(wxobj, line);
		}
		static extern(C) private int staticOnGetLineHeight(HtmlListBox obj, int line)
		{
			return obj.OnGetLineHeight(line);
		}
		
	}
