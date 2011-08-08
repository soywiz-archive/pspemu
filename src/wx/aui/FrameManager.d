//-----------------------------------------------------------------------------
// wxD - FrameManager.d
// (C) 2006 David Gileadi
//
/// The wxAUI wrapper class.
//
// Written by David Gileadi <gileadis@gmail.com>
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: FrameManager.d,v 1.3 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.aui.FrameManager;

public import wx.wx;
public import wx.MiniFrame;
public import wx.Image;
public import wx.Event;
public import wx.EvtHandler;

public import wx.aui.DockArt;

enum wxFrameManagerDock
{
    wxAUI_DOCK_NONE = 0,
    wxAUI_DOCK_TOP = 1,
    wxAUI_DOCK_RIGHT = 2,
    wxAUI_DOCK_BOTTOM = 3,
    wxAUI_DOCK_LEFT = 4,
    wxAUI_DOCK_CENTER = 5,
    wxAUI_DOCK_CENTRE = wxAUI_DOCK_CENTER
};

enum wxFrameManagerOption
{
    wxAUI_MGR_ALLOW_FLOATING        = 1 << 0,
    wxAUI_MGR_ALLOW_ACTIVE_PANE     = 1 << 1,
    wxAUI_MGR_TRANSPARENT_DRAG      = 1 << 2,
    wxAUI_MGR_TRANSPARENT_HINT      = 1 << 3,
    wxAUI_MGR_TRANSPARENT_HINT_FADE = 1 << 4,

    wxAUI_MGR_DEFAULT = wxAUI_MGR_ALLOW_FLOATING |
                        wxAUI_MGR_TRANSPARENT_HINT |
                        wxAUI_MGR_TRANSPARENT_HINT_FADE
};

enum wxPaneDockArtSetting
{
    wxAUI_ART_SASH_SIZE = 0,
    wxAUI_ART_CAPTION_SIZE = 1,
    wxAUI_ART_GRIPPER_SIZE = 2,
    wxAUI_ART_PANE_BORDER_SIZE = 3,
    wxAUI_ART_PANE_BUTTON_SIZE = 4,
    wxAUI_ART_BACKGROUND_COLOUR = 5,
    wxAUI_ART_SASH_COLOUR = 6,
    wxAUI_ART_ACTIVE_CAPTION_COLOUR = 7,
    wxAUI_ART_ACTIVE_CAPTION_GRADIENT_COLOUR = 8,
    wxAUI_ART_INACTIVE_CAPTION_COLOUR = 9,
    wxAUI_ART_INACTIVE_CAPTION_GRADIENT_COLOUR = 10,
    wxAUI_ART_ACTIVE_CAPTION_TEXT_COLOUR = 11,
    wxAUI_ART_INACTIVE_CAPTION_TEXT_COLOUR = 12,
    wxAUI_ART_BORDER_COLOUR = 13,
    wxAUI_ART_GRIPPER_COLOUR = 14,
    wxAUI_ART_CAPTION_FONT = 15,
    wxAUI_ART_GRADIENT_TYPE = 16
};

enum wxPaneDockArtGradients
{
    wxAUI_GRADIENT_NONE = 0,
    wxAUI_GRADIENT_VERTICAL = 1,
    wxAUI_GRADIENT_HORIZONTAL = 2
};

enum wxPaneButtonState
{
    wxAUI_BUTTON_STATE_NORMAL = 0,
    wxAUI_BUTTON_STATE_HOVER = 1,
    wxAUI_BUTTON_STATE_PRESSED = 2
};

enum wxPaneInsertLevel
{
    wxAUI_INSERT_PANE = 0,
    wxAUI_INSERT_ROW = 1,
    wxAUI_INSERT_DOCK = 2
};

//-----------------------------------------------------------------------------

