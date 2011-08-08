//-----------------------------------------------------------------------------
// wxD - ProgressDialog.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - ProgressDialog.cs
//
/// The wxProgressDialog wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2003 Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: ProgressDialog.d,v 1.9 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.ProgressDialog;
public import wx.common;
public import wx.Dialog;

		//! \cond EXTERN
        static extern (C) IntPtr wxProgressDialog_ctor(string title, string message, int maximum, IntPtr parent, uint style);
	static extern (C) void wxProgressDialog_dtor(IntPtr self);
        static extern (C) bool wxProgressDialog_Update(IntPtr self, int value, string newmsg);
        static extern (C) void wxProgressDialog_Resume(IntPtr self);
        static extern (C) bool wxProgressDialog_Show(IntPtr self, bool show);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias ProgressDialog wxProgressDialog;
    public class ProgressDialog : Dialog
    {
        public const int wxPD_CAN_ABORT      = 0x0001;
        public const int wxPD_APP_MODAL      = 0x0002;
        public const int wxPD_AUTO_HIDE      = 0x0004;
        public const int wxPD_ELAPSED_TIME   = 0x0008;
        public const int wxPD_ESTIMATED_TIME = 0x0010;
        public const int wxPD_REMAINING_TIME = 0x0040;
	
		//---------------------------------------------------------------------

        public this(IntPtr wxobj)
            { super(wxobj);}

        public this(string title, string message, int maximum = 100, Window parent = null, int style = wxPD_APP_MODAL | wxPD_AUTO_HIDE)
            { this(wxProgressDialog_ctor(title, message, maximum, wxObject.SafePtr(parent), cast(uint)style));}

        //-----------------------------------------------------------------------------

        public bool Update(int value)
        {
            return wxProgressDialog_Update(wxobj, value, "");
        }

		//---------------------------------------------------------------------

        public bool Update(int value, string newmsg)
        {
            return wxProgressDialog_Update(wxobj, value, newmsg);
        }

		//---------------------------------------------------------------------

        public void Resume()
        {
            wxProgressDialog_Resume(wxobj);
        }

		//---------------------------------------------------------------------

        public override bool Show(bool show=true)
        {
            return wxProgressDialog_Show(wxobj, show);
        }
	
	//---------------------------------------------------------------------
	
	override protected void dtor() { wxProgressDialog_dtor(wxobj); }
    }

