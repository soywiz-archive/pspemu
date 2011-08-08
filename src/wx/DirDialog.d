//-----------------------------------------------------------------------------
// wxD - DirDialog.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - DirDialog.cs
//
/// The wxDirDialog wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: DirDialog.d,v 1.11 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.DirDialog;
public import wx.common;
public import wx.Dialog;

		//! \cond EXTERN
        static extern (C) IntPtr wxDirDialog_ctor(IntPtr parent, string message, string defaultPath, uint style, ref Point pos, ref Size size, string name);

        static extern (C) void   wxDirDialog_SetPath(IntPtr self, string path);
        static extern (C) IntPtr wxDirDialog_GetPath(IntPtr self);

        static extern (C) int    wxDirDialog_GetStyle(IntPtr self);
        static extern (C) void   wxDirDialog_SetStyle(IntPtr self, int style);

        static extern (C) void   wxDirDialog_SetMessage(IntPtr self, string message);
        static extern (C) IntPtr wxDirDialog_GetMessage(IntPtr self);

        static extern (C) int    wxDirDialog_ShowModal(IntPtr self);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias DirDialog wxDirDialog;
    public class DirDialog : Dialog
    {
	enum {  wxDD_NEW_DIR_BUTTON  = 0x0080 }
	enum {  wxDD_DEFAULT_STYLE = (wxDEFAULT_DIALOG_STYLE | wxRESIZE_BORDER | wxDD_NEW_DIR_BUTTON) }

	public const string wxDirSelectorPromptStr = "Select a directory";
	public const string wxDirDialogNameStr = "DirDialog";
	
        public this(IntPtr wxobj) 
            { super(wxobj); }

        public this(Window parent, string title = wxDirSelectorPromptStr, string defaultPath = "", int style = wxDD_DEFAULT_STYLE, Point pos = wxDefaultPosition, Size size = wxDefaultSize, string name = wxDirDialogNameStr)
            { this(wxDirDialog_ctor(wxObject.SafePtr(parent), title, defaultPath, style, pos, size, name)); }

        //-----------------------------------------------------------------------------

        public void Path(string value) { wxDirDialog_SetPath(wxobj, value); }
        public string Path() { return cast(string) new wxString(wxDirDialog_GetPath(wxobj), true); }

        //-----------------------------------------------------------------------------

        public void Message(string value) { wxDirDialog_SetMessage(wxobj, value); }
        public string Message() { return cast(string) new wxString(wxDirDialog_GetMessage(wxobj), true); }

        //-----------------------------------------------------------------------------

        public override int ShowModal()
        {
            return wxDirDialog_ShowModal(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void Style(int value) { wxDirDialog_SetStyle(wxobj, value); }
        public int Style() { return wxDirDialog_GetStyle(wxobj); }

        //-----------------------------------------------------------------------------
    }

	//! \cond EXTERN
	extern (C) string wxDirSelector_func(string message,
              string defaultPath,
              int style,
              ref Point pos,
              IntPtr parent);
	//! \endcond

	string DirSelector(string message = null,
              string defaultPath = null,
              int style = DirDialog.wxDD_DEFAULT_STYLE ,
              Point pos = Dialog.wxDefaultPosition,
              Window parent = null)
	{
		return wxDirSelector_func(message,defaultPath,style,pos,wxObject.SafePtr(parent));
	}