//! \cond EXTERN
static extern (C) IntPtr wxPaneInfo_ctor();
static extern (C) void wxPaneInfo_Copy(IntPtr self, IntPtr c);
static extern (C) bool wxPaneInfo_IsOk(IntPtr self);
static extern (C) bool wxPaneInfo_IsFixed(IntPtr self);
static extern (C) bool wxPaneInfo_IsResizable(IntPtr self);
static extern (C) bool wxPaneInfo_IsShown(IntPtr self);
static extern (C) bool wxPaneInfo_IsFloating(IntPtr self);
static extern (C) bool wxPaneInfo_IsDocked(IntPtr self);
static extern (C) bool wxPaneInfo_IsToolbar(IntPtr self);
static extern (C) bool wxPaneInfo_IsTopDockable(IntPtr self);
static extern (C) bool wxPaneInfo_IsBottomDockable(IntPtr self);
static extern (C) bool wxPaneInfo_IsLeftDockable(IntPtr self);
static extern (C) bool wxPaneInfo_IsRightDockable(IntPtr self);
static extern (C) bool wxPaneInfo_IsFloatable(IntPtr self);
static extern (C) bool wxPaneInfo_IsMovable(IntPtr self);
static extern (C) bool wxPaneInfo_HasCaption(IntPtr self);
static extern (C) bool wxPaneInfo_HasGripper(IntPtr self);
static extern (C) bool wxPaneInfo_HasBorder(IntPtr self);
static extern (C) bool wxPaneInfo_HasCloseButton(IntPtr self);
static extern (C) bool wxPaneInfo_HasMaximizeButton(IntPtr self);
static extern (C) bool wxPaneInfo_HasMinimizeButton(IntPtr self);
static extern (C) bool wxPaneInfo_HasPinButton(IntPtr self);
static extern (C) IntPtr wxPaneInfo_Window(IntPtr self, IntPtr w);
static extern (C) IntPtr wxPaneInfo_Name(IntPtr self, char[] n);
static extern (C) IntPtr wxPaneInfo_Caption(IntPtr self, char[] c);
static extern (C) IntPtr wxPaneInfo_Left(IntPtr self);
static extern (C) IntPtr wxPaneInfo_Right(IntPtr self);
static extern (C) IntPtr wxPaneInfo_Top(IntPtr self);
static extern (C) IntPtr wxPaneInfo_Bottom(IntPtr self);
static extern (C) IntPtr wxPaneInfo_Center(IntPtr self);
static extern (C) IntPtr wxPaneInfo_Centre(IntPtr self);
static extern (C) IntPtr wxPaneInfo_Direction(IntPtr self, int direction);
static extern (C) IntPtr wxPaneInfo_Layer(IntPtr self, int layer);
static extern (C) IntPtr wxPaneInfo_Row(IntPtr self, int row);
static extern (C) IntPtr wxPaneInfo_Position(IntPtr self, int pos);
static extern (C) IntPtr wxPaneInfo_BestSize(IntPtr self, ref Size size);
static extern (C) IntPtr wxPaneInfo_MinSize(IntPtr self, ref Size size);
static extern (C) IntPtr wxPaneInfo_MaxSize(IntPtr self, ref Size size);
static extern (C) IntPtr wxPaneInfo_BestSizeXY(IntPtr self, int x, int y);
static extern (C) IntPtr wxPaneInfo_MinSizeXY(IntPtr self, int x, int y);
static extern (C) IntPtr wxPaneInfo_MaxSizeXY(IntPtr self, int x, int y);
static extern (C) IntPtr wxPaneInfo_FloatingPosition(IntPtr self, ref Point pos);
static extern (C) IntPtr wxPaneInfo_FloatingPositionXY(IntPtr self, int x, int y);
static extern (C) IntPtr wxPaneInfo_FloatingSize(IntPtr self, ref Size size);
static extern (C) IntPtr wxPaneInfo_FloatingSizeXY(IntPtr self, int x, int y);
static extern (C) IntPtr wxPaneInfo_Fixed(IntPtr self);
static extern (C) IntPtr wxPaneInfo_Resizable(IntPtr self, bool resizable = true);
static extern (C) IntPtr wxPaneInfo_Dock(IntPtr self);
static extern (C) IntPtr wxPaneInfo_Float(IntPtr self);
static extern (C) IntPtr wxPaneInfo_Hide(IntPtr self);
static extern (C) IntPtr wxPaneInfo_Show(IntPtr self, bool show = true);
static extern (C) IntPtr wxPaneInfo_CaptionVisible(IntPtr self, bool visible = true);
static extern (C) IntPtr wxPaneInfo_PaneBorder(IntPtr self, bool visible = true);
static extern (C) IntPtr wxPaneInfo_Gripper(IntPtr self, bool visible = true);
static extern (C) IntPtr wxPaneInfo_CloseButton(IntPtr self, bool visible = true);
static extern (C) IntPtr wxPaneInfo_MaximizeButton(IntPtr self, bool visible = true);
static extern (C) IntPtr wxPaneInfo_MinimizeButton(IntPtr self, bool visible = true);
static extern (C) IntPtr wxPaneInfo_PinButton(IntPtr self, bool visible = true);
static extern (C) IntPtr wxPaneInfo_DestroyOnClose(IntPtr self, bool b = true);
static extern (C) IntPtr wxPaneInfo_TopDockable(IntPtr self, bool b = true);
static extern (C) IntPtr wxPaneInfo_BottomDockable(IntPtr self, bool b = true);
static extern (C) IntPtr wxPaneInfo_LeftDockable(IntPtr self, bool b = true);
static extern (C) IntPtr wxPaneInfo_RightDockable(IntPtr self, bool b = true);
static extern (C) IntPtr wxPaneInfo_Floatable(IntPtr self, bool b = true);
static extern (C) IntPtr wxPaneInfo_Movable(IntPtr self, bool b = true);
static extern (C) IntPtr wxPaneInfo_Dockable(IntPtr self, bool b = true);
static extern (C) IntPtr wxPaneInfo_DefaultPane(IntPtr self);
static extern (C) IntPtr wxPaneInfo_CentrePane(IntPtr self);
static extern (C) IntPtr wxPaneInfo_CenterPane(IntPtr self);
static extern (C) IntPtr wxPaneInfo_ToolbarPane(IntPtr self);
static extern (C) IntPtr wxPaneInfo_SetFlag(IntPtr self, uint flag, bool option_state);
static extern (C) bool wxPaneInfo_HasFlag(IntPtr self, uint flag);
static extern (C) char[] wxPaneInfo_GetName(IntPtr self);
static extern (C) char[] wxPaneInfo_GetCaption(IntPtr self);
static extern (C) IntPtr wxPaneInfo_GetWindow(IntPtr self);
static extern (C) IntPtr wxPaneInfo_GetFrame(IntPtr self);
static extern (C) uint wxPaneInfo_GetState(IntPtr self);
static extern (C) int wxPaneInfo_GetDock_Direction(IntPtr self);
static extern (C) int wxPaneInfo_GetDock_Layer(IntPtr self);
static extern (C) int wxPaneInfo_GetDock_Row(IntPtr self);
static extern (C) int wxPaneInfo_GetDock_Pos(IntPtr self);
static extern (C) void wxPaneInfo_GetBest_Size(IntPtr self, out Size size);
static extern (C) void wxPaneInfo_GetMin_Size(IntPtr self, out Size size);
static extern (C) void wxPaneInfo_GetMax_Size(IntPtr self, out Size size);
static extern (C) void wxPaneInfo_GetFloating_Pos(IntPtr self, out Point point);
static extern (C) void wxPaneInfo_GetFloating_Size(IntPtr self, out Size size);
static extern (C) int wxPaneInfo_GetDock_Proportion(IntPtr self);
static extern (C) void wxPaneInfo_GetRect(IntPtr self, out Rectangle rect);
//! \endcond

