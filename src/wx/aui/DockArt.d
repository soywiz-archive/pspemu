//-----------------------------------------------------------------------------
// wxD - DockArt.d
// (C) 2006 David Gileadi
//
/// The wxAUI wrapper class.
//
// Written by David Gileadi <gileadis@gmail.com>
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: DockArt.d,v 1.5 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.aui.DockArt;

public import wx.aui.FrameManager;

public import wx.wx;

//-----------------------------------------------------------------------------

//! \cond EXTERN
extern (C) alias int function(DockArt obj, int id) Virtual_GetMetric;
extern (C) alias void function(DockArt obj, int id, int new_val) Virtual_SetMetric;
extern (C) alias void function(DockArt obj, int id, IntPtr font) Virtual_SetFont;
extern (C) alias IntPtr function(DockArt obj, int id) Virtual_GetFont;
extern (C) alias IntPtr function(DockArt obj, int id) Virtual_GetColour;
extern (C) alias void function(DockArt obj, int id, IntPtr colour) Virtual_SetColour;
extern (C) alias IntPtr function(DockArt obj, int id) Virtual_GetColor;
extern (C) alias void function(DockArt obj, int id, IntPtr color) Virtual_SetColor;
extern (C) alias void function(DockArt obj, IntPtr dc, int orientation, ref Rectangle rect) Virtual_DrawSash;
extern (C) alias void function(DockArt obj, IntPtr dc, int orientation, ref Rectangle rect) Virtual_DrawBackground;
extern (C) alias void function(DockArt obj, IntPtr dc, string text, ref Rectangle rect, IntPtr pane) Virtual_DrawCaption;
extern (C) alias void function(DockArt obj, IntPtr dc, ref Rectangle rect, IntPtr pane) Virtual_DrawGripper;
extern (C) alias void function(DockArt obj, IntPtr dc, ref Rectangle rect, IntPtr pane) Virtual_DrawBorder;
extern (C) alias void function(DockArt obj, IntPtr dc, int button, int button_state, ref Rectangle rect, IntPtr pane) Virtual_DrawPaneButton;

//-----------------------------------------------------------------------------

static extern (C) IntPtr wxDockArt_ctor();
static extern (C) void wxDockArt_dtor(IntPtr self);
static extern (C) IntPtr wxDefaultDockArt_ctor();
static extern (C) void wxDefaultDockArt_dtor(IntPtr self);
static extern (C) void wxDockArt_RegisterVirtual(IntPtr self, DockArt obj,
                      Virtual_GetMetric getMetric,
                      Virtual_SetMetric setMetric,
                      Virtual_SetFont setFont,
                      Virtual_GetFont getFont,
                      Virtual_GetColour getColour,
                      Virtual_SetColour setColour,
                      Virtual_GetColor getColor,
                      Virtual_SetColor setColor,
                      Virtual_DrawSash drawSash,
                      Virtual_DrawBackground drawBackground,
                      Virtual_DrawCaption drawCaption,
                      Virtual_DrawGripper drawGripper,
                      Virtual_DrawBorder drawBorder,
                      Virtual_DrawPaneButton drawPaneButton);
static extern (C) int wxDockArt_GetMetric(IntPtr self, int id);
static extern (C) void wxDockArt_SetMetric(IntPtr self, int id, int new_val);
static extern (C) void wxDockArt_SetFont(IntPtr self, int id, IntPtr font);
static extern (C) IntPtr wxDockArt_GetFont(IntPtr self, int id);
static extern (C) IntPtr wxDockArt_GetColour(IntPtr self, int id);
static extern (C) void wxDockArt_SetColour(IntPtr self, int id, IntPtr colour);
static extern (C) IntPtr wxDockArt_GetColor(IntPtr self, int id);
static extern (C) void wxDockArt_SetColor(IntPtr self, int id, IntPtr color);
static extern (C) void wxDockArt_DrawSash(IntPtr self, IntPtr dc, int orientation, ref Rectangle rect);
static extern (C) void wxDockArt_DrawBackground(IntPtr self, IntPtr dc, int orientation, ref Rectangle rect);
static extern (C) void wxDockArt_DrawCaption(IntPtr self, IntPtr dc, string text, ref Rectangle rect, IntPtr pane);
static extern (C) void wxDockArt_DrawGripper(IntPtr self, IntPtr dc, ref Rectangle rect, IntPtr pane);
static extern (C) void wxDockArt_DrawBorder(IntPtr self, IntPtr dc, ref Rectangle rect, IntPtr pane);
static extern (C) void wxDockArt_DrawPaneButton(IntPtr self, IntPtr dc, int button, int button_state, ref Rectangle rect, IntPtr pane);
//! \endcond

