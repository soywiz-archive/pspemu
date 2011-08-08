//-----------------------------------------------------------------------------
// wxD - SizerItem.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - SizerItem.cs
//
/// The wxSizerItem wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: SizerItem.d,v 1.9 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.SizerItem;
public import wx.common;
public import wx.Window;

		//! \cond EXTERN
        static extern (C) IntPtr wxSizerItem_ctorSpace(int width, int height, int proportion, int flag, int border, IntPtr userData);
        static extern (C) IntPtr wxSizerItem_ctorWindow(IntPtr window, int proportion, int flag, int border, IntPtr userData);
        static extern (C) IntPtr wxSizerItem_ctorSizer(IntPtr sizer, int proportion, int flag, int border, IntPtr userData);
        static extern (C) IntPtr wxSizerItem_ctor();
        static extern (C) void   wxSizerItem_DeleteWindows(IntPtr self);
        static extern (C) void   wxSizerItem_DetachSizer(IntPtr self);
        static extern (C) void   wxSizerItem_GetSize(IntPtr self, ref Size size);
        static extern (C) void   wxSizerItem_CalcMin(IntPtr self, ref Size min);
        static extern (C) void   wxSizerItem_SetDimension(IntPtr self, ref Point pos, ref Size size);
        static extern (C) void   wxSizerItem_GetMinSize(IntPtr self, ref Size size);
        static extern (C) void   wxSizerItem_SetInitSize(IntPtr self, int x, int y);
        static extern (C) void   wxSizerItem_SetRatio(IntPtr self, int width, int height);
        static extern (C) void   wxSizerItem_SetRatioFloat(IntPtr self, float ratio);
        static extern (C) float  wxSizerItem_GetRatioFloat(IntPtr self);
        static extern (C) bool   wxSizerItem_IsWindow(IntPtr self);
        static extern (C) bool   wxSizerItem_IsSizer(IntPtr self);
        static extern (C) bool   wxSizerItem_IsSpacer(IntPtr self);
        static extern (C) void   wxSizerItem_SetProportion(IntPtr self, int proportion);
        static extern (C) int    wxSizerItem_GetProportion(IntPtr self);
        static extern (C) void   wxSizerItem_SetFlag(IntPtr self, int flag);
        static extern (C) int    wxSizerItem_GetFlag(IntPtr self);
        static extern (C) void   wxSizerItem_SetBorder(IntPtr self, int border);
        static extern (C) int    wxSizerItem_GetBorder(IntPtr self);
        static extern (C) IntPtr wxSizerItem_GetWindow(IntPtr self);
        static extern (C) void   wxSizerItem_SetWindow(IntPtr self, IntPtr window);
        static extern (C) IntPtr wxSizerItem_GetSizer(IntPtr self);
        static extern (C) void   wxSizerItem_SetSizer(IntPtr self, IntPtr sizer);
        static extern (C) void   wxSizerItem_GetSpacer(IntPtr self, ref Size size);
        static extern (C) void   wxSizerItem_SetSpacer(IntPtr self, ref Size size);
        static extern (C) void   wxSizerItem_Show(IntPtr self, bool show);
        static extern (C) bool   wxSizerItem_IsShown(IntPtr self);
        static extern (C) IntPtr wxSizerItem_GetUserData(IntPtr self);
        static extern (C) void   wxSizerItem_GetPosition(IntPtr self, ref Point pos);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias SizerItem wxSizerItem;
    public class SizerItem : wxObject
    {
        public this(int width, int height, int proportion, int flag, int border, wxObject userData)
            { this(wxSizerItem_ctorSpace(width, height, proportion, flag, border, wxObject.SafePtr(userData))); }

        public this(Window window, int proportion, int flag, int border, wxObject userData)
            { this(wxSizerItem_ctorWindow(wxObject.SafePtr(window), proportion, flag, border, wxObject.SafePtr(userData))); }

        public this(Sizer sizer, int proportion, int flag, int border, wxObject userData)
            { this(wxSizerItem_ctorSizer(wxObject.SafePtr(sizer), proportion, flag, border, wxObject.SafePtr(userData))); }

        public this()
            { this(wxSizerItem_ctor()); }

        public this(IntPtr wxobj)
            { super(wxobj); }

        //-----------------------------------------------------------------------------

        public void DeleteWindows()
        {
            wxSizerItem_DeleteWindows(wxobj);
        }

        public void DetachSizer()
        {
            wxSizerItem_DetachSizer(wxobj);
        }

        //-----------------------------------------------------------------------------

        public Size size() { 
                Size size;
                wxSizerItem_GetSize(wxobj, size);
                return size; 
            }

        //-----------------------------------------------------------------------------

        public Size CalcMin()
        { 
            Size min;
            wxSizerItem_CalcMin(wxobj, min);
            return min;
        }

        //-----------------------------------------------------------------------------

        public void SetDimension(Point pos, Size size)
        {
            wxSizerItem_SetDimension(wxobj, pos, size);
        }

        //-----------------------------------------------------------------------------

        public Size MinSize() { 
                Size size;
                wxSizerItem_GetMinSize(wxobj, size);
                return size;
            }

        //-----------------------------------------------------------------------------

        public void SetInitSize(int x, int y)
        {
            wxSizerItem_SetInitSize(wxobj, x, y);
        }

        //-----------------------------------------------------------------------------

        public void SetRatio(Size size)
            { SetRatio(size.Width, size.Height); }
       
        public void SetRatio(int width, int height)
        {
            wxSizerItem_SetRatio(wxobj, width, height);
        }

        public void Ratio(float value) { wxSizerItem_SetRatioFloat(wxobj, value); }
        public float Ratio() { return wxSizerItem_GetRatioFloat(wxobj); }

        //-----------------------------------------------------------------------------

        public bool IsWindow() { return wxSizerItem_IsWindow(wxobj); }

        public bool IsSizer() { return wxSizerItem_IsSizer(wxobj); }

        public bool IsSpacer() { return wxSizerItem_IsSpacer(wxobj); }

        //-----------------------------------------------------------------------------

        public void Proportion(int value) { wxSizerItem_SetProportion(wxobj, value); }
        public int Proportion() { return wxSizerItem_GetProportion(wxobj); }

        //-----------------------------------------------------------------------------

        public void Flag(int value) { wxSizerItem_SetFlag(wxobj, value); }
        public int Flag() { return wxSizerItem_GetFlag(wxobj); }

        //-----------------------------------------------------------------------------

        public void Border(int value) { wxSizerItem_SetBorder(wxobj, value); }
        public int Border() { return wxSizerItem_GetBorder(wxobj); }

        //-----------------------------------------------------------------------------

        public Window window() { return cast(Window)FindObject(wxSizerItem_GetWindow(wxobj)); }
        public void window(Window value) { wxSizerItem_SetWindow(wxobj, wxObject.SafePtr(value)); }

        //-----------------------------------------------------------------------------

        public Sizer sizer() { return cast(Sizer)FindObject(wxSizerItem_GetSizer(wxobj)); }
        public void sizer(Sizer value) { wxSizerItem_SetSizer(wxobj, wxObject.SafePtr(value)); }

        //-----------------------------------------------------------------------------

        public Size Spacer() { 
                Size spacer;
                wxSizerItem_GetSpacer(wxobj, spacer);
                return spacer;
            }
        public void Spacer(Size value) { wxSizerItem_SetSpacer(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void Show(bool show)
        {
            wxSizerItem_Show(wxobj, show);
        }

        public bool IsShown() { return wxSizerItem_IsShown(wxobj); }

        //-----------------------------------------------------------------------------

        public wxObject UserData() { return FindObject(wxSizerItem_GetUserData(wxobj)); }

        //-----------------------------------------------------------------------------

        public Point Position() {
                Point pos;
                wxSizerItem_GetPosition(wxobj, pos);
                return pos;
            }
    }