//-----------------------------------------------------------------------------

//! \cond EXTERN
static extern (C) IntPtr wxFrameManager_ctor(IntPtr frame = null, uint flags = wxFrameManagerOption.wxAUI_MGR_DEFAULT);
static extern (C) void wxFrameManager_dtor(IntPtr self);
static extern (C) void wxFrameManager_UnInit(IntPtr self);
static extern (C) void wxFrameManager_SetFlags(IntPtr self, uint flags);
static extern (C) uint wxFrameManager_GetFlags(IntPtr self);
static extern (C) void wxFrameManager_SetFrame(IntPtr self, IntPtr frame);
static extern (C) IntPtr wxFrameManager_GetFrame(IntPtr self);
static extern (C) void wxFrameManager_SetArtProvider(IntPtr self, IntPtr art_provider);
static extern (C) IntPtr wxFrameManager_GetArtProvider(IntPtr self);
static extern (C) IntPtr wxFrameManager_GetPaneByWindow(IntPtr self, IntPtr window);
static extern (C) IntPtr wxFrameManager_GetPaneByName(IntPtr self, char[] name);
static extern (C) int wxFrameManager_GetPaneCount(IntPtr self);
static extern (C) IntPtr wxFrameManager_GetPane(IntPtr self, int index);
static extern (C) bool wxFrameManager_AddPane(IntPtr self, IntPtr window, IntPtr pane_info);
static extern (C) bool wxFrameManager_AddPane2(IntPtr self, IntPtr window, int direction, string caption);
static extern (C) bool wxFrameManager_InsertPane(IntPtr self, IntPtr window, IntPtr pane_info, int insert_level = wxPaneInsertLevel.wxAUI_INSERT_PANE);
static extern (C) bool wxFrameManager_DetachPane(IntPtr self, IntPtr window);
static extern (C) char[] wxFrameManager_SavePerspective(IntPtr self);
static extern (C) bool wxFrameManager_LoadPerspective(IntPtr self, char[] perspective, bool update = true);
static extern (C) void wxFrameManager_Update(IntPtr self);

