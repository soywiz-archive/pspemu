//-----------------------------------------------------------------------------
// wxD - Timer.d
// (C) 2006 afb <afb@users.sourceforge.net> (thanks to Matrix for updates)
// 
/// The wxTimer wrapper classes. (Optional, requires timer)
//
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Timer.d,v 1.1 2007/08/21 20:58:44 afb Exp $
//-----------------------------------------------------------------------------

module wx.Timer;
public import wx.common;
public import wx.EvtHandler;

	//---------------------------------------------------------------------------
	// Constants for Timer.Play
	//---------------------------------------------------------------------------
	
	/// generate notifications periodically until the timer is stopped (default)
	const bool wxTIMER_CONTINOUS = false;

	/// only send the notification once and then stop the timer
	const bool wxTIMER_ONE_SHOT = true;

	//-----------------------------------------------------------------------------

		extern (C) {
		alias void function (Timer) Virtual_Notify;
		}
		
		//! \cond EXTERN
		static extern (C) IntPtr wxTimer_ctor();
		static extern (C) IntPtr wxTimer_ctor2(IntPtr owner, int id);
		static extern (C) void   wxTimer_RegisterVirtual(IntPtr self, Timer obj, 
			Virtual_Notify notify);
		static extern (C) IntPtr wxTimer_dtor(IntPtr self);

		static extern (C) int wxTimer_GetInterval(IntPtr self);
		static extern (C) bool wxTimer_IsOneShot(IntPtr self);
		static extern (C) bool wxTimer_IsRunning(IntPtr self);
		static extern (C) void wxTimer_BaseNotify(IntPtr self);
		static extern (C) void wxTimer_SetOwner(IntPtr self, IntPtr owner, int id);
		static extern (C) bool wxTimer_Start(IntPtr self, int milliseconds, bool oneShot);
		static extern (C) void wxTimer_Stop(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias Timer wxTimer;
	public class Timer : EvtHandler
	{

		public this()
			{ this(wxTimer_ctor(), true); }
		
		public this(EvtHandler owner, int id=-1)
			{ this(wxTimer_ctor2(owner.wxobj, id), true); }
		
		public this(IntPtr wxobj) 
		{
			super(wxobj);
			
			wxTimer_RegisterVirtual(wxobj, this, &staticNotify);
		}
		
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
			
			wxTimer_RegisterVirtual(wxobj, this, &staticNotify);
		}

		override protected void dtor() { wxTimer_dtor(wxobj); }
		
		//---------------------------------------------------------------------
		
		static extern(C) private void staticNotify(Timer obj)
		{
			obj.Notify();
		}
		protected /+virtual+/ void Notify()
		{
			wxTimer_BaseNotify(wxobj);
		}

		//---------------------------------------------------------------------
				
		public int Interval()
		{
			return wxTimer_GetInterval(wxobj);
		}
		
		public bool IsOneShot()
		{
			return wxTimer_IsOneShot(wxobj);
		}
		
		public bool IsRunning()
		{
			return wxTimer_IsRunning(wxobj);
		}
		
		public void SetOwner(EvtHandler owner, int id=-1)
		{
			wxTimer_SetOwner(wxobj, owner.wxobj, id);
		}
		
		public bool Start(int milliseconds=-1, bool oneShot=false)
		{
			return wxTimer_Start(wxobj, milliseconds, oneShot);
		}

		public void Stop()
		{
			wxTimer_Stop(wxobj);
		}

	}
