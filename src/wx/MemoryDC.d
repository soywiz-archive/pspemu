//-----------------------------------------------------------------------------
// wxD - MemoryDC.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - MemoryDC.cs
//
/// The wxBufferedDC and wxMemoryDC wrapper classes.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 by Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: MemoryDC.d,v 1.10 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.MemoryDC;
public import wx.common;
public import wx.DC;

		//! \cond EXTERN
		static extern (C) IntPtr wxMemoryDC_ctor();
		static extern (C) IntPtr wxMemoryDC_ctorByDC(IntPtr dc);
		static extern (C) void   wxMemoryDC_SelectObject(IntPtr self, IntPtr bitmap);
		//! \endcond

		//---------------------------------------------------------------------

	alias MemoryDC wxMemoryDC;
	public class MemoryDC : WindowDC
	{
        public this(IntPtr wxobj) 
            { super(wxobj); }

        public this()
            { this(wxMemoryDC_ctor()); }

        public this(DC dc)
            { this(wxMemoryDC_ctorByDC(wxObject.SafePtr(dc))); }

		//---------------------------------------------------------------------

        public void SelectObject(Bitmap bitmap)
        {
            wxMemoryDC_SelectObject(wxobj, wxObject.SafePtr(bitmap));
        }

		//---------------------------------------------------------------------
	}

		//! \cond EXTERN
		static extern (C) IntPtr wxBufferedDC_ctor();
		static extern (C) IntPtr wxBufferedDC_ctorByBitmap(IntPtr dc, IntPtr buffer);
		static extern (C) IntPtr wxBufferedDC_ctorBySize(IntPtr dc, ref Size area);
		
		static extern (C) void   wxBufferedDC_InitByBitmap(IntPtr self, IntPtr dc, IntPtr bitmap);
		static extern (C) void   wxBufferedDC_InitBySize(IntPtr self, IntPtr dc, ref Size area);
		static extern (C) void   wxBufferedDC_UnMask(IntPtr self);
		//! \endcond

		//---------------------------------------------------------------------

	alias BufferedDC wxBufferedDC;
	public class BufferedDC : MemoryDC
	{
        public this(IntPtr wxobj) 
            { super(wxobj); }

 		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}

        public this()
            { this(wxBufferedDC_ctor(), true); }

        public this(DC dc, Bitmap bitmap) 
            { this(wxBufferedDC_ctorByBitmap(wxObject.SafePtr(dc), wxObject.SafePtr(bitmap)), true); }

        public this(DC dc, Size size)
            { this(wxBufferedDC_ctorBySize(wxObject.SafePtr(dc), size), true); }

		//---------------------------------------------------------------------

		public void InitByBitmap(DC dc, Bitmap bitmap)
        {
            wxBufferedDC_InitByBitmap(wxobj, wxObject.SafePtr(dc), wxObject.SafePtr(bitmap));
        }

		public void InitBySize(DC dc, Size area)
        {
            wxBufferedDC_InitBySize(wxobj, wxObject.SafePtr(dc), area);
        }

		//---------------------------------------------------------------------

        public void UnMask()
        {
            wxBufferedDC_UnMask(wxobj);
        }

		//---------------------------------------------------------------------
	}

		//! \cond EXTERN
		static extern (C) IntPtr wxBufferedPaintDC_ctor(IntPtr window, IntPtr buffer);
		//! \endcond

		//---------------------------------------------------------------------
        
	alias BufferedPaintDC wxBufferedPaintDC;
	public class BufferedPaintDC : BufferedDC
	{
        public this(IntPtr wxobj) 
            { super(wxobj); }

 		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}

       public this(Window window, Bitmap buffer)
            { this(wxBufferedPaintDC_ctor(wxObject.SafePtr(window), wxObject.SafePtr(buffer)), true); }

		//---------------------------------------------------------------------
	}

