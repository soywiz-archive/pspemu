//-----------------------------------------------------------------------------
// wxD - WizardPageSimple.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - WizardPageSimple.cs
//
/// The wxWizardPageSimple wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: WizardPageSimple.d,v 1.9 2006/11/17 15:21:01 afb Exp $
//-----------------------------------------------------------------------------

module wx.WizardPageSimple;
public import wx.WizardPage;
public import wx.Wizard;

		//! \cond EXTERN
		static extern (C) IntPtr wxWizardPageSimple_ctor(IntPtr parent, IntPtr prev, IntPtr next, IntPtr bitmap, string resource);
		static extern (C) void   wxWizardPageSimple_Chain(IntPtr first, IntPtr second);
		//! \endcond

		//---------------------------------------------------------------------

	alias WizardPageSimple wxWizardPageSimple;
	public class WizardPageSimple : WizardPage
	{
		public this(Wizard parent, WizardPage prev = null, WizardPage next = null, Bitmap bitmap = Bitmap.wxNullBitmap, string resource = null)
		{
			super(wxWizardPageSimple_ctor(wxObject.SafePtr(parent),
						wxObject.SafePtr(prev),wxObject.SafePtr(next),
						wxObject.SafePtr(bitmap),resource));
		}

		public this(IntPtr wxobj) 
		{
			super(wxobj);
		}

		//---------------------------------------------------------------------

		public static void Chain(WizardPageSimple first, WizardPageSimple second)
		{
			wxWizardPageSimple_Chain(wxObject.SafePtr(first), wxObject.SafePtr(second));
		}

		//---------------------------------------------------------------------
	}

