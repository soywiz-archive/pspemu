//-----------------------------------------------------------------------------
// wxD - BoxSizer.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - BoxSizer.cs
//
/// The wxBoxSizer wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: BoxSizer.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.BoxSizer;
public import wx.common;
public import wx.Sizer;

		//! \cond EXTERN
		extern(C) {
		alias void function(BoxSizer obj) Virtual_voidvoid;
		alias void function(BoxSizer obj,out Size size) Virtual_wxSizevoid;
		}
		
		static extern (C) void wxBoxSizer_RegisterVirtual(IntPtr self, BoxSizer obj, Virtual_voidvoid recalcSizes, Virtual_wxSizevoid calcMin);	
		static extern (C) void wxBoxSizer_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
	
		static extern (C) IntPtr wxBoxSizer_ctor(int orient);
		static extern (C) void wxBoxSizer_RecalcSizes(IntPtr self);
		static extern (C) void wxBoxSizer_CalcMin(IntPtr self,out Size size);
		static extern (C) int wxBoxSizer_GetOrientation(IntPtr self);
		static extern (C) void wxBoxSizer_SetOrientation(IntPtr self, int orient);
		//! \endcond

		//---------------------------------------------------------------------

	alias BoxSizer wxBoxSizer;
	public class BoxSizer : Sizer
	{
		public this(IntPtr wxobj)
			{ super(wxobj); }
			
		public this(int orient)
		{ 
			this(wxBoxSizer_ctor(cast(int)orient));
			wxBoxSizer_RegisterVirtual(wxobj, this, &staticRecalcSizes, &staticCalcMin);
			wxBoxSizer_RegisterDisposable(wxobj, &VirtualDispose);
		}
			
		//---------------------------------------------------------------------
		extern(C) private static void staticRecalcSizes(BoxSizer obj) { return obj.RecalcSizes(); }
		extern(C) private static void staticCalcMin(BoxSizer obj,out Size size) { size = obj.CalcMin(); }

		public override void RecalcSizes()
		{
			wxBoxSizer_RecalcSizes(wxobj);
		}
		
		//---------------------------------------------------------------------
		public override Size CalcMin()
		{
			Size size;
			wxBoxSizer_CalcMin(wxobj,size);
			return size;
		}
		
		//---------------------------------------------------------------------
		
		public int Orientation() { return wxBoxSizer_GetOrientation(wxobj); }
		public void Orientation(int value) { wxBoxSizer_SetOrientation(wxobj, value); }
	}
