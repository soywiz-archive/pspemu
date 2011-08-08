//-----------------------------------------------------------------------------
// wxD - ToolBar.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - ToolBar.cs
//
/// The wxToolBar wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: ToolBar.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.ToolBar;
public import wx.common;
public import wx.Bitmap;
public import wx.Control;
public import wx.ClientData;

		//! \cond EXTERN
		static extern (C) IntPtr wxToolBarToolBase_ctor(IntPtr tbar, int toolid, string label, IntPtr bmpNormal, IntPtr bmpDisabled, int kind, IntPtr clientData, string shortHelpString, string longHelpString);
		static extern (C) IntPtr wxToolBarToolBase_ctorCtrl(IntPtr tbar, IntPtr control);
		static extern (C) int    wxToolBarToolBase_GetId(IntPtr self);
		static extern (C) IntPtr wxToolBarToolBase_GetControl(IntPtr self);
		static extern (C) IntPtr wxToolBarToolBase_GetToolBar(IntPtr self);
		static extern (C) bool   wxToolBarToolBase_IsButton(IntPtr self);
		static extern (C) bool   wxToolBarToolBase_IsControl(IntPtr self);
		static extern (C) bool   wxToolBarToolBase_IsSeparator(IntPtr self);
		static extern (C) int    wxToolBarToolBase_GetStyle(IntPtr self);
		static extern (C) int    wxToolBarToolBase_GetKind(IntPtr self);
		static extern (C) bool   wxToolBarToolBase_IsEnabled(IntPtr self);
		static extern (C) bool   wxToolBarToolBase_IsToggled(IntPtr self);
		static extern (C) bool   wxToolBarToolBase_CanBeToggled(IntPtr self);
		static extern (C) IntPtr wxToolBarToolBase_GetLabel(IntPtr self);
		static extern (C) IntPtr wxToolBarToolBase_GetShortHelp(IntPtr self);
		static extern (C) IntPtr wxToolBarToolBase_GetLongHelp(IntPtr self);
		static extern (C) IntPtr wxToolBarToolBase_GetClientData(IntPtr self);
		static extern (C) bool   wxToolBarToolBase_Enable(IntPtr self, bool enable);
		static extern (C) bool   wxToolBarToolBase_Toggle(IntPtr self, bool toggle);
		static extern (C) bool   wxToolBarToolBase_SetToggle(IntPtr self, bool toggle);
		static extern (C) bool   wxToolBarToolBase_SetShortHelp(IntPtr self, string help);
		static extern (C) bool   wxToolBarToolBase_SetLongHelp(IntPtr self, string help);
		static extern (C) void   wxToolBarToolBase_Toggle(IntPtr self);
		static extern (C) void   wxToolBarToolBase_SetNormalBitmap(IntPtr self, IntPtr bmp);
		static extern (C) void   wxToolBarToolBase_SetDisabledBitmap(IntPtr self, IntPtr bmp);
		static extern (C) void   wxToolBarToolBase_SetLabel(IntPtr self, string label);
		static extern (C) void   wxToolBarToolBase_SetClientData(IntPtr self, IntPtr clientData);
		static extern (C) void   wxToolBarToolBase_Detach(IntPtr self);
		static extern (C) void   wxToolBarToolBase_Attach(IntPtr self, IntPtr tbar);
		//! \endcond

       //---------------------------------------------------------------------
        
	alias ToolBarTool wxToolBarTool;
	public class ToolBarTool : wxObject
	{
        public this(IntPtr wxobj) 
            { super(wxobj); }

        public this(ToolBar tbar = null, int toolid = wxID_SEPARATOR, string label = "", Bitmap bmpNormal = Bitmap.wxNullBitmap, Bitmap bmpDisabled = Bitmap.wxNullBitmap, ItemKind kind = ItemKind.wxITEM_NORMAL, ClientData clientData = null, string shortHelpString = "", string longHelpString = "")
            { this(wxToolBarToolBase_ctor(wxObject.SafePtr(tbar), toolid, label, wxObject.SafePtr(bmpNormal), wxObject.SafePtr(bmpDisabled), cast(int)kind, wxObject.SafePtr(clientData), shortHelpString, longHelpString)); }

        public this(ToolBar tbar, Control control)
            { this(wxToolBarToolBase_ctorCtrl(wxObject.SafePtr(tbar), wxObject.SafePtr(control))); }


	public static wxObject New(IntPtr ptr) { return new ToolBarTool(ptr); }
        //---------------------------------------------------------------------

		public int ID() {return wxToolBarToolBase_GetId(wxobj); }

		public Control control() { return cast(Control)FindObject(wxToolBarToolBase_GetControl(wxobj)); }

		public ToolBar toolBar() { return cast(ToolBar)FindObject(wxToolBarToolBase_GetToolBar(wxobj), &ToolBar.New); }

        //---------------------------------------------------------------------

		public bool IsButton() { return wxToolBarToolBase_IsButton(wxobj); }

		bool IsControl() { return wxToolBarToolBase_IsControl(wxobj); }

		bool IsSeparator() { return wxToolBarToolBase_IsSeparator(wxobj); }

        //---------------------------------------------------------------------

		public int Style() { return wxToolBarToolBase_GetStyle(wxobj); }

		public ItemKind Kind() { return cast(ItemKind)wxToolBarToolBase_GetKind(wxobj); }

        //---------------------------------------------------------------------

		bool CanBeToggled()
        {
            return wxToolBarToolBase_CanBeToggled(wxobj);
        }

        //---------------------------------------------------------------------

		public string Label() { return cast(string) new wxString(wxToolBarToolBase_GetLabel(wxobj), true); }
		public void Label(string value) { wxToolBarToolBase_SetLabel(wxobj, value); }

		public string ShortHelp() { return cast(string) new wxString(wxToolBarToolBase_GetShortHelp(wxobj), true); }
		public void ShortHelp(string value) { wxToolBarToolBase_SetShortHelp(wxobj, value); }

		public string LongHelp() { return cast(string) new wxString(wxToolBarToolBase_GetLongHelp(wxobj), true); }
		public void LongHelp(string value) { wxToolBarToolBase_SetLongHelp(wxobj, value); }

        //---------------------------------------------------------------------
        
		public ClientData clientData() { return cast(ClientData)FindObject(wxToolBarToolBase_GetClientData(wxobj)); }
		public void clientData(ClientData value) { wxToolBarToolBase_SetClientData(wxobj, wxObject.SafePtr(value)); }

        //---------------------------------------------------------------------

		public void Enabled(bool value) { wxToolBarToolBase_Enable(wxobj, value); }
		public bool Enabled() {return wxToolBarToolBase_IsEnabled(wxobj); }

		public void Toggled(bool value) { wxToolBarToolBase_SetToggle(wxobj, value); }
		public bool Toggled() { return wxToolBarToolBase_IsToggled(wxobj); }

        //---------------------------------------------------------------------

		public void NormalBitmap(Bitmap value) { wxToolBarToolBase_SetNormalBitmap(wxobj, wxObject.SafePtr(value)); }

		public void DisabledBitmap(Bitmap value) { wxToolBarToolBase_SetDisabledBitmap(wxobj, wxObject.SafePtr(value)); }

        //---------------------------------------------------------------------

		void Detach()
        {
            wxToolBarToolBase_Detach(wxobj);
        }

		void Attach(ToolBar tbar)
        {
            wxToolBarToolBase_Attach(wxobj, wxObject.SafePtr(tbar));
        }

        //---------------------------------------------------------------------
	}

		//! \cond EXTERN
		static extern (C) IntPtr wxToolBar_ctor(IntPtr parent, int id, ref Point pos, ref Size size, uint style);
		static extern (C) IntPtr wxToolBar_AddTool1(IntPtr self, int toolid, string label, IntPtr bitmap, IntPtr bmpDisabled, int kind, string shortHelp, string longHelp, IntPtr data);
		static extern (C) IntPtr wxToolBar_AddTool2(IntPtr self, int toolid, string label, IntPtr bitmap, string shortHelp, int kind);
		static extern (C) IntPtr wxToolBar_AddCheckTool(IntPtr self, int toolid, string label, IntPtr bitmap, IntPtr bmpDisabled, string shortHelp, string longHelp, IntPtr data);
		static extern (C) IntPtr wxToolBar_AddRadioTool(IntPtr self, int toolid, string label, IntPtr bitmap, IntPtr bmpDisabled, string shortHelp, string longHelp, IntPtr data);
		static extern (C) IntPtr wxToolBar_AddControl(IntPtr self, IntPtr control);
		static extern (C) IntPtr wxToolBar_InsertControl(IntPtr self, int pos, IntPtr control);
		static extern (C) IntPtr wxToolBar_FindControl(IntPtr self, int toolid);
		static extern (C) IntPtr wxToolBar_AddSeparator(IntPtr self);
		static extern (C) IntPtr wxToolBar_InsertSeparator(IntPtr self, int pos);
		static extern (C) IntPtr wxToolBar_RemoveTool(IntPtr self, int toolid);
		static extern (C) bool   wxToolBar_DeleteToolByPos(IntPtr self, int pos);
		static extern (C) bool   wxToolBar_DeleteTool(IntPtr self, int toolid);
		static extern (C) void   wxToolBar_ClearTools(IntPtr self);
		static extern (C) bool   wxToolBar_Realize(IntPtr self);
		static extern (C) void   wxToolBar_EnableTool(IntPtr self, int toolid, bool enable);
		static extern (C) void   wxToolBar_ToggleTool(IntPtr self, int toolid, bool toggle);
		static extern (C) IntPtr wxToolBar_GetToolClientData(IntPtr self, int toolid);
		static extern (C) void   wxToolBar_SetToolClientData(IntPtr self, int toolid, IntPtr clientData);
		static extern (C) bool   wxToolBar_GetToolState(IntPtr self, int toolid);
		static extern (C) bool   wxToolBar_GetToolEnabled(IntPtr self, int toolid);
		static extern (C) void   wxToolBar_SetToolShortHelp(IntPtr self, int toolid, string helpString);
		static extern (C) IntPtr wxToolBar_GetToolShortHelp(IntPtr self, int toolid);
		static extern (C) void   wxToolBar_SetToolLongHelp(IntPtr self, int toolid, string helpString);
		static extern (C) IntPtr wxToolBar_GetToolLongHelp(IntPtr self, int toolid);
		static extern (C) void   wxToolBar_SetMargins(IntPtr self, int x, int y);
		static extern (C) void   wxToolBar_SetToolPacking(IntPtr self, int packing);
		static extern (C) void   wxToolBar_SetToolSeparation(IntPtr self, int separation);
		static extern (C) void   wxToolBar_GetToolMargins(IntPtr self, ref Size size);
		static extern (C) int    wxToolBar_GetToolPacking(IntPtr self);
		static extern (C) int    wxToolBar_GetToolSeparation(IntPtr self);
		static extern (C) void   wxToolBar_SetRows(IntPtr self, int nRows);
		static extern (C) void   wxToolBar_SetMaxRowsCols(IntPtr self, int rows, int cols);
		static extern (C) int    wxToolBar_GetMaxRows(IntPtr self);
		static extern (C) int    wxToolBar_GetMaxCols(IntPtr self);
		static extern (C) void   wxToolBar_SetToolBitmapSize(IntPtr self, ref Size size);
		static extern (C) void   wxToolBar_GetToolBitmapSize(IntPtr self, ref Size size);
		static extern (C) void   wxToolBar_GetToolSize(IntPtr self, ref Size size);
		static extern (C) IntPtr wxToolBar_FindToolForPosition(IntPtr self, int x, int y);
		static extern (C) bool   wxToolBar_IsVertical(IntPtr self);
		static extern (C) IntPtr wxToolBar_AddTool3(IntPtr self, int toolid, IntPtr bitmap, IntPtr bmpDisabled, bool toggle, IntPtr clientData, string shortHelpString, string longHelpString);
		static extern (C) IntPtr wxToolBar_AddTool4(IntPtr self, int toolid, IntPtr bitmap, string shortHelpString, string longHelpString);
		static extern (C) IntPtr wxToolBar_AddTool5(IntPtr self, int toolid, IntPtr bitmap, IntPtr bmpDisabled, bool toggle, int xPos, int yPos, IntPtr clientData, string shortHelp, string longHelp);
		static extern (C) IntPtr wxToolBar_InsertTool(IntPtr self, int pos, int toolid, IntPtr bitmap, IntPtr bmpDisabled, bool toggle, IntPtr clientData, string shortHelp, string longHelp);
		static extern (C) bool   wxToolBar_AcceptsFocus(IntPtr self);
		//! \endcond

        //---------------------------------------------------------------------

	alias ToolBar wxToolBar;
	public class ToolBar : Control
	{
		enum {
			wxTB_HORIZONTAL   = Orientation.wxHORIZONTAL,
			wxTB_VERTICAL     = Orientation.wxVERTICAL,
			wxTB_3DBUTTONS    = 0x0010,
			wxTB_FLAT         = 0x0020,
			wxTB_DOCKABLE     = 0x0040,
			wxTB_NOICONS      = 0x0080,
			wxTB_TEXT         = 0x0100,
			wxTB_NODIVIDER    = 0x0200,
			wxTB_NOALIGN      = 0x0400,
			wxTB_HORZ_LAYOUT  = 0x0800,
			wxTB_HORZ_TEXT    = wxTB_HORZ_LAYOUT | wxTB_TEXT
		}
	
		//---------------------------------------------------------------------

        public this(IntPtr wxobj) 
            { super(wxobj); }

        public this(Window parent, int id, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = wxNO_BORDER|wxTB_HORIZONTAL)
            { this(wxToolBar_ctor(wxObject.SafePtr(parent), id, pos, size, style)); }
	    
	//---------------------------------------------------------------------
	// ctors with self created id
	    
        public this(Window parent, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = wxNO_BORDER|wxTB_HORIZONTAL)
	    { this(parent, Window.UniqueID, pos, size, style);}

        //---------------------------------------------------------------------

        public ToolBarTool AddTool(int toolid, string label, Bitmap bitmap)
        {
            return AddTool(toolid, label, bitmap, "", cast(ItemKind)0);
        }

        public ToolBarTool AddTool(int toolid, string label, Bitmap bitmap, Bitmap bmpDisabled, ItemKind kind, string shortHelp, string longHelp, ClientData clientData)
        {
            return new ToolBarTool(wxToolBar_AddTool1(wxobj, toolid, label, wxObject.SafePtr(bitmap), wxObject.SafePtr(bmpDisabled), cast(int)kind, shortHelp, longHelp, wxObject.SafePtr(clientData)));
        }

        public ToolBarTool AddTool(int toolid, string label, Bitmap bitmap, string shortHelp, ItemKind kind = ItemKind.wxITEM_NORMAL)
        {
            return new ToolBarTool(wxToolBar_AddTool2(wxobj, toolid, label, wxObject.SafePtr(bitmap), shortHelp, cast(int)kind));
        }

        public ToolBarTool AddTool(int toolid, Bitmap bitmap, Bitmap bmpDisabled, bool toggle, ClientData clientData, string shortHelpString, string longHelpString)
        {
            return new ToolBarTool(wxToolBar_AddTool3(wxobj, toolid, wxObject.SafePtr(bitmap), wxObject.SafePtr(bmpDisabled), toggle, wxObject.SafePtr(clientData), shortHelpString, longHelpString));
        }

        public ToolBarTool AddTool(int toolid, Bitmap bitmap, string shortHelpString)
            { return AddTool(toolid, bitmap, shortHelpString, ""); }
        public ToolBarTool AddTool(int toolid, Bitmap bitmap, string shortHelpString, string longHelpString)
        {
            return new ToolBarTool(wxToolBar_AddTool4(wxobj, toolid, wxObject.SafePtr(bitmap), shortHelpString, longHelpString));
        }

        public ToolBarTool AddTool(int toolid, Bitmap bitmap, Bitmap bmpDisabled, bool toggle, int xPos, int yPos, ClientData clientData, string shortHelp, string longHelp)
        {
            return new ToolBarTool(wxToolBar_AddTool5(wxobj, toolid, wxObject.SafePtr(bitmap), wxObject.SafePtr(bmpDisabled), toggle, xPos, yPos, wxObject.SafePtr(clientData), shortHelp, longHelp));
        }

        //---------------------------------------------------------------------
        
        public ToolBarTool InsertTool(int pos, int toolid, Bitmap bitmap, Bitmap bmpDisabled, bool toggle, ClientData clientData, string shortHelp, string longHelp)
        {
            return new ToolBarTool(wxToolBar_InsertTool(wxobj, pos, toolid, wxObject.SafePtr(bitmap), wxObject.SafePtr(bmpDisabled), toggle, wxObject.SafePtr(clientData), shortHelp, longHelp));
        }

        //---------------------------------------------------------------------

        public ToolBarTool AddCheckTool(int toolid, string label, Bitmap bitmap, Bitmap bmpDisabled, string shortHelp, string longHelp)
        {
            return new ToolBarTool(wxToolBar_AddCheckTool(wxobj, toolid, label, wxObject.SafePtr(bitmap), wxObject.SafePtr(bmpDisabled), shortHelp, longHelp, wxObject.SafePtr(null)));
        }

        public ToolBarTool AddRadioTool(int toolid, string label, Bitmap bitmap, Bitmap bmpDisabled, string shortHelp, string longHelp)
        {
            return new ToolBarTool(wxToolBar_AddRadioTool(wxobj, toolid, label, wxObject.SafePtr(bitmap), wxObject.SafePtr(bmpDisabled), shortHelp, longHelp, wxObject.SafePtr(null)));
        }

        //---------------------------------------------------------------------

        public ToolBarTool AddControl(Control ctrl)
        {
            return new ToolBarTool(wxToolBar_AddControl(wxobj, wxObject.SafePtr(ctrl)));
        }

        public ToolBarTool InsertControl(int pos, Control ctrl)
        {
            return new ToolBarTool(wxToolBar_InsertControl(wxobj, pos, wxObject.SafePtr(ctrl)));
        }

        public ToolBarTool FindControl(int toolid)
        {
            return cast(ToolBarTool)FindObject(wxToolBar_FindControl(wxobj, toolid), &ToolBarTool.New);
        }

        //---------------------------------------------------------------------

        public ToolBarTool AddSeparator()
        {
            return new ToolBarTool(wxToolBar_AddSeparator(wxobj));
        }

        public ToolBarTool InsertSeparator(int pos)
        {
            return new ToolBarTool(wxToolBar_InsertSeparator(wxobj, pos));
        }

        //---------------------------------------------------------------------

        public ToolBarTool RemoveTool(int toolid)
        {
            return cast(ToolBarTool)FindObject(wxToolBar_RemoveTool(wxobj, toolid), &ToolBarTool.New);
        }

        public bool DeleteToolByPos(int pos)
        {
            return wxToolBar_DeleteToolByPos(wxobj, pos);
        }

        public bool DeleteTool(int toolid)
        {
            return wxToolBar_DeleteTool(wxobj, toolid);
        }

        public void ClearTools()
        {
            wxToolBar_ClearTools(wxobj);
        }

        //---------------------------------------------------------------------

        public bool Realize()
        {
            return wxToolBar_Realize(wxobj);
        }

        //---------------------------------------------------------------------

        public void EnableTool(int toolid, bool enable)
        {
            wxToolBar_EnableTool(wxobj, toolid, enable);
        }

        public void ToggleTool(int toolid, bool toggle)
        {
            wxToolBar_ToggleTool(wxobj, toolid, toggle);
        }

        //---------------------------------------------------------------------

        public void SetToolClientData(int toolid, ClientData clientData)
        {
            wxToolBar_SetToolClientData(wxobj, toolid, wxObject.SafePtr(clientData));
        }

        public ClientData GetToolClientData(int toolid)
        {
            return cast(ClientData)wxObject.FindObject(wxToolBar_GetToolClientData(wxobj, toolid));
        }

        //---------------------------------------------------------------------
        
        public bool GetToolState(int toolid)
        {
            return wxToolBar_GetToolState(wxobj, toolid);
        }

        public bool GetToolEnable(int toolid)
        {
            return wxToolBar_GetToolEnabled(wxobj, toolid);
        }

        //---------------------------------------------------------------------

        public string GetToolShortHelp(int toolid)
        {
            return cast(string) new wxString(wxToolBar_GetToolShortHelp(wxobj, toolid), true);
        }

        public void SetToolShortHelp(int toolid, string helpString)
        {
            wxToolBar_SetToolShortHelp(wxobj, toolid, helpString);
        }

        //---------------------------------------------------------------------

        public string GetToolLongHelp(int toolid)
        {
            return cast(string) new wxString(wxToolBar_GetToolLongHelp(wxobj, toolid), true);
        }

        public void SetToolLongHelp(int toolid, string helpString)
        {
            wxToolBar_SetToolLongHelp(wxobj, toolid, helpString);
        }

        //---------------------------------------------------------------------

        public void SetMargins(int x, int y) { wxToolBar_SetMargins(wxobj, x, y); }

        public Size Margins()
        { 
		Size size;
		wxToolBar_GetToolMargins(wxobj, size);
		return size;
	}
        public void Margins(Size value) { wxToolBar_SetMargins(wxobj, value.Width, value.Height); }

        //---------------------------------------------------------------------

        public int ToolPacking() { return wxToolBar_GetToolPacking(wxobj); }
        public void ToolPacking(int value) { wxToolBar_SetToolPacking(wxobj, value); }

        //---------------------------------------------------------------------

        public int Separation() { return wxToolBar_GetToolSeparation(wxobj); }
        public void Separation(int value) { wxToolBar_SetToolSeparation(wxobj, value); }

        //---------------------------------------------------------------------

        public void Rows(int value) { wxToolBar_SetRows(wxobj, value); }

        public int MaxRows() { return wxToolBar_GetMaxRows(wxobj); }

        public int MaxCols() { return wxToolBar_GetMaxCols(wxobj); }

        //---------------------------------------------------------------------

        public void SetMaxRowsCols(int rows, int cols)
        {
            wxToolBar_SetMaxRowsCols(wxobj, rows, cols);
        }

        //---------------------------------------------------------------------

        public Size ToolBitmapSize() { 
                Size size;
                wxToolBar_GetToolBitmapSize(wxobj, size); 
                return size;
            }
        public void ToolBitmapSize(Size value) { wxToolBar_SetToolBitmapSize(wxobj, value); }

        //---------------------------------------------------------------------

        public Size ToolSize() { 
                Size size;
                wxToolBar_GetToolSize(wxobj, size); 
                return size;
            }

        //---------------------------------------------------------------------

        public ToolBarTool FindToolForPosition(int x, int y)
        {
            return cast(ToolBarTool)FindObject(wxToolBar_FindToolForPosition(wxobj, x, y), &ToolBarTool.New);
        }

        //---------------------------------------------------------------------

        public bool IsVertical() { return wxToolBar_IsVertical(wxobj); }

        //---------------------------------------------------------------------

        public override bool AcceptsFocus()
        {
            return wxToolBar_AcceptsFocus(wxobj); 
        }

	}

