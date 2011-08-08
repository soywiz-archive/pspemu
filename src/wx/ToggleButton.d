//-----------------------------------------------------------------------------
// wxD - ToggleButton.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - ToggleButton.cs
//
/// The wxToggleToggleButton wrapper class.
//
// Written by Florian Fankhauser (f.fankhauser@gmx.at)
// (C) 2003 Florian Fankhauser
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: ToggleButton.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.ToggleButton;
public import wx.common;
public import wx.Control;

		//! \cond EXTERN
		static extern (C) IntPtr wxToggleButton_ctor();
		static extern (C) bool   wxToggleButton_Create(IntPtr self, IntPtr parent,
			int id, string label, ref Point pos, ref Size size, uint style,
			IntPtr validator, string name);
		static extern (C) bool wxToggleButton_GetValue(IntPtr self);
		static extern (C) bool wxToggleButton_SetValue(IntPtr self, bool state);
		//! \endcond

		//---------------------------------------------------------------------
		
	alias ToggleButton wxToggleButton;
	public class ToggleButton : Control
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ super(wxToggleButton_ctor()); }

		public this(Window parent, int id, string label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, Validator validator = null, string name = "checkbox")
		{
			super(wxToggleButton_ctor());
			if (!Create(parent, id, label, pos, size, style, validator, name))
			{
				throw new InvalidOperationException("Failed to create ToggleButton");
			}
		}
		
	public static wxObject New(IntPtr ptr) { return new ToggleButton(ptr); }

		//---------------------------------------------------------------------
		
		public this(Window parent, string label, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, Validator validator = null, string name = "checkbox")
			{ this(parent, Window.UniqueID, label, pos, size, style, validator, name);}
		
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, string label, ref Point pos, ref Size size,
			int style, Validator validator, string name)
		{
			return wxToggleButton_Create(wxobj, wxObject.SafePtr(parent), id, label, pos, size,
				cast(uint)style, wxObject.SafePtr(validator), name);
		}

		//---------------------------------------------------------------------

		public bool State() { return wxToggleButton_GetValue(wxobj); }
		public void State(bool value) { wxToggleButton_SetValue(wxobj, value); }

		//---------------------------------------------------------------------

		public void Click_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, ID, value, this); }
		public void Click_Remove(EventListener value) { RemoveHandler(value, this); }
	}

