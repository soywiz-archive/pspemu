//-----------------------------------------------------------------------------
// wxD - ScrolledWindow.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - ScrolledWindow.cs
//
/// The wxScrolledWindow wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: ScrolledWindow.d,v 1.10 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.ScrolledWindow;
public import wx.common;
public import wx.Panel;

		//! \cond EXTERN
		static extern (C) IntPtr wxScrollWnd_ctor(IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) void   wxScrollWnd_PrepareDC(IntPtr self, IntPtr dc);
		static extern (C) void   wxScrollWnd_SetScrollbars(IntPtr self, int pixX, int pixY, int numX, int numY, int x, int y, bool noRefresh);
		static extern (C) void   wxScrollWnd_GetViewStart(IntPtr self, ref int x, ref int y);
		static extern (C) void   wxScrollWnd_GetScrollPixelsPerUnit(IntPtr self, ref int xUnit, ref int yUnit);
		
		static extern (C) void   wxScrollWnd_CalcScrolledPosition(IntPtr self, int x, int y, ref int xx, ref int yy);
		static extern (C) void   wxScrollWnd_CalcUnscrolledPosition(IntPtr self, int x, int y, ref int xx, ref int yy);
		static extern (C) void   wxScrollWnd_GetVirtualSize(IntPtr self, ref int x, ref int y);
		static extern (C) void   wxScrollWnd_Scroll(IntPtr self, int x, int y);
		static extern (C) void   wxScrollWnd_SetScrollRate(IntPtr self, int xstep, int ystep);
		static extern (C) void   wxScrollWnd_SetTargetWindow(IntPtr self, IntPtr window);
		//! \endcond

		//---------------------------------------------------------------------

	alias ScrolledWindow wxScrolledWindow;
	public class ScrolledWindow : Panel
	{
		enum {
			wxScrolledWindowStyle = (wxHSCROLL | wxVSCROLL),
		}
	
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(Window parent, int id /*= wxID_ANY*/, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = wxScrolledWindowStyle, string name = wxPanelNameStr)
		{
			super(wxScrollWnd_ctor(wxObject.SafePtr(parent), id, pos, size, style, name));
			EVT_PAINT(&OnPaint);
		}

		public this(Window parent, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = wxScrolledWindowStyle, string name = wxPanelNameStr)
		{
			this(parent,Window.UniqueID,pos,size,style,name);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void OnDraw(DC dc)
		{
		}

		//---------------------------------------------------------------------

		public override void PrepareDC(DC dc)
		{
			wxScrollWnd_PrepareDC(wxobj, dc.wxobj);
		}

		//---------------------------------------------------------------------

		public void SetScrollbars(int pixelsPerUnitX, int pixelsPerUnitY, int noUnitsX, int noUnitsY)
		{ 
			SetScrollbars(pixelsPerUnitY, pixelsPerUnitY, noUnitsY, noUnitsY, 0, 0, false); 
		}
		
		public void SetScrollbars(int pixelsPerUnitX, int pixelsPerUnitY, int noUnitsX, int noUnitsY, int x, int y)
		{ 
			SetScrollbars(pixelsPerUnitY, pixelsPerUnitY, noUnitsY, noUnitsY, x, y, false); 
		}
		
		public void SetScrollbars(int pixelsPerUnitX, int pixelsPerUnitY, int noUnitsX, int noUnitsY, int x, int y, bool noRefresh)
		{
			wxScrollWnd_SetScrollbars(wxobj, pixelsPerUnitX, pixelsPerUnitY, noUnitsX, noUnitsY, x, y, noRefresh);
		}

		//---------------------------------------------------------------------

		private void OnPaint(Object sender, Event e)
		{
			PaintDC dc = new PaintDC(this);
			PrepareDC(dc);
			OnDraw(dc);
			dc.Dispose();
		}

		//---------------------------------------------------------------------

		public Point ViewStart()
		{
			Point pt;
			GetViewStart(pt.X, pt.Y);
			return pt;
		}

		public void GetViewStart(ref int x, ref int y)
		{
			wxScrollWnd_GetViewStart(wxobj, x, y);
		}

		//---------------------------------------------------------------------

		public void GetScrollPixelsPerUnit(ref int xUnit, ref int yUnit)
		{
			wxScrollWnd_GetScrollPixelsPerUnit(wxobj, xUnit, yUnit);
		}
		
		//---------------------------------------------------------------------
		
		public void CalcScrolledPosition(int x, int y, ref int xx, ref int yy)
		{
			wxScrollWnd_CalcScrolledPosition(wxobj, x, y, xx, yy);
		}
		
		//---------------------------------------------------------------------
		
		public void CalcUnscrolledPosition(int x, int y, ref int xx, ref int yy)
		{
			wxScrollWnd_CalcUnscrolledPosition(wxobj, x, y, xx, yy);
		}
		
		//---------------------------------------------------------------------
		
		public void GetVirtualSize(ref int x, ref int y)
		{
			wxScrollWnd_GetVirtualSize(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------
		
		public void Scroll(int x, int y)
		{
			wxScrollWnd_Scroll(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------
		
		public void SetScrollRate(int xstep, int ystep)
		{
			wxScrollWnd_SetScrollRate(wxobj, xstep, ystep);
		}
		
		//---------------------------------------------------------------------
		
		public void TargetWindow(Window value) { wxScrollWnd_SetTargetWindow(wxobj, wxObject.SafePtr(value)); }
	}