static extern (C) EventType wxEvent_EVT_AUI_PANEBUTTON();
//! \endcond

//-----------------------------------------------------------------------------

//! \cond EXTERN
static extern (C) void wxFrameManagerEvent_SetPane(IntPtr self, IntPtr p);
static extern (C) IntPtr wxFrameManagerEvent_GetPane(IntPtr self);
static extern (C) void wxFrameManagerEvent_SetButton(IntPtr self, int b);
static extern (C) int wxFrameManagerEvent_GetButton(IntPtr self);
static extern (C) IntPtr wxFrameManagerEvent_Clone(IntPtr self);
//! \endcond

//-----------------------------------------------------------------------------

alias PaneInfo wxPaneInfo;
public class PaneInfo : wxObject
{
    public this(IntPtr wxobj)
    {
      super(wxobj);
    }

    public this()
    {
      this(wxPaneInfo_ctor());
    }

    public this(PaneInfo c)
    {
        this();
        wxPaneInfo_Copy(wxobj, c.wxobj);
    }

    public bool IsOk() { return wxPaneInfo_IsOk(wxobj); }
    public bool IsFixed() { return wxPaneInfo_IsFixed(wxobj); }
    public bool IsResizable() { return wxPaneInfo_IsResizable(wxobj); }
    public bool IsShown() { return wxPaneInfo_IsShown(wxobj); }
    public bool IsFloating() { return wxPaneInfo_IsFloating(wxobj); }
    public bool IsDocked() { return wxPaneInfo_IsDocked(wxobj); }
    public bool IsToolbar() { return wxPaneInfo_IsToolbar(wxobj); }
    public bool IsTopDockable() { return wxPaneInfo_IsTopDockable(wxobj); }
    public bool IsBottomDockable() { return wxPaneInfo_IsBottomDockable(wxobj); }
    public bool IsLeftDockable() { return wxPaneInfo_IsLeftDockable(wxobj); }
    public bool IsRightDockable() { return wxPaneInfo_IsRightDockable(wxobj); }
    public bool IsFloatable() { return wxPaneInfo_IsFloatable(wxobj); }
    public bool IsMovable() { return wxPaneInfo_IsMovable(wxobj); }
    public bool HasCaption() { return wxPaneInfo_HasCaption(wxobj); }
    public bool HasGripper() { return wxPaneInfo_HasGripper(wxobj); }
    public bool HasBorder() { return wxPaneInfo_HasBorder(wxobj); }
    public bool HasCloseButton() { return wxPaneInfo_HasCloseButton(wxobj); }
    public bool HasMaximizeButton() { return wxPaneInfo_HasMaximizeButton(wxobj); }
    public bool HasMinimizeButton() { return wxPaneInfo_HasMinimizeButton(wxobj); }
    public bool HasPinButton() { return wxPaneInfo_HasPinButton(wxobj); }

