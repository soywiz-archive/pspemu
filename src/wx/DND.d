//-----------------------------------------------------------------------------
// wxD - Dnd.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Dnd.cs
//
/// The wxDND wrapper classes.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 by Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
// 
// $Id: DND.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.DND;
public import wx.common;
public import wx.DataObject;
public import wx.Window;

	public enum Drag
	{
		wxDrag_CopyOnly    = 0,
		wxDrag_AllowMove   = 1,
		wxDrag_DefaultMove = 3
	}
	
	//---------------------------------------------------------------------

	public enum DragResult
	{
    		wxDragError,
    		wxDragNone,
    		wxDragCopy,
    		wxDragMove,
    		wxDragLink,
    		wxDragCancel
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		extern (C) {
		alias int function(DropSource obj, int flags) Virtual_DoDragDrop;
		}

		static extern (C) IntPtr wxDropSource_Win_ctor(IntPtr win);
		static extern (C) IntPtr wxDropSource_DataObject_ctor(IntPtr dataObject, IntPtr win);
		static extern (C) void wxDropSource_dtor(IntPtr self);
		static extern (C) void wxDropSource_RegisterVirtual(IntPtr self, DropSource obj, Virtual_DoDragDrop doDragDrop);
		static extern (C) int wxDropSource_DoDragDrop(IntPtr self, int flags);
		static extern (C) void wxDropSource_SetData(IntPtr self, IntPtr dataObject);
		//! \endcond
		
		//---------------------------------------------------------------------

	alias DropSource wxDropSource;
	public class DropSource : wxObject
	{
		protected DataObject m_dataObject = null;
		
		public this(IntPtr wxobj)
		{
			super(wxobj);
		}		
			
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}
		
		public this(Window win = null)
		{ 
			this(wxDropSource_Win_ctor(wxObject.SafePtr(win)), true);
			m_dataObject = null;
			
			wxDropSource_RegisterVirtual( wxobj, this, &staticDoDoDragDrop );
		}

		public this(DataObject dataObject, Window win = null)
		{
			this(wxDropSource_DataObject_ctor(wxObject.SafePtr(dataObject), wxObject.SafePtr(win)), true);
			m_dataObject = dataObject;

			wxDropSource_RegisterVirtual( wxobj, this, &staticDoDoDragDrop );
		}
		
		//---------------------------------------------------------------------
		override protected void dtor() { wxDropSource_dtor(wxobj); }

		//---------------------------------------------------------------------

		static extern (C) private int staticDoDoDragDrop(DropSource obj,int flags)
		{
			return cast(int)obj.DoDragDrop(flags);
		}

		public /+virtual+/ DragResult DoDragDrop(int flags)
		{
			return cast(DragResult)wxDropSource_DoDragDrop(wxobj, flags);
		}
		
		//---------------------------------------------------------------------
		
		public DataObject dataObject() { return m_dataObject; }
		public void dataObject(DataObject value) { m_dataObject = value; wxDropSource_SetData(wxobj, wxObject.SafePtr(value)); }
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		extern (C) {
		alias int  function(DropTarget obj, int x, int y, int def) Virtual_OnDragOver;
		alias bool function(DropTarget obj, int x, int y) Virtual_OnDrop;
		alias int  function(DropTarget obj, int x, int y, int def) Virtual_OnData3;
		alias bool function(DropTarget obj) Virtual_GetData;
		alias void function(DropTarget obj) Virtual_OnLeave;
		alias int  function(DropTarget obj, int x, int y, int def) Virtual_OnEnter;
		}
		//! \endcond
		
		//---------------------------------------------------------------------
		
		//! \cond EXTERN
		static extern (C) IntPtr wxDropTarget_ctor(IntPtr dataObject);
		static extern (C) void wxDropTarget_dtor(IntPtr self);
		static extern (C) void wxDropTarget_RegisterVirtual(IntPtr self, DropTarget obj, Virtual_OnDragOver onDragOver, Virtual_OnDrop onDrop, Virtual_OnData3 onData, Virtual_GetData getData, Virtual_OnLeave onLeave, Virtual_OnEnter onEnter);  
		static extern (C) void   wxDropTarget_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) void   wxDropTarget_SetDataObject(IntPtr self, IntPtr dataObject);
		static extern (C) int wxDropTarget_OnEnter(IntPtr self, int x, int y, int def);
		static extern (C) int wxDropTarget_OnDragOver(IntPtr self, int x, int y, int def);
		static extern (C) void   wxDropTarget_OnLeave(IntPtr self);
		static extern (C) bool wxDropTarget_OnDrop(IntPtr self, int x, int y);
		static extern (C) bool wxDropTarget_GetData(IntPtr self);
		//! \endcond
		
		//---------------------------------------------------------------------

	public abstract class DropTarget : wxObject
	{
		protected DataObject m_dataObject = null;
		
		public this(DataObject dataObject = null)
		{ 
			this(wxDropTarget_ctor(wxObject.SafePtr(dataObject)), true);
			m_dataObject = dataObject;

			wxDropTarget_RegisterVirtual( wxobj, this,
				&staticDoOnDragOver,
				&staticOnDrop,
				&staticDoOnData,
				&staticGetData,
				&staticOnLeave,
				&staticDoOnEnter);
				
			wxDropTarget_RegisterDisposable(wxobj, &VirtualDispose);
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
		
		override protected void dtor() { wxDropTarget_dtor(wxobj); }
		
		//---------------------------------------------------------------------

		static extern (C) private int staticDoOnDragOver(DropTarget obj, int x, int y, int def)
		{
			return cast(int)obj.OnDragOver(x, y, cast(DragResult)def);
		}
		public /+virtual+/ DragResult OnDragOver(int x, int y, DragResult def)
		{
			return cast(DragResult)wxDropTarget_OnDragOver(wxobj, x, y, cast(int)def);
		}
		
		//---------------------------------------------------------------------

		static extern (C) private bool staticOnDrop(DropTarget obj, int x, int y)
		{
			return obj.OnDrop(x,y);
		}
		public /+virtual+/ bool OnDrop(int x, int y)
		{
			return wxDropTarget_OnDrop(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------

		static extern (C) private int staticDoOnData(DropTarget obj, int x, int y, int def)
		{
			return cast(int)obj.OnData(x, y, cast(DragResult) def);
		}
		public abstract DragResult OnData(int x, int y, DragResult def);
		
		//---------------------------------------------------------------------

		static extern (C) private bool staticGetData(DropTarget obj)
		{
			return obj.GetData();
		}
		public /+virtual+/ bool GetData()
		{
			return wxDropTarget_GetData(wxobj);
		}
		
		//---------------------------------------------------------------------

		static extern (C) private int staticDoOnEnter(DropTarget obj, int x, int y, int def)
		{
			return cast(int)obj.OnEnter(x, y, cast(DragResult) def);
		}
		public /+virtual+/ DragResult OnEnter(int x, int y, DragResult def)
		{
			return cast(DragResult)wxDropTarget_OnEnter(wxobj, x, y, cast(int)def);
		}
		
		//---------------------------------------------------------------------

		static extern (C) private void staticOnLeave(DropTarget obj)
		{
			return obj.OnLeave();
		}
		public /+virtual+/ void OnLeave()
		{
			wxDropTarget_OnLeave(wxobj);
		}
		
		//---------------------------------------------------------------------

		public DataObject dataObject() { return m_dataObject; }
		public void dataObject(DataObject value) { m_dataObject = value; wxDropTarget_SetDataObject(wxobj, wxObject.SafePtr(value)); }

	//	public static wxObject New(IntPtr ptr) { return new DropTarget(ptr); }
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) bool wxTextDropTarget_OnDrop(IntPtr self, int x, int y);
		static extern (C) bool wxTextDropTarget_GetData(IntPtr self);
		//! \endcond

		//---------------------------------------------------------------------

	public abstract class TextDropTarget : DropTarget
	{
		public this()
			{ super(new TextDataObject());}
			
		public abstract bool OnDropText(int x, int y, string text);

		//---------------------------------------------------------------------

		public override DragResult OnData(int x, int y, DragResult def)
		{
			if (!GetData())
				return DragResult.wxDragNone;
				
			TextDataObject dobj = cast(TextDataObject)m_dataObject;
		
			return OnDropText(x, y, dobj.Text) ? def : DragResult.wxDragNone;
		}

		//---------------------------------------------------------------------
        
		public override bool OnDrop(int x, int y)
		{
			return wxTextDropTarget_OnDrop(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------

		public override bool GetData()
		{
			return wxTextDropTarget_GetData(wxobj);
		}
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) bool wxFileDropTarget_OnDrop(IntPtr self, int x, int y);
		static extern (C) bool wxFileDropTarget_GetData(IntPtr self);
		//! \endcond

		//---------------------------------------------------------------------

	public abstract class FileDropTarget : DropTarget
	{
		public this()
			{ super(new FileDataObject());}
 
		public abstract bool OnDropFiles(int x, int y, string[] filenames);
		
		//---------------------------------------------------------------------

		public override DragResult OnData(int x, int y, DragResult def)
		{
			if ( !GetData() )
				return DragResult.wxDragNone;
				
			FileDataObject dobj = cast(FileDataObject)m_dataObject;
			
			return OnDropFiles(x, y, dobj.Filenames) ? def : DragResult.wxDragNone;
		}

		//---------------------------------------------------------------------
                
		public override bool OnDrop(int x, int y)
		{
			return wxFileDropTarget_OnDrop(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------

		public override bool GetData()
		{
			return wxFileDropTarget_GetData(wxobj);
		}
	}

