//-----------------------------------------------------------------------------
// wxD - Document.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Document.cs
//
/// The wxDocument wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
// 
// $Id: Document.d,v 1.10 2007/01/28 23:06:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.Document;
public import wx.common;
public import wx.EvtHandler;

//! \cond VERSION
version(NOT_READY_YET){

		//! \cond EXTERN
        static extern (C) IntPtr wxDocument_ctor(IntPtr parent);
        static extern (C) void   wxDocument_SetFilename(IntPtr self, string filename, bool notifyViews);
        static extern (C) IntPtr wxDocument_GetFilename(IntPtr self);
        static extern (C) void   wxDocument_SetTitle(IntPtr self, string title);
        static extern (C) IntPtr wxDocument_GetTitle(IntPtr self);
        static extern (C) void   wxDocument_SetDocumentName(IntPtr self, string name);
        static extern (C) IntPtr wxDocument_GetDocumentName(IntPtr self);
        static extern (C) bool   wxDocument_GetDocumentSaved(IntPtr self);
        static extern (C) void   wxDocument_SetDocumentSaved(IntPtr self, bool saved);
        static extern (C) bool   wxDocument_Close(IntPtr self);
        static extern (C) bool   wxDocument_Save(IntPtr self);
        static extern (C) bool   wxDocument_SaveAs(IntPtr self);
        static extern (C) bool   wxDocument_Revert(IntPtr self);
        //static extern (C) IntPtr wxDocument_SaveObject(IntPtr self, IntPtr stream);
        //static extern (C) IntPtr wxDocument_LoadObject(IntPtr self, IntPtr stream);
        static extern (C) IntPtr wxDocument_GetCommandProcessor(IntPtr self);
        static extern (C) void   wxDocument_SetCommandProcessor(IntPtr self, IntPtr proc);
        static extern (C) bool   wxDocument_DeleteContents(IntPtr self);
        static extern (C) bool   wxDocument_Draw(IntPtr self, IntPtr wxDC);
        static extern (C) bool   wxDocument_IsModified(IntPtr self);
        static extern (C) void   wxDocument_Modify(IntPtr self, bool mod);
        static extern (C) bool   wxDocument_AddView(IntPtr self, IntPtr view);
        static extern (C) bool   wxDocument_RemoveView(IntPtr self, IntPtr view);
        static extern (C) IntPtr wxDocument_GetViews(IntPtr self);
        static extern (C) IntPtr wxDocument_GetFirstView(IntPtr self);
        static extern (C) void   wxDocument_UpdateAllViews(IntPtr self, IntPtr sender, IntPtr hint);
        static extern (C) void   wxDocument_NotifyClosing(IntPtr self);
        static extern (C) bool   wxDocument_DeleteAllViews(IntPtr self);
        static extern (C) IntPtr wxDocument_GetDocumentManager(IntPtr self);
        static extern (C) IntPtr wxDocument_GetDocumentTemplate(IntPtr self);
        static extern (C) void   wxDocument_SetDocumentTemplate(IntPtr self, IntPtr temp);
        static extern (C) bool   wxDocument_GetPrintableName(IntPtr self, IntPtr buf);
        static extern (C) IntPtr wxDocument_GetDocumentWindow(IntPtr self);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias Document wxDocument;
    public class Document : EvtHandler
    {
        public  this(Document parent)
            { super(wxDocument_ctor(wxObject.SafePtr(parent))); }

        //-----------------------------------------------------------------------------

        public void SetFilename(string filename, bool notifyViews)
        {
            wxDocument_SetFilename(wxobj, filename, notifyViews);
        }

        public void Filename(string value) { SetFilename(value, true); }
        public string Filename() { return cast(string) new wxString(wxDocument_GetFilename(wxobj), true); }

        //-----------------------------------------------------------------------------

        public void Title(string value) { wxDocument_SetTitle(wxobj, value); }
        public string Title() { return cast(string) new wxString(wxDocument_GetTitle(wxobj), true); }

        public void DocumentName(string value) { wxDocument_SetDocumentName(wxobj, value); }
        public string DocumentName() { return cast(string) new wxString(wxDocument_GetDocumentName(wxobj), true); }

        //-----------------------------------------------------------------------------

        public bool DocumentSaved() { return wxDocument_GetDocumentSaved(wxobj); }
        public void DocumentSaved(bool value) { wxDocument_SetDocumentSaved(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool Close()
        {
            return wxDocument_Close(wxobj);
        }

        public bool Save()
        {
            return wxDocument_Save(wxobj);
        }

        public bool SaveAs()
        {
            return wxDocument_SaveAs(wxobj);
        }

        public bool Revert()
        {
            return wxDocument_Revert(wxobj);
        }

        //-----------------------------------------------------------------------------

        /*
        public OutputStream SaveObject(OutputStream stream)
        {
            return wxDocument_SaveObject(wxobj, wxObject.SafePtr(stream));
        }

        public InputStream LoadObject(InputStream stream)
        {
            return wxDocument_LoadObject(wxobj, wxObject.SafePtr(stream));
        }*/

        //-----------------------------------------------------------------------------

        /*public CommandProcessor CommandProcessor
        {
            get { return FindObject(wxDocument_GetCommandProcessor(wxobj)); }
            set { wxDocument_SetCommandProcessor(wxobj, wxObject.SafePtr(value)); }
        }*/

        //-----------------------------------------------------------------------------

        public bool DeleteContents()
        {
            return wxDocument_DeleteContents(wxobj);
        }

        //-----------------------------------------------------------------------------

        public bool Draw(DC dc)
        {
            return wxDocument_Draw(wxobj, wxObject.SafePtr(dc));
        }

        //-----------------------------------------------------------------------------

        public bool IsModified() { return wxDocument_IsModified(wxobj); }
        public void IsModified(bool value) { Modify(value); }

        public void Modify(bool mod)
        {
            wxDocument_Modify(wxobj, mod);
        }

        //-----------------------------------------------------------------------------

        /*public bool AddView(View view)
        {
            return wxDocument_AddView(wxobj, wxObject.SafePtr(view));
        }

        public bool RemoveView(View view)
        {
            return wxDocument_RemoveView(wxobj, wxObject.SafePtr(view));
        }*/

        /*
        public List GetViews()
        {
            return wxDocument_GetViews(wxobj);
        }

        public View FirstView() { return wxDocument_GetFirstView(wxobj); }

        public void UpdateAllViews(View sender, wxObject hint)
        {
            wxDocument_UpdateAllViews(wxobj, wxObject.SafePtr(sender), wxObject.SafePtr(hint));
        }*/

        //-----------------------------------------------------------------------------

        public void NotifyClosing()
        {
            wxDocument_NotifyClosing(wxobj);
        }

        //-----------------------------------------------------------------------------

        public bool DeleteAllViews()
        {
            return wxDocument_DeleteAllViews(wxobj);
        }

        //-----------------------------------------------------------------------------

        /*public DocManager DocumentManager
        {
            get { return (DocManager)FindObject(wxDocument_GetDocumentManager(wxobj), DocManager); }
        }

        //-----------------------------------------------------------------------------

        public DocTemplate DocumentTemplate() { return (DocTemplate)FindObject(return wxDocument_GetDocumentTemplate(wxobj), DocTemplate);
        public void DocumentTemplate(DocTemplate value) { wxDocument_SetDocumentTemplate(wxobj, wxObject.SafePtr(value)); }
        }*/

        //-----------------------------------------------------------------------------
/+
        public bool GetPrintableName(out string buf)
        {
            wxString name = "";
            bool ret = wxDocument_GetPrintableName(wxobj, wxObject.SafePtr(name));
            buf = name;

            return ret;
        }
+/
        //-----------------------------------------------------------------------------

        public Window DocumentWindow() { return cast(Window)FindObject(wxDocument_GetDocumentWindow(wxobj)); }
    }
} // version(NOT_READY_YET)
//! \endcond
