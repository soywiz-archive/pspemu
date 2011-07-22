// D import file generated from 'src\core\sys\windows\threadaux.d'
module core.sys.windows.threadaux;
version (Windows)
{
    import core.sys.windows.windows;
    import core.stdc.stdlib;
    public import core.thread;

    extern (Windows) HANDLE OpenThread(DWORD dwDesiredAccess, BOOL bInheritHandle, DWORD dwThreadId);

    extern (C) extern __gshared int _tls_index;


    private 
{
    struct thread_aux
{
    enum SystemProcessInformation = 5;
    enum STATUS_INFO_LENGTH_MISMATCH = -1073741820u;
    struct _SYSTEM_PROCESS_INFORMATION
{
    int NextEntryOffset;
    int NumberOfThreads;
    int[15] fill1;
    int ProcessId;
    int[28] fill2;
}
    struct _SYSTEM_THREAD_INFORMATION
{
    int[8] fill1;
    int ProcessId;
    int ThreadId;
    int[6] fill2;
}
    extern (Windows) alias HRESULT fnNtQuerySystemInformation(uint SystemInformationClass, void* info, uint infoLength, uint* ReturnLength);

    enum ThreadBasicInformation = 0;
    struct THREAD_BASIC_INFORMATION
{
    int ExitStatus;
    void** TebBaseAddress;
    int ProcessId;
    int ThreadId;
    int AffinityMask;
    int Priority;
    int BasePriority;
}
    extern (Windows) alias int fnNtQueryInformationThread(HANDLE ThreadHandle, uint ThreadInformationClass, void* buf, uint size, uint* ReturnLength);

    enum SYNCHRONIZE = 1048576;
    enum THREAD_GET_CONTEXT = 8;
    enum THREAD_QUERY_INFORMATION = 64;
    enum THREAD_SUSPEND_RESUME = 2;
    static void** getTEB(HANDLE hnd)
{
HANDLE nthnd = GetModuleHandleA("NTDLL");
assert(nthnd,"cannot get module handle for ntdll");
fnNtQueryInformationThread* fn = cast(fnNtQueryInformationThread*)GetProcAddress(nthnd,"NtQueryInformationThread");
assert(fn,"cannot find NtQueryInformationThread in ntdll");
THREAD_BASIC_INFORMATION tbi;
int Status = (*fn)(hnd,ThreadBasicInformation,&tbi,tbi.sizeof,null);
assert(Status == 0);
return tbi.TebBaseAddress;
}

    static void** getTEB(uint id)
{
HANDLE hnd = OpenThread(THREAD_QUERY_INFORMATION,FALSE,id);
assert(hnd,"OpenThread failed");
void** teb = getTEB(hnd);
CloseHandle(hnd);
return teb;
}

    static void** getTEB();

    static void* getThreadStackBottom(HANDLE hnd)
{
void** teb = getTEB(hnd);
return teb[1];
}

    static void* getThreadStackBottom(uint id)
{
void** teb = getTEB(id);
return teb[1];
}

    static HANDLE OpenThreadHandle(uint id)
{
return OpenThread(SYNCHRONIZE | THREAD_GET_CONTEXT | THREAD_QUERY_INFORMATION | THREAD_SUSPEND_RESUME,FALSE,id);
}

    static bool enumProcessThreads(uint procid, bool function(uint id, void* context) dg, void* context);

    static bool enumProcessThreads(bool function(uint id, void* context) dg, void* context)
{
return enumProcessThreads(GetCurrentProcessId(),dg,context);
}

    extern (C) alias void function() externCVoidFunc;

    static void impersonate_thread(uint id, externCVoidFunc fn);

}
    public 
{
    alias thread_aux.getTEB getTEB;
    alias thread_aux.getThreadStackBottom getThreadStackBottom;
    alias thread_aux.OpenThreadHandle OpenThreadHandle;
    alias thread_aux.enumProcessThreads enumProcessThreads;
    void* GetTlsDataAddress(HANDLE hnd);
    void* GetTlsDataAddress(uint id)
{
HANDLE hnd = OpenThread(thread_aux.THREAD_QUERY_INFORMATION,FALSE,id);
assert(hnd,"OpenThread failed");
void* tls = GetTlsDataAddress(hnd);
CloseHandle(hnd);
return tls;
}
    void thread_moduleTlsCtor(uint id)
{
thread_aux.impersonate_thread(id,&_moduleTlsCtor);
}
    void thread_moduleTlsDtor(uint id)
{
thread_aux.impersonate_thread(id,&_moduleTlsDtor);
}
}
}
}
