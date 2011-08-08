//-----------------------------------------------------------------------------
// wxD - Frame.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Frame.cs
//
/// The wxFrame wrapper class.
//
// Written by Jason Perkins (jason@379.com), Bryan Bulten (bryan@bulten.ca)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Frame.d,v 1.13 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.Frame;
public import wx.common;
public import wx.Window;
public import wx.ToolBar;
public import wx.MenuBar;
public import wx.StatusBar;
public import wx.Icon;

		//! \cond EXTERN
		static extern (C) IntPtr wxFrame_ctor();
		static extern (C) bool   wxFrame_Create(IntPtr self, IntPtr parent, int id, string title, ref Point pos, ref Size size, uint style, string name);

		static extern (C) IntPtr wxFrame_CreateStatusBar(IntPtr self, int number, uint style, int id, string name);

		static extern (C) void   wxFrame_SendSizeEvent(IntPtr self);

		static extern (C) void   wxFrame_SetIcon(IntPtr self, IntPtr icon);

		static extern (C) void   wxFrame_SetMenuBar(IntPtr self, IntPtr menuBar);
		static extern (C) IntPtr wxFrame_GetMenuBar(IntPtr self);

		static extern (C) void   wxFrame_SetStatusText(IntPtr self, string text, int number);

		static extern (C) IntPtr wxFrame_CreateToolBar(IntPtr self, uint style, int id, string name);
		static extern (C) IntPtr wxFrame_GetToolBar(IntPtr self);
		static extern (C) void   wxFrame_SetToolBar(IntPtr self, IntPtr toolbar);

		static extern (C) bool   wxFrame_ShowFullScreen(IntPtr self, bool show, uint style);
		static extern (C) bool   wxFrame_IsFullScreen(IntPtr self);

		static extern (C) IntPtr wxFrame_GetStatusBar(IntPtr wxobj); 
		static extern (C) void   wxFrame_SetStatusBar(IntPtr wxobj, IntPtr statusbar);

		static extern (C) int    wxFrame_GetStatusBarPane(IntPtr wxobj); 
		static extern (C) void   wxFrame_SetStatusBarPane(IntPtr wxobj, int n); 

		static extern (C) void   wxFrame_SetStatusWidths(IntPtr self, int n, int* widths);

		static extern (C) void   wxFrame_Iconize(IntPtr wxobj, bool iconize); 
		static extern (C) bool   wxFrame_IsIconized(IntPtr wxobj); 

		static extern (C) void   wxFrame_Maximize(IntPtr wxobj, bool maximize); 
		static extern (C) bool   wxFrame_IsMaximized(IntPtr wxobj); 

		//static extern (C) bool   wxFrame_SetShape(IntPtr self, IntPtr region);
		
		static extern (C) void   wxFrame_GetClientAreaOrigin(IntPtr self, ref Point pt);
		//! \endcond
            
		//---------------------------------------------------------------------

	alias Frame wxFrame;
	/// A frame is a window whose size and position can (usually) be
	/// changed by the user. It usually has thick borders and a title bar,
	/// and can optionally contain a menu bar, toolbar and status bar.
	/// A frame can contain any window that is not a frame or dialog.
	public class Frame : Window
	{
		public const int wxFULLSCREEN_NOMENUBAR   = 0x0001;
		public const int wxFULLSCREEN_NOTOOLBAR   = 0x0002;
		public const int wxFULLSCREEN_NOSTATUSBAR = 0x0004;
		public const int wxFULLSCREEN_NOBORDER    = 0x0008;
		public const int wxFULLSCREEN_NOCAPTION   = 0x0010;
		public const int wxFULLSCREEN_ALL         = 
                    wxFULLSCREEN_NOMENUBAR | wxFULLSCREEN_NOTOOLBAR |
                    wxFULLSCREEN_NOSTATUSBAR | wxFULLSCREEN_NOBORDER |
                    wxFULLSCREEN_NOCAPTION;
		    
		//-----------------------------------------------------------------------------
		const string wxFrameNameStr="frame";

		public this(IntPtr wxobj)
			{ super(wxobj); }
			
		public this()
			{ this(wxFrame_ctor());}
			
		public this(Window parent, int id, string title, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=wxDEFAULT_FRAME_STYLE, string name=wxFrameNameStr)
		{
			this(wxFrame_ctor());
			if (!Create(parent, id, title, pos, size, style, name))
			{
				throw new InvalidOperationException("Failed to create Frame");
			}
		}
		
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, string title, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=wxDEFAULT_FRAME_STYLE, string name=wxFrameNameStr)
			{ this(parent, Window.UniqueID, title, pos, size, style, name);}
		
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, string title, ref Point pos, ref Size size, int style, string name)
		{
			return wxFrame_Create(wxobj, wxObject.SafePtr(parent), id, title, pos, size, style, name);
		}

		//---------------------------------------------------------------------
        
		// Helper constructors

		public this(string title, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=wxDEFAULT_FRAME_STYLE)
			{ this(null, -1, title, pos, size, style); }

		//---------------------------------------------------------------------
        
		public bool ShowFullScreen(bool show, int style) 
		{
			return wxFrame_ShowFullScreen(wxobj, show, cast(uint)style);
		}

		public bool ShowFullScreen(bool show) 
		{
			return ShowFullScreen(show, wxFULLSCREEN_ALL);
		}

		public bool IsFullScreen() { return wxFrame_IsFullScreen(wxobj); }

		//---------------------------------------------------------------------

		public StatusBar CreateStatusBar()
		{ 
			return CreateStatusBar(1, 0, -1, "statusBar"); 
		}
		
		public StatusBar CreateStatusBar(int number)
		{ 
			return CreateStatusBar(number, 0, -1, "statusBar"); 
		}
		
		public StatusBar CreateStatusBar(int number, int style)
		{ 
			return CreateStatusBar(number, style, -1, "statusBar"); 
		}
		
		public StatusBar CreateStatusBar(int number, int style, int id)
		{ 
			return CreateStatusBar(number, style, id, "statusBar"); 
		}

		public StatusBar CreateStatusBar(int number, int style, int id, string name)
		{
			return new StatusBar(wxFrame_CreateStatusBar(wxobj, number, cast(uint)style, id, name));
		}

		public StatusBar statusBar() { return cast(StatusBar)FindObject(wxFrame_GetStatusBar(wxobj), &StatusBar.New); }
		public void statusBar(StatusBar value) { wxFrame_SetStatusBar(wxobj, wxObject.SafePtr(value)); }

		public int StatusBarPane() { return wxFrame_GetStatusBarPane(wxobj); }
		public void StatusBarPane(int value) { wxFrame_SetStatusBarPane(wxobj, value); }

		//---------------------------------------------------------------------

		public void SendSizeEvent()
		{
			wxFrame_SendSizeEvent(wxobj);
		}

		//---------------------------------------------------------------------

		public void icon(Icon value) { wxFrame_SetIcon(wxobj, wxObject.SafePtr(value)); }

		//---------------------------------------------------------------------

		public void menuBar(MenuBar value) { 
				wxFrame_SetMenuBar(wxobj, wxObject.SafePtr(value)); 
				// add menu events...
			if (value)
			{
				for ( int i = 0; i < menuBar.MenuCount; ++i )
				{
					Menu menu = value.GetMenu(i);
					menu.ConnectEvents(this);
				}
			}
		}
		public MenuBar menuBar() { return cast(MenuBar)FindObject(wxFrame_GetMenuBar(wxobj), &MenuBar.New); }

		//---------------------------------------------------------------------

		public void StatusText(string value) { SetStatusText(value); }

		public void SetStatusText(string text) 
		{ SetStatusText(text, 0); }

		public void SetStatusText(string text, int number)
		{
			wxFrame_SetStatusText(wxobj, text, number);
		}

		//---------------------------------------------------------------------

		public void StatusWidths(int[] value)
		{
			SetStatusWidths(value.length, value);
		}

		public void SetStatusWidths(int n, int[] widths)
		{
			wxFrame_SetStatusWidths(wxobj, n, widths.ptr);
		}

		//---------------------------------------------------------------------

		public ToolBar CreateToolBar()
		{ return CreateToolBar(/*Border.*/wxNO_BORDER | ToolBar.wxTB_HORIZONTAL, -1, "toolBar"); }
		public ToolBar CreateToolBar(int style)
		{ return CreateToolBar(style, -1, "toolBar"); }
		public ToolBar CreateToolBar(int style, int id)
		{ return CreateToolBar(style, id, "toolBar"); }

		public ToolBar CreateToolBar(int style, int id, string name)
		{
			return new ToolBar(wxFrame_CreateToolBar(wxobj, cast(uint)style, id, name));
		}

		public ToolBar toolBar() { return cast(ToolBar)FindObject(wxFrame_GetToolBar(wxobj)); }
		public void toolBar(ToolBar value) { wxFrame_SetToolBar(wxobj, wxObject.SafePtr(value)); }

		//---------------------------------------------------------------------

		public bool Iconized() { return wxFrame_IsIconized(wxobj); }
		public void Iconized(bool value) { wxFrame_Iconize(wxobj, value); }

		//---------------------------------------------------------------------

		public bool Maximized() { return wxFrame_IsMaximized(wxobj); }
		public void Maximized(bool value) { wxFrame_Maximize(wxobj, value); }

		//---------------------------------------------------------------------

		/*public bool SetShape(wx.Region region)
		{
			return wxFrame_SetShape(wxobj, wxObject.SafePtr(region));
		}*/

		//---------------------------------------------------------------------
		
		public override Point ClientAreaOrigin()
		{
			Point pt;
			wxFrame_GetClientAreaOrigin(wxobj, pt);
			return pt;
		}
	}
