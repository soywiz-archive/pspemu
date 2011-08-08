//-----------------------------------------------------------------------------
// wxD - WizardPage.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - WizardPage.cs
//
/// The wxWizardPage wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: WizardPage.d,v 1.9 2006/11/17 15:21:01 afb Exp $
//-----------------------------------------------------------------------------

module wx.WizardPage;
public import wx.Panel;

	alias WizardPage wxWizardPage;
	public class WizardPage : Panel
	{
		//---------------------------------------------------------------------

		public this(IntPtr wxobj) 
		{
			super(wxobj);
		}

		static wxObject New(IntPtr ptr) { return new WizardPage(ptr); }
		//---------------------------------------------------------------------
	}

