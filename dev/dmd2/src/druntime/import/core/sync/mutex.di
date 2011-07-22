// D import file generated from 'src\core\sync\mutex.d'
module core.sync.mutex;
public import core.sync.exception;

version (Win32)
{
    private import core.sys.windows.windows;

}
else
{
    version (Posix)
{
    private import core.sys.posix.pthread;

}
}
class Mutex : Object.Monitor
{
    this();
    this(Object o)
in
{
assert(o.__monitor is null);
}
body
{
this();
o.__monitor = &m_proxy;
}
    ~this();
    void lock();
    void unlock();
    bool tryLock();
    private 
{
    version (Win32)
{
    CRITICAL_SECTION m_hndl;
}
else
{
    version (Posix)
{
    pthread_mutex_t m_hndl;
}
}
    struct MonitorProxy
{
    Object.Monitor link;
}
    MonitorProxy m_proxy;
    package version (Posix)
{
    pthread_mutex_t* handleAddr()
{
return &m_hndl;
}
}

}
}
version (unittest)
{
    private import core.thread;

    }
