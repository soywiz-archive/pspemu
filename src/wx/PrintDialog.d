//-----------------------------------------------------------------------------
// wxD - PrintDialog.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - PrintDialog.cs
//
/// The wxPrintDialog wrapper classes.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: PrintDialog.d,v 1.9 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.PrintDialog;
public import wx.common;
public import wx.Dialog;
public import wx.PrintData;

		//! \cond EXTERN
        static extern (C) IntPtr wxPageSetupDialog_ctor(IntPtr parent, IntPtr data);
        static extern (C) IntPtr wxPageSetupDialog_GetPageSetupData(IntPtr self);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias PageSetupDialog wxPageSetupDialog;
    public class PageSetupDialog : Dialog
    {
        private this(IntPtr wxobj)
            { super(wxobj); }

        public this(Window parent)
            { this(parent, null); }
        public this(Window parent, PageSetupDialogData data)
            { this(wxPageSetupDialog_ctor(wxObject.SafePtr(parent), wxObject.SafePtr(data))); }

        //-----------------------------------------------------------------------------

        public PageSetupDialogData PageSetupData() { return cast(PageSetupDialogData)FindObject(wxPageSetupDialog_GetPageSetupData(wxobj), &PageSetupDialogData.New); }
    }

		//! \cond EXTERN
        static extern (C) IntPtr wxPrintDialog_ctor(IntPtr parent, IntPtr data);
        static extern (C) IntPtr wxPrintDialog_ctorPrintData(IntPtr parent, IntPtr data);
        static extern (C) IntPtr wxPrintDialog_GetPrintData(IntPtr self);
        static extern (C) IntPtr wxPrintDialog_GetPrintDialogData(IntPtr self);
        static extern (C) IntPtr wxPrintDialog_GetPrintDC(IntPtr self);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias PrintDialog wxPrintDialog;
    public class PrintDialog : Dialog
    {
        private this(IntPtr wxobj)
            { super(wxobj); }

        public this(Window parent)
            { this(parent, cast(PrintDialogData)null); }
        public this(Window parent, PrintDialogData data)
            { this(wxPrintDialog_ctor(wxObject.SafePtr(parent), wxObject.SafePtr(data))); }

        public this(Window parent, PrintData data)
            { this(wxPrintDialog_ctorPrintData(wxObject.SafePtr(parent), wxObject.SafePtr(data))); }

        //-----------------------------------------------------------------------------

        public PrintData printData() { return cast(PrintData)FindObject(wxPrintDialog_GetPrintData(wxobj), &PrintData.New); }

        //-----------------------------------------------------------------------------

        public PrintDialogData printDialogData() { return cast(PrintDialogData)FindObject(wxPrintDialog_GetPrintDialogData(wxobj), &PrintDialogData.New); }

        //-----------------------------------------------------------------------------

        public DC PrintDC() { return cast(DC)FindObject(wxPrintDialog_GetPrintDC(wxobj), &DC.New); }
    }

//! \cond VERSION
version(none) /*(__WXGTK__)*/{
    
		//! \cond EXTERN
        static extern (C) IntPtr wxPrintSetupDialog_ctor(IntPtr parent, IntPtr data);
        static extern (C) IntPtr wxPrintSetupDialog_ctorPrintData(IntPtr parent, IntPtr data);
        static extern (C) void wxPrintSetupDialog_Init(IntPtr self, IntPtr data);
        static extern (C) IntPtr wxPrintSetupDialog_GetPrintData(IntPtr self);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias PrintSetupDialog wxPrintSetupDialog;
    public class PrintSetupDialog : Dialog
    {
        private this(IntPtr wxobj)
            { super(wxobj); }

        public this(Window parent) 
            { this(parent, cast(PrintDialogData)null); }
        public this(Window parent, PrintDialogData data)
            { this(wxPrintSetupDialog_ctor(wxObject.SafePtr(parent), wxObject.SafePtr(data))); }

        public this(Window parent, PrintData data)
            { this(wxPrintSetupDialog_ctorPrintData(wxObject.SafePtr(parent), wxObject.SafePtr(data))); }

        //-----------------------------------------------------------------------------

        public void Init(PrintData data)
        {
            wxPrintSetupDialog_Init(wxobj, wxObject.SafePtr(data));
        }

        //-----------------------------------------------------------------------------

        public PrintData printData() { return cast(PrintData)FindObject(wxPrintSetupDialog_GetPrintData(wxobj), &PrintData.New); }
    }

} // __WXGTK__
//! \endcond
