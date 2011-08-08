//-----------------------------------------------------------------------------
// wxD - ComboBox.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - ComboBox.cs
//
/// The wxComboBox wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: ComboBox.d,v 1.13 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.ComboBox;
public import wx.common;
public import wx.Control;
public import wx.ClientData;

		
		//! \cond EXTERN
		static extern (C) IntPtr wxComboBox_ctor();
		static extern (C) bool   wxComboBox_Create(IntPtr self, IntPtr window, int id, string value, ref Point pos, ref Size size, int n, string* choices, uint style, IntPtr validator, string name);
		
		static extern (C) void   wxComboBox_Append(IntPtr self, string item);
		static extern (C) void   wxComboBox_AppendData(IntPtr self, string item, IntPtr data);
		
		static extern (C) void   wxComboBox_Clear(IntPtr self);
		static extern (C) void   wxComboBox_Delete(IntPtr self, int n);
		
		static extern (C) int    wxComboBox_FindString(IntPtr self, string str);
		
		static extern (C) int    wxComboBox_GetCount(IntPtr self);
		static extern (C) int    wxComboBox_GetSelection(IntPtr self);
		static extern (C) IntPtr wxComboBox_GetString(IntPtr self, int n);
		//static extern (C) void   wxComboBox_SetString(IntPtr self, int n, string text);
		
		static extern (C) IntPtr wxComboBox_GetValue(IntPtr self);
		static extern (C) void   wxComboBox_SetValue(IntPtr self, string text);
		
		static extern (C) IntPtr wxComboBox_GetStringSelection(IntPtr self);
		static extern (C) void   wxComboBox_SetStringSelection(IntPtr self, string value);
		
		static extern (C) IntPtr wxComboBox_GetClientData(IntPtr self, int n);
		static extern (C) void   wxComboBox_SetClientData(IntPtr self, int n, IntPtr data);
		
		static extern (C) void   wxComboBox_Copy(IntPtr self);
		static extern (C) void   wxComboBox_Cut(IntPtr self);
		static extern (C) void   wxComboBox_Paste(IntPtr self);
		
		static extern (C) void   wxComboBox_SetInsertionPoint(IntPtr self, uint pos);
		static extern (C) uint   wxComboBox_GetInsertionPoint(IntPtr self);
		static extern (C) void   wxComboBox_SetInsertionPointEnd(IntPtr self);
		static extern (C) uint   wxComboBox_GetLastPosition(IntPtr self);
		
		static extern (C) void   wxComboBox_Replace(IntPtr self, uint from, uint to, string value);
		static extern (C) void   wxComboBox_SetSelectionSingle(IntPtr self, int n);
		static extern (C) void   wxComboBox_SetSelectionMult(IntPtr self, uint from, uint to);
		static extern (C) void   wxComboBox_SetEditable(IntPtr self, bool editable);
		static extern (C) void   wxComboBox_Remove(IntPtr self, uint from, uint to);
		
		static extern (C) void wxComboBox_SetSelection(IntPtr self, int n);
		
		static extern (C) void wxComboBox_Select(IntPtr self, int n);
		//! \endcond
		
		//---------------------------------------------------------------------
	
	alias ComboBox wxComboBox;
	public class ComboBox : Control
	{
		public const int wxCB_SIMPLE           = 0x0004;
		public const int wxCB_SORT             = 0x0008;
		public const int wxCB_READONLY         = 0x0010;
		public const int wxCB_DROPDOWN         = 0x0020;
		
		public const string wxComboBoxNameStr = "comboBox";
		//---------------------------------------------------------------------

		public this(IntPtr wxobj) 
			{ super(wxobj); }

		public this()
			{ super(wxComboBox_ctor()); }

		public this(Window parent, int id, string value="", Point pos = wxDefaultPosition, Size size = wxDefaultSize, string[] choices = null, int style = 0, Validator val = null, string name = wxComboBoxNameStr)
		{
			super(wxComboBox_ctor());
			if(!wxComboBox_Create(wxobj, wxObject.SafePtr(parent), id, 
						value, pos, size, 
						choices.length, choices.ptr, cast(uint)style, 
						wxObject.SafePtr(validator), name)) 
			{
				throw new InvalidOperationException("Failed to create ListBox");
			}
		}
		
		public static wxObject New(IntPtr wxobj) { return new ComboBox(wxobj); }
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent)
			{ this(parent, Window.UniqueID, "", wxDefaultPosition, wxDefaultSize, cast(string[])null, 0, null, null); }

		public this(Window parent, string value="", Point pos = wxDefaultPosition, Size size = wxDefaultSize, string[] choices = null, int style = 0, Validator val = null, string name = wxComboBoxNameStr)
			{ this(parent, Window.UniqueID, value, pos, size, choices, style, validator, name);}
		
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, string value, 
				Point pos, Size size,
				string[] choices, int style, Validator validator,
				string name)
		{
			return wxComboBox_Create(wxobj, wxObject.SafePtr(parent), id,
					value, pos, size, 
					choices.length, choices.ptr, 
					cast(uint)style, wxObject.SafePtr(validator), name);
		}

		//---------------------------------------------------------------------
        
		public int Selection() { return wxComboBox_GetSelection(wxobj); }
		public void Selection(int value) { wxComboBox_SetSelectionSingle(wxobj, value); }

		//---------------------------------------------------------------------

		public string StringSelection() { return cast(string) new wxString(wxComboBox_GetStringSelection(wxobj), true); }
		public void StringSelection(string value) { wxComboBox_SetStringSelection(wxobj, value); }

		//---------------------------------------------------------------------
        
		public int Count() { return wxComboBox_GetCount(wxobj); }
		
		//---------------------------------------------------------------------

		public string GetString(int n)
		{
			return cast(string) new wxString(wxComboBox_GetString(wxobj, n), true);
		}

		//---------------------------------------------------------------------

		public ClientData GetClientData(int n)
		{
			return cast(ClientData)FindObject(wxComboBox_GetClientData(wxobj, n));
		}

		public void SetClientData(int n, ClientData data)
		{
			wxComboBox_SetClientData(wxobj, n, wxObject.SafePtr(data));
		}

		//---------------------------------------------------------------------

		public int FindString(string str)
		{
			return wxComboBox_FindString(wxobj, str);
		}

		//---------------------------------------------------------------------

		public void Delete(int n)
		{
			wxComboBox_Delete(wxobj, n);
		}

		public void Clear()
		{
			wxComboBox_Clear(wxobj);
		}

		//---------------------------------------------------------------------

		public void Append(string item)
		{
			wxComboBox_Append(wxobj, item);
		}

		public void Append(string item, ClientData data)
		{
			wxComboBox_AppendData(wxobj, item, wxObject.SafePtr(data));
		}

		//---------------------------------------------------------------------

		public void Copy()
		{
			wxComboBox_Copy(wxobj);
		}
		
		//---------------------------------------------------------------------

		public void Cut()
		{
			wxComboBox_Cut(wxobj);
		}
		
		//---------------------------------------------------------------------

		public void Paste()
		{
			wxComboBox_Paste(wxobj);
		}

		//---------------------------------------------------------------------
        
		public int InsertionPoint() { return wxComboBox_GetInsertionPoint(wxobj); }
		public void InsertionPoint(int value) { wxComboBox_SetInsertionPoint(wxobj, cast(uint)value); }
		
		//---------------------------------------------------------------------

		public void SetInsertionPointEnd()
		{
			wxComboBox_SetInsertionPointEnd(wxobj);
		}
		
		//---------------------------------------------------------------------

		public int GetLastPosition()
		{
			return wxComboBox_GetLastPosition(wxobj);
		}

		//---------------------------------------------------------------------

		public void Replace(int from, int to, string value)
		{
			wxComboBox_Replace(wxobj, cast(uint)from, cast(uint)to, value);
		}

		//---------------------------------------------------------------------

		public void SetSelection(int from, int to)
		{
			wxComboBox_SetSelectionMult(wxobj, cast(uint)from, cast(uint)to);
		}
		
		public void SetSelection(int n)
		{
			wxComboBox_SetSelection(wxobj, n);
		}

		//---------------------------------------------------------------------

		public void Editable(bool value) { wxComboBox_SetEditable(wxobj, value); }

		//---------------------------------------------------------------------
        
		public void Remove(int from, int to)
		{
			wxComboBox_Remove(wxobj, cast(uint)from, cast(uint)to);
		}

		//---------------------------------------------------------------------
        
		public string Value() { return cast(string) new wxString(wxComboBox_GetValue(wxobj), true); }
		public void Value(string value) { wxComboBox_SetValue(wxobj, value); }
		
		public void Select(int n)
		{
			wxComboBox_Select(wxobj, n);
		}

		//---------------------------------------------------------------------

		public void Selected_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_COMBOBOX_SELECTED, ID, value, this); }
		public void Selected_Remove(EventListener value) { RemoveHandler(value, this); }
	}

