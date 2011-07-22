// D import file generated from 'src\core\exception.d'
module core.exception;
import core.stdc.stdio;
private 
{
    alias void function(string file, size_t line, string msg = null) errorHandlerType;
    __gshared errorHandlerType assertHandler = null;

}
class RangeError : Error
{
    this(string file = __FILE__, size_t line = __LINE__, Throwable next = null)
{
super("Range violation",file,line,next);
}
}
class AssertError : Error
{
    this(string file, size_t line)
{
this(cast(Throwable)null,file,line);
}
    this(Throwable next, string file = __FILE__, size_t line = __LINE__)
{
this("Assertion failure",file,line,next);
}
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
{
super(msg,file,line,next);
}
}
class FinalizeError : Error
{
    ClassInfo info;
    this(ClassInfo ci, Throwable next, string file = __FILE__, size_t line = __LINE__)
{
this(ci,file,line,next);
}
    this(ClassInfo ci, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
{
super("Finalization error",file,line,next);
info = ci;
}
    override string toString()
{
return "An exception was thrown while finalizing an instance of class " ~ info.name;
}

}
class HiddenFuncError : Error
{
    this(ClassInfo ci)
{
super("Hidden method called for " ~ ci.name);
}
}
class OutOfMemoryError : Error
{
    this(string file = __FILE__, size_t line = __LINE__, Throwable next = null)
{
super("Memory allocation failed",file,line,next);
}
    override string toString()
{
return msg ? super.toString() : "Memory allocation failed";
}

}
class SwitchError : Error
{
    this(string file = __FILE__, size_t line = __LINE__, Throwable next = null)
{
super("No appropriate switch clause found",file,line,next);
}
}
class UnicodeException : Exception
{
    size_t idx;
    this(string msg, size_t idx, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
{
super(msg,file,line,next);
this.idx = idx;
}
}
deprecated void setAssertHandler(errorHandlerType h)
{
assertHandler = h;
}

extern (C) void onAssertError(string file = __FILE__, size_t line = __LINE__);

extern (C) void onAssertErrorMsg(string file, size_t line, string msg);

extern (C) void onUnittestErrorMsg(string file, size_t line, string msg)
{
onAssertErrorMsg(file,line,msg);
}

extern (C) void onRangeError(string file = __FILE__, size_t line = __LINE__);

extern (C) void onFinalizeError(ClassInfo info, Exception e, string file = __FILE__, size_t line = __LINE__);

extern (C) void onHiddenFuncError(Object o);

extern (C) void onOutOfMemoryError();

extern (C) void onSwitchError(string file = __FILE__, size_t line = __LINE__);

extern (C) void onUnicodeError(string msg, size_t idx, string file = __FILE__, size_t line = __LINE__);

