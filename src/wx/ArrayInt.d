/// The wxArrayInt wrapper class
module wx.ArrayInt;
public import wx.common;

		//! \cond EXTERN
		static extern (C) IntPtr wxArrayInt_ctor();
		static extern (C) void   wxArrayInt_dtor(IntPtr self);
		static extern (C) void   wxArrayInt_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
		static extern (C) void   wxArrayInt_Add(IntPtr self, int toadd);
		static extern (C) int    wxArrayInt_Item(IntPtr self, int num);
		static extern (C) int    wxArrayInt_GetCount(IntPtr self);
		//! \endcond
		
	alias ArrayInt wxArrayInt;
	public class ArrayInt : wxObject
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
			this(wxArrayInt_ctor(), true);
			wxArrayInt_RegisterDisposable(wxobj, &VirtualDispose);
		}
		
		//---------------------------------------------------------------------

		public int[] toArray()
		{
			int count = this.Count;
			int[] tmpi = new int[count];
			for (int i = 0; i < count; i++)
				tmpi[i] = this.Item(i);
			return tmpi;
		}

		public void Add(int toadd)
		{
			wxArrayInt_Add(wxobj, toadd);
		}

		public int Item(int num)
		{
			return wxArrayInt_Item(wxobj, num);
		}

		public int Count() { return wxArrayInt_GetCount(wxobj); }
                
		//---------------------------------------------------------------------

		override protected void dtor() { wxArrayInt_dtor(wxobj); }
	}
	
