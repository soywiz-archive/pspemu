//-----------------------------------------------------------------------------
// wxD - Validator.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Validator.cs
//
/// The wxValidator wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Validator.d,v 1.9 2006/11/17 15:21:01 afb Exp $
//-----------------------------------------------------------------------------

module wx.Validator;
public import wx.common;
public import wx.EvtHandler;

		//! \cond EXTERN
		static extern (C) IntPtr wxValidator_ctor();
		static extern (C) IntPtr wxDefaultValidator_Get();
		//! \endcond
		
		//---------------------------------------------------------------------
		
	alias Validator wxValidator;
	public class Validator : EvtHandler
	{
		static Validator wxDefaultValidator;
		static this()
		{
			wxDefaultValidator = new Validator(wxDefaultValidator_Get());
		}
	
		public this()
			{ super(wxValidator_ctor());}

		public this(IntPtr wxobj) 
			{ super(wxobj);}

		//---------------------------------------------------------------------
	}