    public PaneInfo Window(wxWindow w) { return cast(PaneInfo) FindObject(wxPaneInfo_Window(wxobj, wxObject.SafePtr(w))); }
    public PaneInfo Name(char[] n) { return cast(PaneInfo) FindObject(wxPaneInfo_Name(wxobj, n)); }
    public PaneInfo Caption(char[] c) { return cast(PaneInfo) FindObject(wxPaneInfo_Caption(wxobj, c)); }
    public PaneInfo Left() { return cast(PaneInfo) FindObject(wxPaneInfo_Left(wxobj)); }
    public PaneInfo Right() { return cast(PaneInfo) FindObject(wxPaneInfo_Right(wxobj)); }
    public PaneInfo Top() { return cast(PaneInfo) FindObject(wxPaneInfo_Top(wxobj)); }
    public PaneInfo Bottom() { return cast(PaneInfo) FindObject(wxPaneInfo_Bottom(wxobj)); }
    public PaneInfo Center() { return cast(PaneInfo) FindObject(wxPaneInfo_Center(wxobj)); }
    public PaneInfo Centre() { return cast(PaneInfo) FindObject(wxPaneInfo_Centre(wxobj)); }
    public PaneInfo Direction(int direction) { return cast(PaneInfo) FindObject(wxPaneInfo_Direction(wxobj, direction)); }
    public PaneInfo Layer(int layer) { return cast(PaneInfo) FindObject(wxPaneInfo_Layer(wxobj, layer)); }
    public PaneInfo Row(int row) { return cast(PaneInfo) FindObject(wxPaneInfo_Row(wxobj, row)); }
    public PaneInfo Position(int pos) { return cast(PaneInfo) FindObject(wxPaneInfo_Position(wxobj, pos)); }
    public PaneInfo BestSize(ref Size size) { return cast(PaneInfo) FindObject(wxPaneInfo_BestSize(wxobj, size)); }
    public PaneInfo MinSize(ref Size size) { return cast(PaneInfo) FindObject(wxPaneInfo_MinSize(wxobj, size)); }
    public PaneInfo MaxSize(ref Size size) { return cast(PaneInfo) FindObject(wxPaneInfo_MaxSize(wxobj, size)); }
    public PaneInfo BestSize(int x, int y) { return cast(PaneInfo) FindObject(wxPaneInfo_BestSizeXY(wxobj, x, y)); }
    public PaneInfo MinSize(int x, int y) { return cast(PaneInfo) FindObject(wxPaneInfo_MinSizeXY(wxobj, x, y)); }
    public PaneInfo MaxSize(int x, int y) { return cast(PaneInfo) FindObject(wxPaneInfo_MaxSizeXY(wxobj, x, y)); }
    public PaneInfo FloatingPosition(ref Point pos) { return cast(PaneInfo) FindObject(wxPaneInfo_FloatingPosition(wxobj, pos)); }
    public PaneInfo FloatingPosition(int x, int y) { return cast(PaneInfo) FindObject(wxPaneInfo_FloatingPositionXY(wxobj, x, y)); }
    public PaneInfo FloatingSize(ref Size size) { return cast(PaneInfo) FindObject(wxPaneInfo_FloatingSize(wxobj, size)); }
    public PaneInfo FloatingSize(int x, int y) { return cast(PaneInfo) FindObject(wxPaneInfo_FloatingSizeXY(wxobj, x, y)); }
    public PaneInfo Fixed() { return cast(PaneInfo) FindObject(wxPaneInfo_Fixed(wxobj)); }
    public PaneInfo Resizable(bool resizable = true) { return cast(PaneInfo) FindObject(wxPaneInfo_Resizable(wxobj, resizable)); }
    public PaneInfo Dock() { return cast(PaneInfo) FindObject(wxPaneInfo_Dock(wxobj)); }
    public PaneInfo Float() { return cast(PaneInfo) FindObject(wxPaneInfo_Float(wxobj)); }
    public PaneInfo Hide() { return cast(PaneInfo) FindObject(wxPaneInfo_Hide(wxobj)); }
    public PaneInfo Show(bool show = true) { return cast(PaneInfo) FindObject(wxPaneInfo_Show(wxobj, show)); }
    public PaneInfo CaptionVisible(bool visible = true) { return cast(PaneInfo) FindObject(wxPaneInfo_CaptionVisible(wxobj, visible)); }
    public PaneInfo PaneBorder(bool visible = true) { return cast(PaneInfo) FindObject(wxPaneInfo_PaneBorder(wxobj, visible)); }
    public PaneInfo Gripper(bool visible = true) { return cast(PaneInfo) FindObject(wxPaneInfo_Gripper(wxobj, visible)); }
    public PaneInfo CloseButton(bool visible = true) { return cast(PaneInfo) FindObject(wxPaneInfo_CloseButton(wxobj, visible)); }
    public PaneInfo MaximizeButton(bool visible = true) { return cast(PaneInfo) FindObject(wxPaneInfo_MaximizeButton(wxobj, visible)); }
    public PaneInfo MinimizeButton(bool visible = true) { return cast(PaneInfo) FindObject(wxPaneInfo_MinimizeButton(wxobj, visible)); }
    public PaneInfo PinButton(bool visible = true) { return cast(PaneInfo) FindObject(wxPaneInfo_PinButton(wxobj, visible)); }
    public PaneInfo DestroyOnClose(bool b = true) { return cast(PaneInfo) FindObject(wxPaneInfo_DestroyOnClose(wxobj, b)); }
    public PaneInfo TopDockable(bool b = true) { return cast(PaneInfo) FindObject(wxPaneInfo_TopDockable(wxobj, b)); }
    public PaneInfo BottomDockable(bool b = true) { return cast(PaneInfo) FindObject(wxPaneInfo_BottomDockable(wxobj, b)); }
    public PaneInfo LeftDockable(bool b = true) { return cast(PaneInfo) FindObject(wxPaneInfo_LeftDockable(wxobj, b)); }
    public PaneInfo RightDockable(bool b = true) { return cast(PaneInfo) FindObject(wxPaneInfo_RightDockable(wxobj, b)); }
    public PaneInfo Floatable(bool b = true) { return cast(PaneInfo) FindObject(wxPaneInfo_Floatable(wxobj, b)); }
    public PaneInfo Movable(bool b = true) { return cast(PaneInfo) FindObject(wxPaneInfo_Movable(wxobj, b)); }
    public PaneInfo Dockable(bool b = true) { return cast(PaneInfo) FindObject(wxPaneInfo_Dockable(wxobj, b)); }
    public PaneInfo DefaultPane() { return cast(PaneInfo) FindObject(wxPaneInfo_DefaultPane(wxobj)); }
    public PaneInfo CentrePane() { return cast(PaneInfo) FindObject(wxPaneInfo_CentrePane(wxobj)); }
    public PaneInfo CenterPane() { return cast(PaneInfo) FindObject(wxPaneInfo_CenterPane(wxobj)); }
    public PaneInfo ToolbarPane() { return cast(PaneInfo) FindObject(wxPaneInfo_ToolbarPane(wxobj)); }
    public PaneInfo SetFlag(uint flag, bool option_state) { return cast(PaneInfo) FindObject(wxPaneInfo_SetFlag(wxobj, flag, option_state)); }
    public bool HasFlag(uint flag) { return wxPaneInfo_HasFlag(wxobj, flag); }

