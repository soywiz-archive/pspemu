// D import file generated from 'src\core\sys\windows\stacktrace.d'
module core.sys.windows.stacktrace;
import core.demangle;
import core.runtime;
import core.stdc.stdlib;
import core.stdc.string;
import core.sys.windows.dbghelp;
import core.sys.windows.windows;
import core.stdc.stdio;
extern (Windows) 
{
    DWORD GetEnvironmentVariableA(LPCSTR lpName, LPSTR pBuffer, DWORD nSize);
    void RtlCaptureContext(CONTEXT* ContextRecord);
    typedef LONG function(void*) UnhandeledExceptionFilterFunc;
    void* SetUnhandledExceptionFilter(void* handler);
}
enum : uint
{
MAX_MODULE_NAME32 = 255,
TH32CS_SNAPMODULE = 8,
MAX_NAMELEN = 1024,
}
extern (Windows) 
{
    typedef HANDLE function(DWORD dwFlags, DWORD th32ProcessID) CreateToolhelp32SnapshotFunc;
    typedef BOOL function(HANDLE hSnapshot, MODULEENTRY32* lpme) Module32FirstFunc;
    typedef BOOL function(HANDLE hSnapshot, MODULEENTRY32* lpme) Module32NextFunc;
}
struct MODULEENTRY32
{
    DWORD dwSize;
    DWORD th32ModuleID;
    DWORD th32ProcessID;
    DWORD GlblcntUsage;
    DWORD ProccntUsage;
    BYTE* modBaseAddr;
    DWORD modBaseSize;
    HMODULE hModule;
    CHAR[MAX_MODULE_NAME32 + 1] szModule;
    CHAR[MAX_PATH] szExePath;
}
private 
{
    string generateSearchPath();
    bool loadModules(HANDLE hProcess, DWORD pid);
    void loadModule(HANDLE hProcess, PCSTR img, PCSTR mod, DWORD64 baseAddr, DWORD size);
    immutable __gshared bool initialized;

}
class StackTrace : Throwable.TraceInfo
{
    public 
{
    this()
{
if (initialized)
m_trace = trace();
}
    int opApply(scope int delegate(ref char[]) dg);
    int opApply(scope int delegate(ref size_t, ref char[]) dg);
    override string toString();

    private 
{
    char[][] m_trace;
    static char[][] trace();

    static char[][] traceNoSync();

    static char[] format(char[] buf, ulong val, uint base = 10);

}
}
}
shared static this();
