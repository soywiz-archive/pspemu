//-----------------------------------------------------------------------------
// wxD - NotebookSizer.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - NotebookSizer.cs
//
/// The wxNotebookSizer proxy interface.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: NotebookSizer.d,v 1.10 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.NotebookSizer;
public import wx.common;
public import wx.Sizer;
public import wx.Notebook;

		//! \cond EXTERN
		static extern (C) IntPtr wxNotebookSizer_ctor(IntPtr nb);
		static extern (C) void wxNotebookSizer_RecalcSizes(IntPtr self);
		static extern (C) void wxNotebookSizer_CalcMin(IntPtr self, ref Size size);
		static extern (C) IntPtr wxNotebookSizer_GetNotebook(IntPtr self);
		//! \endcond

		//---------------------------------------------------------------------

	alias NotebookSizer wxNotebookSizer;
	/*deprecated*/ public class NotebookSizer : Sizer
	{
		public this(IntPtr wxobj)
		{
			super(wxobj);
		}

		public this(Notebook nb)
		{
			super(wxNotebookSizer_ctor(wxObject.SafePtr(nb)));
		}

		//---------------------------------------------------------------------

		public override void RecalcSizes()
		{
			wxNotebookSizer_RecalcSizes(wxobj);
		}

		//---------------------------------------------------------------------

		public override Size CalcMin()
		{
			Size size;
			wxNotebookSizer_CalcMin(wxobj, size);
			return size;
		}

		//---------------------------------------------------------------------

		public Notebook notebook() 
			{
				return cast(Notebook)FindObject(
                                    wxNotebookSizer_GetNotebook(wxobj)
                                );
			}

		//---------------------------------------------------------------------
	}
