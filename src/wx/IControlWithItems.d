//-----------------------------------------------------------------------------
// wxD - IControlWithItems.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - IControlWithItems.cs
//
/// The ControlWithItems Interface.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: IControlWithItems.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.IControlWithItems;
public import wx.ClientData;

	public interface IControlWithItems 
	{
		int Append(string item);
		
		int Append(string item, ClientData clientData);
		
		//-----------------------------------------------------------------------------
		
		void AppendString(string item);
		
		//-----------------------------------------------------------------------------
		
		void Append(string[] strings);
		
		//-----------------------------------------------------------------------------
		
		int Insert(string item, int pos);
		
		int Insert(string item, int pos, ClientData clientData);
		
		//-----------------------------------------------------------------------------
		
		void Clear();
		
		//-----------------------------------------------------------------------------
		
		void Delete(int n);
		
		//-----------------------------------------------------------------------------
		
		int Count();
		
		//-----------------------------------------------------------------------------
		
		bool Empty();
		
		//-----------------------------------------------------------------------------
		
		string GetString(int n);
		
		//-----------------------------------------------------------------------------
		
		string[] GetStrings();
		
		//-----------------------------------------------------------------------------
		
		void SetString(int n, string s);
		
		//-----------------------------------------------------------------------------
		
		int FindString(string s);
		
		//-----------------------------------------------------------------------------
		
		void Select(int n);
		
		int GetSelection();
		
		//-----------------------------------------------------------------------------
		
		string StringSelection();
		
		//-----------------------------------------------------------------------------
		
		void SetClientObject(int n, ClientData clientData);
		
		ClientData GetClientObject(int n);
		
		//-----------------------------------------------------------------------------
		
		bool HasClientObjectData();
		
		//-----------------------------------------------------------------------------
		
		bool HasClientUntypedData();
		
		//-----------------------------------------------------------------------------
		
		bool ShouldInheritColours();
	}

