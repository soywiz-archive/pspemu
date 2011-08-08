//-----------------------------------------------------------------------------
// wxD - Config.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Config.cs
//
/// The wxConfig wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Config.d,v 1.14 2010/10/11 09:41:07 afb Exp $
//-----------------------------------------------------------------------------

module wx.Config;
public import wx.common;
public import wx.Font;
public import wx.Colour;
public import wx.wxString;

    public enum EntryType 
    {
        Unknown,
        String,
        Boolean,
        Integer,
        Float
    }
    
    // Style flags for constructor style parameter
    public enum ConfigStyleFlags
    {
    	wxCONFIG_USE_LOCAL_FILE = 1,
    	wxCONFIG_USE_GLOBAL_FILE = 2,
    	wxCONFIG_USE_RELATIVE_PATH = 4,
    	wxCONFIG_USE_NO_ESCAPE_CHARACTERS = 8
    }


		//! \cond EXTERN
        static extern (C) IntPtr wxConfigBase_Set(IntPtr pConfig);
        static extern (C) IntPtr wxConfigBase_Get(bool createOnDemand);
        static extern (C) IntPtr wxConfigBase_Create();
        static extern (C) void   wxConfigBase_DontCreateOnDemand();
        static extern (C) void   wxConfigBase_SetPath(IntPtr self, string strPath);
        static extern (C) IntPtr wxConfigBase_GetPath(IntPtr self);
        static extern (C) bool   wxConfigBase_GetFirstGroup(IntPtr self, IntPtr str, ref int lIndex);
        static extern (C) bool   wxConfigBase_GetNextGroup(IntPtr self, IntPtr str, ref int lIndex);
        static extern (C) bool   wxConfigBase_GetFirstEntry(IntPtr self, IntPtr str, ref int lIndex);
        static extern (C) bool   wxConfigBase_GetNextEntry(IntPtr self, IntPtr str, ref int lIndex);
        static extern (C) int    wxConfigBase_GetNumberOfEntries(IntPtr self, bool bRecursive);
        static extern (C) int    wxConfigBase_GetNumberOfGroups(IntPtr self, bool bRecursive);
        static extern (C) bool   wxConfigBase_HasGroup(IntPtr self, string strName);
        static extern (C) bool   wxConfigBase_HasEntry(IntPtr self, string strName);
        static extern (C) bool   wxConfigBase_Exists(IntPtr self, string strName);
        static extern (C) int    wxConfigBase_GetEntryType(IntPtr self, string name);
        static extern (C) bool   wxConfigBase_ReadStr(IntPtr self, string key, IntPtr pStr);
        static extern (C) bool   wxConfigBase_ReadStrDef(IntPtr self, string key, IntPtr pStr, string defVal);
        static extern (C) bool   wxConfigBase_ReadInt(IntPtr self, string key, ref int pl);
        static extern (C) bool   wxConfigBase_ReadIntDef(IntPtr self, string key, ref int pl, int defVal);
        static extern (C) bool   wxConfigBase_ReadDbl(IntPtr self, string key, ref double val);
        static extern (C) bool   wxConfigBase_ReadDblDef(IntPtr self, string key, ref double val, double defVal);
        static extern (C) bool   wxConfigBase_ReadBool(IntPtr self, string key, ref bool val);
        static extern (C) bool   wxConfigBase_ReadBoolDef(IntPtr self, string key, ref bool val, bool defVal);
        static extern (C) IntPtr wxConfigBase_ReadStrRet(IntPtr self, string key, string defVal);
        static extern (C) int    wxConfigBase_ReadIntRet(IntPtr self, string key, int defVal);
        static extern (C) bool   wxConfigBase_WriteStr(IntPtr self, string key, string val);
        static extern (C) bool   wxConfigBase_WriteInt(IntPtr self, string key, int val);
        static extern (C) bool   wxConfigBase_WriteDbl(IntPtr self, string key, double val);
        static extern (C) bool   wxConfigBase_WriteBool(IntPtr self, string key, bool val);
        static extern (C) bool   wxConfigBase_Flush(IntPtr self, bool bCurrentOnly);
        static extern (C) bool   wxConfigBase_RenameEntry(IntPtr self, string oldName, string newName);
        static extern (C) bool   wxConfigBase_RenameGroup(IntPtr self, string oldName, string newName);
        static extern (C) bool   wxConfigBase_DeleteEntry(IntPtr self, string key, bool bDeleteGroupIfEmpty);
        static extern (C) bool   wxConfigBase_DeleteGroup(IntPtr self, string key);
        static extern (C) bool   wxConfigBase_DeleteAll(IntPtr self);
        static extern (C) bool   wxConfigBase_IsExpandingEnvVars(IntPtr self);
        static extern (C) void   wxConfigBase_SetExpandEnvVars(IntPtr self, bool bDoIt);
        static extern (C) IntPtr wxConfigBase_ExpandEnvVars(IntPtr self, string str);
        static extern (C) void   wxConfigBase_SetRecordDefaults(IntPtr self, bool bDoIt);
        static extern (C) bool   wxConfigBase_IsRecordingDefaults(IntPtr self);
        static extern (C) IntPtr wxConfigBase_GetAppName(IntPtr self);
        static extern (C) void   wxConfigBase_SetAppName(IntPtr self, string appName);
        static extern (C) IntPtr wxConfigBase_GetVendorName(IntPtr self);
        static extern (C) void   wxConfigBase_SetVendorName(IntPtr self, string vendorName);
        static extern (C) void   wxConfigBase_SetStyle(IntPtr self, int style);
        static extern (C) int    wxConfigBase_GetStyle(IntPtr self);
		//! \endcond

		//---------------------------------------------------------------------

    // although it wxConfig is not derived from wxobj we do not change it.
    // Use Config.Get() to get an instance.
    alias Config wxConfig;
    public class Config : wxObject
    {
        public this(IntPtr wxobj)
            { super(wxobj); }
	
	public static wxObject New(IntPtr ptr) { return new Config(ptr); }
	
        public static Config Set(Config config)
        {
            return cast(Config)FindObject(wxConfigBase_Set(wxObject.SafePtr(config)), &Config.New);
        }

        public static Config Get(bool createOnDemand)
        {
            return cast(Config)FindObject(wxConfigBase_Get(createOnDemand), &Config.New);
        }
	
	public static Config Get()
        {
            return cast(Config)FindObject(wxConfigBase_Get(true), &Config.New);
        }

        public static Config Create()
        {
            return new Config(wxConfigBase_Create());
        }

		//---------------------------------------------------------------------

        public void DontCreateOnDemand()
        {
            wxConfigBase_DontCreateOnDemand();
        }

		//---------------------------------------------------------------------

        public void Path(string value) { wxConfigBase_SetPath(wxobj, value); }
        public string Path() { return cast(string) new wxString(wxConfigBase_GetPath(wxobj), true); }

		//---------------------------------------------------------------------

        public bool GetFirstGroup(ref string str, ref int lIndex)
        {
            bool ret;
            wxString wstr = new wxString(str);

            ret = wxConfigBase_GetFirstGroup(wxobj, wxString.SafePtr(wstr), lIndex);
            str = wstr.toString();

            return ret;
        }

        public bool GetNextGroup(ref string str, ref int lIndex)
        {
            bool ret;
            wxString wstr = new wxString(str);

            ret = wxConfigBase_GetNextGroup(wxobj, wxString.SafePtr(wstr), lIndex);
            str = wstr.toString();

            return ret;
        }

		//---------------------------------------------------------------------

        public bool GetFirstEntry(ref string str, ref int lIndex)
        {
            bool ret;
            wxString wstr = new wxString(str);

            ret = wxConfigBase_GetFirstEntry(wxobj, wxString.SafePtr(wstr), lIndex);
            str = wstr.toString();

            return ret;
        }

        public bool GetNextEntry(ref string str, ref int lIndex)
        {
            bool ret;
            wxString wstr = new wxString(str);

            ret = wxConfigBase_GetNextEntry(wxobj, wxString.SafePtr(wstr), lIndex);
            str = wstr.toString();

            return ret;
        }

		//---------------------------------------------------------------------

        public int GetNumberOfEntries(bool bRecursive)
        {
            return wxConfigBase_GetNumberOfEntries(wxobj, bRecursive);
        }

        public int GetNumberOfGroups(bool bRecursive)
        {
            return wxConfigBase_GetNumberOfGroups(wxobj, bRecursive);
        }

		//---------------------------------------------------------------------

        public bool HasGroup(string strName)
        {
            return wxConfigBase_HasGroup(wxobj, strName);
        }

        public bool HasEntry(string strName)
        {
            return wxConfigBase_HasEntry(wxobj, strName);
        }

		//---------------------------------------------------------------------

        public bool Exists(string strName)
        {
            return wxConfigBase_Exists(wxobj, strName);
        }

        public EntryType GetEntryType(string name)
        {
            return cast(EntryType)wxConfigBase_GetEntryType(wxobj, name);
        }

		//---------------------------------------------------------------------

        public bool Read(string key, ref string str)
        {
            bool ret;
            wxString wstr = new wxString(str);

            ret = wxConfigBase_ReadStr(wxobj, key, wxString.SafePtr(wstr));
            str = wstr.toString();

            return ret;
        }

        public bool Read(string key, ref string str, string defVal)
        {
            bool ret;
            wxString wstr = new wxString(str);

            ret = wxConfigBase_ReadStrDef(wxobj, key, wxString.SafePtr(wstr), defVal);
            str = wstr.toString();

            return ret;
        }

		//---------------------------------------------------------------------

        public bool Read(string key, ref int pl)
        {
            return wxConfigBase_ReadInt(wxobj, key, pl);
        }

        public bool Read(string key, ref int pl, int defVal)
        {
            return wxConfigBase_ReadIntDef(wxobj, key, pl, defVal);
        }

		//---------------------------------------------------------------------

        public bool Read(string key, ref double val)
        {
            return wxConfigBase_ReadDbl(wxobj, key, val);
        }

        public bool Read(string key, ref double val, double defVal)
        {
            return wxConfigBase_ReadDblDef(wxobj, key, val, defVal);
        }

		//---------------------------------------------------------------------

        public bool Read(string key, ref bool val)
        {
            return wxConfigBase_ReadBool(wxobj, key, val);
        }

        public bool Read(string key, ref bool val, bool defVal)
        {
            return wxConfigBase_ReadBoolDef(wxobj, key, val, defVal);
        }

		//---------------------------------------------------------------------

        public bool Read(string key, ref Font val)
        {
            return Read(key, val, Font.wxNORMAL_FONT);
        }

        public bool Read(string key, ref Font val, Font defVal)
        {
            bool ret = true;

            int pointSize = 0, family = 0, style = 0, weight = 0, encoding = 0;
            bool underline = false;
            string faceName = "";

            ret &= Read(key ~ "/PointSize", pointSize,  cast(int)defVal.PointSize);
            ret &= Read(key ~ "/Family",    family,     cast(int)defVal.Family);
            ret &= Read(key ~ "/Style",     style,      cast(int)defVal.Style);
            ret &= Read(key ~ "/Weight",    weight,     cast(int)defVal.Weight);
            ret &= Read(key ~ "/Underline", underline,  cast(bool)defVal.Underlined);
            ret &= Read(key ~ "/FaceName",  faceName,   defVal.FaceName);
            ret &= Read(key ~ "/Encoding",  encoding,   cast(int)defVal.Encoding);

            val.PointSize   = pointSize;
            val.Family      = cast(FontFamily)family;
            val.Style       = cast(FontStyle)style;
            val.Weight      = cast(FontWeight)weight;
            val.Underlined  = underline;
            val.FaceName    = faceName;
            val.Encoding    = cast(FontEncoding)encoding;

            return ret;
        }

		//---------------------------------------------------------------------

        public bool Read(string key, ref Colour val)
        {
            Colour def = new Colour(0, 0, 0);
            return Read(key, val, def);
        }

	private static int hex2int(string str)
	{
		int value = 0;
		foreach(char foo; str) {
			char ch = foo;
			if (ch>='0' && ch<='9') ch-='0';
			else if (ch>='A' && ch<='F') ch=cast(char)(ch-'A'+10);
			else if (ch>='a' && ch<='f') ch=cast(char)(ch-'a'+10);
			else return -1;
			value = value*10 + ch;
		}
		return value;
	}

        public bool Read(string key, ref Colour val, Colour defVal)
        {
            string str;
            bool ret = Read(key,str);
            if (!ret || !str || str[0]!='#') {
            //    val = defval;
            } else {
                uint c = hex2int(str[1..str.length]);

                int r = (c>>16)&255;
                int g = (c>>8)&255;
                int b = c&255;

                val = new Colour(cast(ubyte)r, cast(ubyte)g, cast(ubyte)b);
            }
            return ret;
/*
            bool ret = true;
            int r = 0, b = 0, g = 0;

            ret &= Read(key ~ "/Red",   r, cast(int)defVal.Red);
            ret &= Read(key ~ "/Blue",  b, cast(int)defVal.Blue);
            ret &= Read(key ~ "/Green", g, cast(int)defVal.Green);

            val = new Colour(cast(ubyte)r, cast(ubyte)g, cast(ubyte)b);

            return ret;
*/
        }

		//---------------------------------------------------------------------
/+
        public string Read(string key, string defVal)
        {
            return cast(string) new wxString(wxConfigBase_ReadStrRet(wxobj, key, defVal), true);
        }
+/
        public int Read(string key, int defVal)
        {
            return wxConfigBase_ReadIntRet(wxobj, key, defVal);
        }

        public bool Read(string key, bool defVal) {
            bool val = false;
            Read(key, val, defVal);
            return val;
        }

        public Colour Read(string key, Colour defVal)
        {
            Colour col = new Colour();
            Read(key, col, defVal);
            return col;
        }

        public Font Read(string key, Font defVal)
        {
            Font fnt = new Font();
            Read(key, fnt, defVal);
            return fnt;
        }

		//---------------------------------------------------------------------

        public bool Write(string key, string val)
        {
            return wxConfigBase_WriteStr(wxobj, key, val);
        }

        public bool Write(string key, int val)
        {
            return wxConfigBase_WriteInt(wxobj, key, val);
        }

        public bool Write(string key, double val)
        {
            return wxConfigBase_WriteDbl(wxobj, key, val);
        }

        public bool Write(string key, bool val)
        {
            return wxConfigBase_WriteBool(wxobj, key, val);
        }

	private static void tohex(char* s,uint value)
	{
		const static char[16] hexdigits = "0123456789ABCDEF";
		s[0] = hexdigits[value>>4];
		s[1] = hexdigits[value&15];
	}
	
        public bool Write(string key, Colour col)
        {
/*
            bool ret = true;
            ret &= Write(key ~ "/Red",   cast(int)col.Red);
            ret &= Write(key ~ "/Blue",  cast(int)col.Blue);
            ret &= Write(key ~ "/Green", cast(int)col.Green);
            return ret;
*/
	    char[] buf = new char[7];
	    buf[0] = '#';
	    tohex(&buf[1],col.Red);
	    tohex(&buf[3],col.Green);
	    tohex(&buf[5],col.Blue);
	    return Write(key, cast(string) buf);
        }

        public bool Write(string key, Font val)
        {
            bool ret = true;

            ret &= Write(key ~ "/PointSize", cast(int)val.PointSize);
            ret &= Write(key ~ "/Family",    cast(int)val.Family);
            ret &= Write(key ~ "/Style",     cast(int)val.Style);
            ret &= Write(key ~ "/Weight",    cast(int)val.Weight);
            ret &= Write(key ~ "/Underline", cast(bool)val.Underlined);
            ret &= Write(key ~ "/FaceName",  val.FaceName);
            ret &= Write(key ~ "/Encoding",  cast(int)val.Encoding);

            return ret;
        }

		//---------------------------------------------------------------------

        public bool Flush(bool bCurrentOnly)
        {
            return wxConfigBase_Flush(wxobj, bCurrentOnly);
        }

		//---------------------------------------------------------------------

        public bool RenameEntry(string oldName, string newName)
        {
            return wxConfigBase_RenameEntry(wxobj, oldName, newName);
        }

        public bool RenameGroup(string oldName, string newName)
        {
            return wxConfigBase_RenameGroup(wxobj, oldName, newName);
        }

		//---------------------------------------------------------------------

        public bool DeleteEntry(string key, bool bDeleteGroupIfEmpty)
        {
            return wxConfigBase_DeleteEntry(wxobj, key, bDeleteGroupIfEmpty);
        }

        public bool DeleteGroup(string key)
        {
            return wxConfigBase_DeleteGroup(wxobj, key);
        }

        public bool DeleteAll()
        {
            return wxConfigBase_DeleteAll(wxobj);
        }

		//---------------------------------------------------------------------

        public bool ExpandEnvVars() { return wxConfigBase_IsExpandingEnvVars(wxobj); }
        public void ExpandEnvVars(bool value) { wxConfigBase_SetExpandEnvVars(wxobj, value); }

        /*public string ExpandEnvVars(string str)
        {
            return cast(string) new wxString(wxConfigBase_ExpandEnvVars(wxobj, str));
        }*/

		//---------------------------------------------------------------------

        public void RecordDefaults(bool value) { wxConfigBase_SetRecordDefaults(wxobj, value); }
        public bool RecordDefaults() { return wxConfigBase_IsRecordingDefaults(wxobj); }

		//---------------------------------------------------------------------

        public string AppName() { return cast(string) new wxString(wxConfigBase_GetAppName(wxobj), true); }
        public void AppName(string value) { wxConfigBase_SetAppName(wxobj, value); }

		//---------------------------------------------------------------------

        public string VendorName() { return cast(string) new wxString(wxConfigBase_GetVendorName(wxobj), true); }
        public void VendorName(string value) { wxConfigBase_SetVendorName(wxobj, value); }

		//---------------------------------------------------------------------

        public void Style(int value) { wxConfigBase_SetStyle(wxobj, value); }
        public int Style() { return wxConfigBase_GetStyle(wxobj); }

		//---------------------------------------------------------------------
    }

