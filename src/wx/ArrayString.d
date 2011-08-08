/// The wxArrayString wrapper class
module wx.ArrayString;
public import wx.common;

		//! \cond EXTERN
		static extern (C) IntPtr wxArrayString_ctor();
		static extern (C) void   wxArrayString_dtor(IntPtr self);
		static extern (C) void   wxArrayString_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) void   wxArrayString_Add(IntPtr self, string toadd);
		static extern (C) IntPtr wxArrayString_Item(IntPtr self, int num);
		static extern (C) int    wxArrayString_GetCount(IntPtr self);
		//! \endcond
		
	alias ArrayString wxArrayString;
	public class ArrayString : wxObject
	{
		//---------------------------------------------------------------------

		public this(IntPtr wxobj)
		{
			super(wxobj);
		}
			
		public this(IntPtr wxobj, bool memOwn)
		{
			super(wxobj);
			this.memOwn = memOwn;
		}

		public this()
		{
			this(wxArrayString_ctor(), true);
			wxArrayString_RegisterDisposable(wxobj, &VirtualDispose);
		}
		
		//---------------------------------------------------------------------

		public string[] toArray()
		{
			int count = this.Count;
			string[] tmps = new string[count];
			for (int i = 0; i < count; i++)
				tmps[i] = this.Item(i);
			return tmps;
		}
	
		public string Item(int num)
		{
			return cast(string) new wxString(wxArrayString_Item(wxobj, num), true);
		}	
	
		public void Add(string toadd)
		{
			wxArrayString_Add(wxobj, toadd);
		}

		public int Count() { return wxArrayString_GetCount(wxobj); }
        
		//---------------------------------------------------------------------

		override protected void dtor() { wxArrayString_dtor(wxobj); }
	}
	
