//-----------------------------------------------------------------------------
// wxD - GridCtrl.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - GridCtrl.cs
//
/// The wxGrid controls wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: GridCtrl.d,v 1.11 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.GridCtrl;
public import wx.common;
public import wx.Grid;

		//! \cond EXTERN
		static extern (C) IntPtr wxGridCellDateTimeRenderer_ctor(string outformat, string informat);
		static extern (C) void wxGridCellDateTimeRenderer_dtor(IntPtr self);
		static extern (C) void wxGridCellDateTimeRenderer_Draw(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, ref Rectangle rect, int row, int col, bool isSelected);
		static extern (C) void wxGridCellDateTimeRenderer_GetBestSize(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, int row, int col, out Size size);
		static extern (C) IntPtr wxGridCellDateTimeRenderer_Clone(IntPtr self);
		static extern (C) void wxGridCellDateTimeRenderer_SetParameters(IntPtr self, string parameter);
		//! \endcond
		
	alias GridCellDateTimeRenderer wxGridCellDateTimeRenderer;
	public class GridCellDateTimeRenderer : GridCellStringRenderer
	{
		public this()
			{ this("%c", "%c");}
			
		public this(string outformat)
			{ this(outformat, "%c");}
			
		public this(string outformat, string informat)
			{ this(wxGridCellDateTimeRenderer_ctor(outformat, informat), true);}
				
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
		
		override protected void dtor() { wxGridCellDateTimeRenderer_dtor(wxobj); }
		
		public override void SetParameters(string parameter)
		{
			wxGridCellDateTimeRenderer_SetParameters(wxobj, parameter);
		}
		
		public override void Draw(Grid grid, GridCellAttr attr, DC dc, Rectangle rect, int row, int col, bool isSelected)
		{
			wxGridCellDateTimeRenderer_Draw(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), rect, row, col, isSelected);
		}
		
		public override Size GetBestSize(Grid grid, GridCellAttr attr, DC dc, int row, int col)
		{
			Size size;
			wxGridCellDateTimeRenderer_GetBestSize(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), row, col, size);			
			return size;
		}
		
		public override GridCellRenderer Clone()
		{
//			return cast(GridCellRenderer)FindObject(wxGridCellDateTimeRenderer_Clone(wxobj), &GridCellRendererer.New);
			return new GridCellDateTimeRenderer(wxGridCellDateTimeRenderer_Clone(wxobj));
		}
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxGridCellEnumRenderer_ctor(int n, string* choices);
		static extern (C) void wxGridCellEnumRenderer_dtor(IntPtr self);
		static extern (C) void wxGridCellEnumRenderer_Draw(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, ref Rectangle rect, int row, int col, bool isSelected);
		static extern (C) void wxGridCellEnumRenderer_GetBestSize(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, int row, int col, out Size size);
		static extern (C) IntPtr wxGridCellEnumRenderer_Clone(IntPtr self);
		static extern (C) void wxGridCellEnumRenderer_SetParameters(IntPtr self, string parameter);
		//! \endcond
		
	alias GridCellEnumRenderer wxGridCellEnumRenderer;
	public class GridCellEnumRenderer : GridCellStringRenderer
	{
		public this()
			{ this(cast(string[])null);}
			
		public this(string[] choices)
			{ this(wxGridCellEnumRenderer_ctor(choices.length, choices.ptr), true);}
				
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
		
		private override void dtor() { wxGridCellEnumRenderer_dtor(wxobj); }
		
		public override void SetParameters(string parameter)
		{
			wxGridCellEnumRenderer_SetParameters(wxobj, parameter);
		}
		
		public override void Draw(Grid grid, GridCellAttr attr, DC dc, Rectangle rect, int row, int col, bool isSelected)
		{
			wxGridCellEnumRenderer_Draw(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), rect, row, col, isSelected);
		}
		
		public override Size GetBestSize(Grid grid, GridCellAttr attr, DC dc, int row, int col)
		{
			Size size;
			wxGridCellEnumRenderer_GetBestSize(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), row, col, size);			
			return size;
		}
		
		public override GridCellRenderer Clone()
		{
//			return cast(GridCellRenderer)FindObject(wxGridCellEnumRenderer_Clone(wxobj), &GridCellRenderer.New);
			return new GridCellEnumRenderer(wxGridCellEnumRenderer_Clone(wxobj));
		}
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxGridCellEnumEditor_ctor(int n, string[] choices);
		static extern (C) void wxGridCellEnumEditor_dtor(IntPtr self);
		static extern (C) void wxGridCellEnumEditor_BeginEdit(IntPtr self, int row, int col, IntPtr grid);
		static extern (C) bool wxGridCellEnumEditor_EndEdit(IntPtr self, int row, int col, IntPtr grid);
		static extern (C) IntPtr wxGridCellEnumEditor_Clone(IntPtr self);
		//! \endcond
		
	alias GridCellEnumEditor wxGridCellEnumEditor;
	public class GridCellEnumEditor : GridCellChoiceEditor
	{
		public this()
			{ this(cast(string[])null);}
		
		public this(string[] choices)
			{ this(wxGridCellEnumEditor_ctor(choices.length, choices), true);}
		
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
				
		private override void dtor() { wxGridCellEnumEditor_dtor(wxobj); }
			
		public override void BeginEdit(int row, int col, Grid grid)
		{
			wxGridCellEnumEditor_BeginEdit(wxobj, row, col, wxObject.SafePtr(grid));
		}
		
		public override bool EndEdit(int row, int col, Grid grid)
		{
			return wxGridCellEnumEditor_EndEdit(wxobj, row, col, wxObject.SafePtr(grid));
		}	

		public override GridCellEditor Clone()
		{
//			return cast(GridCellEditor)FindObject(wxGridCellEnumEditor_Clone(wxobj), &GridCellEditor.New);
			return new GridCellEnumEditor(wxGridCellEnumEditor_Clone(wxobj));
		}
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxGridCellAutoWrapStringEditor_ctor();
		static extern (C) void wxGridCellAutoWrapStringEditor_dtor(IntPtr self);
		static extern (C) void wxGridCellAutoWrapStringEditor_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) void wxGridCellAutoWrapStringEditor_Create(IntPtr self, IntPtr parent, int id, IntPtr evtHandler);
		static extern (C) IntPtr wxGridCellAutoWrapStringEditor_Clone(IntPtr self);
		//! \endcond
		
	alias GridCellAutoWrapStringEditor wxGridCellAutoWrapStringEditor;
	public class GridCellAutoWrapStringEditor : GridCellTextEditor
	{
		public this()
		{
			this(wxGridCellAutoWrapStringEditor_ctor(), true);
			wxGridCellAutoWrapStringEditor_RegisterDisposable(wxobj, &VirtualDispose);
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
		
		override protected void dtor() { wxGridCellAutoWrapStringEditor_dtor(wxobj); }
			
		public override void Create(Window parent, int id, EvtHandler evtHandler)
		{
			wxGridCellAutoWrapStringEditor_Create(wxobj, wxObject.SafePtr(parent), id, wxObject.SafePtr(evtHandler));
		}
		
		public override GridCellEditor Clone()
		{
//			return cast(GridCellEditor)FindObject(wxGridCellAutoWrapStringEditor_Clone(wxobj), &GridCellEditor.New);
			return new GridCellAutoWrapStringEditor(wxGridCellAutoWrapStringEditor_Clone(wxobj));

		}		
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxGridCellAutoWrapStringRenderer_ctor();
		static extern (C) void wxGridCellAutoWrapStringRenderer_dtor(IntPtr self);
		static extern (C) void   wxGridCellAutoWrapStringRenderer_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) void wxGridCellAutoWrapStringRenderer_Draw(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, ref Rectangle rect, int row, int col, bool isSelected);
		static extern (C) void wxGridCellAutoWrapStringRenderer_GetBestSize(IntPtr self, IntPtr grid, IntPtr attr, IntPtr dc, int row, int col, out Size size);
		static extern (C) IntPtr wxGridCellAutoWrapStringRenderer_Clone(IntPtr self);
		//! \endcond
		
	alias GridCellAutoWrapStringRenderer wxGridCellAutoWrapStringRenderer;
	public class GridCellAutoWrapStringRenderer : GridCellStringRenderer
	{
		public this()
		{
			this(wxGridCellAutoWrapStringRenderer_ctor(), true);
			wxGridCellAutoWrapStringRenderer_RegisterDisposable(wxobj, &VirtualDispose);
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
				
		override protected void dtor() { wxGridCellAutoWrapStringRenderer_dtor(wxobj); }
		
		public override void Draw(Grid grid, GridCellAttr attr, DC dc, Rectangle rect, int row, int col, bool isSelected)
		{
			wxGridCellAutoWrapStringRenderer_Draw(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), rect, row, col, isSelected);
		}
		
		public override Size GetBestSize(Grid grid, GridCellAttr attr, DC dc, int row, int col)
		{
			Size size;
			wxGridCellAutoWrapStringRenderer_GetBestSize(wxobj, wxObject.SafePtr(grid), wxObject.SafePtr(attr), wxObject.SafePtr(dc), row, col, size);			
			return size;
		}
		
		public override GridCellRenderer Clone()
		{
		//	return cast(GridCellRenderer)FindObject(wxGridCellAutoWrapStringRenderer_Clone(wxobj), &GridCellRenderer.New);
			return new GridCellAutoWrapStringRenderer(wxGridCellAutoWrapStringRenderer_Clone(wxobj));
		}			
	}
