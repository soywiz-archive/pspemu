//-----------------------------------------------------------------------------
// wxD - TipDialog.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - TipDialog.cs
//
/// The wxTipProvider proxy interface.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2003 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: TipDialog.d,v 1.9 2006/11/17 15:21:01 afb Exp $
//-----------------------------------------------------------------------------

module wx.TipDialog;
public import wx.common;
public import wx.Dialog;

	//! \cond EXTERN
	static extern (C) IntPtr wxCreateFileTipProvider_func(string filename, int currentTip);
	static extern (C) bool wxShowTip_func(IntPtr parent, IntPtr tipProvider, bool showAtStartup);
	static extern (C) int wxTipProvider_GetCurrentTip();
	//! \endcond

    alias TipProvider wxTipProvider;
    public class TipProvider
    {
	public static IntPtr CreateFileTipProvider(string filename, int currentTip)
	{
		return wxCreateFileTipProvider_func(filename, currentTip);
	}

	public static bool ShowTip(Window parent, IntPtr tipProvider)
	{
		return wxShowTip_func(wxObject.SafePtr(parent), tipProvider, true);
	}

	public static bool ShowTip(Window parent, IntPtr tipProvider, bool showAtStartup)
	{
		return wxShowTip_func(wxObject.SafePtr(parent), tipProvider, showAtStartup);
	}

	static int CurrentTip() { return wxTipProvider_GetCurrentTip(); }
    }
