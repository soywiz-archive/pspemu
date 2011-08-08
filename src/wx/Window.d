//-----------------------------------------------------------------------------
// wxD - Window.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - Window.cs
//
/// The wxWindow wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Window.d,v 1.14 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.Window;
public import wx.common;
public import wx.EvtHandler;
public import wx.Cursor;
public import wx.Font;
public import wx.Colour;
public import wx.Region;
public import wx.Validator;
public import wx.Palette;
public import wx.Accelerator;

public import wx.Caret;
public import wx.DC;
public import wx.DND;
public import wx.Sizer;
public import wx.Menu;
public import wx.ToolTip;

	public enum WindowVariant
	{
		wxWINDOW_VARIANT_NORMAL,  // Normal size
		wxWINDOW_VARIANT_SMALL,   // Smaller size (about 25 % smaller than normal)
		wxWINDOW_VARIANT_MINI,    // Mini size (about 33 % smaller than normal)
		wxWINDOW_VARIANT_LARGE,   // Large size (about 25 % larger than normal)
		wxWINDOW_VARIANT_MAX
	};	
	
	//---------------------------------------------------------------------
	
	public enum BackgroundStyle
	{
		wxBG_STYLE_SYSTEM,
		wxBG_STYLE_COLOUR,
		wxBG_STYLE_CUSTOM
	};
	
	//---------------------------------------------------------------------
	
	public enum Border
	{
		wxBORDER_DEFAULT = 0,

		wxBORDER_NONE   = 0x00200000,
		wxBORDER_STATIC = 0x01000000,
		wxBORDER_SIMPLE = 0x02000000,
		wxBORDER_RAISED = 0x04000000,
		wxBORDER_SUNKEN = 0x08000000,
		wxBORDER_DOUBLE = 0x10000000,

		wxBORDER_MASK   = 0x1f200000,
		
		wxDOUBLE_BORDER   = wxBORDER_DOUBLE,
		wxSUNKEN_BORDER   = wxBORDER_SUNKEN,
		wxRAISED_BORDER   = wxBORDER_RAISED,
		wxBORDER          = wxBORDER_SIMPLE,
		wxSIMPLE_BORDER   = wxBORDER_SIMPLE,
		wxSTATIC_BORDER   = wxBORDER_STATIC,
		wxNO_BORDER       = wxBORDER_NONE
	};
	
		//! \cond EXTERN
		static extern (C) IntPtr wxVisualAttributes_ctor();
		static extern (C) void   wxVisualAttributes_dtor(IntPtr self);
		static extern (C) void   wxVisualAttributes_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) void   wxVisualAttributes_SetFont(IntPtr self, IntPtr font);
		static extern (C) IntPtr wxVisualAttributes_GetFont(IntPtr self);
		static extern (C) void   wxVisualAttributes_SetColourFg(IntPtr self, IntPtr colour);
		static extern (C) IntPtr wxVisualAttributes_GetColourFg(IntPtr self);
		static extern (C) void   wxVisualAttributes_SetColourBg(IntPtr self, IntPtr colour);
		static extern (C) IntPtr wxVisualAttributes_GetColourBg(IntPtr self);
		//! \endcond
		
		//---------------------------------------------------------------------

	alias VisualAttributes wxVisualAttributes;
	public class VisualAttributes : wxObject
	{
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
		
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}
			
		public this()
		{ 
			this(wxVisualAttributes_ctor(), true);
			wxVisualAttributes_RegisterDisposable(wxobj, &VirtualDispose);
		}
		
		//---------------------------------------------------------------------

		public Font font() { return new Font(wxVisualAttributes_GetFont(wxobj), true); }
		public void font(Font value) { wxVisualAttributes_SetFont(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------
		
		public Colour colFg() { return new Colour(wxVisualAttributes_GetColourFg(wxobj), true); }		
		//---------------------------------------------------------------------
		
		public Colour colBg() { return new Colour(wxVisualAttributes_GetColourBg(wxobj), true); }		
		//---------------------------------------------------------------------
		
		override protected void dtor() { wxVisualAttributes_dtor(wxobj); }
	}

	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxWindow_ctor(IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
		static extern (C) bool   wxWindow_Close(IntPtr self, bool force);
		static extern (C) void   wxWindow_GetBestSize(IntPtr self, out Size size);
		static extern (C) void   wxWindow_GetClientSize(IntPtr self, out Size size);
		static extern (C) int    wxWindow_GetId(IntPtr self);
		static extern (C) uint   wxWindow_GetWindowStyleFlag(IntPtr self);
		static extern (C) uint   wxWindow_Layout(IntPtr self);
		static extern (C) void   wxWindow_SetAutoLayout(IntPtr self, bool autoLayout);
		static extern (C) void   wxWindow_SetBackgroundColour(IntPtr self, IntPtr colour);
		static extern (C) IntPtr wxWindow_GetBackgroundColour(IntPtr self);
		static extern (C) void   wxWindow_SetForegroundColour(IntPtr self, IntPtr colour);
		static extern (C) IntPtr wxWindow_GetForegroundColour(IntPtr self);
		static extern (C) void   wxWindow_SetCursor(IntPtr self, IntPtr cursor);
		static extern (C) void   wxWindow_SetId(IntPtr self, int id);
		static extern (C) void   wxWindow_SetSize(IntPtr self, int x, int y, int width, int height, uint flags);
		static extern (C) void   wxWindow_SetSize2(IntPtr self, int width, int height);
		static extern (C) void   wxWindow_SetSize3(IntPtr self, ref Size size);
		static extern (C) void   wxWindow_SetSize4(IntPtr self, ref Rectangle rect);
		static extern (C) void   wxWindow_SetSizer(IntPtr self, IntPtr sizer, bool deleteOld);
		static extern (C) void   wxWindow_SetWindowStyleFlag(IntPtr self, uint style);
		static extern (C) bool   wxWindow_Show(IntPtr self, bool show);
		static extern (C) bool   wxWindow_SetFont(IntPtr self, IntPtr font);
		static extern (C) IntPtr wxWindow_GetFont(IntPtr self);
		static extern (C) void   wxWindow_SetToolTip(IntPtr self, string tip);
		static extern (C) bool 	 wxWindow_Enable(IntPtr self, bool enable);
		static extern (C) bool   wxWindow_IsEnabled(IntPtr self);

		static extern (C) int    wxWindow_EVT_TRANSFERDATAFROMWINDOW();
		static extern (C) int    wxWindow_EVT_TRANSFERDATATOWINDOW();

		//static extern (C) bool wxWindow_LoadFromResource(IntPtr self, IntPtr parent, string resourceName, IntPtr table);
		//static extern (C) IntPtr wxWindow_CreateItem(IntPtr self, IntPtr childResource, IntPtr parentResource, IntPtr table);
		static extern (C) bool   wxWindow_Destroy(IntPtr self);
		static extern (C) bool   wxWindow_DestroyChildren(IntPtr self);
		static extern (C) void   wxWindow_SetTitle(IntPtr self, string title);
		static extern (C) IntPtr wxWindow_GetTitle(IntPtr self);
		static extern (C) void   wxWindow_SetName(IntPtr self, string name);
		static extern (C) IntPtr wxWindow_GetName(IntPtr self);
		static extern (C) int    wxWindow_NewControlId();
		static extern (C) int    wxWindow_NextControlId(int id);
		static extern (C) int    wxWindow_PrevControlId(int id);
		static extern (C) void   wxWindow_Move(IntPtr self, int x, int y, int flags);
		static extern (C) void   wxWindow_Raise(IntPtr self);
		static extern (C) void   wxWindow_Lower(IntPtr self);
		static extern (C) void   wxWindow_SetClientSize(IntPtr self, int width, int height);
		static extern (C) void   wxWindow_GetPosition(IntPtr self, out Point point);
		static extern (C) void   wxWindow_GetSize(IntPtr self, out Size size);
		static extern (C) void   wxWindow_GetRect(IntPtr self, out Rectangle rect);
		static extern (C) void   wxWindow_GetClientAreaOrigin(IntPtr self, out Point point);
		static extern (C) void   wxWindow_GetClientRect(IntPtr self, out Rectangle rect);
		static extern (C) void   wxWindow_GetAdjustedBestSize(IntPtr self, out Size size);
		static extern (C) void   wxWindow_Center(IntPtr self, int direction);
		static extern (C) void   wxWindow_CenterOnScreen(IntPtr self, int dir);
		static extern (C) void   wxWindow_CenterOnParent(IntPtr self, int dir);
		static extern (C) void   wxWindow_Fit(IntPtr self);
		static extern (C) void   wxWindow_FitInside(IntPtr self);
		static extern (C) void   wxWindow_SetSizeHints(IntPtr self, int minW, int minH, int maxW, int maxH, int incW, int incH);
		static extern (C) void   wxWindow_SetVirtualSizeHints(IntPtr self, int minW, int minH, int maxW, int maxH);
		static extern (C) int    wxWindow_GetMinWidth(IntPtr self);
		static extern (C) int    wxWindow_GetMinHeight(IntPtr self);
		static extern (C) void   wxWindow_GetMinSize(IntPtr self, out Size size);
		static extern (C) void   wxWindow_SetMinSize(IntPtr self, Size* size);
		static extern (C) int    wxWindow_GetMaxWidth(IntPtr self);
		static extern (C) int    wxWindow_GetMaxHeight(IntPtr self);
		static extern (C) void   wxWindow_GetMaxSize(IntPtr self, out Size size);
		static extern (C) void   wxWindow_SetMaxSize(IntPtr self, Size* size);
		static extern (C) void   wxWindow_SetVirtualSize(IntPtr self, ref Size size);
		static extern (C) void   wxWindow_GetVirtualSize(IntPtr self, out Size size);
		static extern (C) void   wxWindow_GetBestVirtualSize(IntPtr self, out Size size);
		static extern (C) bool   wxWindow_Hide(IntPtr self);
		static extern (C) bool   wxWindow_Disable(IntPtr self);
		static extern (C) bool   wxWindow_IsShown(IntPtr self);
		static extern (C) void   wxWindow_SetWindowStyle(IntPtr self, uint style);
		static extern (C) uint   wxWindow_GetWindowStyle(IntPtr self);
		static extern (C) bool   wxWindow_HasFlag(IntPtr self, int flag);
		static extern (C) bool   wxWindow_IsRetained(IntPtr self);
		static extern (C) void   wxWindow_SetExtraStyle(IntPtr self, uint exStyle);
		static extern (C) uint   wxWindow_GetExtraStyle(IntPtr self);
		static extern (C) void   wxWindow_MakeModal(IntPtr self, bool modal);
		static extern (C) void   wxWindow_SetThemeEnabled(IntPtr self, bool enableTheme);
		static extern (C) bool   wxWindow_GetThemeEnabled(IntPtr self);
		static extern (C) void   wxWindow_SetFocus(IntPtr self);
		static extern (C) void   wxWindow_SetFocusFromKbd(IntPtr self);
		static extern (C) IntPtr wxWindow_FindFocus();
		static extern (C) bool   wxWindow_AcceptsFocus(IntPtr self);
		static extern (C) bool   wxWindow_AcceptsFocusFromKeyboard(IntPtr self);
		static extern (C) IntPtr wxWindow_GetParent(IntPtr self);
		static extern (C) IntPtr wxWindow_GetGrandParent(IntPtr self);
		static extern (C) bool   wxWindow_IsTopLevel(IntPtr self);
		static extern (C) void   wxWindow_SetParent(IntPtr self, IntPtr parent);
		static extern (C) bool   wxWindow_Reparent(IntPtr self, IntPtr newParent);
		static extern (C) void   wxWindow_AddChild(IntPtr self, IntPtr child);
		static extern (C) void   wxWindow_RemoveChild(IntPtr self, IntPtr child);
		static extern (C) IntPtr wxWindow_FindWindowId(IntPtr self, int id);
		static extern (C) IntPtr wxWindow_FindWindowName(IntPtr self, string name);
		static extern (C) IntPtr wxWindow_FindWindowById(int id, IntPtr parent);
		static extern (C) IntPtr wxWindow_FindWindowByName(string name, IntPtr parent);
		static extern (C) IntPtr wxWindow_FindWindowByLabel(string label, IntPtr parent);
		static extern (C) IntPtr wxWindow_GetEventHandler(IntPtr self);
		static extern (C) void   wxWindow_SetEventHandler(IntPtr self, IntPtr handler);
		static extern (C) void   wxWindow_PushEventHandler(IntPtr self, IntPtr handler);
		static extern (C) IntPtr wxWindow_PopEventHandler(IntPtr self, bool deleteHandler);
		static extern (C) bool   wxWindow_RemoveEventHandler(IntPtr self, IntPtr handler);
		static extern (C) void   wxWindow_SetValidator(IntPtr self, IntPtr validator);
		static extern (C) IntPtr wxWindow_GetValidator(IntPtr self);
		static extern (C) bool   wxWindow_Validate(IntPtr self);
		static extern (C) bool   wxWindow_TransferDataToWindow(IntPtr self);
		static extern (C) bool   wxWindow_TransferDataFromWindow(IntPtr self);
		static extern (C) void   wxWindow_InitDialog(IntPtr self);
		static extern (C) void   wxWindow_SetAcceleratorTable(IntPtr self, IntPtr accel);
		static extern (C) IntPtr wxWindow_GetAcceleratorTable(IntPtr self);
		static extern (C) void   wxWindow_ConvertPixelsToDialogPoint(IntPtr self, ref Point pt, out Point point);
		static extern (C) void   wxWindow_ConvertDialogToPixelsPoint(IntPtr self, ref Point pt, out Point point);
		static extern (C) void   wxWindow_ConvertPixelsToDialogSize(IntPtr self, ref Size sz, out Size size);
		static extern (C) void   wxWindow_ConvertDialogToPixelsSize(IntPtr self, ref Size sz, out Size size);
		static extern (C) void   wxWindow_WarpPointer(IntPtr self, int x, int y);
		static extern (C) void   wxWindow_CaptureMouse(IntPtr self);
		static extern (C) void   wxWindow_ReleaseMouse(IntPtr self);
		static extern (C) IntPtr wxWindow_GetCapture();
		static extern (C) bool   wxWindow_HasCapture(IntPtr self);
		static extern (C) void   wxWindow_Refresh(IntPtr self, bool eraseBackground, ref Rectangle rect);
		static extern (C) void   wxWindow_RefreshRect(IntPtr self, ref Rectangle rect);
		static extern (C) void   wxWindow_Update(IntPtr self);
		static extern (C) void   wxWindow_ClearBackground(IntPtr self);
		static extern (C) void   wxWindow_Freeze(IntPtr self);
		static extern (C) void   wxWindow_Thaw(IntPtr self);
		static extern (C) void   wxWindow_PrepareDC(IntPtr self, IntPtr dc);
		static extern (C) bool   wxWindow_IsExposed(IntPtr self, int x, int y, int w, int h);
		static extern (C) void   wxWindow_SetCaret(IntPtr self, IntPtr caret);
		static extern (C) IntPtr wxWindow_GetCaret(IntPtr self);
		static extern (C) int    wxWindow_GetCharHeight(IntPtr self);
		static extern (C) int    wxWindow_GetCharWidth(IntPtr self);
		static extern (C) void   wxWindow_GetTextExtent(IntPtr self, string str, out int x, out int y, out int descent, out int externalLeading, IntPtr theFont);
		static extern (C) void   wxWindow_ClientToScreen(IntPtr self, ref int x, ref int y);
		static extern (C) void   wxWindow_ScreenToClient(IntPtr self, ref int x, ref int y);
		static extern (C) void   wxWindow_ClientToScreen(IntPtr self, ref Point pt, out Point point);
		static extern (C) void   wxWindow_ScreenToClient(IntPtr self, ref Point pt, out Point point);
		//static extern (C) wxHitTest wxWindow_HitTest(IntPtr self, Coord x, Coord y);
		//static extern (C) wxHitTest wxWindow_HitTest(IntPtr self, ref Point pt);
		static extern (C) int    wxWindow_GetBorder(IntPtr self);
		static extern (C) int    wxWindow_GetBorderByFlags(IntPtr self, uint flags);
		static extern (C) void   wxWindow_UpdateWindowUI(IntPtr self);
		static extern (C) bool   wxWindow_PopupMenu(IntPtr self, IntPtr menu, ref Point pos);
		static extern (C) bool   wxWindow_HasScrollbar(IntPtr self, int orient);
		static extern (C) void   wxWindow_SetScrollbar(IntPtr self, int orient, int pos, int thumbvisible, int range, bool refresh);
		static extern (C) void   wxWindow_SetScrollPos(IntPtr self, int orient, int pos, bool refresh);
		static extern (C) int    wxWindow_GetScrollPos(IntPtr self, int orient);
		static extern (C) int    wxWindow_GetScrollThumb(IntPtr self, int orient);
		static extern (C) int    wxWindow_GetScrollRange(IntPtr self, int orient);
		static extern (C) void   wxWindow_ScrollWindow(IntPtr self, int dx, int dy, ref Rectangle rect);
		static extern (C) bool   wxWindow_ScrollLines(IntPtr self, int lines);
		static extern (C) bool   wxWindow_ScrollPages(IntPtr self, int pages);
		static extern (C) bool   wxWindow_LineUp(IntPtr self);
		static extern (C) bool   wxWindow_LineDown(IntPtr self);
		static extern (C) bool   wxWindow_PageUp(IntPtr self);
		static extern (C) bool   wxWindow_PageDown(IntPtr self);
		static extern (C) void   wxWindow_SetHelpText(IntPtr self, string text);
		static extern (C) void   wxWindow_SetHelpTextForId(IntPtr self, string text);
		static extern (C) IntPtr wxWindow_GetHelpText(IntPtr self);
		//static extern (C) void wxWindow_SetToolTip(IntPtr self, IntPtr tip);
		//static extern (C) IntPtr wxWindow_GetToolTip(IntPtr self);
		static extern (C) void   wxWindow_SetDropTarget(IntPtr self, IntPtr dropTarget);
		static extern (C) IntPtr wxWindow_GetDropTarget(IntPtr self);
		static extern (C) void   wxWindow_SetConstraints(IntPtr self, IntPtr constraints);
		static extern (C) IntPtr wxWindow_GetConstraints(IntPtr self);
		static extern (C) bool   wxWindow_GetAutoLayout(IntPtr self);
		static extern (C) void   wxWindow_SetSizerAndFit(IntPtr self, IntPtr sizer, bool deleteOld);
		static extern (C) IntPtr wxWindow_GetSizer(IntPtr self);
		static extern (C) void   wxWindow_SetContainingSizer(IntPtr self, IntPtr sizer);
		static extern (C) IntPtr wxWindow_GetContainingSizer(IntPtr self);
		static extern (C) IntPtr wxWindow_GetPalette(IntPtr self);
		static extern (C) void   wxWindow_SetPalette(IntPtr self, IntPtr pal);
		static extern (C) bool   wxWindow_HasCustomPalette(IntPtr self);
		static extern (C) IntPtr wxWindow_GetUpdateRegion(IntPtr self);
		
		static extern (C) void   wxWindow_SetWindowVariant(IntPtr self, int variant);
		static extern (C) int    wxWindow_GetWindowVariant(IntPtr self);
		static extern (C) bool   wxWindow_IsBeingDeleted(IntPtr self);
		static extern (C) void   wxWindow_InvalidateBestSize(IntPtr self);
		static extern (C) void   wxWindow_CacheBestSize(IntPtr self, Size size);
		static extern (C) void   wxWindow_GetBestFittingSize(IntPtr self, ref Size size);
		static extern (C) void   wxWindow_SetBestFittingSize(IntPtr self, ref Size size);
		static extern (C) IntPtr wxWindow_GetChildren(IntPtr self, int num);
		static extern (C) int    wxWindow_GetChildrenCount(IntPtr self);
		static extern (C) IntPtr wxWindow_GetDefaultAttributes(IntPtr self);
		static extern (C) IntPtr wxWindow_GetClassDefaultAttributes(int variant);
		static extern (C) void   wxWindow_SetBackgroundStyle(IntPtr self, int style);
		static extern (C) int    wxWindow_GetBackgroundStyle(IntPtr self);
		//static extern (C) IntPtr wxWindow_GetToolTipText(IntPtr self);
		static extern (C) IntPtr wxWindow_GetAncestorWithCustomPalette(IntPtr self);
		static extern (C) void   wxWindow_InheritAttributes(IntPtr self);
		static extern (C) bool   wxWindow_ShouldInheritColours(IntPtr self);
		//! \endcond

		//---------------------------------------------------------------------

	alias Window wxWindow;
	/// wxWindow is the base class for all windows and represents any
	/// visible object on screen. All controls, top level windows and so on
	/// are windows. Sizers and device contexts are not, however, as they don't
	/// appear on screen themselves.
	public class Window : EvtHandler
	{
		enum {
			wxVSCROLL			= cast(int)0x80000000,
			wxHSCROLL			= 0x40000000,
			wxCAPTION			= 0x20000000,

			wxCLIP_CHILDREN			= 0x00400000,
			wxMINIMIZE_BOX 			= 0x00000400,
			wxCLOSE_BOX			= 0x1000,
			wxMAXIMIZE_BOX			= 0x0200,
			wxNO_3D				= 0x00800000,
			wxRESIZE_BORDER			= 0x00000040,
			wxSYSTEM_MENU			= 0x00000800,
			wxTAB_TRAVERSAL			= 0x00008000,

			wxNO_FULL_REPAINT_ON_RESIZE	= 0x00010000,

			 wxID_OK			= 5100,
			 wxID_CANCEL			= 5101,
			 wxID_YES			= 5103,
			 wxID_NO			= 5104,
	 
			wxID_ANY			= -1,
			wxID_ABOUT			= 5013,
	
			wxSTAY_ON_TOP			= 0x8000,
			wxICONIZE			= 0x4000,
			wxMINIMIZE			= wxICONIZE,
			wxMAXIMIZE			= 0x2000,
	
			wxTINY_CAPTION_HORIZ		= 0x0100,
			wxTINY_CAPTION_VERT		= 0x0080,
	
			wxDIALOG_NO_PARENT		= 0x0001,
			wxFRAME_NO_TASKBAR		= 0x0002,
			wxFRAME_TOOL_WINDOW		= 0x0004,
			wxFRAME_FLOAT_ON_PARENT		= 0x0008,
			wxFRAME_SHAPED			= 0x0010,
			wxFRAME_EX_CONTEXTHELP		= 0x00000004,

		//---------------------------------------------------------------------
	
			wxBORDER_DEFAULT		= 0x00000000,
			wxBORDER_NONE			= 0x00200000,
			wxBORDER_STATIC			= 0x01000000,
			wxBORDER_SIMPLE			= 0x02000000,
			wxBORDER_RAISED			= 0x04000000,
			wxBORDER_SUNKEN			= 0x08000000,
			wxBORDER_DOUBLE			= 0x10000000,
			wxBORDER_MASK			= 0x1f200000,
	
		// Border flags
			wxDOUBLE_BORDER			= wxBORDER_DOUBLE,
			wxSUNKEN_BORDER			= wxBORDER_SUNKEN,
			wxRAISED_BORDER			= wxBORDER_RAISED,
			wxBORDER			= wxBORDER_SIMPLE,
			wxSIMPLE_BORDER			= wxBORDER_SIMPLE,
			wxSTATIC_BORDER			= wxBORDER_STATIC,
			wxNO_BORDER			= wxBORDER_NONE,
	
			wxWANTS_CHARS			= 0x00040000,
		
			wxDEFAULT_FRAME			= wxSYSTEM_MENU | wxRESIZE_BORDER |
									wxMINIMIZE_BOX | wxMAXIMIZE_BOX | wxCAPTION |
									wxCLIP_CHILDREN | wxCLOSE_BOX,
			wxDEFAULT_FRAME_STYLE		= wxDEFAULT_FRAME,

			wxDEFAULT_DIALOG_STYLE		= wxSYSTEM_MENU | wxCAPTION | wxCLOSE_BOX,
		}

		private static int uniqueID			= 10000; // start with 10000 to not interfere with the old id system

		//---------------------------------------------------------------------

		public const Point wxDefaultPosition = {X:-1, Y:-1};
		public const Size  wxDefaultSize     = {Width:-1, Height:-1};
		const string wxPanelNameStr = "panel";

		//---------------------------------------------------------------------

		public this(Window parent, int id, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=0, string name=wxPanelNameStr)
			{ this(wxWindow_ctor(wxObject.SafePtr(parent), id, pos, size, style, name), 
				false /*a Window will always be destroyed by its parent*/);}
			
		public this(Window parent, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=0, string name=wxPanelNameStr)
			{ this(parent, Window.UniqueID, pos, size, style, name);}

		public this(IntPtr wxobj) 
		{
			super(wxobj);
			AddEventListener(wxWindow_EVT_TRANSFERDATATOWINDOW(), &OnTransferDataToWindow);
			AddEventListener(wxWindow_EVT_TRANSFERDATAFROMWINDOW(), &OnTransferDataFromWindow);
		}
		
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
			
			AddEventListener(wxWindow_EVT_TRANSFERDATATOWINDOW(), &OnTransferDataToWindow);
			AddEventListener(wxWindow_EVT_TRANSFERDATAFROMWINDOW(), &OnTransferDataFromWindow);
		}


		static wxObject New(IntPtr ptr) { return new Window(ptr); }
		//---------------------------------------------------------------------

		public /+virtual+/ void   BackgroundColour(Colour value)
		{
			wxWindow_SetBackgroundColour(wxobj, wxObject.SafePtr(value));
		}
		public /+virtual+/ Colour BackgroundColour()
		{
			return new Colour(wxWindow_GetBackgroundColour(wxobj), true);
		}

		public /+virtual+/ Colour ForegroundColour()
		{
			return new Colour(wxWindow_GetForegroundColour(wxobj), true);
		}
		public /+virtual+/ void   ForegroundColour(Colour value)
		{
			wxWindow_SetForegroundColour(wxobj, wxObject.SafePtr(value));
		}

		//---------------------------------------------------------------------

		// Note: was previously defined as WindowFont
		public /+virtual+/ void font(Font value)
		{
			wxWindow_SetFont(wxobj, value.wxobj);
		}
		public /+virtual+/ Font font()
		{
			return new Font(wxWindow_GetFont(wxobj), true);
		}


		//---------------------------------------------------------------------

		public /+virtual+/ Size BestSize()
		{
			Size size;
			wxWindow_GetBestSize(wxobj, size);
			return size;
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Size ClientSize()
		{
			Size size;
			wxWindow_GetClientSize(wxobj, size);
			return size;
		}
		public /+virtual+/ void ClientSize(Size value)
		{
			wxWindow_SetClientSize(wxobj, value.Width, value.Height);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ bool Close()
		{
			return wxWindow_Close(wxobj, false);
		}

		public /+virtual+/ bool Close(bool force)
		{
			return wxWindow_Close(wxobj, force);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ int ID() { return wxWindow_GetId(wxobj); }
		public /+virtual+/ void ID(int value) { wxWindow_SetId(wxobj, value); }
		
		//---------------------------------------------------------------------
		
		public static int UniqueID() { return ++uniqueID; }
		
		//---------------------------------------------------------------------

		public /+virtual+/ void Layout()
		{
			wxWindow_Layout(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void cursor(Cursor value)
		{
			wxWindow_SetCursor(wxobj, wxObject.SafePtr(value));
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void SetSize(int x, int y, int width, int height)
		{
			wxWindow_SetSize(wxobj, x, y, width, height, 0);
		}
		
		public /+virtual+/ void SetSize(int width, int height)
		{
			wxWindow_SetSize2(wxobj, width, height);
		}
		
		public /+virtual+/ void SetSize(Size size)
		{
			wxWindow_SetSize3(wxobj, size);
		}

		public /+virtual+/ void SetSize(Rectangle rect)
		{
			wxWindow_SetSize4(wxobj, rect);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void SetSizer(Sizer sizer, bool deleteOld=true)
		{
			wxWindow_SetSizer(wxobj, sizer.wxobj, deleteOld);
		}

		//---------------------------------------------------------------------
		
		public /+virtual+/ bool Show(bool show=true)
		{
			return wxWindow_Show(wxobj, show);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ int  StyleFlags()
		{
			return wxWindow_GetWindowStyleFlag(wxobj);
		}
		public /+virtual+/ void StyleFlags(uint value) 
		{
			wxWindow_SetWindowStyleFlag(wxobj, value);
		}

		//---------------------------------------------------------------------

		private void OnTransferDataFromWindow(Object sender, Event e)
		{
			if (!TransferDataFromWindow())
				e.Skip();
		}

		//---------------------------------------------------------------------

		private void OnTransferDataToWindow(Object sender, Event e)
		{
			if (!TransferDataToWindow())
				e.Skip();
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void toolTip(string value)
		{
			wxWindow_SetToolTip(wxobj, value);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void Enabled(bool value)
		{
			wxWindow_Enable(wxobj, value);
		}
		public /+virtual+/ bool Enabled()
		{
			return wxWindow_IsEnabled(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ bool Destroy()
		{
			return wxWindow_Destroy(wxobj);
		}

		public /+virtual+/ bool DestroyChildren()
		{
			return wxWindow_DestroyChildren(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void  Title(string value)
		{
			wxWindow_SetTitle(wxobj, value);
		}
		public /+virtual+/ string Title()
		{
			return cast(string) new wxString(wxWindow_GetTitle(wxobj), true);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void Name(string value)
			{
				wxWindow_SetName(wxobj, value);
			}
		public /+virtual+/ string Name()
			{
				return cast(string) new wxString(wxWindow_GetName(wxobj), true);
			}

		//---------------------------------------------------------------------

		public static int NewControlId()
		{
			return wxWindow_NewControlId();
		}

		public static int NextControlId(int id)
		{
			return wxWindow_NextControlId(id);
		}

		public static int PrevControlId(int id)
		{
			return wxWindow_PrevControlId(id);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void Move(int x, int y, int flags)
		{
			wxWindow_Move(wxobj, x, y, flags);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void Raise()
		{
			wxWindow_Raise(wxobj);
		}

		public /+virtual+/ void Lower()
		{
			wxWindow_Lower(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Point Position()
			{
				Point point;
				wxWindow_GetPosition(wxobj, point);
				return point;
			}
		public /+virtual+/ void  Position(Point value)
			{
				Move(value.X, value.Y, 0);
			}

		//---------------------------------------------------------------------

		public /+virtual+/ Size size()
			{
				Size size;
				wxWindow_GetSize(wxobj, size);
				return size;
			}
		public /+virtual+/ void size(Size value)
			{
				wxWindow_SetSize(wxobj, Position.X, Position.Y,
								 value.Width, value.Height, 0);
			}

		//---------------------------------------------------------------------

		public /+virtual+/ Rectangle Rect()
		{
				Rectangle rect;
				wxWindow_GetRect(wxobj, rect);
				return rect;
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Point ClientAreaOrigin()
		{
				Point point;
				wxWindow_GetClientAreaOrigin(wxobj, point);
				return point;
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Rectangle ClientRect()
		{
				Rectangle rect;
				wxWindow_GetClientRect(wxobj, rect);
				return rect;
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Size AdjustedBestSize()
		{
				Size size;
				wxWindow_GetAdjustedBestSize(wxobj, size);
				return size;
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void Centre()
		{ 
			Center( Orientation.wxBOTH ); 
		}
		
		public /+virtual+/ void Center()
		{ 
			Center( Orientation.wxBOTH ); 
		}
		
		public /+virtual+/ void Centre(int direction)
		{ 
			Center( direction ); 
		}
		
		public /+virtual+/ void Center(int direction)
		{
			wxWindow_Center(wxobj, direction);
		}

		public /+virtual+/ void CentreOnScreen()
		{ 
			CenterOnScreen( Orientation.wxBOTH ); 
		}
		
		public /+virtual+/ void CenterOnScreen()
		{ 
			CenterOnScreen( Orientation.wxBOTH ); 
		}
		
		public /+virtual+/ void CentreOnScreen(int direction)
		{ 
			CenterOnScreen( direction ); 
		}
		
		public /+virtual+/ void CenterOnScreen(int direction)
		{
			wxWindow_CenterOnScreen(wxobj, direction);
		}

		public /+virtual+/ void CentreOnParent()
		{ 
			CenterOnParent( Orientation.wxBOTH ); 
		}
		
		public /+virtual+/ void CenterOnParent()
		{ 
			CenterOnParent( Orientation.wxBOTH ); 
		}
		
		public /+virtual+/ void CentreOnParent(int direction)
		{ 
			CenterOnParent( direction ); 
		}
		
		public /+virtual+/ void CenterOnParent(int direction)
		{
			wxWindow_CenterOnParent(wxobj, direction);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void Fit()
		{
			wxWindow_Fit(wxobj);
		}

		public /+virtual+/ void FitInside()
		{
			wxWindow_FitInside(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void SetSizeHints(int minW, int minH)
		{ 
			SetSizeHints(minW, minH, -1, -1, -1, -1); 
		}
		
		public /+virtual+/ void SetSizeHints(int minW, int minH, int maxW, int maxH)
		{ 
			SetSizeHints(minW, minH, maxW, maxH, -1, -1); 
		}
		
		public /+virtual+/ void SetSizeHints(int minW, int minH, int maxW, int maxH, int incW, int incH)
		{
			wxWindow_SetSizeHints(wxobj, minW, minH, maxW, maxH, incW, incH);
		}

		public /+virtual+/ void SetVirtualSizeHints(int minW, int minH, int maxW, int maxH)
		{
			wxWindow_SetVirtualSizeHints(wxobj, minW, minH, maxW, maxH);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ int MinWidth()
		{
				return wxWindow_GetMinWidth(wxobj);
		}

		public /+virtual+/ int MinHeight()
		{
				return wxWindow_GetMinHeight(wxobj);
		}

		public /+virtual+/ int MaxWidth()
		{
				return wxWindow_GetMaxWidth(wxobj);
		}

		public /+virtual+/ int MaxHeight()
		{
				return wxWindow_GetMaxHeight(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Size MinSize()
		{
				Size size;
				wxWindow_GetMinSize(wxobj, size);
				return size;
		}

		public void MinSize(Size size)
		{
				wxWindow_SetMinSize(wxobj, &size);
		}

		public /+virtual+/ Size MaxSize()
		{
				Size size;
				wxWindow_GetMaxSize(wxobj, size);
				return size;
		}

		public void MaxSize(Size size)
		{
				wxWindow_SetMaxSize(wxobj, &size);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Size VirtualSize()
			{
				Size size;
				wxWindow_GetVirtualSize(wxobj, size);
				return size;
			}
		public /+virtual+/ void  VirtualSize(Size value)
			{
				wxWindow_SetVirtualSize(wxobj, value);
			}

		//---------------------------------------------------------------------

		public /+virtual+/ Size BestVirtualSize()
		{
				Size size;
				wxWindow_GetBestVirtualSize(wxobj, size);
				return size;
		}

		//---------------------------------------------------------------------

		public /+virtual+/ bool Hide()
		{
			return wxWindow_Hide(wxobj);
		}

		public /+virtual+/ bool Disable()
		{
			return wxWindow_Disable(wxobj);
		}

		public /+virtual+/ bool IsShown()
		{
			return wxWindow_IsShown(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ int WindowStyle()
			{
				return wxWindow_GetWindowStyle(wxobj);
			}
		public /+virtual+/ void WindowStyle(uint value)
			{
				wxWindow_SetWindowStyle(wxobj, value);
			}

		public /+virtual+/ bool HasFlag(int flag)
		{
			return wxWindow_HasFlag(wxobj, flag);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ bool IsRetained()
		{
			return wxWindow_IsRetained(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ int ExtraStyle()
			{
				return wxWindow_GetExtraStyle(wxobj);
			}
		public /+virtual+/ void ExtraStyle(uint value)
			{
				wxWindow_SetExtraStyle(wxobj, value);
			}

		//---------------------------------------------------------------------

		public void MakeModal(bool value)
		{
			wxWindow_MakeModal(wxobj, value);
		}

		//---------------------------------------------------------------------

		public bool ThemeEnabled()
		{
			return wxWindow_GetThemeEnabled(wxobj);
		}
		public void ThemeEnabled(bool value)
		{
			wxWindow_SetThemeEnabled(wxobj, value);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void SetFocus()
		{
			wxWindow_SetFocus(wxobj);
		}

		public /+virtual+/ void SetFocusFromKbd()
		{
			wxWindow_SetFocusFromKbd(wxobj);
		}

		public static Window FindFocus()
		{
			return cast(Window)FindObject(wxWindow_FindFocus());
		}

		//---------------------------------------------------------------------

		public /+virtual+/ bool AcceptsFocus()
		{
			return wxWindow_AcceptsFocus(wxobj);
		}

		public /+virtual+/ bool AcceptsFocusFromKeyboard()
		{
			return wxWindow_AcceptsFocusFromKeyboard(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Window Parent()
		{
			return cast(Window)FindObject(wxWindow_GetParent(wxobj));
		}
		public /+virtual+/ void Parent(Window value)
		{
			wxWindow_SetParent(wxobj, wxObject.SafePtr(value));
		}

		public /+virtual+/ Window GrandParent()
		{
			return cast(Window)FindObject(wxWindow_GetGrandParent(wxobj));
		}

		public /+virtual+/ bool Reparent(Window newParent)
		{
			return wxWindow_Reparent(wxobj, wxObject.SafePtr(newParent));
		}

		//---------------------------------------------------------------------

		public /+virtual+/ bool IsTopLevel()
		{
			return wxWindow_IsTopLevel(wxobj);
		}
		//---------------------------------------------------------------------

		public /+virtual+/ void AddChild(Window child)
		{
			wxWindow_AddChild(wxobj, wxObject.SafePtr(child));
		}

		public /+virtual+/ void RemoveChild(Window child)
		{
			wxWindow_RemoveChild(wxobj, wxObject.SafePtr(child));
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Window FindWindow(int id)
		{
			return cast(Window)FindObject(wxWindow_FindWindowId(wxobj, id));
		}

		public /+virtual+/ Window FindWindow(int id, newfunc func)
		{
			return cast(Window)FindObject(wxWindow_FindWindowId(wxobj, id), func);
		}

		public /+virtual+/ Window FindWindow(string name)
		{
			return cast(Window)FindObject(wxWindow_FindWindowName(wxobj, name));
		}

		//---------------------------------------------------------------------

		public static Window FindWindowById(int id, Window parent)
		{
			return cast(Window)FindObject(wxWindow_FindWindowById(id, wxObject.SafePtr(parent)));
		}

		public static Window FindWindowByName(string name, Window parent)
		{
			return cast(Window)FindObject(wxWindow_FindWindowByName(name, wxObject.SafePtr(parent)));
		}

		public static Window FindWindowByLabel(string label, Window parent)
		{
			return cast(Window)FindObject(wxWindow_FindWindowByLabel(label, wxObject.SafePtr(parent)));
		}

		//---------------------------------------------------------------------

		public EvtHandler EventHandler()
		{
			IntPtr ptr = wxWindow_GetEventHandler(wxobj);
			wxObject o = FindObject(ptr);
			if (o) return cast(EvtHandler)o;
			else return new EvtHandler(ptr);
		//	return cast(EvtHandler)FindObject(wxWindow_GetEventHandler(wxobj),&EvtHandler.New);
		}
		public void EventHandler(EvtHandler value)
		{
			wxWindow_SetEventHandler(wxobj, wxObject.SafePtr(value));
		}

		//---------------------------------------------------------------------

		public void PushEventHandler(EvtHandler handler)
		{
			wxWindow_PushEventHandler(wxobj, wxObject.SafePtr(handler));
		}

		public EvtHandler PopEventHandler(bool deleteHandler)
		{
			IntPtr ptr = wxWindow_PopEventHandler(wxobj, deleteHandler);
			wxObject o = FindObject(ptr);
			if (o) return cast(EvtHandler)o;
			else return new EvtHandler(ptr);
		//	return cast(EvtHandler)FindObject(wxWindow_PopEventHandler(wxobj, deleteHandler),&EvtHandler.New);
		}

		public bool RemoveEventHandler(EvtHandler handler)
		{
			return wxWindow_RemoveEventHandler(wxobj, wxObject.SafePtr(handler));
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Validator validator()
		{
			return cast(Validator)FindObject(wxWindow_GetValidator(wxobj));
		}
		public /+virtual+/ void validator(Validator value)
		{
			wxWindow_SetValidator(wxobj, wxObject.SafePtr(value));
		}

		public /+virtual+/ bool Validate()
		{
			return wxWindow_Validate(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ bool TransferDataToWindow()
		{
			//return wxWindow_TransferDataToWindow(wxobj);
			return true;
		}

		public /+virtual+/ bool TransferDataFromWindow()
		{
			//return wxWindow_TransferDataFromWindow(wxobj);
			return true;
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void InitDialog()
		{
			wxWindow_InitDialog(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Point ConvertPixelsToDialog(Point pt)
		{
			Point point;
			wxWindow_ConvertPixelsToDialogPoint(wxobj, pt, point);
			return point;
		}

		public /+virtual+/ Point ConvertDialogToPixels(Point pt)
		{
			Point point;
			wxWindow_ConvertDialogToPixelsPoint(wxobj, pt, point);
			return point;
		}

		public /+virtual+/ Size ConvertPixelsToDialog(Size sz)
		{
			Size size;
			wxWindow_ConvertPixelsToDialogSize(wxobj, sz, size);
			return size;
		}

		public /+virtual+/ Size ConvertDialogToPixels(Size sz)
		{
			Size size;
			wxWindow_ConvertPixelsToDialogSize(wxobj, sz, size);
			return size;
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void WarpPointer(int x, int y)
		{
			wxWindow_WarpPointer(wxobj, x, y);
		}

		public /+virtual+/ void CaptureMouse()
		{
			wxWindow_CaptureMouse(wxobj);
		}

		public /+virtual+/ void ReleaseMouse()
		{
			wxWindow_ReleaseMouse(wxobj);
		}

		public static Window GetCapture()
		{
			return cast(Window)FindObject(wxWindow_GetCapture());
		}

		public /+virtual+/ bool HasCapture()
		{
			return wxWindow_HasCapture(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void Refresh()
		{
			Refresh(true, ClientRect);
		}

		public /+virtual+/ void Refresh(bool eraseBackground)
		{
			Refresh(eraseBackground, ClientRect);
		}

		public /+virtual+/ void Refresh(bool eraseBackground, Rectangle rect)
		{
			wxWindow_Refresh(wxobj, eraseBackground, rect);
		}

		public /+virtual+/ void RefreshRectangle(Rectangle rect)
		{
			wxWindow_RefreshRect(wxobj, rect);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void Update()
		{
			wxWindow_Update(wxobj);
		}

		public /+virtual+/ void ClearBackground()
		{
			wxWindow_ClearBackground(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void Freeze()
		{
			wxWindow_Freeze(wxobj);
		}

		public /+virtual+/ void Thaw()
		{
			wxWindow_Thaw(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void PrepareDC(DC dc)
		{
			wxWindow_PrepareDC(wxobj, wxObject.SafePtr(dc));
		}

		//---------------------------------------------------------------------

		public /+virtual+/ bool  IsExposed(int x, int y, int w, int h)
		{
			return wxWindow_IsExposed(wxobj, x, y, w, h);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Caret caret()
		{
			return cast(Caret)FindObject(wxWindow_GetCaret(wxobj),&Caret.New);
		}
		public /+virtual+/ void caret(Caret value)
		{
			wxWindow_SetCaret(wxobj, wxObject.SafePtr(value));
		}

		//---------------------------------------------------------------------

		public /+virtual+/ int CharHeight()
		{
			return wxWindow_GetCharHeight(wxobj);
		}

		public /+virtual+/ int CharWidth()
		{
			return wxWindow_GetCharWidth(wxobj);
		}

		//---------------------------------------------------------------------

		public void GetTextExtent(string str, out int x, out int y, out int descent,
								  out int externalLeading, Font font)
		{
			wxWindow_GetTextExtent(wxobj, str, x, y, descent,
								   externalLeading, wxObject.SafePtr(font));
		}

		//---------------------------------------------------------------------

		public void ClientToScreen(ref int x, ref int y)
		{
			wxWindow_ClientToScreen(wxobj, x, y);
		}

		public Point ClientToScreen(Point clientPoint)
		{
			Point screenPoint;
			wxWindow_ClientToScreen(wxobj, clientPoint, screenPoint);
			return screenPoint;
		}

		public /+virtual+/ void ScreenToClient(ref int x, ref int y)
		{
			wxWindow_ScreenToClient(wxobj, x, y);
		}

		public Point ScreenToClient(Point screenPoint)
		{
			Point clientPoint;
			wxWindow_ScreenToClient(wxobj, screenPoint, clientPoint);
			return clientPoint;
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void UpdateWindowUI()
		{
			wxWindow_UpdateWindowUI(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ bool PopupMenu(Menu menu, Point pos)
		{
			bool tmpbool = wxWindow_PopupMenu(wxobj, wxObject.SafePtr(menu), pos);
			
			menu.ConnectEvents(this);
			
			return tmpbool;
		}

		//---------------------------------------------------------------------

		public /+virtual+/ bool HasScrollbar(int orient)
		{
			return wxWindow_HasScrollbar(wxobj, orient);
		}

		public /+virtual+/ void SetScrollbar(int orient, int pos, int thumbSize, int range, bool refresh)
		{
			wxWindow_SetScrollbar(wxobj, orient, pos, thumbSize, range, refresh);
		}

		public /+virtual+/ void SetScrollPos(int orient, int pos, bool refresh)
		{
			wxWindow_SetScrollPos(wxobj, orient, pos, refresh);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ int GetScrollPos(int orient)
		{
			return wxWindow_GetScrollPos(wxobj, orient);
		}

		public /+virtual+/ int GetScrollThumb(int orient)
		{
			return wxWindow_GetScrollThumb(wxobj, orient);
		}

		public /+virtual+/ int GetScrollRange(int orient)
		{
			return wxWindow_GetScrollRange(wxobj, orient);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ void ScrollWindow(int dx, int dy, Rectangle rect)
		{
			wxWindow_ScrollWindow(wxobj, dx, dy, rect);
		}

		public /+virtual+/ bool ScrollLines(int lines)
		{
			return wxWindow_ScrollLines(wxobj, lines);
		}

		public /+virtual+/ bool ScrollPages(int pages)
		{
			return wxWindow_ScrollPages(wxobj, pages);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ bool LineUp()
		{
			return wxWindow_LineUp(wxobj);
		}

		public /+virtual+/ bool LineDown()
		{
			return wxWindow_LineDown(wxobj);
		}

		public /+virtual+/ bool PageUp()
		{
			return wxWindow_PageUp(wxobj);
		}

		public /+virtual+/ bool PageDown()
		{
			return wxWindow_PageDown(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ string HelpText()
			{
				return cast(string) new wxString(wxWindow_GetHelpText(wxobj), true);
			}
		public /+virtual+/ void HelpText(string value)
			{
				wxWindow_SetHelpText(wxobj, value);
			}

		public /+virtual+/ void SetHelpTextForId(string text)
		{
			wxWindow_SetHelpTextForId(wxobj, text);
		}

		//---------------------------------------------------------------------
/+FIXME
		public /+virtual+/ DropTarget dropTarget()
			{
				return cast(DropTarget)FindObject(wxWindow_GetDropTarget(wxobj),&DropTarget.New);
			}
+/
		public /+virtual+/ void dropTarget(DropTarget value)
			{
				wxWindow_SetDropTarget(wxobj, wxObject.SafePtr(value));
			}

		//---------------------------------------------------------------------

		// LayoutConstraints are now depreciated.  Should this be implemented?
		/*public LayoutContraints Constraints
		{
			get
			{
				return new LayoutConstraints(wxWindow_GetConstraints(wxobj));
			}
			set
			{
				wxWindow_SetConstraints(wxobj, wxObject.SafePtr(value));
			}
		}*/

		//---------------------------------------------------------------------

		public /+virtual+/ bool AutoLayout()
			{
				return wxWindow_GetAutoLayout(wxobj);
			}
		public /+virtual+/ void AutoLayout(bool value)
			{
				wxWindow_SetAutoLayout(wxobj, value);
			}

		//---------------------------------------------------------------------

		public /+virtual+/ void SetSizerAndFit(Sizer sizer, bool deleteOld)
		{
			wxWindow_SetSizerAndFit(wxobj, wxObject.SafePtr(sizer), deleteOld);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Sizer sizer()
			{
				return cast(Sizer)FindObject(wxWindow_GetSizer(wxobj));
			}
		public /+virtual+/ void  sizer(Sizer value)
			{
				SetSizer(value, true);
			}

		//---------------------------------------------------------------------

		public /+virtual+/ Sizer ContainingSizer()
			{
				return cast(Sizer)FindObject(wxWindow_GetContainingSizer(wxobj));
			}
		public /+virtual+/ void  ContainingSizer(Sizer value)
			{
				wxWindow_SetContainingSizer(wxobj, wxObject.SafePtr(value));
			}

		//---------------------------------------------------------------------

		public /+virtual+/ Palette palette()
			{
				return new Palette(wxWindow_GetPalette(wxobj));
			}
		public /+virtual+/ void palette(Palette value)
			{
				wxWindow_SetPalette(wxobj, wxObject.SafePtr(value));
			}

		//---------------------------------------------------------------------

		public /+virtual+/ bool HasCustomPalette()
		{
			return wxWindow_HasCustomPalette(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Region UpdateRegion()
		{
			return new Region(wxWindow_GetUpdateRegion(wxobj));
		}

		//---------------------------------------------------------------------
		
		// Implement very common System.Windows.Forms.Control members

		public /+virtual+/ int Top() { return this.Position.Y; }
		public /+virtual+/ void Top(int value) { this.Move(this.Position.X, value,	0);	}

		public /+virtual+/ int Left()	{ return this.Position.X; }
		public /+virtual+/ void Left(int value) { this.Move(value, this.Position.Y,	0);	}

		public /+virtual+/ int Right() { return this.Position.X + this.size.Width;	}
		public /+virtual+/ void Right( int value) { this.Move(value -	this.size.Width, this.Position.Y, 0); }

		public /+virtual+/ int Bottom() { return this.Position.Y + this.size.Height; }
		public /+virtual+/ void Bottom(int value) { this.Move(this.Position.X, value - this.size.Height, 0); }

		public /+virtual+/ int Width() { return this.size.Width; }
		public /+virtual+/ void Width(int value) { Size size; size.Width = value; size.Height = this.size.Height; this.size = size; }

		public /+virtual+/ int Height() { return this.size.Height; }
		public /+virtual+/ void Height(int value) { Size size; size.Width = this.size.Width; size.Height = value; this.size = size; }

		//---------------------------------------------------------------------
		
		public WindowVariant windowVariant() { return cast(WindowVariant)wxWindow_GetWindowVariant(wxobj); }		
		//---------------------------------------------------------------------
		
		public bool IsBeingDeleted()
		{
			return wxWindow_IsBeingDeleted(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public void CacheBestSize(Size size)
		{
			wxWindow_CacheBestSize(wxobj, size);
		}
		
		//---------------------------------------------------------------------
		
		public void InvalidateBestSize()
		{
			wxWindow_InvalidateBestSize(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public Size BestFittingSize()
		{
			Size size;
			wxWindow_GetBestFittingSize(wxobj, size);
			return size;
		}
		public void BestFittingSize(Size value)
		{			
			wxWindow_SetBestFittingSize(wxobj, value);
		}
		
		//---------------------------------------------------------------------
		
		public Window[] Children()
		{
			int count = wxWindow_GetChildrenCount(wxobj);
			Window[] ret = new Window[count];
			for (int num = 0; num < count; num++)
			{
				ret[num] = cast(Window)FindObject(wxWindow_GetChildren(wxobj, num));
			}
			return ret;
		}
		
		//---------------------------------------------------------------------
		
		public AcceleratorTable acceleratorTable() { return cast(AcceleratorTable)FindObject(wxWindow_GetAcceleratorTable(wxobj),&AcceleratorTable.New); }		
		//---------------------------------------------------------------------
		
		public /+virtual+/ VisualAttributes DefaultAttributes()
		{
			return new VisualAttributes(wxWindow_GetDefaultAttributes(wxobj), true);
		}
		
		//---------------------------------------------------------------------
		
		public static VisualAttributes ClassDefaultAttributes()
		{
			return ClassDefaultAttributes(WindowVariant.wxWINDOW_VARIANT_NORMAL);
		}
		
		public static VisualAttributes ClassDefaultAttributes(WindowVariant variant)
		{
			return new VisualAttributes(wxWindow_GetClassDefaultAttributes(cast(int)variant), true);
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ BackgroundStyle backgroundStyle()
		{
			return cast(BackgroundStyle)wxWindow_GetBackgroundStyle(wxobj);
		}
		public /+virtual+/ void backgroundStyle(BackgroundStyle value)
		{
			wxWindow_SetBackgroundStyle(wxobj, cast(int)value);
		}
		
		//---------------------------------------------------------------------
		
		public Border border() { return cast(Border)wxWindow_GetBorder(wxobj); }		
		public Border BorderByFlags(uint flags)
		{
			return cast(Border)wxWindow_GetBorderByFlags(wxobj, flags);
		}
		
		//---------------------------------------------------------------------
		
                // TODO Not available in OS X
                /*
		public string ToolTipText() { return cast(string) new wxString(wxWindow_GetToolTipText(wxobj), true); }                */
		
		//---------------------------------------------------------------------
		
		public Window AncestorWithCustomPalette() { return cast(Window)FindObject(wxWindow_GetAncestorWithCustomPalette(wxobj),&Window.New); }		
		//---------------------------------------------------------------------
		
		public /+virtual+/ void InheritAttributes()
		{
			wxWindow_InheritAttributes(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ bool ShouldInheritColours()
		{
			return wxWindow_ShouldInheritColours(wxobj);
		}
		
		//---------------------------------------------------------------------

		public void LeftUp_Add(EventListener value) { AddCommandListener(Event.wxEVT_LEFT_UP, ID, value, this); }
		public void LeftUp_Remove(EventListener value) { RemoveHandler(value, this); }

		public void RightUp_Add(EventListener value) { AddCommandListener(Event.wxEVT_RIGHT_UP, ID, value, this); }
		public void RightUp_Remove(EventListener value) { RemoveHandler(value, this); }

		public void MiddleUp_Add(EventListener value) { AddCommandListener(Event.wxEVT_MIDDLE_UP, ID, value, this); }
		public void MiddleUp_Remove(EventListener value) { RemoveHandler(value, this); }

		public void LeftDown_Add(EventListener value) { AddCommandListener(Event.wxEVT_LEFT_DOWN, ID, value, this); }
		public void LeftDown_Remove(EventListener value) { RemoveHandler(value, this); }

		public void MiddleDown_Add(EventListener value) { AddCommandListener(Event.wxEVT_MIDDLE_DOWN, ID, value, this); }
		public void MiddleDown_Remove(EventListener value) { RemoveHandler(value, this); }

		public void RightDown_Add(EventListener value) { AddCommandListener(Event.wxEVT_RIGHT_DOWN, ID, value, this); }
		public void RightDown_Remove(EventListener value) { RemoveHandler(value, this); }

		public void LeftDoubleClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_LEFT_DCLICK, ID, value, this); }
		public void LeftDoubleClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void RightDoubleClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_RIGHT_DCLICK, ID, value, this); }
		public void RightDoubleClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void MiddleDoubleClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_MIDDLE_DCLICK, ID, value, this); }
		public void MiddleDoubleClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void MouseMove_Add(EventListener value) { AddCommandListener(Event.wxEVT_MOTION, ID, value, this); }
		public void MouseMove_Remove(EventListener value) { RemoveHandler(value, this); }

		public void MouseThumbTrack_Add(EventListener value) { AddCommandListener(Event.wxEVT_SCROLL_THUMBTRACK, ID, value, this); }
		public void MouseThumbTrack_Remove(EventListener value) { RemoveHandler(value, this); }

		public void MouseEnter_Add(EventListener value) { AddCommandListener(Event.wxEVT_ENTER_WINDOW, ID, value, this); }
		public void MouseEnter_Remove(EventListener value) { RemoveHandler(value, this); }

		public void MouseLeave_Add(EventListener value) { AddCommandListener(Event.wxEVT_LEAVE_WINDOW, ID, value, this); }
		public void MouseLeave_Remove(EventListener value) { RemoveHandler(value, this); }

		public void ScrollLineUp_Add(EventListener value) { AddCommandListener(Event.wxEVT_SCROLL_LINEUP, ID, value, this); }
		public void ScrollLineUp_Remove(EventListener value) { RemoveHandler(value, this); }

		public void ScrollLineDown_Add(EventListener value) { AddCommandListener(Event.wxEVT_SCROLL_LINEDOWN, ID, value, this); }
		public void ScrollLineDown_Remove(EventListener value) { RemoveHandler(value, this); }

		public void UpdateUI_Add(EventListener value) { AddCommandListener(Event.wxEVT_UPDATE_UI, ID, value, this); }
		public void UpdateUI_Remove(EventListener value) { RemoveHandler(value, this); }

		public void KeyDown_Add(EventListener value) { AddCommandListener(Event.wxEVT_KEY_DOWN, ID, value, this); }
		public void KeyDown_Remove(EventListener value) { RemoveHandler(value, this); }

		public void KeyUp_Add(EventListener value) { AddCommandListener(Event.wxEVT_KEY_UP, ID, value, this); }
		public void KeyUp_Remove(EventListener value) { RemoveHandler(value, this); }

		public void Char_Add(EventListener value) { AddCommandListener(Event.wxEVT_CHAR, ID, value, this); }
		public void Char_Remove(EventListener value) { RemoveHandler(value, this); }

		public void Closing_Add(EventListener value) { AddCommandListener(Event.wxEVT_CLOSE_WINDOW, ID, value, this); }
		public void Closing_Remove(EventListener value) { RemoveHandler(value, this); }

		public void Activated_Add(EventListener value) { AddCommandListener(Event.wxEVT_ACTIVATE, ID, value, this); }
		public void Activated_Remove(EventListener value) { RemoveHandler(value, this); }

		public void Moved_Add(EventListener value) { AddCommandListener(Event.wxEVT_MOVE, ID, value, this); }
		public void Moved_Remove(EventListener value) { RemoveHandler(value, this); }

		public void Resized_Add(EventListener value) { AddCommandListener(Event.wxEVT_SIZE, ID, value, this); }
		public void Resized_Remove(EventListener value) { RemoveHandler(value, this); }
	}