//-----------------------------------------------------------------------------

alias DockArt wxDockArt;
/// dock art provider code - a dock provider provides all drawing
/// functionality to the wxAui dock manager.  This allows the dock
/// manager to have plugable look-and-feels
public class DockArt : wxObject
{
	IntPtr proxy;

    public this(IntPtr wxobj)
    {
      super(wxobj);
      proxy = wxDockArt_ctor();
      wxDockArt_RegisterVirtual(proxy, this,
                      &staticGetMetric,
                      &staticSetMetric,
                      &staticSetFont,
                      &staticGetFont,
                      &staticGetColour,
                      &staticSetColour,
                      &staticGetColor,
                      &staticSetColor,
                      &staticDrawSash,
                      &staticDrawBackground,
                      &staticDrawCaption,
                      &staticDrawGripper,
                      &staticDrawBorder,
                      &staticDrawPaneButton);
    }

    override protected void dtor()
    {
		wxDockArt_dtor(proxy);
	}
	
    extern (C) protected static int staticGetMetric(DockArt obj, int id) { return obj.GetMetric(id); }
    extern (C) protected static void staticSetMetric(DockArt obj, int id, int new_val) { obj.SetMetric(id, new_val); }
    extern (C) protected static void staticSetFont(DockArt obj, int id, IntPtr font)
    {
      wxObject o = FindObject(font);
      Font f = (o)? cast(Font)o : new Font(font);
      obj.SetFont(id, f);
    }
    extern (C) protected static IntPtr staticGetFont(DockArt obj, int id) { return wxObject.SafePtr(obj.GetFont(id)); }
    extern (C) protected static IntPtr staticGetColour(DockArt obj, int id) { return wxObject.SafePtr(obj.GetColour(id)); }
    extern (C) protected static void staticSetColour(DockArt obj, int id, IntPtr colour)
    {
      wxObject o = FindObject(colour);
      Colour c = (o)? cast(Colour)o : new Colour(colour);
      obj.SetColour(id, c);
    }
    extern (C) protected static IntPtr staticGetColor(DockArt obj, int id) { return wxObject.SafePtr(obj.GetColor(id)); }
    extern (C) protected static void staticSetColor(DockArt obj, int id, IntPtr color)
    {
      wxObject o = FindObject(color);
      Colour c = (o)? cast(Colour)o : new Colour(color);
      obj.SetColor(id, c);
    }
    extern (C) protected static void staticDrawSash(DockArt obj, IntPtr dc, int orientation, ref Rectangle rect)
    {
      wxObject o = FindObject(dc);
      DC d = (o)? cast(DC)o : new DC(dc);
      obj.DrawSash(d, orientation, rect);
    }
    extern (C) protected static void staticDrawBackground(DockArt obj, IntPtr dc, int orientation, ref Rectangle rect)
    {
      wxObject o = FindObject(dc);
      DC d = (o)? cast(DC)o : new DC(dc);
      obj.DrawBackground(d, orientation, rect);
    }
    extern (C) protected static void staticDrawCaption(DockArt obj, IntPtr dc, string text, ref Rectangle rect, IntPtr pane)
    {
      wxObject o = FindObject(dc);
      DC d = (o)? cast(DC)o : new DC(dc);
      o = FindObject(pane);
      PaneInfo p = (o)? cast(PaneInfo)o : new PaneInfo(pane);
      obj.DrawCaption(d, text, rect, p);
    }
    extern (C) protected static void staticDrawGripper(DockArt obj, IntPtr dc, ref Rectangle rect, IntPtr pane)
    {
      wxObject o = FindObject(dc);
      DC d = (o)? cast(DC)o : new DC(dc);
      o = FindObject(pane);
      PaneInfo p = (o)? cast(PaneInfo)o : new PaneInfo(pane);
      obj.DrawGripper(d, rect, p);
    }
    extern (C) protected static void staticDrawBorder(DockArt obj, IntPtr dc, ref Rectangle rect, IntPtr pane)
    {
      wxObject o = FindObject(dc);
      DC d = (o)? cast(DC)o : new DC(dc);
      o = FindObject(pane);
      PaneInfo p = (o)? cast(PaneInfo)o : new PaneInfo(pane);
      obj.DrawBorder(d, rect, p);
    }
    extern (C) protected static void staticDrawPaneButton(DockArt obj, IntPtr dc, int button, int button_state, ref Rectangle rect, IntPtr pane)
    {
      wxObject o = FindObject(dc);
      DC d = (o)? cast(DC)o : new DC(dc);
      o = FindObject(pane);
      PaneInfo p = (o)? cast(PaneInfo)o : new PaneInfo(pane);
      obj.DrawPaneButton(d, button, button_state, rect, p);
    }

