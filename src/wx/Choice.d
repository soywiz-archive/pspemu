//-----------------------------------------------------------------------------
// wxD - Choice.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - Choice.cs
//
/// The wxChoice wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Choice.d,v 1.13 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.Choice;
public import wx.common;
public import wx.Control;
public import wx.ClientData;
public import wx.IControlWithItems;
public import wx.ArrayString;

		//! \cond EXTERN
		static extern (C) IntPtr wxChoice_ctor();
		static extern (C) bool   wxChoice_Create(IntPtr self, IntPtr parent, int id, ref Point pos, ref Size size, int n, string* choices, int style, IntPtr validator, string name);
		static extern (C) void   wxChoice_dtor(IntPtr self);

		static extern (C) void   wxChoice_SetSelection(IntPtr self, int n);
		static extern (C) bool   wxChoice_SetStringSelection(IntPtr self, string s);
		static extern (C) IntPtr wxChoice_GetStringSelection(IntPtr self);

		static extern (C) void   wxChoice_SetColumns(IntPtr self, int n);
		static extern (C) int    wxChoice_GetColumns(IntPtr self);

		static extern (C) void   wxChoice_Command(IntPtr self, IntPtr evt);
		static extern (C) int    wxChoice_GetCount(IntPtr self);
		static extern (C) IntPtr wxChoice_GetString(IntPtr self, int n);
		static extern (C) int    wxChoice_GetSelection(IntPtr self);

		static extern (C) IntPtr wxChoice_GetClientData(IntPtr self, int n);
		static extern (C) void   wxChoice_SetClientData(IntPtr self, int n, IntPtr data);

		static extern (C) int    wxChoice_FindString(IntPtr self, string str);
		
		static extern (C) void   wxChoice_Delete(IntPtr self, int n);
		static extern (C) void   wxChoice_Clear(IntPtr self);

		static extern (C) int   wxChoice_Append(IntPtr self, string item);
		static extern (C) int   wxChoice_AppendData(IntPtr self, string item, IntPtr data);
		
		static extern (C)	void wxChoice_AppendString(IntPtr self, string item);
		
		static extern (C)	void wxChoice_AppendArrayString(IntPtr self, int n, string* strings);
		
		static extern (C)	int wxChoice_Insert(IntPtr self, string item, int pos);
		static extern (C)	int wxChoice_InsertClientData(IntPtr self, string item, int pos, IntPtr clientData);
		
		static extern (C)	IntPtr wxChoice_GetStrings(IntPtr self);
		
		static extern (C)	void wxChoice_SetClientObject(IntPtr self, int n, IntPtr clientData);
		static extern (C)	IntPtr wxChoice_GetClientObject(IntPtr self, int n);
		static extern (C)	bool wxChoice_HasClientObjectData(IntPtr self);
		static extern (C)	bool wxChoice_HasClientUntypedData(IntPtr self);
		
		static extern (C) void wxChoice_SetString(IntPtr self, int n, string text);
		
		static extern (C) void wxChoice_Select(IntPtr self, int n);
		
		static extern (C)	bool wxChoice_ShouldInheritColours(IntPtr self);
		
		static extern (C)	bool wxChoice_IsEmpty(IntPtr self);
		//! \endcond

		//---------------------------------------------------------------------
		
	alias Choice wxChoice;
	public class Choice : Control , IControlWithItems
	{
		public const string wxChoiceNameStr = "choice";
	
		public this(IntPtr wxobj) 
			{ super(wxobj);}

		public this()
			{ super(wxChoice_ctor()); }

		public this(Window parent, int id, Point pos, Size size, string[] choices = null, int style = 0, Validator val = null,string name = wxChoiceNameStr)
		{
			super(wxChoice_ctor());
			if(!wxChoice_Create(wxobj, wxObject.SafePtr(parent), id, pos,
								size, choices.length, choices.ptr, style, 
								wxObject.SafePtr(validator), name)) 
			{
				throw new InvalidOperationException("Failed to create ListBox");
			}
		}
		
		public static wxObject New(IntPtr wxobj)
		{
			return new Choice(wxobj);
		}
	
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent, Point pos, Size size, string[] choices = null, int style = 0, Validator val = null,string name = wxChoiceNameStr)
			{ this(parent, Window.UniqueID, pos, size, choices, style, validator, name);}
		
		//---------------------------------------------------------------------

		public bool Create(Window parent, int id, ref Point pos, ref Size size,
						   string[] choices, int style, Validator validator,
						   string name)
		{
			return wxChoice_Create(wxobj, wxObject.SafePtr(parent), id,
								   pos, size, choices.length, choices.ptr, 
								   cast(uint)style, wxObject.SafePtr(validator), name);
		}
		
		//-----------------------------------------------------------------------------
		
		public int Append(string item)
		{
			return wxChoice_Append(wxobj, item);
		}
		
		public int Append(string item, ClientData clientData)
		{
			return wxChoice_AppendData(wxobj, item, wxObject.SafePtr(clientData));
		}
		
		//-----------------------------------------------------------------------------
		
		public void AppendString(string item)
		{
			wxChoice_AppendString(wxobj, item);
		}
		
		//-----------------------------------------------------------------------------
		
		public void Append(string[] strings)
		{
			wxChoice_AppendArrayString(wxobj, strings.length, strings.ptr);
		}
		
		//-----------------------------------------------------------------------------
		
		public int Insert(string item, int pos)
		{
			return wxChoice_Insert(wxobj, item, pos);
		}
		
		public int Insert(string item, int pos, ClientData clientData)
		{
			return wxChoice_InsertClientData(wxobj, item, pos, wxObject.SafePtr(clientData));
		}
		
		//-----------------------------------------------------------------------------
		
		public string[] GetStrings()
		{
			return (new ArrayString(wxChoice_GetStrings(wxobj), true)).toArray();
		}
		
		//-----------------------------------------------------------------------------
		
		public void SetClientObject(int n, ClientData clientData)
		{
			wxChoice_SetClientObject(wxobj, n, wxObject.SafePtr(clientData));
		}
		
		public ClientData GetClientObject(int n)
		{
			return cast(ClientData)FindObject(wxChoice_GetClientObject(wxobj, n), &ClientData.New);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool HasClientObjectData()
		{
			return wxChoice_HasClientObjectData(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool HasClientUntypedData()
		{
			return wxChoice_HasClientUntypedData(wxobj);
		}

		//---------------------------------------------------------------------
		
		public int Selection() { return wxChoice_GetSelection(wxobj); }
		public void Selection(int value) { wxChoice_SetSelection(wxobj, value); }
		
		public int GetSelection()
		{
			return wxChoice_GetSelection(wxobj);
		}

		//---------------------------------------------------------------------

		public string StringSelection() { return cast(string) new wxString(wxChoice_GetStringSelection(wxobj), true); }
		public void StringSelection(string value) { wxChoice_SetStringSelection(wxobj, value); }

		//---------------------------------------------------------------------

		public int Columns() { return wxChoice_GetColumns(wxobj); }
		public void Columns(int value) { wxChoice_SetColumns(wxobj, value); }
		
		//---------------------------------------------------------------------

		public void Command(Event evt)
		{
			wxChoice_Command(wxobj, wxObject.SafePtr(evt));
		}

		//---------------------------------------------------------------------
		
		public int Count() { return wxChoice_GetCount(wxobj); }
		
		//---------------------------------------------------------------------

		public string GetString(int n)
		{
			return cast(string) new wxString(wxChoice_GetString(wxobj, n), true);
		}

		//---------------------------------------------------------------------

		// TODO: Find way to pass data through C# object
		
		public ClientData GetClientData(int n)
		{
			return cast(ClientData)FindObject(wxChoice_GetClientData(wxobj, n));
		}

		public void SetClientData(int n, ClientData data)
		{
			wxChoice_SetClientData(wxobj, n, wxObject.SafePtr(data));
		}

		//---------------------------------------------------------------------

		public int FindString(string str)
		{
			return wxChoice_FindString(wxobj, str);
		}

		//---------------------------------------------------------------------

		public void Delete(int n)
		{
			wxChoice_Delete(wxobj, n);
		}
		
		//---------------------------------------------------------------------

		public void Clear()
		{
			wxChoice_Clear(wxobj);
		}

		//---------------------------------------------------------------------

		public void SetString(int n, string str)
		{
			wxChoice_SetString(wxobj, n, str);
		}
		
		//---------------------------------------------------------------------
		
		public void Select(int n)
		{
			wxChoice_Select(wxobj, n);
		}
		
		//-----------------------------------------------------------------------------
		
		public override bool ShouldInheritColours()
		{
			return wxChoice_ShouldInheritColours(wxobj);
		}
		
		//-----------------------------------------------------------------------------
		
		public bool Empty() { return wxChoice_IsEmpty(wxobj); }

		//---------------------------------------------------------------------

		public void Selected_Add(EventListener value) { AddCommandListener(Event.wxEVT_COMMAND_CHOICE_SELECTED, ID, value, this); }
		public void Selected_Remove(EventListener value) { RemoveHandler(value, this); }

	}
