//-----------------------------------------------------------------------------
// wxD - Sound.d
// (C) 2006 afb <afb@users.sourceforge.net>
// 
/// The wxSound wrapper classes. (Optional on non-Windows platforms)
//
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Sound.d,v 1.4 2006/11/17 15:21:00 afb Exp $
//-----------------------------------------------------------------------------

module wx.Sound;
public import wx.common;

	//---------------------------------------------------------------------------
	// Constants for Sound.Play
	//---------------------------------------------------------------------------
	
	const uint wxSOUND_SYNC = 0U;
	const uint wxSOUND_ASYNC = 1U;
	const uint wxSOUND_LOOP = 2U;

	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxSound_ctor();
		static extern (C) IntPtr wxSound_ctor2(string fileName, bool isResource);
		static extern (C) IntPtr wxSound_ctor3(int size, ubyte* data);
		static extern (C) IntPtr wxSound_dtor(IntPtr self);

		static extern (C) bool wxSound_Play(IntPtr self, uint flags);
		static extern (C) void wxSound_Stop(IntPtr self);
		static extern (C) bool wxSound_IsOk(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias Sound wxSound;
	public class Sound : wxObject
	{

		public this()
			{ this(wxSound_ctor(), true); }
		
		public this(string fileName, bool isResource=false)
			{ this(wxSound_ctor2(fileName, isResource), true); }
		
		public this(ubyte[] data)
			{ this(wxSound_ctor3(data.length, data.ptr), true); }

		public this(IntPtr wxobj) 
		{
			super(wxobj);
		}
		
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}

		override protected void dtor() { wxSound_dtor(wxobj); }

		//---------------------------------------------------------------------
				
		public bool Play(uint flags=wxSOUND_ASYNC)
		{
			return wxSound_Play(wxobj, flags);
		}

		public void Stop()
		{
			wxSound_Stop(wxobj);
		}
		
		public bool IsOk()
		{
			return wxSound_IsOk(wxobj);
		}
		
		//---------------------------------------------------------------------

	    // Plays sound from filename:
		static bool Play(string filename, uint flags=wxSOUND_ASYNC)
		{
		    Sound snd = new Sound(filename);
		    return snd.IsOk() ? snd.Play(flags) : false;
		}

	}
