//-----------------------------------------------------------------------------
// wxD - SizeEvent.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - SizeEvent.cs
//
/// The wxSizeEvent wrapper class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: SizeEvent.d,v 1.10 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.SizeEvent;
public import wx.common;
public import wx.Event;

		//! \cond EXTERN
		static extern (C) IntPtr wxSizeEvent_ctor();
		static extern (C) IntPtr wxSizeEvent_ctorSize(ref Size sz,int winid);
		static extern (C) IntPtr wxSizeEvent_ctorRect(ref Rect sz,int winid);
		static extern (C) void wxSizeEvent_GetSize(IntPtr self, out Size size);
		static extern (C) void wxSizeEvent_GetRect(IntPtr self, out Rect rect);
		static extern (C) void wxSizeEvent_SetRect(IntPtr self, ref Rect rect);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias SizeEvent wxSizeEvent;
	public class SizeEvent : Event
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ this(wxSizeEvent_ctor()); }

		public this(Size sz,int winid = 0)
			{ this(wxSizeEvent_ctorSize(sz,winid)); }

		public this(Rectangle rect,int winid = 0)
			{ this(wxSizeEvent_ctorRect(rect,winid)); }


		//-----------------------------------------------------------------------------	
		
		public Size size()
			{
				Size size;
				wxSizeEvent_GetSize(wxobj, size);
				return size;
			}

		public Rectangle rect()
			{
				Rectangle rect;
				wxSizeEvent_GetRect(wxobj, rect);
				return rect;
			}

		public void rect(Rectangle rect)
			{
				wxSizeEvent_SetRect(wxobj, rect);
			}


		private static Event New(IntPtr obj) { return new SizeEvent(obj); }

		static this()
		{
			AddEventType(wxEVT_SIZE,                            &SizeEvent.New);
		}
	}
