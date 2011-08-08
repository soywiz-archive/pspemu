//-----------------------------------------------------------------------------
// wxD - ClientData.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - ClientData.cs
//
/// The wxClientData wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: ClientData.d,v 1.10 2007/01/28 23:06:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.ClientData;
public import wx.common;

		//! \cond EXTERN
		static extern (C) IntPtr wxClientData_ctor();
		static extern (C) void wxClientData_dtor(IntPtr self);
		static extern (C) void wxClientData_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		//! \endcond
		
		//---------------------------------------------------------------------
        
	alias ClientData wxClientData;
	public class ClientData : wxObject
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
			this(wxClientData_ctor(), true);
			wxClientData_RegisterDisposable(wxobj, &VirtualDispose);
		}
			
		//---------------------------------------------------------------------
				
		override protected void dtor() { wxClientData_dtor(wxobj); }

		static wxObject New(IntPtr ptr) { return new ClientData(ptr); }
	}
    
	//---------------------------------------------------------------------
    
		//! \cond EXTERN
		static extern (C) IntPtr wxStringClientData_ctor(string data);
		static extern (C) void   wxStringClientData_dtor(IntPtr self);
		static extern (C) void   wxStringClientData_SetData(IntPtr self, string data);
		static extern (C) IntPtr wxStringClientData_GetData(IntPtr self);
		//! \endcond
		
		//---------------------------------------------------------------------
        
	alias StringClientData wxStringClientData;
	public class StringClientData : ClientData
	{
		public this()
			{ this(wxStringClientData_ctor(""), true); }
			
		public this(string data)
			{ this(wxStringClientData_ctor(data), true); }
			
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
				
		override protected void dtor() { wxStringClientData_dtor(wxobj); }
		//---------------------------------------------------------------------
		
		public string Data() { return cast(string) new wxString(wxStringClientData_GetData(wxobj), true); }
		public void Data(string value) { wxStringClientData_SetData(wxobj, value); }
	}

