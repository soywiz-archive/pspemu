//-----------------------------------------------------------------------------
// wxD - HtmlHelpController.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - HtmlHelpController.cs
//
/// The wxHtmlHelpController wrapper class
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: HtmlHelpController.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.HtmlHelpController;
public import wx.common;

public import wx.Config;
public import wx.Frame;

		//! \cond EXTERN
		static extern (C) IntPtr wxHtmlHelpController_ctor(int style);
		static extern (C) void   wxHtmlHelpController_SetTitleFormat(IntPtr self, string format);
		static extern (C) void   wxHtmlHelpController_SetTempDir(IntPtr self, string path);
		static extern (C) bool   wxHtmlHelpController_AddBook(IntPtr self, string book_url);
		static extern (C) bool   wxHtmlHelpController_Display(IntPtr self, string x);
		static extern (C) bool   wxHtmlHelpController_DisplayInt(IntPtr self, int id);
		static extern (C) bool   wxHtmlHelpController_DisplayContents(IntPtr self);
		static extern (C) bool   wxHtmlHelpController_DisplayIndex(IntPtr self);
		static extern (C) bool   wxHtmlHelpController_KeywordSearch(IntPtr self, string keyword, int mode);
		static extern (C) void   wxHtmlHelpController_UseConfig(IntPtr self, IntPtr config, string rootpath);
		static extern (C) void   wxHtmlHelpController_ReadCustomization(IntPtr self, IntPtr cfg, string path);
		static extern (C) void   wxHtmlHelpController_WriteCustomization(IntPtr self, IntPtr cfg, string path);
		static extern (C) IntPtr wxHtmlHelpController_GetFrame(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------
		
	alias HtmlHelpController wxHtmlHelpController;
	public class HtmlHelpController : wxObject
	{
		enum {
			wxHF_TOOLBAR =	0x0001,
			wxHF_CONTENTS =	0x0002,
			wxHF_INDEX =		0x0004,
			wxHF_SEARCH =		0x0008,
			wxHF_BOOKMARKS =	0x0010,
			wxHF_OPEN_FILES =	0x0020,
			wxHF_PRINT = 		0x0040,
			wxHF_FLAT_TOOLBAR =	0x0080,
			wxHF_MERGE_BOOKS =	0x0100,
			wxHF_ICONS_BOOK =	0x0200,
			wxHF_ICONS_BOOK_CHAPTER = 0x0400,
			wxHF_ICONS_FOLDER = 0x0000,
			wxHF_DEFAULT_STYLE =		(wxHF_TOOLBAR | wxHF_CONTENTS | 
					wxHF_INDEX | wxHF_SEARCH | 
					wxHF_BOOKMARKS | wxHF_PRINT),
			wxHF_OPENFILES =	wxHF_OPEN_FILES,
			wxHF_FLATTOOLBAR = 	wxHF_FLAT_TOOLBAR,
			wxHF_DEFAULTSTYLE =	wxHF_DEFAULT_STYLE,
		}
		//-----------------------------------------------------------------------------
	
		public this(IntPtr wxobj)
			{ super(wxobj);}
			
		public this(int style = wxHF_DEFAULT_STYLE)
			{ super(wxHtmlHelpController_ctor(style));}
			
		//-----------------------------------------------------------------------------
		
		public void TitleFormat(string value) { wxHtmlHelpController_SetTitleFormat(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public void TempDir(string value) { wxHtmlHelpController_SetTempDir(wxobj, value); }
		
		//-----------------------------------------------------------------------------
		
		public bool AddBook(string book_url)
		{
			return wxHtmlHelpController_AddBook(wxobj, book_url);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool Display(string x)
		{
			return wxHtmlHelpController_Display(wxobj, x);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool Display(int id)
		{
			return wxHtmlHelpController_DisplayInt(wxobj, id); 
		}
		
		//-----------------------------------------------------------------------------
		
		public bool DisplayContents()
		{
			return wxHtmlHelpController_DisplayContents(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool DisplayIndex()
		{
			return wxHtmlHelpController_DisplayIndex(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool KeywordSearch(string keyword)
		{
			return KeywordSearch(keyword, HelpSearchMode.wxHELP_SEARCH_ALL);
		}
		
		public bool KeywordSearch(string keyword, HelpSearchMode mode)
		{
			return wxHtmlHelpController_KeywordSearch(wxobj, keyword, cast(int)mode);
		}
		
		//-----------------------------------------------------------------------------
		
		public void UseConfig(Config config)
		{
			UseConfig(config, "");
		}
		
		public void UseConfig(Config config, string rootpath)
		{
			wxHtmlHelpController_UseConfig(wxobj, wxObject.SafePtr(config), rootpath);
		}
		
		//-----------------------------------------------------------------------------
		
		public void ReadCustomization(Config cfg)
		{
			ReadCustomization(cfg, "");
		}
		
		public void ReadCustomization(Config cfg, string path)
		{
			wxHtmlHelpController_ReadCustomization(wxobj, wxObject.SafePtr(cfg), path);
		}
		
		//-----------------------------------------------------------------------------
		
		public void WriteCustomization(Config cfg)
		{
			WriteCustomization(cfg, "");
		}
		
		public void WriteCustomization(Config cfg, string path)
		{
			wxHtmlHelpController_WriteCustomization(wxobj, wxObject.SafePtr(cfg), path);
		}
		
		//-----------------------------------------------------------------------------
		
		public Frame frame() { 
				IntPtr tmp = wxHtmlHelpController_GetFrame(wxobj); 
				if ( tmp != IntPtr.init )
					return new Frame(tmp);
				else
					return null;
			}
	}