    public char[] name() { return wxPaneInfo_GetName(wxobj); }
    public char[] caption() { return wxPaneInfo_GetCaption(wxobj); }

    public wxWindow window()
    {
      IntPtr ptr = wxPaneInfo_GetWindow(wxobj);
      wxObject o = FindObject(ptr);
      return (o)? cast(wxWindow)o : new wxWindow(ptr);
    }
    public wxWindow frame()
    {
      IntPtr ptr = wxPaneInfo_GetFrame(wxobj);
      wxObject o = FindObject(ptr);
      return (o)? cast(wxWindow)o : new wxWindow(ptr);
    }
    public uint state() { return wxPaneInfo_GetState(wxobj); }

    public int dock_direction() { return wxPaneInfo_GetDock_Direction(wxobj); }
    public int dock_layer() { return wxPaneInfo_GetDock_Layer(wxobj); }
    public int dock_row() { return wxPaneInfo_GetDock_Row(wxobj); }
    public int dock_pos() { return wxPaneInfo_GetDock_Pos(wxobj); }

    public Size best_size()
    {
      Size size;
      wxPaneInfo_GetBest_Size(wxobj, size);
      return size;
    }
    public Size min_size()
    {
      Size size;
      wxPaneInfo_GetMin_Size(wxobj, size);
      return size;
    }
    public Size max_size()
    {
      Size size;
      wxPaneInfo_GetMax_Size(wxobj, size);
      return size;
    }

