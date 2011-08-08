//-----------------------------------------------------------------------------
// wxD - StyledTextCtrl.h
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - StyledTextCtrl.h
//
/// The wxStyledTextCtrl wrapper class. (Optional, requires STC contrib)
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: StyledTextCtrl.d,v 1.13 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.StyledTextCtrl;

//! \cond VERSION
version(WXD_STYLEDTEXTCTRL){
//! \endcond

public import wx.common;
public import wx.Control;
public import wx.CommandEvent;

		//! \cond EXTERN
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_CHANGE();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_STYLENEEDED();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_CHARADDED();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_SAVEPOINTREACHED();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_SAVEPOINTLEFT();  
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_ROMODIFYATTEMPT();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_KEY();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_DOUBLECLICK();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_UPDATEUI();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_MODIFIED();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_MACRORECORD();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_MARGINCLICK();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_NEEDSHOWN();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_POSCHANGED();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_PAINTED();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_USERLISTSELECTION();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_URIDROPPED();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_DWELLSTART();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_DWELLEND();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_START_DRAG();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_DRAG_OVER();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_DO_DROP();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_ZOOM();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_HOTSPOT_CLICK();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_HOTSPOT_DCLICK();
        static extern (C) EventType wxStyledTextCtrl_EVT_STC_CALLTIP_CLICK();

        static extern (C) IntPtr wxStyledTextCtrl_ctor(IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name);
        static extern (C) void   wxStyledTextCtrl_AddText(IntPtr self, string text);
        //static extern (C) void   wxStyledTextCtrl_AddStyledText(IntPtr self, IntPtr data);
        static extern (C) void   wxStyledTextCtrl_InsertText(IntPtr self, int pos, string text);
        static extern (C) void   wxStyledTextCtrl_ClearAll(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_ClearDocumentStyle(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_GetLength(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_GetCharAt(IntPtr self, int pos);
        static extern (C) int    wxStyledTextCtrl_GetCurrentPos(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_GetAnchor(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_GetStyleAt(IntPtr self, int pos);
        static extern (C) void   wxStyledTextCtrl_Redo(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetUndoCollection(IntPtr self, bool collectUndo);
        static extern (C) void   wxStyledTextCtrl_SelectAll(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetSavePoint(IntPtr self);
        //static extern (C) IntPtr wxStyledTextCtrl_GetStyledText(IntPtr self, int startPos, int endPos);
        static extern (C) bool   wxStyledTextCtrl_CanRedo(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_MarkerLineFromHandle(IntPtr self, int handle);
        static extern (C) void   wxStyledTextCtrl_MarkerDeleteHandle(IntPtr self, int handle);
        static extern (C) bool   wxStyledTextCtrl_GetUndoCollection(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_GetViewWhiteSpace(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetViewWhiteSpace(IntPtr self, int viewWS);
        static extern (C) int    wxStyledTextCtrl_PositionFromPoint(IntPtr self, ref Point pt);
        static extern (C) int    wxStyledTextCtrl_PositionFromPointClose(IntPtr self, int x, int y);
        static extern (C) void   wxStyledTextCtrl_GotoLine(IntPtr self, int line);
        static extern (C) void   wxStyledTextCtrl_GotoPos(IntPtr self, int pos);
        static extern (C) void   wxStyledTextCtrl_SetAnchor(IntPtr self, int posAnchor);
        static extern (C) IntPtr wxStyledTextCtrl_GetCurLine(IntPtr self, ref int linePos);
        static extern (C) int    wxStyledTextCtrl_GetEndStyled(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_ConvertEOLs(IntPtr self, int eolMode);
        static extern (C) int    wxStyledTextCtrl_GetEOLMode(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetEOLMode(IntPtr self, int eolMode);
        static extern (C) void   wxStyledTextCtrl_StartStyling(IntPtr self, int pos, int mask);
        static extern (C) void   wxStyledTextCtrl_SetStyling(IntPtr self, int length, int style);
        static extern (C) bool   wxStyledTextCtrl_GetBufferedDraw(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetBufferedDraw(IntPtr self, bool buffered);
        static extern (C) void   wxStyledTextCtrl_SetTabWidth(IntPtr self, int tabWidth);
        static extern (C) int    wxStyledTextCtrl_GetTabWidth(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetCodePage(IntPtr self, int codePage);
        static extern (C) void   wxStyledTextCtrl_MarkerDefine(IntPtr self, int markerNumber, int markerSymbol, IntPtr foreground, IntPtr background);
        static extern (C) void   wxStyledTextCtrl_MarkerSetForeground(IntPtr self, int markerNumber, IntPtr fore);
        static extern (C) void   wxStyledTextCtrl_MarkerSetBackground(IntPtr self, int markerNumber, IntPtr back);
        static extern (C) int    wxStyledTextCtrl_MarkerAdd(IntPtr self, int line, int markerNumber);
        static extern (C) void   wxStyledTextCtrl_MarkerDelete(IntPtr self, int line, int markerNumber);
        static extern (C) void   wxStyledTextCtrl_MarkerDeleteAll(IntPtr self, int markerNumber);
        static extern (C) int    wxStyledTextCtrl_MarkerGet(IntPtr self, int line);
        static extern (C) int    wxStyledTextCtrl_MarkerNext(IntPtr self, int lineStart, int markerMask);
        static extern (C) int    wxStyledTextCtrl_MarkerPrevious(IntPtr self, int lineStart, int markerMask);
        static extern (C) void   wxStyledTextCtrl_MarkerDefineBitmap(IntPtr self, int markerNumber, IntPtr bmp);
        static extern (C) void   wxStyledTextCtrl_SetMarginType(IntPtr self, int margin, int marginType);
        static extern (C) int    wxStyledTextCtrl_GetMarginType(IntPtr self, int margin);
        static extern (C) void   wxStyledTextCtrl_SetMarginWidth(IntPtr self, int margin, int pixelWidth);
        static extern (C) int    wxStyledTextCtrl_GetMarginWidth(IntPtr self, int margin);
        static extern (C) void   wxStyledTextCtrl_SetMarginMask(IntPtr self, int margin, int mask);
        static extern (C) int    wxStyledTextCtrl_GetMarginMask(IntPtr self, int margin);
        static extern (C) void   wxStyledTextCtrl_SetMarginSensitive(IntPtr self, int margin, bool sensitive);
        static extern (C) bool   wxStyledTextCtrl_GetMarginSensitive(IntPtr self, int margin);
        static extern (C) void   wxStyledTextCtrl_StyleClearAll(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_StyleSetForeground(IntPtr self, int style, IntPtr fore);
        static extern (C) void   wxStyledTextCtrl_StyleSetBackground(IntPtr self, int style, IntPtr back);
        static extern (C) void   wxStyledTextCtrl_StyleSetBold(IntPtr self, int style, bool bold);
        static extern (C) void   wxStyledTextCtrl_StyleSetItalic(IntPtr self, int style, bool italic);
        static extern (C) void   wxStyledTextCtrl_StyleSetSize(IntPtr self, int style, int sizePoints);
        static extern (C) void   wxStyledTextCtrl_StyleSetFaceName(IntPtr self, int style, string fontName);
        static extern (C) void   wxStyledTextCtrl_StyleSetEOLFilled(IntPtr self, int style, bool filled);
        static extern (C) void   wxStyledTextCtrl_StyleResetDefault(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_StyleSetUnderline(IntPtr self, int style, bool underline);
        static extern (C) void   wxStyledTextCtrl_StyleSetCase(IntPtr self, int style, int caseForce);
        static extern (C) void   wxStyledTextCtrl_StyleSetCharacterSet(IntPtr self, int style, int characterSet);
        static extern (C) void   wxStyledTextCtrl_StyleSetHotSpot(IntPtr self, int style, bool hotspot);
        static extern (C) void   wxStyledTextCtrl_SetSelForeground(IntPtr self, bool useSetting, IntPtr fore);
        static extern (C) void   wxStyledTextCtrl_SetSelBackground(IntPtr self, bool useSetting, IntPtr back);
        static extern (C) void   wxStyledTextCtrl_SetCaretForeground(IntPtr self, IntPtr fore);
        static extern (C) void   wxStyledTextCtrl_CmdKeyAssign(IntPtr self, int key, int modifiers, int cmd);
        static extern (C) void   wxStyledTextCtrl_CmdKeyClear(IntPtr self, int key, int modifiers);
        static extern (C) void   wxStyledTextCtrl_CmdKeyClearAll(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetStyleBytes(IntPtr self, int length, ubyte* styleBytes);
        static extern (C) void   wxStyledTextCtrl_StyleSetVisible(IntPtr self, int style, bool visible);
        static extern (C) int    wxStyledTextCtrl_GetCaretPeriod(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetCaretPeriod(IntPtr self, int periodMilliseconds);
        static extern (C) void   wxStyledTextCtrl_SetWordChars(IntPtr self, string characters);
        static extern (C) void   wxStyledTextCtrl_BeginUndoAction(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_EndUndoAction(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_IndicatorSetStyle(IntPtr self, int indic, int style);
        static extern (C) int    wxStyledTextCtrl_IndicatorGetStyle(IntPtr self, int indic);
        static extern (C) void   wxStyledTextCtrl_IndicatorSetForeground(IntPtr self, int indic, IntPtr fore);
        static extern (C) IntPtr wxStyledTextCtrl_IndicatorGetForeground(IntPtr self, int indic);
        static extern (C) void   wxStyledTextCtrl_SetWhitespaceForeground(IntPtr self, bool useSetting, IntPtr fore);
        static extern (C) void   wxStyledTextCtrl_SetWhitespaceBackground(IntPtr self, bool useSetting, IntPtr back);
        static extern (C) void   wxStyledTextCtrl_SetStyleBits(IntPtr self, int bits);
        static extern (C) int    wxStyledTextCtrl_GetStyleBits(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetLineState(IntPtr self, int line, int state);
        static extern (C) int    wxStyledTextCtrl_GetLineState(IntPtr self, int line);
        static extern (C) int    wxStyledTextCtrl_GetMaxLineState(IntPtr self);
        static extern (C) bool   wxStyledTextCtrl_GetCaretLineVisible(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetCaretLineVisible(IntPtr self, bool show);
        static extern (C) IntPtr wxStyledTextCtrl_GetCaretLineBack(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetCaretLineBack(IntPtr self, IntPtr back);
        static extern (C) void   wxStyledTextCtrl_StyleSetChangeable(IntPtr self, int style, bool changeable);
        static extern (C) void   wxStyledTextCtrl_AutoCompShow(IntPtr self, int lenEntered, string itemList);
        static extern (C) void   wxStyledTextCtrl_AutoCompCancel(IntPtr self);
        static extern (C) bool   wxStyledTextCtrl_AutoCompActive(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_AutoCompPosStart(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_AutoCompComplete(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_AutoCompStops(IntPtr self, string characterSet);
        static extern (C) void   wxStyledTextCtrl_AutoCompSetSeparator(IntPtr self, int separatorCharacter);
        static extern (C) int    wxStyledTextCtrl_AutoCompGetSeparator(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_AutoCompSelect(IntPtr self, string text);
        static extern (C) void   wxStyledTextCtrl_AutoCompSetCancelAtStart(IntPtr self, bool cancel);
        static extern (C) bool   wxStyledTextCtrl_AutoCompGetCancelAtStart(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_AutoCompSetFillUps(IntPtr self, string characterSet);
        static extern (C) void   wxStyledTextCtrl_AutoCompSetChooseSingle(IntPtr self, bool chooseSingle);
        static extern (C) bool   wxStyledTextCtrl_AutoCompGetChooseSingle(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_AutoCompSetIgnoreCase(IntPtr self, bool ignoreCase);
        static extern (C) bool   wxStyledTextCtrl_AutoCompGetIgnoreCase(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_UserListShow(IntPtr self, int listType, string itemList);
        static extern (C) void   wxStyledTextCtrl_AutoCompSetAutoHide(IntPtr self, bool autoHide);
        static extern (C) bool   wxStyledTextCtrl_AutoCompGetAutoHide(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_AutoCompSetDropRestOfWord(IntPtr self, bool dropRestOfWord);
        static extern (C) bool   wxStyledTextCtrl_AutoCompGetDropRestOfWord(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_RegisterImage(IntPtr self, int type, IntPtr bmp);
        static extern (C) void   wxStyledTextCtrl_ClearRegisteredImages(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_AutoCompGetTypeSeparator(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_AutoCompSetTypeSeparator(IntPtr self, int separatorCharacter);
        static extern (C) void   wxStyledTextCtrl_SetIndent(IntPtr self, int indentSize);
        static extern (C) int    wxStyledTextCtrl_GetIndent(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetUseTabs(IntPtr self, bool useTabs);
        static extern (C) bool   wxStyledTextCtrl_GetUseTabs(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetLineIndentation(IntPtr self, int line, int indentSize);
        static extern (C) int    wxStyledTextCtrl_GetLineIndentation(IntPtr self, int line);
        static extern (C) int    wxStyledTextCtrl_GetLineIndentPosition(IntPtr self, int line);
        static extern (C) int    wxStyledTextCtrl_GetColumn(IntPtr self, int pos);
        static extern (C) void   wxStyledTextCtrl_SetUseHorizontalScrollBar(IntPtr self, bool show);
        static extern (C) bool   wxStyledTextCtrl_GetUseHorizontalScrollBar(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetIndentationGuides(IntPtr self, bool show);
        static extern (C) bool   wxStyledTextCtrl_GetIndentationGuides(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetHighlightGuide(IntPtr self, int column);
        static extern (C) int    wxStyledTextCtrl_GetHighlightGuide(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_GetLineEndPosition(IntPtr self, int line);
        static extern (C) int    wxStyledTextCtrl_GetCodePage(IntPtr self);
        static extern (C) IntPtr wxStyledTextCtrl_GetCaretForeground(IntPtr self);
        static extern (C) bool   wxStyledTextCtrl_GetReadOnly(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetCurrentPos(IntPtr self, int pos);
        static extern (C) void   wxStyledTextCtrl_SetSelectionStart(IntPtr self, int pos);
        static extern (C) int    wxStyledTextCtrl_GetSelectionStart(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetSelectionEnd(IntPtr self, int pos);
        static extern (C) int    wxStyledTextCtrl_GetSelectionEnd(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetPrintMagnification(IntPtr self, int magnification);
        static extern (C) int    wxStyledTextCtrl_GetPrintMagnification(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetPrintColourMode(IntPtr self, int mode);
        static extern (C) int    wxStyledTextCtrl_GetPrintColourMode(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_FindText(IntPtr self, int minPos, int maxPos, string text, int flags);
        static extern (C) int    wxStyledTextCtrl_FormatRange(IntPtr self, bool doDraw, int startPos, int endPos, IntPtr draw, IntPtr target, ref Rectangle renderRect, ref Rectangle pageRect);
        static extern (C) int    wxStyledTextCtrl_GetFirstVisibleLine(IntPtr self);
        static extern (C) IntPtr wxStyledTextCtrl_GetLine(IntPtr self, int line);
        static extern (C) int    wxStyledTextCtrl_GetLineCount(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetMarginLeft(IntPtr self, int pixelWidth);
        static extern (C) int    wxStyledTextCtrl_GetMarginLeft(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetMarginRight(IntPtr self, int pixelWidth);
        static extern (C) int    wxStyledTextCtrl_GetMarginRight(IntPtr self);
        static extern (C) bool   wxStyledTextCtrl_GetModify(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetSelection(IntPtr self, int start, int end);
        static extern (C) IntPtr wxStyledTextCtrl_GetSelectedText(IntPtr self);
        static extern (C) IntPtr wxStyledTextCtrl_GetTextRange(IntPtr self, int startPos, int endPos);
        static extern (C) void   wxStyledTextCtrl_HideSelection(IntPtr self, bool normal);
        static extern (C) int    wxStyledTextCtrl_LineFromPosition(IntPtr self, int pos);
        static extern (C) int    wxStyledTextCtrl_PositionFromLine(IntPtr self, int line);
        static extern (C) void   wxStyledTextCtrl_LineScroll(IntPtr self, int columns, int lines);
        static extern (C) void   wxStyledTextCtrl_EnsureCaretVisible(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_ReplaceSelection(IntPtr self, string text);
        static extern (C) void   wxStyledTextCtrl_SetReadOnly(IntPtr self, bool readOnly);
        static extern (C) bool   wxStyledTextCtrl_CanPaste(IntPtr self);
        static extern (C) bool   wxStyledTextCtrl_CanUndo(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_EmptyUndoBuffer(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_Undo(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_Cut(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_Copy(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_Paste(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_Clear(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetText(IntPtr self, string text);
        static extern (C) IntPtr wxStyledTextCtrl_GetText(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_GetTextLength(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetOvertype(IntPtr self, bool overtype);
        static extern (C) bool   wxStyledTextCtrl_GetOvertype(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetCaretWidth(IntPtr self, int pixelWidth);
        static extern (C) int    wxStyledTextCtrl_GetCaretWidth(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetTargetStart(IntPtr self, int pos);
        static extern (C) int    wxStyledTextCtrl_GetTargetStart(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetTargetEnd(IntPtr self, int pos);
        static extern (C) int    wxStyledTextCtrl_GetTargetEnd(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_ReplaceTarget(IntPtr self, string text);
        static extern (C) int    wxStyledTextCtrl_ReplaceTargetRE(IntPtr self, string text);
        static extern (C) int    wxStyledTextCtrl_SearchInTarget(IntPtr self, string text);
        static extern (C) void   wxStyledTextCtrl_SetSearchFlags(IntPtr self, int flags);
        static extern (C) int    wxStyledTextCtrl_GetSearchFlags(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_CallTipShow(IntPtr self, int pos, string definition);
        static extern (C) void   wxStyledTextCtrl_CallTipCancel(IntPtr self);
        static extern (C) bool   wxStyledTextCtrl_CallTipActive(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_CallTipPosAtStart(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_CallTipSetHighlight(IntPtr self, int start, int end);
        static extern (C) void   wxStyledTextCtrl_CallTipSetBackground(IntPtr self, IntPtr back);
        static extern (C) void   wxStyledTextCtrl_CallTipSetForeground(IntPtr self, IntPtr fore);
        static extern (C) void   wxStyledTextCtrl_CallTipSetForegroundHighlight(IntPtr self, IntPtr fore);
        static extern (C) int    wxStyledTextCtrl_VisibleFromDocLine(IntPtr self, int line);
        static extern (C) int    wxStyledTextCtrl_DocLineFromVisible(IntPtr self, int lineDisplay);
        static extern (C) void   wxStyledTextCtrl_SetFoldLevel(IntPtr self, int line, int level);
        static extern (C) int    wxStyledTextCtrl_GetFoldLevel(IntPtr self, int line);
        static extern (C) int    wxStyledTextCtrl_GetLastChild(IntPtr self, int line, int level);
        static extern (C) int    wxStyledTextCtrl_GetFoldParent(IntPtr self, int line);
        static extern (C) void   wxStyledTextCtrl_ShowLines(IntPtr self, int lineStart, int lineEnd);
        static extern (C) void   wxStyledTextCtrl_HideLines(IntPtr self, int lineStart, int lineEnd);
        static extern (C) bool   wxStyledTextCtrl_GetLineVisible(IntPtr self, int line);
        static extern (C) void   wxStyledTextCtrl_SetFoldExpanded(IntPtr self, int line, bool expanded);
        static extern (C) bool   wxStyledTextCtrl_GetFoldExpanded(IntPtr self, int line);
        static extern (C) void   wxStyledTextCtrl_ToggleFold(IntPtr self, int line);
        static extern (C) void   wxStyledTextCtrl_EnsureVisible(IntPtr self, int line);
        static extern (C) void   wxStyledTextCtrl_SetFoldFlags(IntPtr self, int flags);
        static extern (C) void   wxStyledTextCtrl_EnsureVisibleEnforcePolicy(IntPtr self, int line);
        static extern (C) void   wxStyledTextCtrl_SetTabIndents(IntPtr self, bool tabIndents);
        static extern (C) bool   wxStyledTextCtrl_GetTabIndents(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetBackSpaceUnIndents(IntPtr self, bool bsUnIndents);
        static extern (C) bool   wxStyledTextCtrl_GetBackSpaceUnIndents(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetMouseDwellTime(IntPtr self, int periodMilliseconds);
        static extern (C) int    wxStyledTextCtrl_GetMouseDwellTime(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_WordStartPosition(IntPtr self, int pos, bool onlyWordCharacters);
        static extern (C) int    wxStyledTextCtrl_WordEndPosition(IntPtr self, int pos, bool onlyWordCharacters);
        static extern (C) void   wxStyledTextCtrl_SetWrapMode(IntPtr self, int mode);
        static extern (C) int    wxStyledTextCtrl_GetWrapMode(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetLayoutCache(IntPtr self, int mode);
        static extern (C) int    wxStyledTextCtrl_GetLayoutCache(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetScrollWidth(IntPtr self, int pixelWidth);
        static extern (C) int    wxStyledTextCtrl_GetScrollWidth(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_TextWidth(IntPtr self, int style, string text);
        static extern (C) void   wxStyledTextCtrl_SetEndAtLastLine(IntPtr self, bool endAtLastLine);
        static extern (C) bool   wxStyledTextCtrl_GetEndAtLastLine(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_TextHeight(IntPtr self, int line);
        static extern (C) void   wxStyledTextCtrl_SetUseVerticalScrollBar(IntPtr self, bool show);
        static extern (C) bool   wxStyledTextCtrl_GetUseVerticalScrollBar(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_AppendText(IntPtr self, int length, string text);
        static extern (C) bool   wxStyledTextCtrl_GetTwoPhaseDraw(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetTwoPhaseDraw(IntPtr self, bool twoPhase);
        static extern (C) void   wxStyledTextCtrl_TargetFromSelection(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_LinesJoin(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_LinesSplit(IntPtr self, int pixelWidth);
        static extern (C) void   wxStyledTextCtrl_SetFoldMarginColour(IntPtr self, bool useSetting, IntPtr back);
        static extern (C) void   wxStyledTextCtrl_SetFoldMarginHiColour(IntPtr self, bool useSetting, IntPtr fore);
        static extern (C) void   wxStyledTextCtrl_LineDuplicate(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_HomeDisplay(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_HomeDisplayExtend(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_LineEndDisplay(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_LineEndDisplayExtend(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_MoveCaretInsideView(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_LineLength(IntPtr self, int line);
        static extern (C) void   wxStyledTextCtrl_BraceHighlight(IntPtr self, int pos1, int pos2);
        static extern (C) void   wxStyledTextCtrl_BraceBadLight(IntPtr self, int pos);
        static extern (C) int    wxStyledTextCtrl_BraceMatch(IntPtr self, int pos);
        static extern (C) bool   wxStyledTextCtrl_GetViewEOL(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetViewEOL(IntPtr self, bool visible);
        static extern (C) IntPtr wxStyledTextCtrl_GetDocPointer(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetDocPointer(IntPtr self, IntPtr docPointer);
        static extern (C) void   wxStyledTextCtrl_SetModEventMask(IntPtr self, int mask);
        static extern (C) int    wxStyledTextCtrl_GetEdgeColumn(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetEdgeColumn(IntPtr self, int column);
        static extern (C) int    wxStyledTextCtrl_GetEdgeMode(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetEdgeMode(IntPtr self, int mode);
        static extern (C) IntPtr wxStyledTextCtrl_GetEdgeColour(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetEdgeColour(IntPtr self, IntPtr edgeColour);
        static extern (C) void   wxStyledTextCtrl_SearchAnchor(IntPtr self);
        static extern (C) int    wxStyledTextCtrl_SearchNext(IntPtr self, int flags, string text);
        static extern (C) int    wxStyledTextCtrl_SearchPrev(IntPtr self, int flags, string text);
        static extern (C) int    wxStyledTextCtrl_LinesOnScreen(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_UsePopUp(IntPtr self, bool allowPopUp);
        static extern (C) bool   wxStyledTextCtrl_SelectionIsRectangle(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetZoom(IntPtr self, int zoom);
        static extern (C) int    wxStyledTextCtrl_GetZoom(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_CreateDocument(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_AddRefDocument(IntPtr self, IntPtr docPointer);
        static extern (C) void   wxStyledTextCtrl_ReleaseDocument(IntPtr self, IntPtr docPointer);
        static extern (C) int    wxStyledTextCtrl_GetModEventMask(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetSTCFocus(IntPtr self, bool focus);
        static extern (C) bool   wxStyledTextCtrl_GetSTCFocus(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetStatus(IntPtr self, int statusCode);
        static extern (C) int    wxStyledTextCtrl_GetStatus(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetMouseDownCaptures(IntPtr self, bool captures);
        static extern (C) bool   wxStyledTextCtrl_GetMouseDownCaptures(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetSTCCursor(IntPtr self, int cursorType);
        static extern (C) int    wxStyledTextCtrl_GetSTCCursor(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetControlCharSymbol(IntPtr self, int symbol);
        static extern (C) int    wxStyledTextCtrl_GetControlCharSymbol(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_WordPartLeft(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_WordPartLeftExtend(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_WordPartRight(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_WordPartRightExtend(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetVisiblePolicy(IntPtr self, int visiblePolicy, int visibleSlop);
        static extern (C) void   wxStyledTextCtrl_DelLineLeft(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_DelLineRight(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetXOffset(IntPtr self, int newOffset);
        static extern (C) int    wxStyledTextCtrl_GetXOffset(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_ChooseCaretX(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetXCaretPolicy(IntPtr self, int caretPolicy, int caretSlop);
        static extern (C) void   wxStyledTextCtrl_SetYCaretPolicy(IntPtr self, int caretPolicy, int caretSlop);
        static extern (C) void   wxStyledTextCtrl_SetPrintWrapMode(IntPtr self, int mode);
        static extern (C) int    wxStyledTextCtrl_GetPrintWrapMode(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetHotspotActiveForeground(IntPtr self, bool useSetting, IntPtr fore);
        static extern (C) void   wxStyledTextCtrl_SetHotspotActiveBackground(IntPtr self, bool useSetting, IntPtr back);
        static extern (C) void   wxStyledTextCtrl_SetHotspotActiveUnderline(IntPtr self, bool underline);
        static extern (C) void   wxStyledTextCtrl_StartRecord(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_StopRecord(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetLexer(IntPtr self, int lexer);
        static extern (C) int    wxStyledTextCtrl_GetLexer(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_Colourise(IntPtr self, int start, int end);
        static extern (C) void   wxStyledTextCtrl_SetProperty(IntPtr self, string key, string value);
        static extern (C) void   wxStyledTextCtrl_SetKeyWords(IntPtr self, int keywordSet, string keyWords);
        static extern (C) void   wxStyledTextCtrl_SetLexerLanguage(IntPtr self, string language);
        static extern (C) int    wxStyledTextCtrl_GetCurrentLine(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_StyleSetSpec(IntPtr self, int styleNum, string spec);
        static extern (C) void   wxStyledTextCtrl_StyleSetFont(IntPtr self, int styleNum, IntPtr font);
        static extern (C) void   wxStyledTextCtrl_StyleSetFontAttr(IntPtr self, int styleNum, int size, string faceName, bool bold, bool italic, bool underline);
        static extern (C) void   wxStyledTextCtrl_CmdKeyExecute(IntPtr self, int cmd);
        static extern (C) void   wxStyledTextCtrl_SetMargins(IntPtr self, int left, int right);
        static extern (C) void   wxStyledTextCtrl_GetSelection(IntPtr self, ref int startPos, ref int endPos);
        static extern (C) void   wxStyledTextCtrl_PointFromPosition(IntPtr self, int pos, ref Point pt);
        static extern (C) void   wxStyledTextCtrl_ScrollToLine(IntPtr self, int line);
        static extern (C) void   wxStyledTextCtrl_ScrollToColumn(IntPtr self, int column);
        static extern (C) int    wxStyledTextCtrl_SendMsg(IntPtr self, int msg, int wp, int lp);
        //static extern (C) void   wxStyledTextCtrl_SetVScrollBar(IntPtr self, IntPtr bar);
        //static extern (C) void   wxStyledTextCtrl_SetHScrollBar(IntPtr self, IntPtr bar);
        static extern (C) bool   wxStyledTextCtrl_GetLastKeydownProcessed(IntPtr self);
        static extern (C) void   wxStyledTextCtrl_SetLastKeydownProcessed(IntPtr self, bool val);
        static extern (C) bool   wxStyledTextCtrl_SaveFile(IntPtr self, string filename);
        static extern (C) bool   wxStyledTextCtrl_LoadFile(IntPtr self, string filename);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias StyledTextCtrl wxStyledTextCtrl;
    public class StyledTextCtrl : Control 
    {
        //-----------------------------------------------------------------------------

        // StyledTextCtrl Events
 
        public static /*readonly*/ EventType wxEVT_STC_CHANGE;
        public static /*readonly*/ EventType wxEVT_STC_STYLENEEDED;
        public static /*readonly*/ EventType wxEVT_STC_CHARADDED;
        public static /*readonly*/ EventType wxEVT_STC_SAVEPOINTREACHED;
        public static /*readonly*/ EventType wxEVT_STC_SAVEPOINTLEFT;  
        public static /*readonly*/ EventType wxEVT_STC_ROMODIFYATTEMPT;
        public static /*readonly*/ EventType wxEVT_STC_KEY;
        public static /*readonly*/ EventType wxEVT_STC_DOUBLECLICK;
        public static /*readonly*/ EventType wxEVT_STC_UPDATEUI;
        public static /*readonly*/ EventType wxEVT_STC_MODIFIED;
        public static /*readonly*/ EventType wxEVT_STC_MACRORECORD;
        public static /*readonly*/ EventType wxEVT_STC_MARGINCLICK;
        public static /*readonly*/ EventType wxEVT_STC_NEEDSHOWN;
        //public static /*readonly*/ EventType wxEVT_STC_POSCHANGED;
        public static /*readonly*/ EventType wxEVT_STC_PAINTED;
        public static /*readonly*/ EventType wxEVT_STC_USERLISTSELECTION;
        public static /*readonly*/ EventType wxEVT_STC_URIDROPPED;
        public static /*readonly*/ EventType wxEVT_STC_DWELLSTART;
        public static /*readonly*/ EventType wxEVT_STC_DWELLEND;
        public static /*readonly*/ EventType wxEVT_STC_START_DRAG;
        public static /*readonly*/ EventType wxEVT_STC_DRAG_OVER;
        public static /*readonly*/ EventType wxEVT_STC_DO_DROP;
        public static /*readonly*/ EventType wxEVT_STC_ZOOM;
        public static /*readonly*/ EventType wxEVT_STC_HOTSPOT_CLICK;
        public static /*readonly*/ EventType wxEVT_STC_HOTSPOT_DCLICK;
        public static /*readonly*/ EventType wxEVT_STC_CALLTIP_CLICK;

        //-----------------------------------------------------------------------------

        public const int wxSTC_INVALID_POSITION = -1;

        // Define start of Scintilla messages to be greater than all edit (EM_*) messages
        // as many EM_ messages can be used although that use is deprecated.
        public const int wxSTC_START = 2000;
        public const int wxSTC_OPTIONAL_START = 3000;
        public const int wxSTC_LEXER_START = 4000;
        public const int wxSTC_WS_INVISIBLE = 0;
        public const int wxSTC_WS_VISIBLEALWAYS = 1;
        public const int wxSTC_WS_VISIBLEAFTERINDENT = 2;
        public const int wxSTC_EOL_CRLF = 0;
        public const int wxSTC_EOL_CR = 1;
        public const int wxSTC_EOL_LF = 2;

        // The SC_CP_UTF8 value can be used to enter Unicode mode.
        // This is the same value as CP_UTF8 in Windows
        public const int wxSTC_CP_UTF8 = 65001;

        // The SC_CP_DBCS value can be used to indicate a DBCS mode for GTK+.
        public const int wxSTC_CP_DBCS = 1;
        public const int wxSTC_MARKER_MAX = 31;
        public const int wxSTC_MARK_CIRCLE = 0;
        public const int wxSTC_MARK_ROUNDRECT = 1;
        public const int wxSTC_MARK_ARROW = 2;
        public const int wxSTC_MARK_SMALLRECT = 3;
        public const int wxSTC_MARK_SHORTARROW = 4;
        public const int wxSTC_MARK_EMPTY = 5;
        public const int wxSTC_MARK_ARROWDOWN = 6;
        public const int wxSTC_MARK_MINUS = 7;
        public const int wxSTC_MARK_PLUS = 8;

        // Shapes used for outlining column.
        public const int wxSTC_MARK_VLINE = 9;
        public const int wxSTC_MARK_LCORNER = 10;
        public const int wxSTC_MARK_TCORNER = 11;
        public const int wxSTC_MARK_BOXPLUS = 12;
        public const int wxSTC_MARK_BOXPLUSCONNECTED = 13;
        public const int wxSTC_MARK_BOXMINUS = 14;
        public const int wxSTC_MARK_BOXMINUSCONNECTED = 15;
        public const int wxSTC_MARK_LCORNERCURVE = 16;
        public const int wxSTC_MARK_TCORNERCURVE = 17;
        public const int wxSTC_MARK_CIRCLEPLUS = 18;
        public const int wxSTC_MARK_CIRCLEPLUSCONNECTED = 19;
        public const int wxSTC_MARK_CIRCLEMINUS = 20;
        public const int wxSTC_MARK_CIRCLEMINUSCONNECTED = 21;

        // Invisible mark that only sets the line background color.
        public const int wxSTC_MARK_BACKGROUND = 22;
        public const int wxSTC_MARK_DOTDOTDOT = 23;
        public const int wxSTC_MARK_ARROWS = 24;
        public const int wxSTC_MARK_PIXMAP = 25;
        public const int wxSTC_MARK_CHARACTER = 10000;

        // Markers used for outlining column.
        public const int wxSTC_MARKNUM_FOLDEREND = 25;
        public const int wxSTC_MARKNUM_FOLDEROPENMID = 26;
        public const int wxSTC_MARKNUM_FOLDERMIDTAIL = 27;
        public const int wxSTC_MARKNUM_FOLDERTAIL = 28;
        public const int wxSTC_MARKNUM_FOLDERSUB = 29;
        public const int wxSTC_MARKNUM_FOLDER = 30;
        public const int wxSTC_MARKNUM_FOLDEROPEN = 31;
        public const int wxSTC_MASK_FOLDERS = -1;
        public const int wxSTC_MARGIN_SYMBOL = 0;
        public const int wxSTC_MARGIN_NUMBER = 1;

        // Styles in range 32..37 are predefined for parts of the UI and are not used as normal styles.
        // Styles 38 and 39 are for future use.
        public const int wxSTC_STYLE_DEFAULT = 32;
        public const int wxSTC_STYLE_LINENUMBER = 33;
        public const int wxSTC_STYLE_BRACELIGHT = 34;
        public const int wxSTC_STYLE_BRACEBAD = 35;
        public const int wxSTC_STYLE_CONTROLCHAR = 36;
        public const int wxSTC_STYLE_INDENTGUIDE = 37;
        public const int wxSTC_STYLE_LASTPREDEFINED = 39;
        public const int wxSTC_STYLE_MAX = 127;

        // Character set identifiers are used in StyleSetCharacterSet.
        // The values are the same as the Windows *_CHARSET values.
        public const int wxSTC_CHARSET_ANSI = 0;
        public const int wxSTC_CHARSET_DEFAULT = 1;
        public const int wxSTC_CHARSET_BALTIC = 186;
        public const int wxSTC_CHARSET_CHINESEBIG5 = 136;
        public const int wxSTC_CHARSET_EASTEUROPE = 238;
        public const int wxSTC_CHARSET_GB2312 = 134;
        public const int wxSTC_CHARSET_GREEK = 161;
        public const int wxSTC_CHARSET_HANGUL = 129;
        public const int wxSTC_CHARSET_MAC = 77;
        public const int wxSTC_CHARSET_OEM = 255;
        public const int wxSTC_CHARSET_RUSSIAN = 204;
        public const int wxSTC_CHARSET_SHIFTJIS = 128;
        public const int wxSTC_CHARSET_SYMBOL = 2;
        public const int wxSTC_CHARSET_TURKISH = 162;
        public const int wxSTC_CHARSET_JOHAB = 130;
        public const int wxSTC_CHARSET_HEBREW = 177;
        public const int wxSTC_CHARSET_ARABIC = 178;
        public const int wxSTC_CHARSET_VIETNAMESE = 163;
        public const int wxSTC_CHARSET_THAI = 222;
        public const int wxSTC_CASE_MIXED = 0;
        public const int wxSTC_CASE_UPPER = 1;
        public const int wxSTC_CASE_LOWER = 2;
        public const int wxSTC_INDIC_MAX = 7;
        public const int wxSTC_INDIC_PLAIN = 0;
        public const int wxSTC_INDIC_SQUIGGLE = 1;
        public const int wxSTC_INDIC_TT = 2;
        public const int wxSTC_INDIC_DIAGONAL = 3;
        public const int wxSTC_INDIC_STRIKE = 4;
        public const int wxSTC_INDIC0_MASK = 0x20;
        public const int wxSTC_INDIC1_MASK = 0x40;
        public const int wxSTC_INDIC2_MASK = 0x80;
        public const int wxSTC_INDICS_MASK = 0xE0;

        // PrintColourMode - use same colours as screen.
        public const int wxSTC_PRINT_NORMAL = 0;

        // PrintColourMode - invert the light value of each style for printing.
        public const int wxSTC_PRINT_INVERTLIGHT = 1;

        // PrintColourMode - force black text on white background for printing.
        public const int wxSTC_PRINT_BLACKONWHITE = 2;

        // PrintColourMode - text stays coloured, but all background is forced to be white for printing.
        public const int wxSTC_PRINT_COLOURONWHITE = 3;

        // PrintColourMode - only the default-background is forced to be white for printing.
        public const int wxSTC_PRINT_COLOURONWHITEDEFAULTBG = 4;
        public const int wxSTC_FIND_WHOLEWORD = 2;
        public const int wxSTC_FIND_MATCHCASE = 4;
        public const int wxSTC_FIND_WORDSTART = 0x00100000;
        public const int wxSTC_FIND_REGEXP = 0x00200000;
        public const int wxSTC_FIND_POSIX = 0x00400000;
        public const int wxSTC_FOLDLEVELBASE = 0x400;
        public const int wxSTC_FOLDLEVELWHITEFLAG = 0x1000;
        public const int wxSTC_FOLDLEVELHEADERFLAG = 0x2000;
        public const int wxSTC_FOLDLEVELBOXHEADERFLAG = 0x4000;
        public const int wxSTC_FOLDLEVELBOXFOOTERFLAG = 0x8000;
        public const int wxSTC_FOLDLEVELCONTRACTED = 0x10000;
        public const int wxSTC_FOLDLEVELUNINDENT = 0x20000;
        public const int wxSTC_FOLDLEVELNUMBERMASK = 0x0FFF;
        public const int wxSTC_FOLDFLAG_LINEBEFORE_EXPANDED = 0x0002;
        public const int wxSTC_FOLDFLAG_LINEBEFORE_CONTRACTED = 0x0004;
        public const int wxSTC_FOLDFLAG_LINEAFTER_EXPANDED = 0x0008;
        public const int wxSTC_FOLDFLAG_LINEAFTER_CONTRACTED = 0x0010;
        public const int wxSTC_FOLDFLAG_LEVELNUMBERS = 0x0040;
        public const int wxSTC_FOLDFLAG_BOX = 0x0001;
        public const int wxSTC_TIME_FOREVER = 10000000;
        public const int wxSTC_WRAP_NONE = 0;
        public const int wxSTC_WRAP_WORD = 1;
        public const int wxSTC_CACHE_NONE = 0;
        public const int wxSTC_CACHE_CARET = 1;
        public const int wxSTC_CACHE_PAGE = 2;
        public const int wxSTC_CACHE_DOCUMENT = 3;
        public const int wxSTC_EDGE_NONE = 0;
        public const int wxSTC_EDGE_LINE = 1;
        public const int wxSTC_EDGE_BACKGROUND = 2;
        public const int wxSTC_CURSORNORMAL = -1;
        public const int wxSTC_CURSORWAIT = 4;

        // Constants for use with SetVisiblePolicy, similar to SetCaretPolicy.
        public const int wxSTC_VISIBLE_SLOP = 0x01;
        public const int wxSTC_VISIBLE_STRICT = 0x04;

        // Caret policy, used by SetXCaretPolicy and SetYCaretPolicy.
        // If CARET_SLOP is set, we can define a slop value: caretSlop.
        // This value defines an unwanted zone (UZ) where the caret is... unwanted.
        // This zone is defined as a number of pixels near the vertical margins,
        // and as a number of lines near the horizontal margins.
        // By keeping the caret away from the edges, it is seen within its context,
        // so it is likely that the identifier that the caret is on can be completely seen,
        // and that the current line is seen with some of the lines following it which are
        // often dependent on that line.
        public const int wxSTC_CARET_SLOP = 0x01;

        // If CARET_STRICT is set, the policy is enforced... strictly.
        // The caret is centred on the display if slop is not set,
        // and cannot go in the UZ if slop is set.
        public const int wxSTC_CARET_STRICT = 0x04;

        // If CARET_JUMPS is set, the display is moved more energetically
        // so the caret can move in the same direction longer before the policy is applied again.
        public const int wxSTC_CARET_JUMPS = 0x10;

        // If CARET_EVEN is not set, instead of having symmetrical UZs,
        // the left and bottom UZs are extended up to right and top UZs respectively.
        // This way, we favour the displaying of useful information: the begining of lines,
        // where most code reside, and the lines after the caret, eg. the body of a function.
        public const int wxSTC_CARET_EVEN = 0x08;

        // Notifications
        // Type of modification and the action which caused the modification.
        // These are defined as a bit mask to make it easy to specify which notifications are wanted.
        // One bit is set from each of SC_MOD_* and SC_PERFORMED_*.
        public const int wxSTC_MOD_INSERTTEXT = 0x1;
        public const int wxSTC_MOD_DELETETEXT = 0x2;
        public const int wxSTC_MOD_CHANGESTYLE = 0x4;
        public const int wxSTC_MOD_CHANGEFOLD = 0x8;
        public const int wxSTC_PERFORMED_USER = 0x10;
        public const int wxSTC_PERFORMED_UNDO = 0x20;
        public const int wxSTC_PERFORMED_REDO = 0x40;
        public const int wxSTC_LASTSTEPINUNDOREDO = 0x100;
        public const int wxSTC_MOD_CHANGEMARKER = 0x200;
        public const int wxSTC_MOD_BEFOREINSERT = 0x400;
        public const int wxSTC_MOD_BEFOREDELETE = 0x800;
        public const int wxSTC_MODEVENTMASKALL = 0xF77;

        // Symbolic key codes and modifier flags.
        // ASCII and other printable characters below 256.
        // Extended keys above 300.
        public const int wxSTC_KEY_DOWN = 300;
        public const int wxSTC_KEY_UP = 301;
        public const int wxSTC_KEY_LEFT = 302;
        public const int wxSTC_KEY_RIGHT = 303;
        public const int wxSTC_KEY_HOME = 304;
        public const int wxSTC_KEY_END = 305;
        public const int wxSTC_KEY_PRIOR = 306;
        public const int wxSTC_KEY_NEXT = 307;
        public const int wxSTC_KEY_DELETE = 308;
        public const int wxSTC_KEY_INSERT = 309;
        public const int wxSTC_KEY_ESCAPE = 7;
        public const int wxSTC_KEY_BACK = 8;
        public const int wxSTC_KEY_TAB = 9;
        public const int wxSTC_KEY_RETURN = 13;
        public const int wxSTC_KEY_ADD = 310;
        public const int wxSTC_KEY_SUBTRACT = 311;
        public const int wxSTC_KEY_DIVIDE = 312;
        public const int wxSTC_SCMOD_SHIFT = 1;
        public const int wxSTC_SCMOD_CTRL = 2;
        public const int wxSTC_SCMOD_ALT = 4;

        // For SciLexer.h
        public const int wxSTC_LEX_CONTAINER = 0;
        public const int wxSTC_LEX_NULL = 1;
        public const int wxSTC_LEX_PYTHON = 2;
        public const int wxSTC_LEX_CPP = 3;
        public const int wxSTC_LEX_HTML = 4;
        public const int wxSTC_LEX_XML = 5;
        public const int wxSTC_LEX_PERL = 6;
        public const int wxSTC_LEX_SQL = 7;
        public const int wxSTC_LEX_VB = 8;
        public const int wxSTC_LEX_PROPERTIES = 9;
        public const int wxSTC_LEX_ERRORLIST = 10;
        public const int wxSTC_LEX_MAKEFILE = 11;
        public const int wxSTC_LEX_BATCH = 12;
        public const int wxSTC_LEX_XCODE = 13;
        public const int wxSTC_LEX_LATEX = 14;
        public const int wxSTC_LEX_LUA = 15;
        public const int wxSTC_LEX_DIFF = 16;
        public const int wxSTC_LEX_CONF = 17;
        public const int wxSTC_LEX_PASCAL = 18;
        public const int wxSTC_LEX_AVE = 19;
        public const int wxSTC_LEX_ADA = 20;
        public const int wxSTC_LEX_LISP = 21;
        public const int wxSTC_LEX_RUBY = 22;
        public const int wxSTC_LEX_EIFFEL = 23;
        public const int wxSTC_LEX_EIFFELKW = 24;
        public const int wxSTC_LEX_TCL = 25;
        public const int wxSTC_LEX_NNCRONTAB = 26;
        public const int wxSTC_LEX_BULLANT = 27;
        public const int wxSTC_LEX_VBSCRIPT = 28;
        public const int wxSTC_LEX_ASP = 29;
        public const int wxSTC_LEX_PHP = 30;
        public const int wxSTC_LEX_BAAN = 31;
        public const int wxSTC_LEX_MATLAB = 32;
        public const int wxSTC_LEX_SCRIPTOL = 33;
        public const int wxSTC_LEX_ASM = 34;
        public const int wxSTC_LEX_CPPNOCASE = 35;
        public const int wxSTC_LEX_FORTRAN = 36;
        public const int wxSTC_LEX_F77 = 37;
        public const int wxSTC_LEX_CSS = 38;
        public const int wxSTC_LEX_POV = 39;

        // When a lexer specifies its language as SCLEX_AUTOMATIC it receives a
        // value assigned in sequence from SCLEX_AUTOMATIC+1.
        public const int wxSTC_LEX_AUTOMATIC = 1000;

        // Lexical states for SCLEX_PYTHON
        public const int wxSTC_P_DEFAULT = 0;
        public const int wxSTC_P_COMMENTLINE = 1;
        public const int wxSTC_P_NUMBER = 2;
        public const int wxSTC_P_STRING = 3;
        public const int wxSTC_P_CHARACTER = 4;
        public const int wxSTC_P_WORD = 5;
        public const int wxSTC_P_TRIPLE = 6;
        public const int wxSTC_P_TRIPLEDOUBLE = 7;
        public const int wxSTC_P_CLASSNAME = 8;
        public const int wxSTC_P_DEFNAME = 9;
        public const int wxSTC_P_OPERATOR = 10;
        public const int wxSTC_P_IDENTIFIER = 11;
        public const int wxSTC_P_COMMENTBLOCK = 12;
        public const int wxSTC_P_STRINGEOL = 13;

        // Lexical states for SCLEX_CPP
        public const int wxSTC_C_DEFAULT = 0;
        public const int wxSTC_C_COMMENT = 1;
        public const int wxSTC_C_COMMENTLINE = 2;
        public const int wxSTC_C_COMMENTDOC = 3;
        public const int wxSTC_C_NUMBER = 4;
        public const int wxSTC_C_WORD = 5;
        public const int wxSTC_C_STRING = 6;
        public const int wxSTC_C_CHARACTER = 7;
        public const int wxSTC_C_UUID = 8;
        public const int wxSTC_C_PREPROCESSOR = 9;
        public const int wxSTC_C_OPERATOR = 10;
        public const int wxSTC_C_IDENTIFIER = 11;
        public const int wxSTC_C_STRINGEOL = 12;
        public const int wxSTC_C_VERBATIM = 13;
        public const int wxSTC_C_REGEX = 14;
        public const int wxSTC_C_COMMENTLINEDOC = 15;
        public const int wxSTC_C_WORD2 = 16;
        public const int wxSTC_C_COMMENTDOCKEYWORD = 17;
        public const int wxSTC_C_COMMENTDOCKEYWORDERROR = 18;

        // Lexical states for SCLEX_HTML, SCLEX_XML
        public const int wxSTC_H_DEFAULT = 0;
        public const int wxSTC_H_TAG = 1;
        public const int wxSTC_H_TAGUNKNOWN = 2;
        public const int wxSTC_H_ATTRIBUTE = 3;
        public const int wxSTC_H_ATTRIBUTEUNKNOWN = 4;
        public const int wxSTC_H_NUMBER = 5;
        public const int wxSTC_H_DOUBLESTRING = 6;
        public const int wxSTC_H_SINGLESTRING = 7;
        public const int wxSTC_H_OTHER = 8;
        public const int wxSTC_H_COMMENT = 9;
        public const int wxSTC_H_ENTITY = 10;

        // XML and ASP
        public const int wxSTC_H_TAGEND = 11;
        public const int wxSTC_H_XMLSTART = 12;
        public const int wxSTC_H_XMLEND = 13;
        public const int wxSTC_H_SCRIPT = 14;
        public const int wxSTC_H_ASP = 15;
        public const int wxSTC_H_ASPAT = 16;
        public const int wxSTC_H_CDATA = 17;
        public const int wxSTC_H_QUESTION = 18;

        // More HTML
        public const int wxSTC_H_VALUE = 19;

        // X-Code
        public const int wxSTC_H_XCCOMMENT = 20;

        // SGML
        public const int wxSTC_H_SGML_DEFAULT = 21;
        public const int wxSTC_H_SGML_COMMAND = 22;
        public const int wxSTC_H_SGML_1ST_PARAM = 23;
        public const int wxSTC_H_SGML_DOUBLESTRING = 24;
        public const int wxSTC_H_SGML_SIMPLESTRING = 25;
        public const int wxSTC_H_SGML_ERROR = 26;
        public const int wxSTC_H_SGML_SPECIAL = 27;
        public const int wxSTC_H_SGML_ENTITY = 28;
        public const int wxSTC_H_SGML_COMMENT = 29;
        public const int wxSTC_H_SGML_1ST_PARAM_COMMENT = 30;
        public const int wxSTC_H_SGML_BLOCK_DEFAULT = 31;

        // Embedded Javascript
        public const int wxSTC_HJ_START = 40;
        public const int wxSTC_HJ_DEFAULT = 41;
        public const int wxSTC_HJ_COMMENT = 42;
        public const int wxSTC_HJ_COMMENTLINE = 43;
        public const int wxSTC_HJ_COMMENTDOC = 44;
        public const int wxSTC_HJ_NUMBER = 45;
        public const int wxSTC_HJ_WORD = 46;
        public const int wxSTC_HJ_KEYWORD = 47;
        public const int wxSTC_HJ_DOUBLESTRING = 48;
        public const int wxSTC_HJ_SINGLESTRING = 49;
        public const int wxSTC_HJ_SYMBOLS = 50;
        public const int wxSTC_HJ_STRINGEOL = 51;
        public const int wxSTC_HJ_REGEX = 52;

        // ASP Javascript
        public const int wxSTC_HJA_START = 55;
        public const int wxSTC_HJA_DEFAULT = 56;
        public const int wxSTC_HJA_COMMENT = 57;
        public const int wxSTC_HJA_COMMENTLINE = 58;
        public const int wxSTC_HJA_COMMENTDOC = 59;
        public const int wxSTC_HJA_NUMBER = 60;
        public const int wxSTC_HJA_WORD = 61;
        public const int wxSTC_HJA_KEYWORD = 62;
        public const int wxSTC_HJA_DOUBLESTRING = 63;
        public const int wxSTC_HJA_SINGLESTRING = 64;
        public const int wxSTC_HJA_SYMBOLS = 65;
        public const int wxSTC_HJA_STRINGEOL = 66;
        public const int wxSTC_HJA_REGEX = 67;

        // Embedded VBScript
        public const int wxSTC_HB_START = 70;
        public const int wxSTC_HB_DEFAULT = 71;
        public const int wxSTC_HB_COMMENTLINE = 72;
        public const int wxSTC_HB_NUMBER = 73;
        public const int wxSTC_HB_WORD = 74;
        public const int wxSTC_HB_STRING = 75;
        public const int wxSTC_HB_IDENTIFIER = 76;
        public const int wxSTC_HB_STRINGEOL = 77;

        // ASP VBScript
        public const int wxSTC_HBA_START = 80;
        public const int wxSTC_HBA_DEFAULT = 81;
        public const int wxSTC_HBA_COMMENTLINE = 82;
        public const int wxSTC_HBA_NUMBER = 83;
        public const int wxSTC_HBA_WORD = 84;
        public const int wxSTC_HBA_STRING = 85;
        public const int wxSTC_HBA_IDENTIFIER = 86;
        public const int wxSTC_HBA_STRINGEOL = 87;

        // Embedded Python
        public const int wxSTC_HP_START = 90;
        public const int wxSTC_HP_DEFAULT = 91;
        public const int wxSTC_HP_COMMENTLINE = 92;
        public const int wxSTC_HP_NUMBER = 93;
        public const int wxSTC_HP_STRING = 94;
        public const int wxSTC_HP_CHARACTER = 95;
        public const int wxSTC_HP_WORD = 96;
        public const int wxSTC_HP_TRIPLE = 97;
        public const int wxSTC_HP_TRIPLEDOUBLE = 98;
        public const int wxSTC_HP_CLASSNAME = 99;
        public const int wxSTC_HP_DEFNAME = 100;
        public const int wxSTC_HP_OPERATOR = 101;
        public const int wxSTC_HP_IDENTIFIER = 102;

        // ASP Python
        public const int wxSTC_HPA_START = 105;
        public const int wxSTC_HPA_DEFAULT = 106;
        public const int wxSTC_HPA_COMMENTLINE = 107;
        public const int wxSTC_HPA_NUMBER = 108;
        public const int wxSTC_HPA_STRING = 109;
        public const int wxSTC_HPA_CHARACTER = 110;
        public const int wxSTC_HPA_WORD = 111;
        public const int wxSTC_HPA_TRIPLE = 112;
        public const int wxSTC_HPA_TRIPLEDOUBLE = 113;
        public const int wxSTC_HPA_CLASSNAME = 114;
        public const int wxSTC_HPA_DEFNAME = 115;
        public const int wxSTC_HPA_OPERATOR = 116;
        public const int wxSTC_HPA_IDENTIFIER = 117;

        // PHP
        public const int wxSTC_HPHP_DEFAULT = 118;
        public const int wxSTC_HPHP_HSTRING = 119;
        public const int wxSTC_HPHP_SIMPLESTRING = 120;
        public const int wxSTC_HPHP_WORD = 121;
        public const int wxSTC_HPHP_NUMBER = 122;
        public const int wxSTC_HPHP_VARIABLE = 123;
        public const int wxSTC_HPHP_COMMENT = 124;
        public const int wxSTC_HPHP_COMMENTLINE = 125;
        public const int wxSTC_HPHP_HSTRING_VARIABLE = 126;
        public const int wxSTC_HPHP_OPERATOR = 127;

        // Lexical states for SCLEX_PERL
        public const int wxSTC_PL_DEFAULT = 0;
        public const int wxSTC_PL_ERROR = 1;
        public const int wxSTC_PL_COMMENTLINE = 2;
        public const int wxSTC_PL_POD = 3;
        public const int wxSTC_PL_NUMBER = 4;
        public const int wxSTC_PL_WORD = 5;
        public const int wxSTC_PL_STRING = 6;
        public const int wxSTC_PL_CHARACTER = 7;
        public const int wxSTC_PL_PUNCTUATION = 8;
        public const int wxSTC_PL_PREPROCESSOR = 9;
        public const int wxSTC_PL_OPERATOR = 10;
        public const int wxSTC_PL_IDENTIFIER = 11;
        public const int wxSTC_PL_SCALAR = 12;
        public const int wxSTC_PL_ARRAY = 13;
        public const int wxSTC_PL_HASH = 14;
        public const int wxSTC_PL_SYMBOLTABLE = 15;
        public const int wxSTC_PL_REGEX = 17;
        public const int wxSTC_PL_REGSUBST = 18;
        public const int wxSTC_PL_LONGQUOTE = 19;
        public const int wxSTC_PL_BACKTICKS = 20;
        public const int wxSTC_PL_DATASECTION = 21;
        public const int wxSTC_PL_HERE_DELIM = 22;
        public const int wxSTC_PL_HERE_Q = 23;
        public const int wxSTC_PL_HERE_QQ = 24;
        public const int wxSTC_PL_HERE_QX = 25;
        public const int wxSTC_PL_STRING_Q = 26;
        public const int wxSTC_PL_STRING_QQ = 27;
        public const int wxSTC_PL_STRING_QX = 28;
        public const int wxSTC_PL_STRING_QR = 29;
        public const int wxSTC_PL_STRING_QW = 30;

        // Lexical states for SCLEX_VB, SCLEX_VBSCRIPT
        public const int wxSTC_B_DEFAULT = 0;
        public const int wxSTC_B_COMMENT = 1;
        public const int wxSTC_B_NUMBER = 2;
        public const int wxSTC_B_KEYWORD = 3;
        public const int wxSTC_B_STRING = 4;
        public const int wxSTC_B_PREPROCESSOR = 5;
        public const int wxSTC_B_OPERATOR = 6;
        public const int wxSTC_B_IDENTIFIER = 7;
        public const int wxSTC_B_DATE = 8;

        // Lexical states for SCLEX_PROPERTIES
        public const int wxSTC_PROPS_DEFAULT = 0;
        public const int wxSTC_PROPS_COMMENT = 1;
        public const int wxSTC_PROPS_SECTION = 2;
        public const int wxSTC_PROPS_ASSIGNMENT = 3;
        public const int wxSTC_PROPS_DEFVAL = 4;

        // Lexical states for SCLEX_LATEX
        public const int wxSTC_L_DEFAULT = 0;
        public const int wxSTC_L_COMMAND = 1;
        public const int wxSTC_L_TAG = 2;
        public const int wxSTC_L_MATH = 3;
        public const int wxSTC_L_COMMENT = 4;

        // Lexical states for SCLEX_LUA
        public const int wxSTC_LUA_DEFAULT = 0;
        public const int wxSTC_LUA_COMMENT = 1;
        public const int wxSTC_LUA_COMMENTLINE = 2;
        public const int wxSTC_LUA_COMMENTDOC = 3;
        public const int wxSTC_LUA_NUMBER = 4;
        public const int wxSTC_LUA_WORD = 5;
        public const int wxSTC_LUA_STRING = 6;
        public const int wxSTC_LUA_CHARACTER = 7;
        public const int wxSTC_LUA_LITERALSTRING = 8;
        public const int wxSTC_LUA_PREPROCESSOR = 9;
        public const int wxSTC_LUA_OPERATOR = 10;
        public const int wxSTC_LUA_IDENTIFIER = 11;
        public const int wxSTC_LUA_STRINGEOL = 12;
        public const int wxSTC_LUA_WORD2 = 13;
        public const int wxSTC_LUA_WORD3 = 14;
        public const int wxSTC_LUA_WORD4 = 15;
        public const int wxSTC_LUA_WORD5 = 16;
        public const int wxSTC_LUA_WORD6 = 17;

        // Lexical states for SCLEX_ERRORLIST
        public const int wxSTC_ERR_DEFAULT = 0;
        public const int wxSTC_ERR_PYTHON = 1;
        public const int wxSTC_ERR_GCC = 2;
        public const int wxSTC_ERR_MS = 3;
        public const int wxSTC_ERR_CMD = 4;
        public const int wxSTC_ERR_BORLAND = 5;
        public const int wxSTC_ERR_PERL = 6;
        public const int wxSTC_ERR_NET = 7;
        public const int wxSTC_ERR_LUA = 8;
        public const int wxSTC_ERR_CTAG = 9;
        public const int wxSTC_ERR_DIFF_CHANGED = 10;
        public const int wxSTC_ERR_DIFF_ADDITION = 11;
        public const int wxSTC_ERR_DIFF_DELETION = 12;
        public const int wxSTC_ERR_DIFF_MESSAGE = 13;
        public const int wxSTC_ERR_PHP = 14;
        public const int wxSTC_ERR_ELF = 15;
        public const int wxSTC_ERR_IFC = 16;

        // Lexical states for SCLEX_BATCH
        public const int wxSTC_BAT_DEFAULT = 0;
        public const int wxSTC_BAT_COMMENT = 1;
        public const int wxSTC_BAT_WORD = 2;
        public const int wxSTC_BAT_LABEL = 3;
        public const int wxSTC_BAT_HIDE = 4;
        public const int wxSTC_BAT_COMMAND = 5;
        public const int wxSTC_BAT_IDENTIFIER = 6;
        public const int wxSTC_BAT_OPERATOR = 7;

        // Lexical states for SCLEX_MAKEFILE
        public const int wxSTC_MAKE_DEFAULT = 0;
        public const int wxSTC_MAKE_COMMENT = 1;
        public const int wxSTC_MAKE_PREPROCESSOR = 2;
        public const int wxSTC_MAKE_IDENTIFIER = 3;
        public const int wxSTC_MAKE_OPERATOR = 4;
        public const int wxSTC_MAKE_TARGET = 5;
        public const int wxSTC_MAKE_IDEOL = 9;

        // Lexical states for SCLEX_DIFF
        public const int wxSTC_DIFF_DEFAULT = 0;
        public const int wxSTC_DIFF_COMMENT = 1;
        public const int wxSTC_DIFF_COMMAND = 2;
        public const int wxSTC_DIFF_HEADER = 3;
        public const int wxSTC_DIFF_POSITION = 4;
        public const int wxSTC_DIFF_DELETED = 5;
        public const int wxSTC_DIFF_ADDED = 6;

        // Lexical states for SCLEX_CONF (Apache Configuration Files Lexer)
        public const int wxSTC_CONF_DEFAULT = 0;
        public const int wxSTC_CONF_COMMENT = 1;
        public const int wxSTC_CONF_NUMBER = 2;
        public const int wxSTC_CONF_IDENTIFIER = 3;
        public const int wxSTC_CONF_EXTENSION = 4;
        public const int wxSTC_CONF_PARAMETER = 5;
        public const int wxSTC_CONF_STRING = 6;
        public const int wxSTC_CONF_OPERATOR = 7;
        public const int wxSTC_CONF_IP = 8;
        public const int wxSTC_CONF_DIRECTIVE = 9;

        // Lexical states for SCLEX_AVE, Avenue
        public const int wxSTC_AVE_DEFAULT = 0;
        public const int wxSTC_AVE_COMMENT = 1;
        public const int wxSTC_AVE_NUMBER = 2;
        public const int wxSTC_AVE_WORD = 3;
        public const int wxSTC_AVE_STRING = 6;
        public const int wxSTC_AVE_ENUM = 7;
        public const int wxSTC_AVE_STRINGEOL = 8;
        public const int wxSTC_AVE_IDENTIFIER = 9;
        public const int wxSTC_AVE_OPERATOR = 10;
        public const int wxSTC_AVE_WORD1 = 11;
        public const int wxSTC_AVE_WORD2 = 12;
        public const int wxSTC_AVE_WORD3 = 13;
        public const int wxSTC_AVE_WORD4 = 14;
        public const int wxSTC_AVE_WORD5 = 15;
        public const int wxSTC_AVE_WORD6 = 16;

        // Lexical states for SCLEX_ADA
        public const int wxSTC_ADA_DEFAULT = 0;
        public const int wxSTC_ADA_WORD = 1;
        public const int wxSTC_ADA_IDENTIFIER = 2;
        public const int wxSTC_ADA_NUMBER = 3;
        public const int wxSTC_ADA_DELIMITER = 4;
        public const int wxSTC_ADA_CHARACTER = 5;
        public const int wxSTC_ADA_CHARACTEREOL = 6;
        public const int wxSTC_ADA_STRING = 7;
        public const int wxSTC_ADA_STRINGEOL = 8;
        public const int wxSTC_ADA_LABEL = 9;
        public const int wxSTC_ADA_COMMENTLINE = 10;
        public const int wxSTC_ADA_ILLEGAL = 11;

        // Lexical states for SCLEX_BAAN
        public const int wxSTC_BAAN_DEFAULT = 0;
        public const int wxSTC_BAAN_COMMENT = 1;
        public const int wxSTC_BAAN_COMMENTDOC = 2;
        public const int wxSTC_BAAN_NUMBER = 3;
        public const int wxSTC_BAAN_WORD = 4;
        public const int wxSTC_BAAN_STRING = 5;
        public const int wxSTC_BAAN_PREPROCESSOR = 6;
        public const int wxSTC_BAAN_OPERATOR = 7;
        public const int wxSTC_BAAN_IDENTIFIER = 8;
        public const int wxSTC_BAAN_STRINGEOL = 9;
        public const int wxSTC_BAAN_WORD2 = 10;

        // Lexical states for SCLEX_LISP
        public const int wxSTC_LISP_DEFAULT = 0;
        public const int wxSTC_LISP_COMMENT = 1;
        public const int wxSTC_LISP_NUMBER = 2;
        public const int wxSTC_LISP_KEYWORD = 3;
        public const int wxSTC_LISP_STRING = 6;
        public const int wxSTC_LISP_STRINGEOL = 8;
        public const int wxSTC_LISP_IDENTIFIER = 9;
        public const int wxSTC_LISP_OPERATOR = 10;

        // Lexical states for SCLEX_EIFFEL and SCLEX_EIFFELKW
        public const int wxSTC_EIFFEL_DEFAULT = 0;
        public const int wxSTC_EIFFEL_COMMENTLINE = 1;
        public const int wxSTC_EIFFEL_NUMBER = 2;
        public const int wxSTC_EIFFEL_WORD = 3;
        public const int wxSTC_EIFFEL_STRING = 4;
        public const int wxSTC_EIFFEL_CHARACTER = 5;
        public const int wxSTC_EIFFEL_OPERATOR = 6;
        public const int wxSTC_EIFFEL_IDENTIFIER = 7;
        public const int wxSTC_EIFFEL_STRINGEOL = 8;

        // Lexical states for SCLEX_NNCRONTAB (nnCron crontab Lexer)
        public const int wxSTC_NNCRONTAB_DEFAULT = 0;
        public const int wxSTC_NNCRONTAB_COMMENT = 1;
        public const int wxSTC_NNCRONTAB_TASK = 2;
        public const int wxSTC_NNCRONTAB_SECTION = 3;
        public const int wxSTC_NNCRONTAB_KEYWORD = 4;
        public const int wxSTC_NNCRONTAB_MODIFIER = 5;
        public const int wxSTC_NNCRONTAB_ASTERISK = 6;
        public const int wxSTC_NNCRONTAB_NUMBER = 7;
        public const int wxSTC_NNCRONTAB_STRING = 8;
        public const int wxSTC_NNCRONTAB_ENVIRONMENT = 9;
        public const int wxSTC_NNCRONTAB_IDENTIFIER = 10;

        // Lexical states for SCLEX_MATLAB
        public const int wxSTC_MATLAB_DEFAULT = 0;
        public const int wxSTC_MATLAB_COMMENT = 1;
        public const int wxSTC_MATLAB_COMMAND = 2;
        public const int wxSTC_MATLAB_NUMBER = 3;
        public const int wxSTC_MATLAB_KEYWORD = 4;
        public const int wxSTC_MATLAB_STRING = 5;
        public const int wxSTC_MATLAB_OPERATOR = 6;
        public const int wxSTC_MATLAB_IDENTIFIER = 7;

        // Lexical states for SCLEX_SCRIPTOL
        public const int wxSTC_SCRIPTOL_DEFAULT = 0;
        public const int wxSTC_SCRIPTOL_COMMENT = 1;
        public const int wxSTC_SCRIPTOL_COMMENTLINE = 2;
        public const int wxSTC_SCRIPTOL_COMMENTDOC = 3;
        public const int wxSTC_SCRIPTOL_NUMBER = 4;
        public const int wxSTC_SCRIPTOL_WORD = 5;
        public const int wxSTC_SCRIPTOL_STRING = 6;
        public const int wxSTC_SCRIPTOL_CHARACTER = 7;
        public const int wxSTC_SCRIPTOL_UUID = 8;
        public const int wxSTC_SCRIPTOL_PREPROCESSOR = 9;
        public const int wxSTC_SCRIPTOL_OPERATOR = 10;
        public const int wxSTC_SCRIPTOL_IDENTIFIER = 11;
        public const int wxSTC_SCRIPTOL_STRINGEOL = 12;
        public const int wxSTC_SCRIPTOL_VERBATIM = 13;
        public const int wxSTC_SCRIPTOL_REGEX = 14;
        public const int wxSTC_SCRIPTOL_COMMENTLINEDOC = 15;
        public const int wxSTC_SCRIPTOL_WORD2 = 16;
        public const int wxSTC_SCRIPTOL_COMMENTDOCKEYWORD = 17;
        public const int wxSTC_SCRIPTOL_COMMENTDOCKEYWORDERROR = 18;
        public const int wxSTC_SCRIPTOL_COMMENTBASIC = 19;

        // Lexical states for SCLEX_ASM
        public const int wxSTC_ASM_DEFAULT = 0;
        public const int wxSTC_ASM_COMMENT = 1;
        public const int wxSTC_ASM_NUMBER = 2;
        public const int wxSTC_ASM_STRING = 3;
        public const int wxSTC_ASM_OPERATOR = 4;
        public const int wxSTC_ASM_IDENTIFIER = 5;
        public const int wxSTC_ASM_CPUINSTRUCTION = 6;
        public const int wxSTC_ASM_MATHINSTRUCTION = 7;
        public const int wxSTC_ASM_REGISTER = 8;
        public const int wxSTC_ASM_DIRECTIVE = 9;
        public const int wxSTC_ASM_DIRECTIVEOPERAND = 10;

        // Lexical states for SCLEX_FORTRAN
        public const int wxSTC_F_DEFAULT = 0;
        public const int wxSTC_F_COMMENT = 1;
        public const int wxSTC_F_NUMBER = 2;
        public const int wxSTC_F_STRING1 = 3;
        public const int wxSTC_F_STRING2 = 4;
        public const int wxSTC_F_STRINGEOL = 5;
        public const int wxSTC_F_OPERATOR = 6;
        public const int wxSTC_F_IDENTIFIER = 7;
        public const int wxSTC_F_WORD = 8;
        public const int wxSTC_F_WORD2 = 9;
        public const int wxSTC_F_WORD3 = 10;
        public const int wxSTC_F_PREPROCESSOR = 11;
        public const int wxSTC_F_OPERATOR2 = 12;
        public const int wxSTC_F_LABEL = 13;
        public const int wxSTC_F_CONTINUATION = 14;

        // Lexical states for SCLEX_CSS
        public const int wxSTC_CSS_DEFAULT = 0;
        public const int wxSTC_CSS_TAG = 1;
        public const int wxSTC_CSS_CLASS = 2;
        public const int wxSTC_CSS_PSEUDOCLASS = 3;
        public const int wxSTC_CSS_UNKNOWN_PSEUDOCLASS = 4;
        public const int wxSTC_CSS_OPERATOR = 5;
        public const int wxSTC_CSS_IDENTIFIER = 6;
        public const int wxSTC_CSS_UNKNOWN_IDENTIFIER = 7;
        public const int wxSTC_CSS_VALUE = 8;
        public const int wxSTC_CSS_COMMENT = 9;
        public const int wxSTC_CSS_ID = 10;
        public const int wxSTC_CSS_IMPORTANT = 11;
        public const int wxSTC_CSS_DIRECTIVE = 12;
        public const int wxSTC_CSS_DOUBLESTRING = 13;
        public const int wxSTC_CSS_SINGLESTRING = 14;

        // Lexical states for SCLEX_POV
        public const int wxSTC_POV_DEFAULT = 0;
        public const int wxSTC_POV_COMMENT = 1;
        public const int wxSTC_POV_COMMENTLINE = 2;
        public const int wxSTC_POV_COMMENTDOC = 3;
        public const int wxSTC_POV_NUMBER = 4;
        public const int wxSTC_POV_WORD = 5;
        public const int wxSTC_POV_STRING = 6;
        public const int wxSTC_POV_OPERATOR = 7;
        public const int wxSTC_POV_IDENTIFIER = 8;
        public const int wxSTC_POV_BRACE = 9;
        public const int wxSTC_POV_WORD2 = 10;


        //-----------------------------------------
        // Commands that can be bound to keystrokes

        // Redoes the next action on the undo history.
        public const int wxSTC_CMD_REDO = 2011;

        // Select all the text in the document.
        public const int wxSTC_CMD_SELECTALL = 2013;

        // Undo one action in the undo history.
        public const int wxSTC_CMD_UNDO = 2176;

        // Cut the selection to the clipboard.
        public const int wxSTC_CMD_CUT = 2177;

        // Copy the selection to the clipboard.
        public const int wxSTC_CMD_COPY = 2178;

        // Paste the contents of the clipboard into the document replacing the selection.
        public const int wxSTC_CMD_PASTE = 2179;

        // Clear the selection.
        public const int wxSTC_CMD_CLEAR = 2180;

        // Move caret down one line.
        public const int wxSTC_CMD_LINEDOWN = 2300;

        // Move caret down one line extending selection to new caret position.
        public const int wxSTC_CMD_LINEDOWNEXTEND = 2301;

        // Move caret up one line.
        public const int wxSTC_CMD_LINEUP = 2302;

        // Move caret up one line extending selection to new caret position.
        public const int wxSTC_CMD_LINEUPEXTEND = 2303;

        // Move caret left one character.
        public const int wxSTC_CMD_CHARLEFT = 2304;

        // Move caret left one character extending selection to new caret position.
        public const int wxSTC_CMD_CHARLEFTEXTEND = 2305;

        // Move caret right one character.
        public const int wxSTC_CMD_CHARRIGHT = 2306;

        // Move caret right one character extending selection to new caret position.
        public const int wxSTC_CMD_CHARRIGHTEXTEND = 2307;

        // Move caret left one word.
        public const int wxSTC_CMD_WORDLEFT = 2308;

        // Move caret left one word extending selection to new caret position.
        public const int wxSTC_CMD_WORDLEFTEXTEND = 2309;

        // Move caret right one word.
        public const int wxSTC_CMD_WORDRIGHT = 2310;

        // Move caret right one word extending selection to new caret position.
        public const int wxSTC_CMD_WORDRIGHTEXTEND = 2311;

        // Move caret to first position on line.
        public const int wxSTC_CMD_HOME = 2312;

        // Move caret to first position on line extending selection to new caret position.
        public const int wxSTC_CMD_HOMEEXTEND = 2313;

        // Move caret to last position on line.
        public const int wxSTC_CMD_LINEEND = 2314;

        // Move caret to last position on line extending selection to new caret position.
        public const int wxSTC_CMD_LINEENDEXTEND = 2315;

        // Move caret to first position in document.
        public const int wxSTC_CMD_DOCUMENTSTART = 2316;

        // Move caret to first position in document extending selection to new caret position.
        public const int wxSTC_CMD_DOCUMENTSTARTEXTEND = 2317;

        // Move caret to last position in document.
        public const int wxSTC_CMD_DOCUMENTEND = 2318;

        // Move caret to last position in document extending selection to new caret position.
        public const int wxSTC_CMD_DOCUMENTENDEXTEND = 2319;

        // Move caret one page up.
        public const int wxSTC_CMD_PAGEUP = 2320;

        // Move caret one page up extending selection to new caret position.
        public const int wxSTC_CMD_PAGEUPEXTEND = 2321;

        // Move caret one page down.
        public const int wxSTC_CMD_PAGEDOWN = 2322;

        // Move caret one page down extending selection to new caret position.
        public const int wxSTC_CMD_PAGEDOWNEXTEND = 2323;

        // Switch from insert to overtype mode or the reverse.
        public const int wxSTC_CMD_EDITTOGGLEOVERTYPE = 2324;

        // Cancel any modes such as call tip or auto-completion list display.
        public const int wxSTC_CMD_CANCEL = 2325;

        // Delete the selection or if no selection, the character before the caret.
        public const int wxSTC_CMD_DELETEBACK = 2326;

        // If selection is empty or all on one line replace the selection with a tab character.
        // If more than one line selected, indent the lines.
        public const int wxSTC_CMD_TAB = 2327;

        // Dedent the selected lines.
        public const int wxSTC_CMD_BACKTAB = 2328;

        // Insert a new line, may use a CRLF, CR or LF depending on EOL mode.
        public const int wxSTC_CMD_NEWLINE = 2329;

        // Insert a Form Feed character.
        public const int wxSTC_CMD_FORMFEED = 2330;

        // Move caret to before first visible character on line.
        // If already there move to first character on line.
        public const int wxSTC_CMD_VCHOME = 2331;

        // Like VCHome but extending selection to new caret position.
        public const int wxSTC_CMD_VCHOMEEXTEND = 2332;

        // Magnify the displayed text by increasing the sizes by 1 point.
        public const int wxSTC_CMD_ZOOMIN = 2333;

        // Make the displayed text smaller by decreasing the sizes by 1 point.
        public const int wxSTC_CMD_ZOOMOUT = 2334;

        // Delete the word to the left of the caret.
        public const int wxSTC_CMD_DELWORDLEFT = 2335;

        // Delete the word to the right of the caret.
        public const int wxSTC_CMD_DELWORDRIGHT = 2336;

        // Cut the line containing the caret.
        public const int wxSTC_CMD_LINECUT = 2337;

        // Delete the line containing the caret.
        public const int wxSTC_CMD_LINEDELETE = 2338;

        // Switch the current line with the previous.
        public const int wxSTC_CMD_LINETRANSPOSE = 2339;

        // Duplicate the current line.
        public const int wxSTC_CMD_LINEDUPLICATE = 2404;

        // Transform the selection to lower case.
        public const int wxSTC_CMD_LOWERCASE = 2340;

        // Transform the selection to upper case.
        public const int wxSTC_CMD_UPPERCASE = 2341;

        // Scroll the document down, keeping the caret visible.
        public const int wxSTC_CMD_LINESCROLLDOWN = 2342;

        // Scroll the document up, keeping the caret visible.
        public const int wxSTC_CMD_LINESCROLLUP = 2343;

        // Delete the selection or if no selection, the character before the caret.
        // Will not delete the character before at the start of a line.
        public const int wxSTC_CMD_DELETEBACKNOTLINE = 2344;

        // Move caret to first position on display line.
        public const int wxSTC_CMD_HOMEDISPLAY = 2345;

        // Move caret to first position on display line extending selection to
        // new caret position.
        public const int wxSTC_CMD_HOMEDISPLAYEXTEND = 2346;

        // Move caret to last position on display line.
        public const int wxSTC_CMD_LINEENDDISPLAY = 2347;

        // Move caret to last position on display line extending selection to new
        // caret position.
        public const int wxSTC_CMD_LINEENDDISPLAYEXTEND = 2348;

        // These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)?
        // except they behave differently when word-wrap is enabled:
        // They go first to the start / end of the display line, like (Home|LineEnd)Display
        // The difference is that, the cursor is already at the point, it goes on to the start
        // or end of the document line, as appropriate for (Home|LineEnd|VCHome)Extend.
        public const int wxSTC_CMD_HOMEWRAP = 2349;
        public const int wxSTC_CMD_HOMEWRAPEXTEND = 2450;
        public const int wxSTC_CMD_LINEENDWRAP = 2451;
        public const int wxSTC_CMD_LINEENDWRAPEXTEND = 2452;
        public const int wxSTC_CMD_VCHOMEWRAP = 2453;
        public const int wxSTC_CMD_VCHOMEWRAPEXTEND = 2454;

        // Move to the previous change in capitalisation.
        public const int wxSTC_CMD_WORDPARTLEFT = 2390;

        // Move to the previous change in capitalisation extending selection
        // to new caret position.
        public const int wxSTC_CMD_WORDPARTLEFTEXTEND = 2391;

        // Move to the change next in capitalisation.
        public const int wxSTC_CMD_WORDPARTRIGHT = 2392;

        // Move to the next change in capitalisation extending selection
        // to new caret position.
        public const int wxSTC_CMD_WORDPARTRIGHTEXTEND = 2393;

        // Delete back from the current position to the start of the line.
        public const int wxSTC_CMD_DELLINELEFT = 2395;

        // Delete forwards from the current position to the end of the line.
        public const int wxSTC_CMD_DELLINERIGHT = 2396;

        // Move caret between paragraphs (delimited by empty lines)
        public const int wxSTC_CMD_PARADOWN = 2413;
        public const int wxSTC_CMD_PARADOWNEXTEND = 2414;
        public const int wxSTC_CMD_PARAUP = 2415;
        public const int wxSTC_CMD_PARAUPEXTEND = 2416;

        //-----------------------------------------------------------------------------

        static this()
        {
        	 wxEVT_STC_CHANGE = wxStyledTextCtrl_EVT_STC_CHANGE();
        	 wxEVT_STC_STYLENEEDED = wxStyledTextCtrl_EVT_STC_STYLENEEDED();
        	 wxEVT_STC_CHARADDED = wxStyledTextCtrl_EVT_STC_CHARADDED();
        	 wxEVT_STC_SAVEPOINTREACHED = wxStyledTextCtrl_EVT_STC_SAVEPOINTREACHED();
        	 wxEVT_STC_SAVEPOINTLEFT = wxStyledTextCtrl_EVT_STC_SAVEPOINTLEFT();  
        	 wxEVT_STC_ROMODIFYATTEMPT = wxStyledTextCtrl_EVT_STC_ROMODIFYATTEMPT();
        	 wxEVT_STC_KEY = wxStyledTextCtrl_EVT_STC_KEY();
        	 wxEVT_STC_DOUBLECLICK = wxStyledTextCtrl_EVT_STC_DOUBLECLICK();
        	 wxEVT_STC_UPDATEUI = wxStyledTextCtrl_EVT_STC_UPDATEUI();
        	 wxEVT_STC_MODIFIED = wxStyledTextCtrl_EVT_STC_MODIFIED();
        	 wxEVT_STC_MACRORECORD = wxStyledTextCtrl_EVT_STC_MACRORECORD();
        	 wxEVT_STC_MARGINCLICK = wxStyledTextCtrl_EVT_STC_MARGINCLICK();
        	 wxEVT_STC_NEEDSHOWN = wxStyledTextCtrl_EVT_STC_NEEDSHOWN();
        //	 wxEVT_STC_POSCHANGED = wxStyledTextCtrl_EVT_STC_POSCHANGED();
        	 wxEVT_STC_PAINTED = wxStyledTextCtrl_EVT_STC_PAINTED();
        	 wxEVT_STC_USERLISTSELECTION = wxStyledTextCtrl_EVT_STC_USERLISTSELECTION();
        	 wxEVT_STC_URIDROPPED = wxStyledTextCtrl_EVT_STC_URIDROPPED();
        	 wxEVT_STC_DWELLSTART = wxStyledTextCtrl_EVT_STC_DWELLSTART();
        	 wxEVT_STC_DWELLEND = wxStyledTextCtrl_EVT_STC_DWELLEND();
        	 wxEVT_STC_START_DRAG = wxStyledTextCtrl_EVT_STC_START_DRAG();
        	 wxEVT_STC_DRAG_OVER = wxStyledTextCtrl_EVT_STC_DRAG_OVER();
        	 wxEVT_STC_DO_DROP = wxStyledTextCtrl_EVT_STC_DO_DROP();
        	 wxEVT_STC_ZOOM = wxStyledTextCtrl_EVT_STC_ZOOM();
        	 wxEVT_STC_HOTSPOT_CLICK = wxStyledTextCtrl_EVT_STC_HOTSPOT_CLICK();
        	 wxEVT_STC_HOTSPOT_DCLICK = wxStyledTextCtrl_EVT_STC_HOTSPOT_DCLICK();
        	 wxEVT_STC_CALLTIP_CLICK = wxStyledTextCtrl_EVT_STC_CALLTIP_CLICK();

            Event.AddEventType(wxEVT_STC_CHANGE,               &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_STYLENEEDED,          &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_CHARADDED,            &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_SAVEPOINTREACHED,     &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_SAVEPOINTLEFT,        &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_ROMODIFYATTEMPT,      &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_KEY,                  &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_DOUBLECLICK,          &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_UPDATEUI,             &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_MODIFIED,             &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_MACRORECORD,          &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_MARGINCLICK,          &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_NEEDSHOWN,            &StyledTextEvent.New);
            //Event.AddEventType(wxEVT_STC_POSCHANGED,           &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_PAINTED,              &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_USERLISTSELECTION,    &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_URIDROPPED,           &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_DWELLSTART,           &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_DWELLEND,             &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_START_DRAG,           &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_DRAG_OVER,            &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_DO_DROP,              &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_ZOOM,                 &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_HOTSPOT_CLICK,        &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_HOTSPOT_DCLICK,       &StyledTextEvent.New);
            Event.AddEventType(wxEVT_STC_CALLTIP_CLICK,        &StyledTextEvent.New);
        }

        //-----------------------------------------------------------------------------
	public const string wxSTCNameStr = "stcwindow";

        public this(IntPtr wxobj) 
            { super (wxobj); }

        public  this(Window parent, int id /*= wxID_ANY*/, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style =0, string name = wxSTCNameStr)
            { this(wxStyledTextCtrl_ctor(wxObject.SafePtr(parent), id, pos, size, cast(uint)style, name)); }
	    
		public static wxObject New(IntPtr wxobj) { return new StyledTextCtrl(wxobj); }
	
	//---------------------------------------------------------------------
	// ctors with self created id
	    
        public  this(Window parent, Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style =0, string name = wxSTCNameStr)
	    { this(parent, Window.UniqueID, pos, size, style, name);}

        //-----------------------------------------------------------------------------

        public void AddText(string text)
        {
            wxStyledTextCtrl_AddText(wxobj, text);
        }

        /*public void AddStyledText(MemoryBuffer data)
        {
            wxStyledTextCtrl_AddStyledText(wxobj, wxObject.SafePtr(data));
        }*/

        public void InsertText(int pos, string text)
        {
            wxStyledTextCtrl_InsertText(wxobj, pos, text);
        }

        //-----------------------------------------------------------------------------

        public void ClearAll()
        {
            wxStyledTextCtrl_ClearAll(wxobj);
        }

        public void ClearDocumentStyle()
        {
            wxStyledTextCtrl_ClearDocumentStyle(wxobj);
        }

        //-----------------------------------------------------------------------------

        public int Length() { return wxStyledTextCtrl_GetLength(wxobj); }

        //-----------------------------------------------------------------------------

        public int GetCharAt(int pos)
        {
            return wxStyledTextCtrl_GetCharAt(wxobj, pos);
        }

        //-----------------------------------------------------------------------------

        public int CurrentPos() { return wxStyledTextCtrl_GetCurrentPos(wxobj); }
        public void CurrentPos(int value) { wxStyledTextCtrl_SetCurrentPos(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int Anchor() { return wxStyledTextCtrl_GetAnchor(wxobj); }
        public void Anchor(int value) { wxStyledTextCtrl_SetAnchor(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int GetStyleAt(int pos)
        {
            return wxStyledTextCtrl_GetStyleAt(wxobj, pos);
        }

        //-----------------------------------------------------------------------------

        public void Redo()
        {
            wxStyledTextCtrl_Redo(wxobj);
        }

        //-----------------------------------------------------------------------------

        public bool UndoCollection() { return wxStyledTextCtrl_GetUndoCollection(wxobj); }
        public void UndoCollection(bool value) { wxStyledTextCtrl_SetUndoCollection(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void SelectAll()
        {
            wxStyledTextCtrl_SelectAll(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void SetSavePoint()
        {
            wxStyledTextCtrl_SetSavePoint(wxobj);
        }

        //-----------------------------------------------------------------------------

        /*public MemoryBuffer GetStyledText(int startPos, int endPos)
        {
            return wxStyledTextCtrl_GetStyledText(wxobj, startPos, endPos);
        }*/

        //-----------------------------------------------------------------------------

        public bool CanRedo() { return wxStyledTextCtrl_CanRedo(wxobj); }

        //-----------------------------------------------------------------------------

        public int MarkerLineFromHandle(int handle)
        {
            return wxStyledTextCtrl_MarkerLineFromHandle(wxobj, handle);
        }

        public void MarkerDeleteHandle(int handle)
        {
            wxStyledTextCtrl_MarkerDeleteHandle(wxobj, handle);
        }

        //-----------------------------------------------------------------------------

        public int ViewWhiteSpace() { return wxStyledTextCtrl_GetViewWhiteSpace(wxobj); }
        public void ViewWhiteSpace(int value) { wxStyledTextCtrl_SetViewWhiteSpace(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int PositionFromPoint(Point pt)
        {
            return wxStyledTextCtrl_PositionFromPoint(wxobj, pt);
        }

        public int PositionFromPointClose(int x, int y)
        {
            return wxStyledTextCtrl_PositionFromPointClose(wxobj, x, y);
        }

        //-----------------------------------------------------------------------------

        public void GotoLine(int line)
        {
            wxStyledTextCtrl_GotoLine(wxobj, line);
        }

        //-----------------------------------------------------------------------------

        public void GotoPos(int pos)
        {
            wxStyledTextCtrl_GotoPos(wxobj, pos);
        }

        //-----------------------------------------------------------------------------

        public string CurLine() {
                int i;
                return GetCurLine(i);
            }

        public string GetCurLine(out int linePos)
        {
            return cast(string) new wxString(wxStyledTextCtrl_GetCurLine(wxobj, linePos), true);
        }

        //-----------------------------------------------------------------------------

        public int EndStyled() { return wxStyledTextCtrl_GetEndStyled(wxobj); }

        //-----------------------------------------------------------------------------

        public void ConvertEOLs(int eolMode)
        {
            wxStyledTextCtrl_ConvertEOLs(wxobj, eolMode);
        }

        //-----------------------------------------------------------------------------

        public int EOLMode() { return wxStyledTextCtrl_GetEOLMode(wxobj); }
        public void EOLMode(int value) { wxStyledTextCtrl_SetEOLMode(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void StartStyling(int pos, int mask)
        {
            wxStyledTextCtrl_StartStyling(wxobj, pos, mask);
        }

        //-----------------------------------------------------------------------------

        public void SetStyling(int length, int style)
        {
            wxStyledTextCtrl_SetStyling(wxobj, length, style);
        }

        //-----------------------------------------------------------------------------

        public bool BufferedDraw() { return wxStyledTextCtrl_GetBufferedDraw(wxobj); }
        public void BufferedDraw(bool value) { wxStyledTextCtrl_SetBufferedDraw(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int TabWidth() { return wxStyledTextCtrl_GetTabWidth(wxobj); }
        public void TabWidth(int value) { wxStyledTextCtrl_SetTabWidth(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int CodePage() { return wxStyledTextCtrl_GetCodePage(wxobj); } 
        public void CodePage(int value) { wxStyledTextCtrl_SetCodePage(wxobj, value); } 

        //-----------------------------------------------------------------------------

        public void MarkerDefine(int markerNumber, int markerSymbol, Colour foreground, Colour background)
        {
            wxStyledTextCtrl_MarkerDefine(wxobj, markerNumber, markerSymbol, wxObject.SafePtr(foreground), wxObject.SafePtr(background));
        }

        public void MarkerSetForeground(int markerNumber, Colour fore)
        {
            wxStyledTextCtrl_MarkerSetForeground(wxobj, markerNumber, wxObject.SafePtr(fore));
        }

        public void MarkerSetBackground(int markerNumber, Colour back)
        {
            wxStyledTextCtrl_MarkerSetBackground(wxobj, markerNumber, wxObject.SafePtr(back));
        }

        public int MarkerAdd(int line, int markerNumber)
        {
            return wxStyledTextCtrl_MarkerAdd(wxobj, line, markerNumber);
        }

        public void MarkerDelete(int line, int markerNumber)
        {
            wxStyledTextCtrl_MarkerDelete(wxobj, line, markerNumber);
        }

        public void MarkerDeleteAll(int markerNumber)
        {
            wxStyledTextCtrl_MarkerDeleteAll(wxobj, markerNumber);
        }

        public int MarkerGet(int line)
        {
            return wxStyledTextCtrl_MarkerGet(wxobj, line);
        }

        public int MarkerNext(int lineStart, int markerMask)
        {
            return wxStyledTextCtrl_MarkerNext(wxobj, lineStart, markerMask);
        }

        public int MarkerPrevious(int lineStart, int markerMask)
        {
            return wxStyledTextCtrl_MarkerPrevious(wxobj, lineStart, markerMask);
        }

        public void MarkerDefineBitmap(int markerNumber, Bitmap bmp)
        {
            wxStyledTextCtrl_MarkerDefineBitmap(wxobj, markerNumber, wxObject.SafePtr(bmp));
        }

        //-----------------------------------------------------------------------------

        public void SetMarginType(int margin, int marginType)
        {
            wxStyledTextCtrl_SetMarginType(wxobj, margin, marginType);
        }

        public int GetMarginType(int margin)
        {
            return wxStyledTextCtrl_GetMarginType(wxobj, margin);
        }

        //-----------------------------------------------------------------------------

        public void SetMarginWidth(int margin, int pixelWidth)
        {
            wxStyledTextCtrl_SetMarginWidth(wxobj, margin, pixelWidth);
        }

        public int GetMarginWidth(int margin)
        {
            return wxStyledTextCtrl_GetMarginWidth(wxobj, margin);
        }

        //-----------------------------------------------------------------------------

        public void SetMarginMask(int margin, int mask)
        {
            wxStyledTextCtrl_SetMarginMask(wxobj, margin, mask);
        }

        public int GetMarginMask(int margin)
        {
            return wxStyledTextCtrl_GetMarginMask(wxobj, margin);
        }

        //-----------------------------------------------------------------------------

        public void SetMarginSensitive(int margin, bool sensitive)
        {
            wxStyledTextCtrl_SetMarginSensitive(wxobj, margin, sensitive);
        }

        public bool GetMarginSensitive(int margin)
        {
            return wxStyledTextCtrl_GetMarginSensitive(wxobj, margin);
        }

        //-----------------------------------------------------------------------------

        public void StyleClearAll()
        {
            wxStyledTextCtrl_StyleClearAll(wxobj);
        }

        public void StyleSetForeground(int style, Colour fore)
        {
            wxStyledTextCtrl_StyleSetForeground(wxobj, style, wxObject.SafePtr(fore));
        }

        public void StyleSetBackground(int style, Colour back)
        {
            wxStyledTextCtrl_StyleSetBackground(wxobj, style, wxObject.SafePtr(back));
        }

        public void StyleSetBold(int style, bool bold)
        {
            wxStyledTextCtrl_StyleSetBold(wxobj, style, bold);
        }

        public void StyleSetItalic(int style, bool italic)
        {
            wxStyledTextCtrl_StyleSetItalic(wxobj, style, italic);
        }

        public void StyleSetSize(int style, int sizePoints)
        {
            wxStyledTextCtrl_StyleSetSize(wxobj, style, sizePoints);
        }

        public void StyleSetFaceName(int style, string fontName)
        {
            wxStyledTextCtrl_StyleSetFaceName(wxobj, style, fontName);
        }

        public void StyleSetEOLFilled(int style, bool filled)
        {
            wxStyledTextCtrl_StyleSetEOLFilled(wxobj, style, filled);
        }

        public void StyleResetDefault()
        {
            wxStyledTextCtrl_StyleResetDefault(wxobj);
        }

        public void StyleSetUnderline(int style, bool underline)
        {
            wxStyledTextCtrl_StyleSetUnderline(wxobj, style, underline);
        }

        public void StyleSetCase(int style, int caseForce)
        {
            wxStyledTextCtrl_StyleSetCase(wxobj, style, caseForce);
        }

        public void StyleSetCharacterSet(int style, int characterSet)
        {
            wxStyledTextCtrl_StyleSetCharacterSet(wxobj, style, characterSet);
        }

        public void StyleSetHotSpot(int style, bool hotspot)
        {
            wxStyledTextCtrl_StyleSetHotSpot(wxobj, style, hotspot);
        }

        public void StyleSetVisible(int style, bool visible)
        {
            wxStyledTextCtrl_StyleSetVisible(wxobj, style, visible);
        }

        public void StyleSetChangeable(int style, bool changeable)
        {
            wxStyledTextCtrl_StyleSetChangeable(wxobj, style, changeable);
        }

        //-----------------------------------------------------------------------------

        public void SetSelForeground(bool useSetting, Colour fore)
        {
            wxStyledTextCtrl_SetSelForeground(wxobj, useSetting, wxObject.SafePtr(fore));
        }

        public void SetSelBackground(bool useSetting, Colour back)
        {
            wxStyledTextCtrl_SetSelBackground(wxobj, useSetting, wxObject.SafePtr(back));
        }

        //-----------------------------------------------------------------------------

        public Colour CaretForeground() { return new Colour(wxStyledTextCtrl_GetCaretForeground(wxobj), true); }
        public void CaretForeground(Colour value) { wxStyledTextCtrl_SetCaretForeground(wxobj, wxObject.SafePtr(value)); } 

        //-----------------------------------------------------------------------------

        public void CmdKeyAssign(int key, int modifiers, int cmd)
        {
            wxStyledTextCtrl_CmdKeyAssign(wxobj, key, modifiers, cmd);
        }

        public void CmdKeyClear(int key, int modifiers)
        {
            wxStyledTextCtrl_CmdKeyClear(wxobj, key, modifiers);
        }

        public void CmdKeyClearAll()
        {
            wxStyledTextCtrl_CmdKeyClearAll(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void SetStyleBytes(ubyte[] styleBytes)
        {
            wxStyledTextCtrl_SetStyleBytes(wxobj, styleBytes.length, styleBytes.ptr);
        }

        //-----------------------------------------------------------------------------

        public int CaretPeriod() { return wxStyledTextCtrl_GetCaretPeriod(wxobj); }
        public void CaretPeriod(int value) { wxStyledTextCtrl_SetCaretPeriod(wxobj, value); } 

        //-----------------------------------------------------------------------------

        public void SetWordChars(string characters)
        {
            wxStyledTextCtrl_SetWordChars(wxobj, characters);
        }

        //-----------------------------------------------------------------------------

        public void BeginUndoAction()
        {
            wxStyledTextCtrl_BeginUndoAction(wxobj);
        }

        public void EndUndoAction()
        {
            wxStyledTextCtrl_EndUndoAction(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void IndicatorSetStyle(int indic, int style)
        {
            wxStyledTextCtrl_IndicatorSetStyle(wxobj, indic, style);
        }

        public int IndicatorGetStyle(int indic)
        {
            return wxStyledTextCtrl_IndicatorGetStyle(wxobj, indic);
        }

        public void IndicatorSetForeground(int indic, Colour fore)
        {
            wxStyledTextCtrl_IndicatorSetForeground(wxobj, indic, wxObject.SafePtr(fore));
        }

        public Colour IndicatorGetForeground(int indic)
        {
            return new Colour(wxStyledTextCtrl_IndicatorGetForeground(wxobj, indic), true);
        }

        //-----------------------------------------------------------------------------

        public void SetWhitespaceForeground(bool useSetting, Colour fore)
        {
            wxStyledTextCtrl_SetWhitespaceForeground(wxobj, useSetting, wxObject.SafePtr(fore));
        }

        public void SetWhitespaceBackground(bool useSetting, Colour back)
        {
            wxStyledTextCtrl_SetWhitespaceBackground(wxobj, useSetting, wxObject.SafePtr(back));
        }

        //-----------------------------------------------------------------------------

        public int StyleBits() { return wxStyledTextCtrl_GetStyleBits(wxobj); }
        public void StyleBits(int value) { wxStyledTextCtrl_SetStyleBits(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void SetLineState(int line, int state)
        {
            wxStyledTextCtrl_SetLineState(wxobj, line, state);
        }

        public int GetLineState(int line)
        {
            return wxStyledTextCtrl_GetLineState(wxobj, line);
        }

        //-----------------------------------------------------------------------------

        public int MaxLineState() { return wxStyledTextCtrl_GetMaxLineState(wxobj); }

        //-----------------------------------------------------------------------------

        public bool CaretLineVisible() { return wxStyledTextCtrl_GetCaretLineVisible(wxobj); }
        public void CaretLineVisible(bool value) { wxStyledTextCtrl_SetCaretLineVisible(wxobj, value); }

        //-----------------------------------------------------------------------------

        public Colour CaretLineBack() { return new Colour(wxStyledTextCtrl_GetCaretLineBack(wxobj), true); } 
        public void CaretLineBack(Colour value) { wxStyledTextCtrl_SetCaretLineBack(wxobj, wxObject.SafePtr(value)); }

        //-----------------------------------------------------------------------------

        public void AutoCompShow(int lenEntered, string itemList)
        {
            wxStyledTextCtrl_AutoCompShow(wxobj, lenEntered, itemList);
        }

        public void AutoCompCancel()
        {
            wxStyledTextCtrl_AutoCompCancel(wxobj);
        }

        public bool AutoCompActive() { return wxStyledTextCtrl_AutoCompActive(wxobj); }

        public int AutoCompPosStart() { return wxStyledTextCtrl_AutoCompPosStart(wxobj); } 

        public void AutoCompComplete()
        {
            wxStyledTextCtrl_AutoCompComplete(wxobj);
        }

        public void AutoCompStops(string value) { wxStyledTextCtrl_AutoCompStops(wxobj, value); }

        public char AutoCompSeparator() { return cast(char)wxStyledTextCtrl_AutoCompGetSeparator(wxobj); }
        public void AutoCompSeparator(char value) { wxStyledTextCtrl_AutoCompSetSeparator(wxobj, cast(int)value); } 

        public void AutoCompSelect(string text)
        {
            wxStyledTextCtrl_AutoCompSelect(wxobj, text);
        }

        public bool AutoCompCancelAtStart() { return wxStyledTextCtrl_AutoCompGetCancelAtStart(wxobj); }
        public void AutoCompCancelAtStart(bool value) { wxStyledTextCtrl_AutoCompSetCancelAtStart(wxobj, value); } 

        public void AutoCompFillUps(string value) { wxStyledTextCtrl_AutoCompSetFillUps(wxobj, value); }

        public bool AutoCompChooseSingle() { return wxStyledTextCtrl_AutoCompGetChooseSingle(wxobj); }
        public void AutoCompChooseSingle(bool value) { wxStyledTextCtrl_AutoCompSetChooseSingle(wxobj, value); }

        public bool AutoCompIgnoreCase() { return wxStyledTextCtrl_AutoCompGetIgnoreCase(wxobj); }
        public void AutoCompIgnoreCase(bool value) { wxStyledTextCtrl_AutoCompSetIgnoreCase(wxobj, value); } 

        public void AutoCompAutoHide(bool value) { wxStyledTextCtrl_AutoCompSetAutoHide(wxobj, value); }
        public bool AutoCompAutoHide() { return wxStyledTextCtrl_AutoCompGetAutoHide(wxobj); }

        public void AutoCompDropRestOfWord(bool value) { wxStyledTextCtrl_AutoCompSetDropRestOfWord(wxobj, value); }
        public bool AutoCompDropRestOfWord() { return wxStyledTextCtrl_AutoCompGetDropRestOfWord(wxobj); } 

        public int AutoCompTypeSeparator() { return wxStyledTextCtrl_AutoCompGetTypeSeparator(wxobj); }
        public void AutoCompTypeSeparator(int value) { wxStyledTextCtrl_AutoCompSetTypeSeparator(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void UserListShow(int listType, string itemList)
        {
            wxStyledTextCtrl_UserListShow(wxobj, listType, itemList);
        }

        //-----------------------------------------------------------------------------

        public void RegisterImage(int type, Bitmap bmp)
        {
            wxStyledTextCtrl_RegisterImage(wxobj, type, wxObject.SafePtr(bmp));
        }

        public void ClearRegisteredImages()
        {
            wxStyledTextCtrl_ClearRegisteredImages(wxobj);
        }

        //-----------------------------------------------------------------------------

        public int Indent() { return wxStyledTextCtrl_GetIndent(wxobj); }
        public void Indent(int value) { wxStyledTextCtrl_SetIndent(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool UseTabs() { return wxStyledTextCtrl_GetUseTabs(wxobj); }
        public void UseTabs(bool value) { wxStyledTextCtrl_SetUseTabs(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void SetLineIndentation(int line, int indentSize)
        {
            wxStyledTextCtrl_SetLineIndentation(wxobj, line, indentSize);
        }

        public int GetLineIndentation(int line)
        {
            return wxStyledTextCtrl_GetLineIndentation(wxobj, line);
        }

        //-----------------------------------------------------------------------------

        public int GetLineIndentPosition(int line)
        {
            return wxStyledTextCtrl_GetLineIndentPosition(wxobj, line);
        }

        //-----------------------------------------------------------------------------

        public int GetColumn(int pos)
        {
            return wxStyledTextCtrl_GetColumn(wxobj, pos);
        }

        //-----------------------------------------------------------------------------

        public void UseHorizontalScrollBar(bool value) { wxStyledTextCtrl_SetUseHorizontalScrollBar(wxobj, value); }
        public bool UseHorizontalScrollBar() { return wxStyledTextCtrl_GetUseHorizontalScrollBar(wxobj); }

        //-----------------------------------------------------------------------------

        public void IndentationGuides(bool value) { wxStyledTextCtrl_SetIndentationGuides(wxobj, value); }
        public bool IndentationGuides() { return wxStyledTextCtrl_GetIndentationGuides(wxobj); }

        //-----------------------------------------------------------------------------

        public int HighlightGuide() { return wxStyledTextCtrl_GetHighlightGuide(wxobj); }
        public void HighlightGuide(int value) { wxStyledTextCtrl_SetHighlightGuide(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int GetLineEndPosition(int line)
        {
            return wxStyledTextCtrl_GetLineEndPosition(wxobj, line);
        }

        //-----------------------------------------------------------------------------

        public bool ReadOnly() { return wxStyledTextCtrl_GetReadOnly(wxobj); }
        public void ReadOnly(bool value) { wxStyledTextCtrl_SetReadOnly(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int SelectionStart() { return wxStyledTextCtrl_GetSelectionStart(wxobj); } 
        public void SelectionStart(int value) { wxStyledTextCtrl_SetSelectionStart(wxobj, value); }

        public int SelectionEnd() { return wxStyledTextCtrl_GetSelectionEnd(wxobj); }
        public void SelectionEnd(int value) { wxStyledTextCtrl_SetSelectionEnd(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int PrintMagnification() { return wxStyledTextCtrl_GetPrintMagnification(wxobj); }
        public void PrintMagnification(int value) { wxStyledTextCtrl_SetPrintMagnification(wxobj, value); }

        public int PrintColourMode() { return wxStyledTextCtrl_GetPrintColourMode(wxobj); }
        public void PrintColourMode(int value) { wxStyledTextCtrl_SetPrintColourMode(wxobj, value); } 

        //-----------------------------------------------------------------------------

        public int FindText(int minPos, int maxPos, string text, int flags)
        {
            return wxStyledTextCtrl_FindText(wxobj, minPos, maxPos, text, flags);
        }

        //-----------------------------------------------------------------------------

        public int FormatRange(bool doDraw, int startPos, int endPos, DC draw, DC target, Rectangle renderRect, Rectangle pageRect)
        {
            return wxStyledTextCtrl_FormatRange(wxobj, doDraw, startPos, endPos, wxObject.SafePtr(draw), wxObject.SafePtr(target), renderRect, pageRect);
        }

        //-----------------------------------------------------------------------------

        public int FirstVisibleLine() { return wxStyledTextCtrl_GetFirstVisibleLine(wxobj); }

        //-----------------------------------------------------------------------------

        public string GetLine(int line)
        {
            return cast(string) new wxString(wxStyledTextCtrl_GetLine(wxobj, line), true);
        }

        //-----------------------------------------------------------------------------

        public int LineCount() { return wxStyledTextCtrl_GetLineCount(wxobj); }

        //-----------------------------------------------------------------------------

        public int MarginLeft() { return wxStyledTextCtrl_GetMarginLeft(wxobj); }
        public void MarginLeft(int value) { wxStyledTextCtrl_SetMarginLeft(wxobj, value); }

        public int MarginRight() { return wxStyledTextCtrl_GetMarginRight(wxobj); }
        public void MarginRight(int value) { wxStyledTextCtrl_SetMarginRight(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool Modify() { return wxStyledTextCtrl_GetModify(wxobj); }

        //-----------------------------------------------------------------------------

        public void SetSelection(int start, int end)
        {
            wxStyledTextCtrl_SetSelection(wxobj, start, end);
        }

        public string SelectedText() { return cast(string) new wxString(wxStyledTextCtrl_GetSelectedText(wxobj), true); }

        //-----------------------------------------------------------------------------

        public string GetTextRange(int startPos, int endPos)
        {
            return cast(string) new wxString(wxStyledTextCtrl_GetTextRange(wxobj, startPos, endPos), true);
        }

        //-----------------------------------------------------------------------------

        public void HideSelection(bool value) { wxStyledTextCtrl_HideSelection(wxobj, value); } 

        //-----------------------------------------------------------------------------

        public int LineFromPosition(int pos)
        {
            return wxStyledTextCtrl_LineFromPosition(wxobj, pos);
        }

        public int PositionFromLine(int line)
        {
            return wxStyledTextCtrl_PositionFromLine(wxobj, line);
        }

        //-----------------------------------------------------------------------------

        public void LineScroll(int columns, int lines)
        {
            wxStyledTextCtrl_LineScroll(wxobj, columns, lines);
        }

        //-----------------------------------------------------------------------------

        public void EnsureCaretVisible()
        {
            wxStyledTextCtrl_EnsureCaretVisible(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void ReplaceSelection(string text)
        {
            wxStyledTextCtrl_ReplaceSelection(wxobj, text);
        }

        //-----------------------------------------------------------------------------

        public bool CanPaste() { return wxStyledTextCtrl_CanPaste(wxobj); } 

        public bool CanUndo() { return wxStyledTextCtrl_CanUndo(wxobj); }

        //-----------------------------------------------------------------------------

        public void EmptyUndoBuffer()
        {
            wxStyledTextCtrl_EmptyUndoBuffer(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void Undo()
        {
            wxStyledTextCtrl_Undo(wxobj);
        }

        public void Cut()
        {
            wxStyledTextCtrl_Cut(wxobj);
        }

        public void Copy()
        {
            wxStyledTextCtrl_Copy(wxobj);
        }

        public void Paste()
        {
            wxStyledTextCtrl_Paste(wxobj);
        }

        public void Clear()
        {
            wxStyledTextCtrl_Clear(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void Text(string value) { wxStyledTextCtrl_SetText(wxobj, value); } 
        public string Text() { return cast(string) new wxString(wxStyledTextCtrl_GetText(wxobj), true); }

        //-----------------------------------------------------------------------------

        public int TextLength() { return wxStyledTextCtrl_GetTextLength(wxobj); }

        //-----------------------------------------------------------------------------

        public bool Overtype() { return wxStyledTextCtrl_GetOvertype(wxobj); }
        public void Overtype(bool value) { wxStyledTextCtrl_SetOvertype(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int CaretWidth() { return wxStyledTextCtrl_GetCaretWidth(wxobj); } 
        public void CaretWidth(int value) { wxStyledTextCtrl_SetCaretWidth(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int TargetStart() { return wxStyledTextCtrl_GetTargetStart(wxobj); }
        public void TargetStart(int value) { wxStyledTextCtrl_SetTargetStart(wxobj, value); }

        public int TargetEnd() { return wxStyledTextCtrl_GetTargetEnd(wxobj); }
        public void TargetEnd(int value) { wxStyledTextCtrl_SetTargetEnd(wxobj, value); } 

        public int ReplaceTarget(string text)
        {
            return wxStyledTextCtrl_ReplaceTarget(wxobj, text);
        }

        public int ReplaceTargetRE(string text)
        {
            return wxStyledTextCtrl_ReplaceTargetRE(wxobj, text);
        }

        public int SearchInTarget(string text)
        {
            return wxStyledTextCtrl_SearchInTarget(wxobj, text);
        }

        //-----------------------------------------------------------------------------

        public int SetSearchFlags() { return wxStyledTextCtrl_GetSearchFlags(wxobj); }
        public void SetSearchFlags(int value) { wxStyledTextCtrl_SetSearchFlags(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void CallTipShow(int pos, string definition)
        {
            wxStyledTextCtrl_CallTipShow(wxobj, pos, definition);
        }

        public void CallTipCancel()
        {
            wxStyledTextCtrl_CallTipCancel(wxobj);
        }

        public bool CallTipActive() { return wxStyledTextCtrl_CallTipActive(wxobj); }

        public int CallTipPosAtStart() { return wxStyledTextCtrl_CallTipPosAtStart(wxobj); }

        public void CallTipSetHighlight(int start, int end)
        {
            wxStyledTextCtrl_CallTipSetHighlight(wxobj, start, end);
        }

        public void CallTipBackground(Colour value) { wxStyledTextCtrl_CallTipSetBackground(wxobj, wxObject.SafePtr(value)); }

        public void CallTipForeground(Colour value) { wxStyledTextCtrl_CallTipSetForeground(wxobj, wxObject.SafePtr(value)); } 

        public void CallTipForegroundHighlight(Colour value) { wxStyledTextCtrl_CallTipSetForegroundHighlight(wxobj, wxObject.SafePtr(value)); }

        //-----------------------------------------------------------------------------

        public int VisibleFromDocLine(int line)
        {
            return wxStyledTextCtrl_VisibleFromDocLine(wxobj, line);
        }

        public int DocLineFromVisible(int lineDisplay)
        {
            return wxStyledTextCtrl_DocLineFromVisible(wxobj, lineDisplay);
        }

        //-----------------------------------------------------------------------------

        public void SetFoldLevel(int line, int level)
        {
            wxStyledTextCtrl_SetFoldLevel(wxobj, line, level);
        }

        public int GetFoldLevel(int line)
        {
            return wxStyledTextCtrl_GetFoldLevel(wxobj, line);
        }

        public int GetLastChild(int line, int level)
        {
            return wxStyledTextCtrl_GetLastChild(wxobj, line, level);
        }

        public int GetFoldParent(int line)
        {
            return wxStyledTextCtrl_GetFoldParent(wxobj, line);
        }

        //-----------------------------------------------------------------------------

        public void ShowLines(int lineStart, int lineEnd)
        {
            wxStyledTextCtrl_ShowLines(wxobj, lineStart, lineEnd);
        }

        public void HideLines(int lineStart, int lineEnd)
        {
            wxStyledTextCtrl_HideLines(wxobj, lineStart, lineEnd);
        }

        public bool GetLineVisible(int line)
        {
            return wxStyledTextCtrl_GetLineVisible(wxobj, line);
        }

        //-----------------------------------------------------------------------------

        public void SetFoldExpanded(int line, bool expanded)
        {
            wxStyledTextCtrl_SetFoldExpanded(wxobj, line, expanded);
        }

        public bool GetFoldExpanded(int line)
        {
            return wxStyledTextCtrl_GetFoldExpanded(wxobj, line);
        }

        public void ToggleFold(int line)
        {
            wxStyledTextCtrl_ToggleFold(wxobj, line);
        }

        public void EnsureVisible(int line)
        {
            wxStyledTextCtrl_EnsureVisible(wxobj, line);
        }

        //-----------------------------------------------------------------------------

        public void FoldFlags(int value) { wxStyledTextCtrl_SetFoldFlags(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void EnsureVisibleEnforcePolicy(int line)
        {
            wxStyledTextCtrl_EnsureVisibleEnforcePolicy(wxobj, line);
        }

        //-----------------------------------------------------------------------------

        public bool TabIndents() { return wxStyledTextCtrl_GetTabIndents(wxobj); }
        public void TabIndents(bool value) { wxStyledTextCtrl_SetTabIndents(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool BackSpaceUnIndents() { return wxStyledTextCtrl_GetBackSpaceUnIndents(wxobj); }
        public void BackSpaceUnIndents(bool value) { wxStyledTextCtrl_SetBackSpaceUnIndents(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void MouseDwellTime(int value) { wxStyledTextCtrl_SetMouseDwellTime(wxobj, value); }
        public int MouseDwellTime() { return wxStyledTextCtrl_GetMouseDwellTime(wxobj); }

        //-----------------------------------------------------------------------------

        public int WordStartPosition(int pos, bool onlyWordCharacters)
        {
            return wxStyledTextCtrl_WordStartPosition(wxobj, pos, onlyWordCharacters);
        }

        public int WordEndPosition(int pos, bool onlyWordCharacters)
        {
            return wxStyledTextCtrl_WordEndPosition(wxobj, pos, onlyWordCharacters);
        }

        //-----------------------------------------------------------------------------

        public int WrapMode() { return wxStyledTextCtrl_GetWrapMode(wxobj); }
        public void WrapMode(int value) { wxStyledTextCtrl_SetWrapMode(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void LayoutCache(int value) { wxStyledTextCtrl_SetLayoutCache(wxobj, value); }
        public int LayoutCache() { return wxStyledTextCtrl_GetLayoutCache(wxobj); }

        //-----------------------------------------------------------------------------

        public int ScrollWidth() { return wxStyledTextCtrl_GetScrollWidth(wxobj); }
        public void ScrollWidth(int value) { wxStyledTextCtrl_SetScrollWidth(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int TextWidth(int style, string text)
        {
            return wxStyledTextCtrl_TextWidth(wxobj, style, text);
        }

        //-----------------------------------------------------------------------------

        public bool EndAtLastLine() { return cast(bool)wxStyledTextCtrl_GetEndAtLastLine(wxobj); }
        public void EndAtLastLine(bool value) { wxStyledTextCtrl_SetEndAtLastLine(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int TextHeight(int line)
        {
            return wxStyledTextCtrl_TextHeight(wxobj, line);
        }

        //-----------------------------------------------------------------------------

        public bool UseVerticalScrollBar() { return wxStyledTextCtrl_GetUseVerticalScrollBar(wxobj); }
        public void UseVerticalScrollBar(bool value) { wxStyledTextCtrl_SetUseVerticalScrollBar(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void AppendText(int length, string text)
        {
            wxStyledTextCtrl_AppendText(wxobj, length, text);
        }

        //-----------------------------------------------------------------------------

        public bool TwoPhaseDraw() { return wxStyledTextCtrl_GetTwoPhaseDraw(wxobj); } 
        public void TwoPhaseDraw(bool value) { wxStyledTextCtrl_SetTwoPhaseDraw(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void TargetFromSelection()
        {
            wxStyledTextCtrl_TargetFromSelection(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void LinesJoin()
        {
            wxStyledTextCtrl_LinesJoin(wxobj);
        }

        public void LinesSplit(int pixelWidth)
        {
            wxStyledTextCtrl_LinesSplit(wxobj, pixelWidth);
        }

        //-----------------------------------------------------------------------------

        public void SetFoldMarginColour(bool useSetting, Colour back)
        {
            wxStyledTextCtrl_SetFoldMarginColour(wxobj, useSetting, wxObject.SafePtr(back));
        }

        public void SetFoldMarginHiColour(bool useSetting, Colour fore)
        {
            wxStyledTextCtrl_SetFoldMarginHiColour(wxobj, useSetting, wxObject.SafePtr(fore));
        }

        //-----------------------------------------------------------------------------

        public void LineDuplicate()
        {
            wxStyledTextCtrl_LineDuplicate(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void HomeDisplay()
        {
            wxStyledTextCtrl_HomeDisplay(wxobj);
        }

        public void HomeDisplayExtend()
        {
            wxStyledTextCtrl_HomeDisplayExtend(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void LineEndDisplay()
        {
            wxStyledTextCtrl_LineEndDisplay(wxobj);
        }

        public void LineEndDisplayExtend()
        {
            wxStyledTextCtrl_LineEndDisplayExtend(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void MoveCaretInsideView()
        {
            wxStyledTextCtrl_MoveCaretInsideView(wxobj);
        }

        //-----------------------------------------------------------------------------

        public int LineLength(int line)
        {
            return wxStyledTextCtrl_LineLength(wxobj, line);
        }

        //-----------------------------------------------------------------------------

        public void BraceHighlight(int pos1, int pos2)
        {
            wxStyledTextCtrl_BraceHighlight(wxobj, pos1, pos2);
        }

        public void BraceBadLight(int pos)
        {
            wxStyledTextCtrl_BraceBadLight(wxobj, pos);
        }

        public int BraceMatch(int pos)
        {
            return wxStyledTextCtrl_BraceMatch(wxobj, pos);
        }

        //-----------------------------------------------------------------------------

        public bool ViewEOL() { return wxStyledTextCtrl_GetViewEOL(wxobj); }
        public void ViewEOL(bool value) { wxStyledTextCtrl_SetViewEOL(wxobj, value); } 

        //-----------------------------------------------------------------------------

        // Not really usable yet, unless sharing documents between styled
        // text controls (?)

        public wxObject DocPointer() { return FindObject(wxStyledTextCtrl_GetDocPointer(wxobj)); }
        public void DocPointer(wxObject value) { wxStyledTextCtrl_SetDocPointer(wxobj, wxObject.SafePtr(value)); }

        //-----------------------------------------------------------------------------

        public int ModEventMask() { return wxStyledTextCtrl_GetModEventMask(wxobj); } 
        public void ModEventMask(int value) { wxStyledTextCtrl_SetModEventMask(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int EdgeColumn() { return wxStyledTextCtrl_GetEdgeColumn(wxobj); }
        public void EdgeColumn(int value) { wxStyledTextCtrl_SetEdgeColumn(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int EdgeMode() { return wxStyledTextCtrl_GetEdgeMode(wxobj); } 
        public void EdgeMode(int value) { wxStyledTextCtrl_SetEdgeMode(wxobj, value); }

        //-----------------------------------------------------------------------------

        public Colour EdgeColour() { return new Colour(wxStyledTextCtrl_GetEdgeColour(wxobj), true); } 
        public void EdgeColour(Colour value) { wxStyledTextCtrl_SetEdgeColour(wxobj, wxObject.SafePtr(value)); }

        //-----------------------------------------------------------------------------

        public void SearchAnchor()
        {
            wxStyledTextCtrl_SearchAnchor(wxobj);
        }

        public int SearchNext(int flags, string text)
        {
            return wxStyledTextCtrl_SearchNext(wxobj, flags, text);
        }

        public int SearchPrev(int flags, string text)
        {
            return wxStyledTextCtrl_SearchPrev(wxobj, flags, text);
        }

        //-----------------------------------------------------------------------------

        public int LinesOnScreen() { return wxStyledTextCtrl_LinesOnScreen(wxobj); }

        //-----------------------------------------------------------------------------

        public void UsePopUp(bool value) { wxStyledTextCtrl_UsePopUp(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool SelectionIsRectangle() { return wxStyledTextCtrl_SelectionIsRectangle(wxobj); }

        //-----------------------------------------------------------------------------

        public int Zoom() { return wxStyledTextCtrl_GetZoom(wxobj); }
        public void Zoom(int value) { wxStyledTextCtrl_SetZoom(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void CreateDocument()
        {
            wxStyledTextCtrl_CreateDocument(wxobj);
        }

        public void AddRefDocument(wxObject docPointer)
        {
            wxStyledTextCtrl_AddRefDocument(wxobj, wxObject.SafePtr(docPointer));
        }

        public void ReleaseDocument(wxObject docPointer)
        {
            wxStyledTextCtrl_ReleaseDocument(wxobj, wxObject.SafePtr(docPointer));
        }

        //-----------------------------------------------------------------------------

        public bool STCFocus() { return wxStyledTextCtrl_GetSTCFocus(wxobj); } 
        public void STCFocus(bool value) { wxStyledTextCtrl_SetSTCFocus(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int Status() { return wxStyledTextCtrl_GetStatus(wxobj); }
        public void Status(int value) { wxStyledTextCtrl_SetStatus(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool MouseDownCaptures() { return wxStyledTextCtrl_GetMouseDownCaptures(wxobj); }
        public void MouseDownCaptures(bool value) { wxStyledTextCtrl_SetMouseDownCaptures(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void STCCursor(int value) { wxStyledTextCtrl_SetSTCCursor(wxobj, value); }
        public int STCCursor() { return wxStyledTextCtrl_GetSTCCursor(wxobj); }

        //-----------------------------------------------------------------------------

        public void ControlCharSymbol(int value) { wxStyledTextCtrl_SetControlCharSymbol(wxobj, value); }
        public int ControlCharSymbol() { return wxStyledTextCtrl_GetControlCharSymbol(wxobj); }

        //-----------------------------------------------------------------------------

        public void WordPartLeft()
        {
            wxStyledTextCtrl_WordPartLeft(wxobj);
        }

        public void WordPartLeftExtend()
        {
            wxStyledTextCtrl_WordPartLeftExtend(wxobj);
        }

        public void WordPartRight()
        {
            wxStyledTextCtrl_WordPartRight(wxobj);
        }

        public void WordPartRightExtend()
        {
            wxStyledTextCtrl_WordPartRightExtend(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void SetVisiblePolicy(int visiblePolicy, int visibleSlop)
        {
            wxStyledTextCtrl_SetVisiblePolicy(wxobj, visiblePolicy, visibleSlop);
        }

        //-----------------------------------------------------------------------------

        public void DelLineLeft()
        {
            wxStyledTextCtrl_DelLineLeft(wxobj);
        }

        public void DelLineRight()
        {
            wxStyledTextCtrl_DelLineRight(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void XOffset(int value) { wxStyledTextCtrl_SetXOffset(wxobj, value); }
        public int XOffset() { return wxStyledTextCtrl_GetXOffset(wxobj); }

        //-----------------------------------------------------------------------------

        public void ChooseCaretX()
        {
            wxStyledTextCtrl_ChooseCaretX(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void SetXCaretPolicy(int caretPolicy, int caretSlop)
        {
            wxStyledTextCtrl_SetXCaretPolicy(wxobj, caretPolicy, caretSlop);
        }

        public void SetYCaretPolicy(int caretPolicy, int caretSlop)
        {
            wxStyledTextCtrl_SetYCaretPolicy(wxobj, caretPolicy, caretSlop);
        }

        //-----------------------------------------------------------------------------

        public void PrintWrapMode(int value) { wxStyledTextCtrl_SetPrintWrapMode(wxobj, value); }
        public int PrintWrapMode() { return wxStyledTextCtrl_GetPrintWrapMode(wxobj); }

        //-----------------------------------------------------------------------------

        public void SetHotspotActiveForeground(bool useSetting, Colour fore)
        {
            wxStyledTextCtrl_SetHotspotActiveForeground(wxobj, useSetting, wxObject.SafePtr(fore));
        }

        public void SetHotspotActiveBackground(bool useSetting, Colour back)
        {
            wxStyledTextCtrl_SetHotspotActiveBackground(wxobj, useSetting, wxObject.SafePtr(back));
        }

        public void SetHotspotActiveUnderline(bool underline)
        {
            wxStyledTextCtrl_SetHotspotActiveUnderline(wxobj, underline);
        }

        //-----------------------------------------------------------------------------

        public void StartRecord()
        {
            wxStyledTextCtrl_StartRecord(wxobj);
        }

        public void StopRecord()
        {
            wxStyledTextCtrl_StopRecord(wxobj);
        }

        //-----------------------------------------------------------------------------

        public void Lexer(int value) { wxStyledTextCtrl_SetLexer(wxobj, value); }
        public int Lexer() { return wxStyledTextCtrl_GetLexer(wxobj); }

        //-----------------------------------------------------------------------------

        public void Colourise(int start, int end)
        {
            wxStyledTextCtrl_Colourise(wxobj, start, end);
        }

        //-----------------------------------------------------------------------------

        public void SetProperty(string key, string value)
        {
            wxStyledTextCtrl_SetProperty(wxobj, key, value);
        }

        //-----------------------------------------------------------------------------

        public void SetKeyWords(int keywordSet, string keyWords)
        {
            wxStyledTextCtrl_SetKeyWords(wxobj, keywordSet, keyWords);
        }

        //-----------------------------------------------------------------------------

        public void LexerLanguage(string value) { wxStyledTextCtrl_SetLexerLanguage(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int CurrentLine() { return wxStyledTextCtrl_GetCurrentLine(wxobj); } 

        //-----------------------------------------------------------------------------

        public void StyleSetSpec(int styleNum, string spec)
        {
            wxStyledTextCtrl_StyleSetSpec(wxobj, styleNum, spec);
        }

        public void StyleSetFont(int styleNum, Font font)
        {
            wxStyledTextCtrl_StyleSetFont(wxobj, styleNum, wxObject.SafePtr(font));
        }

        public void StyleSetFontAttr(int styleNum, int size, string faceName, bool bold, bool italic, bool underline)
        {
            wxStyledTextCtrl_StyleSetFontAttr(wxobj, styleNum, size, faceName, bold, italic, underline);
        }

        //-----------------------------------------------------------------------------

        public void CmdKeyExecute(int cmd)
        {
            wxStyledTextCtrl_CmdKeyExecute(wxobj, cmd);
        }

        //-----------------------------------------------------------------------------

        public void SetMargins(int left, int right)
        {
            wxStyledTextCtrl_SetMargins(wxobj, left, right);
        }

        //-----------------------------------------------------------------------------

        public void GetSelection(out int startPos, out int endPos)
        {
            wxStyledTextCtrl_GetSelection(wxobj, startPos, endPos);
        }

        //-----------------------------------------------------------------------------

        public Point PointFromPosition(int pos)
        {
            Point pt;
            wxStyledTextCtrl_PointFromPosition(wxobj, pos, pt);
            return pt;
        }

        //-----------------------------------------------------------------------------

        public void ScrollToLine(int line)
        {
            wxStyledTextCtrl_ScrollToLine(wxobj, line);
        }

        //-----------------------------------------------------------------------------

        public void ScrollToColumn(int column)
        {
            wxStyledTextCtrl_ScrollToColumn(wxobj, column);
        }

        //-----------------------------------------------------------------------------

        /*public int SendMsg(int msg, int wp, int lp)
        {
            return wxStyledTextCtrl_SendMsg(wxobj, msg, wp, lp);
        }*/

        //-----------------------------------------------------------------------------

        /*public ScrollBar VScrollBar
        {
            set { wxStyledTextCtrl_SetVScrollBar(wxobj, wxObject.SafePtr(value)); }
        }*/

        //-----------------------------------------------------------------------------

        /*public ScrollBar SetHScrollBar
        {
            set { wxStyledTextCtrl_SetHScrollBar(wxobj, wxObject.SafePtr(value)); }
        }*/

        //-----------------------------------------------------------------------------

        public bool LastKeydownProcessed() { return wxStyledTextCtrl_GetLastKeydownProcessed(wxobj); }
        public void LastKeydownProcessed(bool value) { wxStyledTextCtrl_SetLastKeydownProcessed(wxobj, value); }

        //-----------------------------------------------------------------------------

        public bool SaveFile(string filename)
        {
            return wxStyledTextCtrl_SaveFile(wxobj, filename);
        }

        public bool LoadFile(string filename)
        {
            return wxStyledTextCtrl_LoadFile(wxobj, filename);
        }

        //-----------------------------------------------------------------------------

		public void Change_Add(EventListener value) { AddCommandListener(wxEVT_STC_CHANGE, ID, value, this); }
		public void Change_Remove(EventListener value) { RemoveHandler(value, this); }

		public void StyleNeeded_Add(EventListener value) { AddCommandListener(wxEVT_STC_STYLENEEDED, ID, value, this); }
		public void StyleNeeded_Remove(EventListener value) { RemoveHandler(value, this); }

		public void CharAdded_Add(EventListener value) { AddCommandListener(wxEVT_STC_CHARADDED, ID, value, this); }
		public void CharAdded_Remove(EventListener value) { RemoveHandler(value, this); }

		public void SavePointReached_Add(EventListener value) { AddCommandListener(wxEVT_STC_SAVEPOINTREACHED, ID, value, this); }
		public void SavePointReached_Remove(EventListener value) { RemoveHandler(value, this); }

		public void SavePointLeft_Add(EventListener value) { AddCommandListener(wxEVT_STC_SAVEPOINTLEFT, ID, value, this); }
		public void SavePointLeft_Remove(EventListener value) { RemoveHandler(value, this); }

		public void ROModifyAttempt_Add(EventListener value) { AddCommandListener(wxEVT_STC_ROMODIFYATTEMPT, ID, value, this); }
		public void ROModifyAttempt_Remove(EventListener value) { RemoveHandler(value, this); }

		public void Key_Add(EventListener value) { AddCommandListener(wxEVT_STC_KEY, ID, value, this); }
		public void Key_Remove(EventListener value) { RemoveHandler(value, this); }

		public void DoubleClick_Add(EventListener value) { AddCommandListener(wxEVT_STC_DOUBLECLICK, ID, value, this); }
		public void DoubleClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void UpdateUI_Add(EventListener value) { AddCommandListener(wxEVT_STC_UPDATEUI, ID, value, this); }
		public void UpdateUI_Remove(EventListener value) { RemoveHandler(value, this); }

		public void Modified_Add(EventListener value) { AddCommandListener(wxEVT_STC_MODIFIED, ID, value, this); }
		public void Modified_Remove(EventListener value) { RemoveHandler(value, this); }

		public void MacroRecord_Add(EventListener value) { AddCommandListener(wxEVT_STC_MACRORECORD, ID, value, this); }
		public void MacroRecord_Remove(EventListener value) { RemoveHandler(value, this); }

		public void MarginClick_Add(EventListener value) { AddCommandListener(wxEVT_STC_MARGINCLICK, ID, value, this); }
		public void MarginClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void NeedShown_Add(EventListener value) { AddCommandListener(wxEVT_STC_NEEDSHOWN, ID, value, this); }
		public void NeedShown_Remove(EventListener value) { RemoveHandler(value, this); }

		/*public event EventListener PositionChanged
		{
			add { AddCommandListener(wxEVT_STC_POSCHANGED, ID, value, this); }
			remove { RemoveHandler(value, this); }
		}*/

		public void Paint_Add(EventListener value) { AddCommandListener(wxEVT_STC_PAINTED, ID, value, this); }
		public void Paint_Remove(EventListener value) { RemoveHandler(value, this); }

		public void UserListSelection_Add(EventListener value) { AddCommandListener(wxEVT_STC_USERLISTSELECTION, ID, value, this); }
		public void UserListSelection_Remove(EventListener value) { RemoveHandler(value, this); }

		public void URIDropped_Add(EventListener value) { AddCommandListener(wxEVT_STC_URIDROPPED, ID, value, this); }
		public void URIDropped_Remove(EventListener value) { RemoveHandler(value, this); }

		public void DwellStart_Add(EventListener value) { AddCommandListener(wxEVT_STC_DWELLSTART, ID, value, this); }
		public void DwellStart_Remove(EventListener value) { RemoveHandler(value, this); }

		public void DwellEnd_Add(EventListener value) { AddCommandListener(wxEVT_STC_DWELLEND, ID, value, this); }
		public void DwellEnd_Remove(EventListener value) { RemoveHandler(value, this); }

		public void StartDrag_Add(EventListener value) { AddCommandListener(wxEVT_STC_START_DRAG, ID, value, this); }
		public void StartDrag_Remove(EventListener value) { RemoveHandler(value, this); }

		public void DragOver_Add(EventListener value) { AddCommandListener(wxEVT_STC_DRAG_OVER, ID, value, this); }
		public void DragOver_Remove(EventListener value) { RemoveHandler(value, this); }

		public void DoDrop_Add(EventListener value) { AddCommandListener(wxEVT_STC_DO_DROP, ID, value, this); }
		public void DoDrop_Remove(EventListener value) { RemoveHandler(value, this); }

		public void Zoomed_Add(EventListener value) { AddCommandListener(wxEVT_STC_ZOOM, ID, value, this); }
		public void Zoomed_Remove(EventListener value) { RemoveHandler(value, this); }

		public void HotspotClick_Add(EventListener value) { AddCommandListener(wxEVT_STC_HOTSPOT_CLICK, ID, value, this); }
		public void HotspotClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void HotspotDoubleClick_Add(EventListener value) { AddCommandListener(wxEVT_STC_HOTSPOT_DCLICK, ID, value, this); }
		public void HotspotDoubleClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void CalltipClick_Add(EventListener value) { AddCommandListener(wxEVT_STC_CALLTIP_CLICK, ID, value, this); }
		public void CalltipClick_Remove(EventListener value) { RemoveHandler(value, this); }
    }

        //! \cond EXTERN
        static extern (C) IntPtr wxStyledTextEvent_ctor(int commandType, int id);
        static extern (C) void   wxStyledTextEvent_SetPosition(IntPtr self, int pos);
        static extern (C) void   wxStyledTextEvent_SetKey(IntPtr self, int k);
        static extern (C) void   wxStyledTextEvent_SetModifiers(IntPtr self, int m);
        static extern (C) void   wxStyledTextEvent_SetModificationType(IntPtr self, int t);
        static extern (C) void   wxStyledTextEvent_SetText(IntPtr self, string t);
        static extern (C) void   wxStyledTextEvent_SetLength(IntPtr self, int len);
        static extern (C) void   wxStyledTextEvent_SetLinesAdded(IntPtr self, int num);
        static extern (C) void   wxStyledTextEvent_SetLine(IntPtr self, int val);
        static extern (C) void   wxStyledTextEvent_SetFoldLevelNow(IntPtr self, int val);
        static extern (C) void   wxStyledTextEvent_SetFoldLevelPrev(IntPtr self, int val);
        static extern (C) void   wxStyledTextEvent_SetMargin(IntPtr self, int val);
        static extern (C) void   wxStyledTextEvent_SetMessage(IntPtr self, int val);
        static extern (C) void   wxStyledTextEvent_SetWParam(IntPtr self, int val);
        static extern (C) void   wxStyledTextEvent_SetLParam(IntPtr self, int val);
        static extern (C) void   wxStyledTextEvent_SetListType(IntPtr self, int val);
        static extern (C) void   wxStyledTextEvent_SetX(IntPtr self, int val);
        static extern (C) void   wxStyledTextEvent_SetY(IntPtr self, int val);
        static extern (C) void   wxStyledTextEvent_SetDragText(IntPtr self, string val);
        static extern (C) void   wxStyledTextEvent_SetDragAllowMove(IntPtr self, bool val);
        //static extern (C) void   wxStyledTextEvent_SetDragResult(IntPtr self, wxDragResult val);
        static extern (C) int    wxStyledTextEvent_GetPosition(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetKey(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetModifiers(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetModificationType(IntPtr self);
        static extern (C) IntPtr wxStyledTextEvent_GetText(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetLength(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetLinesAdded(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetLine(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetFoldLevelNow(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetFoldLevelPrev(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetMargin(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetMessage(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetWParam(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetLParam(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetListType(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetX(IntPtr self);
        static extern (C) int    wxStyledTextEvent_GetY(IntPtr self);
        static extern (C) IntPtr wxStyledTextEvent_GetDragText(IntPtr self);
        static extern (C) bool   wxStyledTextEvent_GetDragAllowMove(IntPtr self);
        //static extern (C) IntPtr wxStyledTextEvent_GetDragResult(IntPtr self);
        static extern (C) bool   wxStyledTextEvent_GetShift(IntPtr self);
        static extern (C) bool   wxStyledTextEvent_GetControl(IntPtr self);
        static extern (C) bool   wxStyledTextEvent_GetAlt(IntPtr self);
        //! \endcond

        //-----------------------------------------------------------------------------

    alias StyledTextEvent wxStyledTextEvent;
    public class StyledTextEvent : CommandEvent 
    {
		public this(IntPtr wxobj) 
            { super(wxobj); }

        public  this(int commandType, int id)
            { super(wxStyledTextEvent_ctor(commandType, id)); }

        //-----------------------------------------------------------------------------

        public int Position() { return wxStyledTextEvent_GetPosition(wxobj); }
        public void Position(int value) { wxStyledTextEvent_SetPosition(wxobj, value); }

        //-----------------------------------------------------------------------------

        public int Key() { return wxStyledTextEvent_GetKey(wxobj); }
        public void Key(int value) { wxStyledTextEvent_SetKey(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void Modifiers(int value) { wxStyledTextEvent_SetModifiers(wxobj, value); }
        public int Modifiers() { return wxStyledTextEvent_GetModifiers(wxobj); } 

        //-----------------------------------------------------------------------------

        public void ModificationType(int value) { wxStyledTextEvent_SetModificationType(wxobj, value); }
        public int ModificationType() { return wxStyledTextEvent_GetModificationType(wxobj); }

        //-----------------------------------------------------------------------------

        public void Text(string value) { wxStyledTextEvent_SetText(wxobj, value); } 
        public string Text() { return cast(string) new wxString(wxStyledTextEvent_GetText(wxobj), true); }

        //-----------------------------------------------------------------------------

        public void Length(int value) { wxStyledTextEvent_SetLength(wxobj, value); }
        public int Length() { return wxStyledTextEvent_GetLength(wxobj); }

        //-----------------------------------------------------------------------------

        public void LinesAdded(int value) { wxStyledTextEvent_SetLinesAdded(wxobj, value); } 
        public int LinesAdded() { return wxStyledTextEvent_GetLinesAdded(wxobj); }

        //-----------------------------------------------------------------------------

        public void Line(int value) { wxStyledTextEvent_SetLine(wxobj, value); } 
        public int Line() { return wxStyledTextEvent_GetLine(wxobj); }

        //-----------------------------------------------------------------------------

        public void FoldLevelNow(int value) { wxStyledTextEvent_SetFoldLevelNow(wxobj, value); }
        public int FoldLevelNow() { return wxStyledTextEvent_GetFoldLevelNow(wxobj); }

        public void FoldLevelPrev(int value) { wxStyledTextEvent_SetFoldLevelPrev(wxobj, value); }
        public int FoldLevelPrev() { return wxStyledTextEvent_GetFoldLevelPrev(wxobj); }

        //-----------------------------------------------------------------------------

        public void Margin(int value) { wxStyledTextEvent_SetMargin(wxobj, value); }
        public int Margin() { return wxStyledTextEvent_GetMargin(wxobj); }

        //-----------------------------------------------------------------------------

        public void Message(int value) { wxStyledTextEvent_SetMessage(wxobj, value); } 
        public int Message() { return wxStyledTextEvent_GetMessage(wxobj); }

        //-----------------------------------------------------------------------------

        public void WParam(int value) { wxStyledTextEvent_SetWParam(wxobj, value); }
        public int WParam() { return wxStyledTextEvent_GetWParam(wxobj); }

        //-----------------------------------------------------------------------------

        public void LParam(int value) { wxStyledTextEvent_SetLParam(wxobj, value); }
        public int LParam() { return wxStyledTextEvent_GetLParam(wxobj); }

        //-----------------------------------------------------------------------------

        public void ListType(int value) { wxStyledTextEvent_SetListType(wxobj, value); }
        public int ListType() { return wxStyledTextEvent_GetListType(wxobj); }

        //-----------------------------------------------------------------------------

        public void X(int value) { wxStyledTextEvent_SetX(wxobj, value); }
        public int X() { return wxStyledTextEvent_GetX(wxobj); }

        //-----------------------------------------------------------------------------

        public void Y(int value) { wxStyledTextEvent_SetY(wxobj, value); }
        public int Y() { return wxStyledTextEvent_GetY(wxobj); }

        //-----------------------------------------------------------------------------

        public void DragText(string value) { wxStyledTextEvent_SetDragText(wxobj, value); }
        public string DragText() { return cast(string) new wxString(wxStyledTextEvent_GetDragText(wxobj), true); }

        //-----------------------------------------------------------------------------

        public void DragAllowMove(bool value) { wxStyledTextEvent_SetDragAllowMove(wxobj, value); } 
        public bool DragAllowMove() { return wxStyledTextEvent_GetDragAllowMove(wxobj); }

        //-----------------------------------------------------------------------------

        /*public DragResult DragResult
        {
            set { wxStyledTextEvent_SetDragResult(wxobj, wxObject.SafePtr(value)); }
            get { return wxStyledTextEvent_GetDragResult(wxobj); }
        }*/

        //-----------------------------------------------------------------------------

        public bool Shift() { return wxStyledTextEvent_GetShift(wxobj); }

        public bool Control() { return wxStyledTextEvent_GetControl(wxobj); }

        public bool Alt() { return wxStyledTextEvent_GetAlt(wxobj); }

        private static Event New(IntPtr obj) { return new StyledTextEvent(obj); }
    }

//! \cond VERSION
} // version(WXD_STYLEDTEXTCTRL)
//! \endcond
