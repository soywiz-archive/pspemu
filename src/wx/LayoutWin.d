//-----------------------------------------------------------------------------
// wxD - LayoutWin.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - LayoutWin.cs
//
/// The wxSashLayoutWindow proxy interface.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: LayoutWin.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.LayoutWin;
public import wx.common;
public import wx.SashWindow;
public import wx.Event;
public import wx.Frame;
public import wx.MDI;

	public enum LayoutOrientation
	{
		wxLAYOUT_HORIZONTAL,
		wxLAYOUT_VERTICAL
	}
	
	//-----------------------------------------------------------------------------

	public enum LayoutAlignment
	{
		wxLAYOUT_NONE,
		wxLAYOUT_TOP,
		wxLAYOUT_LEFT,
		wxLAYOUT_RIGHT,
		wxLAYOUT_BOTTOM
	}
	
	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxSashLayoutWindow_ctor();
		static extern (C) bool wxSashLayoutWindow_Create(IntPtr self, IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) LayoutAlignment wxSashLayoutWindow_GetAlignment(IntPtr self);
		static extern (C) LayoutOrientation wxSashLayoutWindow_GetOrientation(IntPtr self);
		static extern (C) void wxSashLayoutWindow_SetAlignment(IntPtr self, LayoutAlignment alignment);
		static extern (C) void wxSashLayoutWindow_SetOrientation(IntPtr self, LayoutOrientation orient);
		static extern (C) void wxSashLayoutWindow_SetDefaultSize(IntPtr self, ref Size size);
		//! \endcond
		
		//-----------------------------------------------------------------------------
	
	alias SashLayoutWindow wxSashLayoutWindow;
	public class SashLayoutWindow : SashWindow
	{
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this()
			{ super(wxSashLayoutWindow_ctor());}
			
		public this(Window parent, int id /*= wxID_ANY*/, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style=wxSW_3D|wxCLIP_CHILDREN, string name = "layoutWindow")
		{
			super(wxSashLayoutWindow_ctor());
			if (!Create(parent, id, pos, size, style, name)) 
			{
				throw new InvalidOperationException("Failed to create SashLayoutWindow");
			}
		}
		
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style=wxSW_3D|wxCLIP_CHILDREN, string name = "layoutWindow")
			{ this(parent, Window.UniqueID, pos, size, style, name);}
		
		//-----------------------------------------------------------------------------
		
		public override bool Create(Window parent, int id, ref Point pos, ref Size size, int style, string name)
		{
			return wxSashLayoutWindow_Create(wxobj, wxObject.SafePtr(parent), id, pos, size, cast(uint)style, name);
		}
		
		//-----------------------------------------------------------------------------
		
		public LayoutAlignment Alignment() { return wxSashLayoutWindow_GetAlignment(wxobj); }
		public void Alignment(LayoutAlignment value) { wxSashLayoutWindow_SetAlignment(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public LayoutOrientation Orientation() { return wxSashLayoutWindow_GetOrientation(wxobj); }
		public void Orientation(LayoutOrientation value) { wxSashLayoutWindow_SetOrientation(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public void DefaultSize(Size value) { wxSashLayoutWindow_SetDefaultSize(wxobj, value); }
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxLayoutAlgorithm_ctor();
		static extern (C) bool wxLayoutAlgorithm_LayoutMDIFrame(IntPtr self, IntPtr frame, ref Rectangle rect);
		static extern (C) bool wxLayoutAlgorithm_LayoutFrame(IntPtr self, IntPtr frame, IntPtr mainWindow);
		static extern (C) bool wxLayoutAlgorithm_LayoutWindow(IntPtr self, IntPtr frame, IntPtr mainWindow);
		//! \endcond
		
		//-----------------------------------------------------------------------------
		
	alias LayoutAlgorithm wxLayoutAlgorithm;
	public class LayoutAlgorithm : wxObject
	{
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this()
			{ super(wxLayoutAlgorithm_ctor());}
			
		//-----------------------------------------------------------------------------
		
		public bool LayoutMDIFrame(MDIParentFrame frame)
		{
			// FIXME
			Rectangle dummy;
			return LayoutMDIFrame(frame, dummy);
		}
		
		public bool LayoutMDIFrame(MDIParentFrame frame, Rectangle rect)
		{
			return wxLayoutAlgorithm_LayoutMDIFrame(wxobj, wxObject.SafePtr(frame), rect);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool LayoutFrame(Frame frame)
		{
			return LayoutFrame(frame, null);
		}
		
		public bool LayoutFrame(Frame frame, Window mainWindow)
		{
			return wxLayoutAlgorithm_LayoutFrame(wxobj, wxObject.SafePtr(frame), wxObject.SafePtr(mainWindow));
		}
		
		//-----------------------------------------------------------------------------
		
		public bool LayoutWindow(Window frame)
		{
			return LayoutWindow(frame, null);
		}
		
		public bool LayoutWindow(Window frame, Window mainWindow)
		{
			return wxLayoutAlgorithm_LayoutWindow(wxobj, wxObject.SafePtr(frame), wxObject.SafePtr(mainWindow));
		}
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxQueryLayoutInfoEvent_ctor(int id);
		static extern (C) void wxQueryLayoutInfoEvent_SetRequestedLength(IntPtr self, int length);
		static extern (C) int wxQueryLayoutInfoEvent_GetRequestedLength(IntPtr self);
		static extern (C) void wxQueryLayoutInfoEvent_SetFlags(IntPtr self, int flags);
		static extern (C) int wxQueryLayoutInfoEvent_GetFlags(IntPtr self);
		static extern (C) void wxQueryLayoutInfoEvent_SetSize(IntPtr self, ref Size size);
		static extern (C) void wxQueryLayoutInfoEvent_GetSize(IntPtr self, out Size size);
		static extern (C) void wxQueryLayoutInfoEvent_SetOrientation(IntPtr self, LayoutOrientation orient);
		static extern (C) LayoutOrientation wxQueryLayoutInfoEvent_GetOrientation(IntPtr self);
		static extern (C) void wxQueryLayoutInfoEvent_SetAlignment(IntPtr self, LayoutAlignment alignment);
		static extern (C) LayoutAlignment wxQueryLayoutInfoEvent_GetAlignment(IntPtr self);
		//! \endcond
	
		//-----------------------------------------------------------------------------
		
	alias QueryLayoutInfoEvent wxQueryLayoutInfoEvent;
	public class QueryLayoutInfoEvent : Event
	{
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this()
			{ this(0);}
			
		public this(int id)
			{ super(wxQueryLayoutInfoEvent_ctor(id));}
			
		//-----------------------------------------------------------------------------
		
		public int RequestedLength() { return wxQueryLayoutInfoEvent_GetRequestedLength(wxobj); }
		public void RequestedLength(int value) { wxQueryLayoutInfoEvent_SetRequestedLength(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public int Flags() { return wxQueryLayoutInfoEvent_GetFlags(wxobj); }
		public void Flags(int value) { wxQueryLayoutInfoEvent_SetFlags(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public Size size() {
				Size size;
				wxQueryLayoutInfoEvent_GetSize(wxobj, size);
				return size;
			}
		public void size(Size value) { wxQueryLayoutInfoEvent_SetSize(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public LayoutOrientation Orientation() { return wxQueryLayoutInfoEvent_GetOrientation(wxobj); }
		public void Orientation(LayoutOrientation value) { wxQueryLayoutInfoEvent_SetOrientation(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public LayoutAlignment Alignment() { return wxQueryLayoutInfoEvent_GetAlignment(wxobj); }
		public void Alignment(LayoutAlignment value) { wxQueryLayoutInfoEvent_SetAlignment(wxobj, value); }

		private static Event New(IntPtr obj) { return new QueryLayoutInfoEvent(obj); }

		static this()
		{
			wxEVT_QUERY_LAYOUT_INFO = wxEvent_EVT_QUERY_LAYOUT_INFO();

			AddEventType(wxEVT_QUERY_LAYOUT_INFO,               &QueryLayoutInfoEvent.New);
		}
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxCalculateLayoutEvent_ctor(int id);
		static extern (C) void wxCalculateLayoutEvent_SetFlags(IntPtr self, int flags);
		static extern (C) int wxCalculateLayoutEvent_GetFlags(IntPtr self);
		static extern (C) void wxCalculateLayoutEvent_SetRect(IntPtr self, ref Rectangle rect);
		static extern (C) void wxCalculateLayoutEvent_GetRect(IntPtr self, out Rectangle rect);
		//! \endcond
		
		//-----------------------------------------------------------------------------
	
	alias CalculateLayoutEvent wxCalculateLayoutEvent;
	public class CalculateLayoutEvent : Event
	{
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this()
			{ this(0);}
			
		public this(int id)
			{ super(wxCalculateLayoutEvent_ctor(id));}
		
		//-----------------------------------------------------------------------------
		
		public int Flags() { return wxCalculateLayoutEvent_GetFlags(wxobj); }
		public void Flags(int value) { wxCalculateLayoutEvent_SetFlags(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public Rectangle Rect() {
				Rectangle rect;
				wxCalculateLayoutEvent_GetRect(wxobj, rect);
				return rect;
			}
			
		public void Rect(Rectangle value) { wxCalculateLayoutEvent_SetRect(wxobj, value); }

		private static Event New(IntPtr obj) { return new CalculateLayoutEvent(obj); }

		static this()
		{
			wxEVT_CALCULATE_LAYOUT = wxEvent_EVT_CALCULATE_LAYOUT();

			AddEventType(wxEVT_CALCULATE_LAYOUT,                &CalculateLayoutEvent.New);
		}
	}
