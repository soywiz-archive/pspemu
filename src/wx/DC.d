//-----------------------------------------------------------------------------
// wxD - DC.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - DC.cs
//
/// The wxDC wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: DC.d,v 1.11 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------


module wx.DC;
public import wx.common;
public import wx.Window;
public import wx.Pen;
public import wx.Brush;
public import wx.ArrayInt;

		//! \cond EXTERN
		static extern (C) void   wxDC_dtor(IntPtr self);
		static extern (C) void   wxDC_DrawBitmap(IntPtr self, IntPtr bmp, int x, int y, bool transparent);
		static extern (C) void   wxDC_DrawPolygon(IntPtr self, int n, Point* points, int xoffset, int yoffset, int fill_style);
		static extern (C) void   wxDC_DrawLine(IntPtr self, int x1, int y1, int x2, int y2);
		static extern (C) void   wxDC_DrawRectangle(IntPtr self, int x1, int y1, int x2, int y2);
		static extern (C) void   wxDC_DrawText(IntPtr self, string text, int x, int y);
		static extern (C) void   wxDC_DrawEllipse(IntPtr self, int x, int y, int width, int height);
		static extern (C) void   wxDC_DrawPoint(IntPtr self, int x, int y);
		static extern (C) void   wxDC_DrawRoundedRectangle(IntPtr self, int x, int y, int width, int height, double radius);
	
		static extern (C) void   wxDC_SetBackgroundMode(IntPtr self, FillStyle mode);
	
		static extern (C) void   wxDC_SetTextBackground(IntPtr self, IntPtr colour);
		static extern (C) IntPtr wxDC_GetTextBackground(IntPtr self);
	
		static extern (C) void   wxDC_SetBrush(IntPtr self, IntPtr brush);
		static extern (C) IntPtr wxDC_GetBrush(IntPtr self);
	
		static extern (C) void   wxDC_SetBackground(IntPtr self, IntPtr brush);
		static extern (C) IntPtr wxDC_GetBackground(IntPtr self);
	
		static extern (C) void   wxDC_SetPen(IntPtr self, IntPtr pen);
		static extern (C) IntPtr wxDC_GetPen(IntPtr self);
	
		static extern (C) void   wxDC_SetTextForeground(IntPtr self, IntPtr colour);
		static extern (C) IntPtr wxDC_GetTextForeground(IntPtr self);
	
		static extern (C) void   wxDC_SetFont(IntPtr self, IntPtr font);
		static extern (C) IntPtr wxDC_GetFont(IntPtr self);
	
		static extern (C) void   wxDC_GetTextExtent(IntPtr self, string str, out int x, out int y, out int descent, out int externalLeading, IntPtr theFont);
		static extern (C) void   wxDC_Clear(IntPtr self);
	
		static extern (C) void   wxDC_DestroyClippingRegion(IntPtr self);
		static extern (C) void   wxDC_SetClippingRegion(IntPtr self, int x, int y, int width, int height);
		static extern (C) void   wxDC_SetClippingRegionPos(IntPtr self, ref Point pos, ref Size size);
		static extern (C) void   wxDC_SetClippingRegionRect(IntPtr self, ref Rectangle rect);
		static extern (C) void   wxDC_SetClippingRegionReg(IntPtr self, IntPtr reg);
	
		static extern (C) int    wxDC_GetLogicalFunction(IntPtr self);
		static extern (C) void   wxDC_SetLogicalFunction(IntPtr self, int func);
	
		static extern (C) bool   wxDC_BeginDrawing(IntPtr self);
		static extern (C) bool   wxDC_Blit(IntPtr self, int xdest, int ydest, int width, int height, IntPtr source, int xsrc, int ysrc, int rop, bool useMask, int xsrcMask, int ysrcMask);
		static extern (C) void   wxDC_EndDrawing(IntPtr self);
		
		static extern (C) bool   wxDC_FloodFill(IntPtr self, int x, int y, IntPtr col, int style);
		
		static extern (C) bool   wxDC_GetPixel(IntPtr self, int x, int y, IntPtr col);
		
		static extern (C) void   wxDC_CrossHair(IntPtr self, int x, int y);
		
		static extern (C) void   wxDC_DrawArc(IntPtr self, int x1, int y1, int x2, int y2, int xc, int yc);
		
		static extern (C) void   wxDC_DrawCheckMark(IntPtr self, int x, int y, int width, int height);
		
		static extern (C) void   wxDC_DrawEllipticArc(IntPtr self, int x, int y, int w, int h, double sa, double ea);
		
		static extern (C) void   wxDC_DrawLines(IntPtr self, int n, Point* points, int xoffset, int yoffset);
		
		static extern (C) void   wxDC_DrawCircle(IntPtr self, int x, int y, int radius);
		
		static extern (C) void   wxDC_DrawIcon(IntPtr self, IntPtr icon, int x, int y);
		
		static extern (C) void   wxDC_DrawRotatedText(IntPtr self, string text, int x, int y, double angle);
		
		static extern (C) void   wxDC_DrawLabel(IntPtr self, string text, IntPtr image, ref Rectangle rect, int alignment, int indexAccel, ref Rectangle rectBounding);
		static extern (C) void   wxDC_DrawLabel2(IntPtr self, string text, ref Rectangle rect, int alignment, int indexAccel);
		
		static extern (C) void   wxDC_DrawSpline(IntPtr self, int x1, int y1, int x2, int y2, int x3, int y3);
		static extern (C) void   wxDC_DrawSpline2(IntPtr self, int n, Point* points);
		
		static extern (C) bool   wxDC_StartDoc(IntPtr self, string message);
		static extern (C) void   wxDC_EndDoc(IntPtr self);
		static extern (C) void   wxDC_StartPage(IntPtr self);
		static extern (C) void   wxDC_EndPage(IntPtr self);
		
		static extern (C) void   wxDC_GetClippingBox(IntPtr self, out int x, out int y, out int w, out int h);
		static extern (C) void   wxDC_GetClippingBox2(IntPtr self, out Rectangle rect);
		
		static extern (C) void   wxDC_GetMultiLineTextExtent(IntPtr self, string text, out int width, out int height, out int heightline, IntPtr font);
		
		static extern (C) bool   wxDC_GetPartialTextExtents(IntPtr self, string text, IntPtr widths);
		
		static extern (C) void   wxDC_GetSize(IntPtr self, out int width, out int height);
		static extern (C) void   wxDC_GetSize2(IntPtr self, ref Size size);
		static extern (C) void   wxDC_GetSizeMM(IntPtr self, out int width, out int height);
		static extern (C) void   wxDC_GetSizeMM2(IntPtr self, ref Size size);
		
		static extern (C) int    wxDC_DeviceToLogicalX(IntPtr self, int x);
		static extern (C) int    wxDC_DeviceToLogicalY(IntPtr self, int y);
		static extern (C) int    wxDC_DeviceToLogicalXRel(IntPtr self, int x);
		static extern (C) int    wxDC_DeviceToLogicalYRel(IntPtr self, int y);
		static extern (C) int    wxDC_LogicalToDeviceX(IntPtr self, int x);
		static extern (C) int    wxDC_LogicalToDeviceY(IntPtr self, int y);
		static extern (C) int    wxDC_LogicalToDeviceXRel(IntPtr self, int x);
		static extern (C) int    wxDC_LogicalToDeviceYRel(IntPtr self, int y);
		
		static extern (C) bool   wxDC_Ok(IntPtr self);
		
		static extern (C) int    wxDC_GetBackgroundMode(IntPtr self);
		
		static extern (C) int    wxDC_GetMapMode(IntPtr self);
		static extern (C) void   wxDC_SetMapMode(IntPtr self, int mode);
		
		static extern (C) void   wxDC_GetUserScale(IntPtr self, out double x, out double y);
		static extern (C) void   wxDC_SetUserScale(IntPtr self, double x, double y);
		
		static extern (C) void   wxDC_GetLogicalScale(IntPtr self, out double x, out double y);
		static extern (C) void   wxDC_SetLogicalScale(IntPtr self, double x, double y);
		
		static extern (C) void   wxDC_GetLogicalOrigin(IntPtr self, out int x, out int y);
		static extern (C) void   wxDC_GetLogicalOrigin2(IntPtr self, ref Point pt);
		static extern (C) void   wxDC_SetLogicalOrigin(IntPtr self, int x, int y);
		
		static extern (C) void   wxDC_GetDeviceOrigin(IntPtr self, out int x, out int y);
		static extern (C) void   wxDC_GetDeviceOrigin2(IntPtr self, ref Point pt);
		static extern (C) void   wxDC_SetDeviceOrigin(IntPtr self, int x, int y);
		
		static extern (C) void   wxDC_SetAxisOrientation(IntPtr self, bool xLeftRight, bool yBottomUp);
		
		static extern (C) void   wxDC_CalcBoundingBox(IntPtr self, int x, int y);
		static extern (C) void   wxDC_ResetBoundingBox(IntPtr self);
		
		static extern (C) int    wxDC_MinX(IntPtr self);
		static extern (C) int    wxDC_MaxX(IntPtr self);
		static extern (C) int    wxDC_MinY(IntPtr self);
		static extern (C) int    wxDC_MaxY(IntPtr self);
		//! \endcond

	alias DC wxDC;
	public class DC : wxObject
	{
		//---------------------------------------------------------------------

		public this(IntPtr wxobj) 
			{ super(wxobj);}

		override protected void dtor() { wxDC_dtor(wxobj); }

		//---------------------------------------------------------------------

		public void BackgroundMode(FillStyle value) { wxDC_SetBackgroundMode(wxobj, value); }
		public FillStyle BackgroundMode() { return cast(FillStyle)wxDC_GetBackgroundMode(wxobj); }

		//---------------------------------------------------------------------

		public void brush(Brush value) { wxDC_SetBrush(wxobj, wxObject.SafePtr(value)); }
		public Brush brush() { return new Brush(wxDC_GetBrush(wxobj)); }

		public void Background(Brush value) { wxDC_SetBackground(wxobj, wxObject.SafePtr(value)); }
		public Brush Background() { return new Brush(wxDC_GetBackground(wxobj)); }

		//---------------------------------------------------------------------

		public void DrawBitmap(Bitmap bmp, int x, int y, bool useMask)
		{
			wxDC_DrawBitmap(wxobj, wxObject.SafePtr(bmp), x, y, useMask);
		}
		
		public void DrawBitmap(Bitmap bmp, int x, int y)
		{
			DrawBitmap(bmp, x, y, false);
		}
		
		public void DrawBitmap(Bitmap bmp, Point pt, bool useMask)
		{
			DrawBitmap(bmp, pt.X, pt.Y, useMask);
		}
		
		public void DrawBitmap(Bitmap bmp, Point pt)
		{
			DrawBitmap(bmp, pt.X, pt.Y, false);
		}

		//---------------------------------------------------------------------

		public void DrawEllipse(int x, int y, int width, int height)
		{
			wxDC_DrawEllipse(wxobj, x, y, width, height);
		}
		
		public void DrawEllipse(Point pt, Size sz)
		{
			DrawEllipse(pt.X, pt.Y, sz.Width, sz.Height);
		}
		
		public void DrawEllipse(Rectangle rect)
		{
			DrawEllipse(rect.X, rect.Y, rect.Width, rect.Height);
		}

		//---------------------------------------------------------------------

		public void DrawPoint(int x, int y)
		{
			wxDC_DrawPoint(wxobj, x, y);
		}
		
		public void DrawPoint(Point pt)
		{
			DrawPoint(pt.X, pt.Y);
		}

		//---------------------------------------------------------------------

		public void DrawLine(Point p1, Point p2)
		{ 
			DrawLine(p1.X, p1.Y, p2.X, p2.Y); 
		}

		public void DrawLine(int x1, int y1, int x2, int y2)
		{
			wxDC_DrawLine(wxobj, x1, y1, x2, y2);
		}

		//---------------------------------------------------------------------

		public void DrawPolygon(Point[] points)
		{ 
			DrawPolygon(points.length, points, 0, 0, FillStyle.wxODDEVEN_RULE); 
		}
		
		public void DrawPolygon(Point[] points, int xoffset, int yoffset)
		{ 
			DrawPolygon(points.length, points, xoffset, yoffset, FillStyle.wxODDEVEN_RULE); 
		}
		
		public void DrawPolygon(Point[] points, int xoffset, int yoffset, FillStyle fill_style)
		{ 
			DrawPolygon(points.length, points, xoffset, yoffset, fill_style); 
		}

		public void DrawPolygon(int n, Point[] points)
		{ 
			DrawPolygon(n, points, 0, 0, FillStyle.wxODDEVEN_RULE); 
		}
		
		public void DrawPolygon(int n, Point[] points, int xoffset, int yoffset)
		{ 
			DrawPolygon(n, points, xoffset, yoffset, FillStyle.wxODDEVEN_RULE); 
		}
		
		public void DrawPolygon(int n, Point[] points, int xoffset, int yoffset, FillStyle fill_style)
		{
			wxDC_DrawPolygon(wxobj, n, points.ptr, xoffset, yoffset, cast(int)fill_style);
		}

		//---------------------------------------------------------------------

		public void DrawRectangle(int x1, int y1, int x2, int y2)
		{
			wxDC_DrawRectangle(wxobj, x1, y1, x2, y2);
		}
		
		public void DrawRectangle(Point pt, Size sz)
		{
			DrawRectangle(pt.X, pt.Y, sz.Width, sz.Height);
		} 

		public void DrawRectangle(Rectangle rect)
		{
			wxDC_DrawRectangle(wxobj, rect.X, rect.Y, rect.Width, rect.Height);
		}

		//---------------------------------------------------------------------

		public void DrawText(string text, int x, int y)
		{
			wxDC_DrawText(wxobj, text, x, y);
		}

		public void DrawText(string text, Point pos)
		{
			wxDC_DrawText(wxobj, text, pos.X, pos.Y);
		}
		
		//---------------------------------------------------------------------

		public void DrawRoundedRectangle(int x, int y, int width, int height, double radius)
		{
			wxDC_DrawRoundedRectangle(wxobj, x, y, width, height, radius);
		}
		
		public void DrawRoundedRectangle(Point pt, Size sz, double radius)
		{
			DrawRoundedRectangle(pt.X, pt.Y, sz.Width, sz.Height, radius);
		}
		
		public void DrawRoundedRectangle(Rectangle r, double radius)
		{
			DrawRoundedRectangle(r.X, r.Y, r.Width, r.Height, radius);
		}

		//---------------------------------------------------------------------

		public void pen(Pen value) { wxDC_SetPen(wxobj, value.wxobj); }
		public Pen pen() { return cast(Pen)FindObject(wxDC_GetPen(wxobj), &Pen.New); }

		//---------------------------------------------------------------------

		public Colour TextForeground() { return cast(Colour)FindObject(wxDC_GetTextForeground(wxobj), &Colour.New); }
		public void TextForeground(Colour value) { wxDC_SetTextForeground(wxobj, wxObject.SafePtr(value)); }

		public Colour TextBackground() { return cast(Colour)FindObject(wxDC_GetTextBackground(wxobj), &Colour.New); }
		public void TextBackground(Colour value) { wxDC_SetTextBackground(wxobj, wxObject.SafePtr(value)); }

		//---------------------------------------------------------------------

		public Font font() { return cast(Font)FindObject(wxDC_GetFont(wxobj), &Font.New); }
		public void font(Font value) { wxDC_SetFont(wxobj, wxObject.SafePtr(value)); }
		
		//---------------------------------------------------------------------

		public /+virtual+/ void Clear()
		{
			wxDC_Clear(wxobj);
		}

		//---------------------------------------------------------------------

		public void GetTextExtent(string str, out int x, out int y)
		{ 
			// Ignoring these parameters
			int descent;
			int externalLeading;

			GetTextExtent(str, x, y, descent, externalLeading, null); 
		}

		public void GetTextExtent(string str, out int x, out int y, out int descent, out int externalLeading, Font theFont)
		{
			wxDC_GetTextExtent(wxobj, str, x, y, descent, externalLeading, wxObject.SafePtr(theFont));
		}

		//---------------------------------------------------------------------

		public void DestroyClippingRegion()
		{
			wxDC_DestroyClippingRegion(wxobj);
		}

		//---------------------------------------------------------------------

		public void SetClippingRegion(int x, int y, int width, int height)
		{
			wxDC_SetClippingRegion(wxobj, x, y, width, height);
		}

		public void SetClippingRegion(Point pos, Size size)
		{
			wxDC_SetClippingRegionPos(wxobj, pos, size);
		}

		public void SetClippingRegion(Rectangle rect)
		{
			wxDC_SetClippingRegionRect(wxobj, rect);
		}

		public void SetClippingRegion(Region reg)
		{
			wxDC_SetClippingRegionReg(wxobj, wxObject.SafePtr(reg));
		}

		//---------------------------------------------------------------------

		public Logic LogicalFunction() { return cast(Logic)wxDC_GetLogicalFunction(wxobj); }
		public void LogicalFunction(Logic value) { wxDC_SetLogicalFunction(wxobj, cast(int)value); }

		//---------------------------------------------------------------------

		public void BeginDrawing()
		{
			wxDC_BeginDrawing(wxobj);
		}

		//---------------------------------------------------------------------

		public bool Blit(int xdest, int ydest, int width, int height, DC source, int xsrc, int ysrc, int rop, bool useMask, int xsrcMask, int ysrcMask)
		{
			return wxDC_Blit(wxobj, xdest, ydest, width, height, wxObject.SafePtr(source), xsrc, ysrc, rop, useMask, xsrcMask, ysrcMask);
		}
		
		public bool Blit(int xdest, int ydest, int width, int height, DC source) 
		{ 
			return Blit(xdest, ydest, width, height, source, 0, 0, cast(int) Logic.wxCOPY, false, -1, -1); 
		}
		
		public bool Blit(int xdest, int ydest, int width, int height, DC source, int xsrc, int ysrc)
		{
			return Blit(xdest, ydest, width, height, source, xsrc, ysrc, cast(int)Logic.wxCOPY, false, -1, -1);
		}
		
		public bool Blit(int xdest, int ydest, int width, int height, DC source, int xsrc, int ysrc, int rop)
		{
			return Blit(xdest, ydest, width, height, source, xsrc, ysrc, rop, false, -1, -1);
		}
		
		public bool Blit(int xdest, int ydest, int width, int height, DC source, int xsrc, int ysrc, int rop, bool useMask)
		{
			return Blit(xdest, ydest, width, height, source, xsrc, ysrc, rop, useMask, -1, -1);
		}
		
		public bool Blit(int xdest, int ydest, int width, int height, DC source, int xsrc, int ysrc, int rop, bool useMask, int xsrcMask)
		{
			return Blit(xdest, ydest, width, height, source, xsrc, ysrc, rop, useMask, xsrcMask, -1);
		}
		
		public bool Blit(Point destPt, Size sz, DC source, Point srcPt, int rop, bool useMask, Point srcPtMask)
		{
			return Blit(destPt.X, destPt.Y, sz.Width, sz.Height, source, srcPt.X, srcPt.Y, rop, useMask, srcPtMask.X, srcPtMask.Y);
		}
		
		public bool Blit(Point destPt, Size sz, DC source, Point srcPt)
		{
			return Blit(destPt.X, destPt.Y, sz.Width, sz.Height, source, srcPt.X, srcPt.Y, cast(int)Logic.wxCOPY, false, -1, -1);
		}
		
		public bool Blit(Point destPt, Size sz, DC source, Point srcPt, int rop)
		{
			return Blit(destPt.X, destPt.Y, sz.Width, sz.Height, source, srcPt.X, srcPt.Y, rop, false, -1, -1);
		}
		
		public bool Blit(Point destPt, Size sz, DC source, Point srcPt, int rop, bool useMask)
		{
			return Blit(destPt.X, destPt.Y, sz.Width, sz.Height, source, srcPt.X, srcPt.Y, rop, useMask, -1, -1);
		}

		//---------------------------------------------------------------------

		public void EndDrawing()
		{
			wxDC_EndDrawing(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public bool FloodFill(int x, int y, Colour col)
		{
			return FloodFill(x, y, col, FloodStyle.wxFLOOD_SURFACE);
		}
		
		public bool FloodFill(int x, int y, Colour col, int style)
		{
			return wxDC_FloodFill(wxobj, x, y, wxObject.SafePtr(col), style);
		}
		
		public bool FloodFill(Point pt, Colour col)
		{
			return FloodFill(pt, col, FloodStyle.wxFLOOD_SURFACE);
		}
		
		public bool FloodFill(Point pt, Colour col, int style)
		{
			return FloodFill(pt.X, pt.Y, col, style);
		}
		
		//---------------------------------------------------------------------
		
		public bool GetPixel(int x, int y, Colour col)
		{
			return wxDC_GetPixel(wxobj, x, y, wxObject.SafePtr(col));
		}
		
		public bool GetPixel(Point pt, Colour col)
		{
			return GetPixel(pt.X, pt.Y, col);
		}
		
		//---------------------------------------------------------------------
		
		public void CrossHair(int x, int y)
		{
			wxDC_CrossHair(wxobj, x, y);
		}
		
		public void CrossHair(Point pt)
		{
			CrossHair(pt.X, pt.Y);
		}
		
		//---------------------------------------------------------------------
		
		public void DrawArc(int x1, int y1, int x2, int y2, int xc, int yc)
		{
			wxDC_DrawArc(wxobj, x1, y1, x2, y2, xc, yc);
		}
		
		public void DrawArc(Point pt1, Point pt2, Point centre)
		{
			DrawArc(pt1.X, pt1.Y, pt2.X, pt2.Y, centre.X, centre.Y);
		}
		
		//---------------------------------------------------------------------
		
		public void DrawCheckMark(int x, int y, int width, int height)
		{
			wxDC_DrawCheckMark(wxobj, x, y, width, height);
		}
		
		public void DrawCheckMark(Rectangle rect)
		{
			DrawCheckMark(rect.X, rect.Y, rect.Width, rect.Height);
		}
		
		//---------------------------------------------------------------------
		
		public void DrawEllipticArc(int x, int y, int w, int h, double sa, double ea)
		{
			wxDC_DrawEllipticArc(wxobj, x, y, w, h, sa, ea);
		}
		
		public void DrawEllipticArc(Point pt, Size sz, double sa, double ea)
		{
			DrawEllipticArc(pt.X, pt.Y, sz.Width, sz.Height, sa, ea);
		}
		
		//---------------------------------------------------------------------
		
		public void DrawLines(Point[] points, int xoffset, int yoffset)
		{
			wxDC_DrawLines(wxobj, points.length, points.ptr, xoffset, yoffset);
		}
		
		public void DrawLines(Point[] points)
		{
			DrawLines(points, 0, 0);
		}
		
		public void DrawLines(Point[] points, int xoffset)
		{
			DrawLines(points, xoffset, 0);
		}
		
		//---------------------------------------------------------------------
		
		public void DrawCircle(int x, int y, int radius)
		{
			wxDC_DrawCircle(wxobj, x, y, radius);
		}
		
		public void DrawCircle(Point pt, int radius)
		{
			DrawCircle(pt.X, pt.Y, radius);
		}
		
		//---------------------------------------------------------------------
		
		public void DrawIcon(Icon icon, int x, int y)
		{
			wxDC_DrawIcon(wxobj, wxObject.SafePtr(icon), x, y);
		}
		
		public void DrawIcon(Icon icon, Point pt)
		{
			DrawIcon(icon, pt.X, pt.Y);
		}
		
		//---------------------------------------------------------------------
		
		public void DrawRotatedText(string text, int x, int y, double angle)
		{
			wxDC_DrawRotatedText(wxobj, text, x, y, angle);
		}
		
		public void DrawRotatedText(string text, Point pt, double angle)
		{
			DrawRotatedText(text, pt.X, pt.Y, angle);
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ void DrawLabel(string text, Bitmap image, Rectangle rect, int alignment, int indexAccel, ref Rectangle rectBounding)
		{
			wxDC_DrawLabel(wxobj, text, wxObject.SafePtr(image), rect, alignment, indexAccel, rectBounding);
		}
		
		public /+virtual+/ void DrawLabel(string text, Bitmap image, Rectangle rect)
		{
			Rectangle dummy;
			DrawLabel(text, image, rect, cast(int)(Alignment.wxALIGN_LEFT | Alignment.wxALIGN_TOP), -1, dummy);
		}
		
		public /+virtual+/ void DrawLabel(string text, Bitmap image, Rectangle rect, int alignment)
		{
			Rectangle dummy;
			DrawLabel(text, image, rect, alignment, -1, dummy);
		}
		
		public /+virtual+/ void DrawLabel(string text, Bitmap image, Rectangle rect, int alignment, int indexAccel)
		{
			Rectangle dummy;
			DrawLabel(text, image, rect, alignment, indexAccel, dummy);
		}
		
		//---------------------------------------------------------------------
		
		public void DrawLabel(string text, Rectangle rect, int alignment, int indexAccel)
		{
			wxDC_DrawLabel2(wxobj, text, rect, alignment, indexAccel);
		}
		
		public void DrawLabel(string text, Rectangle rect)
		{
			DrawLabel(text, rect, cast(int)(Alignment.wxALIGN_LEFT | Alignment.wxALIGN_TOP), -1);
		}
		
		public void DrawLabel(string text, Rectangle rect, int alignment)
		{
			DrawLabel(text, rect, alignment, -1);
		}
		
		//---------------------------------------------------------------------
		
		public void DrawSpline(int x1, int y1, int x2, int y2, int x3, int y3)
		{
			wxDC_DrawSpline(wxobj, x1, y1, x2, y2, x3, y3);
		}
		
		public void DrawSpline(Point[] points)
		{
			wxDC_DrawSpline2(wxobj, points.length, points.ptr);
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ bool StartDoc(string message)
		{
			return wxDC_StartDoc(wxobj, message);
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ void EndDoc()
		{
			wxDC_EndDoc(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ void StartPage()
		{
			wxDC_StartPage(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ void EndPage()
		{
			wxDC_EndPage(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public void GetClippingBox(out int x, out int y, out int w, out int h)
		{
			wxDC_GetClippingBox(wxobj, x, y, w, h);
		}
		
		public void GetClippingBox(out Rectangle rect)
		{
			wxDC_GetClippingBox2(wxobj, rect);
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ void GetMultiLineTextExtent(string text, out int width, out int height, out int heightline, Font font)
		{
			wxDC_GetMultiLineTextExtent(wxobj, text, width, height, heightline, wxObject.SafePtr(font));
		}
		
		public /+virtual+/ void GetMultiLineTextExtent(string text, out int width, out int height)
		{	
			int heightline;
			
			GetMultiLineTextExtent(text, width, height, heightline, null);
		}
		
		public /+virtual+/ void GetMultiLineTextExtent(string text, out int width, out int height, out int heightline)
		{	
			GetMultiLineTextExtent(text, width, height, heightline, null);
		}
		
		//---------------------------------------------------------------------
		
		public bool GetPartialTextExtents(string text, int[] widths)
		{
			ArrayInt ai = new ArrayInt();
			
			for(int i = 0; i < widths.length; ++i)
				ai.Add(widths[i]);
				
			return wxDC_GetPartialTextExtents(wxobj, text, ArrayInt.SafePtr(ai));
		}
		
		//---------------------------------------------------------------------
		
		public void GetSize(out int width, out int height)
		{
			wxDC_GetSize(wxobj, width, height);
		}
		
		public Size size()
		{ 
			Size size;
			wxDC_GetSize2(wxobj, size);
			return size;
		}
		
		//---------------------------------------------------------------------
		
		public void GetSizeMM(out int width, out int height)
		{
			wxDC_GetSizeMM(wxobj, width, height);
		}
		
		public Size SizeMM() { 
				Size size;
				wxDC_GetSizeMM2(wxobj, size);
				return size;
			}
		
		//---------------------------------------------------------------------
		
		public int DeviceToLogicalX(int x)
		{
			return wxDC_DeviceToLogicalX(wxobj, x);
		}
		
		//---------------------------------------------------------------------
		
		public int DeviceToLogicalY(int y)
		{
			return wxDC_DeviceToLogicalY(wxobj, y);
		}
		
		//---------------------------------------------------------------------
		
		public int DeviceToLogicalXRel(int x)
		{
			return wxDC_DeviceToLogicalXRel(wxobj, x);
		}
		
		//---------------------------------------------------------------------
		
		public int DeviceToLogicalYRel(int y)
		{
			return wxDC_DeviceToLogicalYRel(wxobj, y);
		}
		
		//---------------------------------------------------------------------
		
		public int LogicalToDeviceX(int x)
		{
			return wxDC_LogicalToDeviceX(wxobj, x);
		}
		
		//---------------------------------------------------------------------
		
		public int LogicalToDeviceY(int y)
		{
			return wxDC_LogicalToDeviceY(wxobj, y);
		}
		
		//---------------------------------------------------------------------
		
		public int LogicalToDeviceXRel(int x)
		{
			return wxDC_LogicalToDeviceXRel(wxobj, x);
		}
		
		//---------------------------------------------------------------------
		
		public int LogicalToDeviceYRel(int y)
		{
			return wxDC_LogicalToDeviceYRel(wxobj, y);
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ bool Ok() { return wxDC_Ok(wxobj); }
		
		//---------------------------------------------------------------------
		
		public int MapMode() { return wxDC_GetMapMode(wxobj); }
		public void MapMode(int value) { wxDC_SetMapMode(wxobj, value); }
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ void GetUserScale(out double x, out double y)
		{
			wxDC_GetUserScale(wxobj, x, y);
		}
		
		public /+virtual+/ void SetUserScale(double x, double y)
		{
			wxDC_SetUserScale(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ void GetLogicalScale(out double x, out double y)
		{
			wxDC_GetLogicalScale(wxobj, x, y);
		}
		
		public /+virtual+/ void SetLogicalScale(double x, double y)
		{
			wxDC_SetLogicalScale(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------
		
		public void GetLogicalOrigin(out int x, out int y)
		{
			wxDC_GetLogicalOrigin(wxobj, x, y);
		}
		
		public Point LogicalOrigin()
		{
			Point pt;
			wxDC_GetLogicalOrigin2(wxobj, pt);
			return pt;
		}
		
		public void SetLogicalOrigin(int x, int y)
		{
			wxDC_SetLogicalOrigin(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------
		
		public void GetDeviceOrigin(out int x, out int y)
		{
			wxDC_GetDeviceOrigin(wxobj, x, y);
		}
		
		public Point DeviceOrigin()
		{
			Point pt;
			wxDC_GetDeviceOrigin2(wxobj, pt);
			return pt;
		}
		
		public void SetDeviceOrigin(int x, int y)
		{
			wxDC_SetDeviceOrigin(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------
		
		public void SetAxisOrientation(bool xLeftRight, bool yBottomUp)
		{
			wxDC_SetAxisOrientation(wxobj, xLeftRight, yBottomUp);
		}
		
		//---------------------------------------------------------------------
		
		public /+virtual+/ void CalcBoundingBox(int x, int y)
		{
			wxDC_CalcBoundingBox(wxobj, x, y);
		}
		
		//---------------------------------------------------------------------
		
		public void ResetBoundingBox()
		{
			wxDC_ResetBoundingBox(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public int MinX() { return wxDC_MinX(wxobj); }
		
		//---------------------------------------------------------------------
		
		public int MaxX() { return wxDC_MaxX(wxobj); }
		
		//---------------------------------------------------------------------
		
		public int MinY() { return wxDC_MinY(wxobj); }
		
		//---------------------------------------------------------------------
		
		public int MaxY() { return wxDC_MaxY(wxobj); }

		public static wxObject New(IntPtr ptr) { return new DC(ptr); }
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxWindowDC_ctor();
		static extern (C) IntPtr wxWindowDC_ctor2(IntPtr win);
		static extern (C) bool wxWindowDC_CanDrawBitmap(IntPtr self);
		static extern (C) bool wxWindowDC_CanGetTextExtent(IntPtr self);
		static extern (C) int wxWindowDC_GetCharWidth(IntPtr self);
		static extern (C) int wxWindowDC_GetCharHeight(IntPtr self);
		static extern (C) void wxWindowDC_Clear(IntPtr self);
		static extern (C) void wxWindowDC_SetFont(IntPtr self, IntPtr font);
		static extern (C) void wxWindowDC_SetPen(IntPtr self, IntPtr pen);
		static extern (C) void wxWindowDC_SetBrush(IntPtr self, IntPtr brush);
		static extern (C) void wxWindowDC_SetBackground(IntPtr self, IntPtr brush);
		static extern (C) void wxWindowDC_SetLogicalFunction(IntPtr self, int func);
		static extern (C) void wxWindowDC_SetTextForeground(IntPtr self, IntPtr colour);
		static extern (C) void wxWindowDC_SetTextBackground(IntPtr self, IntPtr colour);
		static extern (C) void wxWindowDC_SetBackgroundMode(IntPtr self, int mode);
		static extern (C) void wxWindowDC_SetPalette(IntPtr self, IntPtr palette);
		static extern (C) void wxWindowDC_GetPPI(IntPtr self, ref Size size);
		static extern (C) int wxWindowDC_GetDepth(IntPtr self);
		//! \endcond
		
		//---------------------------------------------------------------------
	
	alias WindowDC wxWindowDC;
	public class WindowDC : DC
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }
			
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}
		
		public this()
			{ this(wxWindowDC_ctor(), true);}
			
		public this(Window win)
			{ this(wxWindowDC_ctor2(wxObject.SafePtr(win)), true);}
			
		//---------------------------------------------------------------------
		
		public bool CanDrawBitmap()
		{
			return wxWindowDC_CanDrawBitmap(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public bool CanGetTextExtent()
		{
			return wxWindowDC_CanGetTextExtent(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public int GetCharWidth()
		{
			return wxWindowDC_GetCharWidth(wxobj); 
		}
		
		//---------------------------------------------------------------------
		
		public int GetCharHeight()
		{
			return wxWindowDC_GetCharHeight(wxobj); 
		}
		
		//---------------------------------------------------------------------
		
		public int CharHeight() { return wxWindowDC_GetCharHeight(wxobj); }
		
		//---------------------------------------------------------------------

		public int CharWidth() { return wxWindowDC_GetCharWidth(wxobj); }
		
		//---------------------------------------------------------------------
		
		public override void Clear()
		{
			wxWindowDC_Clear(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public void SetFont(Font font)
		{
			wxWindowDC_SetFont(wxobj, wxObject.SafePtr(font));
		}
		
		//---------------------------------------------------------------------
		
		public void SetPen(Pen pen)
		{
			wxWindowDC_SetPen(wxobj, wxObject.SafePtr(pen));
		}
		
		//---------------------------------------------------------------------
		
		public void SetBrush(Brush brush)
		{
			wxWindowDC_SetBrush(wxobj, wxObject.SafePtr(brush));
		}
		
		//---------------------------------------------------------------------
		
		public void SetBackground(Brush brush)
		{
			wxWindowDC_SetBackground(wxobj, wxObject.SafePtr(brush));
		}
		
		//---------------------------------------------------------------------
		
		public void SetLogicalFunction(int func)
		{
			wxWindowDC_SetLogicalFunction(wxobj, func);
		}
		
		//---------------------------------------------------------------------
		
		public void SetTextForeground(Colour colour)
		{
			wxWindowDC_SetTextForeground(wxobj, wxObject.SafePtr(colour));
		}
		
		//---------------------------------------------------------------------
		
		public void SetTextBackground(Colour colour)
		{
			wxWindowDC_SetTextBackground(wxobj, wxObject.SafePtr(colour));
		}
		
		//---------------------------------------------------------------------
		
		public void SetBackgroundMode(int mode)	
		{
			wxWindowDC_SetBackgroundMode(wxobj, mode);
		}
		
		//---------------------------------------------------------------------
		
		public void SetPalette(Palette palette)
		{
			wxWindowDC_SetPalette(wxobj, wxObject.SafePtr(palette));
		}
		
		//---------------------------------------------------------------------
		
		public Size GetPPI()
		{
			Size sz;
			wxWindowDC_GetPPI(wxobj, sz);
			return sz;
		}
		
		//---------------------------------------------------------------------
		
		public int GetDepth()
		{
			return wxWindowDC_GetDepth(wxobj);
		}
	}
	
		//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxClientDC_ctor();
		static extern (C) IntPtr wxClientDC_ctor2(IntPtr window);
		//! \endcond

		//---------------------------------------------------------------------
		
	alias ClientDC wxClientDC;
	public class ClientDC : WindowDC
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }
			
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}
			
		public this()
			{ this(wxClientDC_ctor(), true);}

		public this(Window window)
			{ this(wxClientDC_ctor2(wxObject.SafePtr(window)), true); }
	}
    
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxPaintDC_ctor();
		static extern (C) IntPtr wxPaintDC_ctor2(IntPtr window);
		//! \endcond

		//---------------------------------------------------------------------

	alias PaintDC wxPaintDC;
	public class PaintDC : WindowDC
	{
		public this(IntPtr wxobj) 
			{ super(wxobj); }
			
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}
			
		public this()
			{ this(wxPaintDC_ctor(), true); }
			
		public this(Window window)
			{ this(wxPaintDC_ctor2(wxObject.SafePtr(window)), true); }
	}
