//-----------------------------------------------------------------------------
// wxD - MDI.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - MDI.cs
//
/// The wxMDI* wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: MDI.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.MDI;
public import wx.common;
public import wx.Frame;

		//! \cond EXTERN
		extern (C) {
		alias IntPtr function(MDIParentFrame obj) Virtual_OnCreateClient;
		}

		static extern (C) IntPtr wxMDIParentFrame_ctor();
		static extern (C) void wxMDIParentFrame_RegisterVirtual(IntPtr self, MDIParentFrame obj, Virtual_OnCreateClient onCreateClient);
		static extern (C) IntPtr wxMDIParentFrame_OnCreateClient(IntPtr self);
		static extern (C) bool   wxMDIParentFrame_Create(IntPtr self, IntPtr parent, int id, string title, ref Point pos, ref Size size, uint style, string name);
	
		static extern (C) IntPtr wxMDIParentFrame_GetActiveChild(IntPtr self);
		//static extern (C) void   wxMDIParentFrame_SetActiveChild(IntPtr self, IntPtr pChildFrame);
	
		static extern (C) IntPtr wxMDIParentFrame_GetClientWindow(IntPtr self);
	
		static extern (C) void   wxMDIParentFrame_Cascade(IntPtr self);
		static extern (C) void   wxMDIParentFrame_Tile(IntPtr self);
	
		static extern (C) void   wxMDIParentFrame_ArrangeIcons(IntPtr self);
	
		static extern (C) void   wxMDIParentFrame_ActivateNext(IntPtr self);
		static extern (C) void   wxMDIParentFrame_ActivatePrevious(IntPtr self);
		
		static extern (C) void   wxMDIParentFrame_GetClientSize(IntPtr self, out int width, out int height);
		//! \endcond

		//-----------------------------------------------------------------------------

	alias MDIParentFrame wxMDIParentFrame;
	public class MDIParentFrame : Frame
	{
		enum { wxDEFAULT_MDI_FRAME_STYLE = wxDEFAULT_FRAME_STYLE | wxVSCROLL | wxHSCROLL }
		
		//-----------------------------------------------------------------------------
		
		public this(IntPtr wxobj)
			{ super(wxobj);}

		public this()
		{ 
			super(wxMDIParentFrame_ctor());
			wxMDIParentFrame_RegisterVirtual(wxobj, this, &staticDoOnCreateClient);
		}

		public this(Window parent, int id, string title, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=wxDEFAULT_MDI_FRAME_STYLE, string name=wxFrameNameStr)
		{
			this();
			
			if (!Create(parent, id, title, pos, size, style, name)) 
			{
				throw new InvalidOperationException("Could not create MDIParentFrame");
			}
		}
		
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, string title, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=wxDEFAULT_MDI_FRAME_STYLE, string name=wxFrameNameStr)
			{ this(parent, Window.UniqueID, title, pos, size, style, name);}
		
		//-----------------------------------------------------------------------------

		public override bool Create(Window parent, int id, string title, ref Point pos, ref Size size, int style, string name)
		{
			return wxMDIParentFrame_Create(wxobj, wxObject.SafePtr(parent), id, title, pos, size, cast(uint)style, name);
		}
		
		//-----------------------------------------------------------------------------
		
		static extern(C) private IntPtr staticDoOnCreateClient(MDIParentFrame obj)
		{
			return wxObject.SafePtr(obj.OnCreateClient());
		}
		
		public /+virtual+/ MDIClientWindow OnCreateClient()
		{
			return cast(MDIClientWindow)FindObject(wxMDIParentFrame_OnCreateClient(wxobj), &MDIClientWindow.New);
		}

		//-----------------------------------------------------------------------------

		public MDIChildFrame GetActiveChild()
		{
			return cast(MDIChildFrame)FindObject(wxMDIParentFrame_GetActiveChild(wxobj), &MDIChildFrame.New);
		}

		/*
		public void SetActiveChild(MDIChildFrame pChildFrame)
		{
			wxMDIParentFrame_SetActiveChild(wxobj, wxObject.SafePtr(pChildFrame));
		}
		*/

		//-----------------------------------------------------------------------------

		public MDIClientWindow GetClientWindow()
		{
			return cast(MDIClientWindow)FindObject(wxMDIParentFrame_GetClientWindow(wxobj), &MDIClientWindow.New);
		}

		//-----------------------------------------------------------------------------

		public /+virtual+/ void Cascade()
		{
			wxMDIParentFrame_Cascade(wxobj);
		}

		public /+virtual+/ void Tile()
		{
			wxMDIParentFrame_Tile(wxobj);
		}

		//-----------------------------------------------------------------------------

		public /+virtual+/ void ArrangeIcons()
		{
			wxMDIParentFrame_ArrangeIcons(wxobj);
		}

		//-----------------------------------------------------------------------------

		public /+virtual+/ void ActivateNext()
		{
			wxMDIParentFrame_ActivateNext(wxobj);
		}

		public /+virtual+/ void ActivatePrevious()
		{
			wxMDIParentFrame_ActivatePrevious(wxobj);
		}

		//-----------------------------------------------------------------------------
		
		public /+virtual+/ void GetClientSize(out int width, out int height)
		{
			wxMDIParentFrame_GetClientSize(wxobj, width, height);
		}
	}

		//! \cond EXTERN
		static extern (C) IntPtr wxMDIChildFrame_ctor();
		static extern (C) bool   wxMDIChildFrame_Create(IntPtr self, IntPtr parent, int id, string title, ref  Point pos, ref Size size, uint style, string name);
		static extern (C) void   wxMDIChildFrame_Activate(IntPtr self);
		static extern (C) void   wxMDIChildFrame_Restore(IntPtr self);
		static extern (C) void   wxMDIChildFrame_Maximize(IntPtr self, bool maximize);
		//! \endcond

		//-----------------------------------------------------------------------------

	alias MDIChildFrame wxMDIChildFrame;
	public class MDIChildFrame : Frame 
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ super(wxMDIChildFrame_ctor());}

		public this(MDIParentFrame parent, int id, string title, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style=wxDEFAULT_FRAME_STYLE, string name=wxFrameNameStr)
		{
			super(wxMDIChildFrame_ctor());
			if (!Create(parent, id, title, pos, size, style, name))
			{
				throw new InvalidOperationException("Could not create MDIChildFrame");
			}
	    
			EVT_ACTIVATE( &OnActivate );
		}
		
		static wxObject New(IntPtr ptr) { return new MDIChildFrame(ptr); }
		
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(MDIParentFrame parent, string title, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style=wxDEFAULT_FRAME_STYLE, string name=wxFrameNameStr)
			{ this(parent, Window.UniqueID, title, pos, size, style, name); }
		
		//-----------------------------------------------------------------------------

		public bool Create(Window parent, int id, string title, ref Point pos, ref Size size, int style, string name)
		{
			bool ret = wxMDIChildFrame_Create(wxobj, wxObject.SafePtr(parent), id, title, pos, size, style, name);
			version(__WXMAC__){
				// Bug in wxMac 2.5.2; it always returns FALSE
				return true;
			} else {
				return ret;
			} // version(__WXMAC__)
		}

		//-----------------------------------------------------------------------------

		public /+virtual+/ void Activate()
		{
			wxMDIChildFrame_Activate(wxobj);
		}

		//-----------------------------------------------------------------------------

		public /+virtual+/ void Restore()
		{
			wxMDIChildFrame_Restore(wxobj);
		}

		//-----------------------------------------------------------------------------
	
		public /+virtual+/ void OnActivate(Object sender, Event e)
		{
		}
		
		//-----------------------------------------------------------------------------
		
		public /+virtual+/ void Maximize()
		{
			wxMDIChildFrame_Maximize(wxobj, true);
		}
	}

		//! \cond EXTERN
		static extern (C) IntPtr wxMDIClientWindow_ctor();
		static extern (C) bool   wxMDIClientWindow_CreateClient(IntPtr self, IntPtr parent, uint style);
		//! \endcond
	
		//-----------------------------------------------------------------------------
	
	alias MDIClientWindow wxMDIClientWindow;
	public class MDIClientWindow : Window
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public  this()
			{ super(wxMDIClientWindow_ctor()); }

		public this(MDIParentFrame parent, int style=0)
		{
			super(wxMDIClientWindow_ctor());
			if (!CreateClient(parent, style))
			{
				throw new InvalidOperationException("Could not create MDIClientWindow");
			}
		}
		
		static wxObject New(IntPtr ptr) { return new MDIClientWindow(ptr); }
		
		//-----------------------------------------------------------------------------

		public bool CreateClient(MDIParentFrame parent, int style)
		{
			return wxMDIClientWindow_CreateClient(wxobj, wxObject.SafePtr(parent), style);
		}
	}

