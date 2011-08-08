//-----------------------------------------------------------------------------
// wxD - MiniFrame.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - MiniFrame.cs
//
/// The wxMiniFrame wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: MiniFrame.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.MiniFrame;
public import wx.common;
public import wx.Frame;

		//! \cond EXTERN
        static extern (C) IntPtr wxMiniFrame_ctor();
        static extern (C) bool   wxMiniFrame_Create(IntPtr self, IntPtr parent, int id, string title, ref Point pos, ref Size size, uint style, string name);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias MiniFrame wxMiniFrame;
    public class MiniFrame : Frame
    {
        enum { wxDEFAULT_MINIFRAME_STYLE = wxCAPTION | wxCLIP_CHILDREN | wxRESIZE_BORDER }
    
        public this(IntPtr wxobj) 
            { super(wxobj); }

        public this()
            { this(wxMiniFrame_ctor()); }

        public this(Window parent, int id, string title, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=wxDEFAULT_MINIFRAME_STYLE, string name=wxFrameNameStr)
        {
        	this();
            if (!Create(parent, id, title, pos, size, style, name))
            {
                throw new InvalidOperationException("Could not create MiniFrame");
            }
        }
	
	//---------------------------------------------------------------------
		// ctors with self created id
	
        public this(Window parent, string title, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=wxDEFAULT_MINIFRAME_STYLE, string name=wxFrameNameStr)
	    { this(parent, Window.UniqueID, title, pos, size, style, name);}
	
	//-----------------------------------------------------------------------------

        public override bool Create(Window parent, int id, string title, ref Point pos, ref Size size, int style, string name)
        {
            return wxMiniFrame_Create(wxobj, wxObject.SafePtr(parent), id, title, pos, size, style, name);
        }

        //-----------------------------------------------------------------------------

        // Helper constructors

        public this(string title, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=wxDEFAULT_MINIFRAME_STYLE)
            { this(null, -1, title, pos, size, style); }

        //-----------------------------------------------------------------------------
    }

