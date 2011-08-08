//-----------------------------------------------------------------------------
// wxD - TipWindow.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - tipwin.h
//
/// The wxTipWindow wrapper class
//
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: TipWindow.d,v 1.10 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.TipWindow;
public import wx.common;
public import wx.Window;

		//! \cond EXTERN
        static extern (C) IntPtr wxTipWindow_ctor(IntPtr parent, string text, int maxLength, Rectangle* rectBound);
        //static extern (C) IntPtr wxTipWindow_ctorNoRect(IntPtr parent, string text, int maxLength);
        //static extern (C) void   wxTipWindow_SetTipWindowPtr(IntPtr self, IntPtr wxTipWindow* windowPtr);
        static extern (C) void   wxTipWindow_SetBoundingRect(IntPtr self, ref Rectangle rectBound);
        static extern (C) void   wxTipWindow_Close(IntPtr self);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias TipWindow wxTipWindow;
    public class TipWindow : Window
    {
        public this(IntPtr wxobj)
            { super(wxobj); }

        public this(Window parent, string text, int maxLength = 100)
            { this(wxTipWindow_ctor(wxObject.SafePtr(parent), text, maxLength,null)); }

        public this(Window parent, string text, int maxLength, Rectangle rectBound)
            { this(wxTipWindow_ctor(wxObject.SafePtr(parent), text, maxLength, &rectBound)); }

        //-----------------------------------------------------------------------------

        /*public void SetTipWindowPtr( TipWindow* windowPtr)
        {
            wxTipWindow_SetTipWindowPtr(wxobj, wxObject.SafePtr(TipWindow* windowPtr));
        }*/

        //-----------------------------------------------------------------------------

        public void BoundingRect(Rectangle value) { wxTipWindow_SetBoundingRect(wxobj, value); }
    }
