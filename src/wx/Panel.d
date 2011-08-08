//-----------------------------------------------------------------------------
// wxD - Panel.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Panel.cs
//
/// The wxPanel wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Panel.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.Panel;
public import wx.common;
public import wx.Window;
public import wx.Button;

		//! \cond EXTERN
		static extern (C) IntPtr wxPanel_ctor();
		static extern (C) IntPtr wxPanel_ctor2(IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) bool wxPanel_Create(IntPtr self, IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) void wxPanel_InitDialog(IntPtr self);
		static extern (C) IntPtr wxPanel_GetDefaultItem(IntPtr self);
		static extern (C) void wxPanel_SetDefaultItem(IntPtr self, IntPtr btn);
		//! \endcond

	alias Panel wxPanel;
	/// A panel is a window on which controls are placed. It is usually
	/// placed within a frame. It contains minimal extra functionality over and
	/// above its parent class wxWindow; its main purpose is to be similar in
	/// appearance and functionality to a dialog, but with the flexibility of
	/// having any window as a parent.
	public class Panel : Window
	{
		//---------------------------------------------------------------------
		
		public this(IntPtr wxobj) 
			{ super(wxobj);}
		
		public this()
			{ super(wxPanel_ctor());}

		public this(Window parent, int id /*= wxID_ANY*/, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = wxTAB_TRAVERSAL|wxNO_BORDER, string name = wxPanelNameStr)
			{ super(wxPanel_ctor2(wxObject.SafePtr(parent), id, pos, size, style, name));}
			
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=wxTAB_TRAVERSAL|wxNO_BORDER, string name=wxPanelNameStr)
			{ this(parent, Window.UniqueID, pos, size, style, name);}
		
		//---------------------------------------------------------------------
		
		public bool Create(Window parent, int id, ref Point pos, ref Size size, int style, string name)
		{
			return wxPanel_Create(wxobj, wxObject.SafePtr(parent), id, pos, size, style, name);
		}

		//---------------------------------------------------------------------

		public Button DefaultItem() 
			{
				IntPtr btn = wxPanel_GetDefaultItem(wxobj);
				return (btn != IntPtr.init) ? new Button(btn) : null;
			}
		public void DefaultItem(Button value) 
			{
				wxPanel_SetDefaultItem(wxobj, value.wxobj);
			}

		//---------------------------------------------------------------------

		public override void InitDialog()
		{
			wxPanel_InitDialog(wxobj);
		}

		//---------------------------------------------------------------------
	}
