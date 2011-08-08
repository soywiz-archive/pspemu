//-----------------------------------------------------------------------------
// wxD - Utils.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Utils.cs
//
/// Common Utils wrapper classes.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2003 Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Utils.d,v 1.11 2010/10/11 09:43:05 afb Exp $
//-----------------------------------------------------------------------------

module wx.Utils;
public import wx.common;
public import wx.Window;

		//! \cond EXTERN
		static extern (C) IntPtr wxGlobal_GetHomeDir();
		static extern (C) IntPtr wxGlobal_GetCwd();
		static extern (C) void wxSleep_func(int num);
		static extern (C) void wxMilliSleep_func(uint num);
		static extern (C) void wxMicroSleep_func(uint num);
		static extern (C) void wxYield_func();
		static extern (C) void wxBeginBusyCursor_func();
		static extern (C) void wxEndBusyCursor_func();
		static extern (C) void wxMutexGuiEnter_func();
		static extern (C) void wxMutexGuiLeave_func();
		//! \endcond
		
		
		public static string GetHomeDir()
		{
			return cast(string) new wxString(wxGlobal_GetHomeDir(), true);
		}
		
		public static string GetCwd()
		{
			return cast(string) new wxString(wxGlobal_GetCwd(), true);
		}
		
		//---------------------------------------------------------------------

		public static void wxSleep(int num)
		{
			wxSleep_func(num);
		}

		public static void wxMilliSleep(int num)
		{
			wxMilliSleep_func(num);
		}

		public static void wxMicroSleep(int num)
		{
			wxMicroSleep_func(num);
		}
		
		//---------------------------------------------------------------------

		public static void wxYield()
		{
			wxYield_func();
		}
		
		//---------------------------------------------------------------------

		public static void BeginBusyCursor()
		{
			wxBeginBusyCursor_func();
		}

		public static void EndBusyCursor()
		{
			wxEndBusyCursor_func();
		}
		
		//---------------------------------------------------------------------
		
		public static void MutexGuiEnter()
		{
			wxMutexGuiEnter_func();
		}
		
		public static void MutexGuiLeave()
		{
			wxMutexGuiLeave_func();
		}
		
			
	//---------------------------------------------------------------------

	alias BusyCursor wxBusyCursor;
	public class BusyCursor : IDisposable
	{
		private bool disposed = false;
		public this()
		{
			BeginBusyCursor();
		}
	
		~this()
		{
			Dispose();
		}
	
		public void Dispose()
		{
			if (!disposed) {
				disposed = true;
				EndBusyCursor();
			}
		}
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxWindowDisabler_ctor(IntPtr winToSkip);
		static extern (C) void wxWindowDisabler_dtor(IntPtr self);
		//! \endcond
		
	alias WindowDisabler wxWindowDisabler;
	public class WindowDisabler : wxObject
	{
		//---------------------------------------------------------------------

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
			{ this(cast(Window)null);}

		public this(Window winToSkip)
			{ this(wxWindowDisabler_ctor(wxObject.SafePtr(winToSkip)), true);}
			
		//---------------------------------------------------------------------
		
		override protected void dtor() { wxWindowDisabler_dtor(wxobj); }
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxBusyInfo_ctor(string message, IntPtr parent);
		static extern (C) void   wxBusyInfo_dtor(IntPtr self);
		//! \endcond
		
	alias BusyInfo wxBusyInfo;
	public class BusyInfo : wxObject
	{
		//---------------------------------------------------------------------
	
		public this(IntPtr wxobj)
		{
			super(wxobj);
		}
	
		public this(string message)
			{ this(message, null);}
	
		public this(string message, Window parent)
			{ this(wxBusyInfo_ctor(message, wxObject.SafePtr(parent)), true);}
			
		private this(IntPtr wxobj, bool memOwn)
		{
			super(wxobj);
			this.memOwn = memOwn;
		}
		
		//---------------------------------------------------------------------

		override protected void dtor() { wxBusyInfo_dtor(wxobj); }
	}
	
	//---------------------------------------------------------------------
