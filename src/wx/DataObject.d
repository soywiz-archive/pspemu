//-----------------------------------------------------------------------------
// wxD - DataObject.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Dataobj.cs
//
/// The wxDataObject wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 by Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: DataObject.d,v 1.10 2007/01/28 23:06:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.DataObject;
public import wx.common;
public import wx.ArrayString;

	public abstract class DataObject : wxObject
	{
		public enum DataDirection
		{
			Get = 0x01,
			Set = 0x02,
			Both = 0x03
		}
		
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
		
		//---------------------------------------------------------------------
				
		override protected void dtor() {  }
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxDataObjectSimple_ctor(IntPtr format);
		static extern (C) void wxDataObjectSimple_dtor(IntPtr self);
		static extern (C) void wxDataObjectSimple_SetFormat(IntPtr self, IntPtr format);
		static extern (C) uint wxDataObjectSimple_GetDataSize(IntPtr self);
		static extern (C) bool wxDataObjectSimple_GetDataHere(IntPtr self, IntPtr buf);
		static extern (C) bool wxDataObjectSimple_SetData(IntPtr self, uint len, IntPtr buf);
		//! \endcond
		
		//---------------------------------------------------------------------

	alias DataObjectSimple wxDataObjectSimple;
	public class DataObjectSimple : DataObject
	{
		public this(IntPtr wxobj)
		{
			super(wxobj);
		}
		
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}
		
		//---------------------------------------------------------------------
				
		override protected void dtor() { wxDataObjectSimple_dtor(wxobj); }
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxTextDataObject_ctor(string text);
		static extern (C) void wxTextDataObject_dtor(IntPtr self);
		static extern (C) void wxTextDataObject_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) int wxTextDataObject_GetTextLength(IntPtr self);
		static extern (C) IntPtr wxTextDataObject_GetText(IntPtr self);
		static extern (C) void wxTextDataObject_SetText(IntPtr self, string text);
		//! \endcond
		
		//---------------------------------------------------------------------

	alias TextDataObject wxTextDataObject;
	public class TextDataObject : DataObjectSimple
	{
		public this(IntPtr wxobj)
		{
			super(wxobj);
		}
			
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}

		public this()
			{ this("");}

		public this(string text)
		{
			this(wxTextDataObject_ctor(text), true);
			wxTextDataObject_RegisterDisposable(wxobj, &VirtualDispose);
		}
			
		//---------------------------------------------------------------------
				
		override protected void dtor() { wxTextDataObject_dtor(wxobj); }
			
		//---------------------------------------------------------------------

		public int TextLength() { return wxTextDataObject_GetTextLength(wxobj); }
		
		//---------------------------------------------------------------------

		public string Text() { return cast(string) new wxString(wxTextDataObject_GetText(wxobj), true); }
		public void Text(string value) { wxTextDataObject_SetText(wxobj, value); }
	}
	
	//---------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxFileDataObject_ctor();
		static extern (C) void wxFileDataObject_dtor(IntPtr self);
		static extern (C) void wxFileDataObject_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) void wxFileDataObject_AddFile(IntPtr self, string filename);
		static extern (C) IntPtr wxFileDataObject_GetFilenames(IntPtr self);
		//! \endcond
		
		//---------------------------------------------------------------------
		
	alias FileDataObject wxFileDataObject;
	public class FileDataObject : DataObjectSimple
	{
		public this(IntPtr wxobj)
		{
			super(wxobj);
		}
			
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}
			
		public this()
		{
			this(wxFileDataObject_ctor(), true);
			wxFileDataObject_RegisterDisposable(wxobj, &VirtualDispose);
		}
		
		//---------------------------------------------------------------------
		
		override protected void dtor() { wxFileDataObject_dtor(wxobj); }
			
		//---------------------------------------------------------------------
			
		public void AddFile(string filename)
		{
			wxFileDataObject_AddFile(wxobj, filename);
		}
		
		public string[] Filenames()
		{
			ArrayString a=new ArrayString(wxFileDataObject_GetFilenames(wxobj), true);
			string[] res;
			res.length=a.Count;
			for(uint i=0; i<a.Count; ++i)
				res[i]=a.Item(i);
			
			return res;
		}
	
	}
