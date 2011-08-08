//------------------------------------------------------------------------
// wxD - Display.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Display.cs
//
/// The wxDisplay wrapper class
//
// Michael S. Muegel mike _at_ muegel dot org
//
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// TODO:
//    + Memory management review
//
// wxWidgets-based quirks of note:
//    + Display resolution did not change on my Fedora1 test system
//      under both wxWidgets display sample and my port.
//    + IsPrimary is wrong, at least on WIN32: assumes display #0
//      is primary, which may not be the case. For example, I have
//      three horizontally aligned displays. wxWidgets numbers them
//      0, 1, 2. But it's #1 is actually the primary, not 0. Note also
//      that the numbering scheme differs from how windows numbers
//      them, which has more to do with the display adapter used. This
//      is not an issue really, but something to be aware of should
//      you be expecting them to match.
//------------------------------------------------------------------------

module wx.Display;
public import wx.common;

public import wx.VideoMode;
public import wx.Window;

//version(LDC) { pragma(ldc, "verbose") }

		//! \cond EXTERN
		static extern (C) IntPtr wxDisplay_ctor(int index);
		//static extern (C) IntPtr wxDisplay_ctor(ref VideoMode mode);
		static extern (C) int wxDisplay_GetCount();
		static extern (C) int wxDisplay_GetFromPoint(ref Point pt);
		static extern (C) int wxDisplay_GetFromWindow(IntPtr window);
		static extern (C) void wxDisplay_GetGeometry(IntPtr self, out Rectangle rect);
		static extern (C) IntPtr wxDisplay_GetName(IntPtr self);
		static extern (C) bool wxDisplay_IsPrimary(IntPtr self);
		static extern (C) void wxDisplay_GetCurrentMode(IntPtr self, out VideoMode mode);
		static extern (C) bool wxDisplay_ChangeMode(IntPtr self, VideoMode mode);


		static extern (C) int wxDisplay_GetNumModes(IntPtr self, VideoMode mode);
		static extern (C) void wxDisplay_GetModes(IntPtr self, VideoMode mode, ref VideoMode[] modes);

		
		static extern (C) void wxDisplay_ResetMode(IntPtr self);
		static extern (C) void wxDisplay_dtor(IntPtr self);
		//! \endcond

	alias Display wxDisplay;
	public class Display : wxObject
	{
		//------------------------------------------------------------------------

		// Symbolic constant used by all Find()-like functions returning positive
		// integer on success as failure indicator. While this is global in
		// wxWidgets it makes more sense to be in each class that uses it??? 
		// Or maybe move it to Window.cs.
		public const int wxNOT_FOUND = -1;
		
		//------------------------------------------------------------------------
		
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
			
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}

		//------------------------------------------------------------------------

		public this(int index)
			{ this(wxDisplay_ctor(index), true); }

		//------------------------------------------------------------------------

		//public this(VideoMode mode)
		//	{ this(wxDisplay_ctor(mode), true); }
			
		//---------------------------------------------------------------------

		override protected void dtor() { wxDisplay_dtor(wxobj); }

		//------------------------------------------------------------------------
		static int Count() { return wxDisplay_GetCount(); }

		// an array of all Displays indexed by display number
		public static Display[] GetDisplays()
		{
			int count = Count;
			Display[] displays = new Display[count];
			for (int i = 0; i < count; i++)
			{
				displays[i] = new Display(i);
			}
			return displays;
		}

		//------------------------------------------------------------------------
		// An array of available VideoModes for this display.
		/+virtual+/ public VideoMode[] GetModes()
		{
			return GetModes(VideoMode(0,0,0,0));
		}

		// An array of the VideoModes that match mode. A match occurs when
		// the resolution and depth matches and the refresh frequency in 
		// equal to or greater than mode.RefreshFrequency.
		/+virtual+/ public VideoMode[] GetModes(VideoMode mode)
		{
			int num_modes = wxDisplay_GetNumModes(wxobj, mode);
			VideoMode[] modes = new VideoMode[num_modes];
			wxDisplay_GetModes(wxobj, mode, modes);
			return modes;
		}


		//------------------------------------------------------------------------

		public static int GetFromPoint(Point pt)
		{
			return wxDisplay_GetFromPoint(pt);
		}

		//------------------------------------------------------------------------

		/+virtual+/ public int GetFromWindow(Window window)
		{
			version(__WXMSW__){
				return wxDisplay_GetFromWindow(wxObject.SafePtr(window));
			} else {
				throw new Exception("Display.GetFromWindow is only available on WIN32");
			} // version(__WXMSW__)
		}

		//------------------------------------------------------------------------

		/+virtual+/ public Rectangle Geometry()
		{
			Rectangle rect;
			wxDisplay_GetGeometry(wxobj, rect);
			return rect;
		}

		//------------------------------------------------------------------------

		/+virtual+/ public string Name()
		{
			return cast(string) new wxString(wxDisplay_GetName(wxobj), true);
		}

		//------------------------------------------------------------------------

		/+virtual+/ public bool IsPrimary()
		{
			return wxDisplay_IsPrimary(wxobj);
		}

		//------------------------------------------------------------------------


		/+virtual+/ public VideoMode CurrentMode()
		{
			VideoMode mode;
			wxDisplay_GetCurrentMode(wxobj, mode);
			return mode;
		}

		//------------------------------------------------------------------------

		/+virtual+/ public bool ChangeMode(VideoMode mode)
		{
			return wxDisplay_ChangeMode(wxobj, mode);
		}

		//------------------------------------------------------------------------

		/+virtual+/ public void ResetMode()
		{
			wxDisplay_ResetMode(wxobj);
		}

		//------------------------------------------------------------------------

	}

