//-----------------------------------------------------------------------------
// wxD - Caret.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - Caret.cs
//
/// The wxCaret wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 by Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Caret.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.Caret;
public import wx.common;
public import wx.Window;

		//! \cond EXTERN
		static extern (C) IntPtr wxCaret_ctor();
		static extern (C) void wxCaret_dtor(IntPtr self);
		static extern (C) bool wxCaret_Create(IntPtr self, IntPtr window, int width, int height);
		static extern (C) bool wxCaret_IsOk(IntPtr self);
		static extern (C) bool wxCaret_IsVisible(IntPtr self);
		static extern (C) void wxCaret_GetPosition(IntPtr self, out int x, out int y);
		static extern (C) void wxCaret_GetSize(IntPtr self, out int width, out int height);
		static extern (C) IntPtr wxCaret_GetWindow(IntPtr self);
		static extern (C) void wxCaret_SetSize(IntPtr self, int width, int height);
		static extern (C) void wxCaret_Move(IntPtr self, int x, int y);
		static extern (C) void wxCaret_Show(IntPtr self, bool show);
		static extern (C) void wxCaret_Hide(IntPtr self);
		static extern (C) int wxCaret_GetBlinkTime();
		static extern (C) void wxCaret_SetBlinkTime(int milliseconds);
		//! \endcond
		
		//---------------------------------------------------------------------

	alias Caret wxCaret;
	public class Caret : wxObject
	{
		public this()
			{ this(wxCaret_ctor(), true);}

		public this(IntPtr wxobj)
		{
			super(wxobj);
		}
		
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}

		public this(Window window, Size size)
			{ this(window, size.Width, size.Height);}

		public this(Window window, int width, int height)
		{
			this(wxCaret_ctor(), true);
			if (!wxCaret_Create(wxobj, wxObject.SafePtr(window), width, height))
			{
				throw new InvalidOperationException("Failed to create Caret");
			}
		}
		
		//---------------------------------------------------------------------
				
		override protected void dtor() { wxCaret_dtor(wxobj); }
		
		//---------------------------------------------------------------------

		public bool Create(Window window, int width, int height)
		{
			return wxCaret_Create(wxobj, wxObject.SafePtr(window), width, height);
		}

		//---------------------------------------------------------------------

		public bool IsOk() { return wxCaret_IsOk(wxobj); }

		public bool IsVisible() { return wxCaret_IsVisible(wxobj); }

		//---------------------------------------------------------------------

		public Point Position() 
			{
				Point point;
				wxCaret_GetPosition(wxobj, point.X, point.Y);
				return point;
			}
		public void Position(Point value) 
			{
				wxCaret_Move(wxobj, value.X, value.Y);
			}

		//---------------------------------------------------------------------

		public Size size() 
		{
			Size sz;
			wxCaret_GetSize(wxobj, sz.Width, sz.Height);
			return sz;
		}
		public void size(Size value) 
		{
			wxCaret_SetSize(wxobj, value.Width, value.Height);
		}

		//---------------------------------------------------------------------

		public Window window() 
		{
			return cast(Window)FindObject(wxCaret_GetWindow(wxobj));
		}

		//---------------------------------------------------------------------

		public void Show(bool show)
		{
			wxCaret_Show(wxobj, show);
		}

		public void Hide()
		{
			wxCaret_Hide(wxobj);
		}

		//---------------------------------------------------------------------

		static int BlinkTime()
		{
			return wxCaret_GetBlinkTime();
		}
		static void BlinkTime(int value) 
		{
			wxCaret_SetBlinkTime(value);
		}

		public static wxObject New(IntPtr ptr) { return new Caret(ptr); }
		//---------------------------------------------------------------------
	}

		//! \cond EXTERN
		static extern (C) IntPtr wxCaretSuspend_ctor(IntPtr win);
		static extern (C) void wxCaretSuspend_dtor(IntPtr self);
		//! \endcond
		
		//---------------------------------------------------------------------

	alias CaretSuspend wxCaretSuspend;
	public class CaretSuspend : wxObject
	{
		public this(Window win)
			{ this(wxCaretSuspend_ctor(wxObject.SafePtr(win)), true);}
		
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
				
		override protected void dtor() { wxCaretSuspend_dtor(wxobj); }
	}
