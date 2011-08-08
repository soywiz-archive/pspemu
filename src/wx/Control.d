//-----------------------------------------------------------------------------
// wxD - Control.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - Control.cs
//
/// The wxControl wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Control.d,v 1.12 2007/04/19 19:45:26 afb Exp $
//-----------------------------------------------------------------------------

module wx.Control;
public import wx.common;
public import wx.Window;

		//! \cond EXTERN
		static extern (C) void   wxControl_Command(IntPtr self, IntPtr evt);
		static extern (C) IntPtr wxControl_GetLabel(IntPtr self);
		static extern (C) void   wxControl_SetLabel(IntPtr self, string label);
		
		static extern (C) int wxControl_GetAlignment(IntPtr self);
		static extern (C) bool wxControl_SetFont(IntPtr self, IntPtr font);
		//! \endcond

		//---------------------------------------------------------------------

	alias Control wxControl;
	/// This is the base class for a control or "widget".
	/// A control is generally a small window which processes user input
	/// and/or displays one or more item of data.
	public class Control : Window
	{
		const string wxControlNameStr = "control";
	
		public this(IntPtr wxobj) 
			{ super(wxobj);}

		public this(Window parent, int id, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=0, string name=wxControlNameStr)
			{ super(parent, id, pos, size, style, name);}
		
		public this(Window parent, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=0, string name=wxControlNameStr)
			{ super(parent, Window.UniqueID, pos, size, style, name);}

		public static wxObject New(IntPtr wxobj) { return new Control(wxobj); }
	
		//---------------------------------------------------------------------

		public void Command() {}

		//---------------------------------------------------------------------

		public string Label() { return cast(string) new wxString(wxControl_GetLabel(wxobj), true); }
		public void Label(string value) { wxControl_SetLabel(wxobj, value); }
		
		//---------------------------------------------------------------------
		
		public int GetAlignment()
		{
			return wxControl_GetAlignment(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public bool SetFont(Font font)
		{
			return wxControl_SetFont(wxobj, wxObject.SafePtr(font));
		}
	}

