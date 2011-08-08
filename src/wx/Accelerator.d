//-----------------------------------------------------------------------------
// wxD - Accelerator.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - Accelerator.cs
//
/// The wxAcceleratorEntry and wxAcceleratorTable wrapper classes
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Accelerator.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.Accelerator;
public import wx.common;
public import wx.MenuItem;

		//! \cond EXTERN
		static extern (C) IntPtr wxAcceleratorEntry_ctor(int flags, int keyCode, int cmd, IntPtr item);
		static extern (C) void   wxAcceleratorEntry_dtor(IntPtr self);
		static extern (C) void   wxAcceleratorEntry_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) void   wxAcceleratorEntry_Set(IntPtr self, int flags, int keyCode, int cmd, IntPtr item);
		static extern (C) void   wxAcceleratorEntry_SetMenuItem(IntPtr self, IntPtr item);
		static extern (C) int    wxAcceleratorEntry_GetFlags(IntPtr self);
		static extern (C) int    wxAcceleratorEntry_GetKeyCode(IntPtr self);
		static extern (C) int    wxAcceleratorEntry_GetCommand(IntPtr self);
		static extern (C) IntPtr wxAcceleratorEntry_GetMenuItem(IntPtr self);
		
		static extern (C) IntPtr wxAcceleratorEntry_GetAccelFromString(string label);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias AcceleratorEntry wxAcceleratorEntry;
	public class AcceleratorEntry : wxObject
	{
		public const int wxACCEL_NORMAL	= 0x0000;
		public const int wxACCEL_ALT	= 0x0001;
		public const int wxACCEL_CTRL	= 0x0002;
		public const int wxACCEL_SHIFT	= 0x0004;
		
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
			{ this(0, 0, 0, null);}
		
		public this(int flags)
			{ this(flags, 0, 0, null);}
			
		public this(int flags, int keyCode)
			{ this(flags, keyCode, 0, null);}
			
		public this(int flags, int keyCode, int cmd)
			{ this(flags, keyCode, cmd, null);}
			
		public this(int flags, int keyCode, int cmd, MenuItem item)
		{
			this(wxAcceleratorEntry_ctor(flags, keyCode, cmd, wxObject.SafePtr(item)), true);
			wxAcceleratorEntry_RegisterDisposable(wxobj, &VirtualDispose);
		}
		
		//-----------------------------------------------------------------------------
		
		public void Set(int flags, int keyCode, int cmd)
		{
			Set(flags, keyCode, cmd);
		}
		
		public void Set(int flags, int keyCode, int cmd, MenuItem item)
		{
			wxAcceleratorEntry_Set(wxobj, flags, keyCode, cmd, wxObject.SafePtr(item));
		}
		
		//-----------------------------------------------------------------------------
		
		public MenuItem menuItem() { return cast(MenuItem)FindObject(wxAcceleratorEntry_GetMenuItem(wxobj), &MenuItem.New2); }		
		//-----------------------------------------------------------------------------
		
		public int Flags() { return wxAcceleratorEntry_GetFlags(wxobj); }		
		//-----------------------------------------------------------------------------
		
		public int KeyCode() { return wxAcceleratorEntry_GetKeyCode(wxobj); }		
		//-----------------------------------------------------------------------------
		
		public int Command() { return wxAcceleratorEntry_GetCommand(wxobj); }		
		//---------------------------------------------------------------------
		
		override protected void dtor() { wxAcceleratorEntry_dtor(wxobj); }

		//---------------------------------------------------------------------
		
		public static AcceleratorEntry GetAccelFromString(string label)
		{
			return cast(AcceleratorEntry)FindObject(wxAcceleratorEntry_GetAccelFromString(label), &AcceleratorEntry.New);
		}
		
		public static wxObject New(IntPtr ptr) { return new AcceleratorEntry(ptr);}
	}
	
	//-----------------------------------------------------------------------------
	
		//! \cond EXTERN
		static extern (C) IntPtr wxAcceleratorTable_ctor();
		static extern (C) bool   wxAcceleratorTable_Ok(IntPtr self);
		//static extern (C) void   wxAcceleratorTable_Add(IntPtr self, IntPtr entry);
		//static extern (C) void   wxAcceleratorTable_Remove(IntPtr self, IntPtr entry);
		//static extern (C) IntPtr wxAcceleratorTable_GetMenuItem(IntPtr self, IntPtr evt);
		//static extern (C) int    wxAcceleratorTable_GetCommand(IntPtr self, IntPtr evt);
		//static extern (C) IntPtr wxAcceleratorTable_GetEntry(IntPtr self, IntPtr evt);
		//! \endcond

		//-----------------------------------------------------------------------------

	alias AcceleratorTable wxAcceleratorTable;
	public class AcceleratorTable : wxObject
	{
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this()
			{ this(wxAcceleratorTable_ctor());}
			
		//! \cond VERSION
		version(__WXMAC__) {} else {
		//! \endcond
		//-----------------------------------------------------------------------------

		/*public void Add(AcceleratorEntry entry)
		{
			wxAcceleratorTable_Add(wxobj, wxObject.SafePtr(entry));
		}*/

		//-----------------------------------------------------------------------------

		/*public void Remove(AcceleratorEntry entry)
		{
			wxAcceleratorTable_Remove(wxobj, wxObject.SafePtr(entry));
		}*/

		//-----------------------------------------------------------------------------

		/*public MenuItem GetMenuItem(KeyEvent evt)
		{
			return cast(MenuItem)FindObject(wxAcceleratorTable_GetMenuItem(wxobj, wxObject.SafePtr(evt)),&MenuItem.New);
		}*/

		//-----------------------------------------------------------------------------

		/*public AcceleratorEntry GetEntry(KeyEvent evt)
		{
			return cast(AcceleratorEntry)FindObject(wxAcceleratorTable_GetEntry(wxobj, wxObject.SafePtr(evt)),&AcceleratorEntry.New);
		}*/
		//! \cond VERSION
		} // version(__WXMAC__)
		//! \endcond

		//-----------------------------------------------------------------------------

		/*public int GetCommand(KeyEvent evt)
		{
			return wxAcceleratorTable_GetCommand(wxobj, wxObject.SafePtr(evt));
		}*/

		//-----------------------------------------------------------------------------

		public bool Ok() { return wxAcceleratorTable_Ok(wxobj); }

		public static wxObject New(IntPtr ptr) { return new AcceleratorTable(ptr); }
	}

