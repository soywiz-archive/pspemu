//-----------------------------------------------------------------------------
// wxD - SpinButton.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - SpinButton.cs
//
/// The wxSpinButton wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
// $Id: SpinButton.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.SpinButton;
public import wx.common;
public import wx.CommandEvent;
public import wx.Control;

		//! \cond EXTERN
		static extern (C) IntPtr wxSpinEvent_ctor(int commandType, int id);
		static extern (C) int wxSpinEvent_GetPosition(IntPtr self);
		static extern (C) void wxSpinEvent_SetPosition(IntPtr self, int pos);
		static extern (C) void wxSpinEvent_Veto(IntPtr self);
		static extern (C) void wxSpinEvent_Allow(IntPtr self);
		static extern (C) bool wxSpinEvent_IsAllowed(IntPtr self);	
		//! \endcond

		//-----------------------------------------------------------------------------
	
	alias SpinEvent wxSpinEvent;
	public class SpinEvent : CommandEvent
	{
		public this(IntPtr wxobj)
			{ super(wxobj); }
			
		public this(int commandType, int id)
			{ super(wxSpinEvent_ctor(commandType, id)); }

		//-----------------------------------------------------------------------------	

		public int Position() { return wxSpinEvent_GetPosition(wxobj); }
		public void Position(int value) { wxSpinEvent_SetPosition(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public void Veto()
		{
			wxSpinEvent_Veto(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public void Allow()
		{
			wxSpinEvent_Allow(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool Allowed() { return wxSpinEvent_IsAllowed(wxobj); }

		private static Event New(IntPtr obj) { return new SpinEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_SCROLL_THUMBTRACK,               &SpinEvent.New);
			AddEventType(wxEVT_SCROLL_LINEUP,                   &SpinEvent.New);
			AddEventType(wxEVT_SCROLL_LINEDOWN,                 &SpinEvent.New);        		}
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxSpinButton_ctor();
		static extern (C) bool   wxSpinButton_Create(IntPtr self, IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) int    wxSpinButton_GetValue(IntPtr self);
		static extern (C) int    wxSpinButton_GetMin(IntPtr self);
		static extern (C) int    wxSpinButton_GetMax(IntPtr self);
		static extern (C) void   wxSpinButton_SetValue(IntPtr self, int val);
		static extern (C) void   wxSpinButton_SetRange(IntPtr self, int minVal, int maxVal);
		//! \endcond

		//---------------------------------------------------------------------
	alias SpinButton wxSpinButton;
	public class SpinButton : Control
	{
		// These are duplicated in SpinCtrl.cs (for easier access)
		enum {
			wxSP_HORIZONTAL       = Orientation.wxHORIZONTAL,
			wxSP_VERTICAL         = Orientation.wxVERTICAL,
			wxSP_ARROW_KEYS       = 0x1000,
			wxSP_WRAP             = 0x2000,
		}
	
		public const string wxSPIN_BUTTON_NAME = "SpinButton";
		//---------------------------------------------------------------------
        
		
		public this(IntPtr wxobj) 
			{ super(wxobj);}

		public this()
			{ super(wxSpinButton_ctor()); }
			
		public this(Window parent, int id /*= wxID_ANY*/, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = wxSP_VERTICAL | wxSP_ARROW_KEYS, string name = wxSPIN_BUTTON_NAME)
		{
			super(wxSpinButton_ctor());
			if(!Create(parent, id, pos, size, style, name))
			{
				throw new InvalidOperationException("Failed to create SpinButton");
			}
		}
		
		public static wxObject New(IntPtr wxobj) { return new SpinButton(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = wxSP_VERTICAL | wxSP_ARROW_KEYS, string name = wxSPIN_BUTTON_NAME)
			{ this(parent, Window.UniqueID, pos, size, style, name);}
		
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, ref Point pos, ref Size size,  int style, string name)
		{
			return wxSpinButton_Create(wxobj, wxObject.SafePtr(parent), id,
						pos, size, cast(uint)style, name);
		}

		//---------------------------------------------------------------------
        
		public int Value() { return wxSpinButton_GetValue(wxobj); }
		public void Value(int value) { wxSpinButton_SetValue(wxobj, value); }

		//---------------------------------------------------------------------
        
		public int Max() { return wxSpinButton_GetMax(wxobj); }

		public int Min() { return wxSpinButton_GetMin(wxobj); }

		public void SetRange(int min, int max)
		{
			wxSpinButton_SetRange(wxobj, min, max);
		}
	}
