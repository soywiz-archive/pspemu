//-----------------------------------------------------------------------------
// wxD - Grid.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Grid.cs
//
/// The wxGrid wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 by Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Grid.d,v 1.12 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.Grid;
public import wx.common;
public import wx.Event;
public import wx.KeyEvent;
public import wx.CommandEvent;
public import wx.Window;
public import wx.Control;
public import wx.ScrolledWindow;

    public enum GridSelectionMode
    {
        wxGridSelectCells,
        wxGridSelectRows,
        wxGridSelectColumns
    }

		//! \cond EXTERN
        static extern (C) IntPtr wxGridEvent_ctor(int id, int type, IntPtr obj, int row, int col, int x, int y, bool sel, bool control, bool shift, bool alt, bool meta);
        static extern (C) int    wxGridEvent_GetRow(IntPtr self);
        static extern (C) int    wxGridEvent_GetCol(IntPtr self);
        static extern (C) void   wxGridEvent_GetPosition(IntPtr self, ref Point pt);
        static extern (C) bool   wxGridEvent_Selecting(IntPtr self);
        static extern (C) bool   wxGridEvent_ControlDown(IntPtr self);
        static extern (C) bool   wxGridEvent_MetaDown(IntPtr self);
        static extern (C) bool   wxGridEvent_ShiftDown(IntPtr self);
        static extern (C) bool   wxGridEvent_AltDown(IntPtr self);
        static extern (C) void wxGridEvent_Veto(IntPtr self);
        static extern (C) void wxGridEvent_Allow(IntPtr self);
        static extern (C) bool wxGridEvent_IsAllowed(IntPtr self);      
		//! \endcond

        //-----------------------------------------------------------------------------

    alias GridEvent wxGridEvent;
    public class GridEvent : Event 
    {
        public this(IntPtr wxobj)
            { super(wxobj); }

        public this(int id, int type, wxObject obj, int row, int col, int x, int y, bool sel, bool control, bool shift, bool alt, bool meta)
            { this(wxGridEvent_ctor(id, type, wxObject.SafePtr(obj), row, col, x, y, sel, control, shift, alt, meta)); }

        //-----------------------------------------------------------------------------

        public int Row() { return wxGridEvent_GetRow(wxobj); }

        public int Col() { return wxGridEvent_GetCol(wxobj); }

        //-----------------------------------------------------------------------------

        public Point Position() { 
                Point pt;
                wxGridEvent_GetPosition(wxobj, pt);
                return pt;
            }

        //-----------------------------------------------------------------------------

        public bool Selecting() { return wxGridEvent_Selecting(wxobj); }

        //-----------------------------------------------------------------------------

        public bool ControlDown() { return wxGridEvent_ControlDown(wxobj); }

        public bool MetaDown() { return wxGridEvent_MetaDown(wxobj); }

        public bool ShiftDown() { return wxGridEvent_ShiftDown(wxobj); }

            public bool AltDown() { return wxGridEvent_AltDown(wxobj); }
        
        //-----------------------------------------------------------------------------     
        
        public void Veto()
        {
            wxGridEvent_Veto(wxobj);
        }
        
        //-----------------------------------------------------------------------------
        
        public void Allow()
        {
            wxGridEvent_Allow(wxobj);
        }
        
        //-----------------------------------------------------------------------------
        
        public bool Allowed() { return wxGridEvent_IsAllowed(wxobj); }

	private static Event New(IntPtr obj) { return new GridEvent(obj); }

	static this()
	{
			wxEVT_GRID_CELL_LEFT_CLICK = wxEvent_EVT_GRID_CELL_LEFT_CLICK();
			wxEVT_GRID_CELL_RIGHT_CLICK = wxEvent_EVT_GRID_CELL_RIGHT_CLICK();
			wxEVT_GRID_CELL_LEFT_DCLICK = wxEvent_EVT_GRID_CELL_LEFT_DCLICK();
			wxEVT_GRID_CELL_RIGHT_DCLICK = wxEvent_EVT_GRID_CELL_RIGHT_DCLICK();
			wxEVT_GRID_LABEL_LEFT_CLICK = wxEvent_EVT_GRID_LABEL_LEFT_CLICK();
			wxEVT_GRID_LABEL_RIGHT_CLICK = wxEvent_EVT_GRID_LABEL_RIGHT_CLICK();
			wxEVT_GRID_LABEL_LEFT_DCLICK = wxEvent_EVT_GRID_LABEL_LEFT_DCLICK();
			wxEVT_GRID_LABEL_RIGHT_DCLICK = wxEvent_EVT_GRID_LABEL_RIGHT_DCLICK();
			wxEVT_GRID_CELL_CHANGE = wxEvent_EVT_GRID_CELL_CHANGE();
			wxEVT_GRID_SELECT_CELL = wxEvent_EVT_GRID_SELECT_CELL();
			wxEVT_GRID_EDITOR_SHOWN = wxEvent_EVT_GRID_EDITOR_SHOWN();
			wxEVT_GRID_EDITOR_HIDDEN = wxEvent_EVT_GRID_EDITOR_HIDDEN();
			wxEVT_GRID_EDITOR_CREATED = wxEvent_EVT_GRID_EDITOR_CREATED();

			AddEventType(wxEVT_GRID_CELL_LEFT_CLICK,            &GridEvent.New);
			AddEventType(wxEVT_GRID_CELL_RIGHT_CLICK,           &GridEvent.New);
			AddEventType(wxEVT_GRID_CELL_LEFT_DCLICK,           &GridEvent.New);
			AddEventType(wxEVT_GRID_CELL_RIGHT_DCLICK,          &GridEvent.New);
			AddEventType(wxEVT_GRID_LABEL_LEFT_CLICK,           &GridEvent.New);
			AddEventType(wxEVT_GRID_LABEL_RIGHT_CLICK,          &GridEvent.New);
			AddEventType(wxEVT_GRID_LABEL_LEFT_DCLICK,          &GridEvent.New);
			AddEventType(wxEVT_GRID_LABEL_RIGHT_DCLICK,         &GridEvent.New);
			AddEventType(wxEVT_GRID_CELL_CHANGE,                &GridEvent.New);
			AddEventType(wxEVT_GRID_SELECT_CELL,                &GridEvent.New);
			AddEventType(wxEVT_GRID_EDITOR_SHOWN,               &GridEvent.New);
			AddEventType(wxEVT_GRID_EDITOR_HIDDEN,              &GridEvent.New);
	}
    }
    
    //-----------------------------------------------------------------------------

		//! \cond EXTERN
	extern (C) {
        alias void   function(GridCellEditor obj, IntPtr parent, int id, IntPtr evtHandler) Virtual_Create;
        alias void   function(GridCellEditor obj, int row, int col, IntPtr grid) Virtual_BeginEdit;
        alias bool   function(GridCellEditor obj, int row, int col, IntPtr grid) Virtual_EndEdit;
        alias void   function(GridCellEditor obj) Virtual_Reset;
        alias IntPtr function(GridCellEditor obj) Virtual_Clone;
        alias void   function(GridCellEditor obj, Rectangle rect) Virtual_SetSize;
        alias void   function(GridCellEditor obj, bool show, IntPtr attr) Virtual_Show;
        alias void   function(GridCellEditor obj, Rectangle rect, IntPtr attr) Virtual_PaintBackground;
        alias bool   function(GridCellEditor obj, IntPtr evt) Virtual_IsAcceptedKey;
        alias void   function(GridCellEditor obj, IntPtr evt) Virtual_StartingKey;
        alias void   function(GridCellEditor obj) Virtual_StartingClick;
        alias void   function(GridCellEditor obj, IntPtr evt) Virtual_HandleReturn;
        alias void   function(GridCellEditor obj) Virtual_Destroy;
        alias string function(GridCellEditor obj) Virtual_GetValue;
	}

        static extern (C) IntPtr wxGridCellEditor_ctor();
	static extern (C) void wxGridCellEditor_dtor(IntPtr self);
        static extern (C) void wxGridCellEditor_RegisterVirtual(IntPtr self, GridCellEditor obj,
            Virtual_Create create, 
            Virtual_BeginEdit beginEdit, 
            Virtual_EndEdit endEdit, 
            Virtual_Reset reset, 
            Virtual_Clone clone,
            Virtual_SetSize setSize,
            Virtual_Show show,
            Virtual_PaintBackground paintBackground,
            Virtual_IsAcceptedKey isAcceptedKey,
            Virtual_StartingKey startingKey,
            Virtual_StartingClick startingClick,
            Virtual_HandleReturn handleReturn,
            Virtual_Destroy destroy,
            Virtual_GetValue getvalue);
        static extern (C) bool   wxGridCellEditor_IsCreated(IntPtr self);
        static extern (C) void   wxGridCellEditor_SetSize(IntPtr self, ref Rectangle rect);
        static extern (C) void   wxGridCellEditor_Show(IntPtr self, bool show, IntPtr attr);
        static extern (C) void   wxGridCellEditor_PaintBackground(IntPtr self, ref Rectangle rectCell, IntPtr attr);
        static extern (C) bool   wxGridCellEditor_IsAcceptedKey(IntPtr self, IntPtr evt);
        static extern (C) void   wxGridCellEditor_StartingKey(IntPtr self, IntPtr evt);
        static extern (C) void   wxGridCellEditor_StartingClick(IntPtr self);
        static extern (C) void   wxGridCellEditor_HandleReturn(IntPtr self, IntPtr evt);
        static extern (C) void   wxGridCellEditor_Destroy(IntPtr self);
        static extern (C) IntPtr wxGridCellEditor_GetValue(IntPtr self);
		//! \endcond
	
        //-----------------------------------------------------------------------------
        
    public abstract class GridCellEditor : GridCellWorker
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
        	this(wxGridCellEditor_ctor(), true);
            wxGridCellEditor_RegisterVirtual(wxobj, this,
                    &staticDoCreate,
                    &staticDoBeginEdit,
                    &staticDoEndEdit,
                    &staticReset,
                    &staticDoClone,
                    &staticSetSize,
                    &staticDoShow,
                    &staticDoPaintBackground,
                    &staticDoIsAcceptedKey,
                    &staticDoStartingKey,
                    &staticStartingClick,
                    &staticDoHandleReturn,
                    &staticDestroy,
                    &staticGetValue);                                    
        }

//	public static wxObject New(IntPtr ptr) { return new GridCellEditor(ptr); }
	//---------------------------------------------------------------------
	
	override protected void dtor() { wxGridCellEditor_dtor(wxobj); }
            
        //-----------------------------------------------------------------------------
    
        public bool IsCreated() { return wxGridCellEditor_IsCreated(wxobj); }
    
        //-----------------------------------------------------------------------------
        
        static extern(C) private void staticDoCreate(GridCellEditor obj, IntPtr parent, int id, IntPtr evtHandler)
        {
            obj.Create(cast(Window)wxObject.FindObject(parent), id, cast(EvtHandler)FindObject(evtHandler, &EvtHandler.New));
        }
    
        public abstract void Create(Window parent, int id, EvtHandler evtHandler);
    
        //-----------------------------------------------------------------------------
        
        static extern(C) private void staticSetSize(GridCellEditor obj, Rectangle rect)
        {
        	obj.SetSize(rect);
        }

        public /+virtual+/ void SetSize(Rectangle rect)
        {
            wxGridCellEditor_SetSize(wxobj, rect);
        }

        //-----------------------------------------------------------------------------
        
        static extern(C) private void staticDoShow(GridCellEditor obj, bool show, IntPtr attr)
        {
            obj.Show(show, cast(GridCellAttr)FindObject(attr, &GridCellAttr.New));
        }

        public /+virtual+/ void Show(bool show, GridCellAttr attr)
        {
            wxGridCellEditor_Show(wxobj, show, wxObject.SafePtr(attr));
        }

        //-----------------------------------------------------------------------------
        
        static extern(C) private void staticDoPaintBackground(GridCellEditor obj, Rectangle rectCell, IntPtr attr)
        {
            obj.PaintBackground(rectCell, cast(GridCellAttr)FindObject(attr, &GridCellAttr.New));
        }

        public /+virtual+/ void PaintBackground(Rectangle rectCell, GridCellAttr attr)
        {
            wxGridCellEditor_PaintBackground(wxobj, rectCell, wxObject.SafePtr(attr));
        }

        //-----------------------------------------------------------------------------
        
        static extern(C) private void staticDoBeginEdit(GridCellEditor obj, int row, int col, IntPtr grid)
        {
            obj.BeginEdit(row, col, cast(Grid)FindObject(grid, &Grid.New));
        }
    
        public abstract void BeginEdit(int row, int col, Grid grid);
        
        static extern(C) private bool staticDoEndEdit(GridCellEditor obj, int row, int col, IntPtr grid)
        {
            return obj.EndEdit(row, col, cast(Grid)FindObject(grid, &Grid.New));
        }
        
        public abstract bool EndEdit(int row, int col, Grid grid);
    
        //-----------------------------------------------------------------------------
    
        static extern(C) private void staticReset(GridCellEditor obj)
        {
            return obj.Reset();
        }

        public abstract void Reset();
    
        //-----------------------------------------------------------------------------
        
        static extern(C) private bool staticDoIsAcceptedKey(GridCellEditor obj, IntPtr evt)
        {
            return obj.IsAcceptedKey(cast(KeyEvent)wxObject.FindObject(evt, cast(wxObject function(IntPtr))&KeyEvent.New));
        }
        
        public /+virtual+/ bool IsAcceptedKey(KeyEvent evt)
        {
            return wxGridCellEditor_IsAcceptedKey(wxobj, wxObject.SafePtr(evt));
        }
        
        static extern(C) private void staticDoStartingKey(GridCellEditor obj, IntPtr evt)
        {
            obj.StartingKey(cast(KeyEvent)wxObject.FindObject(evt, cast(wxObject function(IntPtr))&KeyEvent.New));
        }
    
        public /+virtual+/ void StartingKey(KeyEvent evt)
        {
            wxGridCellEditor_StartingKey(wxobj, wxObject.SafePtr(evt));
        }

	static extern(C) private void staticStartingClick(GridCellEditor obj)
	{
	    obj.StartingClick();
	}
        public /+virtual+/ void StartingClick()
        {
            wxGridCellEditor_StartingClick(wxobj);
        }

        //-----------------------------------------------------------------------------
        
        static extern(C) private void staticDoHandleReturn(GridCellEditor obj, IntPtr evt)
        {
            obj.HandleReturn(cast(KeyEvent)wxObject.FindObject(evt, cast(wxObject function(IntPtr))&KeyEvent.New));
        }

        public /+virtual+/ void HandleReturn(KeyEvent evt)
        {
            wxGridCellEditor_HandleReturn(wxobj, wxObject.SafePtr(evt));
        }

        //-----------------------------------------------------------------------------

	static extern(C) private void staticDestroy(GridCellEditor obj)
	{
		obj.Destroy();
	}

        public /+virtual+/ void Destroy()
        {
            wxGridCellEditor_Destroy(wxobj);
        }

        //-----------------------------------------------------------------------------
        
        static extern(C) private IntPtr staticDoClone(GridCellEditor obj)
        {
            return wxObject.SafePtr(obj.Clone());
        }
        
        public abstract GridCellEditor Clone();
        
        //-----------------------------------------------------------------------------
        
        static extern(C) private string staticGetValue(GridCellEditor obj)
        {
            return obj.GetValue();
        }
        public abstract string GetValue();
