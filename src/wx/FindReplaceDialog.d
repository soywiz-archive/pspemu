//-----------------------------------------------------------------------------
// wxD - FindReplaceDialog.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - FindReplaceDialog.cs
//
/// The wxFindReplaceDialog wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: FindReplaceDialog.d,v 1.10 2007/01/28 23:06:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.FindReplaceDialog;
public import wx.common;
public import wx.Dialog;
public import wx.CommandEvent;

		//! \cond EXTERN
        static extern (C) IntPtr wxFindReplaceDialog_ctor();
        static extern (C) bool   wxFindReplaceDialog_Create(IntPtr self, IntPtr parent, IntPtr data, string title, uint style);

        static extern (C) IntPtr wxFindReplaceDialog_GetData(IntPtr self);
        static extern (C) void   wxFindReplaceDialog_SetData(IntPtr self, IntPtr data);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias FindReplaceDialog wxFindReplaceDialog;
    public class FindReplaceDialog : Dialog
    {
        public const int wxFR_DOWN       = 1;
        public const int wxFR_WHOLEWORD  = 2;
        public const int wxFR_MATCHCASE  = 4;

        public const int wxFR_REPLACEDIALOG = 1;
        public const int wxFR_NOUPDOWN      = 2;
        public const int wxFR_NOMATCHCASE   = 4;
        public const int wxFR_NOWHOLEWORD   = 8;

        //-----------------------------------------------------------------------------

        public this(IntPtr wxobj) 
            { super(wxobj); }

        public this()
            { super(wxFindReplaceDialog_ctor()); }

        public this(Window parent, FindReplaceData data, string title, int style = 0)
        {
        	super(wxFindReplaceDialog_ctor());
            if (!Create(parent, data, title, style))
            {
                throw new InvalidOperationException("Could not create FindReplaceDialog");
            }
        }

        public bool Create(Window parent, FindReplaceData data, string title, int style = 0)
        {
            return wxFindReplaceDialog_Create(wxobj, wxObject.SafePtr(parent), wxObject.SafePtr(data), title, cast(uint)style);
        }

        //-----------------------------------------------------------------------------

        public FindReplaceData Data() { return cast(FindReplaceData)FindObject(wxFindReplaceDialog_GetData(wxobj), &FindReplaceData.New); }
        public void Data(FindReplaceData value) { wxFindReplaceDialog_SetData(wxobj, wxObject.SafePtr(value)); } 

        //-----------------------------------------------------------------------------

		public void Find_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_FIND, ID, value, this); }
		public void Find_Remove(EventListener value) { RemoveHandler(value, this); }

		public void FindNext_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_FIND_NEXT, ID, value, this); }
		public void FindNext_Remove(EventListener value) { RemoveHandler(value, this); }

		public void FindReplace_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_FIND_REPLACE, ID, value, this); }
		public void FindReplace_Remove(EventListener value) { RemoveHandler(value, this); }

		public void FindReplaceAll_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_FIND_REPLACE_ALL, ID, value, this); }
		public void FindReplaceAll_Remove(EventListener value) { RemoveHandler(value, this); }

		public void FindClose_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_FIND_CLOSE, ID, value, this); }
		public void FindClose_Remove(EventListener value) { RemoveHandler(value, this); }
    }

	//-----------------------------------------------------------------------------

		//! \cond EXTERN
        static extern (C) IntPtr wxFindDialogEvent_ctor(int commandType, int id);

        static extern (C) int    wxFindDialogEvent_GetFlags(IntPtr self);
        static extern (C) void   wxFindDialogEvent_SetFlags(IntPtr self, int flags);

        static extern (C) IntPtr wxFindDialogEvent_GetFindString(IntPtr self);
        static extern (C) void   wxFindDialogEvent_SetFindString(IntPtr self, string str);

        static extern (C) IntPtr wxFindDialogEvent_GetReplaceString(IntPtr self);
        static extern (C) void   wxFindDialogEvent_SetReplaceString(IntPtr self, string str);

        static extern (C) IntPtr wxFindDialogEvent_GetDialog(IntPtr self);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias FindDialogEvent wxFindDialogEvent;
    public class FindDialogEvent : CommandEvent
    {
	static this()
	{
			wxEVT_COMMAND_FIND = wxEvent_EVT_COMMAND_FIND();
			wxEVT_COMMAND_FIND_NEXT = wxEvent_EVT_COMMAND_FIND_NEXT();
			wxEVT_COMMAND_FIND_REPLACE = wxEvent_EVT_COMMAND_FIND_REPLACE();
			wxEVT_COMMAND_FIND_REPLACE_ALL = wxEvent_EVT_COMMAND_FIND_REPLACE_ALL();
			wxEVT_COMMAND_FIND_CLOSE = wxEvent_EVT_COMMAND_FIND_CLOSE();

			AddEventType(wxEVT_COMMAND_FIND,	&FindDialogEvent.New);
			AddEventType(wxEVT_COMMAND_FIND_NEXT,	&FindDialogEvent.New);
			AddEventType(wxEVT_COMMAND_FIND_REPLACE,	&FindDialogEvent.New);
			AddEventType(wxEVT_COMMAND_FIND_REPLACE_ALL,	&FindDialogEvent.New);
			AddEventType(wxEVT_COMMAND_FIND_CLOSE,	&FindDialogEvent.New);
	
	}

        public this(IntPtr wxobj)
            { super(wxobj); }

        public this(int commandType, int id)
            { super(wxFindDialogEvent_ctor(commandType, id)); }

	public static Event New(IntPtr ptr) { return new FindDialogEvent(ptr); }

        //-----------------------------------------------------------------------------

        public int Flags() { return wxFindDialogEvent_GetFlags(wxobj); }
        public void Flags(int value) { wxFindDialogEvent_SetFlags(wxobj, value); }

        //-----------------------------------------------------------------------------

        public string FindString() { return cast(string) new wxString(wxFindDialogEvent_GetFindString(wxobj), true); }
        public void FindString(string value) { wxFindDialogEvent_SetFindString(wxobj, value); }

        //-----------------------------------------------------------------------------

        public string ReplaceString() { return cast(string) new wxString(wxFindDialogEvent_GetReplaceString(wxobj), true); }
        public void ReplaceString(string value) { wxFindDialogEvent_SetReplaceString(wxobj, value); }

        //-----------------------------------------------------------------------------

        public FindReplaceDialog Dialog() { return cast(FindReplaceDialog)FindObject(wxFindDialogEvent_GetDialog(wxobj)); }
    }

	//-----------------------------------------------------------------------------

		//! \cond EXTERN
        static extern (C) IntPtr wxFindReplaceData_ctor(uint flags);

        static extern (C) IntPtr wxFindReplaceData_GetFindString(IntPtr self);
        static extern (C) void   wxFindReplaceData_SetFindString(IntPtr self, string str);

        static extern (C) int    wxFindReplaceData_GetFlags(IntPtr self);
        static extern (C) void   wxFindReplaceData_SetFlags(IntPtr self, int flags);

        static extern (C) void   wxFindReplaceData_SetReplaceString(IntPtr self, string str);
        static extern (C) IntPtr wxFindReplaceData_GetReplaceString(IntPtr self);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias FindReplaceData wxFindReplaceData;
    public class FindReplaceData : wxObject
    {
        public this(IntPtr wxobj)
            { super(wxobj); }

        public this()
            { this(0); }

        public this(int flags)
            { super(wxFindReplaceData_ctor(cast(uint)flags));}

        //-----------------------------------------------------------------------------

        public string FindString() { return cast(string) new wxString(wxFindReplaceData_GetFindString(wxobj), true); }
        public void FindString(string value) { wxFindReplaceData_SetFindString(wxobj, value); }

        //-----------------------------------------------------------------------------

        public string ReplaceString() { return cast(string) new wxString(wxFindReplaceData_GetReplaceString(wxobj), true); }
        public void ReplaceString(string value) { wxFindReplaceData_SetReplaceString(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int Flags() { return wxFindReplaceData_GetFlags(wxobj); }
        public void Flags(int value) { wxFindReplaceData_SetFlags(wxobj, value); }
        
        public static wxObject New(IntPtr ptr) { return new FindReplaceData(ptr); }
    }

