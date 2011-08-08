//-----------------------------------------------------------------------------
// wxD - XmlResource.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - XmlResource.cs
//
/// The wxXmlResource wrapper class.
//
// Written by Achim Breunig (achim.breunig@web.de)
// (C) 2003 Achim Breunig
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: XmlResource.d,v 1.11 2009/03/13 08:42:11 afb Exp $
//-----------------------------------------------------------------------------

module wx.XmlResource;
public import wx.common;
public import wx.Dialog;

public import wx.Window;

public import wx.Frame;

public import wx.Menu;

public import wx.MenuBar;

public import wx.Panel;

public import wx.ToolBar;

//! \cond STD
version (Tango)
{
}
else // Phobos
{
private import std.stream;
private import std.regexp;
}
//! \endcond

	public enum XmlResourceFlags : int
	{
		XRC_USE_LOCALE     = 1,
		XRC_NO_SUBCLASSING = 2
	};

		//! \cond EXTERN
		static extern (C) void wxXmlResource_InitAllHandlers(IntPtr self);
		static extern (C) bool wxXmlResource_Load(IntPtr self, string filemask);
		static extern (C) bool wxXmlResource_LoadFromByteArray(IntPtr self, string filemask, IntPtr data, int length);
		static extern (C) IntPtr wxXmlResource_LoadDialog(IntPtr self, IntPtr parent, string name);
		static extern (C) bool wxXmlResource_LoadDialogDlg(IntPtr self, IntPtr dlg, IntPtr parent, string name);
		static extern (C) int wxXmlResource_GetXRCID(string str_id);
		static extern (C) IntPtr wxXmlResource_ctorByFilemask(string filemask, int flags);
		static extern (C) IntPtr wxXmlResource_ctor(int flags);
		static extern (C) uint wxXmlResource_GetVersion(IntPtr self);
		static extern (C) bool wxXmlResource_LoadFrameWithFrame(IntPtr self, IntPtr frame, IntPtr parent, string name);
		static extern (C) IntPtr wxXmlResource_LoadFrame(IntPtr self, IntPtr parent, string name);
		static extern (C) IntPtr wxXmlResource_LoadBitmap(IntPtr self, string name);
		static extern (C) IntPtr wxXmlResource_LoadIcon(IntPtr self, string name);
		static extern (C) IntPtr wxXmlResource_LoadMenu(IntPtr self, string name);
		static extern (C) IntPtr wxXmlResource_LoadMenuBarWithParent(IntPtr self, IntPtr parent, string name);
		static extern (C) IntPtr wxXmlResource_LoadMenuBar(IntPtr self, string name);
		static extern (C) bool wxXmlResource_LoadPanelWithPanel(IntPtr self, IntPtr panel, IntPtr parent, string name);
		static extern (C) IntPtr wxXmlResource_LoadPanel(IntPtr self, IntPtr parent, string name);
		static extern (C) IntPtr wxXmlResource_LoadToolBar(IntPtr self, IntPtr parent, string name);
		static extern (C) int wxXmlResource_SetFlags(IntPtr self, int flags);
		static extern (C) int wxXmlResource_GetFlags(IntPtr self);
		static extern (C) void wxXmlResource_UpdateResources(IntPtr self);
		static extern (C) int wxXmlResource_CompareVersion(IntPtr self, int major, int minor, int release, int revision);
		static extern (C) bool wxXmlResource_AttachUnknownControl(IntPtr self, string name, IntPtr control, IntPtr parent);

		//---------------------------------------------------------------------

		extern (C) {
		alias IntPtr function(string className) XmlSubclassCreate;
		}

		static extern (C) bool wxXmlSubclassFactory_ctor(XmlSubclassCreate create);
		//! \endcond

	alias XmlResource wxXmlResource;
	public class XmlResource : wxObject
	{
		public static XmlResource globalXmlResource = null;
	
		//---------------------------------------------------------------------
    
		static this()
		{
			m_create = cast(XmlSubclassCreate)&XmlSubclassCreateCS;
			wxXmlSubclassFactory_ctor(m_create);
		}
		private static void SetSubclassDefaults() {}

/+
		// Sets the default assembly/namespace based on the assembly from
		// which this method is called (i.e. your assembly!).
		//
		// Determines these by walking a stack trace. Normally 
		// Assembly.GetCallingAssembly should work but in my tests it 
		// returned the current assembly in the static constructor above.
		private static void SetSubclassDefaults()
		{
			string my_assembly = Assembly.GetExecutingAssembly().GetName().Name;
			StackTrace st = new StackTrace();
			
			for (int i = 0; i < st.FrameCount; ++i)
			{
				Type type = st.GetFrame(i).GetMethod().ReflectedType;
				string st_assembly = type.Assembly.GetName().Name;
				if (st_assembly != my_assembly)
				{
					_CallerNamespace = type.Namespace;
					_CallerAssembly = st_assembly;
					stdout.writeLine("Setting sub-class default assembly to {0}, namespace to {1}", _CallerAssembly, _CallerNamespace);
					break;
				}
			}
		}

		// Get/set the assembly used for sub-classing. If this is not set, the
		// assembly of the class that invokes one of the LoadXXX() methods
		// will be used. This property is only used if an assembly is not
		// specified in the XRC XML subclass property via the [assembly]class
		// syntax.
		static void SubclassAssembly(string value) { _SubclassAssembly = value; }
		static string SubclassAssembly() { return _SubclassAssembly; }
		static string _SubclassAssembly;

		// Get/set the namespace that is pre-pended to class names in sub-classing.
		// This is only used if class name does not have a dot (.) in it. If
		// this is not specified and the class does not already have a namespace
		// specified, the namespace of the class which invoked the LoadXXX() method
		// is used.
		static void SubclassNamespace(string value) { _SubclassNamespace = value; }
		static string SubclassNamespace() { return _SubclassNamespace; }
		static string _SubclassNamespace;

		// Defaults set via LoadXXX() methods
		private static string _CallerAssembly;
		private static string _CallerNamespace;
+/

		//---------------------------------------------------------------------

		public this()
			{ this(XmlResourceFlags.XRC_USE_LOCALE);}

		public this(IntPtr wxobj)
			{ super(wxobj); }
 
		public this(XmlResourceFlags flags)
			{ this(wxXmlResource_ctor(cast(int)flags)); }

		public this(string filemask, XmlResourceFlags flags)
			{ this(wxXmlResource_ctorByFilemask(filemask,cast(int)flags)); }
	    
		//---------------------------------------------------------------------
	
		public static XmlResource Get()
		{
			if (globalXmlResource is null)
			{
				globalXmlResource = new XmlResource();
			}
		
			return globalXmlResource;
		}
	
		//---------------------------------------------------------------------	
	
		public static XmlResource Set(XmlResource res)
		{ 
			XmlResource old = globalXmlResource;
			globalXmlResource = res;
			return old; 
		}
	
		//---------------------------------------------------------------------

		public void InitAllHandlers()
		{
			wxXmlResource_InitAllHandlers(wxobj);
		}
	
		//---------------------------------------------------------------------

		public bool Load(string filemask)
		{
			return wxXmlResource_Load(wxobj,filemask);
		}
	
		//---------------------------------------------------------------------

		public Dialog LoadDialog(Window parent, string name)
		{
			SetSubclassDefaults();
			IntPtr ptr = wxXmlResource_LoadDialog(wxobj,wxObject.SafePtr(parent),name);
			if (ptr != IntPtr.init)
				return new Dialog(ptr);
			else
				return null;
		}
	
		//---------------------------------------------------------------------
        
		public bool LoadDialog(Dialog dlg, Window parent, string name)
		{
			SetSubclassDefaults();
			return wxXmlResource_LoadDialogDlg(wxobj,wxObject.SafePtr(dlg),wxObject.SafePtr(parent),name);
		}
	
		//---------------------------------------------------------------------

		public static int GetXRCID(string str_id)
		{
			return wxXmlResource_GetXRCID(str_id);
		}
	
		//---------------------------------------------------------------------
	
		public static int XRCID(string str_id)
		{
			return wxXmlResource_GetXRCID(str_id);
		}
	
		//---------------------------------------------------------------------

		public int Version() { return wxXmlResource_GetVersion(wxobj); }
	
		//---------------------------------------------------------------------

		public bool LoadFrame(Frame frame, Window parent, string name)
		{
			SetSubclassDefaults();
			return wxXmlResource_LoadFrameWithFrame(wxobj, wxObject.SafePtr(frame), wxObject.SafePtr(parent), name);
		}
	
		//---------------------------------------------------------------------

		public Frame LoadFrame(Window parent, string name)
		{
			SetSubclassDefaults();
			IntPtr ptr = wxXmlResource_LoadFrame(wxobj,wxObject.SafePtr(parent),name);
			if (ptr != IntPtr.init)
				return new Frame(ptr);
			else
				return null;
		}
	
		//---------------------------------------------------------------------

		public Menu LoadMenu(string name)
		{
			SetSubclassDefaults();
			IntPtr ptr = wxXmlResource_LoadMenu(wxobj, name);
			if (ptr != IntPtr.init)
				return new Menu(ptr);
			else
				return null;
		}
	
		//---------------------------------------------------------------------

		public MenuBar LoadMenuBar(Window parent, string name)
		{
			SetSubclassDefaults();
			IntPtr ptr = wxXmlResource_LoadMenuBarWithParent(wxobj, wxObject.SafePtr(parent), name);
			if (ptr != IntPtr.init)
				return new MenuBar(ptr);
			else
				return null;
		}
	
		//---------------------------------------------------------------------

		public MenuBar LoadMenuBar(string name)
		{
			SetSubclassDefaults();
			IntPtr ptr = wxXmlResource_LoadMenuBar(wxobj, name);
			if (ptr != IntPtr.init)
				return new MenuBar(ptr);
			else
				return null;
		}
	
		//---------------------------------------------------------------------

		public bool LoadPanel(Panel panel, Window parent, string name)
		{
			SetSubclassDefaults();
			return wxXmlResource_LoadPanelWithPanel(wxobj, wxObject.SafePtr(panel), wxObject.SafePtr(parent), name);
		}
	
		//---------------------------------------------------------------------

		public Panel LoadPanel(Window parent, string name)
		{
			SetSubclassDefaults();
			IntPtr ptr = wxXmlResource_LoadPanel(wxobj, wxObject.SafePtr(parent), name);
			if (ptr != IntPtr.init)
				return new Panel(ptr);
			else
				return null;
		}
	
		//---------------------------------------------------------------------

		public ToolBar LoadToolBar(Window parent, string name)
		{
			SetSubclassDefaults();
			IntPtr ptr = wxXmlResource_LoadToolBar(wxobj, wxObject.SafePtr(parent), name);
			if (ptr != IntPtr.init)
				return new ToolBar(ptr);
			else
				return null;
		}
	
		//---------------------------------------------------------------------

		public void Flags(XmlResourceFlags value) { wxXmlResource_SetFlags(wxobj, cast(int)value); }
		public XmlResourceFlags Flags() { return cast(XmlResourceFlags)wxXmlResource_GetFlags(wxobj); }
	
		//---------------------------------------------------------------------
	/+
		public void UpdateResources()
		{
			wxXmlResource_UpdateResources(wxobj);
		}
	+/
		//---------------------------------------------------------------------
	
		public Bitmap LoadBitmap(string name)
		{
			return new Bitmap(wxXmlResource_LoadBitmap(wxobj, name));
		}
	
		//---------------------------------------------------------------------
	
		public Icon LoadIcon(string name)
		{
			return new Icon(wxXmlResource_LoadIcon(wxobj, name));
		}
	
		//---------------------------------------------------------------------
	
		public int CompareVersion(int major, int minor, int release, int revision)
		{
			return wxXmlResource_CompareVersion(wxobj, major, minor, release, revision);
		}
	
		//---------------------------------------------------------------------
	
		public bool AttachUnknownControl(string name, Window control)
		{
			return AttachUnknownControl(name, control, null);
		}
	
		public bool AttachUnknownControl(string name, Window control, Window parent)
		{
			return wxXmlResource_AttachUnknownControl(wxobj, name, wxObject.SafePtr(control), wxObject.SafePtr(parent));
		}
	
		//---------------------------------------------------------------------
 
		public static wxObject XRCCTRL(Window window, string id, newfunc func)
		{
			return window.FindWindow(XRCID(id), func);
		}

        public static wxObject GetControl(Window window, string id, newfunc func)
        { 
            return XRCCTRL(window, id, func); 
        }
		//---------------------------------------------------------------------
		// XmlResource control subclassing
        
		private static XmlSubclassCreate m_create; // = cast(XmlSubclassCreate)&XmlSubclassCreateCS;
		//private static IntPtr function(string className) m_create = &XmlSubclassCreateCS;

		extern(C) private static IntPtr XmlSubclassCreateCS(string className)
		{
/+
			string name = className;
			string assembly = null;
			// Allow these two formats for for class names:
			//   class
			//   [assembly]class (specify assembly)

			Match m = Regex.Match(name, "\\[(.+)\\]");
			if (m.Success)
			{
				assembly = m.Result("$1");
				name = m.Result("$'");
			}
			else
			{
				assembly = _SubclassAssembly;
			}

			// Use caller's assembly?
			if ((assembly == null) || (assembly == ""))
				assembly = _CallerAssembly;

			// Tack on any namespace prefix to the class? Only if the 
			// class does not already have a "." in it
			if (name.IndexOf(".") == -1)
			{
				string ns = "";
				// Use caller's namespace?
				if ((_SubclassNamespace == null) || (_SubclassNamespace == ""))
					ns = _CallerNamespace;
				else
					ns = _SubclassNamespace;
				name = ns + "." + name;
			}

			try 
			{
				stdout.writeLine("Attempting to create " ~ name ~ " from assembly " ~ assembly);
			//	ObjectHandle handle = Activator.CreateInstance(assembly, name);

				if (handle === null) 
				{
					return IntPtr.init;
				}

				wxObject o = cast(wxObject)handle.Unwrap();
				return o.wxobj;
			} 
			catch (Exception e) 
			{
				stdout.writeLine(e);

				return IntPtr.init;
			}
+/
			return IntPtr.init;
		}

	}