//        {
//            return cast(string) new wxString(wxGridCellEditor_GetValue(wxobj), true);
//        }
    }
    
    //-----------------------------------------------------------------------------
    
		//! \cond EXTERN
        static extern (C) IntPtr wxGridCellTextEditor_ctor();
	static extern (C) void wxGridCellTextEditor_dtor(IntPtr self);
        static extern (C) void wxGridCellTextEditor_Create(IntPtr self, IntPtr parent, int id, IntPtr evtHandler);
        static extern (C) void wxGridCellTextEditor_SetSize(IntPtr self, ref Rectangle rect);
        static extern (C) void wxGridCellTextEditor_PaintBackground(IntPtr self, ref Rectangle rectCell, IntPtr attr);
        static extern (C) bool wxGridCellTextEditor_IsAcceptedKey(IntPtr self, IntPtr evt);
        static extern (C) void wxGridCellTextEditor_BeginEdit(IntPtr self, int row, int col, IntPtr grid);
        static extern (C) bool wxGridCellTextEditor_EndEdit(IntPtr self, int row, int col, IntPtr grid);
        static extern (C) void wxGridCellTextEditor_Reset(IntPtr self);
        static extern (C) void wxGridCellTextEditor_StartingKey(IntPtr self, IntPtr evt);
        static extern (C) void wxGridCellTextEditor_SetParameters(IntPtr self, string parameter);
        static extern (C) IntPtr wxGridCellTextEditor_Clone(IntPtr self);
        static extern (C) IntPtr wxGridCellTextEditor_GetValue(IntPtr self);
		//! \endcond
	
    alias GridCellTextEditor wxGridCellTextEditor;
    public class GridCellTextEditor : GridCellEditor
    {
        public this()
            { this(wxGridCellTextEditor_ctor(), true); }

        public this(IntPtr wxobj)
	{ 
		super(wxobj);
	}
	
	private this(IntPtr wxobj, bool memOwn)
	{ 
		super(wxobj);
		this.memOwn = memOwn;
	}
	
	//---------------------------------------------------------------------
				
	override protected void dtor() { wxGridCellTextEditor_dtor(wxobj); }

        public override void Create(Window parent, int id, EvtHandler evtHandler)
        {
            wxGridCellTextEditor_Create(wxobj, wxObject.SafePtr(parent), id, wxObject.SafePtr(evtHandler));
        }

        public override void SetSize(Rectangle rect)
        {
            wxGridCellTextEditor_SetSize(wxobj, rect);
        }

        public override void PaintBackground(Rectangle rectCell, GridCellAttr attr)
        {
            wxGridCellTextEditor_PaintBackground(wxobj, rectCell, wxObject.SafePtr(attr));
        }

        public override bool IsAcceptedKey(KeyEvent evt)
        {
            return wxGridCellTextEditor_IsAcceptedKey(wxobj, wxObject.SafePtr(evt));
        }

        public override void BeginEdit(int row, int col, Grid grid)
        {
            wxGridCellTextEditor_BeginEdit(wxobj, row, col, wxObject.SafePtr(grid));
        }

        public override bool EndEdit(int row, int col, Grid grid)
        {
            return wxGridCellTextEditor_EndEdit(wxobj, row, col, wxObject.SafePtr(grid));
        }

        public override void Reset()
        {
            wxGridCellTextEditor_Reset(wxobj);
        }

        public override void StartingKey(KeyEvent evt)
        {
            wxGridCellTextEditor_StartingKey(wxobj, wxObject.SafePtr(evt));
        }

        public override void SetParameters(string parameter)
        {
            wxGridCellTextEditor_SetParameters(wxobj, parameter);
        }

        public override GridCellEditor Clone()
        {
//            return cast(GridCellEditor)FindObject(wxGridCellTextEditor_Clone(wxobj), &GridCellEditor.New);
              return new GridCellTextEditor(wxGridCellTextEditor_Clone(wxobj));
        }
        public override string GetValue()
        {
            return cast(string) new wxString(wxGridCellTextEditor_GetValue(wxobj), true);
        }
    }

    //-----------------------------------------------------------------------------

		//! \cond EXTERN
        static extern (C) IntPtr wxGridCellNumberEditor_ctor(int min, int max);
	static extern (C) void wxGridCellNumberEditor_dtor(IntPtr self);
	static extern (C) void wxGridCellNumberEditor_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
        static extern (C) void wxGridCellNumberEditor_Create(IntPtr self, IntPtr parent, int id, IntPtr evtHandler);
        static extern (C) bool wxGridCellNumberEditor_IsAcceptedKey(IntPtr self, IntPtr evt);
        static extern (C) void wxGridCellNumberEditor_BeginEdit(IntPtr self, int row, int col, IntPtr grid);
        static extern (C) bool wxGridCellNumberEditor_EndEdit(IntPtr self, int row, int col, IntPtr grid);
        static extern (C) void wxGridCellNumberEditor_Reset(IntPtr self);
        static extern (C) void wxGridCellNumberEditor_StartingKey(IntPtr self, IntPtr evt);
        static extern (C) void wxGridCellNumberEditor_SetParameters(IntPtr self, string parameter);
        static extern (C) IntPtr wxGridCellNumberEditor_Clone(IntPtr self);
        static extern (C) IntPtr wxGridCellNumberEditor_GetValue(IntPtr self);
		//! \endcond
	
    alias GridCellNumberEditor wxGridCellNumberEditor;
    public class GridCellNumberEditor : GridCellTextEditor
    {
        public this()
            { this(-1, -1); }

        public this(int min)
            { this(min, -1); }

        public this(int min, int max)
	{ 
		this(wxGridCellNumberEditor_ctor(min, max), true);
		wxGridCellNumberEditor_RegisterDisposable(wxobj, &VirtualDispose);
	}

        public this(IntPtr wxobj)
	{ 
		super(wxobj);
	}
	
	private this(IntPtr wxobj, bool memOwn)
	{ 
		super(wxobj);
		this.memOwn = memOwn;
	}
	
	//---------------------------------------------------------------------
				
	override protected void dtor() { wxGridCellNumberEditor_dtor(wxobj); }

        public override void Create(Window parent, int id, EvtHandler evtHandler)
        {
            wxGridCellNumberEditor_Create(wxobj, wxObject.SafePtr(parent), id, wxObject.SafePtr(evtHandler));
        }

        public override bool IsAcceptedKey(KeyEvent evt)
        {
            return wxGridCellNumberEditor_IsAcceptedKey(wxobj, wxObject.SafePtr(evt));
        }

        public override void BeginEdit(int row, int col, Grid grid)
        {
            wxGridCellNumberEditor_BeginEdit(wxobj, row, col, wxObject.SafePtr(grid));
        }

        public override bool EndEdit(int row, int col, Grid grid)
        {
            return wxGridCellNumberEditor_EndEdit(wxobj, row, col, wxObject.SafePtr(grid));
        }

        public override void Reset()
        {
            wxGridCellNumberEditor_Reset(wxobj);
        }

        public override void StartingKey(KeyEvent evt)
        {
            wxGridCellNumberEditor_StartingKey(wxobj, wxObject.SafePtr(evt));
        }

        public override void SetParameters(string parameter)
        {
            wxGridCellNumberEditor_SetParameters(wxobj, parameter);
        }

        public override GridCellEditor Clone()
        {
//            return cast(GridCellEditor)FindObject(wxGridCellNumberEditor_Clone(wxobj), &GridCellEditor.New);
              return new GridCellNumberEditor(wxGridCellNumberEditor_Clone(wxobj));
        }

        public override string GetValue()
        {
            return cast(string) new wxString(wxGridCellNumberEditor_GetValue(wxobj), true);
        }
    }

    //-----------------------------------------------------------------------------

		//! \cond EXTERN
        static extern (C) IntPtr wxGridCellFloatEditor_ctor(int width, int precision);
	static extern (C) void wxGridCellFloatEditor_dtor(IntPtr self);
        static extern (C) void wxGridCellFloatEditor_Create(IntPtr self, IntPtr parent, int id, IntPtr evtHandler);
        static extern (C) bool wxGridCellFloatEditor_IsAcceptedKey(IntPtr self, IntPtr evt);
        static extern (C) void wxGridCellFloatEditor_BeginEdit(IntPtr self, int row, int col, IntPtr grid);
        static extern (C) bool wxGridCellFloatEditor_EndEdit(IntPtr self, int row, int col, IntPtr grid);
        static extern (C) void wxGridCellFloatEditor_Reset(IntPtr self);
        static extern (C) void wxGridCellFloatEditor_StartingKey(IntPtr self, IntPtr evt);
        static extern (C) void wxGridCellFloatEditor_SetParameters(IntPtr self, string parameter);
        static extern (C) IntPtr wxGridCellFloatEditor_Clone(IntPtr self);
        static extern (C) IntPtr wxGridCellFloatEditor_GetValue(IntPtr self);
		//! \endcond
	
    alias GridCellFloatEditor wxGridCellFloatEditor;
    public class GridCellFloatEditor : GridCellTextEditor
    {
        public this()
            { this(-1, -1); }

        public this(int width)
            { this(width, -1); }

        public this(int width, int precision)
            { this(wxGridCellFloatEditor_ctor(width, precision), true); }

        public this(IntPtr wxobj)
	{ 
		super(wxobj);
	}
	
	private this(IntPtr wxobj, bool memOwn)
	{ 
		super(wxobj);
		this.memOwn = memOwn;
	}
	
	//---------------------------------------------------------------------
				
	override protected void dtor() { wxGridCellFloatEditor_dtor(wxobj); }

        public override void Create(Window parent, int id, EvtHandler evtHandler)
        {
            wxGridCellFloatEditor_Create(wxobj, wxObject.SafePtr(parent), id, wxObject.SafePtr(evtHandler));
        }

        public override bool IsAcceptedKey(KeyEvent evt)
        {
            return wxGridCellFloatEditor_IsAcceptedKey(wxobj, wxObject.SafePtr(evt));
        }

        public override void BeginEdit(int row, int col, Grid grid)
        {
            wxGridCellFloatEditor_BeginEdit(wxobj, row, col, wxObject.SafePtr(grid));
        }

        public override bool EndEdit(int row, int col, Grid grid)
        {
            return wxGridCellFloatEditor_EndEdit(wxobj, row, col, wxObject.SafePtr(grid));
        }

        public override void Reset()
        {
            wxGridCellFloatEditor_Reset(wxobj);
        }

        public override void StartingKey(KeyEvent evt)
        {
            wxGridCellFloatEditor_StartingKey(wxobj, wxObject.SafePtr(evt));
        }

        public override void SetParameters(string parameter)
        {
            wxGridCellFloatEditor_SetParameters(wxobj, parameter);
        }

        public override GridCellEditor Clone()
        {
//            return cast(GridCellEditor)FindObject(wxGridCellFloatEditor_Clone(wxobj), &GridCellEditor.New);
              return new GridCellFloatEditor(wxGridCellFloatEditor_Clone(wxobj));
        }

        public override string GetValue()
        {
            return cast(string) new wxString(wxGridCellFloatEditor_GetValue(wxobj), true);
        }
    }

    //-----------------------------------------------------------------------------
    
		//! \cond EXTERN
        static extern (C) IntPtr wxGridCellBoolEditor_ctor();
	static extern (C) void wxGridCellBoolEditor_dtor(IntPtr self);
	static extern (C) void wxGridCellBoolEditor_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
        static extern (C) void wxGridCellBoolEditor_Create(IntPtr self, IntPtr parent, int id, IntPtr evtHandler);
        static extern (C) void wxGridCellBoolEditor_SetSize(IntPtr self, ref Rectangle rect);
        static extern (C) bool wxGridCellBoolEditor_IsAcceptedKey(IntPtr self, IntPtr evt);
        static extern (C) void wxGridCellBoolEditor_BeginEdit(IntPtr self, int row, int col, IntPtr grid);
        static extern (C) bool wxGridCellBoolEditor_EndEdit(IntPtr self, int row, int col, IntPtr grid);
        static extern (C) void wxGridCellBoolEditor_Reset(IntPtr self);
        static extern (C) void wxGridCellBoolEditor_StartingClick(IntPtr self);
        static extern (C) IntPtr wxGridCellBoolEditor_Clone(IntPtr self);
        static extern (C) IntPtr wxGridCellBoolEditor_GetValue(IntPtr self);
		//! \endcond
	
    alias GridCellBoolEditor wxGridCellBoolEditor;
    public class GridCellBoolEditor : GridCellEditor
    {
        public this()
	{ 
		this(wxGridCellBoolEditor_ctor(), true);
		wxGridCellBoolEditor_RegisterDisposable(wxobj, &VirtualDispose);
	}

        public this(IntPtr wxobj)
	{ 
		super(wxobj);
	}
	
	private this(IntPtr wxobj, bool memOwn)
	{ 
		super(wxobj);
		this.memOwn = memOwn;
	}
	
	//---------------------------------------------------------------------
				
	override protected void dtor() { wxGridCellBoolEditor_dtor(wxobj); }

        public override void Create(Window parent, int id, EvtHandler evtHandler)
        {
            wxGridCellBoolEditor_Create(wxobj, wxObject.SafePtr(parent), id, wxObject.SafePtr(evtHandler));
        }

        public override void SetSize(Rectangle rect)
        {
            wxGridCellBoolEditor_SetSize(wxobj, rect);
        }

        public override bool IsAcceptedKey(KeyEvent evt)
        {
            return wxGridCellBoolEditor_IsAcceptedKey(wxobj, wxObject.SafePtr(evt));
        }

        public override void BeginEdit(int row, int col, Grid grid)
        {
            wxGridCellBoolEditor_BeginEdit(wxobj, row, col, wxObject.SafePtr(grid));
        }
        
        public override bool EndEdit(int row, int col, Grid grid)
        {
            return wxGridCellBoolEditor_EndEdit(wxobj, row, col, wxObject.SafePtr(grid));
        }
        
        public override void Reset()
        {
            wxGridCellBoolEditor_Reset(wxobj);
        }

        public override void StartingClick()
        {
            wxGridCellBoolEditor_StartingClick(wxobj);
        }
        
        public override GridCellEditor Clone()
        {
//            return cast(GridCellEditor)FindObject(wxGridCellBoolEditor_Clone(wxobj), &GridCellEditor.New);
              return new GridCellBoolEditor(wxGridCellBoolEditor_Clone(wxobj));
        }       

        public override string GetValue()
        {
            return cast(string) new wxString(wxGridCellBoolEditor_GetValue(wxobj), true);
        }
    }
    
    //-----------------------------------------------------------------------------
    
		//! \cond EXTERN
        static extern (C) IntPtr wxGridCellChoiceEditor_ctor(int n, string* choices, bool allowOthers);
	static extern (C) void wxGridCellChoiceEditor_dtor(IntPtr self);
	static extern (C) void wxGridCellChoiceEditor_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
        static extern (C) void wxGridCellChoiceEditor_Create(IntPtr self, IntPtr parent, int id, IntPtr evtHandler);
        static extern (C) void wxGridCellChoiceEditor_PaintBackground(IntPtr self, ref Rectangle rectCell, IntPtr attr);
        static extern (C) void wxGridCellChoiceEditor_BeginEdit(IntPtr self, int row, int col, IntPtr grid);
        static extern (C) bool wxGridCellChoiceEditor_EndEdit(IntPtr self, int row, int col, IntPtr grid);
        static extern (C) void wxGridCellChoiceEditor_Reset(IntPtr self);
        static extern (C) void wxGridCellChoiceEditor_SetParameters(IntPtr self, string parameter);
        static extern (C) IntPtr wxGridCellChoiceEditor_Clone(IntPtr self);
        static extern (C) IntPtr wxGridCellChoiceEditor_GetValue(IntPtr self);
		//! \endcond
	
    alias GridCellChoiceEditor wxGridCellChoiceEditor;
    public class GridCellChoiceEditor : GridCellEditor
    {
        public this()
            { this(cast(string[])null, false); }
        
        public this(string[] choices)
            { this(choices, false); }
        
        public this(string[] choices, bool allowOthers)
	{ 
		this(wxGridCellChoiceEditor_ctor(choices.length, choices.ptr, allowOthers), true);
		wxGridCellChoiceEditor_RegisterDisposable(wxobj, &VirtualDispose);
	}

        public this(IntPtr wxobj)
	{ 
		super(wxobj);
	}
	
	private this(IntPtr wxobj, bool memOwn)
	{ 
		super(wxobj);
		this.memOwn = memOwn;
	}
	
	//---------------------------------------------------------------------
				
	override protected void dtor() { wxGridCellChoiceEditor_dtor(wxobj); }

        public override void Create(Window parent, int id, EvtHandler evtHandler)
        {
            wxGridCellChoiceEditor_Create(wxobj, wxObject.SafePtr(parent), id, wxObject.SafePtr(evtHandler));
        }

        public override void PaintBackground(Rectangle rectCell, GridCellAttr attr)
        {
            wxGridCellChoiceEditor_PaintBackground(wxobj, rectCell, wxObject.SafePtr(attr));
        }

        public override void BeginEdit(int row, int col, Grid grid)
        {
            wxGridCellChoiceEditor_BeginEdit(wxobj, row, col, wxObject.SafePtr(grid));
        }
        
        public override bool EndEdit(int row, int col, Grid grid)
        {
            return wxGridCellChoiceEditor_EndEdit(wxobj, row, col, wxObject.SafePtr(grid));
        }
        
        public override void Reset()
        {
            wxGridCellChoiceEditor_Reset(wxobj);
        }

        public override void SetParameters(string parameter)
        {
            wxGridCellChoiceEditor_SetParameters(wxobj, parameter);
        }

        public override GridCellEditor Clone()
        {
//            return cast(GridCellEditor)FindObject(wxGridCellChoiceEditor_Clone(wxobj), &GridCellEditor.New);
              return new GridCellChoiceEditor(wxGridCellChoiceEditor_Clone(wxobj));
        }       

        public override string GetValue()
        {
            return cast(string) new wxString(wxGridCellChoiceEditor_GetValue(wxobj), true);
        }
    }
    
    //-----------------------------------------------------------------------------

		//! \cond EXTERN
        static extern (C) IntPtr wxGridRangeSelectEvent_ctor(int id, int type, IntPtr obj, IntPtr topLeft, IntPtr bottomRight, bool sel, bool control, bool shift, bool alt, bool meta);
        static extern (C) IntPtr wxGridRangeSelectEvent_GetTopLeftCoords(IntPtr self);
        static extern (C) IntPtr wxGridRangeSelectEvent_GetBottomRightCoords(IntPtr self);
        static extern (C) int wxGridRangeSelectEvent_GetTopRow(IntPtr self);
        static extern (C) int wxGridRangeSelectEvent_GetBottomRow(IntPtr self);
        static extern (C) int wxGridRangeSelectEvent_GetLeftCol(IntPtr self);
        static extern (C) int wxGridRangeSelectEvent_GetRightCol(IntPtr self);
        static extern (C) bool wxGridRangeSelectEvent_Selecting(IntPtr self);
        static extern (C) bool wxGridRangeSelectEvent_ControlDown(IntPtr self);
        static extern (C) bool wxGridRangeSelectEvent_MetaDown(IntPtr self);
        static extern (C) bool wxGridRangeSelectEvent_ShiftDown(IntPtr self);
        static extern (C) bool wxGridRangeSelectEvent_AltDown(IntPtr self);
        static extern (C) void wxGridRangeSelectEvent_Veto(IntPtr self);
        static extern (C) void wxGridRangeSelectEvent_Allow(IntPtr self);
        static extern (C) bool wxGridRangeSelectEvent_IsAllowed(IntPtr self);       
		//! \endcond
    
        //-----------------------------------------------------------------------------
    
    alias GridRangeSelectEvent wxGridRangeSelectEvent;
    public class GridRangeSelectEvent : Event
    {
        public this(IntPtr wxobj)
            { super(wxobj); }
    
        public this(int id, int type, wxObject obj, GridCellCoords topLeft, GridCellCoords bottomRight, bool sel, bool control, bool shift, bool alt, bool meta)
            { super(wxGridRangeSelectEvent_ctor(id, type, wxObject.SafePtr(obj), wxObject.SafePtr(topLeft), wxObject.SafePtr(bottomRight), sel, control, shift, alt, meta)); }
    
            //-----------------------------------------------------------------------------
    
        public GridCellCoords TopLeftCoords() { return new GridCellCoords(wxGridRangeSelectEvent_GetTopLeftCoords(wxobj)); }
    
        public GridCellCoords BottomRightCoords() { return new GridCellCoords(wxGridRangeSelectEvent_GetBottomRightCoords(wxobj)); }
    
        //-----------------------------------------------------------------------------
    
        public int TopRow() { return wxGridRangeSelectEvent_GetTopRow(wxobj); }
    
        public int BottomRow() { return wxGridRangeSelectEvent_GetBottomRow(wxobj); }
    
        //-----------------------------------------------------------------------------
    
        public int LeftCol() { return wxGridRangeSelectEvent_GetLeftCol(wxobj); }
    
        public int RightCol() { return wxGridRangeSelectEvent_GetRightCol(wxobj); }
    
        //-----------------------------------------------------------------------------
    
        public bool Selecting() { return wxGridRangeSelectEvent_Selecting(wxobj); }
    
        //-----------------------------------------------------------------------------
    
        public bool ControlDown() { return wxGridRangeSelectEvent_ControlDown(wxobj); }
    
        public bool MetaDown() { return wxGridRangeSelectEvent_MetaDown(wxobj); }
    
        public bool ShiftDown() { return wxGridRangeSelectEvent_ShiftDown(wxobj); }
    
        public bool AltDown() { return wxGridRangeSelectEvent_AltDown(wxobj); }
        
        //-----------------------------------------------------------------------------     
        
        public void Veto()
        {
            wxGridRangeSelectEvent_Veto(wxobj);
        }
        
        //-----------------------------------------------------------------------------
        
        public void Allow()
        {
            wxGridRangeSelectEvent_Allow(wxobj);
        }
        
        //-----------------------------------------------------------------------------
        
        public bool Allowed() { return wxGridRangeSelectEvent_IsAllowed(wxobj); }

	private static Event New(IntPtr obj) { return new GridRangeSelectEvent(obj); }

	static this()
	{
			wxEVT_GRID_RANGE_SELECT = wxEvent_EVT_GRID_RANGE_SELECT();

			AddEventType(wxEVT_GRID_RANGE_SELECT,               &GridRangeSelectEvent.New);
	}
    }

		//! \cond EXTERN
	extern (C) {
        alias void function(GridCellWorker obj, string param) Virtual_SetParameters;
	}

        static extern (C) IntPtr wxGridCellWorker_ctor();
        static extern (C) void wxGridCellWorker_RegisterVirtual(IntPtr self, GridCellWorker obj, Virtual_SetParameters setParameters);
        static extern (C) void wxGridCellWorker_IncRef(IntPtr self);
        static extern (C) void wxGridCellWorker_DecRef(IntPtr self);
        static extern (C) void wxGridCellWorker_SetParameters(IntPtr self, string parms);
		//! \endcond
	
        //-----------------------------------------------------------------------------
        
    alias GridCellWorker wxGridCellWorker;
    public class GridCellWorker : wxObject //ClientData
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
        	this(wxGridCellWorker_ctor(), true);
            wxGridCellWorker_RegisterVirtual(wxobj, this, &staticDoSetParameters);
        }
	
	//---------------------------------------------------------------------
				
	override protected void dtor() {}
        
        //-----------------------------------------------------------------------------
        
        public void IncRef()
        {
            wxGridCellWorker_IncRef(wxobj);
        }
        
        public void DecRef()
        {
            wxGridCellWorker_DecRef(wxobj);
        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private void staticDoSetParameters(GridCellWorker obj, string param)
        {
            obj.SetParameters(param);
        }
        
        public /+virtual+/ void SetParameters(string param)
        {
            wxGridCellWorker_SetParameters(wxobj, param);
        }
    }
    
    //-----------------------------------------------------------------------------

            //! \cond EXTERN
            static extern (C) IntPtr wxGridEditorCreatedEvent_ctor(int id, int type, IntPtr obj, int row, int col, IntPtr ctrl);
            static extern (C) int    wxGridEditorCreatedEvent_GetRow(IntPtr self);
            static extern (C) int    wxGridEditorCreatedEvent_GetCol(IntPtr self);
            static extern (C) IntPtr wxGridEditorCreatedEvent_GetControl(IntPtr self);
            static extern (C) void   wxGridEditorCreatedEvent_SetRow(IntPtr self, int row);
            static extern (C) void   wxGridEditorCreatedEvent_SetCol(IntPtr self, int col);
            static extern (C) void   wxGridEditorCreatedEvent_SetControl(IntPtr self, IntPtr ctrl);
            //! \endcond

            //-----------------------------------------------------------------------------
    
    alias GridEditorCreatedEvent wxGridEditorCreatedEvent;
    public class GridEditorCreatedEvent : CommandEvent 
    {
            public this(IntPtr wxobj)
            { super(wxobj); }
    
            public this(int id, int type, wxObject obj, int row, int col, Control ctrl)
            { this(wxGridEditorCreatedEvent_ctor(id, type, wxObject.SafePtr(obj), row, col, wxObject.SafePtr(ctrl))); }
    
            //-----------------------------------------------------------------------------
    
            public int Row() { return wxGridEditorCreatedEvent_GetRow(wxobj); }
            public void Row(int value) { wxGridEditorCreatedEvent_SetRow(wxobj, value); }
    
            //-----------------------------------------------------------------------------
    
            public int Col() { return wxGridEditorCreatedEvent_GetCol(wxobj); }
            public void Col(int value) { wxGridEditorCreatedEvent_SetCol(wxobj, value); }
    
            //-----------------------------------------------------------------------------
    
            public Control control() { return cast(Control)FindObject(wxGridEditorCreatedEvent_GetControl(wxobj), &Control.New); }
            public void control(Control value) { wxGridEditorCreatedEvent_SetControl(wxobj, wxObject.SafePtr(value)); }

		private static Event New(IntPtr obj) { return new GridEditorCreatedEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_GRID_EDITOR_CREATED,             &GridEditorCreatedEvent.New);        
		}
    }
    
    //-----------------------------------------------------------------------------

            //! \cond EXTERN
            static extern (C) IntPtr wxGrid_ctor();
            static extern (C) IntPtr wxGrid_ctorFull(IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
            static extern (C) bool   wxGrid_CreateGrid(IntPtr self, int numRows, int numCols,  int selmode);
            static extern (C) void   wxGrid_SetSelectionMode(IntPtr self, int selmode);
            static extern (C) int    wxGrid_GetNumberRows(IntPtr self);
            static extern (C) int    wxGrid_GetNumberCols(IntPtr self);
            static extern (C) IntPtr wxGrid_GetTable(IntPtr self);
            static extern (C) bool   wxGrid_SetTable(IntPtr self, IntPtr table, bool takeOwnership, int select);
            static extern (C) void   wxGrid_ClearGrid(IntPtr self);
            static extern (C) bool   wxGrid_InsertRows(IntPtr self, int pos, int numRows, bool updateLabels);
            static extern (C) bool   wxGrid_AppendRows(IntPtr self, int numRows, bool updateLabels);
            static extern (C) bool   wxGrid_DeleteRows(IntPtr self, int pos, int numRows, bool updateLabels);
            static extern (C) bool   wxGrid_InsertCols(IntPtr self, int pos, int numCols, bool updateLabels);
            static extern (C) bool   wxGrid_AppendCols(IntPtr self, int numCols, bool updateLabels);
            static extern (C) bool   wxGrid_DeleteCols(IntPtr self, int pos, int numCols, bool updateLabels);
            static extern (C) void   wxGrid_BeginBatch(IntPtr self);
            static extern (C) void   wxGrid_EndBatch(IntPtr self);
            static extern (C) int    wxGrid_GetBatchCount(IntPtr self);
            static extern (C) void   wxGrid_ForceRefresh(IntPtr self);
            static extern (C) bool   wxGrid_IsEditable(IntPtr self);
            static extern (C) void   wxGrid_EnableEditing(IntPtr self, bool edit);
            static extern (C) void   wxGrid_EnableCellEditControl(IntPtr self, bool enable);
            static extern (C) void   wxGrid_DisableCellEditControl(IntPtr self);
            static extern (C) bool   wxGrid_CanEnableCellControl(IntPtr self);
            static extern (C) bool   wxGrid_IsCellEditControlEnabled(IntPtr self);
            static extern (C) bool   wxGrid_IsCellEditControlShown(IntPtr self);
            static extern (C) bool   wxGrid_IsCurrentCellReadOnly(IntPtr self);
            static extern (C) void   wxGrid_ShowCellEditControl(IntPtr self);
            static extern (C) void   wxGrid_HideCellEditControl(IntPtr self);
            static extern (C) void   wxGrid_SaveEditControlValue(IntPtr self);
            static extern (C) int    wxGrid_YToRow(IntPtr self, int y);
            static extern (C) int    wxGrid_XToCol(IntPtr self, int x);
            static extern (C) int    wxGrid_YToEdgeOfRow(IntPtr self, int y);
            static extern (C) int    wxGrid_XToEdgeOfCol(IntPtr self, int x);
            static extern (C) void   wxGrid_CellToRect(IntPtr self, int row, int col, ref Rectangle rect);
            static extern (C) int    wxGrid_GetGridCursorRow(IntPtr self);
            static extern (C) int    wxGrid_GetGridCursorCol(IntPtr self);
            static extern (C) bool   wxGrid_IsVisible(IntPtr self, int row, int col, bool wholeCellVisible);
            static extern (C) void   wxGrid_MakeCellVisible(IntPtr self, int row, int col);
            static extern (C) void   wxGrid_SetGridCursor(IntPtr self, int row, int col);
            static extern (C) bool   wxGrid_MoveCursorUp(IntPtr self, bool expandSelection);
            static extern (C) bool   wxGrid_MoveCursorDown(IntPtr self, bool expandSelection);
            static extern (C) bool   wxGrid_MoveCursorLeft(IntPtr self, bool expandSelection);
            static extern (C) bool   wxGrid_MoveCursorRight(IntPtr self, bool expandSelection);
            static extern (C) bool   wxGrid_MovePageDown(IntPtr self);
            static extern (C) bool   wxGrid_MovePageUp(IntPtr self);
            static extern (C) bool   wxGrid_MoveCursorUpBlock(IntPtr self, bool expandSelection);
            static extern (C) bool   wxGrid_MoveCursorDownBlock(IntPtr self, bool expandSelection);
            static extern (C) bool   wxGrid_MoveCursorLeftBlock(IntPtr self, bool expandSelection);
            static extern (C) bool   wxGrid_MoveCursorRightBlock(IntPtr self, bool expandSelection);
            static extern (C) int    wxGrid_GetDefaultRowLabelSize(IntPtr self);
            static extern (C) int    wxGrid_GetRowLabelSize(IntPtr self);
            static extern (C) int    wxGrid_GetDefaultColLabelSize(IntPtr self);
            static extern (C) int    wxGrid_GetColLabelSize(IntPtr self);
            static extern (C) IntPtr wxGrid_GetLabelBackgroundColour(IntPtr self);
            static extern (C) IntPtr wxGrid_GetLabelTextColour(IntPtr self);
            static extern (C) IntPtr wxGrid_GetLabelFont(IntPtr self);
            static extern (C) void   wxGrid_GetRowLabelAlignment(IntPtr self, out int horiz, out int vert);
            static extern (C) void   wxGrid_GetColLabelAlignment(IntPtr self, out int horiz, out int vert);
            static extern (C) IntPtr wxGrid_GetRowLabelValue(IntPtr self, int row);
            static extern (C) IntPtr wxGrid_GetColLabelValue(IntPtr self, int col);
            static extern (C) IntPtr wxGrid_GetGridLineColour(IntPtr self);
            static extern (C) IntPtr wxGrid_GetCellHighlightColour(IntPtr self);
            static extern (C) int    wxGrid_GetCellHighlightPenWidth(IntPtr self);
            static extern (C) int    wxGrid_GetCellHighlightROPenWidth(IntPtr self);
            static extern (C) void   wxGrid_SetRowLabelSize(IntPtr self, int width);
            static extern (C) void   wxGrid_SetColLabelSize(IntPtr self, int height);
            static extern (C) void   wxGrid_SetLabelBackgroundColour(IntPtr self, IntPtr col);
            static extern (C) void   wxGrid_SetLabelTextColour(IntPtr self, IntPtr col);
            static extern (C) void   wxGrid_SetLabelFont(IntPtr self, IntPtr fnt);
            static extern (C) void   wxGrid_SetRowLabelAlignment(IntPtr self, int horiz, int vert);
            static extern (C) void   wxGrid_SetColLabelAlignment(IntPtr self, int horiz, int vert);
            static extern (C) void   wxGrid_SetRowLabelValue(IntPtr self, int row, string val);
            static extern (C) void   wxGrid_SetColLabelValue(IntPtr self, int col, string val);
            static extern (C) void   wxGrid_SetGridLineColour(IntPtr self, IntPtr col);
            static extern (C) void   wxGrid_SetCellHighlightColour(IntPtr self, IntPtr col);
            static extern (C) void   wxGrid_SetCellHighlightPenWidth(IntPtr self, int width);
            static extern (C) void   wxGrid_SetCellHighlightROPenWidth(IntPtr self, int width);
            static extern (C) void   wxGrid_EnableDragRowSize(IntPtr self, bool enable);
            static extern (C) void   wxGrid_DisableDragRowSize(IntPtr self);
            static extern (C) bool   wxGrid_CanDragRowSize(IntPtr self);
            static extern (C) void   wxGrid_EnableDragColSize(IntPtr self, bool enable);
            static extern (C) void   wxGrid_DisableDragColSize(IntPtr self);
            static extern (C) bool   wxGrid_CanDragColSize(IntPtr self);
            static extern (C) void   wxGrid_EnableDragGridSize(IntPtr self, bool enable);
            static extern (C) void   wxGrid_DisableDragGridSize(IntPtr self);
            static extern (C) bool   wxGrid_CanDragGridSize(IntPtr self);
            static extern (C) void   wxGrid_SetAttr(IntPtr self, int row, int col, IntPtr attr);
            static extern (C) void   wxGrid_SetRowAttr(IntPtr self, int row, IntPtr attr);
            static extern (C) void   wxGrid_SetColAttr(IntPtr self, int col, IntPtr attr);
            static extern (C) void   wxGrid_SetColFormatBool(IntPtr self, int col);
            static extern (C) void   wxGrid_SetColFormatNumber(IntPtr self, int col);
            static extern (C) void   wxGrid_SetColFormatFloat(IntPtr self, int col, int width, int precision);
            static extern (C) void   wxGrid_SetColFormatCustom(IntPtr self, int col, string typeName);
            static extern (C) void   wxGrid_EnableGridLines(IntPtr self, bool enable);
            static extern (C) bool   wxGrid_GridLinesEnabled(IntPtr self);
            static extern (C) int    wxGrid_GetDefaultRowSize(IntPtr self);
            static extern (C) int    wxGrid_GetRowSize(IntPtr self, int row);
            static extern (C) int    wxGrid_GetDefaultColSize(IntPtr self);
            static extern (C) int    wxGrid_GetColSize(IntPtr self, int col);
            static extern (C) IntPtr wxGrid_GetDefaultCellBackgroundColour(IntPtr self);
            static extern (C) IntPtr wxGrid_GetCellBackgroundColour(IntPtr self, int row, int col);
            static extern (C) IntPtr wxGrid_GetDefaultCellTextColour(IntPtr self);
            static extern (C) IntPtr wxGrid_GetCellTextColour(IntPtr self, int row, int col);
            static extern (C) IntPtr wxGrid_GetDefaultCellFont(IntPtr self);
            static extern (C) IntPtr wxGrid_GetCellFont(IntPtr self, int row, int col);
            static extern (C) void   wxGrid_GetDefaultCellAlignment(IntPtr self, ref int horiz, ref int vert);
            static extern (C) void   wxGrid_GetCellAlignment(IntPtr self, int row, int col, ref int horiz, ref int vert);
            static extern (C) bool   wxGrid_GetDefaultCellOverflow(IntPtr self);
            static extern (C) bool   wxGrid_GetCellOverflow(IntPtr self, int row, int col);
            static extern (C) void   wxGrid_GetCellSize(IntPtr self, int row, int col, ref int num_rows, ref int num_cols);
            static extern (C) void   wxGrid_SetDefaultRowSize(IntPtr self, int height, bool resizeExistingRows);
            static extern (C) void   wxGrid_SetRowSize(IntPtr self, int row, int height);
            static extern (C) void   wxGrid_SetDefaultColSize(IntPtr self, int width, bool resizeExistingCols);
            static extern (C) void   wxGrid_SetColSize(IntPtr self, int col, int width);
            static extern (C) void   wxGrid_AutoSizeColumn(IntPtr self, int col, bool setAsMin);
            static extern (C) void   wxGrid_AutoSizeRow(IntPtr self, int row, bool setAsMin);
            static extern (C) void   wxGrid_AutoSizeColumns(IntPtr self, bool setAsMin);
            static extern (C) void   wxGrid_AutoSizeRows(IntPtr self, bool setAsMin);
            static extern (C) void   wxGrid_AutoSize(IntPtr self);
            static extern (C) void   wxGrid_SetColMinimalWidth(IntPtr self, int col, int width);
            static extern (C) void   wxGrid_SetRowMinimalHeight(IntPtr self, int row, int width);
            static extern (C) void   wxGrid_SetColMinimalAcceptableWidth(IntPtr self, int width);
            static extern (C) void   wxGrid_SetRowMinimalAcceptableHeight(IntPtr self, int width);
            static extern (C) int    wxGrid_GetColMinimalAcceptableWidth(IntPtr self);
            static extern (C) int    wxGrid_GetRowMinimalAcceptableHeight(IntPtr self);
            static extern (C) void   wxGrid_SetDefaultCellBackgroundColour(IntPtr self, IntPtr wxColour);
            static extern (C) void   wxGrid_SetDefaultCellTextColour(IntPtr self, IntPtr wxColour);
            static extern (C) void   wxGrid_SetDefaultCellFont(IntPtr self, IntPtr wxFont);
            static extern (C) void   wxGrid_SetCellFont(IntPtr self, int row, int col, IntPtr wxFont );
            static extern (C) void   wxGrid_SetDefaultCellAlignment(IntPtr self, int horiz, int vert);
            static extern (C) void   wxGrid_SetCellAlignmentHV(IntPtr self, int row, int col, int horiz, int vert);
            static extern (C) void   wxGrid_SetDefaultCellOverflow(IntPtr self, bool allow);
            static extern (C) void   wxGrid_SetCellOverflow(IntPtr self, int row, int col, bool allow);
            static extern (C) void   wxGrid_SetCellSize(IntPtr self, int row, int col, int num_rows, int num_cols);
            static extern (C) void   wxGrid_SetDefaultRenderer(IntPtr self, IntPtr renderer);
            static extern (C) void   wxGrid_SetCellRenderer(IntPtr self, int row, int col, IntPtr renderer);
            static extern (C) IntPtr wxGrid_GetDefaultRenderer(IntPtr self);
            static extern (C) IntPtr wxGrid_GetCellRenderer(IntPtr self, int row, int col);
            static extern (C) void   wxGrid_SetDefaultEditor(IntPtr self, IntPtr editor);
            static extern (C) void   wxGrid_SetCellEditor(IntPtr self, int row, int col, IntPtr editor);
            static extern (C) IntPtr wxGrid_GetDefaultEditor(IntPtr self);
            static extern (C) IntPtr wxGrid_GetCellEditor(IntPtr self, int row, int col);
            static extern (C) IntPtr wxGrid_GetCellValue(IntPtr self, int row, int col);
            static extern (C) void   wxGrid_SetCellValue(IntPtr self, int row, int col, string s);
            static extern (C) bool   wxGrid_IsReadOnly(IntPtr self, int row, int col);
            static extern (C) void   wxGrid_SetReadOnly(IntPtr self, int row, int col, bool isReadOnly);
            static extern (C) void   wxGrid_SelectRow(IntPtr self, int row, bool addToSelected);
            static extern (C) void   wxGrid_SelectCol(IntPtr self, int col, bool addToSelected);
            static extern (C) void   wxGrid_SelectBlock(IntPtr self, int topRow, int leftCol, int bottomRow, int rightCol, bool addToSelected);
            static extern (C) void   wxGrid_SelectAll(IntPtr self);
            static extern (C) bool   wxGrid_IsSelection(IntPtr self);
            static extern (C) void   wxGrid_DeselectRow(IntPtr self, int row);
            static extern (C) void   wxGrid_DeselectCol(IntPtr self, int col);
            static extern (C) void   wxGrid_DeselectCell(IntPtr self, int row, int col);
            static extern (C) void   wxGrid_ClearSelection(IntPtr self);
            static extern (C) bool   wxGrid_IsInSelection(IntPtr self, int row, int col);
            //static extern (C) IntPtr wxGrid_GetSelectedCells(IntPtr self);
            //static extern (C) IntPtr wxGrid_GetSelectionBlockTopLeft(IntPtr self);
            //static extern (C) IntPtr wxGrid_GetSelectionBlockBottomRight(IntPtr self);
            //static extern (C) IntPtr wxGrid_GetSelectedRows(IntPtr self);
            //static extern (C) IntPtr wxGrid_GetSelectedCols(IntPtr self);
            static extern (C) void   wxGrid_BlockToDeviceRect(IntPtr self, IntPtr topLeft, IntPtr bottomRight, ref Rectangle rect);
            static extern (C) IntPtr wxGrid_GetSelectionBackground(IntPtr self);
            static extern (C) IntPtr wxGrid_GetSelectionForeground(IntPtr self);
            static extern (C) void   wxGrid_SetSelectionBackground(IntPtr self, IntPtr c);
            static extern (C) void   wxGrid_SetSelectionForeground(IntPtr self, IntPtr c);
            static extern (C) void   wxGrid_RegisterDataType(IntPtr self, string typeName, IntPtr renderer, IntPtr editor);
            static extern (C) IntPtr wxGrid_GetDefaultEditorForCell(IntPtr self, int row, int col);
            static extern (C) IntPtr wxGrid_GetDefaultRendererForCell(IntPtr self, int row, int col);
            static extern (C) IntPtr wxGrid_GetDefaultEditorForType(IntPtr self, string typeName);
            static extern (C) IntPtr wxGrid_GetDefaultRendererForType(IntPtr self, string typeName);
            static extern (C) void   wxGrid_SetMargins(IntPtr self, int extraWidth, int extraHeight);
            static extern (C) IntPtr wxGrid_GetGridWindow(IntPtr self);
            static extern (C) IntPtr wxGrid_GetGridRowLabelWindow(IntPtr self);
            static extern (C) IntPtr wxGrid_GetGridColLabelWindow(IntPtr self);
            static extern (C) IntPtr wxGrid_GetGridCornerLabelWindow(IntPtr self);
            static extern (C) void   wxGrid_UpdateDimensions(IntPtr self);
            static extern (C) int    wxGrid_GetRows(IntPtr self);
            static extern (C) int    wxGrid_GetCols(IntPtr self);
            static extern (C) int    wxGrid_GetCursorRow(IntPtr self);
            static extern (C) int    wxGrid_GetCursorColumn(IntPtr self);
            static extern (C) int    wxGrid_GetScrollPosX(IntPtr self);
            static extern (C) int    wxGrid_GetScrollPosY(IntPtr self);
            static extern (C) void   wxGrid_SetScrollX(IntPtr self, int x);
            static extern (C) void   wxGrid_SetScrollY(IntPtr self, int y);
            static extern (C) void   wxGrid_SetColumnWidth(IntPtr self, int col, int width);
            static extern (C) int    wxGrid_GetColumnWidth(IntPtr self, int col);
            static extern (C) void   wxGrid_SetRowHeight(IntPtr self, int row, int height);
            static extern (C) int    wxGrid_GetViewHeight(IntPtr self);
            static extern (C) int    wxGrid_GetViewWidth(IntPtr self);
            static extern (C) void   wxGrid_SetLabelSize(IntPtr self, int orientation, int sz);
            static extern (C) int    wxGrid_GetLabelSize(IntPtr self, int orientation);
            static extern (C) void   wxGrid_SetLabelAlignment(IntPtr self, int orientation, int alignment);
            static extern (C) int    wxGrid_GetLabelAlignment(IntPtr self, int orientation, int alignment);
            static extern (C) void   wxGrid_SetLabelValue(IntPtr self, int orientation, string val, int pos);
            static extern (C) IntPtr wxGrid_GetLabelValue(IntPtr self, int orientation, int pos);
            static extern (C) IntPtr wxGrid_GetCellTextFontGrid(IntPtr self);
            static extern (C) IntPtr wxGrid_GetCellTextFont(IntPtr self, int row, int col);
            static extern (C) void   wxGrid_SetCellTextFontGrid(IntPtr self, IntPtr fnt);
            static extern (C) void   wxGrid_SetCellTextFont(IntPtr self, IntPtr fnt, int row, int col);
            static extern (C) void   wxGrid_SetCellTextColour(IntPtr self, int row, int col, IntPtr val);
            static extern (C) void   wxGrid_SetCellTextColourGrid(IntPtr self, IntPtr col);
            static extern (C) void   wxGrid_SetCellBackgroundColourGrid(IntPtr self, IntPtr col);
            static extern (C) void   wxGrid_SetCellBackgroundColour(IntPtr self, int row, int col, IntPtr colour);
            static extern (C) bool   wxGrid_GetEditable(IntPtr self);
            static extern (C) void   wxGrid_SetEditable(IntPtr self, bool edit);
            static extern (C) bool   wxGrid_GetEditInPlace(IntPtr self);
            static extern (C) void   wxGrid_SetCellAlignment(IntPtr self, int alignment, int row, int col);
            static extern (C) void   wxGrid_SetCellAlignmentGrid(IntPtr self, int alignment);
            static extern (C) void   wxGrid_SetCellBitmap(IntPtr self, IntPtr bitmap, int row, int col);
            static extern (C) void   wxGrid_SetDividerPen(IntPtr self, IntPtr pen);
            static extern (C) IntPtr wxGrid_GetDividerPen(IntPtr self);
            static extern (C) int    wxGrid_GetRowHeight(IntPtr self, int row);
            //! \endcond

        //-----------------------------------------------------------------------------

    alias Grid wxGrid;
    public class Grid : ScrolledWindow
    {
        public this(IntPtr wxobj)
            { super(wxobj); }

        public this()
            { this(wxGrid_ctor()); }

        public this(Window parent, int id)
            { this(parent, id, wxDefaultPosition, wxDefaultSize, wxWANTS_CHARS, "grid"); }
	    
        public this(Window parent, int id, Point pos)
            { this(parent, id, pos, wxDefaultSize, wxWANTS_CHARS, "grid"); }
	    
        public this(Window parent, int id, Point pos, Size size)
            { this(parent, id, pos, size, wxWANTS_CHARS, "grid"); }
	    
        public this(Window parent, int id, Point pos, Size size, int style)
            { this(parent, id, pos, size, style, "grid"); }

        public this(Window parent, int id, Point pos, Size size, int style, string name)
            { this(wxGrid_ctorFull(wxObject.SafePtr(parent), id, pos, size, cast(uint)style, name)); }

        //public  this(Window parent, int x, int y, int w, int h, int style, string name)
        //    { super(wxGrid_ctor(wxObject.SafePtr(parent), x, y, w, h, style, name)); }
	
	//---------------------------------------------------------------------
	// ctors with self created id
	
	public this(Window parent)
            { this(parent, Window.UniqueID, wxDefaultPosition, wxDefaultSize, wxWANTS_CHARS, "grid"); }
	    
        public this(Window parent, Point pos)
            { this(parent, Window.UniqueID, pos, wxDefaultSize, wxWANTS_CHARS, "grid"); }
	    
        public this(Window parent, Point pos, Size size)
            { this(parent, Window.UniqueID, pos, size, wxWANTS_CHARS, "grid"); }
	    
        public this(Window parent, Point pos, Size size, int style)
            { this(parent, Window.UniqueID, pos, size, style, "grid"); }

        public this(Window parent, Point pos, Size size, int style, string name)
		{ this(parent, Window.UniqueID, pos, size, style, name);}

        //-----------------------------------------------------------------------------

        public bool CreateGrid(int numRows, int numCols)
        { return CreateGrid(numRows, numCols, GridSelectionMode.wxGridSelectCells); }

            public bool CreateGrid(int numRows, int numCols, GridSelectionMode selmode)
            {
            return wxGrid_CreateGrid(wxobj, numRows, numCols, cast(int)selmode);
            }

        //-----------------------------------------------------------------------------

            public void SelectionMode(GridSelectionMode value) { wxGrid_SetSelectionMode(wxobj, cast(int)value); }
            //get { return wxGrid_GetSelectionMode(wxobj); }
    
            //-----------------------------------------------------------------------------

            public int NumberRows() { return wxGrid_GetNumberRows(wxobj); }
    
            public int NumberCols() { return wxGrid_GetNumberCols(wxobj); }

        //-----------------------------------------------------------------------------

       //     public GridTableBase Table() { return cast(GridTableBase)FindObject(wxGrid_GetTable(wxobj), &GridTableBase.New); }
        
        public bool SetTable(GridTableBase table)
        {
            return SetTable(table, false, GridSelectionMode.wxGridSelectCells ); 
        }
        
        public bool SetTable(GridTableBase table, bool takeOwnerShip)
        {
            return SetTable(table, takeOwnerShip, GridSelectionMode.wxGridSelectCells);
        }
    
            public bool SetTable(GridTableBase table, bool takeOwnership, GridSelectionMode select)
            {
            return wxGrid_SetTable(wxobj, wxObject.SafePtr(table), takeOwnership, cast(int)select);
            }
    
            //-----------------------------------------------------------------------------
    
            public void ClearGrid()
            {
            wxGrid_ClearGrid(wxobj);
            }

            //-----------------------------------------------------------------------------
        
        public bool InsertRows()
        {
            return InsertRows(0, 1, true);
        }
        
        public bool InsertRows(int pos)
        {
            return InsertRows(pos, 1, true);
        }
        
        public bool InsertRows(int pos, int numRows)
        {
            return InsertRows(pos, numRows, true);
        }   
    
            public bool InsertRows(int pos, int numRows, bool updateLabels)
            {
            return wxGrid_InsertRows(wxobj, pos, numRows, updateLabels);
        }
        
        public bool AppendRows()
        {
            return AppendRows(1, true);
        }
        
        public bool AppendRows(int numRows)
        {
            return AppendRows(numRows, true);
        }
    
            public bool AppendRows(int numRows, bool updateLabels)
            {
            return wxGrid_AppendRows(wxobj, numRows, updateLabels);
            }
        
        public bool DeleteRows()
        {
            return DeleteRows(0, 1, true);
        }
        
        public bool DeleteRows(int pos)
        {
            return DeleteRows(pos, 1, true);
        }
        
        public bool DeleteRows(int pos, int numRows)
        {
            return DeleteRows(pos, numRows, true);
        }
    
            public bool DeleteRows(int pos, int numRows, bool updateLabels)
            {
            return wxGrid_DeleteRows(wxobj, pos, numRows, updateLabels);
            }

        //-----------------------------------------------------------------------------
    
        public bool InsertCols()
        {
            return InsertCols(0, 1, true);
        }
        
        public bool InsertCols(int pos)
        {
            return InsertCols(pos, 1, true);
        }
        
        public bool InsertCols(int pos, int numRows)
        {
            return InsertCols(pos, numRows, true);
        }   
    
            public bool InsertCols(int pos, int numCols, bool updateLabels)
            {
            return wxGrid_InsertCols(wxobj, pos, numCols, updateLabels);
            }
        
        public bool AppendCols()
        {
            return AppendCols(1, true);
        }
        
        public bool AppendCols(int numCols)
        {
            return AppendCols(numCols, true);
        }
    
            public bool AppendCols(int numCols, bool updateLabels)
            {
            return wxGrid_AppendCols(wxobj, numCols, updateLabels);
            }
        
        public bool DeleteCols()
        {
            return DeleteCols(0, 1, true);
        }
        
        public bool DeleteCols(int pos)
        {
            return DeleteCols(pos, 1, true);
        }
        
        public bool DeleteCols(int pos, int numRows)
        {
            return DeleteCols(pos, numRows, true);
        }
    
            public bool DeleteCols(int pos, int numCols, bool updateLabels)
            {
            return wxGrid_DeleteCols(wxobj, pos, numCols, updateLabels);
            }

            //-----------------------------------------------------------------------------
    
            public void BeginBatch()
            {
            wxGrid_BeginBatch(wxobj);
            }
    
            public void EndBatch()
            {
            wxGrid_EndBatch(wxobj);
            }
    
            public int BatchCount() { return wxGrid_GetBatchCount(wxobj); }
    
            //-----------------------------------------------------------------------------
    
            public void ForceRefresh()
            {
            wxGrid_ForceRefresh(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            public bool IsEditable() { return wxGrid_IsEditable(wxobj); }
            public void IsEditable(bool value) { wxGrid_EnableEditing(wxobj, value); }
    
            //-----------------------------------------------------------------------------
    
            public void CellEditControlEnabled(bool value) { wxGrid_EnableCellEditControl(wxobj, value); }
            public bool CellEditControlEnabled() { return wxGrid_IsCellEditControlEnabled(wxobj); }
    
            public void DisableCellEditControl()
            {
            wxGrid_DisableCellEditControl(wxobj);
            }
    
            public bool CanEnableCellControl() { return wxGrid_CanEnableCellControl(wxobj); }
    
            //-----------------------------------------------------------------------------
    
            public bool IsCellEditControlShown() { return wxGrid_IsCellEditControlShown(wxobj); }
    
            public bool IsCurrentCellReadOnly() { return wxGrid_IsCurrentCellReadOnly(wxobj); }

            //-----------------------------------------------------------------------------
    
            public void ShowCellEditControl()
            {
            wxGrid_ShowCellEditControl(wxobj);
            }
    
            public void HideCellEditControl()
            {
            wxGrid_HideCellEditControl(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SaveEditControlValue()
            {
            wxGrid_SaveEditControlValue(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            /*public void XYToCell(int x, int y,  GridCellCoords )
            {
                    wxGrid_XYToCell(wxobj, x, y, wxObject.SafePtr(GridCellCoords ));
            }*/
    
            //-----------------------------------------------------------------------------
    
            public int YToRow(int y)
            {
            return wxGrid_YToRow(wxobj, y);
            }
    
            public int XToCol(int x)
            {
            return wxGrid_XToCol(wxobj, x);
            }
    
            public int YToEdgeOfRow(int y)
            {
            return wxGrid_YToEdgeOfRow(wxobj, y);
            }
    
            public int XToEdgeOfCol(int x)
            {
            return wxGrid_XToEdgeOfCol(wxobj, x);
            }
    
            //-----------------------------------------------------------------------------
    
            public Rectangle CellToRect(int row, int col)
            {
            Rectangle rect;
            wxGrid_CellToRect(wxobj, row, col, rect);
            return rect;
            }
    
            //-----------------------------------------------------------------------------
    
            public int GridCursorRow() { return wxGrid_GetGridCursorRow(wxobj); }
    
            public int GridCursorCol() { return wxGrid_GetGridCursorCol(wxobj); }
    
            //-----------------------------------------------------------------------------
    
            public bool IsVisible(int row, int col, bool wholeCellVisible)
            {
            return wxGrid_IsVisible(wxobj, row, col, wholeCellVisible);
            }
    
            //-----------------------------------------------------------------------------
    
            public void MakeCellVisible(int row, int col)
            {
            wxGrid_MakeCellVisible(wxobj, row, col);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SetGridCursor(int row, int col)
            {
            wxGrid_SetGridCursor(wxobj, row, col);
            }
    
            //-----------------------------------------------------------------------------
    
            public bool MoveCursorUp(bool expandSelection)
            {
            return wxGrid_MoveCursorUp(wxobj, expandSelection);
            }
    
            public bool MoveCursorDown(bool expandSelection)
            {
            return wxGrid_MoveCursorDown(wxobj, expandSelection);
            }
    
            public bool MoveCursorLeft(bool expandSelection)
            {
            return wxGrid_MoveCursorLeft(wxobj, expandSelection);
            }
    
            public bool MoveCursorRight(bool expandSelection)
            {
            return wxGrid_MoveCursorRight(wxobj, expandSelection);
            }
    
            public bool MovePageDown()
            {
            return wxGrid_MovePageDown(wxobj);
            }
    
            public bool MovePageUp()
            {
            return wxGrid_MovePageUp(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            public bool MoveCursorUpBlock(bool expandSelection)
            {
            return wxGrid_MoveCursorUpBlock(wxobj, expandSelection);
            }
    
            public bool MoveCursorDownBlock(bool expandSelection)
            {
            return wxGrid_MoveCursorDownBlock(wxobj, expandSelection);
            }
    
            public bool MoveCursorLeftBlock(bool expandSelection)
            {
            return wxGrid_MoveCursorLeftBlock(wxobj, expandSelection);
            }
    
            public bool MoveCursorRightBlock(bool expandSelection)
            {
            return wxGrid_MoveCursorRightBlock(wxobj, expandSelection);
            }
    
            //-----------------------------------------------------------------------------
    
            public int DefaultRowLabelSize() { return wxGrid_GetDefaultRowLabelSize(wxobj); }
    
            public int RowLabelSize() { return wxGrid_GetRowLabelSize(wxobj); }
            public void RowLabelSize(int value) { wxGrid_SetRowLabelSize(wxobj, value); }
    
            //-----------------------------------------------------------------------------
    
            public int DefaultColLabelSize() { return wxGrid_GetDefaultColLabelSize(wxobj); }
    
            public int ColLabelSize() { return wxGrid_GetColLabelSize(wxobj); }
            public void ColLabelSize(int value) { wxGrid_SetColLabelSize(wxobj, value); }
    
            //-----------------------------------------------------------------------------
    
            public Colour LabelBackgroundColour() { return new Colour(wxGrid_GetLabelBackgroundColour(wxobj), true); }
            public void LabelBackgroundColour(Colour value) { wxGrid_SetLabelBackgroundColour(wxobj, wxObject.SafePtr(value)); }
    
            public Colour LabelTextColour() { return new Colour(wxGrid_GetLabelTextColour(wxobj), true); }
            public void LabelTextColour(Colour value) { wxGrid_SetLabelTextColour(wxobj, wxObject.SafePtr(value)); }
    
            //-----------------------------------------------------------------------------
    
            public Font LabelFont() { return new Font(wxGrid_GetLabelFont(wxobj)); }
            public void LabelFont(Font value) { wxGrid_SetLabelFont(wxobj, wxObject.SafePtr(value)); }
    
            //-----------------------------------------------------------------------------
    
            public void GetRowLabelAlignment(out int horiz, out int vert)
            {
            wxGrid_GetRowLabelAlignment(wxobj, horiz, vert);
            }
    
            public void GetColLabelAlignment(out int horiz, out int vert)
            {
            wxGrid_GetColLabelAlignment(wxobj, horiz, vert);
            }
    
            //-----------------------------------------------------------------------------
    
            public string GetRowLabelValue(int row)
            {
            return cast(string) new wxString(wxGrid_GetRowLabelValue(wxobj, row), true);
            }
    
            public string GetColLabelValue(int col)
            {
            return cast(string) new wxString(wxGrid_GetColLabelValue(wxobj, col), true);
            }
    
            //-----------------------------------------------------------------------------
    
            public Colour GridLineColour() { return new Colour(wxGrid_GetGridLineColour(wxobj), true); }
            public void GridLineColour(Colour value) { wxGrid_SetGridLineColour(wxobj, wxObject.SafePtr(value)); }
    
            //-----------------------------------------------------------------------------
    
            public Colour CellHighlightColour() { return new Colour(wxGrid_GetCellHighlightColour(wxobj), true); }
            public void CellHighlightColour(Colour value) { wxGrid_SetCellHighlightColour(wxobj, wxObject.SafePtr(value)); }
    
            //-----------------------------------------------------------------------------
    
            public int CellHighlightPenWidth() { return wxGrid_GetCellHighlightPenWidth(wxobj); }
            public void CellHighlightPenWidth(int value) { wxGrid_SetCellHighlightPenWidth(wxobj, value); }
    
            //-----------------------------------------------------------------------------
    
            public int CellHighlightROPenWidth() { return wxGrid_GetCellHighlightROPenWidth(wxobj); }
            public void CellHighlightROPenWidth(int value) { wxGrid_SetCellHighlightROPenWidth(wxobj, value); }
    
            //-----------------------------------------------------------------------------
    
            public void SetRowLabelAlignment(int horiz, int vert)
            {
            wxGrid_SetRowLabelAlignment(wxobj, horiz, vert);
            }
    
            public void SetColLabelAlignment(int horiz, int vert)
            {
            wxGrid_SetColLabelAlignment(wxobj, horiz, vert);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SetRowLabelValue(int row, string str)
            {
            wxGrid_SetRowLabelValue(wxobj, row, str);
            }
    
            public void SetColLabelValue(int col, string str)
            {
            wxGrid_SetColLabelValue(wxobj, col, str);
            }
    
            //-----------------------------------------------------------------------------
    
            public void DragRowSizeEnabled(bool value) { wxGrid_EnableDragRowSize(wxobj, value); }
            public bool DragRowSizeEnabled() { return wxGrid_CanDragRowSize(wxobj); }
    
            public void DisableDragRowSize()
            {
            wxGrid_DisableDragRowSize(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            public void DragColSizeEnabled(bool value) { wxGrid_EnableDragColSize(wxobj, value); }
            public bool DragColSizeEnabled() { return wxGrid_CanDragColSize(wxobj); }
    
            public void DisableDragColSize()
            {
            wxGrid_DisableDragColSize(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            public void DragGridSizeEnabled(bool value) { wxGrid_EnableDragGridSize(wxobj, value); }
            public bool DragGridSizeEnabled() { return wxGrid_CanDragGridSize(wxobj); }
    
            public void DisableDragGridSize()
            {
            wxGrid_DisableDragGridSize(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SetAttr(int row, int col, GridCellAttr attr)
            {
            wxGrid_SetAttr(wxobj, row, col, wxObject.SafePtr(attr));
            }
    
            public void SetRowAttr(int row, GridCellAttr attr)
            {
            wxGrid_SetRowAttr(wxobj, row, wxObject.SafePtr(attr));
            }
    
            public void SetColAttr(int col, GridCellAttr attr)
            {
            wxGrid_SetColAttr(wxobj, col, wxObject.SafePtr(attr));
            }
    
            //-----------------------------------------------------------------------------
    
            public void ColFormatBool(int value) { wxGrid_SetColFormatBool(wxobj, value); }
    
            public void ColFormatNumber(int value) { wxGrid_SetColFormatNumber(wxobj, value); }
        
        public void SetColFormatFloat(int col)
        {
            SetColFormatFloat(col, -1, -1);
        }
        
        public void SetColFormatFloat(int col, int width)
        {
            SetColFormatFloat(col, width, -1);
        }
    
            public void SetColFormatFloat(int col, int width, int precision)
            {
            wxGrid_SetColFormatFloat(wxobj, col, width, precision);
            }
    
            public void SetColFormatCustom(int col, string typeName)
            {
            wxGrid_SetColFormatCustom(wxobj, col, typeName);
            }
    
            //-----------------------------------------------------------------------------
    
            public void GridLinesEnabled(bool value) { wxGrid_EnableGridLines(wxobj, value); } 
            public bool GridLinesEnabled() { return wxGrid_GridLinesEnabled(wxobj); }
    
            //-----------------------------------------------------------------------------
    
            public int DefaultRowSize() { return wxGrid_GetDefaultRowSize(wxobj); }
    
            public int GetRowSize(int row)
            {
            return wxGrid_GetRowSize(wxobj, row);
            }
    
            public int DefaultColSize() { return wxGrid_GetDefaultColSize(wxobj); }
    
            public int GetColSize(int col)
            {
            return wxGrid_GetColSize(wxobj, col);
            }
    
            //-----------------------------------------------------------------------------
    
            public Colour DefaultCellBackgroundColour() { return new Colour(wxGrid_GetDefaultCellBackgroundColour(wxobj), true); }
            public void DefaultCellBackgroundColour(Colour value) { wxGrid_SetDefaultCellBackgroundColour(wxobj, wxObject.SafePtr(value)); }
    
            public Colour DefaultCellTextColour() { return new Colour(wxGrid_GetDefaultCellTextColour(wxobj), true); }
            public void DefaultCellTextColour(Colour value) { wxGrid_SetDefaultCellTextColour(wxobj, wxObject.SafePtr(value)); }
    
            //-----------------------------------------------------------------------------
    
            public Font DefaultCellFont() { return new Font(wxGrid_GetDefaultCellFont(wxobj)); }
            public void DefaultCellFont(Font value) { wxGrid_SetDefaultCellFont(wxobj, wxObject.SafePtr(value)); }
    
            public Font GetCellFont(int row, int col)
            {
            return new Font(wxGrid_GetCellFont(wxobj, row, col));
            }
    
            //-----------------------------------------------------------------------------
    
            public void GetDefaultCellAlignment(ref int horiz, ref int vert)
            {
            wxGrid_GetDefaultCellAlignment(wxobj, horiz, vert);
            }
    
            //-----------------------------------------------------------------------------
    
            public void GetCellAlignment(int row, int col, ref int horiz, ref int vert)
            {
            wxGrid_GetCellAlignment(wxobj, row, col, horiz, vert);
            }
    
            //-----------------------------------------------------------------------------
    
            public bool DefaultCellOverflow() { return wxGrid_GetDefaultCellOverflow(wxobj); }
            public void DefaultCellOverflow(bool value) { wxGrid_SetDefaultCellOverflow(wxobj, value); }
    
            public bool GetCellOverflow(int row, int col)
            {
            return wxGrid_GetCellOverflow(wxobj, row, col);
            }
    
            //-----------------------------------------------------------------------------
    
            public void GetCellSize(int row, int col, ref int num_rows, ref int num_cols)
            {
            wxGrid_GetCellSize(wxobj, row, col, num_rows, num_cols);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SetDefaultRowSize(int height, bool resizeExistingRows)
            {
            wxGrid_SetDefaultRowSize(wxobj, height, resizeExistingRows);
            }
    
            public void SetRowSize(int row, int height)
            {
            wxGrid_SetRowSize(wxobj, row, height);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SetDefaultColSize(int width, bool resizeExistingCols)
            {
            wxGrid_SetDefaultColSize(wxobj, width, resizeExistingCols);
            }
    
            public void SetColSize(int col, int width)
            {
            wxGrid_SetColSize(wxobj, col, width);
            }
    
            //-----------------------------------------------------------------------------
    
            public void AutoSizeColumn(int col, bool setAsMin)
            {
            wxGrid_AutoSizeColumn(wxobj, col, setAsMin);
            }
    
            public void AutoSizeRow(int row, bool setAsMin)
            {
            wxGrid_AutoSizeRow(wxobj, row, setAsMin);
            }
    
            //-----------------------------------------------------------------------------
        
        public void AutoSizeColumns()
        {
            AutoSizeColumns(true);
        }
    
            public void AutoSizeColumns(bool setAsMin)
            {
            wxGrid_AutoSizeColumns(wxobj, setAsMin);
            }
        
        public void AutoSizeRows()
        {
            AutoSizeRows(true);
        }
    
            public void AutoSizeRows(bool setAsMin)
            {
            wxGrid_AutoSizeRows(wxobj, setAsMin);
            }
    
            //-----------------------------------------------------------------------------
    
            public void AutoSize()
            {
            wxGrid_AutoSize(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SetColMinimalWidth(int col, int width)
            {
            wxGrid_SetColMinimalWidth(wxobj, col, width);
            }
    
            public void SetRowMinimalHeight(int row, int width)
            {
            wxGrid_SetRowMinimalHeight(wxobj, row, width);
            }
    
            //-----------------------------------------------------------------------------
    
            public void ColMinimalAcceptableWidth(int value) { wxGrid_SetColMinimalAcceptableWidth(wxobj, value); }
            public int ColMinimalAcceptableWidth() { return wxGrid_GetColMinimalAcceptableWidth(wxobj); }
    
            public void RowMinimalAcceptableHeight(int value) { wxGrid_SetRowMinimalAcceptableHeight(wxobj, value); }
            public int RowMinimalAcceptableHeight() { return wxGrid_GetRowMinimalAcceptableHeight(wxobj); }
    
            //-----------------------------------------------------------------------------
    
            public void SetCellFont(int row, int col, Font fnt)
            {
            wxGrid_SetCellFont(wxobj, row, col, wxObject.SafePtr(fnt));
            }
    
            //-----------------------------------------------------------------------------
    
            public void SetDefaultCellAlignment(int horiz, int vert)
            {
            wxGrid_SetDefaultCellAlignment(wxobj, horiz, vert);
            }
    
            public void SetCellAlignment(int row, int col, int horiz, int vert)
            {
            wxGrid_SetCellAlignmentHV(wxobj, row, col, horiz, vert);
            }
    
            public void SetCellOverflow(int row, int col, bool allow)
            {
            wxGrid_SetCellOverflow(wxobj, row, col, allow);
            }
    
            public void SetCellSize(int row, int col, int num_rows, int num_cols)
            {
            wxGrid_SetCellSize(wxobj, row, col, num_rows, num_cols);
            }
    
            //-----------------------------------------------------------------------------
    
            public void DefaultRenderer(GridCellRenderer value) { wxGrid_SetDefaultRenderer(wxobj, wxObject.SafePtr(value)); }
            //get { return wxGrid_GetDefaultRenderer(wxobj); }
    
            //-----------------------------------------------------------------------------
    
            public void SetCellRenderer(int row, int col, GridCellRenderer renderer)
            {
            wxGrid_SetCellRenderer(wxobj, row, col, wxObject.SafePtr(renderer));
            }
    
            //-----------------------------------------------------------------------------
    /+
            public GridCellRenderer GetCellRenderer(int row, int col)
            {
                    return cast(GridCellRenderer)FindObject(wxGrid_GetCellRenderer(wxobj, row, col), &GridCellRenderer.New);
            }
    +/
            //-----------------------------------------------------------------------------
    
            public void DefaultEditor(GridCellEditor value) { wxGrid_SetDefaultEditor(wxobj, wxObject.SafePtr(value)); }/+
            public GridCellEditor DefaultEditor() { return cast(GridCellEditor)FindObject(wxGrid_GetDefaultEditor(wxobj), &GridCellEditor.New); }
    +/
            //-----------------------------------------------------------------------------
    
            public void SetCellEditor(int row, int col, GridCellEditor editor)
            {
                wxGrid_SetCellEditor(wxobj, row, col, wxObject.SafePtr(editor));
            }
    
            //-----------------------------------------------------------------------------
    /+
            public GridCellEditor GetCellEditor(int row, int col)
            {
                return cast(GridCellEditor)FindObject(wxGrid_GetCellEditor(wxobj, row, col), &GridCellEditor.New);
            }
    +/
            //-----------------------------------------------------------------------------
    
            public string GetCellValue(int row, int col)
            {
                return cast(string) new wxString(wxGrid_GetCellValue(wxobj, row, col), true);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SetCellValue(int row, int col, string s)
            {
                wxGrid_SetCellValue(wxobj, row, col, s);
            }
    
            //-----------------------------------------------------------------------------
    
            public bool IsReadOnly(int row, int col)
            {
                return wxGrid_IsReadOnly(wxobj, row, col);
            }
        
        public void SetReadOnly(int row, int col)
        {
            SetReadOnly(row, col, true);
        }
    
            public void SetReadOnly(int row, int col, bool isReadOnly)
            {
            wxGrid_SetReadOnly(wxobj, row, col, isReadOnly);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SelectRow(int row, bool addToSelected)
            {
            wxGrid_SelectRow(wxobj, row, addToSelected);
            }
    
            public void SelectCol(int col, bool addToSelected)
            {
            wxGrid_SelectCol(wxobj, col, addToSelected);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SelectBlock(int topRow, int leftCol, int bottomRow, int rightCol, bool addToSelected)
            {
            wxGrid_SelectBlock(wxobj, topRow, leftCol, bottomRow, rightCol, addToSelected);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SelectAll()
            {
            wxGrid_SelectAll(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            public bool IsSelection() { return wxGrid_IsSelection(wxobj); }
    
            //-----------------------------------------------------------------------------
    
            public void DeselectRow(int row)
            {
            wxGrid_DeselectRow(wxobj, row);
            }
    
            public void DeselectCol(int col)
            {
            wxGrid_DeselectCol(wxobj, col);
            }
    
            public void DeselectCell(int row, int col)
            {
            wxGrid_DeselectCell(wxobj, row, col);
            }
    
            //-----------------------------------------------------------------------------
    
            public void ClearSelection()
            {
            wxGrid_ClearSelection(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            public bool IsInSelection(int row, int col)
            {
            return wxGrid_IsInSelection(wxobj, row, col);
            }
    
            //-----------------------------------------------------------------------------

//! \cond VERSION
version(NOT_IMPLEMENTED){
            public GridCellCoordsArray GetSelectedCells()
        {
            return wxGrid_GetSelectedCells(wxobj);
            }

            //-----------------------------------------------------------------------------
    
            public GridCellCoordsArray GetSelectionBlockTopLeft()
            {
            return wxGrid_GetSelectionBlockTopLeft(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            public GridCellCoordsArray GetSelectionBlockBottomRight()
            {
            return wxGrid_GetSelectionBlockBottomRight(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            public ArrayInt GetSelectedRows()
            {
            return wxGrid_GetSelectedRows(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            public ArrayInt GetSelectedCols()
            {
            return wxGrid_GetSelectedCols(wxobj);
            }
} // version(NOT_IMPLEMENTED)
//! \endcond
            //-----------------------------------------------------------------------------
    
            public Rectangle BlockToDeviceRect(GridCellCoords topLeft, GridCellCoords bottomRight)
            {
            Rectangle rect;
            wxGrid_BlockToDeviceRect(wxobj, wxObject.SafePtr(topLeft), wxObject.SafePtr(bottomRight), rect);
            return rect;
            }
    
            //-----------------------------------------------------------------------------
    
            public Colour SelectionBackground() { return new Colour(wxGrid_GetSelectionBackground(wxobj), true); }
            public void SelectionBackground(Colour value) { wxGrid_SetSelectionBackground(wxobj, wxObject.SafePtr(value)); }
    
            //-----------------------------------------------------------------------------
    
            public Colour SelectionForeground() { return new Colour(wxGrid_GetSelectionForeground(wxobj), true); }
            public void SelectionForeground(Colour value) { wxGrid_SetSelectionForeground(wxobj, wxObject.SafePtr(value)); }
    
            //-----------------------------------------------------------------------------
    
            public void RegisterDataType(string typeName, GridCellRenderer renderer, GridCellEditor editor)
            {
            wxGrid_RegisterDataType(wxobj, typeName, wxObject.SafePtr(renderer), wxObject.SafePtr(editor));
            }
    
            //-----------------------------------------------------------------------------
    /+
            public GridCellEditor GetDefaultEditorForCell(int row, int col)
            {
            return cast(GridCellEditor)FindObject(wxGrid_GetDefaultEditorForCell(wxobj, row, col), &GridCellEditor.New);
            }
    +/
            //-----------------------------------------------------------------------------
    /+
            public GridCellRenderer GetDefaultRendererForCell(int row, int col)
            {
                    return cast(GridCellRenderer)FindObject(wxGrid_GetDefaultRendererForCell(wxobj, row, col), &GridCellRenderer.New);
            }
    +/
            //-----------------------------------------------------------------------------
    /+
            public GridCellEditor GetDefaultEditorForType(string typeName)
            {
            return cast(GridCellEditor)FindObject(wxGrid_GetDefaultEditorForType(wxobj, typeName), &GridCellEditor.New);
            }
    +/
            //-----------------------------------------------------------------------------
    /+
            public GridCellRenderer GetDefaultRendererForType(string typeName)
            {
                    return cast(GridCellRenderer)FindObject(wxGrid_GetDefaultRendererForType(wxobj, typeName), &GridCellRenderer.New);
            }
    +/
            //-----------------------------------------------------------------------------
    
            public void SetMargins(int extraWidth, int extraHeight)
            {
            wxGrid_SetMargins(wxobj, extraWidth, extraHeight);
            }
    
            //-----------------------------------------------------------------------------
    
            public Window GridWindow() { return cast(Window)FindObject(wxGrid_GetGridWindow(wxobj)); }
    
            public Window GridRowLabelWindow() { return cast(Window)FindObject(wxGrid_GetGridRowLabelWindow(wxobj)); }
    
            public Window GridColLabelWindow() { return cast(Window)FindObject(wxGrid_GetGridColLabelWindow(wxobj)); }
    
            public Window GridCornerLabelWindow() { return cast(Window)FindObject(wxGrid_GetGridCornerLabelWindow(wxobj)); }
    
            //-----------------------------------------------------------------------------
    
            public void UpdateDimensions()
            {
            wxGrid_UpdateDimensions(wxobj);
            }
    
            //-----------------------------------------------------------------------------
    
            public int Rows() { return wxGrid_GetRows(wxobj); }
    
            public int Cols() { return wxGrid_GetCols(wxobj); }
    
            //-----------------------------------------------------------------------------
    
            public int CursorRow() { return wxGrid_GetCursorRow(wxobj); }
    
            public int CursorColumn() { return wxGrid_GetCursorColumn(wxobj); }
    
            //-----------------------------------------------------------------------------
    
            public int ScrollPosX() { return wxGrid_GetScrollPosX(wxobj); }
            public void ScrollPosX(int value) { wxGrid_SetScrollX(wxobj, value); }
    
            public int ScrollPosY() { return wxGrid_GetScrollPosY(wxobj); }
            public void ScrollPosY(int value) { wxGrid_SetScrollY(wxobj, value); }
    
            //-----------------------------------------------------------------------------
    
            public void SetColumnWidth(int col, int width)
            {
            wxGrid_SetColumnWidth(wxobj, col, width);
            }
    
            public int GetColumnWidth(int col)
            {
            return wxGrid_GetColumnWidth(wxobj, col);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SetRowHeight(int row, int height)
            {
            wxGrid_SetRowHeight(wxobj, row, height);
            }
    
            //-----------------------------------------------------------------------------
    
            public int ViewHeight() { return wxGrid_GetViewHeight(wxobj); }
    
            public int ViewWidth() { return wxGrid_GetViewWidth(wxobj); }
    
            //-----------------------------------------------------------------------------
    
            public void SetLabelSize(int orientation, int sz)
            {
            wxGrid_SetLabelSize(wxobj, orientation, sz);
            }
    
            public int GetLabelSize(int orientation)
            {
            return wxGrid_GetLabelSize(wxobj, orientation);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SetLabelAlignment(int orientation, int alignment)
            {
            wxGrid_SetLabelAlignment(wxobj, orientation, alignment);
            }
    
            public int GetLabelAlignment(int orientation, int alignment)
            {
            return wxGrid_GetLabelAlignment(wxobj, orientation, alignment);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SetLabelValue(int orientation, string val, int pos)
            {
            wxGrid_SetLabelValue(wxobj, orientation, val, pos);
            }
    
            public string GetLabelValue(int orientation, int pos)
            {
            return cast(string) new wxString(wxGrid_GetLabelValue(wxobj, orientation, pos), true);
            }
    
            //-----------------------------------------------------------------------------
    
            public Font CellTextFont() { return new Font(wxGrid_GetCellTextFontGrid(wxobj)); }
            public void CellTextFont(Font value) { wxGrid_SetCellTextFontGrid(wxobj, wxObject.SafePtr(value)); }
    
            //-----------------------------------------------------------------------------
    
            public Font GetCellTextFont(int row, int col)
            {
            return new Font(wxGrid_GetCellTextFont(wxobj, row, col));
            }
    
            public void SetCellTextFont(Font fnt, int row, int col)
            {
            wxGrid_SetCellTextFont(wxobj, wxObject.SafePtr(fnt), row, col);
            }
    
            //-----------------------------------------------------------------------------
    
            public void SetCellTextColour(int row, int col, Colour val)
            {
            wxGrid_SetCellTextColour(wxobj, row, col, wxObject.SafePtr(val));
            }
    
            //-----------------------------------------------------------------------------
    
            public void CellTextColour(Colour value) { wxGrid_SetCellTextColourGrid(wxobj, wxObject.SafePtr(value)); }
    
            //-----------------------------------------------------------------------------
                
            public Colour GetCellTextColour(int row, int col)
            {
            return new Colour(wxGrid_GetCellTextColour(wxobj, row, col), true); 
            }
    
            //-----------------------------------------------------------------------------
    
            public void CellBackgroundColour(Colour value) { wxGrid_SetCellBackgroundColourGrid(wxobj, wxObject.SafePtr(value)); }
    
            //-----------------------------------------------------------------------------
    
            public void SetCellBackgroundColour(int row, int col, Colour colour)
            {
            wxGrid_SetCellBackgroundColour(wxobj, row, col, wxObject.SafePtr(colour));
            }
    
            public Colour GetCellBackgroundColour(int row, int col)
            {
            return new Colour(wxGrid_GetCellBackgroundColour(wxobj, row, col), true); 
            }
    
            //-----------------------------------------------------------------------------
    
            public bool Editable() { return wxGrid_GetEditable(wxobj); }
            public void Editable(bool value) { wxGrid_SetEditable(wxobj, value); }
    
            //-----------------------------------------------------------------------------
    
            public bool EditInPlace() { return wxGrid_GetEditInPlace(wxobj); }
    
            //-----------------------------------------------------------------------------
    
            public void SetCellAlignment(int alignment, int row, int col)
            {
            wxGrid_SetCellAlignment(wxobj, alignment, row, col);
            }
    
            public void CellAlignment(int value) { wxGrid_SetCellAlignmentGrid(wxobj, value); }
    
            //-----------------------------------------------------------------------------
    
            public void SetCellBitmap(Bitmap bitmap, int row, int col)
            {
            wxGrid_SetCellBitmap(wxobj, wxObject.SafePtr(bitmap), row, col);
            }
    
            //-----------------------------------------------------------------------------
    
            public void DividerPen(Pen value) { wxGrid_SetDividerPen(wxobj, wxObject.SafePtr(value)); }
            public Pen DividerPen() { return new Pen(wxGrid_GetDividerPen(wxobj)); }
    
            //-----------------------------------------------------------------------------
    
            public int GetRowHeight(int row)
            {
            return wxGrid_GetRowHeight(wxobj, row);
            }

        //-----------------------------------------------------------------------------

		public void CellLeftClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_CELL_LEFT_CLICK, ID, value, this); }
		public void CellLeftClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void CellRightClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_CELL_RIGHT_CLICK, ID, value, this); }
		public void CellRightClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void CellLeftDoubleClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_CELL_LEFT_DCLICK, ID, value, this); }
		public void CellLeftDoubleClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void CellRightDoubleClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_CELL_RIGHT_DCLICK, ID, value, this); }
		public void CellRightDoubleClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void LabelLeftClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_LABEL_LEFT_CLICK, ID, value, this); }
		public void LabelLeftClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void LabelRightClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_LABEL_RIGHT_CLICK, ID, value, this); }
		public void LabelRightClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void LabelLeftDoubleClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_LABEL_LEFT_DCLICK, ID, value, this); }
		public void LabelLeftDoubleClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void LabelRightDoubleClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_LABEL_RIGHT_DCLICK, ID, value, this); }
		public void LabelRightDoubleClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void RowSize_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_ROW_SIZE, ID, value, this); }
		public void RowSize_Remove(EventListener value) { RemoveHandler(value, this); }

		public void ColumnSize_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_COL_SIZE, ID, value, this); }
		public void ColumnSize_Remove(EventListener value) { RemoveHandler(value, this); }

		public void RangeSelect_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_RANGE_SELECT, ID, value, this); }
		public void RangeSelect_Remove(EventListener value) { RemoveHandler(value, this); }

		public void CellChange_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_CELL_CHANGE, ID, value, this); }
		public void CellChange_Remove(EventListener value) { RemoveHandler(value, this); }

		public void SelectCell_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_SELECT_CELL, ID, value, this); }
		public void SelectCell_Remove(EventListener value) { RemoveHandler(value, this); }

		public void EditorShown_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_EDITOR_SHOWN, ID, value, this); }
		public void EditorShown_Remove(EventListener value) { RemoveHandler(value, this); }

		public void EditorHidden_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_EDITOR_HIDDEN, ID, value, this); }
		public void EditorHidden_Remove(EventListener value) { RemoveHandler(value, this); }

		public void EditorCreate_Add(EventListener value) { AddCommandListener(Event.wxEVT_GRID_EDITOR_CREATED, ID, value, this); }
		public void EditorCreate_Remove(EventListener value) { RemoveHandler(value, this); }

    }

        //! \cond EXTERN
        static extern (C) IntPtr wxGridCellCoords_ctor();
	static extern (C) void   wxGridCellCoords_dtor(IntPtr self);
        static extern (C) int    wxGridCellCoords_GetRow(IntPtr self);
        static extern (C) void   wxGridCellCoords_SetRow(IntPtr self, int n);
        static extern (C) int    wxGridCellCoords_GetCol(IntPtr self);
        static extern (C) void   wxGridCellCoords_SetCol(IntPtr self, int n);
        static extern (C) void   wxGridCellCoords_Set(IntPtr self, int row, int col);
        //! \endcond
	
        //-----------------------------------------------------------------------------
    
    alias GridCellCoords wxGridCellCoords;
    public class GridCellCoords : wxObject
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
            { this(wxGridCellCoords_ctor(), true); }
    
        public this(int r, int c)
        {
        	this();
            Set(r, c);
        }
	
	//---------------------------------------------------------------------
				
	override protected void dtor() { wxGridCellCoords_dtor(wxobj); }
    
        //-----------------------------------------------------------------------------
    
        public void Row(int value) { wxGridCellCoords_SetRow(wxobj, value); }
        public int Row() { return wxGridCellCoords_GetRow(wxobj); }
    
        //-----------------------------------------------------------------------------
    
        public void Col(int value) { wxGridCellCoords_SetCol(wxobj, value); }
        public int Col() { return wxGridCellCoords_GetCol(wxobj); }
    
        //-----------------------------------------------------------------------------
    
        public void Set(int row, int col)
        {
            wxGridCellCoords_Set(wxobj, row, col);
        }
    }

        //! \cond EXTERN
        static extern (C) IntPtr wxGridCellAttr_ctor(IntPtr colText, IntPtr colBack, IntPtr font, int hAlign, int vAlign);
        static extern (C) IntPtr wxGridCellAttr_ctor2();
        static extern (C) IntPtr wxGridCellAttr_ctor3(IntPtr attrDefault);
        static extern (C) IntPtr wxGridCellAttr_Clone(IntPtr self);
        static extern (C) void   wxGridCellAttr_MergeWith(IntPtr self, IntPtr mergefrom);
        static extern (C) void   wxGridCellAttr_IncRef(IntPtr self);
        static extern (C) void   wxGridCellAttr_DecRef(IntPtr self);
        static extern (C) void   wxGridCellAttr_SetTextColour(IntPtr self, IntPtr colText);
        static extern (C) void   wxGridCellAttr_SetBackgroundColour(IntPtr self, IntPtr colBack);
        static extern (C) void   wxGridCellAttr_SetFont(IntPtr self, IntPtr font);
        static extern (C) void   wxGridCellAttr_SetAlignment(IntPtr self, int hAlign, int vAlign);
        static extern (C) void   wxGridCellAttr_SetSize(IntPtr self, int num_rows, int num_cols);
        static extern (C) void   wxGridCellAttr_SetOverflow(IntPtr self, bool allow);
        static extern (C) void   wxGridCellAttr_SetReadOnly(IntPtr self, bool isReadOnly);
        static extern (C) void   wxGridCellAttr_SetRenderer(IntPtr self, IntPtr renderer);
        static extern (C) void   wxGridCellAttr_SetEditor(IntPtr self, IntPtr editor);
        static extern (C) bool   wxGridCellAttr_HasTextColour(IntPtr self);
        static extern (C) bool   wxGridCellAttr_HasBackgroundColour(IntPtr self);
        static extern (C) bool   wxGridCellAttr_HasFont(IntPtr self);
        static extern (C) bool   wxGridCellAttr_HasAlignment(IntPtr self);
        static extern (C) bool   wxGridCellAttr_HasRenderer(IntPtr self);
        static extern (C) bool   wxGridCellAttr_HasEditor(IntPtr self);
        static extern (C) bool   wxGridCellAttr_HasReadWriteMode(IntPtr self);
        static extern (C) IntPtr wxGridCellAttr_GetTextColour(IntPtr self);
        static extern (C) IntPtr wxGridCellAttr_GetBackgroundColour(IntPtr self);
        static extern (C) IntPtr wxGridCellAttr_GetFont(IntPtr self);
        static extern (C) void   wxGridCellAttr_GetAlignment(IntPtr self, ref int hAlign, ref int vAlign);
        static extern (C) void   wxGridCellAttr_GetSize(IntPtr self, ref int num_rows, ref int num_cols);
        static extern (C) bool   wxGridCellAttr_GetOverflow(IntPtr self);
        static extern (C) IntPtr wxGridCellAttr_GetRenderer(IntPtr self, IntPtr grid, int row, int col);
        static extern (C) IntPtr wxGridCellAttr_GetEditor(IntPtr self, IntPtr grid, int row, int col);
        static extern (C) bool   wxGridCellAttr_IsReadOnly(IntPtr self);
        static extern (C) void   wxGridCellAttr_SetDefAttr(IntPtr self, IntPtr defAttr);
        //! \endcond
	
        //-----------------------------------------------------------------------------
    
    alias GridCellAttr wxGridCellAttr;
    public class GridCellAttr : wxObject
    {
        public enum AttrKind
        {
            Any, Default, Cell, Row, Col, Merged
        }
    
        //-----------------------------------------------------------------------------
    
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
            { this(wxGridCellAttr_ctor2(), true); }
            
        public this(GridCellAttr attrDefault)
            { this(wxGridCellAttr_ctor3(wxObject.SafePtr(attrDefault)), true); }
    
        public this(Colour colText, Colour colBack, Font font, int hAlign, int vAlign)
            { this(wxGridCellAttr_ctor(wxObject.SafePtr(colText), wxObject.SafePtr(colBack), wxObject.SafePtr(font), hAlign, vAlign), true); }
	    
	public static wxObject New(IntPtr ptr) { return new GridCellAttr(ptr); }
	//---------------------------------------------------------------------
				
	override protected void dtor() {}
    
        //-----------------------------------------------------------------------------
    
        public GridCellAttr Clone()
        {
            return new GridCellAttr(wxGridCellAttr_Clone(wxobj));
        }
    
        //-----------------------------------------------------------------------------
    
        public void MergeWith(GridCellAttr mergefrom)
        {
            wxGridCellAttr_MergeWith(wxobj, wxObject.SafePtr(mergefrom));
        }
    
        //-----------------------------------------------------------------------------
    
        public void IncRef()
        {
            wxGridCellAttr_IncRef(wxobj);
        }
    
        //-----------------------------------------------------------------------------
    
        public void DecRef()
        {
            wxGridCellAttr_DecRef(wxobj);
        }
    
        //-----------------------------------------------------------------------------
    
        public void TextColour(Colour value) { wxGridCellAttr_SetTextColour(wxobj, wxObject.SafePtr(value)); }
        public Colour TextColour() { return new Colour(wxGridCellAttr_GetTextColour(wxobj), true); }
    
        //-----------------------------------------------------------------------------
        
        public void BackgroundColour(Colour value) { wxGridCellAttr_SetBackgroundColour(wxobj, wxObject.SafePtr(value)); }
        public Colour BackgroundColour() { return new Colour(wxGridCellAttr_GetBackgroundColour(wxobj), true); }
        
        //-----------------------------------------------------------------------------
        
        public void font(Font value) { wxGridCellAttr_SetFont(wxobj, wxObject.SafePtr(value)); }
        public Font font() { return new Font(wxGridCellAttr_GetFont(wxobj)); }
        
        //-----------------------------------------------------------------------------
        
        public void SetAlignment(int hAlign, int vAlign)
        {
            wxGridCellAttr_SetAlignment(wxobj, hAlign, vAlign);
        }
        
        public void GetAlignment(ref int hAlign, ref int vAlign)
        {
            wxGridCellAttr_GetAlignment(wxobj, hAlign, vAlign);
        }
        
        public void SetSize(int num_rows, int num_cols)
        {
            wxGridCellAttr_SetSize(wxobj, num_rows, num_cols);
        }
        
        public void GetSize(ref int num_rows, ref int num_cols)
        {
            wxGridCellAttr_GetSize(wxobj, num_rows, num_cols);
        }
        
        //-----------------------------------------------------------------------------
        
        public void Overflow(bool value) { wxGridCellAttr_SetOverflow(wxobj, value); }
        public bool Overflow() { return wxGridCellAttr_GetOverflow(wxobj); }
        
        //-----------------------------------------------------------------------------
        
        public void ReadOnly(bool value) { wxGridCellAttr_SetReadOnly(wxobj, value); }
        public bool ReadOnly() { return wxGridCellAttr_IsReadOnly(wxobj); }
        
        //-----------------------------------------------------------------------------
        
        public void SetRenderer(GridCellRenderer renderer)
        {
            wxGridCellAttr_SetRenderer(wxobj, wxObject.SafePtr(renderer));
        }
        
        //-----------------------------------------------------------------------------
        
        public void Editor(GridCellEditor value) { wxGridCellAttr_SetEditor(wxobj, wxObject.SafePtr(value)); }
        /+
        public GridCellEditor GetEditor(Grid grid, int row, int col)
        {
            return cast(GridCellEditor)FindObject(wxGridCellAttr_GetEditor(wxobj, wxObject.SafePtr(grid), row, col), &GridCellEditor.New);
        }
        +/
        //-----------------------------------------------------------------------------
        
        public bool HasTextColour() { return wxGridCellAttr_HasTextColour(wxobj); }
        
        public bool HasBackgroundColour() { return wxGridCellAttr_HasBackgroundColour(wxobj); }
        
        public bool HasFont() { return wxGridCellAttr_HasFont(wxobj); }
        
        public bool HasAlignment() { return wxGridCellAttr_HasAlignment(wxobj); }
        
        public bool HasRenderer() { return wxGridCellAttr_HasRenderer(wxobj); }
        
        public bool HasEditor() { return wxGridCellAttr_HasEditor(wxobj); }
        
        public bool HasReadWriteMode() { return wxGridCellAttr_HasReadWriteMode(wxobj); }
        
        //-----------------------------------------------------------------------------
        /+
        public GridCellRenderer GetRenderer(Grid grid, int row, int col)
        {
            return cast(GridCellRenderer)FindObject(wxGridCellAttr_GetRenderer(wxobj, wxObject.SafePtr(grid), row, col), &GridCellRenderer.New);
        }
        +/
        //-----------------------------------------------------------------------------
        
        public void DefAttr(GridCellAttr value) { wxGridCellAttr_SetDefAttr(wxobj, wxObject.SafePtr(value)); }
    }

        //! \cond EXTERN
        static extern (C) IntPtr wxGridSizeEvent_ctor();
        static extern (C) IntPtr wxGridSizeEvent_ctorParam(int id, int type, IntPtr obj, int rowOrCol, int x, int y, bool control, bool shift, bool alt, bool meta);
        static extern (C) int    wxGridSizeEvent_GetRowOrCol(IntPtr self);
        static extern (C) void   wxGridSizeEvent_GetPosition(IntPtr self, ref Point pt);
        static extern (C) bool   wxGridSizeEvent_ControlDown(IntPtr self);
        static extern (C) bool   wxGridSizeEvent_MetaDown(IntPtr self);
        static extern (C) bool   wxGridSizeEvent_ShiftDown(IntPtr self);
        static extern (C) bool   wxGridSizeEvent_AltDown(IntPtr self);
        static extern (C) void wxGridSizeEvent_Veto(IntPtr self);
        static extern (C) void wxGridSizeEvent_Allow(IntPtr self);
        static extern (C) bool wxGridSizeEvent_IsAllowed(IntPtr self);          
        //! \endcond
    
        //-----------------------------------------------------------------------------
        
    alias GridSizeEvent wxGridSizeEvent;
    public class GridSizeEvent : Event 
    {
        public this(IntPtr wxobj) 
            { super(wxobj); }
        
        public this()
            { this(wxGridSizeEvent_ctor()); }
        
        public this(int id, int type, wxObject obj, int rowOrCol, int x, int y, bool control, bool shift, bool alt, bool meta)
            { this(wxGridSizeEvent_ctorParam(id, type, wxObject.SafePtr(obj), rowOrCol, x, y, control, shift, alt, meta)); }
        
        //-----------------------------------------------------------------------------
        
        public int RowOrCol() { return wxGridSizeEvent_GetRowOrCol(wxobj); }
        
        //-----------------------------------------------------------------------------
        
        public Point Position() { 
                Point pt;
                wxGridSizeEvent_GetPosition(wxobj, pt); 
                return pt;
            }
        
        //-----------------------------------------------------------------------------
        
        public bool ControlDown() { return wxGridSizeEvent_ControlDown(wxobj); }
    
        public bool MetaDown() { return wxGridSizeEvent_MetaDown(wxobj); }
        
        public bool ShiftDown() { return wxGridSizeEvent_ShiftDown(wxobj); }
        
        public bool AltDown() { return wxGridSizeEvent_AltDown(wxobj); }
        
        //-----------------------------------------------------------------------------     
        
        public void Veto()
        {
            wxGridSizeEvent_Veto(wxobj);
        }
        
        //-----------------------------------------------------------------------------
        
        public void Allow()
        {
            wxGridSizeEvent_Allow(wxobj);
        }
        
        //-----------------------------------------------------------------------------
        
        public bool Allowed() { return wxGridSizeEvent_IsAllowed(wxobj); }

	private static Event New(IntPtr obj) { return new GridSizeEvent(obj); }

	static this()
	{
			wxEVT_GRID_ROW_SIZE = wxEvent_EVT_GRID_ROW_SIZE();
			wxEVT_GRID_COL_SIZE = wxEvent_EVT_GRID_COL_SIZE();

			AddEventType(wxEVT_GRID_ROW_SIZE,                   &GridSizeEvent.New);
			AddEventType(wxEVT_GRID_COL_SIZE,                   &GridSizeEvent.New);
	}
    }
    
    //-----------------------------------------------------------------------------

	extern (C) {
        alias void function(GridCellRenderer obj, IntPtr grid, IntPtr attr, IntPtr dc, Rectangle rect, int row, int col, bool isSelected) Virtual_Draw;
        alias Size function(GridCellRenderer obj, IntPtr grid, IntPtr attr, IntPtr dc, int row, int col) Virtual_GetBestSize;
        alias IntPtr function(GridCellRenderer obj) Virtual_RendererClone;
	}

        //-----------------------------------------------------------------------------
        
        //! \cond EXTERN
        static extern (C) IntPtr wxGridCellRenderer_ctor();
	static extern (C) void wxGridCellRenderer_dtor(IntPtr self);
        static extern (C) void wxGridCellRenderer_RegisterVirtual(IntPtr self, GridCellRenderer obj, Virtual_Draw draw, Virtual_GetBestSize getBestSize, Virtual_RendererClone clone);
        //! \endcond
	
	//-----------------------------------------------------------------------------
	
    public abstract class GridCellRenderer : GridCellWorker
    {
        public this()
        {
        	this(wxGridCellRenderer_ctor(), true);

            wxGridCellRenderer_RegisterVirtual(wxobj, this,
                &staticDoDraw,
                &staticDoGetBestSize,
                &staticDoClone);
        }
        
        public this(IntPtr wxobj)
	{ 
		super(wxobj);
	}
	
	private this(IntPtr wxobj, bool memOwn)
	{ 
		super(wxobj);
		this.memOwn = memOwn;
	}
	
	//public static wxObject New(IntPtr ptr) { return new GridCellRenderer(ptr);}
	
	//---------------------------------------------------------------------
	
	override protected void dtor() { wxGridCellRenderer_dtor(wxobj); }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private void staticDoDraw(GridCellRenderer obj, IntPtr grid, IntPtr attr, IntPtr dc, Rectangle rect, int row, int col, bool isSelected)
        {
            //if ( FindObject(grid) === null ) Console.WriteLine("grid == null"); else Console.WriteLine("grid found");
            obj.Draw(cast(Grid)FindObject(grid, &Grid.New), cast(GridCellAttr)FindObject(attr, &GridCellAttr.New), cast(DC)wxObject.FindObject(dc), rect, row, col, isSelected);
        }
        
        public abstract void Draw(Grid grid, GridCellAttr attr, DC dc, Rectangle rect, int row, int col, bool isSelected);
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private Size staticDoGetBestSize(GridCellRenderer obj, IntPtr grid, IntPtr attr, IntPtr dc,  int row, int col)
        {
            return obj.GetBestSize(cast(Grid)FindObject(grid, &Grid.New), cast(GridCellAttr)FindObject(attr, &GridCellAttr.New), cast(DC)wxObject.FindObject(dc, &DC.New), row, col);
            
        }
        
        public abstract Size GetBestSize(Grid grid, GridCellAttr attr, DC dc, int row, int col);
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private IntPtr staticDoClone(GridCellRenderer obj)
        {
            return wxObject.SafePtr(obj.Clone());
        }
        
        public abstract GridCellRenderer Clone();
    }
    
    //-----------------------------------------------------------------------------
    
        //! \cond EXTERN
        static extern (C) IntPtr wxGridCellStringRenderer_ctor();
	static extern (C) void wxGridCellStringRenderer_dtor(IntPtr self);
	static extern (C) void wxGridCellStringRenderer_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
        static extern (C) void wxGridCellStringRenderer_Draw(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, ref Rectangle rect, int row, int col, bool isSelected);
        static extern (C) void wxGridCellStringRenderer_GetBestSize(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, int row, int col, out Size size);
        static extern (C) IntPtr wxGridCellStringRenderer_Clone(IntPtr self);
        //! \endcond
	
    alias GridCellStringRenderer wxGridCellStringRenderer;
    public class GridCellStringRenderer : GridCellRenderer
    {
        public this()
	{ 
		this(wxGridCellStringRenderer_ctor(), true);
		wxGridCellStringRenderer_RegisterDisposable(wxobj, &VirtualDispose);
	}
            
        public this(IntPtr wxobj)
	{ 
		super(wxobj);
	}
	
	private this(IntPtr wxobj, bool memOwn)
	{ 
		super(wxobj);
		this.memOwn = memOwn;
	}
	
	//---------------------------------------------------------------------
	
	override protected void dtor() { wxGridCellStringRenderer_dtor(wxobj); }

	//---------------------------------------------------------------------

        public override void Draw(Grid grid, GridCellAttr attr, DC dc, Rectangle rect, int row, int col, bool isSelected)
        {
            wxGridCellStringRenderer_Draw(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), rect, row, col, isSelected);
        }
        
        public override Size GetBestSize(Grid grid, GridCellAttr attr, DC dc, int row, int col)
        {
            Size size;
            wxGridCellStringRenderer_GetBestSize(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), row, col, size);         
            return size;
        }
        
        public override GridCellRenderer Clone()
        {
//            return cast(GridCellRenderer)FindObject(wxGridCellStringRenderer_Clone(wxobj), &GridCellRenderer.New);
              return new GridCellStringRenderer(wxGridCellStringRenderer_Clone(wxobj));
        }       
    }
    
    //-----------------------------------------------------------------------------
    
        static extern (C) IntPtr wxGridCellNumberRenderer_ctor();
	static extern (C) void wxGridCellNumberRenderer_dtor(IntPtr self);
        static extern (C) void wxGridCellNumberRenderer_Draw(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, ref Rectangle rect, int row, int col, bool isSelected);
        static extern (C) void wxGridCellNumberRenderer_GetBestSize(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, int row, int col, out Size size);
        static extern (C) IntPtr wxGridCellNumberRenderer_Clone(IntPtr self);
	
    alias GridCellNumberRenderer wxGridCellNumberRenderer;
    public class GridCellNumberRenderer : GridCellStringRenderer
    {
        public this()
            { this(wxGridCellNumberRenderer_ctor(), true); }
            
        public this(IntPtr wxobj)
	{ 
		super(wxobj);
	}
	
	private this(IntPtr wxobj, bool memOwn)
	{ 
		super(wxobj);
		this.memOwn = memOwn;
	}
	
	//---------------------------------------------------------------------
				
	override protected void dtor() { wxGridCellNumberRenderer_dtor(wxobj); }
        
        public override void Draw(Grid grid, GridCellAttr attr, DC dc, Rectangle rect, int row, int col, bool isSelected)
        {
            wxGridCellNumberRenderer_Draw(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), rect, row, col, isSelected);
        }
        
        public override Size GetBestSize(Grid grid, GridCellAttr attr, DC dc, int row, int col)
        {
            Size size;
            wxGridCellNumberRenderer_GetBestSize(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), row, col, size);         
            return size;
        }
        
        public override GridCellRenderer Clone()
        {
        //    return cast(GridCellRenderer)FindObject(wxGridCellNumberRenderer_Clone(wxobj), &GridCellRenderer.New);
            return new GridCellNumberRenderer(wxGridCellNumberRenderer_Clone(wxobj));
        }               
    }
    
    //-----------------------------------------------------------------------------
    
        //! \cond EXTERN
        static extern (C) IntPtr wxGridCellFloatRenderer_ctor(int width, int precision);
	static extern (C) void wxGridCellFloatRenderer_dtor(IntPtr self);
        static extern (C) void wxGridCellFloatRenderer_Draw(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, ref Rectangle rect, int row, int col, bool isSelected);
        static extern (C) void wxGridCellFloatRenderer_GetBestSize(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, int row, int col, out Size size);
        static extern (C) IntPtr wxGridCellFloatRenderer_Clone(IntPtr self);
        static extern (C) int wxGridCellFloatRenderer_GetWidth(IntPtr self);
        static extern (C) void wxGridCellFloatRenderer_SetWidth(IntPtr self, int width);
        static extern (C) int wxGridCellFloatRenderer_GetPrecision(IntPtr self);
        static extern (C) void wxGridCellFloatRenderer_SetPrecision(IntPtr self, int precision);
        static extern (C) void wxGridCellFloatRenderer_SetParameters(IntPtr self, string parameter);
        //! \endcond
	
    alias GridCellFloatRenderer wxGridCellFloatRenderer;
    public class GridCellFloatRenderer : GridCellStringRenderer
    {
        public this()
            { this(-1, -1); }
            
        public this(int width)
            { this(width, -1); }
            
        public this(int width, int precision)
            { this(wxGridCellFloatRenderer_ctor(width, precision), true); }
                
        public this(IntPtr wxobj)
	{ 
		super(wxobj);
	}
	
	private this(IntPtr wxobj, bool memOwn)
	{ 
		super(wxobj);
		this.memOwn = memOwn;
	}
	
	//---------------------------------------------------------------------
				
	override protected void dtor() { wxGridCellFloatRenderer_dtor(wxobj); }
        
        public override void SetParameters(string parameter)
        {
            wxGridCellFloatRenderer_SetParameters(wxobj, parameter);
        }
        
        public int Width() { return wxGridCellFloatRenderer_GetWidth(wxobj); }
        public void Width(int value) { wxGridCellFloatRenderer_SetWidth(wxobj,value); }
        
        public int Precision() { return wxGridCellFloatRenderer_GetPrecision(wxobj); }
        public void Precision(int value) { wxGridCellFloatRenderer_SetPrecision(wxobj, value); }
        
        public override void Draw(Grid grid, GridCellAttr attr, DC dc, Rectangle rect, int row, int col, bool isSelected)
        {
            wxGridCellFloatRenderer_Draw(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), rect, row, col, isSelected);
        }
        
        public override Size GetBestSize(Grid grid, GridCellAttr attr, DC dc, int row, int col)
        {
            Size size;
            wxGridCellFloatRenderer_GetBestSize(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), row, col, size);          
            return size;
        }
        
        public override GridCellRenderer Clone()
        {
//            return cast(GridCellRenderer)FindObject(wxGridCellFloatRenderer_Clone(wxobj), &GridCellRenderer.New);
            return new GridCellFloatRenderer(wxGridCellFloatRenderer_Clone(wxobj));
        }                       
    }
    
    //-----------------------------------------------------------------------------
    
        //! \cond EXTERN
        static extern (C) IntPtr wxGridCellBoolRenderer_ctor();
	static extern (C) void wxGridCellBoolRenderer_dtor(IntPtr self);
	static extern (C) void wxGridCellBoolRenderer_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
        static extern (C) void wxGridCellBoolRenderer_Draw(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, ref Rectangle rect, int row, int col, bool isSelected);
        static extern (C) void wxGridCellBoolRenderer_GetBestSize(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, int row, int col, out Size size);
        static extern (C) IntPtr wxGridCellBoolRenderer_Clone(IntPtr self);
        //! \endcond
	
    alias GridCellBoolRenderer wxGridCellBoolRenderer;
    public class GridCellBoolRenderer : GridCellRenderer
    {
        public this()
	{ 
		this(wxGridCellBoolRenderer_ctor(), true);
		wxGridCellBoolRenderer_RegisterDisposable(wxobj, &VirtualDispose);
	}
            
        public this(IntPtr wxobj)
	{ 
		super(wxobj);
	}
	
	private this(IntPtr wxobj, bool memOwn)
	{ 
		super(wxobj);
		this.memOwn = memOwn;
	}
	
	//---------------------------------------------------------------------
				
	override protected void dtor() { wxGridCellBoolRenderer_dtor(wxobj); }
        
        public override void Draw(Grid grid, GridCellAttr attr, DC dc, Rectangle rect, int row, int col, bool isSelected)
        {
            wxGridCellBoolRenderer_Draw(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), rect, row, col, isSelected);
        }
        
        public override Size GetBestSize(Grid grid, GridCellAttr attr, DC dc, int row, int col)
        {
            Size size;
            wxGridCellBoolRenderer_GetBestSize(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), row, col, size);           
            return size;
        }
        
        public override GridCellRenderer Clone()
        {
//            return cast(GridCellRenderer)FindObject(wxGridCellBoolRenderer_Clone(wxobj), &GridCellRenderer.New);
            return new GridCellBoolRenderer(wxGridCellBoolRenderer_Clone(wxobj));
        }
    }
    
    //-----------------------------------------------------------------------------
    
        extern (C) {
        alias int  function(GridTableBase obj) Virtual_GetNumberRows;
        alias int  function(GridTableBase obj) Virtual_GetNumberCols;
        alias bool function(GridTableBase obj, int row, int col) Virtual_IsEmptyCell;
        alias string function(GridTableBase obj, int row, int col) Virtual_GetValue_gt;
        alias void function(GridTableBase obj, int row, int col, IntPtr val) Virtual_SetValue;
        alias bool function(GridTableBase obj, int row, int col, IntPtr typeName) Virtual_CanGetValueAs;
        alias int  function(GridTableBase obj, int row, int col) Virtual_GetValueAsLong;
        alias double function(GridTableBase obj, int row, int col) Virtual_GetValueAsDouble;
        alias void function(GridTableBase obj, int row, int col, int value) Virtual_SetValueAsLong;
        alias void function(GridTableBase obj, int row, int col, double value) Virtual_SetValueAsDouble;
        alias void function(GridTableBase obj, int row, int col, bool value) Virtual_SetValueAsBool;
        alias IntPtr function(GridTableBase obj, int row, int col, IntPtr typeName) Virtual_GetValueAsCustom;
        alias void function(GridTableBase obj, int row, int col, IntPtr typeName, IntPtr value) Virtual_SetValueAsCustom;
        alias string function(GridTableBase obj, int col) Virtual_GetColLabelValue;
        alias void function(GridTableBase obj, IntPtr grid) Virtual_SetView;
        alias IntPtr function(GridTableBase obj) Virtual_GetView;
        alias void function(GridTableBase obj) Virtual_Clear;
        alias bool function(GridTableBase obj, int pos, int numRows) Virtual_InsertRows;
        alias bool function(GridTableBase obj, int numRows) Virtual_AppendRows;
        alias void function(GridTableBase obj, int row, IntPtr val) Virtual_SetRowLabelValue;
        alias void function(GridTableBase obj, IntPtr attrProvider) Virtual_SetAttrProvider;
        alias IntPtr function(GridTableBase obj) Virtual_GetAttrProvider;
        alias bool function(GridTableBase obj) Virtual_CanHaveAttributes;
        alias IntPtr function(GridTableBase obj, int row, int col, int kind) Virtual_GetAttr_gt;
        alias void function(GridTableBase obj, IntPtr attr, int row, int col) Virtual_SetAttr_gt;
        alias void function(GridTableBase obj, IntPtr attr, int row) Virtual_SetRowAttr_gt;
        }

        //! \cond EXTERN
        static extern (C) IntPtr wxGridTableBase_ctor();
        static extern (C) void wxGridTableBase_RegisterVirtual(IntPtr self, GridTableBase obj, 
            Virtual_GetNumberRows getNumberRows, 
            Virtual_GetNumberCols getNumberCols, 
            Virtual_IsEmptyCell isEmptyCell, 
            Virtual_GetValue_gt getValue, 
            Virtual_SetValue setValue, 
            Virtual_GetValue_gt getTypeName, 
            Virtual_CanGetValueAs canGetValueAs, 
            Virtual_CanGetValueAs canSetValueAs, 
            Virtual_GetValueAsLong getValueAsLong,
            Virtual_GetValueAsDouble getValueAsDouble, 
            Virtual_IsEmptyCell getValueAsBool,
            Virtual_SetValueAsLong setValueAsLong,
            Virtual_SetValueAsDouble setValueAsDouble,
            Virtual_SetValueAsBool setValueAsBool,
            Virtual_GetValueAsCustom getValueAsCustom,
            Virtual_SetValueAsCustom setValueAsCustom,
            Virtual_SetView setView,
            Virtual_GetView getView,
            Virtual_Clear clear,
            Virtual_InsertRows insertRows,
            Virtual_AppendRows appendRows,
            Virtual_InsertRows deleteRows,
            Virtual_InsertRows insertCols,
            Virtual_AppendRows appendCols,
            Virtual_InsertRows deleteCols,
            Virtual_GetColLabelValue getRowLabelValue,
            Virtual_GetColLabelValue getColLabelValue,
            Virtual_SetRowLabelValue setRowLabelValue,
            Virtual_SetRowLabelValue setColLabelValue,
            Virtual_SetAttrProvider setAttrProvider,
            Virtual_GetAttrProvider getAttrProvider,
            Virtual_CanHaveAttributes canHaveAttributes,
            Virtual_GetAttr_gt getAttr,
            Virtual_SetAttr_gt setAttr,
            Virtual_SetRowAttr_gt setRowAttr,
            Virtual_SetRowAttr_gt setColAttr);

        static extern (C) int    wxGridTableBase_GetNumberRows(IntPtr self);
        static extern (C) int    wxGridTableBase_GetNumberCols(IntPtr self);
        static extern (C) bool   wxGridTableBase_IsEmptyCell(IntPtr self, int row, int col);
        static extern (C) IntPtr wxGridTableBase_GetValue(IntPtr self, int row, int col);
        static extern (C) void   wxGridTableBase_SetValue(IntPtr self, int row, int col, IntPtr val);
        static extern (C) IntPtr wxGridTableBase_GetTypeName(IntPtr self, int row, int col);
        static extern (C) bool   wxGridTableBase_CanGetValueAs(IntPtr self, int row, int col, string typeName);
        static extern (C) bool   wxGridTableBase_CanSetValueAs(IntPtr self, int row, int col, string typeName);
        static extern (C) int   wxGridTableBase_GetValueAsLong(IntPtr self, int row, int col);
        static extern (C) double wxGridTableBase_GetValueAsDouble(IntPtr self, int row, int col);
        static extern (C) bool   wxGridTableBase_GetValueAsBool(IntPtr self, int row, int col);
        static extern (C) void   wxGridTableBase_SetValueAsLong(IntPtr self, int row, int col, int val);
        static extern (C) void   wxGridTableBase_SetValueAsDouble(IntPtr self, int row, int col, double val);
        static extern (C) void   wxGridTableBase_SetValueAsBool(IntPtr self, int row, int col, bool val);
        static extern (C) IntPtr wxGridTableBase_GetValueAsCustom(IntPtr self, int row, int col, string typeName);
        static extern (C) void   wxGridTableBase_SetValueAsCustom(IntPtr self, int row, int col, string typeName, IntPtr val);
        static extern (C) void   wxGridTableBase_SetView(IntPtr self, IntPtr grid);
        static extern (C) IntPtr wxGridTableBase_GetView(IntPtr self);
        static extern (C) void   wxGridTableBase_Clear(IntPtr self);
        static extern (C) bool   wxGridTableBase_InsertRows(IntPtr self, int pos, int numRows);
        static extern (C) bool   wxGridTableBase_AppendRows(IntPtr self, int numRows);
        static extern (C) bool   wxGridTableBase_DeleteRows(IntPtr self, int pos, int numRows);
        static extern (C) bool   wxGridTableBase_InsertCols(IntPtr self, int pos, int numCols);
        static extern (C) bool   wxGridTableBase_AppendCols(IntPtr self, int numCols);
        static extern (C) bool   wxGridTableBase_DeleteCols(IntPtr self, int pos, int numCols);
        static extern (C) IntPtr wxGridTableBase_GetRowLabelValue(IntPtr self, int row);
        static extern (C) IntPtr wxGridTableBase_GetColLabelValue(IntPtr self, int col);
        static extern (C) void   wxGridTableBase_SetRowLabelValue(IntPtr self, int row, string val);
        static extern (C) void   wxGridTableBase_SetColLabelValue(IntPtr self, int col, string val);
        static extern (C) void   wxGridTableBase_SetAttrProvider(IntPtr self, IntPtr attrProvider);
        static extern (C) IntPtr wxGridTableBase_GetAttrProvider(IntPtr self);
        static extern (C) bool   wxGridTableBase_CanHaveAttributes(IntPtr self);
        static extern (C) IntPtr wxGridTableBase_GetAttr(IntPtr self, int row, int col, int kind);
        static extern (C) void   wxGridTableBase_SetAttr(IntPtr self, IntPtr attr, int row, int col);
        static extern (C) void   wxGridTableBase_SetRowAttr(IntPtr self, IntPtr attr, int row);
        static extern (C) void   wxGridTableBase_SetColAttr(IntPtr self, IntPtr attr, int col);
        //! \endcond
        
        //-----------------------------------------------------------------------------
    
    public abstract class GridTableBase : wxObject//ClientData 
    {
        public this()
        {
        	this(wxGridTableBase_ctor());
            wxGridTableBase_RegisterVirtual(wxobj, this, 
                &staticGetNumberRows,
                &staticGetNumberCols,
                &staticIsEmptyCell,
                &staticGetValue,
                &staticDoSetValue,
                &staticGetTypeName,
                &staticDoCanGetValueAs,
                &staticDoCanSetValueAs,
                &staticGetValueAsLong,
                &staticGetValueAsDouble,
                &staticGetValueAsBool,
                &staticSetValueAsLong,
                &staticSetValueAsDouble,
                &staticSetValueAsBool,
                &staticDoGetValueAsCustom,
                &staticDoSetValueAsCustom,
                &staticDoSetView,
                &staticDoGetView,
                &staticClear,
                &staticInsertRows,
                &staticAppendRows,
                &staticDeleteRows,
                &staticInsertCols,
                &staticAppendCols,
                &staticDeleteCols,
                &staticGetRowLabelValue,
                &staticGetColLabelValue,
                &staticDoSetRowLabelValue,
                &staticDoSetColLabelValue,
                &staticDoSetAttrProvider,
                &staticDoGetAttrProvider,
                &staticCanHaveAttributes,
                &staticDoGetAttr,
                &staticDoSetAttr,
                &staticDoSetRowAttr,
                &staticDoSetColAttr
            );
        }
        
        public this(IntPtr wxobj)
            { super(wxobj); }
        
        //public static wxObject New(IntPtr ptr) { return new GridTableBase(ptr); }
        //-----------------------------------------------------------------------------
        
        static extern (C) private int staticGetNumberRows(GridTableBase obj)
        {
            return obj.GetNumberRows();
        }
        public abstract int GetNumberRows();
//        {
//            return wxGridTableBase_GetNumberRows(wxobj);
//        }
        
        static extern (C) private int staticGetNumberCols(GridTableBase obj)
        {
            return obj.GetNumberCols();
        }
        public abstract int GetNumberCols();
//        {
//            return wxGridTableBase_GetNumberCols(wxobj);
//        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private bool staticIsEmptyCell(GridTableBase obj, int row, int col)
        {
            return obj.IsEmptyCell(row,col);
        }
        public abstract bool IsEmptyCell(int row, int col);
//        {
//            return wxGridTableBase_IsEmptyCell(wxobj, row, col);
//        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private string staticGetValue(GridTableBase obj, int row, int col)
        {
            return obj.GetValue(row,col);
        }
        public abstract string GetValue(int row, int col);
//        {
//            return cast(string) new wxString(wxGridTableBase_GetValue(wxobj, row, col), true);
//        }

        static extern (C) private void staticDoSetValue(GridTableBase obj, int row, int col, IntPtr val)
        {
            obj.SetValue(row, col, cast(string) new wxString(val));
        }       
        
        public abstract void SetValue(int row, int col, string val);
//        {
//            wxGridTableBase_SetValue(wxobj, row, col, val);
//        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private string staticGetTypeName(GridTableBase obj, int row, int col)
        {
            return obj.GetTypeName(row,col);
        }
        public /+virtual+/ string GetTypeName(int row, int col)
        {
            return cast(string) new wxString(wxGridTableBase_GetTypeName(wxobj, row, col), true);
        }
        
        static extern (C) private bool staticDoCanGetValueAs(GridTableBase obj, int row, int col, IntPtr typeName)
        {
            return obj.CanGetValueAs(row, col, cast(string) new wxString(typeName));
        }
        
        public /+virtual+/ bool CanGetValueAs(int row, int col, string typeName)
        {
            return wxGridTableBase_CanGetValueAs(wxobj, row, col, typeName);
        }

        static extern (C) private bool staticDoCanSetValueAs(GridTableBase obj, int row, int col, IntPtr typeName)
        {
            return obj.CanSetValueAs(row, col, cast(string) new wxString(typeName));
        }
        
        public /+virtual+/ bool CanSetValueAs(int row, int col, string typeName)
        {
            return wxGridTableBase_CanSetValueAs(wxobj, row, col, typeName);
        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private int staticGetValueAsLong(GridTableBase obj, int row, int col)
	{
	    return obj.GetValueAsLong(row,col);
	}
        public /+virtual+/ int GetValueAsLong(int row, int col)
        {
            return wxGridTableBase_GetValueAsLong(wxobj, row, col);
        }
        
        static extern (C) private double staticGetValueAsDouble(GridTableBase obj, int row, int col)
	{
	    return obj.GetValueAsDouble(row,col);
	}
        public /+virtual+/ double GetValueAsDouble(int row, int col)
        {
            return wxGridTableBase_GetValueAsDouble(wxobj, row, col);
        }
        
        static extern (C) private bool staticGetValueAsBool(GridTableBase obj, int row, int col)
	{
	    return obj.GetValueAsBool(row,col);
	}
        public /+virtual+/ bool GetValueAsBool(int row, int col)
        {
            return wxGridTableBase_GetValueAsBool(wxobj, row, col);
        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private void staticSetValueAsLong(GridTableBase obj, int row, int col, int val)
	{
	    return obj.SetValueAsLong(row,col,val);
	}
        public /+virtual+/ void SetValueAsLong(int row, int col, int val)
        {
            wxGridTableBase_SetValueAsLong(wxobj, row, col, val);
        }
        
        static extern (C) private void staticSetValueAsDouble(GridTableBase obj, int row, int col, double val)
	{
	    return obj.SetValueAsDouble(row,col,val);
	}
        public /+virtual+/ void SetValueAsDouble(int row, int col, double val)
        {
            wxGridTableBase_SetValueAsDouble(wxobj, row, col, val);
        }
        
        static extern (C) private void staticSetValueAsBool(GridTableBase obj, int row, int col, bool val)
	{
	    return obj.SetValueAsBool(row,col,val);
	}
        public /+virtual+/ void SetValueAsBool(int row, int col, bool val)
        {
            wxGridTableBase_SetValueAsBool(wxobj, row, col, val);
        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private IntPtr staticDoGetValueAsCustom(GridTableBase obj, int row, int col, IntPtr typeName)
        {
            return wxObject.SafePtr(obj.GetValueAsCustom(row, col, cast(string) new wxString(typeName)));
        }
        
        public /+virtual+/ wxObject GetValueAsCustom(int row, int col, string typeName)
        {
            return FindObject(wxGridTableBase_GetValueAsCustom(wxobj, row, col, typeName));
        }
        
        static extern (C) private void staticDoSetValueAsCustom(GridTableBase obj, int row, int col, IntPtr typeName, IntPtr val)
        {
            obj.SetValueAsCustom(row, col, cast(string) new wxString(typeName), FindObject(val));
        }
        
        public /+virtual+/ void SetValueAsCustom(int row, int col, string typeName, wxObject val)
        {
            wxGridTableBase_SetValueAsCustom(wxobj, row, col, typeName, wxObject.SafePtr(val));
        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private void staticDoSetView(GridTableBase obj, IntPtr grid)
        {
            obj.SetView(cast(Grid)FindObject(grid, &Grid.New));
        }
        
        public /+virtual+/ void SetView(Grid grid)
        {
            wxGridTableBase_SetView(wxobj, wxObject.SafePtr(grid));
        }
        
        static extern (C) private IntPtr staticDoGetView(GridTableBase obj)
        {
            return wxObject.SafePtr(obj.GetView());
        }
        
        public /+virtual+/ Grid GetView()
        {
            return cast(Grid)FindObject(wxGridTableBase_GetView(wxobj), &Grid.New);
        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private void staticClear(GridTableBase obj)
	{
	    obj.Clear();
	}
        public /+virtual+/ void Clear()
        {
            wxGridTableBase_Clear(wxobj);
        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private bool staticInsertRows(GridTableBase obj, int pos, int numRows)
	{
	    return obj.InsertRows(pos, numRows);
	}
        public /+virtual+/ bool InsertRows(int pos, int numRows)
        {
            return wxGridTableBase_InsertRows(wxobj, pos, numRows);
        }
        
        static extern (C) private bool staticAppendRows(GridTableBase obj, int numRows)
        {
            return obj.AppendRows(numRows);
        }
        public /+virtual+/ bool AppendRows(int numRows)
        {
            return wxGridTableBase_AppendRows(wxobj, numRows);
        }
        
        static extern (C) private bool staticDeleteRows(GridTableBase obj, int pos, int numRows)
	{
	    return obj.DeleteRows(pos, numRows);
	}
        public /+virtual+/ bool DeleteRows(int pos, int numRows)
        {
            return wxGridTableBase_DeleteRows(wxobj, pos, numRows);
        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private bool staticInsertCols(GridTableBase obj, int pos, int numCols)
	{
	    return obj.InsertCols(pos, numCols);
	}
        public /+virtual+/ bool InsertCols(int pos, int numCols)
        {
            return wxGridTableBase_InsertCols(wxobj, pos, numCols);
        }
        
        static extern (C) private bool staticAppendCols(GridTableBase obj, int numCols)
        {
            return obj.AppendCols(numCols);
        }
        public /+virtual+/ bool AppendCols(int numCols)
        {
            return wxGridTableBase_AppendCols(wxobj, numCols);
        }
        
        static extern (C) private bool staticDeleteCols(GridTableBase obj, int pos, int numCols)
	{
	    return obj.DeleteCols(pos, numCols);
	}
        public /+virtual+/ bool DeleteCols(int pos, int numCols)
        {
            return wxGridTableBase_DeleteCols(wxobj, pos, numCols);
        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private string staticGetRowLabelValue(GridTableBase obj, int row)
        {
            return obj.GetRowLabelValue(row);
        }
        public /+virtual+/ string GetRowLabelValue(int row)
        {
            return cast(string) new wxString(wxGridTableBase_GetRowLabelValue(wxobj, row), true);
        }
        
        static extern (C) private string staticGetColLabelValue(GridTableBase obj, int col)
        {
            return obj.GetColLabelValue(col);
        }
        public /+virtual+/ string GetColLabelValue(int col)
        {
            return cast(string) new wxString(wxGridTableBase_GetColLabelValue(wxobj, col), true);
        }
        
        static extern (C) private void staticDoSetRowLabelValue(GridTableBase obj, int row, IntPtr val)
        {
            obj.SetRowLabelValue(row, cast(string) new wxString(val));
        }       
        
        public /+virtual+/ void SetRowLabelValue(int row, string val)
        {
            wxGridTableBase_SetRowLabelValue(wxobj, row, val);
        }
        
        static extern (C) private void staticDoSetColLabelValue(GridTableBase obj, int col, IntPtr val)
        {
            obj.SetColLabelValue(col, cast(string) new wxString(val));
        }       
        
        public /+virtual+/ void SetColLabelValue(int col, string val)
        {
            wxGridTableBase_SetColLabelValue(wxobj, col, val);
        }       
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private void staticDoSetAttrProvider(GridTableBase obj, IntPtr attrProvider)
        {
            obj.SetAttrProvider(cast(GridCellAttrProvider)FindObject(attrProvider, &GridCellAttrProvider.New));
        }
        
        public void SetAttrProvider(GridCellAttrProvider attrProvider)
        {
            wxGridTableBase_SetAttrProvider(wxobj, wxObject.SafePtr(attrProvider));
        }
        
        static extern (C) private IntPtr staticDoGetAttrProvider(GridTableBase obj)
        {
            return wxObject.SafePtr(obj.GetAttrProvider());
        }
        
        public GridCellAttrProvider GetAttrProvider()
        {
            return new GridCellAttrProvider(wxGridTableBase_GetAttrProvider(wxobj));
        }
        
        static extern (C) private bool staticCanHaveAttributes(GridTableBase obj)
        {
            return obj.CanHaveAttributes();
        }
        public /+virtual+/ bool CanHaveAttributes()
        {
            return wxGridTableBase_CanHaveAttributes(wxobj);
        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private IntPtr staticDoGetAttr(GridTableBase obj, int row, int col, int kind)
        {
            return wxObject.SafePtr(obj.GetAttr(row, col, cast(GridCellAttr.AttrKind) kind));
        }
        
        public /+virtual+/ GridCellAttr GetAttr(int row, int col, GridCellAttr.AttrKind kind)
        {
            return cast(GridCellAttr)FindObject(wxGridTableBase_GetAttr(wxobj, row, col, cast(int)kind), &GridCellAttr.New);
        }
        
        static extern (C) private void staticDoSetAttr(GridTableBase obj, IntPtr attr, int row, int col)
        {
            obj.SetAttr(cast(GridCellAttr)FindObject(attr, &GridCellAttr.New), row, col);
        }
        
        public /+virtual+/ void SetAttr(GridCellAttr attr, int row, int col)
        {
            wxGridTableBase_SetAttr(wxobj, wxObject.SafePtr(attr), row, col);
        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private void staticDoSetRowAttr(GridTableBase obj, IntPtr attr, int row)
        {
            obj.SetRowAttr(cast(GridCellAttr)FindObject(attr, &GridCellAttr.New), row);
        }
        
        public /+virtual+/ void SetRowAttr(GridCellAttr attr, int row)
        {
            wxGridTableBase_SetRowAttr(wxobj, wxObject.SafePtr(attr), row);
        }
        
        static extern (C) private void staticDoSetColAttr(GridTableBase obj, IntPtr attr, int col)
        {
            obj.SetColAttr(cast(GridCellAttr)FindObject(attr, &GridCellAttr.New), col);
        }       
        
        public /+virtual+/ void SetColAttr(GridCellAttr attr, int col)
        {
            wxGridTableBase_SetColAttr(wxobj, wxObject.SafePtr(attr), col);
        }
    }
    
	extern (C) {
        alias IntPtr function(GridCellAttrProvider obj, int row, int col, int kind) Virtual_GetAttr;
        alias void function(GridCellAttrProvider obj, IntPtr attr, int row, int col) Virtual_SetAttr;
        alias void function(GridCellAttrProvider obj, IntPtr attr, int row) Virtual_SetRowAttr;
	}

        //! \cond EXTERN
        static extern (C) IntPtr wxGridCellAttrProvider_ctor();
	static extern (C) void wxGridCellAttrProvider_dtor(IntPtr self);
        static extern (C) void wxGridCellAttrProvider_RegisterVirtual(IntPtr self,GridCellAttrProvider obj, 
            Virtual_GetAttr getAttr,
            Virtual_SetAttr setAttr,
            Virtual_SetRowAttr setRowAttr,
            Virtual_SetRowAttr setColAttr);
	static extern (C) void wxGridCellAttrProvider_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
        static extern (C) IntPtr wxGridCellAttrProvider_GetAttr(IntPtr self, int row, int col, int kind);
        static extern (C) void wxGridCellAttrProvider_SetAttr(IntPtr self, IntPtr attr, int row, int col); 
        static extern (C) void wxGridCellAttrProvider_SetRowAttr(IntPtr self, IntPtr attr, int row); 
        static extern (C) void wxGridCellAttrProvider_SetColAttr(IntPtr self, IntPtr attr, int col); 
        static extern (C) void wxGridCellAttrProvider_UpdateAttrRows(IntPtr self, int pos, int numRows);
        static extern (C) void wxGridCellAttrProvider_UpdateAttrCols(IntPtr self, int pos, int numCols);
        //! \endcond
	
        //-----------------------------------------------------------------------------
        
    alias GridCellAttrProvider wxGridCellAttrProvider;
    public class GridCellAttrProvider : wxObject  // ClientData
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
        	this(wxGridCellAttrProvider_ctor(), true);

            wxGridCellAttrProvider_RegisterVirtual(wxobj,this,
                &staticDoGetAttr,
                &staticDoSetAttr,
                &staticDoSetRowAttr,
                &staticDoSetColAttr);
		
		wxGridCellAttrProvider_RegisterDisposable(wxobj, &VirtualDispose);
        }
	
	public static wxObject New(IntPtr ptr) { return new GridCellAttrProvider(ptr); }
	//---------------------------------------------------------------------
				
	override protected void dtor() { wxGridCellAttrProvider_dtor(wxobj); }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private IntPtr staticDoGetAttr(GridCellAttrProvider obj, int row, int col, int kind)
        {
            return wxObject.SafePtr(obj.GetAttr(row, col, cast(GridCellAttr.AttrKind) kind));
        }
        
        public /+virtual+/ GridCellAttr GetAttr(int row, int col, GridCellAttr.AttrKind kind)
        {
            return cast(GridCellAttr)FindObject(wxGridCellAttrProvider_GetAttr(wxobj, row, col, cast(int)kind), &GridCellAttr.New);
        }
        
        static extern (C) private void staticDoSetAttr(GridCellAttrProvider obj, IntPtr attr, int row, int col)
        {
            obj.SetAttr(cast(GridCellAttr)FindObject(attr, &GridCellAttr.New), row, col);
        }
        
        public /+virtual+/ void SetAttr(GridCellAttr attr, int row, int col)
        {
            wxGridCellAttrProvider_SetAttr(wxobj, wxObject.SafePtr(attr), row, col);
        }
        
        //-----------------------------------------------------------------------------
        
        static extern (C) private void staticDoSetRowAttr(GridCellAttrProvider obj, IntPtr attr, int row)
        {
            obj.SetRowAttr(cast(GridCellAttr)FindObject(attr, &GridCellAttr.New), row);
        }
        
        public /+virtual+/ void SetRowAttr(GridCellAttr attr, int row)
        {
            wxGridCellAttrProvider_SetRowAttr(wxobj, wxObject.SafePtr(attr), row);
        }
        
        static extern (C) private void staticDoSetColAttr(GridCellAttrProvider obj, IntPtr attr, int col)
        {
            obj.SetColAttr(cast(GridCellAttr)FindObject(attr, &GridCellAttr.New), col);
        }       
        
        public /+virtual+/ void SetColAttr(GridCellAttr attr, int col)
        {
            wxGridCellAttrProvider_SetColAttr(wxobj, wxObject.SafePtr(attr), col);
        }
        
        //-----------------------------------------------------------------------------
        
        public void UpdateAttrRows(int pos, int numRows)
        {
            wxGridCellAttrProvider_UpdateAttrRows(wxobj, pos, numRows);
        }
        
        public void UpdateAttrCols(int pos, int numCols)
        {
            wxGridCellAttrProvider_UpdateAttrCols(wxobj, pos, numCols);
        }       
    }
