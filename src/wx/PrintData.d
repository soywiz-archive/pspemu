//-----------------------------------------------------------------------------
// wxD - PrintData.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - PrintData.cs
//
/// The wxPrint data wrapper classes.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: PrintData.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.PrintData;
public import wx.common;

    public enum PrintMode
    {
        wxPRINT_MODE_NONE =    0,
        wxPRINT_MODE_PREVIEW = 1,   // Preview in external application
        wxPRINT_MODE_FILE =    2,   // Print to file
        wxPRINT_MODE_PRINTER = 3    // Send to printer
    }

    public enum PrintQuality
    {
        wxPRINT_QUALITY_HIGH    = -1,
        wxPRINT_QUALITY_MEDIUM  = -2,
        wxPRINT_QUALITY_LOW     = -3,
        wxPRINT_QUALITY_DRAFT   = -4
    }

    public enum DuplexMode
    {
        wxDUPLEX_SIMPLEX, 
        wxDUPLEX_HORIZONTAL,
        wxDUPLEX_VERTICAL
    }

    public enum PaperSize 
    {
        wxPAPER_NONE,               // Use specific dimensions
        wxPAPER_LETTER,             // Letter, 8 1/2 by 11 inches
        wxPAPER_LEGAL,              // Legal, 8 1/2 by 14 inches
        wxPAPER_A4,                 // A4 Sheet, 210 by 297 millimeters
        wxPAPER_CSHEET,             // C Sheet, 17 by 22 inches
        wxPAPER_DSHEET,             // D Sheet, 22 by 34 inches
        wxPAPER_ESHEET,             // E Sheet, 34 by 44 inches
        wxPAPER_LETTERSMALL,        // Letter Small, 8 1/2 by 11 inches
        wxPAPER_TABLOID,            // Tabloid, 11 by 17 inches
        wxPAPER_LEDGER,             // Ledger, 17 by 11 inches
        wxPAPER_STATEMENT,          // Statement, 5 1/2 by 8 1/2 inches
        wxPAPER_EXECUTIVE,          // Executive, 7 1/4 by 10 1/2 inches
        wxPAPER_A3,                 // A3 sheet, 297 by 420 millimeters
        wxPAPER_A4SMALL,            // A4 small sheet, 210 by 297 millimeters
        wxPAPER_A5,                 // A5 sheet, 148 by 210 millimeters
        wxPAPER_B4,                 // B4 sheet, 250 by 354 millimeters
        wxPAPER_B5,                 // B5 sheet, 182-by-257-millimeter paper
        wxPAPER_FOLIO,              // Folio, 8-1/2-by-13-inch paper
        wxPAPER_QUARTO,             // Quarto, 215-by-275-millimeter paper
        wxPAPER_10X14,              // 10-by-14-inch sheet
        wxPAPER_11X17,              // 11-by-17-inch sheet
        wxPAPER_NOTE,               // Note, 8 1/2 by 11 inches
        wxPAPER_ENV_9,              // #9 Envelope, 3 7/8 by 8 7/8 inches
        wxPAPER_ENV_10,             // #10 Envelope, 4 1/8 by 9 1/2 inches
        wxPAPER_ENV_11,             // #11 Envelope, 4 1/2 by 10 3/8 inches
        wxPAPER_ENV_12,             // #12 Envelope, 4 3/4 by 11 inches
        wxPAPER_ENV_14,             // #14 Envelope, 5 by 11 1/2 inches
        wxPAPER_ENV_DL,             // DL Envelope, 110 by 220 millimeters
        wxPAPER_ENV_C5,             // C5 Envelope, 162 by 229 millimeters
        wxPAPER_ENV_C3,             // C3 Envelope, 324 by 458 millimeters
        wxPAPER_ENV_C4,             // C4 Envelope, 229 by 324 millimeters
        wxPAPER_ENV_C6,             // C6 Envelope, 114 by 162 millimeters
        wxPAPER_ENV_C65,            // C65 Envelope, 114 by 229 millimeters
        wxPAPER_ENV_B4,             // B4 Envelope, 250 by 353 millimeters
        wxPAPER_ENV_B5,             // B5 Envelope, 176 by 250 millimeters
        wxPAPER_ENV_B6,             // B6 Envelope, 176 by 125 millimeters
        wxPAPER_ENV_ITALY,          // Italy Envelope, 110 by 230 millimeters
        wxPAPER_ENV_MONARCH,        // Monarch Envelope, 3 7/8 by 7 1/2 inches
        wxPAPER_ENV_PERSONAL,       // 6 3/4 Envelope, 3 5/8 by 6 1/2 inches
        wxPAPER_FANFOLD_US,         // US Std Fanfold, 14 7/8 by 11 inches
        wxPAPER_FANFOLD_STD_GERMAN, // German Std Fanfold, 8 1/2 by 12 inches
        wxPAPER_FANFOLD_LGL_GERMAN, // German Legal Fanfold, 8 1/2 by 13 inches

        wxPAPER_ISO_B4,             // B4 (ISO) 250 x 353 mm
        wxPAPER_JAPANESE_POSTCARD,  // Japanese Postcard 100 x 148 mm
        wxPAPER_9X11,               // 9 x 11 in
        wxPAPER_10X11,              // 10 x 11 in
        wxPAPER_15X11,              // 15 x 11 in
        wxPAPER_ENV_INVITE,         // Envelope Invite 220 x 220 mm
        wxPAPER_LETTER_EXTRA,       // Letter Extra 9 \275 x 12 in
        wxPAPER_LEGAL_EXTRA,        // Legal Extra 9 \275 x 15 in
        wxPAPER_TABLOID_EXTRA,      // Tabloid Extra 11.69 x 18 in
        wxPAPER_A4_EXTRA,           // A4 Extra 9.27 x 12.69 in
        wxPAPER_LETTER_TRANSVERSE,  // Letter Transverse 8 \275 x 11 in
        wxPAPER_A4_TRANSVERSE,      // A4 Transverse 210 x 297 mm
        wxPAPER_LETTER_EXTRA_TRANSVERSE, // Letter Extra Transverse 9\275 x 12 in
        wxPAPER_A_PLUS,             // SuperA/SuperA/A4 227 x 356 mm
        wxPAPER_B_PLUS,             // SuperB/SuperB/A3 305 x 487 mm
        wxPAPER_LETTER_PLUS,        // Letter Plus 8.5 x 12.69 in
        wxPAPER_A4_PLUS,            // A4 Plus 210 x 330 mm
        wxPAPER_A5_TRANSVERSE,      // A5 Transverse 148 x 210 mm
        wxPAPER_B5_TRANSVERSE,      // B5 (JIS) Transverse 182 x 257 mm
        wxPAPER_A3_EXTRA,           // A3 Extra 322 x 445 mm
        wxPAPER_A5_EXTRA,           // A5 Extra 174 x 235 mm
        wxPAPER_B5_EXTRA,           // B5 (ISO) Extra 201 x 276 mm
        wxPAPER_A2,                 // A2 420 x 594 mm
        wxPAPER_A3_TRANSVERSE,      // A3 Transverse 297 x 420 mm
        wxPAPER_A3_EXTRA_TRANSVERSE // A3 Extra Transverse 322 x 445 mm
    }

		//! \cond EXTERN
        static extern (C) IntPtr wxPageSetupDialogData_ctor();
        static extern (C) IntPtr wxPageSetupDialogData_ctorPrintSetup(IntPtr dialogData);
        static extern (C) IntPtr wxPageSetupDialogData_ctorPrintData(IntPtr printData);
        static extern (C) void wxPageSetupDialogData_GetPaperSize(IntPtr self, ref Size size);
        static extern (C) int wxPageSetupDialogData_GetPaperId(IntPtr self);
        static extern (C) void wxPageSetupDialogData_GetMinMarginTopLeft(IntPtr self, ref Point pt);
        static extern (C) void wxPageSetupDialogData_GetMinMarginBottomRight(IntPtr self, ref Point pt);
        static extern (C) void wxPageSetupDialogData_GetMarginTopLeft(IntPtr self, ref Point pt);
        static extern (C) void wxPageSetupDialogData_GetMarginBottomRight(IntPtr self, ref Point pt);
        static extern (C) bool wxPageSetupDialogData_GetDefaultMinMargins(IntPtr self);
        static extern (C) bool wxPageSetupDialogData_GetEnableMargins(IntPtr self);
        static extern (C) bool wxPageSetupDialogData_GetEnableOrientation(IntPtr self);
        static extern (C) bool wxPageSetupDialogData_GetEnablePaper(IntPtr self);
        static extern (C) bool wxPageSetupDialogData_GetEnablePrinter(IntPtr self);
        static extern (C) bool wxPageSetupDialogData_GetDefaultInfo(IntPtr self);
        static extern (C) bool wxPageSetupDialogData_GetEnableHelp(IntPtr self);
        static extern (C) bool wxPageSetupDialogData_Ok(IntPtr self);
        static extern (C) void wxPageSetupDialogData_SetPaperSize(IntPtr self, ref Size sz);
        static extern (C) void wxPageSetupDialogData_SetPaperId(IntPtr self, int id);
        static extern (C) void wxPageSetupDialogData_SetPaperSize(IntPtr self, int id);
        static extern (C) void wxPageSetupDialogData_SetMinMarginTopLeft(IntPtr self, ref Point pt);
        static extern (C) void wxPageSetupDialogData_SetMinMarginBottomRight(IntPtr self, ref Point pt);
        static extern (C) void wxPageSetupDialogData_SetMarginTopLeft(IntPtr self, ref Point pt);
        static extern (C) void wxPageSetupDialogData_SetMarginBottomRight(IntPtr self, ref Point pt);
        static extern (C) void wxPageSetupDialogData_SetDefaultMinMargins(IntPtr self, bool flag);
        static extern (C) void wxPageSetupDialogData_SetDefaultInfo(IntPtr self, bool flag);
        static extern (C) void wxPageSetupDialogData_EnableMargins(IntPtr self, bool flag);
        static extern (C) void wxPageSetupDialogData_EnableOrientation(IntPtr self, bool flag);
        static extern (C) void wxPageSetupDialogData_EnablePaper(IntPtr self, bool flag);
        static extern (C) void wxPageSetupDialogData_EnablePrinter(IntPtr self, bool flag);
        static extern (C) void wxPageSetupDialogData_EnableHelp(IntPtr self, bool flag);
        static extern (C) void wxPageSetupDialogData_CalculateIdFromPaperSize(IntPtr self);
        static extern (C) void wxPageSetupDialogData_CalculatePaperSizeFromId(IntPtr self);
        static extern (C) IntPtr wxPageSetupDialogData_GetPrintData(IntPtr self);
        static extern (C) void wxPageSetupDialogData_SetPrintData(IntPtr self, IntPtr printData);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias PageSetupDialogData wxPageSetupDialogData;
    public class PageSetupDialogData : wxObject
    {
        public this(IntPtr wxobj) 
            { super(wxobj); }

        public this()
            { this(wxPageSetupDialogData_ctor()); }
        public  this(PageSetupDialogData dialogData)
            { this(wxPageSetupDialogData_ctorPrintSetup(wxObject.SafePtr(dialogData))); }
        public  this(PrintData printData)
            { this(wxPageSetupDialogData_ctorPrintData(wxObject.SafePtr(printData))); }

	public static wxObject New(IntPtr ptr) { return new PageSetupDialogData(ptr); }
        //-----------------------------------------------------------------------------

        public Size paperSize() { 
                Size size;
                wxPageSetupDialogData_GetPaperSize(wxobj, size);
                return size;
            }
        public void paperSize(Size value) { wxPageSetupDialogData_SetPaperSize(wxobj, value); }

        public PaperSize PaperId() { return cast(PaperSize)wxPageSetupDialogData_GetPaperId(wxobj); }
        public void PaperId(PaperSize value) { wxPageSetupDialogData_SetPaperId(wxobj, cast(int)value); }

        //-----------------------------------------------------------------------------

        public Point MinMarginTopLeft() { 
                Point pt;
                wxPageSetupDialogData_GetMinMarginTopLeft(wxobj, pt);
                return pt;
            }
        public void MinMarginTopLeft(Point value) { wxPageSetupDialogData_SetMinMarginTopLeft(wxobj, value); }

        public Point MinMarginBottomRight() { 
                Point pt;
                wxPageSetupDialogData_GetMinMarginBottomRight(wxobj, pt);
                return pt;
            }
        public void MinMarginBottomRight(Point value) { wxPageSetupDialogData_SetMinMarginBottomRight(wxobj, value); }

        public Point MarginTopLeft() { 
                Point pt;
                wxPageSetupDialogData_GetMarginTopLeft(wxobj, pt);
                return pt;
            }
        public void MarginTopLeft(Point value) { wxPageSetupDialogData_SetMarginTopLeft(wxobj, value); }

        public Point MarginBottomRight() {
                Point pt;
                wxPageSetupDialogData_GetMarginBottomRight(wxobj, pt);
                return pt;
            } 
        public void MarginBottomRight(Point value) { wxPageSetupDialogData_SetMarginBottomRight(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool DefaultMinMargins() { return wxPageSetupDialogData_GetDefaultMinMargins(wxobj); }
        public void DefaultMinMargins(bool value) { wxPageSetupDialogData_SetDefaultMinMargins(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool EnableOrientation() { return wxPageSetupDialogData_GetEnableOrientation(wxobj); }
        public void EnableOrientation(bool value) { wxPageSetupDialogData_EnableOrientation(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool EnablePaper() { return wxPageSetupDialogData_GetEnablePaper(wxobj); }
        public void EnablePaper(bool value) { wxPageSetupDialogData_EnablePaper(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool EnablePrinter() { return wxPageSetupDialogData_GetEnablePrinter(wxobj); }
        public void EnablePrinter(bool value) { wxPageSetupDialogData_EnablePrinter(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool DefaultInfo() { return wxPageSetupDialogData_GetDefaultInfo(wxobj); }
        public void DefaultInfo(bool value) { wxPageSetupDialogData_SetDefaultInfo(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool EnableHelp() { return wxPageSetupDialogData_GetEnableHelp(wxobj); }
        public void EnableHelp(bool value) { wxPageSetupDialogData_EnableHelp(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool Ok()
        {
            return wxPageSetupDialogData_Ok(wxobj);
        }

        //-----------------------------------------------------------------------------

        public bool EnableMargins() { return wxPageSetupDialogData_GetEnableMargins(wxobj); }
        public void EnableMargins(bool value) { wxPageSetupDialogData_EnableMargins(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void CalculateIdFromPaperSize()
        {
            wxPageSetupDialogData_CalculateIdFromPaperSize(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void CalculatePaperSizeFromId()
        {
            wxPageSetupDialogData_CalculatePaperSizeFromId(wxobj);
        }

        //-----------------------------------------------------------------------------

        public PrintData printData() { return cast(PrintData)FindObject(wxPageSetupDialogData_GetPrintData(wxobj), &PrintData.New); }
        public void printData(PrintData value) { wxPageSetupDialogData_SetPrintData(wxobj, wxObject.SafePtr(value)); }

        //-----------------------------------------------------------------------------
/+
        public static implicit operator PageSetupDialogData (PrintData data)
        {
            return new this(data);
        }
+/
    }

		//! \cond EXTERN
        static extern (C) IntPtr wxPrintDialogData_ctor();
        static extern (C) IntPtr wxPrintDialogData_ctorDialogData(IntPtr dialogData);
        static extern (C) IntPtr wxPrintDialogData_ctorPrintData(IntPtr printData);
        static extern (C) int wxPrintDialogData_GetFromPage(IntPtr self);
        static extern (C) int wxPrintDialogData_GetToPage(IntPtr self);
        static extern (C) int wxPrintDialogData_GetMinPage(IntPtr self);
        static extern (C) int wxPrintDialogData_GetMaxPage(IntPtr self);
        static extern (C) int wxPrintDialogData_GetNoCopies(IntPtr self);
        static extern (C) bool wxPrintDialogData_GetAllPages(IntPtr self);
        static extern (C) bool wxPrintDialogData_GetSelection(IntPtr self);
        static extern (C) bool wxPrintDialogData_GetCollate(IntPtr self);
        static extern (C) bool wxPrintDialogData_GetPrintToFile(IntPtr self);
        static extern (C) bool wxPrintDialogData_GetSetupDialog(IntPtr self);
        static extern (C) void wxPrintDialogData_SetFromPage(IntPtr self, int v);
        static extern (C) void wxPrintDialogData_SetToPage(IntPtr self, int v);
        static extern (C) void wxPrintDialogData_SetMinPage(IntPtr self, int v);
        static extern (C) void wxPrintDialogData_SetMaxPage(IntPtr self, int v);
        static extern (C) void wxPrintDialogData_SetNoCopies(IntPtr self, int v);
        static extern (C) void wxPrintDialogData_SetAllPages(IntPtr self, bool flag);
        static extern (C) void wxPrintDialogData_SetSelection(IntPtr self, bool flag);
        static extern (C) void wxPrintDialogData_SetCollate(IntPtr self, bool flag);
        static extern (C) void wxPrintDialogData_SetPrintToFile(IntPtr self, bool flag);
        static extern (C) void wxPrintDialogData_SetSetupDialog(IntPtr self, bool flag);
        static extern (C) void wxPrintDialogData_EnablePrintToFile(IntPtr self, bool flag);
        static extern (C) void wxPrintDialogData_EnableSelection(IntPtr self, bool flag);
        static extern (C) void wxPrintDialogData_EnablePageNumbers(IntPtr self, bool flag);
        static extern (C) void wxPrintDialogData_EnableHelp(IntPtr self, bool flag);
        static extern (C) bool wxPrintDialogData_GetEnablePrintToFile(IntPtr self);
        static extern (C) bool wxPrintDialogData_GetEnableSelection(IntPtr self);
        static extern (C) bool wxPrintDialogData_GetEnablePageNumbers(IntPtr self);
        static extern (C) bool wxPrintDialogData_GetEnableHelp(IntPtr self);
        static extern (C) bool wxPrintDialogData_Ok(IntPtr self);
        static extern (C) IntPtr wxPrintDialogData_GetPrintData(IntPtr self);
        static extern (C) void wxPrintDialogData_SetPrintData(IntPtr self, IntPtr printData);
		//! \endcond

    alias PrintDialogData wxPrintDialogData;
    public class PrintDialogData : wxObject
    {
        //-----------------------------------------------------------------------------

        public this(IntPtr wxobj)
            { super(wxobj); }

        public this()
            { this(wxPrintDialogData_ctor()); }
        public this(PrintDialogData dialogData)
            { this(wxPrintDialogData_ctorDialogData(wxObject.SafePtr(dialogData))); }
        public this(PrintData printData)
            { this(wxPrintDialogData_ctorPrintData(wxObject.SafePtr(printData))); }
	public static wxObject New(IntPtr ptr) { return new PrintDialogData(ptr); }

        //-----------------------------------------------------------------------------

        public int FromPage() { return wxPrintDialogData_GetFromPage(wxobj); }
        public void FromPage(int value) { wxPrintDialogData_SetFromPage(wxobj, value); }

        public int ToPage() { return wxPrintDialogData_GetToPage(wxobj); }
        public void ToPage(int value) { wxPrintDialogData_SetToPage(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int MinPage() { return wxPrintDialogData_GetMinPage(wxobj); }
        public void MinPage(int value) { wxPrintDialogData_SetMinPage(wxobj, value); }

        public int MaxPage() { return wxPrintDialogData_GetMaxPage(wxobj); }
        public void MaxPage(int value) { wxPrintDialogData_SetMaxPage(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int NoCopies() { return wxPrintDialogData_GetNoCopies(wxobj); }
        public void NoCopies(int value) { wxPrintDialogData_SetNoCopies(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool AllPages() { return wxPrintDialogData_GetAllPages(wxobj); }
        public void AllPages(bool value) { wxPrintDialogData_SetAllPages(wxobj, value); }

        public bool Selection() { return wxPrintDialogData_GetSelection(wxobj); }
        public void Selection(bool value) { wxPrintDialogData_SetSelection(wxobj, value); }

        public bool Collate() { return wxPrintDialogData_GetCollate(wxobj); }
        public void Collate(bool value) { wxPrintDialogData_SetCollate(wxobj, value); }

        public bool PrintToFile() { return wxPrintDialogData_GetPrintToFile(wxobj); }
        public void PrintToFile(bool value) { wxPrintDialogData_SetPrintToFile(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool SetupDialog() { return wxPrintDialogData_GetSetupDialog(wxobj); }
        public void SetupDialog(bool value) { wxPrintDialogData_SetSetupDialog(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void EnablePrintToFile(bool value) { wxPrintDialogData_EnablePrintToFile(wxobj, value); }
        public bool EnablePrintToFile() { return wxPrintDialogData_GetEnablePrintToFile(wxobj); }

        //-----------------------------------------------------------------------------

        public void EnableSelection(bool value) { wxPrintDialogData_EnableSelection(wxobj, value); }
        public bool EnableSelection() { return wxPrintDialogData_GetEnableSelection(wxobj); }

        //-----------------------------------------------------------------------------

        public void EnablePageNumbers(bool value) { wxPrintDialogData_EnablePageNumbers(wxobj, value); }
        public bool EnablePageNumbers() { return wxPrintDialogData_GetEnablePageNumbers(wxobj); }

        //-----------------------------------------------------------------------------

        public void EnableHelp(bool value) { wxPrintDialogData_EnableHelp(wxobj, value); }
        public bool EnableHelp() { return wxPrintDialogData_GetEnableHelp(wxobj); }

        //-----------------------------------------------------------------------------

        public bool Ok()
        {
            return wxPrintDialogData_Ok(wxobj);
        }

        //-----------------------------------------------------------------------------

        public PrintData printData() { return cast(PrintData)FindObject(wxPrintDialogData_GetPrintData(wxobj), &PrintData.New); }
        public void printData(PrintData value) { wxPrintDialogData_SetPrintData(wxobj, wxObject.SafePtr(value)); }
    }

		//! \cond EXTERN
        static extern (C) IntPtr wxPrintData_ctor();
        static extern (C) IntPtr wxPrintData_ctorPrintData(IntPtr printData);
        static extern (C) int wxPrintData_GetNoCopies(IntPtr self);
        static extern (C) bool wxPrintData_GetCollate(IntPtr self);
        static extern (C) int wxPrintData_GetOrientation(IntPtr self);
        static extern (C) bool wxPrintData_Ok(IntPtr self);
        static extern (C) IntPtr wxPrintData_GetPrinterName(IntPtr self);
        static extern (C) bool wxPrintData_GetColour(IntPtr self);
        static extern (C) int wxPrintData_GetDuplex(IntPtr self);
        static extern (C) int wxPrintData_GetPaperId(IntPtr self);
        static extern (C) void wxPrintData_GetPaperSize(IntPtr self, ref Size sz);
        static extern (C) int wxPrintData_GetQuality(IntPtr self);
        static extern (C) void wxPrintData_SetNoCopies(IntPtr self, int v);
        static extern (C) void wxPrintData_SetCollate(IntPtr self, bool flag);
        static extern (C) void wxPrintData_SetOrientation(IntPtr self, int orient);
        static extern (C) void wxPrintData_SetPrinterName(IntPtr self, string name);
        static extern (C) void wxPrintData_SetColour(IntPtr self, bool colour);
        static extern (C) void wxPrintData_SetDuplex(IntPtr self, int duplex);
        static extern (C) void wxPrintData_SetPaperId(IntPtr self, int sizeId);
        static extern (C) void wxPrintData_SetPaperSize(IntPtr self, ref Size sz);
        static extern (C) void wxPrintData_SetQuality(IntPtr self, int quality);
        static extern (C) IntPtr wxPrintData_GetPrinterCommand(IntPtr self);
        static extern (C) IntPtr wxPrintData_GetPrinterOptions(IntPtr self);
        static extern (C) IntPtr wxPrintData_GetPreviewCommand(IntPtr self);
        static extern (C) IntPtr wxPrintData_GetFilename(IntPtr self);
        static extern (C) IntPtr wxPrintData_GetFontMetricPath(IntPtr self);
        static extern (C) double wxPrintData_GetPrinterScaleX(IntPtr self);
        static extern (C) double wxPrintData_GetPrinterScaleY(IntPtr self);
        static extern (C) int wxPrintData_GetPrinterTranslateX(IntPtr self);
        static extern (C) int wxPrintData_GetPrinterTranslateY(IntPtr self);
        static extern (C) int wxPrintData_GetPrintMode(IntPtr self);
        static extern (C) void wxPrintData_SetPrinterCommand(IntPtr self, string command);
        static extern (C) void wxPrintData_SetPrinterOptions(IntPtr self, string options);
        static extern (C) void wxPrintData_SetPreviewCommand(IntPtr self, string command);
        static extern (C) void wxPrintData_SetFilename(IntPtr self, string filename);
        static extern (C) void wxPrintData_SetFontMetricPath(IntPtr self, string path);
        static extern (C) void wxPrintData_SetPrinterScaleX(IntPtr self, double x);
        static extern (C) void wxPrintData_SetPrinterScaleY(IntPtr self, double y);
        static extern (C) void wxPrintData_SetPrinterScaling(IntPtr self, double x, double y);
        static extern (C) void wxPrintData_SetPrinterTranslateX(IntPtr self, int x);
        static extern (C) void wxPrintData_SetPrinterTranslateY(IntPtr self, int y);
        static extern (C) void wxPrintData_SetPrinterTranslation(IntPtr self, int x, int y);
        static extern (C) void wxPrintData_SetPrintMode(IntPtr self, int printMode);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias PrintData wxPrintData;
    public class PrintData : wxObject
    {
        public this(IntPtr wxobj) 
            { super(wxobj); }

        public this()
            { this(wxPrintData_ctor()); }
        public this(PrintData printData)
            { this(wxPrintData_ctorPrintData(wxObject.SafePtr(printData))); }

        public static wxObject New(IntPtr ptr) { return new PrintData(ptr); }

        //-----------------------------------------------------------------------------

        public int NoCopies() { return wxPrintData_GetNoCopies(wxobj); }
        public void NoCopies(int value) { wxPrintData_SetNoCopies(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool Collate() { return wxPrintData_GetCollate(wxobj); }
        public void Collate(bool value) { wxPrintData_SetCollate(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int Orientation() { return wxPrintData_GetOrientation(wxobj); }
        public void Orientation(int value) { wxPrintData_SetOrientation(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool Ok()
        {
            return wxPrintData_Ok(wxobj);
        }

        //-----------------------------------------------------------------------------

        public string PrinterName() { return cast(string) new wxString(wxPrintData_GetPrinterName(wxobj), true); }
        public void PrinterName(string value) { wxPrintData_SetPrinterName(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool Colour() { return wxPrintData_GetColour(wxobj); }
        public void Colour(bool value) { wxPrintData_SetColour(wxobj, value); }

        //-----------------------------------------------------------------------------

        public DuplexMode Duplex() { return cast(DuplexMode)wxPrintData_GetDuplex(wxobj); }
        public void Duplex(DuplexMode value) { wxPrintData_SetDuplex(wxobj, cast(int)value); }

        //-----------------------------------------------------------------------------

        public PaperSize PaperId() { return cast(PaperSize)wxPrintData_GetPaperId(wxobj); }
        public void PaperId(PaperSize value) { wxPrintData_SetPaperId(wxobj, cast(int)value); }

        //-----------------------------------------------------------------------------

        public Size paperSize() { 
                Size sz;
                wxPrintData_GetPaperSize(wxobj, sz);
                return sz;
            }
        public void paperSize(Size value) { wxPrintData_SetPaperSize(wxobj, value); }

        //-----------------------------------------------------------------------------

        public PrintQuality Quality() { return cast(PrintQuality)wxPrintData_GetQuality(wxobj); }
        public void Quality(PrintQuality value) { wxPrintData_SetQuality(wxobj, cast(int)value); }

        //-----------------------------------------------------------------------------

        public string PrinterCommand() { return cast(string) new wxString(wxPrintData_GetPrinterCommand(wxobj), true); }
        public void PrinterCommand(string value) { wxPrintData_SetPrinterCommand(wxobj, value); }

        //-----------------------------------------------------------------------------

        public string PrinterOptions() { return cast(string) new wxString(wxPrintData_GetPrinterOptions(wxobj), true); }
        public void PrinterOptions(string value) { wxPrintData_SetPrinterOptions(wxobj, value); }

        //-----------------------------------------------------------------------------

        public string PreviewCommand() { return cast(string) new wxString(wxPrintData_GetPreviewCommand(wxobj), true); }
        public void PreviewCommand(string value) { wxPrintData_SetPreviewCommand(wxobj, value); }

        //-----------------------------------------------------------------------------

        public string Filename() { return cast(string) new wxString(wxPrintData_GetFilename(wxobj), true); }
        public void Filename(string value) { wxPrintData_SetFilename(wxobj, value); }

        //-----------------------------------------------------------------------------

        public string FontMetricPath() { return cast(string) new wxString(wxPrintData_GetFontMetricPath(wxobj), true); }
        public void FontMetricPath(string value) { wxPrintData_SetFontMetricPath(wxobj, value); }

        //-----------------------------------------------------------------------------

        public double PrinterScaleX() { return wxPrintData_GetPrinterScaleX(wxobj); }
        public void PrinterScaleX(double value) { wxPrintData_SetPrinterScaleX(wxobj, value); }

        //-----------------------------------------------------------------------------

        public double PrinterScaleY() { return wxPrintData_GetPrinterScaleY(wxobj); }
        public void PrinterScaleY(double value) { wxPrintData_SetPrinterScaleY(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int PrinterTranslateX() { return wxPrintData_GetPrinterTranslateX(wxobj); }
        public void PrinterTranslateX(int value) { wxPrintData_SetPrinterTranslateX(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int PrinterTranslateY() { return wxPrintData_GetPrinterTranslateY(wxobj); }
        public void PrinterTranslateY(int value) { wxPrintData_SetPrinterTranslateY(wxobj, value); }

        //-----------------------------------------------------------------------------

        public PrintMode printMode() { return cast(PrintMode)wxPrintData_GetPrintMode(wxobj); }
        public void printMode(PrintMode value) { wxPrintData_SetPrintMode(wxobj, cast(int)value); }

        //-----------------------------------------------------------------------------

        public void SetPrinterScaling(double x, double y)
        {
            wxPrintData_SetPrinterScaling(wxobj, x, y);
        }

        //-----------------------------------------------------------------------------

        public void SetPrinterTranslation(int x, int y)
        {
            wxPrintData_SetPrinterTranslation(wxobj, x, y);
        }
    }

