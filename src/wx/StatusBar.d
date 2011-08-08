//-----------------------------------------------------------------------------
// wxD - statusbr.h
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - statusbr.h
//
/// The wxStatusBar wrapper class
//
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: StatusBar.d,v 1.12 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.StatusBar;
public import wx.common;
public import wx.Window;


		public const int wxST_SIZEGRIP         = 0x0010;
		public const int wxST_NO_AUTORESIZE    = 0x0001;
		
		public const int wxSB_NORMAL	= 0x000;
		public const int wxSB_FLAT	= 0x001;
		public const int wxSB_RAISED	= 0x002; 
	
		//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxStatusBar_ctor();
		static extern (C) bool   wxStatusBar_Create(IntPtr self, IntPtr parent, int id, uint style, string name);
	
		static extern (C) void   wxStatusBar_SetFieldsCount(IntPtr self, int number, int* widths);
		static extern (C) bool   wxStatusBar_GetFieldRect(IntPtr self, int i, ref Rectangle rect);
		static extern (C) int    wxStatusBar_GetBorderY(IntPtr self);
		static extern (C) IntPtr wxStatusBar_GetStatusText(IntPtr self, int number);
		static extern (C) int    wxStatusBar_GetBorderX(IntPtr self);
		static extern (C) void   wxStatusBar_SetStatusText(IntPtr self, string text, int number);
		static extern (C) void   wxStatusBar_SetStatusWidths(IntPtr self, int n, int* widths);
		
		static extern (C) int    wxStatusBar_GetFieldsCount(IntPtr self);
		static extern (C) void   wxStatusBar_PopStatusText(IntPtr self, int field);
		static extern (C) void   wxStatusBar_PushStatusText(IntPtr self, string xstring, int field);
		static extern (C) void   wxStatusBar_SetMinHeight(IntPtr self, int height);
		static extern (C) void   wxStatusBar_SetStatusStyles(IntPtr self, int n, int* styles);
		//! \endcond
	
		//-----------------------------------------------------------------------------

	alias StatusBar wxStatusBar;
	public class StatusBar : Window
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ super(wxStatusBar_ctor()); }

		public this(Window parent, int id /*= wxID_ANY*/, int style = wxST_SIZEGRIP, string name="")
		{
			this();
			if (!Create(parent, id, style, name))
			{
				throw new InvalidOperationException("Failed to create StatusBar");
			}
		}
		
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, int style = wxST_SIZEGRIP, string name="")
			{ this(parent, Window.UniqueID, style, name);}
		
		//-----------------------------------------------------------------------------

		public bool Create(Window parent, int id, int style, string name)
		{
			return wxStatusBar_Create(wxobj, wxObject.SafePtr(parent), id, cast(uint)style, name);
		}

		//-----------------------------------------------------------------------------
        
		public void SetFieldsCount(int number, int[] widths)
		{
			wxStatusBar_SetFieldsCount(wxobj, number, widths.ptr);
		}
		
		public int FieldsCount() { return wxStatusBar_GetFieldsCount(wxobj); }

		//-----------------------------------------------------------------------------

		public int BorderY() { return wxStatusBar_GetBorderY(wxobj); }

		public int BorderX() { return wxStatusBar_GetBorderX(wxobj); }

		//-----------------------------------------------------------------------------

		public bool GetFieldRect(int i, ref Rectangle rect)
		{
			return wxStatusBar_GetFieldRect(wxobj, i, rect);
		}

		//-----------------------------------------------------------------------------

		public void StatusText(string value) { SetStatusText(value); }
		public string StatusText() { return GetStatusText(0); }

		public void SetStatusText(string text) { SetStatusText(text, 0); }

		public void SetStatusText(string text, int number)
		{
			wxStatusBar_SetStatusText(wxobj, text, number);
		}

		public string GetStatusText(int number)
		{
			return cast(string) new wxString(wxStatusBar_GetStatusText(wxobj, number), true);
		}

		//-----------------------------------------------------------------------------

		public void StatusWidths(int[] value)
		{
			SetStatusWidths(value.length, value.ptr);
		}

		public void SetStatusWidths(int n, int* widths)
		{
			wxStatusBar_SetStatusWidths(wxobj, n, widths);
		}
		
		//-----------------------------------------------------------------------------
		
		public void PopStatusText()
		{
			PopStatusText(0);
		}
		
		public void PopStatusText(int field)
		{
			wxStatusBar_PopStatusText(wxobj, field);
		}
		
		//-----------------------------------------------------------------------------
		
		public void PushStatusText(string xstring)
		{
			PushStatusText(xstring, 0);
		}
		
		public void PushStatusText(string xstring, int field)
		{
			wxStatusBar_PushStatusText(wxobj, xstring, field);
		}
		
		//-----------------------------------------------------------------------------
		
		public void MinHeight(int value)
		{
			wxStatusBar_SetMinHeight(wxobj, value); 
		}
		
		//-----------------------------------------------------------------------------
		
		public void StatusStyles(int[] value)
		{
			wxStatusBar_SetStatusStyles(wxobj, value.length, value.ptr);
		}

	}

