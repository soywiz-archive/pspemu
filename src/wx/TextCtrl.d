//-----------------------------------------------------------------------------
// wxD - TextCtrl.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - TextCtrl.cs
//
/// The wxTextCtrl wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
// $Id: TextCtrl.d,v 1.12 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.TextCtrl;
public import wx.common;
public import wx.Control;
public import wx.CommandEvent;
public import wx.KeyEvent;

	public enum TextAttrAlignment
	{
		wxTEXT_ALIGNMENT_DEFAULT,
		wxTEXT_ALIGNMENT_LEFT,
		wxTEXT_ALIGNMENT_CENTRE,
		wxTEXT_ALIGNMENT_CENTER = wxTEXT_ALIGNMENT_CENTRE,
		wxTEXT_ALIGNMENT_RIGHT,
		wxTEXT_ALIGNMENT_JUSTIFIED
	}
	
	//---------------------------------------------------------------------
	
	public enum TextCtrlHitTestResult
	{
		wxTE_HT_UNKNOWN = -2,
		wxTE_HT_BEFORE,      
		wxTE_HT_ON_TEXT,     
		wxTE_HT_BELOW,       
		wxTE_HT_BEYOND       
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxTextAttr_ctor(IntPtr colText, IntPtr colBack, IntPtr font, int alignment);
		static extern (C) IntPtr wxTextAttr_ctor2();
		static extern (C) void   wxTextAttr_dtor(IntPtr self);
		static extern (C) void   wxTextAttr_Init(IntPtr self);
		static extern (C) void   wxTextAttr_SetTextColour(IntPtr self, IntPtr colText);
		static extern (C) IntPtr wxTextAttr_GetTextColour(IntPtr self);
		static extern (C) void   wxTextAttr_SetBackgroundColour(IntPtr self, IntPtr colBack);
		static extern (C) IntPtr wxTextAttr_GetBackgroundColour(IntPtr self);
		static extern (C) void   wxTextAttr_SetFont(IntPtr self, IntPtr font);
		static extern (C) IntPtr wxTextAttr_GetFont(IntPtr self);
		static extern (C) bool   wxTextAttr_HasTextColour(IntPtr self);
		static extern (C) bool   wxTextAttr_HasBackgroundColour(IntPtr self);
		static extern (C) bool   wxTextAttr_HasFont(IntPtr self);
		static extern (C) bool   wxTextAttr_IsDefault(IntPtr self);
		
		static extern (C) void   wxTextAttr_SetAlignment(IntPtr self, int alignment);
		static extern (C) int    wxTextAttr_GetAlignment(IntPtr self);
		static extern (C) void   wxTextAttr_SetTabs(IntPtr self, IntPtr tabs);
		static extern (C) IntPtr wxTextAttr_GetTabs(IntPtr self);
		static extern (C) void   wxTextAttr_SetLeftIndent(IntPtr self, int indent, int subIndent);
		static extern (C) int    wxTextAttr_GetLeftIndent(IntPtr self);
		static extern (C) int    wxTextAttr_GetLeftSubIndent(IntPtr self);
		static extern (C) void   wxTextAttr_SetRightIndent(IntPtr self, int indent);
		static extern (C) int    wxTextAttr_GetRightIndent(IntPtr self);
		static extern (C) void   wxTextAttr_SetFlags(IntPtr self, uint flags);
		static extern (C) uint   wxTextAttr_GetFlags(IntPtr self);
		static extern (C) bool   wxTextAttr_HasAlignment(IntPtr self);
		static extern (C) bool   wxTextAttr_HasTabs(IntPtr self);
		static extern (C) bool   wxTextAttr_HasLeftIndent(IntPtr self);
		static extern (C) bool   wxTextAttr_HasRightIndent(IntPtr self);
		static extern (C) bool   wxTextAttr_HasFlag(IntPtr self, uint flag);
		//! \endcond
		
		//---------------------------------------------------------------------
		
	alias TextAttr wxTextAttr;
	public class TextAttr : wxObject
	{
		public const int wxTEXT_ATTR_TEXT_COLOUR =		0x0001;
		public const int wxTEXT_ATTR_BACKGROUND_COLOUR =	0x0002;
		public const int wxTEXT_ATTR_FONT_FACE =		0x0004;
		public const int wxTEXT_ATTR_FONT_SIZE = 		0x0008;
		public const int wxTEXT_ATTR_FONT_WEIGHT =		0x0010;
		public const int wxTEXT_ATTR_FONT_ITALIC =		0x0020;
		public const int wxTEXT_ATTR_FONT_UNDERLINE =		0x0040;
		public const int wxTEXT_ATTR_FONT = wxTEXT_ATTR_FONT_FACE | wxTEXT_ATTR_FONT_SIZE | 
							wxTEXT_ATTR_FONT_WEIGHT | wxTEXT_ATTR_FONT_ITALIC | 
							wxTEXT_ATTR_FONT_UNDERLINE;
		public const int wxTEXT_ATTR_ALIGNMENT =		0x0080;
		public const int wxTEXT_ATTR_LEFT_INDENT =		0x0100;
		public const int wxTEXT_ATTR_RIGHT_INDENT =		0x0200;
		public const int wxTEXT_ATTR_TABS =			0x0400;

	
		//---------------------------------------------------------------------
	
		public this(IntPtr wxobj)
		{
			super(wxobj);
		}
		
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}

	        public this(Colour colText, Colour colBack=null, Font font=null, TextAttrAlignment alignment = TextAttrAlignment.wxTEXT_ALIGNMENT_DEFAULT)
        		{ this(wxTextAttr_ctor(wxObject.SafePtr(colText), wxObject.SafePtr(colBack), wxObject.SafePtr(font), cast(int)alignment), true); }
			
		//---------------------------------------------------------------------
		
		override protected void dtor() { wxTextAttr_dtor(wxobj); }
			    
		//---------------------------------------------------------------------
		
		public void TextColour(Colour value) { wxTextAttr_SetTextColour(wxobj, wxObject.SafePtr(value)); }
		public Colour TextColour() { return new Colour(wxTextAttr_GetTextColour(wxobj), true); }
		
		//---------------------------------------------------------------------
		
		public void BackgroundColour(Colour value) { wxTextAttr_SetBackgroundColour(wxobj, wxObject.SafePtr(value)); }
		public Colour BackgroundColour() { return new Colour(wxTextAttr_GetBackgroundColour(wxobj), true); }
		
		//---------------------------------------------------------------------
		
		public void font(Font value) { wxTextAttr_SetFont(wxobj, wxObject.SafePtr(value)); }
		public Font font() { return new Font(wxTextAttr_GetFont(wxobj)); }
		
		//---------------------------------------------------------------------
		
		public void Alignment(TextAttrAlignment value) { wxTextAttr_SetAlignment(wxobj, cast(int)value); }
		public TextAttrAlignment Alignment() { return cast(TextAttrAlignment)wxTextAttr_GetAlignment(wxobj); }
		
		//---------------------------------------------------------------------
		
		public void Tabs(int[] value)
		{
			ArrayInt ai = new ArrayInt();
			
			for(int i = 0; i < value.length; ++i)
				ai.Add(value[i]);
				
			wxTextAttr_SetTabs(wxobj, ArrayInt.SafePtr(ai));
		}
		public int[] Tabs()
		{
			return (new ArrayInt(wxTextAttr_GetTabs(wxobj), true)).toArray();
		}
		
		//---------------------------------------------------------------------
		
		public void SetLeftIndent(int indent)
		{
			SetLeftIndent(indent, 0);
		}
		
		public void SetLeftIndent(int indent, int subIndent)
		{
			wxTextAttr_SetLeftIndent(wxobj, indent, subIndent);
		}
		
		public int LeftIndent() { return wxTextAttr_GetLeftIndent(wxobj); }
		
		public int LeftSubIndent() { return wxTextAttr_GetLeftSubIndent(wxobj); }
		
		//---------------------------------------------------------------------
		
		public void RightIndent(int value) { wxTextAttr_SetRightIndent(wxobj, value); }
		public int RightIndent() { return wxTextAttr_GetRightIndent(wxobj); }
		
		//---------------------------------------------------------------------
		
		public void Flags(int value) { wxTextAttr_SetFlags(wxobj, cast(uint)value); }
		public int Flags() { return cast(int)wxTextAttr_GetFlags(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool HasTextColour() { return wxTextAttr_HasTextColour(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool HasBackgroundColour() { return wxTextAttr_HasBackgroundColour(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool HasFont() { return wxTextAttr_HasFont(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool HasAlignment() { return wxTextAttr_HasAlignment(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool HasTabs() { return wxTextAttr_HasTabs(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool HasLeftIndent() { return wxTextAttr_HasLeftIndent(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool HasRightIndent() { return wxTextAttr_HasRightIndent(wxobj); }
		
		//---------------------------------------------------------------------
		
		public bool HasFlag(int flag)
		{
			return wxTextAttr_HasFlag(wxobj, cast(uint)flag); 
		}
		
		//---------------------------------------------------------------------
		
		public bool IsDefault() { return wxTextAttr_IsDefault(wxobj); }
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxTextCtrl_GetValue(IntPtr self);
		static extern (C) void   wxTextCtrl_SetValue(IntPtr self, string value);
		static extern (C) IntPtr wxTextCtrl_GetRange(IntPtr self, uint from, uint to);
		static extern (C) int    wxTextCtrl_GetLineLength(IntPtr self, uint lineNo);
		static extern (C) IntPtr wxTextCtrl_GetLineText(IntPtr self, uint lineNo);
		static extern (C) int    wxTextCtrl_GetNumberOfLines(IntPtr self);
		static extern (C) bool   wxTextCtrl_IsModified(IntPtr self);
		static extern (C) bool   wxTextCtrl_IsEditable(IntPtr self);
		static extern (C) bool   wxTextCtrl_IsSingleLine(IntPtr self);
		static extern (C) bool   wxTextCtrl_IsMultiLine(IntPtr self);
		static extern (C) void   wxTextCtrl_GetSelection(IntPtr self, out int from, out int to);
		static extern (C) IntPtr wxTextCtrl_GetStringSelection(IntPtr self);
		static extern (C) void   wxTextCtrl_Clear(IntPtr self);
		static extern (C) void   wxTextCtrl_Replace(IntPtr self, uint from, uint to, string value);
		static extern (C) void   wxTextCtrl_Remove(IntPtr self, uint from, uint to);
		static extern (C) bool   wxTextCtrl_LoadFile(IntPtr self, string file);
		static extern (C) bool   wxTextCtrl_SaveFile(IntPtr self, string file);
		static extern (C) void   wxTextCtrl_MarkDirty(IntPtr self);
		static extern (C) void   wxTextCtrl_DiscardEdits(IntPtr self);
		static extern (C) void   wxTextCtrl_SetMaxLength(IntPtr self, uint len);
		static extern (C) void   wxTextCtrl_WriteText(IntPtr self, string text);
		static extern (C) void   wxTextCtrl_AppendText(IntPtr self, string text);
		static extern (C) bool   wxTextCtrl_EmulateKeyPress(IntPtr self, IntPtr evt);
		static extern (C) bool   wxTextCtrl_SetStyle(IntPtr self, uint start, uint end, IntPtr style);
		static extern (C) bool   wxTextCtrl_GetStyle(IntPtr self, uint position, ref IntPtr style);
		static extern (C) bool   wxTextCtrl_SetDefaultStyle(IntPtr self, IntPtr style);
		static extern (C) IntPtr wxTextCtrl_GetDefaultStyle(IntPtr self);
		static extern (C) uint   wxTextCtrl_XYToPosition(IntPtr self, uint x, uint y);
		static extern (C) bool   wxTextCtrl_PositionToXY(IntPtr self, uint pos, out int x, out int y);
		static extern (C) void   wxTextCtrl_ShowPosition(IntPtr self, uint pos);
		static extern (C) int    wxTextCtrl_HitTest(IntPtr self, ref Point pt, out int pos);
		static extern (C) int    wxTextCtrl_HitTest2(IntPtr self, ref Point pt, out int col, out int row);
		static extern (C) void   wxTextCtrl_Copy(IntPtr self);
		static extern (C) void   wxTextCtrl_Cut(IntPtr self);
		static extern (C) void   wxTextCtrl_Paste(IntPtr self);
		static extern (C) bool   wxTextCtrl_CanCopy(IntPtr self);
		static extern (C) bool   wxTextCtrl_CanCut(IntPtr self);
		static extern (C) bool   wxTextCtrl_CanPaste(IntPtr self);
		static extern (C) void   wxTextCtrl_Undo(IntPtr self);
		static extern (C) void   wxTextCtrl_Redo(IntPtr self);
		static extern (C) bool   wxTextCtrl_CanUndo(IntPtr self);
		static extern (C) bool   wxTextCtrl_CanRedo(IntPtr self);
		static extern (C) void   wxTextCtrl_SetInsertionPoint(IntPtr self, uint pos);
		static extern (C) void   wxTextCtrl_SetInsertionPointEnd(IntPtr self);
		static extern (C) uint   wxTextCtrl_GetInsertionPoint(IntPtr self);
		static extern (C) uint   wxTextCtrl_GetLastPosition(IntPtr self);
		static extern (C) void   wxTextCtrl_SetSelection(IntPtr self, uint from, uint to);
		static extern (C) void   wxTextCtrl_SelectAll(IntPtr self);
		static extern (C) void   wxTextCtrl_SetEditable(IntPtr self, bool editable);
		static extern (C)        IntPtr wxTextCtrl_ctor();
		static extern (C) bool   wxTextCtrl_Create(IntPtr self, IntPtr parent, int id, string value, ref Point pos, ref Size size, uint style, IntPtr validator, string name);
		static extern (C) bool   wxTextCtrl_Enable(IntPtr self, bool enable);
		static extern (C) void   wxTextCtrl_OnDropFiles(IntPtr self, IntPtr evt);
		static extern (C) bool   wxTextCtrl_SetFont(IntPtr self, IntPtr font);
		static extern (C) bool   wxTextCtrl_SetForegroundColour(IntPtr self, IntPtr colour);
		static extern (C) bool   wxTextCtrl_SetBackgroundColour(IntPtr self, IntPtr colour);
		static extern (C) void   wxTextCtrl_Freeze(IntPtr self);
		static extern (C) void   wxTextCtrl_Thaw(IntPtr self);
		static extern (C) bool   wxTextCtrl_ScrollLines(IntPtr self, int lines);
		static extern (C) bool   wxTextCtrl_ScrollPages(IntPtr self, int pages);
		//! \endcond

		//---------------------------------------------------------------------
        
	alias TextCtrl wxTextCtrl;
	public class TextCtrl : Control
	{
		public const int wxTE_NO_VSCROLL       = 0x0002;
		public const int wxTE_AUTO_SCROLL      = 0x0008;
	
		public const int wxTE_READONLY         = 0x0010;
		public const int wxTE_MULTILINE        = 0x0020;
		public const int wxTE_PROCESS_TAB      = 0x0040;
	
		public const int wxTE_LEFT             = 0x0000;
		public const int wxTE_CENTER           = Alignment.wxALIGN_CENTER;
		public const int wxTE_RIGHT            = Alignment.wxALIGN_RIGHT;
	
		public const int wxTE_RICH             = 0x0080;
		public const int wxTE_PROCESS_ENTER    = 0x0400;
		public const int wxTE_PASSWORD         = 0x0800;
	
		public const int wxTE_AUTO_URL         = 0x1000;
		public const int wxTE_NOHIDESEL        = 0x2000;
		public const int wxTE_DONTWRAP         = Window.wxHSCROLL;
		public const int wxTE_LINEWRAP         = 0x4000;
		public const int wxTE_WORDWRAP         = 0x0000;
		public const int wxTE_RICH2            = 0x8000;


		public const string wxTextCtrlNameStr = "text";
		//---------------------------------------------------------------------

		public this(IntPtr wxobj)
			{ super(wxobj); }

		public this(Window parent, int id, string value="", Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, Validator validator = null, string name = wxTextCtrlNameStr)
		{
			this(wxTextCtrl_ctor());
			if (!wxTextCtrl_Create(wxobj, wxObject.SafePtr(parent), id, value, pos, size, cast(uint)style, wxObject.SafePtr(validator), name))
			{
				throw new InvalidOperationException("Failed to create TextCtrl");
			}
		}

		public static wxObject New(IntPtr wxobj)
		{
			return new TextCtrl(wxobj);
		}
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, string value="", Point pos = wxDefaultPosition, Size size = wxDefaultSize, int style = 0, Validator validator = null, string name = wxTextCtrlNameStr)
			{ this(parent, Window.UniqueID, value, pos, size, 0, validator, name);}
	
		//---------------------------------------------------------------------

		public void Clear()
		{
			wxTextCtrl_Clear(wxobj);
		}
	
		//---------------------------------------------------------------------
	
		public override void BackgroundColour(Colour value)
		{
			wxTextCtrl_SetBackgroundColour(wxobj, wxObject.SafePtr(value));
		}
	
		public override void ForegroundColour(Colour value)
		{
			wxTextCtrl_SetForegroundColour(wxobj, wxObject.SafePtr(value));
		}
	
		//---------------------------------------------------------------------
	
		public string Value() 
			{
				return cast(string) new wxString(wxTextCtrl_GetValue(wxobj), true);
			}
		public void Value(string value) 
			{
				wxTextCtrl_SetValue(wxobj, value);
			}
	
		//---------------------------------------------------------------------
	
		public string GetRange(int from, int to)
		{
			return cast(string) new wxString(wxTextCtrl_GetRange(wxobj, cast(uint)from, cast(uint)to), true);
		}
	
		//---------------------------------------------------------------------
	
		public int LineLength(int lineNo)
		{
			return wxTextCtrl_GetLineLength(wxobj, cast(uint)lineNo);
		}
	
		public string GetLineText(int lineNo)
		{
			return cast(string) new wxString(wxTextCtrl_GetLineText(wxobj, cast(uint)lineNo), true);
		}
	
		public int GetNumberOfLines()
		{
			return wxTextCtrl_GetNumberOfLines(wxobj);
		}
	
		//---------------------------------------------------------------------
	
		public bool IsModified() { return wxTextCtrl_IsModified(wxobj); }
	
		public bool IsEditable() { return wxTextCtrl_IsEditable(wxobj); }
	
		public bool IsSingleLine() { return wxTextCtrl_IsSingleLine(wxobj); }
	
		public bool IsMultiLine() { return wxTextCtrl_IsMultiLine(wxobj); }
	
		//---------------------------------------------------------------------
	
		public void GetSelection(out int from, out int to)
		{
			wxTextCtrl_GetSelection(wxobj, from, to);
		}
	
		//---------------------------------------------------------------------
	
		public void Replace(int from, int to, string value)
		{
			wxTextCtrl_Replace(wxobj, cast(uint)from, cast(uint)to, value);
		}
	
		public void Remove(int from, int to)
		{
			wxTextCtrl_Remove(wxobj, cast(uint)from, cast(uint)to);
		}
	
		//---------------------------------------------------------------------
	
		public bool LoadFile(string file)
		{
			return wxTextCtrl_LoadFile(wxobj, file);
		}
		
		// using wx.NET with wxGTK wxTextCtrl_LoadFile didn't work
		// LoadFileNET uses StreamReader
		// this should also handle encoding problems...
/+
		public bool LoadFileNET(string file)
		{
			try
			{
				System.IO.StreamReader sr = new System.IO.StreamReader(file);
				string s = sr.ReadToEnd();
				sr.Close();
				AppendText(s);
				
				return true;
				
			} catch ( Exception e )
			{
				return false;
			}
		}
+/
	
		public bool SaveFile(string file)
		{
			return wxTextCtrl_SaveFile(wxobj, file);
		}
		
		// counterpart of LoadFileNET
/+
		public bool SaveFileNET(string file)
		{
			try
			{
				System.IO.StreamWriter sw = new System.IO.StreamWriter(file);
				sw.Write(Value);
				sw.Close();
				
				return true;
			} catch ( Exception e )
			{
				return false;
			}
		}
+/
	
		//---------------------------------------------------------------------
	
		public void DiscardEdits()
		{
			wxTextCtrl_DiscardEdits(wxobj);
		}
		
		//---------------------------------------------------------------------
		
		public void MarkDirty()
		{
			wxTextCtrl_MarkDirty(wxobj);
		}
	
		//---------------------------------------------------------------------
	
		public void MaxLength(int value) { wxTextCtrl_SetMaxLength(wxobj, cast(uint)value); }
	
		//---------------------------------------------------------------------
	
		public void WriteText(string text)
		{
			wxTextCtrl_WriteText(wxobj, text);
		}
		
		//---------------------------------------------------------------------
	
		public void AppendText(string text)
		{
			wxTextCtrl_AppendText(wxobj, text);
		}
		
		//---------------------------------------------------------------------
		
		public bool EmulateKeyPress(KeyEvent evt)
		{
			return wxTextCtrl_EmulateKeyPress(wxobj, wxObject.SafePtr(evt));
		}
	
		//---------------------------------------------------------------------
	
		public bool SetStyle(int start, int end, TextAttr style)
		{
			return wxTextCtrl_SetStyle(wxobj, cast(uint)start, cast(uint)end, wxObject.SafePtr(style));
		}
		
		public bool GetStyle(int position, ref TextAttr style)
		{
			IntPtr tmp = wxObject.SafePtr(style);
			bool retval = wxTextCtrl_GetStyle(wxobj, cast(uint)position, tmp);
			style.wxobj = tmp;
			return retval;
		}
		
		//---------------------------------------------------------------------
	
		public bool SetDefaultStyle(TextAttr style)
		{
			return wxTextCtrl_SetDefaultStyle(wxobj, wxObject.SafePtr(style));
		}
		
		public TextAttr GetDefaultStyle()
		{
			return cast(TextAttr)FindObject(wxTextCtrl_GetDefaultStyle(wxobj));
		}
	
		//---------------------------------------------------------------------
	
		public int XYToPosition(int x, int y)
		{
			return wxTextCtrl_XYToPosition(wxobj, cast(uint)x, cast(uint)y);
		}
	
		public bool PositionToXY(int pos, out int x, out int y)
		{
			return wxTextCtrl_PositionToXY(wxobj, cast(uint)pos, x, y);
		}
	
		public void ShowPosition(int pos)
		{
			wxTextCtrl_ShowPosition(wxobj, cast(uint)pos);
		}
	
		//---------------------------------------------------------------------
		
		public TextCtrlHitTestResult HitTest(Point pt, out int pos)
		{
			return cast(TextCtrlHitTestResult)wxTextCtrl_HitTest(wxobj, pt, pos);
		}
		
		public TextCtrlHitTestResult HitTest(Point pt, out int col, out int row)
		{
			return cast(TextCtrlHitTestResult)wxTextCtrl_HitTest2(wxobj, pt, col, row);
		}
		
		//---------------------------------------------------------------------
	
		public void Copy()
		{
			wxTextCtrl_Copy(wxobj);
		}
	
		public void Cut()
		{
			wxTextCtrl_Cut(wxobj);
		}
	
		public void Paste()
		{
			wxTextCtrl_Paste(wxobj);
		}
	
		//---------------------------------------------------------------------
	
		public bool CanCopy()
		{
			return wxTextCtrl_CanCopy(wxobj);
		}
	
		public bool CanCut()
		{
			return wxTextCtrl_CanCut(wxobj);
		}
	
		public bool CanPaste()
		{
			return wxTextCtrl_CanPaste(wxobj);
		}
	
		//---------------------------------------------------------------------
	
		public void Undo()
		{
			wxTextCtrl_Undo(wxobj);
		}
	
		public void Redo()
		{
			wxTextCtrl_Redo(wxobj);
		}
	
		//---------------------------------------------------------------------
	
		public bool CanUndo()
		{
			return wxTextCtrl_CanUndo(wxobj);
		}
	
		public bool CanRedo()
		{
			return wxTextCtrl_CanRedo(wxobj);
		}
	
		//---------------------------------------------------------------------
	
		public void InsertionPoint(int value) 
			{
				wxTextCtrl_SetInsertionPoint(wxobj, cast(uint)value);
			}
		public int InsertionPoint() 
			{
				return wxTextCtrl_GetInsertionPoint(wxobj);
			}
	
		public void SetInsertionPointEnd()
		{
			wxTextCtrl_SetInsertionPointEnd(wxobj);
		}
	
		public int GetLastPosition()
		{
			return cast(int)wxTextCtrl_GetLastPosition(wxobj);
		}
	
		//---------------------------------------------------------------------
	
		public void SetSelection(int from, int to)
		{
			wxTextCtrl_SetSelection(wxobj, cast(uint)from, cast(uint)to);
		}
	
		public void SelectAll()
		{
			wxTextCtrl_SelectAll(wxobj);
		}
	
		//---------------------------------------------------------------------
	
		public void SetEditable(bool editable)
		{
			wxTextCtrl_SetEditable(wxobj, editable);
		}
	
		//---------------------------------------------------------------------
	
		public bool Enable(bool enable)
		{
			return wxTextCtrl_Enable(wxobj, enable);
		}
	
		//---------------------------------------------------------------------
	
		public /+virtual+/ void OnDropFiles(Event evt)
		{
			wxTextCtrl_OnDropFiles(wxobj, wxObject.SafePtr(evt));
		}
	
		//---------------------------------------------------------------------
	
		public override void Freeze()
		{
			wxTextCtrl_Freeze(wxobj);
		}
	
		public override void Thaw()
		{
			wxTextCtrl_Thaw(wxobj);
		}
	
		//---------------------------------------------------------------------
	
		public override bool ScrollLines(int lines)
		{
			return wxTextCtrl_ScrollLines(wxobj, lines);
		}
	
		public override bool ScrollPages(int pages)
		{
			return wxTextCtrl_ScrollPages(wxobj, pages);
		}
	
		//---------------------------------------------------------------------
	
		public override void UpdateUI_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TEXT_UPDATED, ID, value, this); }
		public override void UpdateUI_Remove(EventListener value)	{ RemoveHandler(value, this); }

		public void Enter_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_TEXT_ENTER, ID, value, this); }
		public void Enter_Remove(EventListener value) { RemoveHandler(value, this); }
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxTextUrlEvent_ctor(int id, IntPtr evtMouse, uint start, uint end);
		static extern (C) uint   wxTextUrlEvent_GetURLStart(IntPtr self);
		static extern (C) uint   wxTextUrlEvent_GetURLEnd(IntPtr self);
		//! \endcond
	
	alias TextUrlEvent wxTextUrlEvent;
	public class TextUrlEvent : CommandEvent
    	{
		// TODO: Replace Event with EventMouse
		public this(int id, Event evtMouse, int start, int end)
		{ super(wxTextUrlEvent_ctor(id, wxObject.SafePtr(evtMouse), cast(uint)start, cast(uint)end));}
	}
