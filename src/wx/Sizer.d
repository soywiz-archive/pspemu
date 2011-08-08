//-----------------------------------------------------------------------------
// wxD - Sizer.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Sizer.cs
//
/// The wxSizer wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Sizer.d,v 1.11 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.Sizer;
public import wx.common;
public import wx.Window;

		//! \cond EXTERN
		static extern (C) void wxSizer_AddWindow(IntPtr self, IntPtr window, int proportion, int flag, int border, IntPtr userData);
		static extern (C) void wxSizer_AddSizer(IntPtr self, IntPtr sizer, int proportion, int flag, int border, IntPtr userData);
		static extern (C) void wxSizer_Add(IntPtr self, int width, int height, int proportion, int flag, int border, IntPtr userData);

		static extern (C) void wxSizer_Fit(IntPtr self, IntPtr window, ref Size size);
		static extern (C) void wxSizer_FitInside(IntPtr self, IntPtr window);
		static extern (C) void wxSizer_Layout(IntPtr self);

		static extern (C) void wxSizer_InsertWindow(IntPtr self, int before, IntPtr window, int option, uint flag, int border, IntPtr userData);
		static extern (C) void wxSizer_InsertSizer(IntPtr self, int before, IntPtr sizer, int option, uint flag, int border, IntPtr userData);
		static extern (C) void wxSizer_Insert(IntPtr self, int before, int width, int height, int option, uint flag, int border, IntPtr userData);

		static extern (C) void wxSizer_PrependWindow(IntPtr self, IntPtr window, int option, uint flag, int border, IntPtr userData);
		static extern (C) void wxSizer_PrependSizer(IntPtr self, IntPtr sizer, int option, uint flag, int border, IntPtr userData);
		static extern (C) void wxSizer_Prepend(IntPtr self, int width, int height, int option, uint flag, int border, IntPtr userData);

		static extern (C) bool wxSizer_RemoveWindow(IntPtr self, IntPtr window);
		static extern (C) bool wxSizer_RemoveSizer(IntPtr self, IntPtr sizer);
		static extern (C) bool wxSizer_Remove(IntPtr self, int pos);

		static extern (C) void wxSizer_Clear(IntPtr self, bool delete_windows);
		static extern (C) void wxSizer_DeleteWindows(IntPtr self);

		static extern (C) void wxSizer_SetMinSize(IntPtr self, ref Size size);

		static extern (C) bool wxSizer_SetItemMinSizeWindow(IntPtr self, IntPtr window, ref Size size);
		static extern (C) bool wxSizer_SetItemMinSizeSizer(IntPtr self, IntPtr sizer, ref Size size);
		static extern (C) bool wxSizer_SetItemMinSize(IntPtr self, int pos, ref Size size);

		static extern (C) void wxSizer_GetSize(IntPtr self, out Size size);
		static extern (C) void wxSizer_GetPosition(IntPtr self, out Point pt);
		static extern (C) void wxSizer_GetMinSize(IntPtr self, out Size size);

		static extern (C) void wxSizer_RecalcSizes(IntPtr self);
		static extern (C) void wxSizer_CalcMin(IntPtr self, out Size size);

		static extern (C) void wxSizer_SetSizeHints(IntPtr self, IntPtr window);
		static extern (C) void wxSizer_SetVirtualSizeHints(IntPtr self, IntPtr window);
		static extern (C) void wxSizer_SetDimension(IntPtr self, int x, int y, int width, int height);

		static extern (C) void wxSizer_ShowWindow(IntPtr self, IntPtr window, bool show);
		static extern (C) void wxSizer_HideWindow(IntPtr self, IntPtr window);
		static extern (C) void wxSizer_ShowSizer(IntPtr self, IntPtr sizer, bool show);
		static extern (C) void wxSizer_HideSizer(IntPtr self, IntPtr sizer);

		static extern (C) bool wxSizer_IsShownWindow(IntPtr self, IntPtr window);
		static extern (C) bool wxSizer_IsShownSizer(IntPtr self, IntPtr sizer);
		
		static extern (C) bool wxSizer_DetachWindow(IntPtr self, IntPtr window);
		static extern (C) bool wxSizer_DetachSizer(IntPtr self, IntPtr sizer);
		static extern (C) bool wxSizer_Detach(IntPtr self, int index);
		//! \endcond

		//---------------------------------------------------------------------

	public abstract class Sizer : wxObject
	{
		public this(IntPtr wxobj)
			{ super(wxobj);}

		//---------------------------------------------------------------------

		public void Add(Window window, int proportion=0, int flag=0, int border=0, wxObject userData=null)
		{
			wxSizer_AddWindow(wxobj, wxObject.SafePtr(window), proportion, flag,
							  border, wxObject.SafePtr(userData));
		}

		public void Add(Sizer sizer, int proportion=0, int flag=0, int border=0, wxObject userData=null)
		{
			wxSizer_AddSizer(wxobj, wxObject.SafePtr(sizer), proportion, cast(int)flag,
							 border, wxObject.SafePtr(userData));
		}

		public void Add(int width, int height, int proportion=0, int flag=0, int border=0, wxObject userData=null)
		{
			wxSizer_Add(wxobj, width, height, proportion, cast(int)flag, border,
						wxObject.SafePtr(userData));
		}

		//---------------------------------------------------------------------

		public void AddSpacer(int size)
		{
			Add(size, size, 0);
		}

		public void AddStretchSpacer(int proportion = 1)
		{
			Add(0, 0, proportion);
		}

		//---------------------------------------------------------------------

		public Size Fit(Window window)
		{
			Size size;
			wxSizer_Fit(wxobj, wxObject.SafePtr(window), size);
			return size;
		}

		public void FitInside(Window window)
		{
			wxSizer_FitInside(wxobj, wxObject.SafePtr(window));
		}

		public void Layout()
		{
			wxSizer_Layout(wxobj);
		}

		//---------------------------------------------------------------------

		public void Insert(uint index, Window window, int proportion=0, int flag=0,
						   int border=0, wxObject userData=null)
		{
			wxSizer_InsertWindow(wxobj, index, wxObject.SafePtr(window),
								 proportion, flag, border,
								 wxObject.SafePtr(userData));
		}

		public void Insert(uint index, Sizer sizer, int proportion=0, int flag=0,
						   int border=0, wxObject userData=null)
		{
			wxSizer_InsertSizer(wxobj, index, wxObject.SafePtr(sizer),
								proportion, flag, border,
								wxObject.SafePtr(userData));
		}

		public void Insert(uint index, int width, int height, int proportion=0,
						   int flag=0, int border=0, wxObject userData=null)
		{
			wxSizer_Insert(wxobj, index, width, height, proportion, flag,
						   border, wxObject.SafePtr(userData));
		}

		//---------------------------------------------------------------------

		public void Prepend(Window window, int proportion=0, int flag=0, int border=0,
							wxObject userData=null)
		{
			wxSizer_PrependWindow(wxobj, wxObject.SafePtr(window), proportion,
								flag, border, wxObject.SafePtr(userData));
		}

		public void Prepend(Sizer sizer, int proportion=0, int flag=0, int border=0,
							wxObject userData=null)
		{
			wxSizer_PrependSizer(wxobj, wxObject.SafePtr(sizer), proportion,
								 flag, border, wxObject.SafePtr(userData));
		}

		public void Prepend(int width, int height, int proportion=0, int flag=0,
						    int border=0, wxObject userData=null)
		{
			wxSizer_Prepend(wxobj, width, height, proportion,
							flag, border, wxObject.SafePtr(userData));
		}

		//---------------------------------------------------------------------

		public void PrependSpacer(int size)
		{
			Prepend(size, size, 0);
		}

		public void PrependStretchSpacer(int proportion = 1)
		{
			Prepend(0, 0, proportion);
		}

		//---------------------------------------------------------------------

		public bool Remove(Window window)
		{
			return wxSizer_RemoveWindow(wxobj, wxObject.SafePtr(window));
		}

		public bool Remove(Sizer sizer)
		{
			return wxSizer_RemoveSizer(wxobj, wxObject.SafePtr(sizer));
		}

		public bool Remove(int pos)
		{
			return wxSizer_Remove(wxobj, pos);
		}

		//---------------------------------------------------------------------

		public void SetMinSize(Size size)
		{
			wxSizer_SetMinSize(wxobj, size);
		}

		//---------------------------------------------------------------------

		public bool SetItemMinSize(Window window, Size size)
		{
			return wxSizer_SetItemMinSizeWindow(wxobj, wxObject.SafePtr(window),size);
		}

		public bool SetItemMinSize(Sizer sizer, Size size)
		{
			return wxSizer_SetItemMinSizeSizer(wxobj, wxObject.SafePtr(sizer),size);
		}

		public bool SetItemMinSize(int pos, Size size)
		{
			return wxSizer_SetItemMinSize(wxobj, pos, size);
		}

		//---------------------------------------------------------------------

		public Size size() 
			{
				Size size;
				wxSizer_GetSize(wxobj, size);
				return size;
			}

		public Point Position() 
			{
				Point pt;
				wxSizer_GetPosition(wxobj, pt);
				return pt;
			}

		public Size MinSize() 
			{
				Size size;
				wxSizer_GetMinSize(wxobj, size);
				return size;
			}

		//---------------------------------------------------------------------

		public /+virtual+/ void RecalcSizes()
		{
			wxSizer_RecalcSizes(wxobj);
		}

		//---------------------------------------------------------------------

		public /+virtual+/ Size CalcMin()
		{
			Size size;
			wxSizer_CalcMin(wxobj, size);
			return size;
		}

		//---------------------------------------------------------------------

		public void SetSizeHints(Window window)
		{
			wxSizer_SetSizeHints(wxobj, wxObject.SafePtr(window));
		}

		public void SetVirtualSizeHints(Window window)
		{
			wxSizer_SetVirtualSizeHints(wxobj, wxObject.SafePtr(window));
		}

		public void SetDimension(int x, int y, int width, int height)
		{
			wxSizer_SetDimension(wxobj, x, y, width, height);
		}

		//---------------------------------------------------------------------

		public void Show(Window window, bool show)
		{
			wxSizer_ShowWindow(wxobj, wxObject.SafePtr(window), show);
		}

		public void Show(Sizer sizer, bool show)
		{
			wxSizer_ShowSizer(wxobj, wxObject.SafePtr(sizer), show);
		}

		// New to wx.NET
		public void Show(bool show)
		{
			Show(this, show);
		}


		//---------------------------------------------------------------------

		public void Clear(bool delete_windows)
		{
			wxSizer_Clear(wxobj, delete_windows);
		}

		public void DeleteWindows()
		{
			wxSizer_DeleteWindows(wxobj);
		}

		//---------------------------------------------------------------------

		public void Hide(Window window)
		{
			wxSizer_HideWindow(wxobj, wxObject.SafePtr(window));
		}

		public void Hide(Sizer sizer)
		{
			wxSizer_HideSizer(wxobj, wxObject.SafePtr(sizer));
		}

		//---------------------------------------------------------------------

		public bool IsShown(Window window)
		{
			return wxSizer_IsShownWindow(wxobj, wxObject.SafePtr(window));
		}

		public bool IsShown(Sizer sizer)
		{
			return wxSizer_IsShownSizer(wxobj, wxObject.SafePtr(sizer));
		}

		//---------------------------------------------------------------------
		
		public bool Detach(Window window)
		{
			return wxSizer_DetachWindow(wxobj, wxObject.SafePtr(window));
		}
		
		public bool Detach(Sizer sizer)
		{
			return wxSizer_DetachSizer(wxobj, wxObject.SafePtr(sizer));
		}
		
		public bool Detach(int index)
		{
			return wxSizer_Detach(wxobj, index);
		}
		
		//---------------------------------------------------------------------
	}
