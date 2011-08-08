//-----------------------------------------------------------------------------
// wxD - TextCtrl.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - TextCtrl.cs
//
/// The wxTextCtrl wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Printer.d,v 1.12 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.Printer;
public import wx.common;
public import wx.Window;
public import wx.PrintData;

    public enum PrinterError 
    {
        wxPRINTER_NO_ERROR = 0,
        wxPRINTER_CANCELLED,
        wxPRINTER_ERROR
    }

		//! \cond EXTERN
        static extern (C) IntPtr wxPrinter_ctor(IntPtr data);
        static extern (C) IntPtr wxPrinter_CreateAbortWindow(IntPtr self, IntPtr parent, IntPtr printout);
        static extern (C) void   wxPrinter_ReportError(IntPtr self, IntPtr parent, IntPtr printout, string message);
        static extern (C) IntPtr wxPrinter_GetPrintDialogData(IntPtr self);
        static extern (C) bool   wxPrinter_GetAbort(IntPtr self);
        static extern (C) int    wxPrinter_GetLastError(IntPtr self);
        static extern (C) bool   wxPrinter_Setup(IntPtr self, IntPtr parent);
        static extern (C) bool   wxPrinter_Print(IntPtr self, IntPtr parent, IntPtr printout, bool prompt);
        static extern (C) IntPtr wxPrinter_PrintDialog(IntPtr self, IntPtr parent);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias Printer wxPrinter;
    public class Printer : wxObject
    {
        private this(IntPtr wxobj) 
            { super(wxobj); }

        public this()
            { this(cast(PrintDialogData)null); }
        public this(PrintDialogData data)
            { this(wxPrinter_ctor(wxObject.SafePtr(data))); }

        //-----------------------------------------------------------------------------

        public Window CreateAbortWindow(Window parent, Printout printout)
        {
            return cast(Window)FindObject(wxPrinter_CreateAbortWindow(wxobj, wxObject.SafePtr(parent), wxObject.SafePtr(printout)), &Window.New);
        }

        //-----------------------------------------------------------------------------

        public void ReportError(Window parent, Printout printout, string message)
        {
            wxPrinter_ReportError(wxobj, wxObject.SafePtr(parent), wxObject.SafePtr(printout), message);
        }

        //-----------------------------------------------------------------------------

        public PrintDialogData printDialogData() { return cast(PrintDialogData)FindObject(wxPrinter_GetPrintDialogData(wxobj), &PrintDialogData.New); }

        //-----------------------------------------------------------------------------

        public bool Abort() { return wxPrinter_GetAbort(wxobj); }

        //-----------------------------------------------------------------------------

        public PrinterError LastError() { return cast(PrinterError)wxPrinter_GetLastError(wxobj); }

        //-----------------------------------------------------------------------------

        public bool Setup(Window parent)
        {
            return wxPrinter_Setup(wxobj, wxObject.SafePtr(parent));
        }

        //-----------------------------------------------------------------------------

        public bool Print(Window parent, Printout printout, bool prompt)
        {
            return wxPrinter_Print(wxobj, wxObject.SafePtr(parent), wxObject.SafePtr(printout), prompt);
        }

        //-----------------------------------------------------------------------------

        public DC PrintDialog(Window parent)
        {
            return cast(DC)FindObject(wxPrinter_PrintDialog(wxobj, wxObject.SafePtr(parent)), &DC.New);
        }
    }


        //-----------------------------------------------------------------------------

		//! \cond EXTERN
	extern (C) {
        alias void function(Printout obj) Virtual_NoParams;
        alias bool function(Printout obj, int i) Virtual_ParamsInt;
        alias bool function(Printout obj, int startPage, int endPage) Virtual_OnBeginDocument;
        alias void function(Printout obj, ref int minPage, ref int maxPage, ref int pageFrom, ref int pageTo) Virtual_GetPageInfo;
	}

        static extern (C) IntPtr wxPrintout_ctor(string title);
        static extern (C) bool   wxPrintout_OnBeginDocument(IntPtr self, int startPage, int endPage);
        static extern (C) void   wxPrintout_OnEndDocument(IntPtr self);
        static extern (C) void   wxPrintout_OnBeginPrinting(IntPtr self);
        static extern (C) void   wxPrintout_OnEndPrinting(IntPtr self);
        static extern (C) void   wxPrintout_OnPreparePrinting(IntPtr self);
        static extern (C) bool   wxPrintout_HasPage(IntPtr self, int page);
        static extern (C) void   wxPrintout_GetPageInfo(IntPtr self, ref int minPage, ref int maxPage, ref int pageFrom, ref int pageTo);
        static extern (C) IntPtr wxPrintout_GetTitle(IntPtr self);
        static extern (C) IntPtr wxPrintout_GetDC(IntPtr self);
        static extern (C) void   wxPrintout_SetDC(IntPtr self, IntPtr dc);
        static extern (C) void   wxPrintout_SetPageSizePixels(IntPtr self, int w, int h);
        static extern (C) void   wxPrintout_GetPageSizePixels(IntPtr self, ref int w, ref int h);
        static extern (C) void   wxPrintout_SetPageSizeMM(IntPtr self, int w, int h);
        static extern (C) void   wxPrintout_GetPageSizeMM(IntPtr self, ref int w, ref int h);
        static extern (C) void   wxPrintout_SetPPIScreen(IntPtr self, int x, int y);
        static extern (C) void   wxPrintout_GetPPIScreen(IntPtr self, ref int x, ref int y);
        static extern (C) void   wxPrintout_SetPPIPrinter(IntPtr self, int x, int y);
        static extern (C) void   wxPrintout_GetPPIPrinter(IntPtr self, ref int x, ref int y);
        static extern (C) bool   wxPrintout_IsPreview(IntPtr self);
        static extern (C) void   wxPrintout_SetIsPreview(IntPtr self, bool p);

        static extern (C) void   wxPrintout_RegisterVirtual(IntPtr self, Printout obj, Virtual_OnBeginDocument onBeginDocument, Virtual_NoParams onEndDocument, Virtual_NoParams onBeginPrinting, Virtual_NoParams onEndPrinting, Virtual_NoParams onPreparePrinting, Virtual_ParamsInt hasPage, Virtual_ParamsInt onPrintPage, Virtual_GetPageInfo getPageInfo);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias Printout wxPrintout;
    public abstract class Printout : wxObject
    {
        private this(IntPtr wxobj) 
        { 
        	super(wxobj);

            wxPrintout_RegisterVirtual(wxobj,this,
                    &staticOnBeginDocument,
                    &staticOnEndDocument,
                    &staticOnBeginPrinting,
                    &staticOnEndPrinting,
                    &staticOnPreparePrinting,
                    &staticHasPage,
                    &staticOnPrintPage,
                    &staticGetPageInfo);
        }

        public this(string title)
            { this(wxPrintout_ctor(title)); }

//	public static wxObject New(IntPtr ptr) { return new Printout(ptr); }
        //-----------------------------------------------------------------------------

        static extern(C) private bool staticOnBeginDocument(Printout obj, int startPage, int endPage)
        {
            return obj.OnBeginDocument(startPage, endPage);
        }
        public /+virtual+/ bool OnBeginDocument(int startPage, int endPage)
        {
            return wxPrintout_OnBeginDocument(wxobj, startPage, endPage);
        }

        static extern(C) private void staticOnEndDocument(Printout obj)
        {
            obj.OnEndDocument();
        }
        public /+virtual+/ void OnEndDocument()
        {
            wxPrintout_OnEndDocument(wxobj);
        }

        //-----------------------------------------------------------------------------

        static extern(C) private void staticOnBeginPrinting(Printout obj)
        {
            obj.OnBeginPrinting();
        }
        public /+virtual+/ void OnBeginPrinting()
        {
            wxPrintout_OnBeginPrinting(wxobj);
        }

        static extern(C) private void staticOnEndPrinting(Printout obj)
        {
            obj.OnEndPrinting();
        }
        public /+virtual+/ void OnEndPrinting()
        {
            wxPrintout_OnEndPrinting(wxobj);
        }

        static extern(C) private void staticOnPreparePrinting(Printout obj)
        {
            obj.OnPreparePrinting();
        }
        public /+virtual+/ void OnPreparePrinting()
        {
            wxPrintout_OnPreparePrinting(wxobj);
        }

        //-----------------------------------------------------------------------------

        static extern(C) private bool staticHasPage(Printout obj, int page)
        {
            return obj.HasPage(page);
        }
        public /+virtual+/ bool HasPage(int page)
        {
            return wxPrintout_HasPage(wxobj, page);
        }

        //-----------------------------------------------------------------------------

        static extern(C) private bool staticOnPrintPage(Printout obj,int page)
        {
            return obj.OnPrintPage(page);
        }
        public abstract bool OnPrintPage(int page);

        //-----------------------------------------------------------------------------

        static extern(C) private void staticGetPageInfo(Printout obj, ref int minPage, ref int maxPage, ref int pageFrom, ref int pageTo)
        {
            obj.GetPageInfo(minPage, maxPage, pageFrom, pageTo);
        }
        public /+virtual+/ void GetPageInfo(ref int minPage, ref int maxPage, ref int pageFrom, ref int pageTo)
        {
            wxPrintout_GetPageInfo(wxobj, minPage, maxPage, pageFrom, pageTo);
        }

        //-----------------------------------------------------------------------------

        public string Title() { return cast(string) new wxString(wxPrintout_GetTitle(wxobj), true); }

        //-----------------------------------------------------------------------------

        public DC Dc() { return cast(DC)FindObject(wxPrintout_GetDC(wxobj), &DC.New); }
        public void Dc(DC value) { wxPrintout_SetDC(wxobj, wxObject.SafePtr(value)); }

        //-----------------------------------------------------------------------------

        public void SetPageSizePixels(int w, int h)
        {
            wxPrintout_SetPageSizePixels(wxobj, w, h);
        }

        public void GetPageSizePixels(out int w, out int h)
        {
            w = h = 0;
            wxPrintout_GetPageSizePixels(wxobj, w, h);
        }

        //-----------------------------------------------------------------------------

        public void SetPageSizeMM(int w, int h)
        {
            wxPrintout_SetPageSizeMM(wxobj, w, h);
        }

        public void GetPageSizeMM(out int w, out int h)
        {
            w = h = 0;
            wxPrintout_GetPageSizeMM(wxobj, w, h);
        }

        //-----------------------------------------------------------------------------

        public void SetPPIScreen(int x, int y)
        {
            wxPrintout_SetPPIScreen(wxobj, x, y);
        }

        //-----------------------------------------------------------------------------

        public void GetPPIScreen(out int x, out int y)
        {
            x = y = 0;
            wxPrintout_GetPPIScreen(wxobj, x, y);
        }

        //-----------------------------------------------------------------------------

        public void SetPPIPrinter(int x, int y)
        {
            wxPrintout_SetPPIPrinter(wxobj, x, y);
        }

        //-----------------------------------------------------------------------------

        public void GetPPIPrinter(out int x, out int y)
        {
            x = y = 0;
            wxPrintout_GetPPIPrinter(wxobj, x, y);
        }

        //-----------------------------------------------------------------------------

        public bool IsPreview() { return wxPrintout_IsPreview(wxobj); }
        public void IsPreview(bool value) { wxPrintout_SetIsPreview(wxobj, value); }
    }

