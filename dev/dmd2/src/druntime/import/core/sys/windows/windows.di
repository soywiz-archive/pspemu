// D import file generated from 'src\core\sys\windows\windows.d'
module core.sys.windows.windows;
extern (Windows) 
{
    alias uint ULONG;
    alias ULONG* PULONG;
    alias ushort USHORT;
    alias USHORT* PUSHORT;
    alias ubyte UCHAR;
    alias UCHAR* PUCHAR;
    alias char* PSZ;
    alias wchar WCHAR;
    alias void VOID;
    alias char CHAR;
    alias short SHORT;
    alias int LONG;
    alias CHAR* LPSTR;
    alias CHAR* PSTR;
    alias const(CHAR)* LPCSTR;
    alias const(CHAR)* PCSTR;
    alias LPSTR LPTCH;
    alias LPSTR PTCH;
    alias LPSTR PTSTR;
    alias LPSTR LPTSTR;
    alias LPCSTR PCTSTR;
    alias LPCSTR LPCTSTR;
    alias WCHAR* LPWSTR;
    alias const(WCHAR)* LPCWSTR;
    alias const(WCHAR)* PCWSTR;
    alias uint DWORD;
    alias ulong DWORD64;
    alias int BOOL;
    alias ubyte BYTE;
    alias ushort WORD;
    alias float FLOAT;
    alias FLOAT* PFLOAT;
    alias BOOL* PBOOL;
    alias BOOL* LPBOOL;
    alias BYTE* PBYTE;
    alias BYTE* LPBYTE;
    alias int* PINT;
    alias int* LPINT;
    alias WORD* PWORD;
    alias WORD* LPWORD;
    alias int* LPLONG;
    alias DWORD* PDWORD;
    alias DWORD* LPDWORD;
    alias void* LPVOID;
    alias void* LPCVOID;
    alias int INT;
    alias uint UINT;
    alias uint* PUINT;
    version (Win64)
{
    alias long INT_PTR;
    alias ulong UINT_PTR;
    alias long LONG_PTR;
    alias ulong ULONG_PTR;
    alias long* PINT_PTR;
    alias ulong* PUINT_PTR;
    alias long* PLONG_PTR;
    alias ulong* PULONG_PTR;
}
else
{
    alias int INT_PTR;
    alias uint UINT_PTR;
    alias int LONG_PTR;
    alias uint ULONG_PTR;
    alias int* PINT_PTR;
    alias uint* PUINT_PTR;
    alias int* PLONG_PTR;
    alias uint* PULONG_PTR;
}
    typedef void* HANDLE;
    alias void* PVOID;
    alias HANDLE HGLOBAL;
    alias HANDLE HLOCAL;
    alias LONG HRESULT;
    alias LONG SCODE;
    alias HANDLE HINSTANCE;
    alias HINSTANCE HMODULE;
    alias HANDLE HWND;
    alias HANDLE HGDIOBJ;
    alias HANDLE HACCEL;
    alias HANDLE HBITMAP;
    alias HANDLE HBRUSH;
    alias HANDLE HCOLORSPACE;
    alias HANDLE HDC;
    alias HANDLE HGLRC;
    alias HANDLE HDESK;
    alias HANDLE HENHMETAFILE;
    alias HANDLE HFONT;
    alias HANDLE HICON;
    alias HANDLE HMENU;
    alias HANDLE HMETAFILE;
    alias HANDLE HPALETTE;
    alias HANDLE HPEN;
    alias HANDLE HRGN;
    alias HANDLE HRSRC;
    alias HANDLE HSTR;
    alias HANDLE HTASK;
    alias HANDLE HWINSTA;
    alias HANDLE HKL;
    alias HICON HCURSOR;
    alias HANDLE HKEY;
    alias HKEY* PHKEY;
    alias DWORD ACCESS_MASK;
    alias ACCESS_MASK* PACCESS_MASK;
    alias ACCESS_MASK REGSAM;
    alias int function() FARPROC;
    alias UINT WPARAM;
    alias LONG LPARAM;
    alias LONG LRESULT;
    alias DWORD COLORREF;
    alias DWORD* LPCOLORREF;
    alias WORD ATOM;
    version (0)
{
    alias BOOL function(HWND, UINT, WPARAM, LPARAM) DLGPROC;
    alias VOID function(HWND, UINT, UINT, DWORD) TIMERPROC;
    alias BOOL function(HDC, LPARAM, int) GRAYSTRINGPROC;
    alias BOOL function(HWND, LPARAM) WNDENUMPROC;
    alias LRESULT function(int code, WPARAM wParam, LPARAM lParam) HOOKPROC;
    alias VOID function(HWND, UINT, DWORD, LRESULT) SENDASYNCPROC;
    alias BOOL function(HWND, LPCSTR, HANDLE) PROPENUMPROCA;
    alias BOOL function(HWND, LPCWSTR, HANDLE) PROPENUMPROCW;
    alias BOOL function(HWND, LPSTR, HANDLE, DWORD) PROPENUMPROCEXA;
    alias BOOL function(HWND, LPWSTR, HANDLE, DWORD) PROPENUMPROCEXW;
    alias int function(LPSTR lpch, int ichCurrent, int cch, int code) EDITWORDBREAKPROCA;
    alias int function(LPWSTR lpch, int ichCurrent, int cch, int code) EDITWORDBREAKPROCW;
    alias BOOL function(HDC hdc, LPARAM lData, WPARAM wData, int cx, int cy) DRAWSTATEPROC;
}
else
{
    alias FARPROC DLGPROC;
    alias FARPROC TIMERPROC;
    alias FARPROC GRAYSTRINGPROC;
    alias FARPROC WNDENUMPROC;
    alias FARPROC HOOKPROC;
    alias FARPROC SENDASYNCPROC;
    alias FARPROC EDITWORDBREAKPROCA;
    alias FARPROC EDITWORDBREAKPROCW;
    alias FARPROC PROPENUMPROCA;
    alias FARPROC PROPENUMPROCW;
    alias FARPROC PROPENUMPROCEXA;
    alias FARPROC PROPENUMPROCEXW;
    alias FARPROC DRAWSTATEPROC;
}
    extern (D) 
{
    WORD HIWORD(int l)
{
return cast(WORD)(l >> 16 & 65535);
}
    WORD LOWORD(int l)
{
return cast(WORD)l;
}
    bool FAILED(int status)
{
return status < 0;
}
    bool SUCCEEDED(int Status)
{
return Status >= 0;
}
}
    enum : int
{
FALSE = 0,
TRUE = 1,
}
    enum : uint
{
MAX_PATH = 260,
HINSTANCE_ERROR = 32,
}
    enum 
{
ERROR_SUCCESS = 0,
ERROR_INVALID_FUNCTION = 1,
ERROR_FILE_NOT_FOUND = 2,
ERROR_PATH_NOT_FOUND = 3,
ERROR_TOO_MANY_OPEN_FILES = 4,
ERROR_ACCESS_DENIED = 5,
ERROR_INVALID_HANDLE = 6,
ERROR_NO_MORE_FILES = 18,
ERROR_MORE_DATA = 234,
ERROR_NO_MORE_ITEMS = 259,
}
    enum 
{
DLL_PROCESS_ATTACH = 1,
DLL_THREAD_ATTACH = 2,
DLL_THREAD_DETACH = 3,
DLL_PROCESS_DETACH = 0,
}
    enum 
{
FILE_BEGIN = 0,
FILE_CURRENT = 1,
FILE_END = 2,
}
    enum : uint
{
DELETE = 65536,
READ_CONTROL = 131072,
WRITE_DAC = 262144,
WRITE_OWNER = 524288,
SYNCHRONIZE = 1048576,
STANDARD_RIGHTS_REQUIRED = 983040,
STANDARD_RIGHTS_READ = READ_CONTROL,
STANDARD_RIGHTS_WRITE = READ_CONTROL,
STANDARD_RIGHTS_EXECUTE = READ_CONTROL,
STANDARD_RIGHTS_ALL = 2031616,
SPECIFIC_RIGHTS_ALL = 65535,
ACCESS_SYSTEM_SECURITY = 16777216,
MAXIMUM_ALLOWED = 33554432,
GENERIC_READ = -2147483648u,
GENERIC_WRITE = 1073741824,
GENERIC_EXECUTE = 536870912,
GENERIC_ALL = 268435456,
}
    enum 
{
FILE_SHARE_READ = 1,
FILE_SHARE_WRITE = 2,
FILE_SHARE_DELETE = 4,
FILE_ATTRIBUTE_READONLY = 1,
FILE_ATTRIBUTE_HIDDEN = 2,
FILE_ATTRIBUTE_SYSTEM = 4,
FILE_ATTRIBUTE_DIRECTORY = 16,
FILE_ATTRIBUTE_ARCHIVE = 32,
FILE_ATTRIBUTE_NORMAL = 128,
FILE_ATTRIBUTE_TEMPORARY = 256,
FILE_ATTRIBUTE_COMPRESSED = 2048,
FILE_ATTRIBUTE_OFFLINE = 4096,
FILE_NOTIFY_CHANGE_FILE_NAME = 1,
FILE_NOTIFY_CHANGE_DIR_NAME = 2,
FILE_NOTIFY_CHANGE_ATTRIBUTES = 4,
FILE_NOTIFY_CHANGE_SIZE = 8,
FILE_NOTIFY_CHANGE_LAST_WRITE = 16,
FILE_NOTIFY_CHANGE_LAST_ACCESS = 32,
FILE_NOTIFY_CHANGE_CREATION = 64,
FILE_NOTIFY_CHANGE_SECURITY = 256,
FILE_ACTION_ADDED = 1,
FILE_ACTION_REMOVED = 2,
FILE_ACTION_MODIFIED = 3,
FILE_ACTION_RENAMED_OLD_NAME = 4,
FILE_ACTION_RENAMED_NEW_NAME = 5,
FILE_CASE_SENSITIVE_SEARCH = 1,
FILE_CASE_PRESERVED_NAMES = 2,
FILE_UNICODE_ON_DISK = 4,
FILE_PERSISTENT_ACLS = 8,
FILE_FILE_COMPRESSION = 16,
FILE_VOLUME_IS_COMPRESSED = 32768,
}
    enum : DWORD
{
MAILSLOT_NO_MESSAGE = cast(DWORD)-1,
MAILSLOT_WAIT_FOREVER = cast(DWORD)-1,
}
    enum : uint
{
FILE_FLAG_WRITE_THROUGH = -2147483648u,
FILE_FLAG_OVERLAPPED = 1073741824,
FILE_FLAG_NO_BUFFERING = 536870912,
FILE_FLAG_RANDOM_ACCESS = 268435456,
FILE_FLAG_SEQUENTIAL_SCAN = 134217728,
FILE_FLAG_DELETE_ON_CLOSE = 67108864,
FILE_FLAG_BACKUP_SEMANTICS = 33554432,
FILE_FLAG_POSIX_SEMANTICS = 16777216,
}
    enum 
{
CREATE_NEW = 1,
CREATE_ALWAYS = 2,
OPEN_EXISTING = 3,
OPEN_ALWAYS = 4,
TRUNCATE_EXISTING = 5,
}
    enum 
{
HANDLE INVALID_HANDLE_VALUE = cast(HANDLE)-1,
DWORD INVALID_SET_FILE_POINTER = cast(DWORD)-1,
DWORD INVALID_FILE_SIZE = cast(DWORD)-1u,
}
    struct OVERLAPPED
{
    DWORD Internal;
    DWORD InternalHigh;
    DWORD Offset;
    DWORD OffsetHigh;
    HANDLE hEvent;
}
    struct SECURITY_ATTRIBUTES
{
    DWORD nLength;
    void* lpSecurityDescriptor;
    BOOL bInheritHandle;
}
    alias SECURITY_ATTRIBUTES* PSECURITY_ATTRIBUTES;
    alias SECURITY_ATTRIBUTES* LPSECURITY_ATTRIBUTES;
    struct FILETIME
{
    DWORD dwLowDateTime;
    DWORD dwHighDateTime;
}
    alias FILETIME* PFILETIME;
    alias FILETIME* LPFILETIME;
    struct WIN32_FIND_DATA
{
    DWORD dwFileAttributes;
    FILETIME ftCreationTime;
    FILETIME ftLastAccessTime;
    FILETIME ftLastWriteTime;
    DWORD nFileSizeHigh;
    DWORD nFileSizeLow;
    DWORD dwReserved0;
    DWORD dwReserved1;
    char[MAX_PATH] cFileName;
    char[14] cAlternateFileName;
}
    struct WIN32_FIND_DATAW
{
    DWORD dwFileAttributes;
    FILETIME ftCreationTime;
    FILETIME ftLastAccessTime;
    FILETIME ftLastWriteTime;
    DWORD nFileSizeHigh;
    DWORD nFileSizeLow;
    DWORD dwReserved0;
    DWORD dwReserved1;
    wchar[260] cFileName;
    wchar[14] cAlternateFileName;
}
    struct _LIST_ENTRY
{
    _LIST_ENTRY* Flink;
    _LIST_ENTRY* Blink;
}
    alias _LIST_ENTRY LIST_ENTRY;
    struct _RTL_CRITICAL_SECTION_DEBUG
{
    WORD Type;
    WORD CreatorBackTraceIndex;
    _RTL_CRITICAL_SECTION* CriticalSection;
    LIST_ENTRY ProcessLocksList;
    DWORD EntryCount;
    DWORD ContentionCount;
    DWORD[2] Spare;
}
    alias _RTL_CRITICAL_SECTION_DEBUG RTL_CRITICAL_SECTION_DEBUG;
    struct _RTL_CRITICAL_SECTION
{
    RTL_CRITICAL_SECTION_DEBUG* DebugInfo;
    LONG LockCount;
    LONG RecursionCount;
    HANDLE OwningThread;
    HANDLE LockSemaphore;
    ULONG_PTR SpinCount;
}
    alias _RTL_CRITICAL_SECTION CRITICAL_SECTION;
    enum 
{
STD_INPUT_HANDLE = cast(DWORD)-10,
STD_OUTPUT_HANDLE = cast(DWORD)-11,
STD_ERROR_HANDLE = cast(DWORD)-12,
}
    export 
{
    BOOL SetCurrentDirectoryA(LPCSTR lpPathName);
    BOOL SetCurrentDirectoryW(LPCWSTR lpPathName);
    UINT GetSystemDirectoryA(LPSTR lpBuffer, UINT uSize);
    UINT GetSystemDirectoryW(LPWSTR lpBuffer, UINT uSize);
    DWORD GetCurrentDirectoryA(DWORD nBufferLength, LPSTR lpBuffer);
    DWORD GetCurrentDirectoryW(DWORD nBufferLength, LPWSTR lpBuffer);
    BOOL CreateDirectoryA(LPCSTR lpPathName, LPSECURITY_ATTRIBUTES lpSecurityAttributes);
    BOOL CreateDirectoryW(LPCWSTR lpPathName, LPSECURITY_ATTRIBUTES lpSecurityAttributes);
    BOOL CreateDirectoryExA(LPCSTR lpTemplateDirectory, LPCSTR lpNewDirectory, LPSECURITY_ATTRIBUTES lpSecurityAttributes);
    BOOL CreateDirectoryExW(LPCWSTR lpTemplateDirectory, LPCWSTR lpNewDirectory, LPSECURITY_ATTRIBUTES lpSecurityAttributes);
    BOOL RemoveDirectoryA(LPCSTR lpPathName);
    BOOL RemoveDirectoryW(LPCWSTR lpPathName);
    BOOL CloseHandle(HANDLE hObject);
    HANDLE CreateFileA(in char* lpFileName, DWORD dwDesiredAccess, DWORD dwShareMode, SECURITY_ATTRIBUTES* lpSecurityAttributes, DWORD dwCreationDisposition, DWORD dwFlagsAndAttributes, HANDLE hTemplateFile);
    HANDLE CreateFileW(LPCWSTR lpFileName, DWORD dwDesiredAccess, DWORD dwShareMode, SECURITY_ATTRIBUTES* lpSecurityAttributes, DWORD dwCreationDisposition, DWORD dwFlagsAndAttributes, HANDLE hTemplateFile);
    BOOL DeleteFileA(in char* lpFileName);
    BOOL DeleteFileW(LPCWSTR lpFileName);
    BOOL FindClose(HANDLE hFindFile);
    HANDLE FindFirstFileA(in char* lpFileName, WIN32_FIND_DATA* lpFindFileData);
    HANDLE FindFirstFileW(in LPCWSTR lpFileName, WIN32_FIND_DATAW* lpFindFileData);
    BOOL FindNextFileA(HANDLE hFindFile, WIN32_FIND_DATA* lpFindFileData);
    BOOL FindNextFileW(HANDLE hFindFile, WIN32_FIND_DATAW* lpFindFileData);
    BOOL GetExitCodeThread(HANDLE hThread, DWORD* lpExitCode);
    DWORD GetLastError();
    DWORD GetFileAttributesA(in char* lpFileName);
    DWORD GetFileAttributesW(in wchar* lpFileName);
    DWORD GetFileSize(HANDLE hFile, DWORD* lpFileSizeHigh);
    BOOL CopyFileA(LPCSTR lpExistingFileName, LPCSTR lpNewFileName, BOOL bFailIfExists);
    BOOL CopyFileW(LPCWSTR lpExistingFileName, LPCWSTR lpNewFileName, BOOL bFailIfExists);
    BOOL MoveFileA(in char* from, in char* to);
    BOOL MoveFileW(LPCWSTR lpExistingFileName, LPCWSTR lpNewFileName);
    BOOL ReadFile(HANDLE hFile, void* lpBuffer, DWORD nNumberOfBytesToRead, DWORD* lpNumberOfBytesRead, OVERLAPPED* lpOverlapped);
    DWORD SetFilePointer(HANDLE hFile, LONG lDistanceToMove, LONG* lpDistanceToMoveHigh, DWORD dwMoveMethod);
    BOOL WriteFile(HANDLE hFile, in void* lpBuffer, DWORD nNumberOfBytesToWrite, DWORD* lpNumberOfBytesWritten, OVERLAPPED* lpOverlapped);
    DWORD GetModuleFileNameA(HMODULE hModule, LPSTR lpFilename, DWORD nSize);
    HANDLE GetStdHandle(DWORD nStdHandle);
    BOOL SetStdHandle(DWORD nStdHandle, HANDLE hHandle);
}
    struct MEMORYSTATUS
{
    DWORD dwLength;
    DWORD dwMemoryLoad;
    DWORD dwTotalPhys;
    DWORD dwAvailPhys;
    DWORD dwTotalPageFile;
    DWORD dwAvailPageFile;
    DWORD dwTotalVirtual;
    DWORD dwAvailVirtual;
}
    alias MEMORYSTATUS* LPMEMORYSTATUS;
    HMODULE LoadLibraryA(LPCSTR lpLibFileName);
    HMODULE LoadLibraryW(LPCWSTR lpLibFileName);
    FARPROC GetProcAddress(HMODULE hModule, LPCSTR lpProcName);
    DWORD GetVersion();
    BOOL FreeLibrary(HMODULE hLibModule);
    void FreeLibraryAndExitThread(HMODULE hLibModule, DWORD dwExitCode);
    BOOL DisableThreadLibraryCalls(HMODULE hLibModule);
    enum 
{
KEY_QUERY_VALUE = 1,
KEY_SET_VALUE = 2,
KEY_CREATE_SUB_KEY = 4,
KEY_ENUMERATE_SUB_KEYS = 8,
KEY_NOTIFY = 16,
KEY_CREATE_LINK = 32,
KEY_READ = cast(int)((STANDARD_RIGHTS_READ | KEY_QUERY_VALUE | KEY_ENUMERATE_SUB_KEYS | KEY_NOTIFY) & ~SYNCHRONIZE),
KEY_WRITE = cast(int)((STANDARD_RIGHTS_WRITE | KEY_SET_VALUE | KEY_CREATE_SUB_KEY) & ~SYNCHRONIZE),
KEY_EXECUTE = cast(int)(KEY_READ & ~SYNCHRONIZE),
KEY_ALL_ACCESS = cast(int)((STANDARD_RIGHTS_ALL | KEY_QUERY_VALUE | KEY_SET_VALUE | KEY_CREATE_SUB_KEY | KEY_ENUMERATE_SUB_KEYS | KEY_NOTIFY | KEY_CREATE_LINK) & ~SYNCHRONIZE),
}
    enum : int
{
REG_CREATED_NEW_KEY = 1,
REG_OPENED_EXISTING_KEY = 2,
}
    enum 
{
REG_NONE = 0,
REG_SZ = 1,
REG_EXPAND_SZ = 2,
REG_BINARY = 3,
REG_DWORD = 4,
REG_DWORD_LITTLE_ENDIAN = 4,
REG_DWORD_BIG_ENDIAN = 5,
REG_LINK = 6,
REG_MULTI_SZ = 7,
REG_RESOURCE_LIST = 8,
REG_FULL_RESOURCE_DESCRIPTOR = 9,
REG_RESOURCE_REQUIREMENTS_LIST = 10,
REG_QWORD = 11,
REG_QWORD_LITTLE_ENDIAN = 11,
}
    enum 
{
MB_OK = 0,
MB_OKCANCEL = 1,
MB_ABORTRETRYIGNORE = 2,
MB_YESNOCANCEL = 3,
MB_YESNO = 4,
MB_RETRYCANCEL = 5,
MB_ICONHAND = 16,
MB_ICONQUESTION = 32,
MB_ICONEXCLAMATION = 48,
MB_ICONASTERISK = 64,
MB_USERICON = 128,
MB_ICONWARNING = MB_ICONEXCLAMATION,
MB_ICONERROR = MB_ICONHAND,
MB_ICONINFORMATION = MB_ICONASTERISK,
MB_ICONSTOP = MB_ICONHAND,
MB_DEFBUTTON1 = 0,
MB_DEFBUTTON2 = 256,
MB_DEFBUTTON3 = 512,
MB_DEFBUTTON4 = 768,
MB_APPLMODAL = 0,
MB_SYSTEMMODAL = 4096,
MB_TASKMODAL = 8192,
MB_HELP = 16384,
MB_NOFOCUS = 32768,
MB_SETFOREGROUND = 65536,
MB_DEFAULT_DESKTOP_ONLY = 131072,
MB_TOPMOST = 262144,
MB_RIGHT = 524288,
MB_RTLREADING = 1048576,
MB_TYPEMASK = 15,
MB_ICONMASK = 240,
MB_DEFMASK = 3840,
MB_MODEMASK = 12288,
MB_MISCMASK = 49152,
}
    int MessageBoxA(HWND hWnd, LPCSTR lpText, LPCSTR lpCaption, UINT uType);
    int MessageBoxW(HWND hWnd, LPCWSTR lpText, LPCWSTR lpCaption, UINT uType);
    int MessageBoxExA(HWND hWnd, LPCSTR lpText, LPCSTR lpCaption, UINT uType, WORD wLanguageId);
    int MessageBoxExW(HWND hWnd, LPCWSTR lpText, LPCWSTR lpCaption, UINT uType, WORD wLanguageId);
    enum : HKEY
{
HKEY_CLASSES_ROOT = cast(HKEY)-2147483648u,
HKEY_CURRENT_USER = cast(HKEY)-2147483647u,
HKEY_LOCAL_MACHINE = cast(HKEY)-2147483646u,
HKEY_USERS = cast(HKEY)-2147483645u,
HKEY_PERFORMANCE_DATA = cast(HKEY)-2147483644u,
HKEY_PERFORMANCE_TEXT = cast(HKEY)-2147483568u,
HKEY_PERFORMANCE_NLSTEXT = cast(HKEY)-2147483552u,
HKEY_CURRENT_CONFIG = cast(HKEY)-2147483643u,
HKEY_DYN_DATA = cast(HKEY)-2147483642u,
}
    enum 
{
REG_OPTION_RESERVED = 0,
REG_OPTION_NON_VOLATILE = 0,
REG_OPTION_VOLATILE = 1,
REG_OPTION_CREATE_LINK = 2,
REG_OPTION_BACKUP_RESTORE = 4,
REG_OPTION_OPEN_LINK = 8,
REG_LEGAL_OPTION = REG_OPTION_RESERVED | REG_OPTION_NON_VOLATILE | REG_OPTION_VOLATILE | REG_OPTION_CREATE_LINK | REG_OPTION_BACKUP_RESTORE | REG_OPTION_OPEN_LINK,
}
    export LONG RegDeleteKeyA(HKEY hKey, LPCSTR lpSubKey);

    export LONG RegDeleteKeyW(HKEY hKey, LPCWSTR lpSubKey);

    export LONG RegDeleteValueA(HKEY hKey, LPCSTR lpValueName);

    export LONG RegDeleteValueW(HKEY hKey, LPCWSTR lpValueName);

    export LONG RegEnumKeyExA(HKEY hKey, DWORD dwIndex, LPSTR lpName, LPDWORD lpcbName, LPDWORD lpReserved, LPSTR lpClass, LPDWORD lpcbClass, FILETIME* lpftLastWriteTime);

    export LONG RegEnumKeyExW(HKEY hKey, DWORD dwIndex, LPWSTR lpName, LPDWORD lpcbName, LPDWORD lpReserved, LPWSTR lpClass, LPDWORD lpcbClass, FILETIME* lpftLastWriteTime);

    export LONG RegEnumValueA(HKEY hKey, DWORD dwIndex, LPSTR lpValueName, LPDWORD lpcbValueName, LPDWORD lpReserved, LPDWORD lpType, LPBYTE lpData, LPDWORD lpcbData);

    export LONG RegEnumValueW(HKEY hKey, DWORD dwIndex, LPWSTR lpValueName, LPDWORD lpcbValueName, LPDWORD lpReserved, LPDWORD lpType, LPBYTE lpData, LPDWORD lpcbData);

    export LONG RegCloseKey(HKEY hKey);

    export LONG RegFlushKey(HKEY hKey);

    export LONG RegOpenKeyA(HKEY hKey, LPCSTR lpSubKey, PHKEY phkResult);

    export LONG RegOpenKeyW(HKEY hKey, LPCWSTR lpSubKey, PHKEY phkResult);

    export LONG RegOpenKeyExA(HKEY hKey, LPCSTR lpSubKey, DWORD ulOptions, REGSAM samDesired, PHKEY phkResult);

    export LONG RegOpenKeyExW(HKEY hKey, LPCWSTR lpSubKey, DWORD ulOptions, REGSAM samDesired, PHKEY phkResult);

    export LONG RegQueryInfoKeyA(HKEY hKey, LPSTR lpClass, LPDWORD lpcbClass, LPDWORD lpReserved, LPDWORD lpcSubKeys, LPDWORD lpcbMaxSubKeyLen, LPDWORD lpcbMaxClassLen, LPDWORD lpcValues, LPDWORD lpcbMaxValueNameLen, LPDWORD lpcbMaxValueLen, LPDWORD lpcbSecurityDescriptor, PFILETIME lpftLastWriteTime);

    export LONG RegQueryInfoKeyW(HKEY hKey, LPWSTR lpClass, LPDWORD lpcbClass, LPDWORD lpReserved, LPDWORD lpcSubKeys, LPDWORD lpcbMaxSubKeyLen, LPDWORD lpcbMaxClassLen, LPDWORD lpcValues, LPDWORD lpcbMaxValueNameLen, LPDWORD lpcbMaxValueLen, LPDWORD lpcbSecurityDescriptor, PFILETIME lpftLastWriteTime);

    export LONG RegQueryValueA(HKEY hKey, LPCSTR lpSubKey, LPSTR lpValue, LPLONG lpcbValue);

    export LONG RegQueryValueW(HKEY hKey, LPCWSTR lpSubKey, LPWSTR lpValue, LPLONG lpcbValue);

    export LONG RegQueryValueExA(HKEY hKey, LPCSTR lpValueName, LPDWORD lpReserved, LPDWORD lpType, LPVOID lpData, LPDWORD lpcbData);

    export LONG RegQueryValueExW(HKEY hKey, LPCWSTR lpValueName, LPDWORD lpReserved, LPDWORD lpType, LPVOID lpData, LPDWORD lpcbData);

    export LONG RegCreateKeyExA(HKEY hKey, LPCSTR lpSubKey, DWORD Reserved, LPSTR lpClass, DWORD dwOptions, REGSAM samDesired, SECURITY_ATTRIBUTES* lpSecurityAttributes, PHKEY phkResult, LPDWORD lpdwDisposition);

    export LONG RegCreateKeyExW(HKEY hKey, LPCWSTR lpSubKey, DWORD Reserved, LPWSTR lpClass, DWORD dwOptions, REGSAM samDesired, SECURITY_ATTRIBUTES* lpSecurityAttributes, PHKEY phkResult, LPDWORD lpdwDisposition);

    export LONG RegSetValueExA(HKEY hKey, LPCSTR lpValueName, DWORD Reserved, DWORD dwType, BYTE* lpData, DWORD cbData);

    export LONG RegSetValueExW(HKEY hKey, LPCWSTR lpValueName, DWORD Reserved, DWORD dwType, BYTE* lpData, DWORD cbData);

    export LONG RegOpenCurrentUser(REGSAM samDesired, PHKEY phkResult);

    export LONG RegConnectRegistryA(LPCSTR lpMachineName, HKEY hKey, PHKEY phkResult);

    export LONG RegConnectRegistryW(LPCWSTR lpMachineName, HKEY hKey, PHKEY phkResult);

    struct MEMORY_BASIC_INFORMATION
{
    PVOID BaseAddress;
    PVOID AllocationBase;
    DWORD AllocationProtect;
    DWORD RegionSize;
    DWORD State;
    DWORD Protect;
    DWORD Type;
}
    alias MEMORY_BASIC_INFORMATION* PMEMORY_BASIC_INFORMATION;
    enum 
{
SECTION_QUERY = 1,
SECTION_MAP_WRITE = 2,
SECTION_MAP_READ = 4,
SECTION_MAP_EXECUTE = 8,
SECTION_EXTEND_SIZE = 16,
SECTION_ALL_ACCESS = cast(int)(STANDARD_RIGHTS_REQUIRED | SECTION_QUERY | SECTION_MAP_WRITE | SECTION_MAP_READ | SECTION_MAP_EXECUTE | SECTION_EXTEND_SIZE),
PAGE_NOACCESS = 1,
PAGE_READONLY = 2,
PAGE_READWRITE = 4,
PAGE_WRITECOPY = 8,
PAGE_EXECUTE = 16,
PAGE_EXECUTE_READ = 32,
PAGE_EXECUTE_READWRITE = 64,
PAGE_EXECUTE_WRITECOPY = 128,
PAGE_GUARD = 256,
PAGE_NOCACHE = 512,
MEM_COMMIT = 4096,
MEM_RESERVE = 8192,
MEM_DECOMMIT = 16384,
MEM_RELEASE = 32768,
MEM_FREE = 65536,
MEM_PRIVATE = 131072,
MEM_MAPPED = 262144,
MEM_RESET = 524288,
MEM_TOP_DOWN = 1048576,
SEC_FILE = 8388608,
SEC_IMAGE = 16777216,
SEC_RESERVE = 67108864,
SEC_COMMIT = 134217728,
SEC_NOCACHE = 268435456,
MEM_IMAGE = SEC_IMAGE,
}
    enum 
{
FILE_MAP_COPY = SECTION_QUERY,
FILE_MAP_WRITE = SECTION_MAP_WRITE,
FILE_MAP_READ = SECTION_MAP_READ,
FILE_MAP_ALL_ACCESS = SECTION_ALL_ACCESS,
}
    enum 
{
FILE_READ_DATA = 1,
FILE_LIST_DIRECTORY = 1,
FILE_WRITE_DATA = 2,
FILE_ADD_FILE = 2,
FILE_APPEND_DATA = 4,
FILE_ADD_SUBDIRECTORY = 4,
FILE_CREATE_PIPE_INSTANCE = 4,
FILE_READ_EA = 8,
FILE_WRITE_EA = 16,
FILE_EXECUTE = 32,
FILE_TRAVERSE = 32,
FILE_DELETE_CHILD = 64,
FILE_READ_ATTRIBUTES = 128,
FILE_WRITE_ATTRIBUTES = 256,
FILE_ALL_ACCESS = cast(int)(STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE | 511),
FILE_GENERIC_READ = cast(int)(STANDARD_RIGHTS_READ | FILE_READ_DATA | FILE_READ_ATTRIBUTES | FILE_READ_EA | SYNCHRONIZE),
FILE_GENERIC_WRITE = cast(int)(STANDARD_RIGHTS_WRITE | FILE_WRITE_DATA | FILE_WRITE_ATTRIBUTES | FILE_WRITE_EA | FILE_APPEND_DATA | SYNCHRONIZE),
FILE_GENERIC_EXECUTE = cast(int)(STANDARD_RIGHTS_EXECUTE | FILE_READ_ATTRIBUTES | FILE_EXECUTE | SYNCHRONIZE),
}
    export 
{
    BOOL FreeResource(HGLOBAL hResData);
    LPVOID LockResource(HGLOBAL hResData);
    BOOL GlobalUnlock(HGLOBAL hMem);
    HGLOBAL GlobalFree(HGLOBAL hMem);
    UINT GlobalCompact(DWORD dwMinFree);
    void GlobalFix(HGLOBAL hMem);
    void GlobalUnfix(HGLOBAL hMem);
    LPVOID GlobalWire(HGLOBAL hMem);
    BOOL GlobalUnWire(HGLOBAL hMem);
    void GlobalMemoryStatus(LPMEMORYSTATUS lpBuffer);
    HLOCAL LocalAlloc(UINT uFlags, UINT uBytes);
    HLOCAL LocalReAlloc(HLOCAL hMem, UINT uBytes, UINT uFlags);
    LPVOID LocalLock(HLOCAL hMem);
    HLOCAL LocalHandle(LPCVOID pMem);
    BOOL LocalUnlock(HLOCAL hMem);
    UINT LocalSize(HLOCAL hMem);
    UINT LocalFlags(HLOCAL hMem);
    HLOCAL LocalFree(HLOCAL hMem);
    UINT LocalShrink(HLOCAL hMem, UINT cbNewSize);
    UINT LocalCompact(UINT uMinFree);
    BOOL FlushInstructionCache(HANDLE hProcess, LPCVOID lpBaseAddress, DWORD dwSize);
    LPVOID VirtualAlloc(LPVOID lpAddress, DWORD dwSize, DWORD flAllocationType, DWORD flProtect);
    BOOL VirtualFree(LPVOID lpAddress, DWORD dwSize, DWORD dwFreeType);
    BOOL VirtualProtect(LPVOID lpAddress, DWORD dwSize, DWORD flNewProtect, PDWORD lpflOldProtect);
    DWORD VirtualQuery(LPCVOID lpAddress, PMEMORY_BASIC_INFORMATION lpBuffer, DWORD dwLength);
    LPVOID VirtualAllocEx(HANDLE hProcess, LPVOID lpAddress, DWORD dwSize, DWORD flAllocationType, DWORD flProtect);
    BOOL VirtualFreeEx(HANDLE hProcess, LPVOID lpAddress, DWORD dwSize, DWORD dwFreeType);
    BOOL VirtualProtectEx(HANDLE hProcess, LPVOID lpAddress, DWORD dwSize, DWORD flNewProtect, PDWORD lpflOldProtect);
    DWORD VirtualQueryEx(HANDLE hProcess, LPCVOID lpAddress, PMEMORY_BASIC_INFORMATION lpBuffer, DWORD dwLength);
}
    struct SYSTEMTIME
{
    WORD wYear;
    WORD wMonth;
    WORD wDayOfWeek;
    WORD wDay;
    WORD wHour;
    WORD wMinute;
    WORD wSecond;
    WORD wMilliseconds;
}
    struct TIME_ZONE_INFORMATION
{
    LONG Bias;
    WCHAR[32] StandardName;
    SYSTEMTIME StandardDate;
    LONG StandardBias;
    WCHAR[32] DaylightName;
    SYSTEMTIME DaylightDate;
    LONG DaylightBias;
}
    enum 
{
TIME_ZONE_ID_UNKNOWN = 0,
TIME_ZONE_ID_STANDARD = 1,
TIME_ZONE_ID_DAYLIGHT = 2,
}
    export void GetSystemTime(SYSTEMTIME* lpSystemTime);

    export BOOL GetFileTime(HANDLE hFile, FILETIME* lpCreationTime, FILETIME* lpLastAccessTime, FILETIME* lpLastWriteTime);

    export void GetSystemTimeAsFileTime(FILETIME* lpSystemTimeAsFileTime);

    export BOOL SetSystemTime(SYSTEMTIME* lpSystemTime);

    export BOOL SetFileTime(HANDLE hFile, in FILETIME* lpCreationTime, in FILETIME* lpLastAccessTime, in FILETIME* lpLastWriteTime);

    export void GetLocalTime(SYSTEMTIME* lpSystemTime);

    export BOOL SetLocalTime(SYSTEMTIME* lpSystemTime);

    export BOOL SystemTimeToTzSpecificLocalTime(TIME_ZONE_INFORMATION* lpTimeZoneInformation, SYSTEMTIME* lpUniversalTime, SYSTEMTIME* lpLocalTime);

    export DWORD GetTimeZoneInformation(TIME_ZONE_INFORMATION* lpTimeZoneInformation);

    export BOOL SetTimeZoneInformation(TIME_ZONE_INFORMATION* lpTimeZoneInformation);

    export BOOL SystemTimeToFileTime(in SYSTEMTIME* lpSystemTime, FILETIME* lpFileTime);

    export BOOL FileTimeToLocalFileTime(in FILETIME* lpFileTime, FILETIME* lpLocalFileTime);

    export BOOL LocalFileTimeToFileTime(in FILETIME* lpLocalFileTime, FILETIME* lpFileTime);

    export BOOL FileTimeToSystemTime(in FILETIME* lpFileTime, SYSTEMTIME* lpSystemTime);

    export LONG CompareFileTime(in FILETIME* lpFileTime1, in FILETIME* lpFileTime2);

    export BOOL FileTimeToDosDateTime(in FILETIME* lpFileTime, WORD* lpFatDate, WORD* lpFatTime);

    export BOOL DosDateTimeToFileTime(WORD wFatDate, WORD wFatTime, FILETIME* lpFileTime);

    export DWORD GetTickCount();

    export BOOL SetSystemTimeAdjustment(DWORD dwTimeAdjustment, BOOL bTimeAdjustmentDisabled);

    export BOOL GetSystemTimeAdjustment(DWORD* lpTimeAdjustment, DWORD* lpTimeIncrement, BOOL* lpTimeAdjustmentDisabled);

    export DWORD FormatMessageA(DWORD dwFlags, LPCVOID lpSource, DWORD dwMessageId, DWORD dwLanguageId, LPSTR lpBuffer, DWORD nSize, void** Arguments);

    export DWORD FormatMessageW(DWORD dwFlags, LPCVOID lpSource, DWORD dwMessageId, DWORD dwLanguageId, LPWSTR lpBuffer, DWORD nSize, void** Arguments);

    enum 
{
FORMAT_MESSAGE_ALLOCATE_BUFFER = 256,
FORMAT_MESSAGE_IGNORE_INSERTS = 512,
FORMAT_MESSAGE_FROM_STRING = 1024,
FORMAT_MESSAGE_FROM_HMODULE = 2048,
FORMAT_MESSAGE_FROM_SYSTEM = 4096,
FORMAT_MESSAGE_ARGUMENT_ARRAY = 8192,
FORMAT_MESSAGE_MAX_WIDTH_MASK = 255,
}
    enum 
{
LANG_NEUTRAL = 0,
LANG_AFRIKAANS = 54,
LANG_ALBANIAN = 28,
LANG_ARABIC = 1,
LANG_BASQUE = 45,
LANG_BELARUSIAN = 35,
LANG_BULGARIAN = 2,
LANG_CATALAN = 3,
LANG_CHINESE = 4,
LANG_CROATIAN = 26,
LANG_CZECH = 5,
LANG_DANISH = 6,
LANG_DUTCH = 19,
LANG_ENGLISH = 9,
LANG_ESTONIAN = 37,
LANG_FAEROESE = 56,
LANG_FARSI = 41,
LANG_FINNISH = 11,
LANG_FRENCH = 12,
LANG_GERMAN = 7,
LANG_GREEK = 8,
LANG_HEBREW = 13,
LANG_HUNGARIAN = 14,
LANG_ICELANDIC = 15,
LANG_INDONESIAN = 33,
LANG_ITALIAN = 16,
LANG_JAPANESE = 17,
LANG_KOREAN = 18,
LANG_LATVIAN = 38,
LANG_LITHUANIAN = 39,
LANG_NORWEGIAN = 20,
LANG_POLISH = 21,
LANG_PORTUGUESE = 22,
LANG_ROMANIAN = 24,
LANG_RUSSIAN = 25,
LANG_SERBIAN = 26,
LANG_SLOVAK = 27,
LANG_SLOVENIAN = 36,
LANG_SPANISH = 10,
LANG_SWEDISH = 29,
LANG_THAI = 30,
LANG_TURKISH = 31,
LANG_UKRAINIAN = 34,
LANG_VIETNAMESE = 42,
}
    enum 
{
SUBLANG_NEUTRAL = 0,
SUBLANG_DEFAULT = 1,
SUBLANG_SYS_DEFAULT = 2,
SUBLANG_ARABIC_SAUDI_ARABIA = 1,
SUBLANG_ARABIC_IRAQ = 2,
SUBLANG_ARABIC_EGYPT = 3,
SUBLANG_ARABIC_LIBYA = 4,
SUBLANG_ARABIC_ALGERIA = 5,
SUBLANG_ARABIC_MOROCCO = 6,
SUBLANG_ARABIC_TUNISIA = 7,
SUBLANG_ARABIC_OMAN = 8,
SUBLANG_ARABIC_YEMEN = 9,
SUBLANG_ARABIC_SYRIA = 10,
SUBLANG_ARABIC_JORDAN = 11,
SUBLANG_ARABIC_LEBANON = 12,
SUBLANG_ARABIC_KUWAIT = 13,
SUBLANG_ARABIC_UAE = 14,
SUBLANG_ARABIC_BAHRAIN = 15,
SUBLANG_ARABIC_QATAR = 16,
SUBLANG_CHINESE_TRADITIONAL = 1,
SUBLANG_CHINESE_SIMPLIFIED = 2,
SUBLANG_CHINESE_HONGKONG = 3,
SUBLANG_CHINESE_SINGAPORE = 4,
SUBLANG_DUTCH = 1,
SUBLANG_DUTCH_BELGIAN = 2,
SUBLANG_ENGLISH_US = 1,
SUBLANG_ENGLISH_UK = 2,
SUBLANG_ENGLISH_AUS = 3,
SUBLANG_ENGLISH_CAN = 4,
SUBLANG_ENGLISH_NZ = 5,
SUBLANG_ENGLISH_EIRE = 6,
SUBLANG_ENGLISH_SOUTH_AFRICA = 7,
SUBLANG_ENGLISH_JAMAICA = 8,
SUBLANG_ENGLISH_CARIBBEAN = 9,
SUBLANG_ENGLISH_BELIZE = 10,
SUBLANG_ENGLISH_TRINIDAD = 11,
SUBLANG_FRENCH = 1,
SUBLANG_FRENCH_BELGIAN = 2,
SUBLANG_FRENCH_CANADIAN = 3,
SUBLANG_FRENCH_SWISS = 4,
SUBLANG_FRENCH_LUXEMBOURG = 5,
SUBLANG_GERMAN = 1,
SUBLANG_GERMAN_SWISS = 2,
SUBLANG_GERMAN_AUSTRIAN = 3,
SUBLANG_GERMAN_LUXEMBOURG = 4,
SUBLANG_GERMAN_LIECHTENSTEIN = 5,
SUBLANG_ITALIAN = 1,
SUBLANG_ITALIAN_SWISS = 2,
SUBLANG_KOREAN = 1,
SUBLANG_KOREAN_JOHAB = 2,
SUBLANG_NORWEGIAN_BOKMAL = 1,
SUBLANG_NORWEGIAN_NYNORSK = 2,
SUBLANG_PORTUGUESE = 2,
SUBLANG_PORTUGUESE_BRAZILIAN = 1,
SUBLANG_SERBIAN_LATIN = 2,
SUBLANG_SERBIAN_CYRILLIC = 3,
SUBLANG_SPANISH = 1,
SUBLANG_SPANISH_MEXICAN = 2,
SUBLANG_SPANISH_MODERN = 3,
SUBLANG_SPANISH_GUATEMALA = 4,
SUBLANG_SPANISH_COSTA_RICA = 5,
SUBLANG_SPANISH_PANAMA = 6,
SUBLANG_SPANISH_DOMINICAN_REPUBLIC = 7,
SUBLANG_SPANISH_VENEZUELA = 8,
SUBLANG_SPANISH_COLOMBIA = 9,
SUBLANG_SPANISH_PERU = 10,
SUBLANG_SPANISH_ARGENTINA = 11,
SUBLANG_SPANISH_ECUADOR = 12,
SUBLANG_SPANISH_CHILE = 13,
SUBLANG_SPANISH_URUGUAY = 14,
SUBLANG_SPANISH_PARAGUAY = 15,
SUBLANG_SPANISH_BOLIVIA = 16,
SUBLANG_SPANISH_EL_SALVADOR = 17,
SUBLANG_SPANISH_HONDURAS = 18,
SUBLANG_SPANISH_NICARAGUA = 19,
SUBLANG_SPANISH_PUERTO_RICO = 20,
SUBLANG_SWEDISH = 1,
SUBLANG_SWEDISH_FINLAND = 2,
}
    enum 
{
SORT_DEFAULT = 0,
SORT_JAPANESE_XJIS = 0,
SORT_JAPANESE_UNICODE = 1,
SORT_CHINESE_BIG5 = 0,
SORT_CHINESE_PRCP = 0,
SORT_CHINESE_UNICODE = 1,
SORT_CHINESE_PRC = 2,
SORT_KOREAN_KSC = 0,
SORT_KOREAN_UNICODE = 1,
SORT_GERMAN_PHONE_BOOK = 1,
}
    int MAKELANGID(int p, int s)
{
return cast(WORD)s << 10 | cast(WORD)p;
}
    WORD PRIMARYLANGID(int lgid)
{
return cast(WORD)(lgid & 1023);
}
    WORD SUBLANGID(int lgid)
{
return cast(WORD)(lgid >> 10);
}
    struct FLOATING_SAVE_AREA
{
    DWORD ControlWord;
    DWORD StatusWord;
    DWORD TagWord;
    DWORD ErrorOffset;
    DWORD ErrorSelector;
    DWORD DataOffset;
    DWORD DataSelector;
    BYTE[80] RegisterArea;
    DWORD Cr0NpxState;
}
    enum 
{
SIZE_OF_80387_REGISTERS = 80,
CONTEXT_i386 = 65536,
CONTEXT_i486 = 65536,
CONTEXT_CONTROL = CONTEXT_i386 | 1,
CONTEXT_INTEGER = CONTEXT_i386 | 2,
CONTEXT_SEGMENTS = CONTEXT_i386 | 4,
CONTEXT_FLOATING_POINT = CONTEXT_i386 | 8,
CONTEXT_DEBUG_REGISTERS = CONTEXT_i386 | 16,
CONTEXT_FULL = CONTEXT_CONTROL | CONTEXT_INTEGER | CONTEXT_SEGMENTS,
}
    struct CONTEXT
{
    DWORD ContextFlags;
    DWORD Dr0;
    DWORD Dr1;
    DWORD Dr2;
    DWORD Dr3;
    DWORD Dr6;
    DWORD Dr7;
    FLOATING_SAVE_AREA FloatSave;
    DWORD SegGs;
    DWORD SegFs;
    DWORD SegEs;
    DWORD SegDs;
    DWORD Edi;
    DWORD Esi;
    DWORD Ebx;
    DWORD Edx;
    DWORD Ecx;
    DWORD Eax;
    DWORD Ebp;
    DWORD Eip;
    DWORD SegCs;
    DWORD EFlags;
    DWORD Esp;
    DWORD SegSs;
}
    enum ADDRESS_MODE 
{
AddrMode1616,
AddrMode1632,
AddrModeReal,
AddrModeFlat,
}
    struct ADDRESS
{
    DWORD Offset;
    WORD Segment;
    ADDRESS_MODE Mode;
}
    struct ADDRESS64
{
    DWORD64 Offset;
    WORD Segment;
    ADDRESS_MODE Mode;
}
    struct KDHELP
{
    DWORD Thread;
    DWORD ThCallbackStack;
    DWORD NextCallback;
    DWORD FramePointer;
    DWORD KiCallUserMode;
    DWORD KeUserCallbackDispatcher;
    DWORD SystemRangeStart;
    DWORD ThCallbackBStore;
    DWORD KiUserExceptionDispatcher;
    DWORD StackBase;
    DWORD StackLimit;
    DWORD[5] Reserved;
}
    struct KDHELP64
{
    DWORD64 Thread;
    DWORD ThCallbackStack;
    DWORD ThCallbackBStore;
    DWORD NextCallback;
    DWORD FramePointer;
    DWORD64 KiCallUserMode;
    DWORD64 KeUserCallbackDispatcher;
    DWORD64 SystemRangeStart;
    DWORD64 KiUserExceptionDispatcher;
    DWORD64 StackBase;
    DWORD64 StackLimit;
    DWORD64[5] Reserved;
}
    struct STACKFRAME
{
    ADDRESS AddrPC;
    ADDRESS AddrReturn;
    ADDRESS AddrFrame;
    ADDRESS AddrStack;
    PVOID FuncTableEntry;
    DWORD[4] Params;
    BOOL Far;
    BOOL Virtual;
    DWORD[3] Reserved;
    KDHELP KdHelp;
    ADDRESS AddrBStore;
}
    struct STACKFRAME64
{
    ADDRESS64 AddrPC;
    ADDRESS64 AddrReturn;
    ADDRESS64 AddrFrame;
    ADDRESS64 AddrStack;
    ADDRESS64 AddrBStore;
    PVOID FuncTableEntry;
    DWORD64[4] Params;
    BOOL Far;
    BOOL Virtual;
    DWORD64[3] Reserved;
    KDHELP64 KdHelp;
}
    enum 
{
THREAD_BASE_PRIORITY_LOWRT = 15,
THREAD_BASE_PRIORITY_MAX = 2,
THREAD_BASE_PRIORITY_MIN = -2,
THREAD_BASE_PRIORITY_IDLE = -15,
THREAD_PRIORITY_LOWEST = THREAD_BASE_PRIORITY_MIN,
THREAD_PRIORITY_BELOW_NORMAL = THREAD_PRIORITY_LOWEST + 1,
THREAD_PRIORITY_NORMAL = 0,
THREAD_PRIORITY_HIGHEST = THREAD_BASE_PRIORITY_MAX,
THREAD_PRIORITY_ABOVE_NORMAL = THREAD_PRIORITY_HIGHEST - 1,
THREAD_PRIORITY_ERROR_RETURN = (int).max,
THREAD_PRIORITY_TIME_CRITICAL = THREAD_BASE_PRIORITY_LOWRT,
THREAD_PRIORITY_IDLE = THREAD_BASE_PRIORITY_IDLE,
}
    export BOOL GetUserNameA(LPSTR lpBuffer, LPDWORD lpnSize);

    export BOOL GetUserNameW(LPWSTR lpBuffer, LPDWORD lpnSize);

    export HANDLE GetCurrentThread();

    export BOOL GetProcessTimes(HANDLE hProcess, LPFILETIME lpCreationTime, LPFILETIME lpExitTime, LPFILETIME lpKernelTime, LPFILETIME lpUserTime);

    export HANDLE GetCurrentProcess();

    export DWORD GetCurrentProcessId();

    export BOOL DuplicateHandle(HANDLE sourceProcess, HANDLE sourceThread, HANDLE targetProcessHandle, HANDLE* targetHandle, DWORD access, BOOL inheritHandle, DWORD options);

    export DWORD GetCurrentThreadId();

    export BOOL SetThreadPriority(HANDLE hThread, int nPriority);

    export BOOL SetThreadPriorityBoost(HANDLE hThread, BOOL bDisablePriorityBoost);

    export BOOL GetThreadPriorityBoost(HANDLE hThread, PBOOL pDisablePriorityBoost);

    export BOOL GetThreadTimes(HANDLE hThread, LPFILETIME lpCreationTime, LPFILETIME lpExitTime, LPFILETIME lpKernelTime, LPFILETIME lpUserTime);

    export int GetThreadPriority(HANDLE hThread);

    export BOOL GetThreadContext(HANDLE hThread, CONTEXT* lpContext);

    export BOOL SetThreadContext(HANDLE hThread, CONTEXT* lpContext);

    export DWORD SuspendThread(HANDLE hThread);

    export DWORD ResumeThread(HANDLE hThread);

    export DWORD WaitForSingleObject(HANDLE hHandle, DWORD dwMilliseconds);

    export DWORD WaitForMultipleObjects(DWORD nCount, HANDLE* lpHandles, BOOL bWaitAll, DWORD dwMilliseconds);

    export void Sleep(DWORD dwMilliseconds);

    export 
{
    LONG InterlockedIncrement(LPLONG lpAddend);
    LONG InterlockedDecrement(LPLONG lpAddend);
    LONG InterlockedExchange(LPLONG Target, LONG Value);
    LONG InterlockedExchangeAdd(LPLONG Addend, LONG Value);
    PVOID InterlockedCompareExchange(PVOID* Destination, PVOID Exchange, PVOID Comperand);
    void InitializeCriticalSection(CRITICAL_SECTION* lpCriticalSection);
    void EnterCriticalSection(CRITICAL_SECTION* lpCriticalSection);
    BOOL TryEnterCriticalSection(CRITICAL_SECTION* lpCriticalSection);
    void LeaveCriticalSection(CRITICAL_SECTION* lpCriticalSection);
    void DeleteCriticalSection(CRITICAL_SECTION* lpCriticalSection);
}
    export BOOL QueryPerformanceCounter(long* lpPerformanceCount);

    export BOOL QueryPerformanceFrequency(long* lpFrequency);

    enum 
{
WM_NOTIFY = 78,
WM_INPUTLANGCHANGEREQUEST = 80,
WM_INPUTLANGCHANGE = 81,
WM_TCARD = 82,
WM_HELP = 83,
WM_USERCHANGED = 84,
WM_NOTIFYFORMAT = 85,
NFR_ANSI = 1,
NFR_UNICODE = 2,
NF_QUERY = 3,
NF_REQUERY = 4,
WM_CONTEXTMENU = 123,
WM_STYLECHANGING = 124,
WM_STYLECHANGED = 125,
WM_DISPLAYCHANGE = 126,
WM_GETICON = 127,
WM_SETICON = 128,
WM_NCCREATE = 129,
WM_NCDESTROY = 130,
WM_NCCALCSIZE = 131,
WM_NCHITTEST = 132,
WM_NCPAINT = 133,
WM_NCACTIVATE = 134,
WM_GETDLGCODE = 135,
WM_NCMOUSEMOVE = 160,
WM_NCLBUTTONDOWN = 161,
WM_NCLBUTTONUP = 162,
WM_NCLBUTTONDBLCLK = 163,
WM_NCRBUTTONDOWN = 164,
WM_NCRBUTTONUP = 165,
WM_NCRBUTTONDBLCLK = 166,
WM_NCMBUTTONDOWN = 167,
WM_NCMBUTTONUP = 168,
WM_NCMBUTTONDBLCLK = 169,
WM_KEYFIRST = 256,
WM_KEYDOWN = 256,
WM_KEYUP = 257,
WM_CHAR = 258,
WM_DEADCHAR = 259,
WM_SYSKEYDOWN = 260,
WM_SYSKEYUP = 261,
WM_SYSCHAR = 262,
WM_SYSDEADCHAR = 263,
WM_KEYLAST = 264,
WM_IME_STARTCOMPOSITION = 269,
WM_IME_ENDCOMPOSITION = 270,
WM_IME_COMPOSITION = 271,
WM_IME_KEYLAST = 271,
WM_INITDIALOG = 272,
WM_COMMAND = 273,
WM_SYSCOMMAND = 274,
WM_TIMER = 275,
WM_HSCROLL = 276,
WM_VSCROLL = 277,
WM_INITMENU = 278,
WM_INITMENUPOPUP = 279,
WM_MENUSELECT = 287,
WM_MENUCHAR = 288,
WM_ENTERIDLE = 289,
WM_CTLCOLORMSGBOX = 306,
WM_CTLCOLOREDIT = 307,
WM_CTLCOLORLISTBOX = 308,
WM_CTLCOLORBTN = 309,
WM_CTLCOLORDLG = 310,
WM_CTLCOLORSCROLLBAR = 311,
WM_CTLCOLORSTATIC = 312,
WM_MOUSEFIRST = 512,
WM_MOUSEMOVE = 512,
WM_LBUTTONDOWN = 513,
WM_LBUTTONUP = 514,
WM_LBUTTONDBLCLK = 515,
WM_RBUTTONDOWN = 516,
WM_RBUTTONUP = 517,
WM_RBUTTONDBLCLK = 518,
WM_MBUTTONDOWN = 519,
WM_MBUTTONUP = 520,
WM_MBUTTONDBLCLK = 521,
WM_MOUSELAST = 521,
WM_PARENTNOTIFY = 528,
MENULOOP_WINDOW = 0,
MENULOOP_POPUP = 1,
WM_ENTERMENULOOP = 529,
WM_EXITMENULOOP = 530,
WM_NEXTMENU = 531,
}
    enum 
{
IDOK = 1,
IDCANCEL = 2,
IDABORT = 3,
IDRETRY = 4,
IDIGNORE = 5,
IDYES = 6,
IDNO = 7,
IDCLOSE = 8,
IDHELP = 9,
ES_LEFT = 0,
ES_CENTER = 1,
ES_RIGHT = 2,
ES_MULTILINE = 4,
ES_UPPERCASE = 8,
ES_LOWERCASE = 16,
ES_PASSWORD = 32,
ES_AUTOVSCROLL = 64,
ES_AUTOHSCROLL = 128,
ES_NOHIDESEL = 256,
ES_OEMCONVERT = 1024,
ES_READONLY = 2048,
ES_WANTRETURN = 4096,
ES_NUMBER = 8192,
EN_SETFOCUS = 256,
EN_KILLFOCUS = 512,
EN_CHANGE = 768,
EN_UPDATE = 1024,
EN_ERRSPACE = 1280,
EN_MAXTEXT = 1281,
EN_HSCROLL = 1537,
EN_VSCROLL = 1538,
EC_LEFTMARGIN = 1,
EC_RIGHTMARGIN = 2,
EC_USEFONTINFO = 65535,
EM_GETSEL = 176,
EM_SETSEL = 177,
EM_GETRECT = 178,
EM_SETRECT = 179,
EM_SETRECTNP = 180,
EM_SCROLL = 181,
EM_LINESCROLL = 182,
EM_SCROLLCARET = 183,
EM_GETMODIFY = 184,
EM_SETMODIFY = 185,
EM_GETLINECOUNT = 186,
EM_LINEINDEX = 187,
EM_SETHANDLE = 188,
EM_GETHANDLE = 189,
EM_GETTHUMB = 190,
EM_LINELENGTH = 193,
EM_REPLACESEL = 194,
EM_GETLINE = 196,
EM_LIMITTEXT = 197,
EM_CANUNDO = 198,
EM_UNDO = 199,
EM_FMTLINES = 200,
EM_LINEFROMCHAR = 201,
EM_SETTABSTOPS = 203,
EM_SETPASSWORDCHAR = 204,
EM_EMPTYUNDOBUFFER = 205,
EM_GETFIRSTVISIBLELINE = 206,
EM_SETREADONLY = 207,
EM_SETWORDBREAKPROC = 208,
EM_GETWORDBREAKPROC = 209,
EM_GETPASSWORDCHAR = 210,
EM_SETMARGINS = 211,
EM_GETMARGINS = 212,
EM_SETLIMITTEXT = EM_LIMITTEXT,
EM_GETLIMITTEXT = 213,
EM_POSFROMCHAR = 214,
EM_CHARFROMPOS = 215,
WB_LEFT = 0,
WB_RIGHT = 1,
WB_ISDELIMITER = 2,
BS_PUSHBUTTON = 0,
BS_DEFPUSHBUTTON = 1,
BS_CHECKBOX = 2,
BS_AUTOCHECKBOX = 3,
BS_RADIOBUTTON = 4,
BS_3STATE = 5,
BS_AUTO3STATE = 6,
BS_GROUPBOX = 7,
BS_USERBUTTON = 8,
BS_AUTORADIOBUTTON = 9,
BS_OWNERDRAW = 11,
BS_LEFTTEXT = 32,
BS_TEXT = 0,
BS_ICON = 64,
BS_BITMAP = 128,
BS_LEFT = 256,
BS_RIGHT = 512,
BS_CENTER = 768,
BS_TOP = 1024,
BS_BOTTOM = 2048,
BS_VCENTER = 3072,
BS_PUSHLIKE = 4096,
BS_MULTILINE = 8192,
BS_NOTIFY = 16384,
BS_FLAT = 32768,
BS_RIGHTBUTTON = BS_LEFTTEXT,
BN_CLICKED = 0,
BN_PAINT = 1,
BN_HILITE = 2,
BN_UNHILITE = 3,
BN_DISABLE = 4,
BN_DOUBLECLICKED = 5,
BN_PUSHED = BN_HILITE,
BN_UNPUSHED = BN_UNHILITE,
BN_DBLCLK = BN_DOUBLECLICKED,
BN_SETFOCUS = 6,
BN_KILLFOCUS = 7,
BM_GETCHECK = 240,
BM_SETCHECK = 241,
BM_GETSTATE = 242,
BM_SETSTATE = 243,
BM_SETSTYLE = 244,
BM_CLICK = 245,
BM_GETIMAGE = 246,
BM_SETIMAGE = 247,
BST_UNCHECKED = 0,
BST_CHECKED = 1,
BST_INDETERMINATE = 2,
BST_PUSHED = 4,
BST_FOCUS = 8,
SS_LEFT = 0,
SS_CENTER = 1,
SS_RIGHT = 2,
SS_ICON = 3,
SS_BLACKRECT = 4,
SS_GRAYRECT = 5,
SS_WHITERECT = 6,
SS_BLACKFRAME = 7,
SS_GRAYFRAME = 8,
SS_WHITEFRAME = 9,
SS_USERITEM = 10,
SS_SIMPLE = 11,
SS_LEFTNOWORDWRAP = 12,
SS_OWNERDRAW = 13,
SS_BITMAP = 14,
SS_ENHMETAFILE = 15,
SS_ETCHEDHORZ = 16,
SS_ETCHEDVERT = 17,
SS_ETCHEDFRAME = 18,
SS_TYPEMASK = 31,
SS_NOPREFIX = 128,
SS_NOTIFY = 256,
SS_CENTERIMAGE = 512,
SS_RIGHTJUST = 1024,
SS_REALSIZEIMAGE = 2048,
SS_SUNKEN = 4096,
SS_ENDELLIPSIS = 16384,
SS_PATHELLIPSIS = 32768,
SS_WORDELLIPSIS = 49152,
SS_ELLIPSISMASK = 49152,
STM_SETICON = 368,
STM_GETICON = 369,
STM_SETIMAGE = 370,
STM_GETIMAGE = 371,
STN_CLICKED = 0,
STN_DBLCLK = 1,
STN_ENABLE = 2,
STN_DISABLE = 3,
STM_MSGMAX = 372,
}
    enum 
{
WM_NULL = 0,
WM_CREATE = 1,
WM_DESTROY = 2,
WM_MOVE = 3,
WM_SIZE = 5,
WM_ACTIVATE = 6,
WA_INACTIVE = 0,
WA_ACTIVE = 1,
WA_CLICKACTIVE = 2,
WM_SETFOCUS = 7,
WM_KILLFOCUS = 8,
WM_ENABLE = 10,
WM_SETREDRAW = 11,
WM_SETTEXT = 12,
WM_GETTEXT = 13,
WM_GETTEXTLENGTH = 14,
WM_PAINT = 15,
WM_CLOSE = 16,
WM_QUERYENDSESSION = 17,
WM_QUIT = 18,
WM_QUERYOPEN = 19,
WM_ERASEBKGND = 20,
WM_SYSCOLORCHANGE = 21,
WM_ENDSESSION = 22,
WM_SHOWWINDOW = 24,
WM_WININICHANGE = 26,
WM_SETTINGCHANGE = WM_WININICHANGE,
WM_DEVMODECHANGE = 27,
WM_ACTIVATEAPP = 28,
WM_FONTCHANGE = 29,
WM_TIMECHANGE = 30,
WM_CANCELMODE = 31,
WM_SETCURSOR = 32,
WM_MOUSEACTIVATE = 33,
WM_CHILDACTIVATE = 34,
WM_QUEUESYNC = 35,
WM_GETMINMAXINFO = 36,
}
    struct RECT
{
    LONG left;
    LONG top;
    LONG right;
    LONG bottom;
}
    alias RECT* PRECT;
    alias RECT* NPRECT;
    alias RECT* LPRECT;
    struct PAINTSTRUCT
{
    HDC hdc;
    BOOL fErase;
    RECT rcPaint;
    BOOL fRestore;
    BOOL fIncUpdate;
    BYTE[32] rgbReserved;
}
    alias PAINTSTRUCT* PPAINTSTRUCT;
    alias PAINTSTRUCT* NPPAINTSTRUCT;
    alias PAINTSTRUCT* LPPAINTSTRUCT;
    enum 
{
DCX_WINDOW = 1,
DCX_CACHE = 2,
DCX_NORESETATTRS = 4,
DCX_CLIPCHILDREN = 8,
DCX_CLIPSIBLINGS = 16,
DCX_PARENTCLIP = 32,
DCX_EXCLUDERGN = 64,
DCX_INTERSECTRGN = 128,
DCX_EXCLUDEUPDATE = 256,
DCX_INTERSECTUPDATE = 512,
DCX_LOCKWINDOWUPDATE = 1024,
DCX_VALIDATE = 2097152,
}
    export 
{
    BOOL UpdateWindow(HWND hWnd);
    HWND SetActiveWindow(HWND hWnd);
    HWND GetForegroundWindow();
    BOOL PaintDesktop(HDC hdc);
    BOOL SetForegroundWindow(HWND hWnd);
    HWND WindowFromDC(HDC hDC);
    HDC GetDC(HWND hWnd);
    HDC GetDCEx(HWND hWnd, HRGN hrgnClip, DWORD flags);
    HDC GetWindowDC(HWND hWnd);
    int ReleaseDC(HWND hWnd, HDC hDC);
    HDC BeginPaint(HWND hWnd, LPPAINTSTRUCT lpPaint);
    BOOL EndPaint(HWND hWnd, PAINTSTRUCT* lpPaint);
    BOOL GetUpdateRect(HWND hWnd, LPRECT lpRect, BOOL bErase);
    int GetUpdateRgn(HWND hWnd, HRGN hRgn, BOOL bErase);
    int SetWindowRgn(HWND hWnd, HRGN hRgn, BOOL bRedraw);
    int GetWindowRgn(HWND hWnd, HRGN hRgn);
    int ExcludeUpdateRgn(HDC hDC, HWND hWnd);
    BOOL InvalidateRect(HWND hWnd, RECT* lpRect, BOOL bErase);
    BOOL ValidateRect(HWND hWnd, RECT* lpRect);
    BOOL InvalidateRgn(HWND hWnd, HRGN hRgn, BOOL bErase);
    BOOL ValidateRgn(HWND hWnd, HRGN hRgn);
    BOOL RedrawWindow(HWND hWnd, RECT* lprcUpdate, HRGN hrgnUpdate, UINT flags);
}
    enum 
{
RDW_INVALIDATE = 1,
RDW_INTERNALPAINT = 2,
RDW_ERASE = 4,
RDW_VALIDATE = 8,
RDW_NOINTERNALPAINT = 16,
RDW_NOERASE = 32,
RDW_NOCHILDREN = 64,
RDW_ALLCHILDREN = 128,
RDW_UPDATENOW = 256,
RDW_ERASENOW = 512,
RDW_FRAME = 1024,
RDW_NOFRAME = 2048,
}
    export 
{
    BOOL GetClientRect(HWND hWnd, LPRECT lpRect);
    BOOL GetWindowRect(HWND hWnd, LPRECT lpRect);
    BOOL AdjustWindowRect(LPRECT lpRect, DWORD dwStyle, BOOL bMenu);
    BOOL AdjustWindowRectEx(LPRECT lpRect, DWORD dwStyle, BOOL bMenu, DWORD dwExStyle);
    HFONT CreateFontA(int, int, int, int, int, DWORD, DWORD, DWORD, DWORD, DWORD, DWORD, DWORD, DWORD, LPCSTR);
    HFONT CreateFontW(int, int, int, int, int, DWORD, DWORD, DWORD, DWORD, DWORD, DWORD, DWORD, DWORD, LPCWSTR);
}
    enum 
{
OUT_DEFAULT_PRECIS = 0,
OUT_STRING_PRECIS = 1,
OUT_CHARACTER_PRECIS = 2,
OUT_STROKE_PRECIS = 3,
OUT_TT_PRECIS = 4,
OUT_DEVICE_PRECIS = 5,
OUT_RASTER_PRECIS = 6,
OUT_TT_ONLY_PRECIS = 7,
OUT_OUTLINE_PRECIS = 8,
OUT_SCREEN_OUTLINE_PRECIS = 9,
CLIP_DEFAULT_PRECIS = 0,
CLIP_CHARACTER_PRECIS = 1,
CLIP_STROKE_PRECIS = 2,
CLIP_MASK = 15,
CLIP_LH_ANGLES = 1 << 4,
CLIP_TT_ALWAYS = 2 << 4,
CLIP_EMBEDDED = 8 << 4,
DEFAULT_QUALITY = 0,
DRAFT_QUALITY = 1,
PROOF_QUALITY = 2,
NONANTIALIASED_QUALITY = 3,
ANTIALIASED_QUALITY = 4,
DEFAULT_PITCH = 0,
FIXED_PITCH = 1,
VARIABLE_PITCH = 2,
MONO_FONT = 8,
ANSI_CHARSET = 0,
DEFAULT_CHARSET = 1,
SYMBOL_CHARSET = 2,
SHIFTJIS_CHARSET = 128,
HANGEUL_CHARSET = 129,
GB2312_CHARSET = 134,
CHINESEBIG5_CHARSET = 136,
OEM_CHARSET = 255,
JOHAB_CHARSET = 130,
HEBREW_CHARSET = 177,
ARABIC_CHARSET = 178,
GREEK_CHARSET = 161,
TURKISH_CHARSET = 162,
VIETNAMESE_CHARSET = 163,
THAI_CHARSET = 222,
EASTEUROPE_CHARSET = 238,
RUSSIAN_CHARSET = 204,
MAC_CHARSET = 77,
BALTIC_CHARSET = 186,
FS_LATIN1 = 1L,
FS_LATIN2 = 2L,
FS_CYRILLIC = 4L,
FS_GREEK = 8L,
FS_TURKISH = 16L,
FS_HEBREW = 32L,
FS_ARABIC = 64L,
FS_BALTIC = 128L,
FS_VIETNAMESE = 256L,
FS_THAI = 65536L,
FS_JISJAPAN = 131072L,
FS_CHINESESIMP = 262144L,
FS_WANSUNG = 524288L,
FS_CHINESETRAD = 1048576L,
FS_JOHAB = 2097152L,
FS_SYMBOL = cast(int)2147483648L,
FF_DONTCARE = 0 << 4,
FF_ROMAN = 1 << 4,
FF_SWISS = 2 << 4,
FF_MODERN = 3 << 4,
FF_SCRIPT = 4 << 4,
FF_DECORATIVE = 5 << 4,
FW_DONTCARE = 0,
FW_THIN = 100,
FW_EXTRALIGHT = 200,
FW_LIGHT = 300,
FW_NORMAL = 400,
FW_MEDIUM = 500,
FW_SEMIBOLD = 600,
FW_BOLD = 700,
FW_EXTRABOLD = 800,
FW_HEAVY = 900,
FW_ULTRALIGHT = FW_EXTRALIGHT,
FW_REGULAR = FW_NORMAL,
FW_DEMIBOLD = FW_SEMIBOLD,
FW_ULTRABOLD = FW_EXTRABOLD,
FW_BLACK = FW_HEAVY,
PANOSE_COUNT = 10,
PAN_FAMILYTYPE_INDEX = 0,
PAN_SERIFSTYLE_INDEX = 1,
PAN_WEIGHT_INDEX = 2,
PAN_PROPORTION_INDEX = 3,
PAN_CONTRAST_INDEX = 4,
PAN_STROKEVARIATION_INDEX = 5,
PAN_ARMSTYLE_INDEX = 6,
PAN_LETTERFORM_INDEX = 7,
PAN_MIDLINE_INDEX = 8,
PAN_XHEIGHT_INDEX = 9,
PAN_CULTURE_LATIN = 0,
}
    struct RGBQUAD
{
    BYTE rgbBlue;
    BYTE rgbGreen;
    BYTE rgbRed;
    BYTE rgbReserved;
}
    alias RGBQUAD* LPRGBQUAD;
    struct BITMAPINFOHEADER
{
    DWORD biSize;
    LONG biWidth;
    LONG biHeight;
    WORD biPlanes;
    WORD biBitCount;
    DWORD biCompression;
    DWORD biSizeImage;
    LONG biXPelsPerMeter;
    LONG biYPelsPerMeter;
    DWORD biClrUsed;
    DWORD biClrImportant;
}
    alias BITMAPINFOHEADER* LPBITMAPINFOHEADER;
    alias BITMAPINFOHEADER* PBITMAPINFOHEADER;
    struct BITMAPINFO
{
    BITMAPINFOHEADER bmiHeader;
    RGBQUAD[1] bmiColors;
}
    alias BITMAPINFO* LPBITMAPINFO;
    alias BITMAPINFO* PBITMAPINFO;
    struct PALETTEENTRY
{
    BYTE peRed;
    BYTE peGreen;
    BYTE peBlue;
    BYTE peFlags;
}
    alias PALETTEENTRY* PPALETTEENTRY;
    alias PALETTEENTRY* LPPALETTEENTRY;
    struct LOGPALETTE
{
    WORD palVersion;
    WORD palNumEntries;
    PALETTEENTRY[1] palPalEntry;
}
    alias LOGPALETTE* PLOGPALETTE;
    alias LOGPALETTE* NPLOGPALETTE;
    alias LOGPALETTE* LPLOGPALETTE;
    struct PIXELFORMATDESCRIPTOR
{
    WORD nSize;
    WORD nVersion;
    DWORD dwFlags;
    BYTE iPixelType;
    BYTE cColorBits;
    BYTE cRedBits;
    BYTE cRedShift;
    BYTE cGreenBits;
    BYTE cGreenShift;
    BYTE cBlueBits;
    BYTE cBlueShift;
    BYTE cAlphaBits;
    BYTE cAlphaShift;
    BYTE cAccumBits;
    BYTE cAccumRedBits;
    BYTE cAccumGreenBits;
    BYTE cAccumBlueBits;
    BYTE cAccumAlphaBits;
    BYTE cDepthBits;
    BYTE cStencilBits;
    BYTE cAuxBuffers;
    BYTE iLayerType;
    BYTE bReserved;
    DWORD dwLayerMask;
    DWORD dwVisibleMask;
    DWORD dwDamageMask;
}
    alias PIXELFORMATDESCRIPTOR* PPIXELFORMATDESCRIPTOR;
    alias PIXELFORMATDESCRIPTOR* LPPIXELFORMATDESCRIPTOR;
    export 
{
    BOOL RoundRect(HDC, int, int, int, int, int, int);
    BOOL ResizePalette(HPALETTE, UINT);
    int SaveDC(HDC);
    int SelectClipRgn(HDC, HRGN);
    int ExtSelectClipRgn(HDC, HRGN, int);
    int SetMetaRgn(HDC);
    HGDIOBJ SelectObject(HDC, HGDIOBJ);
    HPALETTE SelectPalette(HDC, HPALETTE, BOOL);
    COLORREF SetBkColor(HDC, COLORREF);
    int SetBkMode(HDC, int);
    LONG SetBitmapBits(HBITMAP, DWORD, void*);
    UINT SetBoundsRect(HDC, RECT*, UINT);
    int SetDIBits(HDC, HBITMAP, UINT, UINT, void*, BITMAPINFO*, UINT);
    int SetDIBitsToDevice(HDC, int, int, DWORD, DWORD, int, int, UINT, UINT, void*, BITMAPINFO*, UINT);
    DWORD SetMapperFlags(HDC, DWORD);
    int SetGraphicsMode(HDC hdc, int iMode);
    int SetMapMode(HDC, int);
    HMETAFILE SetMetaFileBitsEx(UINT, BYTE*);
    UINT SetPaletteEntries(HPALETTE, UINT, UINT, PALETTEENTRY*);
    COLORREF SetPixel(HDC, int, int, COLORREF);
    BOOL SetPixelV(HDC, int, int, COLORREF);
    BOOL SetPixelFormat(HDC, int, PIXELFORMATDESCRIPTOR*);
    int SetPolyFillMode(HDC, int);
    BOOL StretchBlt(HDC, int, int, int, int, HDC, int, int, int, int, DWORD);
    BOOL SetRectRgn(HRGN, int, int, int, int);
    int StretchDIBits(HDC, int, int, int, int, int, int, int, int, void*, BITMAPINFO*, UINT, DWORD);
    int SetROP2(HDC, int);
    int SetStretchBltMode(HDC, int);
    UINT SetSystemPaletteUse(HDC, UINT);
    int SetTextCharacterExtra(HDC, int);
    COLORREF SetTextColor(HDC, COLORREF);
    UINT SetTextAlign(HDC, UINT);
    BOOL SetTextJustification(HDC, int, int);
    BOOL UpdateColors(HDC);
}
    enum 
{
TA_NOUPDATECP = 0,
TA_UPDATECP = 1,
TA_LEFT = 0,
TA_RIGHT = 2,
TA_CENTER = 6,
TA_TOP = 0,
TA_BOTTOM = 8,
TA_BASELINE = 24,
TA_RTLREADING = 256,
TA_MASK = TA_BASELINE + TA_CENTER + TA_UPDATECP + TA_RTLREADING,
}
    struct POINT
{
    LONG x;
    LONG y;
}
    alias POINT* PPOINT;
    alias POINT* NPPOINT;
    alias POINT* LPPOINT;
    export 
{
    BOOL MoveToEx(HDC, int, int, LPPOINT);
    BOOL TextOutA(HDC, int, int, LPCSTR, int);
    BOOL TextOutW(HDC, int, int, LPCWSTR, int);
}
    export void PostQuitMessage(int nExitCode);

    export LRESULT DefWindowProcA(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);

    export LRESULT DefWindowProcW(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);

    export HMODULE GetModuleHandleA(LPCSTR lpModuleName);

    export HMODULE GetModuleHandleW(LPCWSTR lpModuleName);

    alias LRESULT function(HWND, UINT, WPARAM, LPARAM) WNDPROC;
    struct WNDCLASSEXA
{
    UINT cbSize;
    UINT style;
    WNDPROC lpfnWndProc;
    int cbClsExtra;
    int cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    LPCSTR lpszMenuName;
    LPCSTR lpszClassName;
    HICON hIconSm;
}
    alias WNDCLASSEXA* PWNDCLASSEXA;
    alias WNDCLASSEXA* NPWNDCLASSEXA;
    alias WNDCLASSEXA* LPWNDCLASSEXA;
    struct WNDCLASSA
{
    UINT style;
    WNDPROC lpfnWndProc;
    int cbClsExtra;
    int cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    LPCSTR lpszMenuName;
    LPCSTR lpszClassName;
}
    alias WNDCLASSA* PWNDCLASSA;
    alias WNDCLASSA* NPWNDCLASSA;
    alias WNDCLASSA* LPWNDCLASSA;
    alias WNDCLASSA WNDCLASS;
    enum : uint
{
WS_OVERLAPPED = 0,
WS_POPUP = -2147483648u,
WS_CHILD = 1073741824,
WS_MINIMIZE = 536870912,
WS_VISIBLE = 268435456,
WS_DISABLED = 134217728,
WS_CLIPSIBLINGS = 67108864,
WS_CLIPCHILDREN = 33554432,
WS_MAXIMIZE = 16777216,
WS_CAPTION = 12582912,
WS_BORDER = 8388608,
WS_DLGFRAME = 4194304,
WS_VSCROLL = 2097152,
WS_HSCROLL = 1048576,
WS_SYSMENU = 524288,
WS_THICKFRAME = 262144,
WS_GROUP = 131072,
WS_TABSTOP = 65536,
WS_MINIMIZEBOX = 131072,
WS_MAXIMIZEBOX = 65536,
WS_TILED = WS_OVERLAPPED,
WS_ICONIC = WS_MINIMIZE,
WS_SIZEBOX = WS_THICKFRAME,
WS_OVERLAPPEDWINDOW = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX,
WS_TILEDWINDOW = WS_OVERLAPPEDWINDOW,
WS_POPUPWINDOW = WS_POPUP | WS_BORDER | WS_SYSMENU,
WS_CHILDWINDOW = WS_CHILD,
}
    enum 
{
CS_VREDRAW = 1,
CS_HREDRAW = 2,
CS_KEYCVTWINDOW = 4,
CS_DBLCLKS = 8,
CS_OWNDC = 32,
CS_CLASSDC = 64,
CS_PARENTDC = 128,
CS_NOKEYCVT = 256,
CS_NOCLOSE = 512,
CS_SAVEBITS = 2048,
CS_BYTEALIGNCLIENT = 4096,
CS_BYTEALIGNWINDOW = 8192,
CS_GLOBALCLASS = 16384,
CS_IME = 65536,
}
    export 
{
    HICON LoadIconA(HINSTANCE hInstance, LPCSTR lpIconName);
    HICON LoadIconW(HINSTANCE hInstance, LPCWSTR lpIconName);
    HCURSOR LoadCursorA(HINSTANCE hInstance, LPCSTR lpCursorName);
    HCURSOR LoadCursorW(HINSTANCE hInstance, LPCWSTR lpCursorName);
}
    enum : LPSTR
{
IDI_APPLICATION = cast(LPSTR)32512,
IDC_ARROW = cast(LPSTR)32512,
IDC_CROSS = cast(LPSTR)32515,
}
    enum 
{
CTLCOLOR_MSGBOX = 0,
CTLCOLOR_EDIT = 1,
CTLCOLOR_LISTBOX = 2,
CTLCOLOR_BTN = 3,
CTLCOLOR_DLG = 4,
CTLCOLOR_SCROLLBAR = 5,
CTLCOLOR_STATIC = 6,
CTLCOLOR_MAX = 7,
COLOR_SCROLLBAR = 0,
COLOR_BACKGROUND = 1,
COLOR_ACTIVECAPTION = 2,
COLOR_INACTIVECAPTION = 3,
COLOR_MENU = 4,
COLOR_WINDOW = 5,
COLOR_WINDOWFRAME = 6,
COLOR_MENUTEXT = 7,
COLOR_WINDOWTEXT = 8,
COLOR_CAPTIONTEXT = 9,
COLOR_ACTIVEBORDER = 10,
COLOR_INACTIVEBORDER = 11,
COLOR_APPWORKSPACE = 12,
COLOR_HIGHLIGHT = 13,
COLOR_HIGHLIGHTTEXT = 14,
COLOR_BTNFACE = 15,
COLOR_BTNSHADOW = 16,
COLOR_GRAYTEXT = 17,
COLOR_BTNTEXT = 18,
COLOR_INACTIVECAPTIONTEXT = 19,
COLOR_BTNHIGHLIGHT = 20,
COLOR_3DDKSHADOW = 21,
COLOR_3DLIGHT = 22,
COLOR_INFOTEXT = 23,
COLOR_INFOBK = 24,
COLOR_DESKTOP = COLOR_BACKGROUND,
COLOR_3DFACE = COLOR_BTNFACE,
COLOR_3DSHADOW = COLOR_BTNSHADOW,
COLOR_3DHIGHLIGHT = COLOR_BTNHIGHLIGHT,
COLOR_3DHILIGHT = COLOR_BTNHIGHLIGHT,
COLOR_BTNHILIGHT = COLOR_BTNHIGHLIGHT,
}
    enum : int
{
CW_USEDEFAULT = cast(int)-2147483648u,
}
    enum : HWND
{
HWND_DESKTOP = cast(HWND)0,
}
    export ATOM RegisterClassA(WNDCLASSA* lpWndClass);

    export HWND CreateWindowExA(DWORD dwExStyle, LPCSTR lpClassName, LPCSTR lpWindowName, DWORD dwStyle, int X, int Y, int nWidth, int nHeight, HWND hWndParent, HMENU hMenu, HINSTANCE hInstance, LPVOID lpParam);

    HWND CreateWindowA(LPCSTR lpClassName, LPCSTR lpWindowName, DWORD dwStyle, int X, int Y, int nWidth, int nHeight, HWND hWndParent, HMENU hMenu, HINSTANCE hInstance, LPVOID lpParam)
{
return CreateWindowExA(0,lpClassName,lpWindowName,dwStyle,X,Y,nWidth,nHeight,hWndParent,hMenu,hInstance,lpParam);
}
    struct MSG
{
    HWND hwnd;
    UINT message;
    WPARAM wParam;
    LPARAM lParam;
    DWORD time;
    POINT pt;
}
    alias MSG* PMSG;
    alias MSG* NPMSG;
    alias MSG* LPMSG;
    export 
{
    BOOL GetMessageA(LPMSG lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax);
    BOOL TranslateMessage(MSG* lpMsg);
    LONG DispatchMessageA(MSG* lpMsg);
    BOOL PeekMessageA(MSG* lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax, UINT wRemoveMsg);
    HWND GetFocus();
}
    export DWORD ExpandEnvironmentStringsA(LPCSTR lpSrc, LPSTR lpDst, DWORD nSize);

    export DWORD ExpandEnvironmentStringsW(LPCWSTR lpSrc, LPWSTR lpDst, DWORD nSize);

    export 
{
    BOOL IsValidCodePage(UINT CodePage);
    UINT GetACP();
    UINT GetOEMCP();
    BOOL IsDBCSLeadByte(BYTE TestChar);
    BOOL IsDBCSLeadByteEx(UINT CodePage, BYTE TestChar);
    int MultiByteToWideChar(UINT CodePage, DWORD dwFlags, LPCSTR lpMultiByteStr, int cchMultiByte, LPWSTR lpWideCharStr, int cchWideChar);
    int WideCharToMultiByte(UINT CodePage, DWORD dwFlags, LPCWSTR lpWideCharStr, int cchWideChar, LPSTR lpMultiByteStr, int cchMultiByte, LPCSTR lpDefaultChar, LPBOOL lpUsedDefaultChar);
}
    export HANDLE CreateFileMappingA(HANDLE hFile, LPSECURITY_ATTRIBUTES lpFileMappingAttributes, DWORD flProtect, DWORD dwMaximumSizeHigh, DWORD dwMaximumSizeLow, LPCSTR lpName);

    export HANDLE CreateFileMappingW(HANDLE hFile, LPSECURITY_ATTRIBUTES lpFileMappingAttributes, DWORD flProtect, DWORD dwMaximumSizeHigh, DWORD dwMaximumSizeLow, LPCWSTR lpName);

    export BOOL GetMailslotInfo(HANDLE hMailslot, LPDWORD lpMaxMessageSize, LPDWORD lpNextSize, LPDWORD lpMessageCount, LPDWORD lpReadTimeout);

    export BOOL SetMailslotInfo(HANDLE hMailslot, DWORD lReadTimeout);

    export LPVOID MapViewOfFile(HANDLE hFileMappingObject, DWORD dwDesiredAccess, DWORD dwFileOffsetHigh, DWORD dwFileOffsetLow, DWORD dwNumberOfBytesToMap);

    export LPVOID MapViewOfFileEx(HANDLE hFileMappingObject, DWORD dwDesiredAccess, DWORD dwFileOffsetHigh, DWORD dwFileOffsetLow, DWORD dwNumberOfBytesToMap, LPVOID lpBaseAddress);

    export BOOL FlushViewOfFile(LPCVOID lpBaseAddress, DWORD dwNumberOfBytesToFlush);

    export BOOL UnmapViewOfFile(LPCVOID lpBaseAddress);

    export HGDIOBJ GetStockObject(int);

    export BOOL ShowWindow(HWND hWnd, int nCmdShow);

    enum 
{
WHITE_BRUSH = 0,
LTGRAY_BRUSH = 1,
GRAY_BRUSH = 2,
DKGRAY_BRUSH = 3,
BLACK_BRUSH = 4,
NULL_BRUSH = 5,
HOLLOW_BRUSH = NULL_BRUSH,
WHITE_PEN = 6,
BLACK_PEN = 7,
NULL_PEN = 8,
OEM_FIXED_FONT = 10,
ANSI_FIXED_FONT = 11,
ANSI_VAR_FONT = 12,
SYSTEM_FONT = 13,
DEVICE_DEFAULT_FONT = 14,
DEFAULT_PALETTE = 15,
SYSTEM_FIXED_FONT = 16,
DEFAULT_GUI_FONT = 17,
STOCK_LAST = 17,
}
    enum 
{
SW_HIDE = 0,
SW_SHOWNORMAL = 1,
SW_NORMAL = 1,
SW_SHOWMINIMIZED = 2,
SW_SHOWMAXIMIZED = 3,
SW_MAXIMIZE = 3,
SW_SHOWNOACTIVATE = 4,
SW_SHOW = 5,
SW_MINIMIZE = 6,
SW_SHOWMINNOACTIVE = 7,
SW_SHOWNA = 8,
SW_RESTORE = 9,
SW_SHOWDEFAULT = 10,
SW_MAX = 10,
}
    struct TEXTMETRICA
{
    LONG tmHeight;
    LONG tmAscent;
    LONG tmDescent;
    LONG tmInternalLeading;
    LONG tmExternalLeading;
    LONG tmAveCharWidth;
    LONG tmMaxCharWidth;
    LONG tmWeight;
    LONG tmOverhang;
    LONG tmDigitizedAspectX;
    LONG tmDigitizedAspectY;
    BYTE tmFirstChar;
    BYTE tmLastChar;
    BYTE tmDefaultChar;
    BYTE tmBreakChar;
    BYTE tmItalic;
    BYTE tmUnderlined;
    BYTE tmStruckOut;
    BYTE tmPitchAndFamily;
    BYTE tmCharSet;
}
    export BOOL GetTextMetricsA(HDC, TEXTMETRICA*);

    enum 
{
SB_HORZ = 0,
SB_VERT = 1,
SB_CTL = 2,
SB_BOTH = 3,
}
    enum 
{
SB_LINEUP = 0,
SB_LINELEFT = 0,
SB_LINEDOWN = 1,
SB_LINERIGHT = 1,
SB_PAGEUP = 2,
SB_PAGELEFT = 2,
SB_PAGEDOWN = 3,
SB_PAGERIGHT = 3,
SB_THUMBPOSITION = 4,
SB_THUMBTRACK = 5,
SB_TOP = 6,
SB_LEFT = 6,
SB_BOTTOM = 7,
SB_RIGHT = 7,
SB_ENDSCROLL = 8,
}
    export int SetScrollPos(HWND hWnd, int nBar, int nPos, BOOL bRedraw);

    export int GetScrollPos(HWND hWnd, int nBar);

    export BOOL SetScrollRange(HWND hWnd, int nBar, int nMinPos, int nMaxPos, BOOL bRedraw);

    export BOOL GetScrollRange(HWND hWnd, int nBar, LPINT lpMinPos, LPINT lpMaxPos);

    export BOOL ShowScrollBar(HWND hWnd, int wBar, BOOL bShow);

    export BOOL EnableScrollBar(HWND hWnd, UINT wSBflags, UINT wArrows);

    export BOOL LockWindowUpdate(HWND hWndLock);

    export BOOL ScrollWindow(HWND hWnd, int XAmount, int YAmount, RECT* lpRect, RECT* lpClipRect);

    export BOOL ScrollDC(HDC hDC, int dx, int dy, RECT* lprcScroll, RECT* lprcClip, HRGN hrgnUpdate, LPRECT lprcUpdate);

    export int ScrollWindowEx(HWND hWnd, int dx, int dy, RECT* prcScroll, RECT* prcClip, HRGN hrgnUpdate, LPRECT prcUpdate, UINT flags);

    enum 
{
VK_LBUTTON = 1,
VK_RBUTTON = 2,
VK_CANCEL = 3,
VK_MBUTTON = 4,
VK_BACK = 8,
VK_TAB = 9,
VK_CLEAR = 12,
VK_RETURN = 13,
VK_SHIFT = 16,
VK_CONTROL = 17,
VK_MENU = 18,
VK_PAUSE = 19,
VK_CAPITAL = 20,
VK_ESCAPE = 27,
VK_SPACE = 32,
VK_PRIOR = 33,
VK_NEXT = 34,
VK_END = 35,
VK_HOME = 36,
VK_LEFT = 37,
VK_UP = 38,
VK_RIGHT = 39,
VK_DOWN = 40,
VK_SELECT = 41,
VK_PRINT = 42,
VK_EXECUTE = 43,
VK_SNAPSHOT = 44,
VK_INSERT = 45,
VK_DELETE = 46,
VK_HELP = 47,
VK_LWIN = 91,
VK_RWIN = 92,
VK_APPS = 93,
VK_NUMPAD0 = 96,
VK_NUMPAD1 = 97,
VK_NUMPAD2 = 98,
VK_NUMPAD3 = 99,
VK_NUMPAD4 = 100,
VK_NUMPAD5 = 101,
VK_NUMPAD6 = 102,
VK_NUMPAD7 = 103,
VK_NUMPAD8 = 104,
VK_NUMPAD9 = 105,
VK_MULTIPLY = 106,
VK_ADD = 107,
VK_SEPARATOR = 108,
VK_SUBTRACT = 109,
VK_DECIMAL = 110,
VK_DIVIDE = 111,
VK_F1 = 112,
VK_F2 = 113,
VK_F3 = 114,
VK_F4 = 115,
VK_F5 = 116,
VK_F6 = 117,
VK_F7 = 118,
VK_F8 = 119,
VK_F9 = 120,
VK_F10 = 121,
VK_F11 = 122,
VK_F12 = 123,
VK_F13 = 124,
VK_F14 = 125,
VK_F15 = 126,
VK_F16 = 127,
VK_F17 = 128,
VK_F18 = 129,
VK_F19 = 130,
VK_F20 = 131,
VK_F21 = 132,
VK_F22 = 133,
VK_F23 = 134,
VK_F24 = 135,
VK_NUMLOCK = 144,
VK_SCROLL = 145,
VK_LSHIFT = 160,
VK_RSHIFT = 161,
VK_LCONTROL = 162,
VK_RCONTROL = 163,
VK_LMENU = 164,
VK_RMENU = 165,
VK_PROCESSKEY = 229,
VK_ATTN = 246,
VK_CRSEL = 247,
VK_EXSEL = 248,
VK_EREOF = 249,
VK_PLAY = 250,
VK_ZOOM = 251,
VK_NONAME = 252,
VK_PA1 = 253,
VK_OEM_CLEAR = 254,
}
    export LRESULT SendMessageA(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);

    alias UINT function(HWND, UINT, WPARAM, LPARAM) LPOFNHOOKPROC;
    struct OPENFILENAMEA
{
    DWORD lStructSize;
    HWND hwndOwner;
    HINSTANCE hInstance;
    LPCSTR lpstrFilter;
    LPSTR lpstrCustomFilter;
    DWORD nMaxCustFilter;
    DWORD nFilterIndex;
    LPSTR lpstrFile;
    DWORD nMaxFile;
    LPSTR lpstrFileTitle;
    DWORD nMaxFileTitle;
    LPCSTR lpstrInitialDir;
    LPCSTR lpstrTitle;
    DWORD Flags;
    WORD nFileOffset;
    WORD nFileExtension;
    LPCSTR lpstrDefExt;
    LPARAM lCustData;
    LPOFNHOOKPROC lpfnHook;
    LPCSTR lpTemplateName;
}
    alias OPENFILENAMEA* LPOPENFILENAMEA;
    struct OPENFILENAMEW
{
    DWORD lStructSize;
    HWND hwndOwner;
    HINSTANCE hInstance;
    LPCWSTR lpstrFilter;
    LPWSTR lpstrCustomFilter;
    DWORD nMaxCustFilter;
    DWORD nFilterIndex;
    LPWSTR lpstrFile;
    DWORD nMaxFile;
    LPWSTR lpstrFileTitle;
    DWORD nMaxFileTitle;
    LPCWSTR lpstrInitialDir;
    LPCWSTR lpstrTitle;
    DWORD Flags;
    WORD nFileOffset;
    WORD nFileExtension;
    LPCWSTR lpstrDefExt;
    LPARAM lCustData;
    LPOFNHOOKPROC lpfnHook;
    LPCWSTR lpTemplateName;
}
    alias OPENFILENAMEW* LPOPENFILENAMEW;
    BOOL GetOpenFileNameA(LPOPENFILENAMEA);
    BOOL GetOpenFileNameW(LPOPENFILENAMEW);
    BOOL GetSaveFileNameA(LPOPENFILENAMEA);
    BOOL GetSaveFileNameW(LPOPENFILENAMEW);
    short GetFileTitleA(LPCSTR, LPSTR, WORD);
    short GetFileTitleW(LPCWSTR, LPWSTR, WORD);
    enum 
{
PM_NOREMOVE = 0,
PM_REMOVE = 1,
PM_NOYIELD = 2,
}
    struct BITMAP
{
    LONG bmType;
    LONG bmWidth;
    LONG bmHeight;
    LONG bmWidthBytes;
    WORD bmPlanes;
    WORD bmBitsPixel;
    LPVOID bmBits;
}
    alias BITMAP* PBITMAP;
    alias BITMAP* NPBITMAP;
    alias BITMAP* LPBITMAP;
    export HDC CreateCompatibleDC(HDC);

    export int GetObjectA(HGDIOBJ, int, LPVOID);

    export int GetObjectW(HGDIOBJ, int, LPVOID);

    export BOOL DeleteDC(HDC);

    struct LOGFONTA
{
    LONG lfHeight;
    LONG lfWidth;
    LONG lfEscapement;
    LONG lfOrientation;
    LONG lfWeight;
    BYTE lfItalic;
    BYTE lfUnderline;
    BYTE lfStrikeOut;
    BYTE lfCharSet;
    BYTE lfOutPrecision;
    BYTE lfClipPrecision;
    BYTE lfQuality;
    BYTE lfPitchAndFamily;
    CHAR[32] lfFaceName;
}
    alias LOGFONTA* PLOGFONTA;
    alias LOGFONTA* NPLOGFONTA;
    alias LOGFONTA* LPLOGFONTA;
    export HMENU LoadMenuA(HINSTANCE hInstance, LPCSTR lpMenuName);

    export HMENU LoadMenuW(HINSTANCE hInstance, LPCWSTR lpMenuName);

    export HMENU GetSubMenu(HMENU hMenu, int nPos);

    export HBITMAP LoadBitmapA(HINSTANCE hInstance, LPCSTR lpBitmapName);

    export HBITMAP LoadBitmapW(HINSTANCE hInstance, LPCWSTR lpBitmapName);

    LPSTR MAKEINTRESOURCEA(int i)
{
return cast(LPSTR)cast(DWORD)cast(WORD)i;
}
    export HFONT CreateFontIndirectA(LOGFONTA*);

    export BOOL MessageBeep(UINT uType);

    export int ShowCursor(BOOL bShow);

    export BOOL SetCursorPos(int X, int Y);

    export HCURSOR SetCursor(HCURSOR hCursor);

    export BOOL GetCursorPos(LPPOINT lpPoint);

    export BOOL ClipCursor(RECT* lpRect);

    export BOOL GetClipCursor(LPRECT lpRect);

    export HCURSOR GetCursor();

    export BOOL CreateCaret(HWND hWnd, HBITMAP hBitmap, int nWidth, int nHeight);

    export UINT GetCaretBlinkTime();

    export BOOL SetCaretBlinkTime(UINT uMSeconds);

    export BOOL DestroyCaret();

    export BOOL HideCaret(HWND hWnd);

    export BOOL ShowCaret(HWND hWnd);

    export BOOL SetCaretPos(int X, int Y);

    export BOOL GetCaretPos(LPPOINT lpPoint);

    export BOOL ClientToScreen(HWND hWnd, LPPOINT lpPoint);

    export BOOL ScreenToClient(HWND hWnd, LPPOINT lpPoint);

    export int MapWindowPoints(HWND hWndFrom, HWND hWndTo, LPPOINT lpPoints, UINT cPoints);

    export HWND WindowFromPoint(POINT Point);

    export HWND ChildWindowFromPoint(HWND hWndParent, POINT Point);

    export BOOL TrackPopupMenu(HMENU hMenu, UINT uFlags, int x, int y, int nReserved, HWND hWnd, RECT* prcRect);

    align (2)struct DLGTEMPLATE
{
    DWORD style;
    DWORD dwExtendedStyle;
    WORD cdit;
    short x;
    short y;
    short cx;
    short cy;
}

    alias DLGTEMPLATE* LPDLGTEMPLATEA;
    alias DLGTEMPLATE* LPDLGTEMPLATEW;
    alias LPDLGTEMPLATEA LPDLGTEMPLATE;
    alias DLGTEMPLATE* LPCDLGTEMPLATEA;
    alias DLGTEMPLATE* LPCDLGTEMPLATEW;
    alias LPCDLGTEMPLATEA LPCDLGTEMPLATE;
    export int DialogBoxParamA(HINSTANCE hInstance, LPCSTR lpTemplateName, HWND hWndParent, DLGPROC lpDialogFunc, LPARAM dwInitParam);

    export int DialogBoxIndirectParamA(HINSTANCE hInstance, LPCDLGTEMPLATEA hDialogTemplate, HWND hWndParent, DLGPROC lpDialogFunc, LPARAM dwInitParam);

    enum : DWORD
{
SRCCOPY = cast(DWORD)13369376,
SRCPAINT = cast(DWORD)15597702,
SRCAND = cast(DWORD)8913094,
SRCINVERT = cast(DWORD)6684742,
SRCERASE = cast(DWORD)4457256,
NOTSRCCOPY = cast(DWORD)3342344,
NOTSRCERASE = cast(DWORD)1114278,
MERGECOPY = cast(DWORD)12583114,
MERGEPAINT = cast(DWORD)12255782,
PATCOPY = cast(DWORD)15728673,
PATPAINT = cast(DWORD)16452105,
PATINVERT = cast(DWORD)5898313,
DSTINVERT = cast(DWORD)5570569,
BLACKNESS = cast(DWORD)66,
WHITENESS = cast(DWORD)16711778,
}
    enum 
{
SND_SYNC = 0,
SND_ASYNC = 1,
SND_NODEFAULT = 2,
SND_MEMORY = 4,
SND_LOOP = 8,
SND_NOSTOP = 16,
SND_NOWAIT = 8192,
SND_ALIAS = 65536,
SND_ALIAS_ID = 1114112,
SND_FILENAME = 131072,
SND_RESOURCE = 262148,
SND_PURGE = 64,
SND_APPLICATION = 128,
SND_ALIAS_START = 0,
}
    export BOOL PlaySoundA(LPCSTR pszSound, HMODULE hmod, DWORD fdwSound);

    export BOOL PlaySoundW(LPCWSTR pszSound, HMODULE hmod, DWORD fdwSound);

    export int GetClipBox(HDC, LPRECT);

    export int GetClipRgn(HDC, HRGN);

    export int GetMetaRgn(HDC, HRGN);

    export HGDIOBJ GetCurrentObject(HDC, UINT);

    export BOOL GetCurrentPositionEx(HDC, LPPOINT);

    export int GetDeviceCaps(HDC, int);

    struct LOGPEN
{
    UINT lopnStyle;
    POINT lopnWidth;
    COLORREF lopnColor;
}
    alias LOGPEN* PLOGPEN;
    alias LOGPEN* NPLOGPEN;
    alias LOGPEN* LPLOGPEN;
    enum 
{
PS_SOLID = 0,
PS_DASH = 1,
PS_DOT = 2,
PS_DASHDOT = 3,
PS_DASHDOTDOT = 4,
PS_NULL = 5,
PS_INSIDEFRAME = 6,
PS_USERSTYLE = 7,
PS_ALTERNATE = 8,
PS_STYLE_MASK = 15,
PS_ENDCAP_ROUND = 0,
PS_ENDCAP_SQUARE = 256,
PS_ENDCAP_FLAT = 512,
PS_ENDCAP_MASK = 3840,
PS_JOIN_ROUND = 0,
PS_JOIN_BEVEL = 4096,
PS_JOIN_MITER = 8192,
PS_JOIN_MASK = 61440,
PS_COSMETIC = 0,
PS_GEOMETRIC = 65536,
PS_TYPE_MASK = 983040,
}
    export HPALETTE CreatePalette(LOGPALETTE*);

    export HPEN CreatePen(int, int, COLORREF);

    export HPEN CreatePenIndirect(LOGPEN*);

    export HRGN CreatePolyPolygonRgn(POINT*, INT*, int, int);

    export HBRUSH CreatePatternBrush(HBITMAP);

    export HRGN CreateRectRgn(int, int, int, int);

    export HRGN CreateRectRgnIndirect(RECT*);

    export HRGN CreateRoundRectRgn(int, int, int, int, int, int);

    export BOOL CreateScalableFontResourceA(DWORD, LPCSTR, LPCSTR, LPCSTR);

    export BOOL CreateScalableFontResourceW(DWORD, LPCWSTR, LPCWSTR, LPCWSTR);

    COLORREF RGB(int r, int g, int b)
{
return cast(COLORREF)(cast(BYTE)r | cast(WORD)cast(BYTE)g << 8 | cast(DWORD)cast(BYTE)b << 16);
}
    export BOOL LineTo(HDC, int, int);

    export BOOL DeleteObject(HGDIOBJ);

    export int FillRect(HDC hDC, RECT* lprc, HBRUSH hbr);

    export BOOL EndDialog(HWND hDlg, int nResult);

    export HWND GetDlgItem(HWND hDlg, int nIDDlgItem);

    export BOOL SetDlgItemInt(HWND hDlg, int nIDDlgItem, UINT uValue, BOOL bSigned);

    export UINT GetDlgItemInt(HWND hDlg, int nIDDlgItem, BOOL* lpTranslated, BOOL bSigned);

    export BOOL SetDlgItemTextA(HWND hDlg, int nIDDlgItem, LPCSTR lpString);

    export BOOL SetDlgItemTextW(HWND hDlg, int nIDDlgItem, LPCWSTR lpString);

    export UINT GetDlgItemTextA(HWND hDlg, int nIDDlgItem, LPSTR lpString, int nMaxCount);

    export UINT GetDlgItemTextW(HWND hDlg, int nIDDlgItem, LPWSTR lpString, int nMaxCount);

    export BOOL CheckDlgButton(HWND hDlg, int nIDButton, UINT uCheck);

    export BOOL CheckRadioButton(HWND hDlg, int nIDFirstButton, int nIDLastButton, int nIDCheckButton);

    export UINT IsDlgButtonChecked(HWND hDlg, int nIDButton);

    export HWND SetFocus(HWND hWnd);

    extern (C) 
{
    export int wsprintfA(LPSTR, LPCSTR,...);

    export int wsprintfW(LPWSTR, LPCWSTR,...);

}
    enum : uint
{
INFINITE = (uint).max,
WAIT_OBJECT_0 = 0,
WAIT_ABANDONED_0 = 128,
WAIT_TIMEOUT = 258,
WAIT_IO_COMPLETION = 192,
WAIT_ABANDONED = 128,
WAIT_FAILED = (uint).max,
}
    export HANDLE CreateSemaphoreA(LPSECURITY_ATTRIBUTES lpSemaphoreAttributes, LONG lInitialCount, LONG lMaximumCount, LPCTSTR lpName);

    export HANDLE OpenSemaphoreA(DWORD dwDesiredAccess, BOOL bInheritHandle, LPCTSTR lpName);

    export BOOL ReleaseSemaphore(HANDLE hSemaphore, LONG lReleaseCount, LPLONG lpPreviousCount);

    struct COORD
{
    SHORT X;
    SHORT Y;
}
    alias COORD* PCOORD;
    struct SMALL_RECT
{
    SHORT Left;
    SHORT Top;
    SHORT Right;
    SHORT Bottom;
}
    alias SMALL_RECT* PSMALL_RECT;
    struct KEY_EVENT_RECORD
{
    BOOL bKeyDown;
    WORD wRepeatCount;
    WORD wVirtualKeyCode;
    WORD wVirtualScanCode;
    union
{
WCHAR UnicodeChar;
CHAR AsciiChar;
}
    DWORD dwControlKeyState;
}
    alias KEY_EVENT_RECORD* PKEY_EVENT_RECORD;
    enum 
{
RIGHT_ALT_PRESSED = 1,
LEFT_ALT_PRESSED = 2,
RIGHT_CTRL_PRESSED = 4,
LEFT_CTRL_PRESSED = 8,
SHIFT_PRESSED = 16,
NUMLOCK_ON = 32,
SCROLLLOCK_ON = 64,
CAPSLOCK_ON = 128,
ENHANCED_KEY = 256,
}
    struct MOUSE_EVENT_RECORD
{
    COORD dwMousePosition;
    DWORD dwButtonState;
    DWORD dwControlKeyState;
    DWORD dwEventFlags;
}
    alias MOUSE_EVENT_RECORD* PMOUSE_EVENT_RECORD;
    enum 
{
FROM_LEFT_1ST_BUTTON_PRESSED = 1,
RIGHTMOST_BUTTON_PRESSED = 2,
FROM_LEFT_2ND_BUTTON_PRESSED = 4,
FROM_LEFT_3RD_BUTTON_PRESSED = 8,
FROM_LEFT_4TH_BUTTON_PRESSED = 16,
}
    enum 
{
MOUSE_MOVED = 1,
DOUBLE_CLICK = 2,
}
    struct WINDOW_BUFFER_SIZE_RECORD
{
    COORD dwSize;
}
    alias WINDOW_BUFFER_SIZE_RECORD* PWINDOW_BUFFER_SIZE_RECORD;
    struct MENU_EVENT_RECORD
{
    UINT dwCommandId;
}
    alias MENU_EVENT_RECORD* PMENU_EVENT_RECORD;
    struct FOCUS_EVENT_RECORD
{
    BOOL bSetFocus;
}
    alias FOCUS_EVENT_RECORD* PFOCUS_EVENT_RECORD;
    struct INPUT_RECORD
{
    WORD EventType;
    union
{
KEY_EVENT_RECORD KeyEvent;
MOUSE_EVENT_RECORD MouseEvent;
WINDOW_BUFFER_SIZE_RECORD WindowBufferSizeEvent;
MENU_EVENT_RECORD MenuEvent;
FOCUS_EVENT_RECORD FocusEvent;
}
}
    alias INPUT_RECORD* PINPUT_RECORD;
    enum 
{
KEY_EVENT = 1,
MOUSE_EVENT = 2,
WINDOW_BUFFER_SIZE_EVENT = 4,
MENU_EVENT = 8,
FOCUS_EVENT = 16,
}
    struct CHAR_INFO
{
    union
{
WCHAR UnicodeChar;
CHAR AsciiChar;
}
    WORD Attributes;
}
    alias CHAR_INFO* PCHAR_INFO;
    enum 
{
FOREGROUND_BLUE = 1,
FOREGROUND_GREEN = 2,
FOREGROUND_RED = 4,
FOREGROUND_INTENSITY = 8,
BACKGROUND_BLUE = 16,
BACKGROUND_GREEN = 32,
BACKGROUND_RED = 64,
BACKGROUND_INTENSITY = 128,
}
    struct CONSOLE_SCREEN_BUFFER_INFO
{
    COORD dwSize;
    COORD dwCursorPosition;
    WORD wAttributes;
    SMALL_RECT srWindow;
    COORD dwMaximumWindowSize;
}
    alias CONSOLE_SCREEN_BUFFER_INFO* PCONSOLE_SCREEN_BUFFER_INFO;
    struct CONSOLE_CURSOR_INFO
{
    DWORD dwSize;
    BOOL bVisible;
}
    alias CONSOLE_CURSOR_INFO* PCONSOLE_CURSOR_INFO;
    enum 
{
ENABLE_PROCESSED_INPUT = 1,
ENABLE_LINE_INPUT = 2,
ENABLE_ECHO_INPUT = 4,
ENABLE_WINDOW_INPUT = 8,
ENABLE_MOUSE_INPUT = 16,
}
    enum 
{
ENABLE_PROCESSED_OUTPUT = 1,
ENABLE_WRAP_AT_EOL_OUTPUT = 2,
}
    BOOL PeekConsoleInputA(HANDLE hConsoleInput, PINPUT_RECORD lpBuffer, DWORD nLength, LPDWORD lpNumberOfEventsRead);
    BOOL PeekConsoleInputW(HANDLE hConsoleInput, PINPUT_RECORD lpBuffer, DWORD nLength, LPDWORD lpNumberOfEventsRead);
    BOOL ReadConsoleInputA(HANDLE hConsoleInput, PINPUT_RECORD lpBuffer, DWORD nLength, LPDWORD lpNumberOfEventsRead);
    BOOL ReadConsoleInputW(HANDLE hConsoleInput, PINPUT_RECORD lpBuffer, DWORD nLength, LPDWORD lpNumberOfEventsRead);
    BOOL WriteConsoleInputA(HANDLE hConsoleInput, in INPUT_RECORD* lpBuffer, DWORD nLength, LPDWORD lpNumberOfEventsWritten);
    BOOL WriteConsoleInputW(HANDLE hConsoleInput, in INPUT_RECORD* lpBuffer, DWORD nLength, LPDWORD lpNumberOfEventsWritten);
    BOOL ReadConsoleOutputA(HANDLE hConsoleOutput, PCHAR_INFO lpBuffer, COORD dwBufferSize, COORD dwBufferCoord, PSMALL_RECT lpReadRegion);
    BOOL ReadConsoleOutputW(HANDLE hConsoleOutput, PCHAR_INFO lpBuffer, COORD dwBufferSize, COORD dwBufferCoord, PSMALL_RECT lpReadRegion);
    BOOL WriteConsoleOutputA(HANDLE hConsoleOutput, in CHAR_INFO* lpBuffer, COORD dwBufferSize, COORD dwBufferCoord, PSMALL_RECT lpWriteRegion);
    BOOL WriteConsoleOutputW(HANDLE hConsoleOutput, in CHAR_INFO* lpBuffer, COORD dwBufferSize, COORD dwBufferCoord, PSMALL_RECT lpWriteRegion);
    BOOL ReadConsoleOutputCharacterA(HANDLE hConsoleOutput, LPSTR lpCharacter, DWORD nLength, COORD dwReadCoord, LPDWORD lpNumberOfCharsRead);
    BOOL ReadConsoleOutputCharacterW(HANDLE hConsoleOutput, LPWSTR lpCharacter, DWORD nLength, COORD dwReadCoord, LPDWORD lpNumberOfCharsRead);
    BOOL ReadConsoleOutputAttribute(HANDLE hConsoleOutput, LPWORD lpAttribute, DWORD nLength, COORD dwReadCoord, LPDWORD lpNumberOfAttrsRead);
    BOOL WriteConsoleOutputCharacterA(HANDLE hConsoleOutput, LPCSTR lpCharacter, DWORD nLength, COORD dwWriteCoord, LPDWORD lpNumberOfCharsWritten);
    BOOL WriteConsoleOutputCharacterW(HANDLE hConsoleOutput, LPCWSTR lpCharacter, DWORD nLength, COORD dwWriteCoord, LPDWORD lpNumberOfCharsWritten);
    BOOL WriteConsoleOutputAttribute(HANDLE hConsoleOutput, in WORD* lpAttribute, DWORD nLength, COORD dwWriteCoord, LPDWORD lpNumberOfAttrsWritten);
    BOOL FillConsoleOutputCharacterA(HANDLE hConsoleOutput, CHAR cCharacter, DWORD nLength, COORD dwWriteCoord, LPDWORD lpNumberOfCharsWritten);
    BOOL FillConsoleOutputCharacterW(HANDLE hConsoleOutput, WCHAR cCharacter, DWORD nLength, COORD dwWriteCoord, LPDWORD lpNumberOfCharsWritten);
    BOOL FillConsoleOutputAttribute(HANDLE hConsoleOutput, WORD wAttribute, DWORD nLength, COORD dwWriteCoord, LPDWORD lpNumberOfAttrsWritten);
    BOOL GetConsoleMode(HANDLE hConsoleHandle, LPDWORD lpMode);
    BOOL GetNumberOfConsoleInputEvents(HANDLE hConsoleInput, LPDWORD lpNumberOfEvents);
    BOOL GetConsoleScreenBufferInfo(HANDLE hConsoleOutput, PCONSOLE_SCREEN_BUFFER_INFO lpConsoleScreenBufferInfo);
    COORD GetLargestConsoleWindowSize(HANDLE hConsoleOutput);
    BOOL GetConsoleCursorInfo(HANDLE hConsoleOutput, PCONSOLE_CURSOR_INFO lpConsoleCursorInfo);
    BOOL GetNumberOfConsoleMouseButtons(LPDWORD lpNumberOfMouseButtons);
    BOOL SetConsoleMode(HANDLE hConsoleHandle, DWORD dwMode);
    BOOL SetConsoleActiveScreenBuffer(HANDLE hConsoleOutput);
    BOOL FlushConsoleInputBuffer(HANDLE hConsoleInput);
    BOOL SetConsoleScreenBufferSize(HANDLE hConsoleOutput, COORD dwSize);
    BOOL SetConsoleCursorPosition(HANDLE hConsoleOutput, COORD dwCursorPosition);
    BOOL SetConsoleCursorInfo(HANDLE hConsoleOutput, in CONSOLE_CURSOR_INFO* lpConsoleCursorInfo);
    BOOL ScrollConsoleScreenBufferA(HANDLE hConsoleOutput, in SMALL_RECT* lpScrollRectangle, in SMALL_RECT* lpClipRectangle, COORD dwDestinationOrigin, in CHAR_INFO* lpFill);
    BOOL ScrollConsoleScreenBufferW(HANDLE hConsoleOutput, in SMALL_RECT* lpScrollRectangle, in SMALL_RECT* lpClipRectangle, COORD dwDestinationOrigin, in CHAR_INFO* lpFill);
    BOOL SetConsoleWindowInfo(HANDLE hConsoleOutput, BOOL bAbsolute, in SMALL_RECT* lpConsoleWindow);
    BOOL SetConsoleTextAttribute(HANDLE hConsoleOutput, WORD wAttributes);
    alias BOOL function(DWORD CtrlType) PHANDLER_ROUTINE;
    BOOL SetConsoleCtrlHandler(PHANDLER_ROUTINE HandlerRoutine, BOOL Add);
    BOOL GenerateConsoleCtrlEvent(DWORD dwCtrlEvent, DWORD dwProcessGroupId);
    BOOL AllocConsole();
    BOOL FreeConsole();
    DWORD GetConsoleTitleA(LPSTR lpConsoleTitle, DWORD nSize);
    DWORD GetConsoleTitleW(LPWSTR lpConsoleTitle, DWORD nSize);
    BOOL SetConsoleTitleA(LPCSTR lpConsoleTitle);
    BOOL SetConsoleTitleW(LPCWSTR lpConsoleTitle);
    BOOL ReadConsoleA(HANDLE hConsoleInput, LPVOID lpBuffer, DWORD nNumberOfCharsToRead, LPDWORD lpNumberOfCharsRead, LPVOID lpReserved);
    BOOL ReadConsoleW(HANDLE hConsoleInput, LPVOID lpBuffer, DWORD nNumberOfCharsToRead, LPDWORD lpNumberOfCharsRead, LPVOID lpReserved);
    BOOL WriteConsoleA(HANDLE hConsoleOutput, in void* lpBuffer, DWORD nNumberOfCharsToWrite, LPDWORD lpNumberOfCharsWritten, LPVOID lpReserved);
    BOOL WriteConsoleW(HANDLE hConsoleOutput, in void* lpBuffer, DWORD nNumberOfCharsToWrite, LPDWORD lpNumberOfCharsWritten, LPVOID lpReserved);
    HANDLE CreateConsoleScreenBuffer(DWORD dwDesiredAccess, DWORD dwShareMode, in SECURITY_ATTRIBUTES* lpSecurityAttributes, DWORD dwFlags, LPVOID lpScreenBufferData);
    UINT GetConsoleCP();
    BOOL SetConsoleCP(UINT wCodePageID);
    UINT GetConsoleOutputCP();
    BOOL SetConsoleOutputCP(UINT wCodePageID);
    enum 
{
CONSOLE_TEXTMODE_BUFFER = 1,
}
    enum 
{
SM_CXSCREEN = 0,
SM_CYSCREEN = 1,
SM_CXVSCROLL = 2,
SM_CYHSCROLL = 3,
SM_CYCAPTION = 4,
SM_CXBORDER = 5,
SM_CYBORDER = 6,
SM_CXDLGFRAME = 7,
SM_CYDLGFRAME = 8,
SM_CYVTHUMB = 9,
SM_CXHTHUMB = 10,
SM_CXICON = 11,
SM_CYICON = 12,
SM_CXCURSOR = 13,
SM_CYCURSOR = 14,
SM_CYMENU = 15,
SM_CXFULLSCREEN = 16,
SM_CYFULLSCREEN = 17,
SM_CYKANJIWINDOW = 18,
SM_MOUSEPRESENT = 19,
SM_CYVSCROLL = 20,
SM_CXHSCROLL = 21,
SM_DEBUG = 22,
SM_SWAPBUTTON = 23,
SM_RESERVED1 = 24,
SM_RESERVED2 = 25,
SM_RESERVED3 = 26,
SM_RESERVED4 = 27,
SM_CXMIN = 28,
SM_CYMIN = 29,
SM_CXSIZE = 30,
SM_CYSIZE = 31,
SM_CXFRAME = 32,
SM_CYFRAME = 33,
SM_CXMINTRACK = 34,
SM_CYMINTRACK = 35,
SM_CXDOUBLECLK = 36,
SM_CYDOUBLECLK = 37,
SM_CXICONSPACING = 38,
SM_CYICONSPACING = 39,
SM_MENUDROPALIGNMENT = 40,
SM_PENWINDOWS = 41,
SM_DBCSENABLED = 42,
SM_CMOUSEBUTTONS = 43,
SM_CXFIXEDFRAME = SM_CXDLGFRAME,
SM_CYFIXEDFRAME = SM_CYDLGFRAME,
SM_CXSIZEFRAME = SM_CXFRAME,
SM_CYSIZEFRAME = SM_CYFRAME,
SM_SECURE = 44,
SM_CXEDGE = 45,
SM_CYEDGE = 46,
SM_CXMINSPACING = 47,
SM_CYMINSPACING = 48,
SM_CXSMICON = 49,
SM_CYSMICON = 50,
SM_CYSMCAPTION = 51,
SM_CXSMSIZE = 52,
SM_CYSMSIZE = 53,
SM_CXMENUSIZE = 54,
SM_CYMENUSIZE = 55,
SM_ARRANGE = 56,
SM_CXMINIMIZED = 57,
SM_CYMINIMIZED = 58,
SM_CXMAXTRACK = 59,
SM_CYMAXTRACK = 60,
SM_CXMAXIMIZED = 61,
SM_CYMAXIMIZED = 62,
SM_NETWORK = 63,
SM_CLEANBOOT = 67,
SM_CXDRAG = 68,
SM_CYDRAG = 69,
SM_SHOWSOUNDS = 70,
SM_CXMENUCHECK = 71,
SM_CYMENUCHECK = 72,
SM_SLOWMACHINE = 73,
SM_MIDEASTENABLED = 74,
SM_CMETRICS = 75,
}
    int GetSystemMetrics(int nIndex);
    enum : DWORD
{
STILL_ACTIVE = 259,
}
    DWORD TlsAlloc();
    LPVOID TlsGetValue(DWORD);
    BOOL TlsSetValue(DWORD, LPVOID);
    BOOL TlsFree(DWORD);
}