    public Point floating_pos()
    {
      Point point;
      wxPaneInfo_GetFloating_Pos(wxobj, point);
      return point;
    }
    public Size floating_size()
    {
      Size size;
      wxPaneInfo_GetFloating_Size(wxobj, size);
      return size;
    }
    public int dock_proportion() { return wxPaneInfo_GetDock_Proportion(wxobj); }

    public Rectangle rect()
    {
      Rectangle rect;
      wxPaneInfo_GetRect(wxobj, rect);
      return rect;
    }

    public enum wxPaneState
    {
      optionFloating        = 1 << 0,
      optionHidden          = 1 << 1,
      optionLeftDockable    = 1 << 2,
      optionRightDockable   = 1 << 3,
      optionTopDockable     = 1 << 4,
      optionBottomDockable  = 1 << 5,
      optionFloatable       = 1 << 6,
      optionMovable         = 1 << 7,
      optionResizable       = 1 << 8,
      optionPaneBorder      = 1 << 9,
      optionCaption         = 1 << 10,
      optionGripper         = 1 << 11,
      optionDestroyOnClose  = 1 << 12,
      optionToolbar         = 1 << 13,
      optionActive          = 1 << 14,

      buttonClose           = 1 << 24,
      buttonMaximize        = 1 << 25,
      buttonMinimize        = 1 << 26,
      buttonPin             = 1 << 27,
      buttonCustom1         = 1 << 28,
      buttonCustom2         = 1 << 29,
      buttonCustom3         = 1 << 30,
      actionPane            = 1 << 31  // used internally
    }
}



alias FrameManager wxFrameManager;
public class FrameManager : EvtHandler
{
    public this(IntPtr wxobj)
    {
      super(wxobj);
    }

    public this(Frame frame = null, uint flags = wxFrameManagerOption.wxAUI_MGR_DEFAULT)
    {
      this(wxFrameManager_ctor(wxObject.SafePtr(frame), flags));
    }

    public void UnInit() { wxFrameManager_UnInit(wxobj); }

    public void SetFlags(uint flags) { wxFrameManager_SetFlags(wxobj, flags); }
    public uint GetFlags() { return wxFrameManager_GetFlags(wxobj); }

    public void SetFrame(Frame frame) { wxFrameManager_SetFrame(wxobj, wxObject.SafePtr(frame)); }
    public Frame GetFrame()
    {
      IntPtr ptr = wxFrameManager_GetFrame(wxobj);
      wxObject o = FindObject(ptr);
      if (o) return cast(Frame)o;
      else return new Frame(ptr);
    }

