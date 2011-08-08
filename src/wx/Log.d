//-----------------------------------------------------------------------------
// wxD - Log.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - Log.cs
//
/// The wxLog wrapper classes.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2003 Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: Log.d,v 1.14 2010/10/11 09:41:07 afb Exp $
//-----------------------------------------------------------------------------

module wx.Log;
public import wx.common;
public import wx.TextCtrl;

//! \cond STD
version (Tango)
{
import tango.core.Vararg;
import tango.text.convert.Format;
}
else // Phobos
{
private import std.format;
private import std.stdarg;
}
//! \endcond

		//! \cond EXTERN
		static extern (C) IntPtr wxLog_ctor();
		static extern (C) bool wxLog_IsEnabled();
		static extern (C) void wxLog_FlushActive();
		static extern (C) IntPtr wxLog_SetActiveTargetTextCtrl(IntPtr pLogger);
		static extern (C) void wxLog_Log_Function(int what, string szFormat);
		static extern (C) void wxLog_AddTraceMask(string tmask);
		//! \endcond
		
	alias Log wxLog;
	public class Log : wxObject
	{
		enum eLogLevel : int
		{
			xLOG,
			xFATALERROR,
			xERROR,
			xWARNING,
			xINFO,
			xVERBOSE,
			xSTATUS,
			xSYSERROR
		}
		
		public this(IntPtr wxobj)
		    { super(wxobj);}

		public this()
		    { super(wxLog_ctor());}


		static bool IsEnabled() { return wxLog_IsEnabled(); }

		public static void FlushActive()
		{
			wxLog_FlushActive();
		}

		// at the moment only TextCtrl
		public static void SetActiveTarget(TextCtrl pLogger)
		{
			wxLog_SetActiveTargetTextCtrl(wxObject.SafePtr(pLogger));
		}

		public static void AddTraceMask(string tmask)
		{
			wxLog_AddTraceMask(tmask);
		}

		public static void LogMessage(...)
		{
			wxLog_Log_Function(cast(int)eLogLevel.xLOG, stringFormat(_arguments,_argptr));
		}

		public static void LogFatalError(...)
		{
			wxLog_Log_Function(cast(int)eLogLevel.xFATALERROR, stringFormat(_arguments,_argptr));
		}

		public static void LogError(...)
		{
			wxLog_Log_Function(cast(int)eLogLevel.xERROR, stringFormat(_arguments,_argptr));
		}

		public static void LogWarning(...)
		{
			wxLog_Log_Function(cast(int)eLogLevel.xWARNING, stringFormat(_arguments,_argptr));
		}

		public static void LogInfo(...)
		{
			wxLog_Log_Function(cast(int)eLogLevel.xINFO, stringFormat(_arguments,_argptr));
		}

		public static void LogVerbose(...)
		{
			wxLog_Log_Function(cast(int)eLogLevel.xVERBOSE, stringFormat(_arguments,_argptr));
		}

		public static void LogStatus(...)
		{
			wxLog_Log_Function(cast(int)eLogLevel.xSTATUS, stringFormat(_arguments,_argptr));
		}

		public static void LogSysError(...)
		{
			wxLog_Log_Function(cast(int)eLogLevel.xSYSERROR, stringFormat(_arguments,_argptr));
		}

		private static string stringFormat(TypeInfo[] arguments, va_list argptr)
		{
			char[] s;

		version (Tango)
		{
			char[] fmts = "";
			for(int i=0; i < arguments.length; i++) {
				fmts ~= "{}";
			}
			s = Format.convert(arguments, argptr, fmts);
		}
		else // Phobos
		{
			void putc(dchar c)
			{
				std.utf.encode(s, c);
			}

			std.format.doFormat(&putc, arguments, argptr);
		}

			return cast(string) s;
		}

//! \cond VERSION
version (none) {
/* C# compatible */
private static string stringFormat(char[] str,va_list argptr,TypeInfo[] arguments)
{
	if (arguments.length==0) return str;

	string[] args = new string[arguments.length];

	for(uint i=0;i<arguments.length;i++) {
		TypeInfo id = arguments[i];
		char[] value;
		if (id == typeid(int)) {
			value = .toString(*cast(int*)argptr);
			argptr += int.sizeof;
		}
		else if (id == typeid(long)) {
			value = .toString(*cast(long*)argptr);
			argptr += long.sizeof;
		}
		else if (id == typeid(float)) {
			value = .toString(*cast(long*)argptr);
			argptr += long.sizeof;
		}
		else if (id == typeid(double)) {
			value = .toString(*cast(long*)argptr);
			argptr += long.sizeof;
		}
		else if (id == typeid(string)) {
			value = *cast(string*)argptr;
			argptr += string.sizeof;
		}
		args[i] = value;
	}

	string ret;
	while(1) {
		int start,end;
		start = find(str,'{');
		if (start<0) break;

		ret ~= str[0..start];
		str = str[start+1..str.length];

		end = find(str,'}');
		assert(end>0);
		int idx = atoi(str[0..end]);
		assert(idx<args.length);
		
		ret ~= args[idx];
		str = str[end+1..str.length];
	}
	ret ~= str;

	return ret;
}

}
//! \endcond
	}

