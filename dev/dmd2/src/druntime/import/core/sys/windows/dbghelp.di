// D import file generated from 'src\core\sys\windows\dbghelp.d'
module core.sys.windows.dbghelp;
import core.sys.windows.windows;
alias CHAR TCHAR;
enum : DWORD
{
SYMOPT_FAIL_CRITICAL_ERRORS = 512,
SYMOPT_LOAD_LINES = 16,
}
struct GUID
{
    uint Data1;
    ushort Data2;
    ushort Data3;
    ubyte[8] Data4;
}
enum : DWORD
{
IMAGE_FILE_MACHINE_I386 = 332,
IMGAE_FILE_MACHINE_IA64 = 512,
IMAGE_FILE_MACHINE_AMD64 = 34404,
}
struct IMAGEHLP_LINE64
{
    DWORD SizeOfStruct;
    PVOID Key;
    DWORD LineNumber;
    PTSTR FileName;
    DWORD64 Address;
}
enum SYM_TYPE : int
{
SymNone = 0,
SymCoff,
SymCv,
SymPdb,
SymExport,
SymDeferred,
SymSym,
SymDia,
SymVirtual,
NumSymTypes,
}
struct IMAGEHLP_MODULE64
{
    DWORD SizeOfStruct;
    DWORD64 BaseOfImage;
    DWORD ImageSize;
    DWORD TimeDateStamp;
    DWORD CheckSum;
    DWORD NumSyms;
    SYM_TYPE SymType;
    TCHAR[32] ModuleName;
    TCHAR[256] ImageName;
    TCHAR[256] LoadedImageName;
    TCHAR[256] LoadedPdbName;
    DWORD CVSig;
    TCHAR[MAX_PATH * 3] CVData;
    DWORD PdbSig;
    GUID PdbSig70;
    DWORD PdbAge;
    BOOL PdbUnmatched;
    BOOL DbgUnmachted;
    BOOL LineNumbers;
    BOOL GlobalSymbols;
    BOOL TypeInfo;
    BOOL SourceIndexed;
    BOOL Publics;
}
struct IMAGEHLP_SYMBOL64
{
    DWORD SizeOfStruct;
    DWORD64 Address;
    DWORD Size;
    DWORD Flags;
    DWORD MaxNameLength;
    TCHAR[1] Name;
}
extern (Windows) 
{
    typedef BOOL function(HANDLE hProcess, DWORD64 lpBaseAddress, PVOID lpBuffer, DWORD nSize, LPDWORD lpNumberOfBytesRead) ReadProcessMemoryProc64;
    typedef PVOID function(HANDLE hProcess, DWORD64 AddrBase) FunctionTableAccessProc64;
    typedef DWORD64 function(HANDLE hProcess, DWORD64 Address) GetModuleBaseProc64;
    typedef DWORD64 function(HANDLE hProcess, HANDLE hThread, ADDRESS64* lpaddr) TranslateAddressProc64;
    typedef BOOL function(HANDLE hProcess, PCSTR UserSearchPath, bool fInvadeProcess) SymInitializeFunc;
    typedef BOOL function(HANDLE hProcess) SymCleanupFunc;
    typedef DWORD function(DWORD SymOptions) SymSetOptionsFunc;
    typedef DWORD function() SymGetOptionsFunc;
    typedef PVOID function(HANDLE hProcess, DWORD64 AddrBase) SymFunctionTableAccess64Func;
    typedef BOOL function(DWORD MachineType, HANDLE hProcess, HANDLE hThread, STACKFRAME64* StackFrame, PVOID ContextRecord, ReadProcessMemoryProc64 ReadMemoryRoutine, FunctionTableAccessProc64 FunctoinTableAccess, GetModuleBaseProc64 GetModuleBaseRoutine, TranslateAddressProc64 TranslateAddress) StackWalk64Func;
    typedef BOOL function(HANDLE hProcess, DWORD64 dwAddr, PDWORD pdwDisplacement, IMAGEHLP_LINE64* line) SymGetLineFromAddr64Func;
    typedef DWORD64 function(HANDLE hProcess, DWORD64 dwAddr) SymGetModuleBase64Func;
    typedef BOOL function(HANDLE hProcess, DWORD64 dwAddr, IMAGEHLP_MODULE64* ModuleInfo) SymGetModuleInfo64Func;
    typedef BOOL function(HANDLE hProcess, DWORD64 Address, DWORD64* Displacement, IMAGEHLP_SYMBOL64* Symbol) SymGetSymFromAddr64Func;
    typedef DWORD function(PCTSTR DecoratedName, PTSTR UnDecoratedName, DWORD UndecoratedLength, DWORD Flags) UnDecorateSymbolNameFunc;
    typedef DWORD64 function(HANDLE hProcess, HANDLE hFile, PCSTR ImageName, PCSTR ModuleName, DWORD64 BaseOfDll, DWORD SizeOfDll) SymLoadModule64Func;
    typedef BOOL function(HANDLE HProcess, PTSTR SearchPath, DWORD SearchPathLength) SymGetSearchPathFunc;
    typedef BOOL function(HANDLE hProcess, DWORD64 Address) SymUnloadModule64Func;
}
struct DbgHelp
{
    SymInitializeFunc SymInitialize;
    SymCleanupFunc SymCleanup;
    StackWalk64Func StackWalk64;
    SymGetOptionsFunc SymGetOptions;
    SymSetOptionsFunc SymSetOptions;
    SymFunctionTableAccess64Func SymFunctionTableAccess64;
    SymGetLineFromAddr64Func SymGetLineFromAddr64;
    SymGetModuleBase64Func SymGetModuleBase64;
    SymGetModuleInfo64Func SymGetModuleInfo64;
    SymGetSymFromAddr64Func SymGetSymFromAddr64;
    UnDecorateSymbolNameFunc UnDecorateSymbolName;
    SymLoadModule64Func SymLoadModule64;
    SymGetSearchPathFunc SymGetSearchPath;
    SymUnloadModule64Func SymUnloadModule64;
    static DbgHelp* get();

        private 
{
    __gshared DbgHelp sm_inst;

    __gshared HANDLE sm_hndl;

}
}