    public void SetArtProvider(DockArt art_provider) { wxFrameManager_SetArtProvider(wxobj, wxObject.SafePtr(art_provider)); }
    public DockArt GetArtProvider()
    {
      IntPtr ptr = wxFrameManager_GetArtProvider(wxobj);
      wxObject o = FindObject(ptr);
      if (o) return cast(DockArt)o;
      else return new DockArt(ptr);
    }

    public PaneInfo GetPane(Window window)
    {
      IntPtr ptr = wxFrameManager_GetPaneByWindow(wxobj, wxObject.SafePtr(window));
      wxObject o = FindObject(ptr);
      if (o) return cast(PaneInfo)o;
      else return new PaneInfo(ptr);
    }
    public PaneInfo GetPane(char[] name)
    {
      IntPtr ptr = wxFrameManager_GetPaneByName(wxobj, name);
      wxObject o = FindObject(ptr);
      if (o) return cast(PaneInfo)o;
      else return new PaneInfo(ptr);
    }
    public int GetPaneCount() { return wxFrameManager_GetPaneCount(wxobj); }
    public PaneInfo GetPane(int index)
    {
      IntPtr ptr = wxFrameManager_GetPane(wxobj, index);
      wxObject o = FindObject(ptr);
      if (o) return cast(PaneInfo)o;
      else return new PaneInfo(ptr);
    }

    public bool AddPane(Window window, PaneInfo pane_info)
    {
      return wxFrameManager_AddPane(wxobj, wxObject.SafePtr(window), wxObject.SafePtr(pane_info));
    }

    public bool AddPane(Window window,
                 int direction = Direction.wxLEFT,
                 string caption = "")
    {
      return wxFrameManager_AddPane2(wxobj, wxObject.SafePtr(window), direction, caption);
    }

    public bool InsertPane(Window window,
                 PaneInfo pane_info,
                 int insert_level = wxPaneInsertLevel.wxAUI_INSERT_PANE)
    {
      return wxFrameManager_InsertPane(wxobj, wxObject.SafePtr(window), wxObject.SafePtr(pane_info), insert_level);
    }

    public bool DetachPane(Window window)
    {
      return wxFrameManager_DetachPane(wxobj, wxObject.SafePtr(window));
    }

    public char[] SavePerspective() { return wxFrameManager_SavePerspective(wxobj); }

    public bool LoadPerspective(char[] perspective,
                 bool update = true)
    {
      return wxFrameManager_LoadPerspective(wxobj, perspective, update);
    }

    public void Update() { return wxFrameManager_Update(wxobj); }


// wx event machinery


// right now the only event that works is wxEVT_AUI_PANEBUTTON. A full
// spectrum of events will be implemented in the next incremental version

    public static EventType wxEVT_AUI_PANEBUTTON;

    static this()
    {
      wxEVT_AUI_PANEBUTTON = wxEvent_EVT_AUI_PANEBUTTON();
    }

    public void EVT_AUI_PANEBUTTON(EventListener lsnr)
    {
      AddEventListener(wxEVT_AUI_PANEBUTTON, lsnr);
    }
}



// event declarations/classes
alias FrameManagerEvent wxFrameManagerEvent;
public class FrameManagerEvent : Event
{
    public this(IntPtr wxobj)
    {
      super(wxobj);
    }

    public Event Clone()
    {
      return new FrameManagerEvent(wxFrameManagerEvent_Clone(wxobj));
    }

    public void SetPane(PaneInfo p) { wxFrameManagerEvent_SetPane(wxobj, wxObject.SafePtr(p)); }
    public void SetButton(int b) { wxFrameManagerEvent_SetButton(wxobj, b); }
    public PaneInfo GetPane()
    {
      IntPtr ptr = wxFrameManagerEvent_GetPane(wxobj);
      wxObject o = FindObject(ptr);
      if (o) return cast(PaneInfo)o;
      else return new PaneInfo(ptr);
    }
    public int GetButton() { return wxFrameManagerEvent_GetButton(wxobj); }
}


