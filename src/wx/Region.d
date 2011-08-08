//-----------------------------------------------------------------------------
// wxD - Region.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Region.cs
//
/// The wxRegion wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
// $Id: Region.d,v 1.10 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.Region;
public import wx.common;
public import wx.GDIObject;
public import wx.Bitmap;
public import wx.Colour;

    public enum RegionContain {
        wxOutRegion = 0,
        wxPartRegion,
        wxInRegion
    }

		//! \cond EXTERN
        static extern (C) IntPtr wxRegion_ctor();
        static extern (C) IntPtr wxRegion_ctorByCoords(int x, int y, int w, int h);
        static extern (C) IntPtr wxRegion_ctorByCorners(ref Point topLeft, ref Point bottomRight);
        static extern (C) IntPtr wxRegion_ctorByRect(ref Rectangle rect);
        static extern (C) IntPtr wxRegion_ctorByPoly(int n, ref Point[] points, int fillStyle);
        static extern (C) IntPtr wxRegion_ctorByBitmap(IntPtr bmp, IntPtr transColour, int tolerance);
        static extern (C) IntPtr wxRegion_ctorByRegion(IntPtr region);

        static extern (C) void   wxRegion_dtor(IntPtr self);

        static extern (C) void   wxRegion_Clear(IntPtr self);
        static extern (C) bool   wxRegion_Offset(IntPtr self, int x, int y);

        static extern (C) bool   wxRegion_Union(IntPtr self, int x, int y, int width, int height);
        static extern (C) bool   wxRegion_UnionRect(IntPtr self, ref Rectangle rect);
        static extern (C) bool   wxRegion_UnionRegion(IntPtr self, IntPtr region);
        static extern (C) bool   wxRegion_UnionBitmap(IntPtr self, IntPtr bmp, IntPtr transColour, int tolerance);

        static extern (C) bool   wxRegion_Intersect(IntPtr self, int x, int y, int width, int height);
        static extern (C) bool   wxRegion_IntersectRect(IntPtr self, ref Rectangle rect);
        static extern (C) bool   wxRegion_IntersectRegion(IntPtr self, IntPtr region);

        static extern (C) bool   wxRegion_Subtract(IntPtr self, int x, int y, int width, int height);
        static extern (C) bool   wxRegion_SubtractRect(IntPtr self, ref Rectangle rect);
        static extern (C) bool   wxRegion_SubtractRegion(IntPtr self, IntPtr region);

        static extern (C) bool   wxRegion_Xor(IntPtr self, int x, int y, int width, int height);
        static extern (C) bool   wxRegion_XorRect(IntPtr self, ref Rectangle rect);
        static extern (C) bool   wxRegion_XorRegion(IntPtr self, IntPtr region);

        static extern (C) RegionContain wxRegion_ContainsCoords(IntPtr self, int x, int y);
        static extern (C) RegionContain wxRegion_ContainsPoint(IntPtr self, ref Point pt);
        static extern (C) RegionContain wxRegion_ContainsRectCoords(IntPtr self, int x, int y, int width, int height);
        static extern (C) RegionContain wxRegion_ContainsRect(IntPtr self, ref Rectangle rect);

        static extern (C) void   wxRegion_GetBox(IntPtr self, ref Rectangle rect);
        static extern (C) bool   wxRegion_IsEmpty(IntPtr self);
        static extern (C) IntPtr wxRegion_ConvertToBitmap(IntPtr self);
		//! \endcond

        //---------------------------------------------------------------------

    alias Region wxRegion;
    public class Region : GDIObject
    {

        public this(IntPtr wxobj) 
            { super(wxobj); }

        public this()
            { this(wxRegion_ctor()); }

        public this(int x, int y, int w, int h)
            { this(wxRegion_ctorByCoords(x, y, w, h)); }

        public this(Point topLeft, Point bottomRight)
            { this(wxRegion_ctorByCorners(topLeft, bottomRight)); }

        public this(Rectangle rect)
            { this(wxRegion_ctorByRect(rect)); }

        version(__WXMAC__) {} else
        public this(Point[] points, int fillStyle)
            { this(wxRegion_ctorByPoly(points.length, points, fillStyle)); }

        public this(Bitmap bmp, Colour transColour, int tolerance)
            { this(wxRegion_ctorByBitmap(wxObject.SafePtr(bmp), wxObject.SafePtr(transColour), tolerance)); }

        public this(Region reg)
            { this(wxRegion_ctorByRegion(wxObject.SafePtr(reg))); }

        //---------------------------------------------------------------------

        public void Clear()
        {
            wxRegion_Clear(wxobj);
        }

        version(__WXMAC__) {} else
        public bool Offset(int x, int y)
        {
            return wxRegion_Offset(wxobj, x, y);
        }

        //---------------------------------------------------------------------

        public bool Union(int x, int y, int width, int height) 
        {
            return wxRegion_Union(wxobj, x, y, width, height);
        }

        public bool Union(Rectangle rect)
        {
            return wxRegion_UnionRect(wxobj, rect);
        }

        public bool Union(Region reg)
        {
            return wxRegion_UnionRegion(wxobj, wxObject.SafePtr(reg));
        }

        public bool Union(Bitmap bmp, Colour transColour, int tolerance)
        {
            return wxRegion_UnionBitmap(wxobj, wxObject.SafePtr(bmp), wxObject.SafePtr(transColour), tolerance);
        }

        //---------------------------------------------------------------------

        public bool Intersect(int x, int y, int width, int height)
        {
            return wxRegion_Intersect(wxobj, x, y, width, height);
        }

        public bool Intersect(Rectangle rect)
        {
            return wxRegion_IntersectRect(wxobj, rect);
        }

        public bool Intersect(Region region)
        {
            return wxRegion_IntersectRegion(wxobj, wxObject.SafePtr(region));
        }

        //---------------------------------------------------------------------

        public bool Subtract(int x, int y, int width, int height)
        {
            return wxRegion_Subtract(wxobj, x, y, width, height);
        }

        public bool Subtract(Rectangle rect)
        {
            return wxRegion_SubtractRect(wxobj, rect);
        }

        public bool Subtract(Region region)
        {
            return wxRegion_SubtractRegion(wxobj, wxObject.SafePtr(region));
        }

        //---------------------------------------------------------------------

        public bool Xor(int x, int y, int width, int height)
        {
            return wxRegion_Xor(wxobj, x, y, width, height);
        }

        public bool Xor(Rectangle rect)
        {
            return wxRegion_XorRect(wxobj, rect);
        }

        public bool Xor(Region region)
        {
            return wxRegion_XorRegion(wxobj, wxObject.SafePtr(region));
        }

        //---------------------------------------------------------------------

        public RegionContain Contains(int x, int y)
        {
            return wxRegion_ContainsCoords(wxobj, x, y);
        }

        public RegionContain Contains(Point pt)
        {
            return wxRegion_ContainsPoint(wxobj, pt);
        }

        public RegionContain Contains(int x, int y, int width, int height)
        {
            return wxRegion_ContainsRectCoords(wxobj, x, y, width, height);
        }

        public RegionContain Contains(Rectangle rect)
        {
            return wxRegion_ContainsRect(wxobj, rect);
        }

        //---------------------------------------------------------------------
        
        public Rectangle GetBox()
        {
            Rectangle rect;
            wxRegion_GetBox(wxobj, rect);
            return rect;
        }

        public bool IsEmpty() { return wxRegion_IsEmpty(wxobj); }

        public Bitmap ConvertToBitmap()
        {
            return new Bitmap(wxRegion_ConvertToBitmap(wxobj));
        }
    }

		//! \cond EXTERN
        static extern (C) IntPtr wxRegionIterator_ctor();
        static extern (C) IntPtr wxRegionIterator_ctorByRegion(IntPtr region);

        static extern (C) void   wxRegionIterator_Reset(IntPtr self);
        static extern (C) void   wxRegionIterator_ResetToRegion(IntPtr self, IntPtr region);

        static extern (C) bool   wxRegionIterator_HaveRects(IntPtr self);
        
        static extern (C) int    wxRegionIterator_GetX(IntPtr self);
        static extern (C) int    wxRegionIterator_GetY(IntPtr self);

        static extern (C) int    wxRegionIterator_GetW(IntPtr self);
        static extern (C) int    wxRegionIterator_GetWidth(IntPtr self);
        static extern (C) int    wxRegionIterator_GetH(IntPtr self);
        static extern (C) int    wxRegionIterator_GetHeight(IntPtr self);

        static extern (C) void   wxRegionIterator_GetRect(IntPtr self, ref Rectangle rect);
		//! \endcond

        //---------------------------------------------------------------------

    alias RegionIterator wxRegionIterator;
    public class RegionIterator : wxObject
    {
        public this(IntPtr wxobj) 
            { super(wxobj); }

        public this()
            { this(wxRegionIterator_ctor()); }

        public this(Region reg)
            { this(wxRegionIterator_ctorByRegion(wxObject.SafePtr(reg))); }

        //---------------------------------------------------------------------

        public void Reset()
        {
            wxRegionIterator_Reset(wxobj);
        }

        public void ResetToRegion(Region region)
        {
            wxRegionIterator_ResetToRegion(wxobj, wxObject.SafePtr(region));
        }

        //---------------------------------------------------------------------

        public bool HaveRects()
        {
            return wxRegionIterator_HaveRects(wxobj);
        }

        //---------------------------------------------------------------------
        
        public int X() { return wxRegionIterator_GetX(wxobj); }

        public int Y() { return wxRegionIterator_GetY(wxobj); }

        //---------------------------------------------------------------------

        public int Width() { return wxRegionIterator_GetWidth(wxobj); }

        public int Height() { return wxRegionIterator_GetHeight(wxobj); }

        //---------------------------------------------------------------------

        public Rectangle Rect() { 
                Rectangle rect;
                wxRegionIterator_GetRect(wxobj, rect);
                return rect;
            }
    }
