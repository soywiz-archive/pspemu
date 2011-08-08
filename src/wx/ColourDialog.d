//-----------------------------------------------------------------------------
// wxD - ColourDialog.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - ColourDialog.cs
//
/// The wxColourDialog wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: ColourDialog.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.ColourDialog;
public import wx.common;
public import wx.Colour;
public import wx.Dialog;

		//! \cond EXTERN
		static extern (C) IntPtr wxColourData_ctor();

		static extern (C) void   wxColourData_SetChooseFull(IntPtr self, bool flag);
		static extern (C) bool   wxColourData_GetChooseFull(IntPtr self);

		static extern (C) void   wxColourData_SetColour(IntPtr self, IntPtr colour);
		static extern (C) IntPtr wxColourData_GetColour(IntPtr self);

		static extern (C) void   wxColourData_SetCustomColour(IntPtr self, int i, IntPtr colour);
		static extern (C) IntPtr wxColourData_GetCustomColour(IntPtr self, int i);
		//! \endcond

		//---------------------------------------------------------------------
        
	alias ColourData wxColourData;
	public class ColourData : wxObject
	{
		private this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ super(wxColourData_ctor()); }

		//---------------------------------------------------------------------

		public bool ChooseFull() 
			{
				return wxColourData_GetChooseFull(wxobj);
			}
		public void ChooseFull(bool value) 
			{
				wxColourData_SetChooseFull(wxobj, value);
			}

		//---------------------------------------------------------------------
	
		public Colour colour() 
			{
				return cast(Colour)FindObject(wxColourData_GetColour(wxobj), &Colour.New);
			}
		public void colour(Colour value) 
			{
				wxColourData_SetColour(wxobj, wxObject.SafePtr(value));
			}
		
		//---------------------------------------------------------------------
	
		public Colour GetCustomColour(int i) 
		{
			return new Colour(wxColourData_GetCustomColour(wxobj, i), true);
		}
	
		public void SetCustomColour(int i, Colour colour)
		{
			wxColourData_SetCustomColour(wxobj, i, wxObject.SafePtr(colour));
		}
		
		public static wxObject New(IntPtr ptr) { return new ColourData(ptr); }
	}
	
	//---------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxColourDialog_ctor();
		static extern (C) bool   wxColourDialog_Create(IntPtr self, IntPtr parent, IntPtr data);
		static extern (C) IntPtr wxColourDialog_GetColourData(IntPtr self);
		static extern (C) int    wxColourDialog_ShowModal(IntPtr self);
		
		static extern (C) IntPtr wxColourDialog_GetColourFromUser(IntPtr parent, IntPtr colInit);
		//! \endcond
	
		//---------------------------------------------------------------------
	
	alias ColourDialog wxColourDialog;
	public class ColourDialog : Dialog
	{
		public this(IntPtr wxobj)
			{ super(wxobj); }
	
		public this()
			{ super(wxColourDialog_ctor()); }
	
		public this(Window parent, ColourData data = null)
		{
			super(wxColourDialog_ctor());
			if (!Create(parent, data)) 
			{
				throw new InvalidOperationException("Failed to create ColourDialog");
			}
		}
	
		public bool Create(Window parent, ColourData data = null)
		{
			return wxColourDialog_Create(wxobj, wxObject.SafePtr(parent),
							wxObject.SafePtr(data));
		}
	
		//---------------------------------------------------------------------
	
		public ColourData colourData() 
			{
				return cast(ColourData)FindObject(wxColourDialog_GetColourData(wxobj), &ColourData.New);
			}
	
		//---------------------------------------------------------------------
	
		public override int ShowModal()
		{
			return wxColourDialog_ShowModal(wxobj);
		}
		
		//---------------------------------------------------------------------

	}

		public static Colour GetColourFromUser(Window parent=null, Colour colInit=null)
		{
			return new Colour(wxColourDialog_GetColourFromUser(wxObject.SafePtr(parent), wxObject.SafePtr(colInit)));
		}
