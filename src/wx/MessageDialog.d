//-----------------------------------------------------------------------------
// wxD - MessageDialog.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - MessageDialog.cs
//
/// The wxMessageDialog wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: MessageDialog.d,v 1.10 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.MessageDialog;
public import wx.common;
public import wx.Dialog;

	// The MessageDialog class implements the interface for wxWidgets' 
	// wxMessageDialog class and wxMessageBox.

		//! \cond EXTERN

		// MessageBox function
		static extern (C) int    wxMsgBox(IntPtr parent, string msg, string cap, uint style, ref Point pos);

		// Message dialog methods
		static extern (C) IntPtr wxMessageDialog_ctor(IntPtr parent, string message, string caption, uint style, ref Point pos);
		static extern (C) int    wxMessageDialog_ShowModal(IntPtr self);

		//! \endcond

	alias MessageDialog wxMessageDialog;
	public class MessageDialog : Dialog
	{
		public const string wxMessageBoxCaptionStr = "Message";
		//---------------------------------------------------------------------
	
		private this(IntPtr wxobj) 
			{ super(wxobj); }

		public this(Window parent, string msg, string caption=wxMessageBoxCaptionStr, int style=wxOK | wxCENTRE, Point pos = wxDefaultPosition)
			{ this(wxMessageDialog_ctor(wxObject.SafePtr(parent), msg, caption, cast(uint)style, pos)); }

		//---------------------------------------------------------------------

		public override int ShowModal()
		{
			return wxMessageDialog_ShowModal(wxobj);
		}

		//---------------------------------------------------------------------

	}

		static extern(C) int wxMessageBox_func(string msg, string cap, int style, IntPtr parent,int x, int y);

		static int MessageBox(string msg,string caption=MessageDialog.wxMessageBoxCaptionStr,int style=Dialog.wxOK | Dialog.wxCENTRE , Window parent=null, int x=-1, int y=-1)
		{
			return wxMessageBox_func(msg,caption,style,wxObject.SafePtr(parent),x,y);
		}

		/* wx.NET compat */
		static int MessageBox(Window parent,string msg,string caption=MessageDialog.wxMessageBoxCaptionStr,int style=Dialog.wxOK | Dialog.wxCENTRE , Point pos=Dialog.wxDefaultPosition)
		{
			return wxMessageBox_func(msg,caption,style,wxObject.SafePtr(parent),pos.X,pos.Y);
		}