    public int GetMetric(int id) { return wxDockArt_GetMetric(wxobj, id); }
    public void SetMetric(int id, int new_val) { wxDockArt_SetMetric(wxobj, id, new_val); }
    public void SetFont(int id, wxFont font) { wxDockArt_SetFont(wxobj, id, wxObject.SafePtr(font)); }
    public Font GetFont(int id)
    {
      IntPtr ptr = wxDockArt_GetFont(wxobj, id);
      wxObject o = FindObject(ptr);
      return (o)? cast(Font)o : new Font(ptr);
    }
    public Colour GetColour(int id)
    {
      IntPtr ptr = wxDockArt_GetColour(wxobj, id);
      wxObject o = FindObject(ptr);
      return (o)? cast(Colour)o : new Colour(ptr);
    }
    public void SetColour(int id, Colour colour) { wxDockArt_SetColour(wxobj, id, wxObject.SafePtr(colour)); }
    public Colour GetColor(int id)
    {
      IntPtr ptr = wxDockArt_GetColor(wxobj, id);
      wxObject o = FindObject(ptr);
      return (o)? cast(Colour)o : new Colour(ptr);
    }
    public void SetColor(int id, Colour color) { wxDockArt_SetColor(wxobj, id, wxObject.SafePtr(color)); }
    public void DrawSash(DC dc, int orientation, Rectangle rect) { wxDockArt_DrawSash(wxobj, wxObject.SafePtr(dc), orientation, rect); }
    public void DrawBackground(DC dc, int orientation, Rectangle rect) { wxDockArt_DrawBackground(wxobj, wxObject.SafePtr(dc), orientation, rect); }
    public void DrawCaption(DC dc, string text, Rectangle rect, PaneInfo pane) { wxDockArt_DrawCaption(wxobj, wxObject.SafePtr(dc), text, rect, wxObject.SafePtr(pane)); }
    public void DrawGripper(DC dc, Rectangle rect, PaneInfo pane) { wxDockArt_DrawGripper(wxobj, wxObject.SafePtr(dc), rect, wxObject.SafePtr(pane)); }
    public void DrawBorder(DC dc, Rectangle rect, PaneInfo pane) { wxDockArt_DrawBorder(wxobj, wxObject.SafePtr(dc), rect, wxObject.SafePtr(pane)); }
    public void DrawPaneButton(DC dc, int button, int button_state, Rectangle rect, PaneInfo pane) { wxDockArt_DrawPaneButton(wxobj, wxObject.SafePtr(dc), button, button_state, rect, wxObject.SafePtr(pane)); }
}

alias DefaultDockArt wxDefaultDockArt;
/// this is the default art provider for wxFrameManager.  Dock art
/// can be customized by creating a class derived from this one.
public class DefaultDockArt : DockArt
{
    public this()
    {
      super(wxDefaultDockArt_ctor());
	}
	
    override protected void dtor()
    {
      wxDefaultDockArt_dtor(wxobj);
	}
}
