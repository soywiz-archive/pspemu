//-----------------------------------------------------------------------------
// wxD - ChoiceDialog.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - ChoiceDialog.cs
//
/// The wxChoiceDialog wrapper classes.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2003 Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: ChoiceDialog.d,v 1.12 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.ChoiceDialog;
public import wx.common;
public import wx.Dialog;
public import wx.ClientData;
public import wx.ArrayInt;

		//! \cond EXTERN
        static extern (C) IntPtr wxSingleChoiceDialog_ctor(IntPtr parent, string message, string caption, int n, string* choices, IntPtr clientData, uint style, ref Point pos);
        static extern (C) void wxSingleChoiceDialog_SetSelection(IntPtr self, int sel);
        static extern (C) int wxSingleChoiceDialog_GetSelection(IntPtr self);
        static extern (C) IntPtr wxSingleChoiceDialog_GetStringSelection(IntPtr self);
        static extern (C) IntPtr wxSingleChoiceDialog_GetSelectionClientData(IntPtr self);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias SingleChoiceDialog wxSingleChoiceDialog;
    public class SingleChoiceDialog : Dialog
    {
        enum {
            wxCHOICEDLG_STYLE	= (wxDEFAULT_DIALOG_STYLE | wxRESIZE_BORDER | wxOK | wxCANCEL | wxCENTRE)
        }
	public const int wxCHOICE_HEIGHT = 150;
	public const int wxCHOICE_WIDTH  = 200;


        // TODO: ClientData... !?!

        public this(IntPtr wxobj)
            { super(wxobj);}

        public  this(Window parent, string message, string caption, string[] choices, ClientData clientData = null, int style =  wxCHOICEDLG_STYLE, Point pos = wxDefaultPosition)
            { super(wxSingleChoiceDialog_ctor(wxObject.SafePtr(parent), message, caption, choices.length, choices.ptr, wxObject.SafePtr(clientData), style, pos));}

        //-----------------------------------------------------------------------------

        public void Selection(int sel)
        {
            wxSingleChoiceDialog_SetSelection(wxobj, sel);
        }

        //-----------------------------------------------------------------------------

        public int Selection()
        {
            return wxSingleChoiceDialog_GetSelection(wxobj);
        }

        //-----------------------------------------------------------------------------

        public string StringSelection()
        {
            return cast(string) new wxString(wxSingleChoiceDialog_GetStringSelection(wxobj), true);
        }

        //-----------------------------------------------------------------------------

        public ClientData SelectionClientData()
        {
            return cast(ClientData)FindObject(wxSingleChoiceDialog_GetSelectionClientData(wxobj));
        }
    }

	//-----------------------------------------------------------------------------

		//! \cond EXTERN
        static extern (C) IntPtr wxMultiChoiceDialog_ctor(IntPtr parent, string message, string caption, int n, string* choices, uint style, ref Point pos);
        static extern (C) void wxMultiChoiceDialog_SetSelections(IntPtr self, int* sel, int numsel);
        static extern (C) IntPtr wxMultiChoiceDialog_GetSelections(IntPtr self);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias MultiChoiceDialog wxMultiChoiceDialog;
    public class MultiChoiceDialog : Dialog
    {
        public this(IntPtr wxobj)
            { super(wxobj);}

        public  this(Window parent, string message, string caption, string[] choices, int style = SingleChoiceDialog.wxCHOICEDLG_STYLE, Point pos = wxDefaultPosition)
            { super(wxMultiChoiceDialog_ctor(wxObject.SafePtr(parent), message, caption, choices.length, choices.ptr, style, pos));}

        //-----------------------------------------------------------------------------

        public void SetSelections(int[] sel)
        {
            wxMultiChoiceDialog_SetSelections(wxobj, sel.ptr, sel.length);
        }

        //-----------------------------------------------------------------------------
	
        public int[] GetSelections()
        {
            return (new ArrayInt(wxMultiChoiceDialog_GetSelections(wxobj), true)).toArray();
        }
        
    }

	//-----------------------------------------------------------------------------

	//! \cond EXTERN
	static extern (C) IntPtr wxGetSingleChoice_func(string message, string caption, int n, string* choices, IntPtr parent, int x, int y, bool centre, int width, int height);
	static extern (C) int wxGetSingleChoiceIndex_func(string message, string caption, int n, string* choices, IntPtr parent, int x, int y, bool centre, int width, int height);
	static extern (C) void* wxGetSingleChoiceData_func(string message, string caption, int n, string* choices, void **client_data, IntPtr parent, int x, int y, bool centre, int width, int height);
	static extern (C) uint wxGetMultipleChoices_func(IntPtr selections,string message, string caption, int n, string* choices, IntPtr parent, int x, int y, bool centre, int width, int height);
	//! \endcond

	public string GetSingleChoice(string message, string caption, string[] choices, Window parent = null, int x = -1, int y= -1, bool centre = true, int width = SingleChoiceDialog.wxCHOICE_WIDTH, int height = SingleChoiceDialog.wxCHOICE_HEIGHT)
	{
		return cast(string) new wxString(wxGetSingleChoice_func(message, caption, choices.length, choices.ptr, wxObject.SafePtr(parent), x, y, centre, width, height), true);
	}

	public int GetSingleChoiceIndex(string message, string caption, string[] choices, Window parent = null, int x = -1, int y= -1, bool centre = true, int width = SingleChoiceDialog.wxCHOICE_WIDTH, int height = SingleChoiceDialog.wxCHOICE_HEIGHT)
	{
		return wxGetSingleChoiceIndex_func(message, caption, choices.length, choices.ptr, wxObject.SafePtr(parent), x, y, centre, width, height);
	}

	public void* GetSingleChoiceData(string message, string caption, string[] choices, void **client_data, Window parent = null, int x = -1, int y= -1, bool centre = true, int width = SingleChoiceDialog.wxCHOICE_WIDTH, int height = SingleChoiceDialog.wxCHOICE_HEIGHT)
	{
		return wxGetSingleChoiceData_func(message, caption, choices.length, choices.ptr, client_data, wxObject.SafePtr(parent), x, y, centre, width, height);
	}

	public int[] GetMultipleChoices(string message, string caption, string[] choices, Window parent = null, int x = -1, int y= -1, bool centre = true, int width = SingleChoiceDialog.wxCHOICE_WIDTH, int height = SingleChoiceDialog.wxCHOICE_HEIGHT)
	{
		ArrayInt ari = new ArrayInt();
		uint sz = wxGetMultipleChoices_func(wxObject.SafePtr(ari), message, caption, choices.length, choices.ptr, wxObject.SafePtr(parent), x, y, centre, width, height);
		return ari.toArray();
	}
