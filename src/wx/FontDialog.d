//-----------------------------------------------------------------------------
// wxD - FontDialog.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Fontdlg.cs
//
/// The wxFontDialog wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: FontDialog.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.FontDialog;
public import wx.common;
public import wx.Dialog;
public import wx.Font;
public import wx.GdiCommon; //for nullobject

		//! \cond EXTERN
		static extern (C) IntPtr wxFontData_ctor();
		static extern (C) void   wxFontData_dtor(IntPtr self);

		static extern (C) void   wxFontData_SetAllowSymbols(IntPtr self, bool flag);
		static extern (C) bool   wxFontData_GetAllowSymbols(IntPtr self);

		static extern (C) void   wxFontData_SetColour(IntPtr self, IntPtr colour);
		static extern (C) IntPtr wxFontData_GetColour(IntPtr self);

		static extern (C) void   wxFontData_SetShowHelp(IntPtr self, bool flag);
		static extern (C) bool   wxFontData_GetShowHelp(IntPtr self);

		static extern (C) void   wxFontData_EnableEffects(IntPtr self, bool flag);
		static extern (C) bool   wxFontData_GetEnableEffects(IntPtr self);

		static extern (C) void   wxFontData_SetInitialFont(IntPtr self, IntPtr font);
		static extern (C) IntPtr wxFontData_GetInitialFont(IntPtr self);

		static extern (C) void   wxFontData_SetChosenFont(IntPtr self, IntPtr font);
		static extern (C) IntPtr wxFontData_GetChosenFont(IntPtr self);

		static extern (C) void   wxFontData_SetRange(IntPtr self, int minRange, int maxRange);
		//! \endcond

        //---------------------------------------------------------------------

    alias FontData wxFontData;
    public class FontData : wxObject
    {
        public this(IntPtr wxobj) 
            { super(wxobj); }

        public this()
            { super(wxFontData_ctor()); }

        //---------------------------------------------------------------------

        public bool AllowSymbols() { return wxFontData_GetAllowSymbols(wxobj); }
        public void AllowSymbols(bool value) { wxFontData_SetAllowSymbols(wxobj, value); }

        //---------------------------------------------------------------------

        public bool EffectsEnabled() { return wxFontData_GetEnableEffects(wxobj); }
        public void EffectsEnabled(bool value) { wxFontData_EnableEffects(wxobj, value); }

        //---------------------------------------------------------------------

        public bool ShowHelp() { return wxFontData_GetShowHelp(wxobj); }
        public void ShowHelp(bool value) { wxFontData_SetShowHelp(wxobj, value); }

        //---------------------------------------------------------------------

        public Colour colour() 
            {
                return new Colour(wxFontData_GetColour(wxobj), true);
            }
        public void colour(Colour value) 
            {
                wxFontData_SetColour(wxobj, wxObject.SafePtr(value)); 
            }

        //---------------------------------------------------------------------
        
        public Font InitialFont() 
            {
                return new Font(wxFontData_GetInitialFont(wxobj));
            }
        public void InitialFont(Font value) 
            {
                wxFontData_SetInitialFont(wxobj, wxObject.SafePtr(value));
            }

        //---------------------------------------------------------------------

        public Font ChosenFont() 
            {
                return new Font(wxFontData_GetChosenFont(wxobj));
            }
        public void ChosenFont(Font value) 
            {
                wxFontData_SetChosenFont(wxobj, wxObject.SafePtr(value));
            }

        //---------------------------------------------------------------------

        public void SetRange(int min, int max)
        {
            wxFontData_SetRange(wxobj, min, max);
        }

        //---------------------------------------------------------------------
	public static wxObject New(IntPtr ptr) { return new FontData(ptr); }
    }

		//! \cond EXTERN
		static extern (C) IntPtr wxFontDialog_ctor();
		static extern (C) bool   wxFontDialog_Create(IntPtr self, IntPtr parent, IntPtr data);
		static extern (C) void   wxFontDialog_dtor(IntPtr self);

		static extern (C) int    wxFontDialog_ShowModal(IntPtr self);
		static extern (C) IntPtr wxFontDialog_GetFontData(IntPtr self);
		//! \endcond

        //---------------------------------------------------------------------

	alias FontDialog wxFontDialog;
	public class FontDialog : Dialog
	{
        public this(IntPtr wxobj)
            { super(wxobj); }

        public this()
            { super(wxFontDialog_ctor()); }

        public this(Window parent)
            { this(parent, null); }

        public this(Window parent, FontData data)
        {
        	this();
            if (!Create(parent, data)) 
            {
                throw new InvalidOperationException("Failed to create FontDialog");
            }
        }

        public bool Create(Window parent, FontData data)
        {
            return wxFontDialog_Create(wxobj, wxObject.SafePtr(parent), wxObject.SafePtr(data));
        }

        //---------------------------------------------------------------------

        public FontData fontData() 
        {
            return cast(FontData)FindObject(wxFontDialog_GetFontData(wxobj), &FontData.New);
        }

        //---------------------------------------------------------------------

        public override int ShowModal()
        {
            return wxFontDialog_ShowModal(wxobj);
        }

        //---------------------------------------------------------------------
	}

	//! \cond EXTERN
	extern (C) IntPtr wxGetFontFromUser_func(IntPtr parent, IntPtr fontInit);
	//! \endcond

	Font GetFontFromUser(Window parent,Font fontInit=null)
	{
		return new Font(wxGetFontFromUser_func(wxObject.SafePtr(parent),wxObject.SafePtr(fontInit)));
	}
