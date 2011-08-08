//-----------------------------------------------------------------------------
// wxD - Thread.d
// (C) 2006 afb <afb@users.sourceforge.net>
// 
/// The wxThread wrapper classes. (Optional, requires threads)
//
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Thread.d,v 1.1 2007/08/21 20:58:44 afb Exp $
//-----------------------------------------------------------------------------

module wx.Thread;
public import wx.common;

// ----------------------------------------------------------------------------
// constants
// ----------------------------------------------------------------------------

enum wxMutexError
{
    wxMUTEX_NO_ERROR = 0,   // operation completed successfully
    wxMUTEX_INVALID,        // mutex hasn't been initialized
    wxMUTEX_DEAD_LOCK,      // mutex is already locked by the calling thread
    wxMUTEX_BUSY,           // mutex is already locked by another thread
    wxMUTEX_UNLOCKED,       // attempt to unlock a mutex which is not locked
    wxMUTEX_MISC_ERROR      // any other error
}

enum wxCondError
{
    wxCOND_NO_ERROR = 0,
    wxCOND_INVALID,
    wxCOND_TIMEOUT,         // WaitTimeout() has timed out
    wxCOND_MISC_ERROR
}

enum wxSemaError
{
    wxSEMA_NO_ERROR = 0,
    wxSEMA_INVALID,         // semaphore hasn't been initialized successfully
    wxSEMA_BUSY,            // returned by TryWait() if Wait() would block
    wxSEMA_TIMEOUT,         // returned by WaitTimeout()
    wxSEMA_OVERFLOW,        // Post() would increase counter past the max
    wxSEMA_MISC_ERROR
}

enum wxThreadError
{
    wxTHREAD_NO_ERROR = 0,      // No error
    wxTHREAD_NO_RESOURCE,       // No resource left to create a new thread
    wxTHREAD_RUNNING,           // The thread is already running
    wxTHREAD_NOT_RUNNING,       // The thread isn't running
    wxTHREAD_KILLED,            // Thread we waited for had to be killed
    wxTHREAD_MISC_ERROR         // Some other error
}

enum wxThreadKind
{
    wxTHREAD_DETACHED,
    wxTHREAD_JOINABLE
}

// defines the interval of priority
enum
{
    WXTHREAD_MIN_PRIORITY      = 0u,
    WXTHREAD_DEFAULT_PRIORITY  = 50u,
    WXTHREAD_MAX_PRIORITY      = 100u
}

// There are 2 types of mutexes: normal mutexes and recursive ones. The attempt
// to lock a normal mutex by a thread which already owns it results in
// undefined behaviour (it always works under Windows, it will almost always
// result in a deadlock under Unix). Locking a recursive mutex in such
// situation always succeeds and it must be unlocked as many times as it has
// been locked.
//
// However recursive mutexes have several important drawbacks: first, in the
// POSIX implementation, they're less efficient. Second, and more importantly,
// they CAN NOT BE USED WITH CONDITION VARIABLES under Unix! Using them with
// wxCondition will work under Windows and some Unices (notably Linux) but will
// deadlock under other Unix versions (e.g. Solaris). As it might be difficult
// to ensure that a recursive mutex is not used with wxCondition, it is a good
// idea to avoid using recursive mutexes at all. Also, the last problem with
// them is that some (older) Unix versions don't support this at all -- which
// results in a configure warning when building and a deadlock when using them.
enum wxMutexType
{
    // normal mutex: try to always use this one
    wxMUTEX_DEFAULT,

    // recursive mutex: don't use these ones with wxCondition
    wxMUTEX_RECURSIVE
}

	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxMutex_ctor(int mutexType);
		static extern (C) void wxMutex_dtor(IntPtr self);
		static extern (C) bool wxMutex_IsOk(IntPtr self);
		//! \endcond

		//-----------------------------------------------------------------------------

	alias Mutex wxMutex;
//! A mutex object is a synchronization object whose state is set to signaled
//! when it is not owned by any thread, and nonsignaled when it is owned. Its
//! name comes from its usefulness in coordinating mutually-exclusive access to
//! a shared resource. Only one thread at a time can own a mutex object.
	public class Mutex : wxObject
	{
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
		
		public bool IsOk()
		{
			return wxMutex_IsOk(wxobj);
		}

		override protected void dtor() { wxMutex_dtor(wxobj); }
	}

	alias MutexLocker wxMutexLocker;
	public class MutexLocker : wxObject
	{
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
	}

		//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxCriticalSection_ctor(int mutexType);
		static extern (C) void wxCriticalSection_dtor(IntPtr self);
		static extern (C) void wxCriticalSection_Enter(IntPtr self);
		static extern (C) void wxCriticalSection_Leave(IntPtr self);
		//! \endcond

	alias CriticalSection wxCriticalSection;
//! Critical section: this is the same as mutex but is only visible to the
//! threads of the same process. For the platforms which don't have native
//! support for critical sections, they're implemented entirely in terms of
//! mutexes.
	public class CriticalSection : wxObject
	{
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
		
		public void Enter()
		{
			wxCriticalSection_Enter(wxobj);
		}

		public void Leave()
		{
			wxCriticalSection_Leave(wxobj);
		}

		override protected void dtor() { wxCriticalSection_dtor(wxobj); }
	}

	alias CriticalSectionLocker wxCriticalSectionLocker;
	public class CriticalSectionLocker : wxObject
	{
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
	}

		//-----------------------------------------------------------------------------

	alias Condition wxCondition;
//! wxCondition models a POSIX condition variable which allows one (or more)
//! thread(s) to wait until some condition is fulfilled
	public class Condition : wxObject
	{
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
	}

		//-----------------------------------------------------------------------------

	alias Semaphore wxSemaphore;
//! wxSemaphore: a counter limiting the number of threads concurrently accessing
//!              a shared resource
	public class Semaphore : wxObject
	{
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
	}

		//-----------------------------------------------------------------------------

	alias Thread wxThread;
//! wxThread: class encapsulating a thread of execution
	public class Thread : wxObject
	{
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
	}

	alias ThreadHelperThread wxThreadHelperThread;
	public class ThreadHelperThread : wxObject
	{
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
	}

	alias ThreadHelper wxThreadHelper;
//! wxThreadHelper: this class implements the threading logic to run a
//! background task in another object (such as a window).  It is a mix-in: just
//! derive from it to implement a threading background task in your class.
	public class ThreadHelper : wxObject
	{
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
	}

