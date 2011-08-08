//-----------------------------------------------------------------------------
// wxD - SashWindow.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - SashWindow.cs
//
/// The wxSashWindow wrapper classes.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: SashWindow.d,v 1.10 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.SashWindow;
public import wx.common;
public import wx.Window;
public import wx.CommandEvent;

	public enum SashEdgePosition 
	{
		wxSASH_TOP = 0,
		wxSASH_RIGHT,
		wxSASH_BOTTOM,
		wxSASH_LEFT,
		wxSASH_NONE = 100
	}
	
	//-----------------------------------------------------------------------------
	
	public enum SashDragStatus
	{
		wxSASH_STATUS_OK,
		wxSASH_STATUS_OUT_OF_RANGE
	}
		
	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxSashEdge_ctor();
		static extern (C) void wxSashEdge_dtor(IntPtr self);
		static extern (C) bool wxSashEdge_m_show(IntPtr self);
		static extern (C) bool wxSashEdge_m_border(IntPtr self);
		static extern (C) int wxSashEdge_m_margin(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------
	
	alias SashEdge wxSashEdge;
	public class SashEdge : wxObject
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
			{ this(wxSashEdge_ctor(), true);}
			
		//---------------------------------------------------------------------
				
		override protected void dtor() { wxSashEdge_dtor(wxobj); }
			
		//-----------------------------------------------------------------------------
		
		public bool m_show() { return wxSashEdge_m_show(wxobj); }
		
		//-----------------------------------------------------------------------------
		
		public bool m_border() { return wxSashEdge_m_border(wxobj); }
		
		//-----------------------------------------------------------------------------
		
		public int m_margin() { return wxSashEdge_m_margin(wxobj); }
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxSashWindow_ctor();
		static extern (C) bool wxSashWindow_Create(IntPtr self, IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) void wxSashWindow_SetSashVisible(IntPtr self, SashEdgePosition edge, bool sash);
		static extern (C) bool wxSashWindow_GetSashVisible(IntPtr self, SashEdgePosition edge);
		static extern (C) void wxSashWindow_SetSashBorder(IntPtr self, SashEdgePosition edge, bool border);
		static extern (C) bool wxSashWindow_HasBorder(IntPtr self, SashEdgePosition edge);
		static extern (C) int wxSashWindow_GetEdgeMargin(IntPtr self, SashEdgePosition edge);
		static extern (C) void wxSashWindow_SetDefaultBorderSize(IntPtr self, int width);
		static extern (C) int wxSashWindow_GetDefaultBorderSize(IntPtr self);
		static extern (C) void wxSashWindow_SetExtraBorderSize(IntPtr self, int width);
		static extern (C) int wxSashWindow_GetExtraBorderSize(IntPtr self);
		static extern (C) void wxSashWindow_SetMinimumSizeX(IntPtr self, int min);
		static extern (C) void wxSashWindow_SetMinimumSizeY(IntPtr self, int min);
		static extern (C) int wxSashWindow_GetMinimumSizeX(IntPtr self);
		static extern (C) int wxSashWindow_GetMinimumSizeY(IntPtr self);
		static extern (C) void wxSashWindow_SetMaximumSizeX(IntPtr self, int max);
		static extern (C) void wxSashWindow_SetMaximumSizeY(IntPtr self, int max);
		static extern (C) int wxSashWindow_GetMaximumSizeX(IntPtr self);
		static extern (C) int wxSashWindow_GetMaximumSizeY(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------
		
	alias SashWindow wxSashWindow;
	public class SashWindow : Window
	{
		enum {
			wxSW_NOBORDER	= 0x0000,
			wxSW_BORDER	= 0x0020,
			wxSW_3DSASH	= 0x0040,
			wxSW_3DBORDER	= 0x0080,
			wxSW_3D	= wxSW_3DSASH | wxSW_3DBORDER,
		}
		enum {
			wxSASH_DRAG_NONE	= 0,
			wxSASH_DRAG_DRAGGING	= 1,
			wxSASH_DRAG_LEFT_DOWN	= 2,
		}

		//-----------------------------------------------------------------------------
	
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this()
			{ super(wxSashWindow_ctor());}
			
		public this(Window parent, int id /*= wxID_ANY*/, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=wxSW_3D|wxCLIP_CHILDREN, string name="sashWindow")
		{
			super(wxSashWindow_ctor());
			if (!Create(parent, id, pos, size, style, name)) 
			{
				throw new InvalidOperationException("Failed to create SashWindow");
			}
		}
		
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=wxSW_3D|wxCLIP_CHILDREN, string name="sashWindow")
			{ this(parent, Window.UniqueID, pos, size, style, name);}
		
		//-----------------------------------------------------------------------------
		
		public bool Create(Window parent, int id, ref Point pos, ref Size size, int style, string name)
		{
			return wxSashWindow_Create(wxobj, wxObject.SafePtr(parent), id, pos, size, style, name);
		}
		
		//-----------------------------------------------------------------------------
		
		public void SetSashVisible(SashEdgePosition edge, bool sash)
		{
			wxSashWindow_SetSashVisible(wxobj, edge, sash);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool GetSashVisible(SashEdgePosition edge)
		{
			return wxSashWindow_GetSashVisible(wxobj, edge);
		}
		
		//-----------------------------------------------------------------------------
		
		public void SetSashBorder(SashEdgePosition edge, bool border)
		{
			wxSashWindow_SetSashBorder(wxobj, edge, border);
		}
		
		//-----------------------------------------------------------------------------
		
		public int GetEdgeMargin(SashEdgePosition edge)
		{
			return wxSashWindow_GetEdgeMargin(wxobj, edge);
		}
		
		//-----------------------------------------------------------------------------
		
		public int DefaultBorderSize() { return wxSashWindow_GetDefaultBorderSize(wxobj); }
		public void DefaultBorderSize(int value) { wxSashWindow_SetDefaultBorderSize(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public int ExtraBorderSize() { return wxSashWindow_GetExtraBorderSize(wxobj); }
		public void ExtraBorderSize(int value) { wxSashWindow_SetExtraBorderSize(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public int MinimumSizeX() { return wxSashWindow_GetMinimumSizeX(wxobj); }
		public void MinimumSizeX(int value) { wxSashWindow_SetMinimumSizeX(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public int MinimumSizeY() { return wxSashWindow_GetMinimumSizeY(wxobj); }
		public void MinimumSizeY(int value) { wxSashWindow_SetMinimumSizeY(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public int MaximumSizeX() { return wxSashWindow_GetMaximumSizeX(wxobj); }
		public void MaximumSizeX(int value) { wxSashWindow_SetMaximumSizeX(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public int MaximumSizeY() { return wxSashWindow_GetMaximumSizeY(wxobj); }
		public void MaximumSizeY(int value) { wxSashWindow_SetMaximumSizeY(wxobj, value); }
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxSashEvent_ctor(int id, SashEdgePosition edge);
		static extern (C) void wxSashEvent_SetEdge(IntPtr self, SashEdgePosition edge);
		static extern (C) SashEdgePosition wxSashEvent_GetEdge(IntPtr self);
		static extern (C) void wxSashEvent_SetDragRect(IntPtr self, ref Rectangle rect);
		static extern (C) void wxSashEvent_GetDragRect(IntPtr self, out Rectangle rect);
		static extern (C) void wxSashEvent_SetDragStatus(IntPtr self, SashDragStatus status);
		static extern (C) SashDragStatus wxSashEvent_GetDragStatus(IntPtr self);
		//! \endcond
	
	alias SashEvent wxSashEvent;
	public class SashEvent : CommandEvent
	{
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this()
			{ this(0, SashEdgePosition.wxSASH_NONE);}
			
		public this(int id)
			{ this(id, SashEdgePosition.wxSASH_NONE);}
			
		public this(int id, SashEdgePosition edge)
			{ super(wxSashEvent_ctor(id, edge));}
			
		//-----------------------------------------------------------------------------
		
		public SashEdgePosition Edge() { return wxSashEvent_GetEdge(wxobj); }
		public void Edge(SashEdgePosition value) { wxSashEvent_SetEdge(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public Rectangle DragRect() { 
				Rectangle rect;
				wxSashEvent_GetDragRect(wxobj, rect);
				return rect;
			}
		public void DragRect(Rectangle value) { wxSashEvent_SetDragRect(wxobj, value); }	
		
		//-----------------------------------------------------------------------------
		
		public SashDragStatus DragStatus() { return wxSashEvent_GetDragStatus(wxobj); }
		public void DragStatus(SashDragStatus value) { wxSashEvent_SetDragStatus(wxobj, value); }

		private static Event New(IntPtr obj) { return new SashEvent(obj); }

		static this()
		{
			wxEVT_SASH_DRAGGED = wxEvent_EVT_SASH_DRAGGED();

			AddEventType(wxEVT_SASH_DRAGGED,                    &SashEvent.New);
		}
	}
