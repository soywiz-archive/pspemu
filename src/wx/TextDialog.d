//-----------------------------------------------------------------------------
// wxD - TextDialog.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - TextDialog.cs
//
/// The wxTextEntryDialog wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2003 Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: TextDialog.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.TextDialog;
public import wx.common;
public import wx.Dialog;

		//! \cond EXTERN
        static extern (C) IntPtr wxTextEntryDialog_ctor(IntPtr parent, string message, string caption, string value, uint style, ref Point pos);
        static extern (C) void wxTextEntryDialog_dtor(IntPtr self);
        static extern (C) void wxTextEntryDialog_SetValue(IntPtr self, string val);
        static extern (C) IntPtr wxTextEntryDialog_GetValue(IntPtr self);
        static extern (C) int wxTextEntryDialog_ShowModal(IntPtr self);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias TextEntryDialog wxTextEntryDialog;
    public class TextEntryDialog : Dialog
    {
    	enum {
        wxTextEntryDialogStyle = (wxOK | wxCANCEL | wxCENTRE),
	}
	public const string wxGetTextFromUserPromptStr = "Input Text";

        public this(IntPtr wxobj)
            { super(wxobj);}

        public  this(Window parent, string message=wxGetTextFromUserPromptStr, string caption="", string value="", int style=wxTextEntryDialogStyle, Point pos=wxDefaultPosition)
            { this(wxTextEntryDialog_ctor(wxObject.SafePtr(parent), message, caption, value, cast(uint)style, pos)); }

        //-----------------------------------------------------------------------------

        public string Value() { return cast(string) new wxString(wxTextEntryDialog_GetValue(wxobj), true); }
        public void Value(string value) { wxTextEntryDialog_SetValue(wxobj, value); }

        //---------------------------------------------------------------------

        public override int ShowModal()
        {
            return wxTextEntryDialog_ShowModal(wxobj);
        }
    }

    //-----------------------------------------------------------------------------

		//! \cond EXTERN
        static extern (C) IntPtr wxGetPasswordFromUser_func(string message, string caption, string defaultValue, IntPtr parent);
        static extern (C) IntPtr wxGetTextFromUser_func(string message, string caption, string defaultValue, IntPtr parent, int x, int y, bool centre);
		//! \endcond

        //-----------------------------------------------------------------------------

        public string GetPasswordFromUser(string message, string caption=TextEntryDialog.wxGetTextFromUserPromptStr, string defaultValue="", Window parent=null)
        {
            return cast(string) new wxString(wxGetPasswordFromUser_func(message, caption, defaultValue, wxObject.SafePtr(parent)), true);
        }

        //-----------------------------------------------------------------------------

        public string GetTextFromUser(string message, string caption=TextEntryDialog.wxGetTextFromUserPromptStr, string defaultValue="", Window parent=null, int x=-1, int y=-1, bool centre=true)
        {
            return cast(string) new wxString(wxGetTextFromUser_func(message, caption, defaultValue, wxObject.SafePtr(parent), x, y, centre), true);
        }
