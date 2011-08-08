// D import file generated from 'src\core\sys\posix\pthread.d'
module core.sys.posix.pthread;
private import core.sys.posix.config;

public import core.sys.posix.sys.types;

public import core.sys.posix.sched;

public import core.sys.posix.time;

import core.stdc.stdint;
extern (C) 
{
    version (linux)
{
    enum 
{
PTHREAD_CANCEL_ENABLE,
PTHREAD_CANCEL_DISABLE,
}
    enum 
{
PTHREAD_CANCEL_DEFERRED,
PTHREAD_CANCEL_ASYNCHRONOUS,
}
    enum PTHREAD_CANCELED = cast(void*)-1;
    enum 
{
PTHREAD_CREATE_JOINABLE,
PTHREAD_CREATE_DETACHED,
}
    enum 
{
PTHREAD_INHERIT_SCHED,
PTHREAD_EXPLICIT_SCHED,
}
    enum PTHREAD_ONCE_INIT = 0;
    enum 
{
PTHREAD_PROCESS_PRIVATE,
PTHREAD_PROCESS_SHARED,
}
}
else
{
    version (OSX)
{
    enum 
{
PTHREAD_CANCEL_ENABLE = 1,
PTHREAD_CANCEL_DISABLE = 0,
}
    enum 
{
PTHREAD_CANCEL_DEFERRED = 2,
PTHREAD_CANCEL_ASYNCHRONOUS = 0,
}
    enum PTHREAD_CANCELED = cast(void*)-1;
    enum 
{
PTHREAD_CREATE_JOINABLE = 1,
PTHREAD_CREATE_DETACHED = 2,
}
    enum 
{
PTHREAD_INHERIT_SCHED = 1,
PTHREAD_EXPLICIT_SCHED = 2,
}
    enum PTHREAD_ONCE_INIT = 0;
    enum 
{
PTHREAD_PROCESS_PRIVATE = 2,
PTHREAD_PROCESS_SHARED = 1,
}
}
else
{
    version (FreeBSD)
{
    enum 
{
PTHREAD_DETACHED = 1,
PTHREAD_INHERIT_SCHED = 4,
PTHREAD_NOFLOAT = 8,
PTHREAD_CREATE_DETACHED = PTHREAD_DETACHED,
PTHREAD_CREATE_JOINABLE = 0,
PTHREAD_EXPLICIT_SCHED = 0,
}
    enum 
{
PTHREAD_PROCESS_PRIVATE = 0,
PTHREAD_PROCESS_SHARED = 1,
}
    enum 
{
PTHREAD_CANCEL_ENABLE = 0,
PTHREAD_CANCEL_DISABLE = 1,
PTHREAD_CANCEL_DEFERRED = 0,
PTHREAD_CANCEL_ASYNCHRONOUS = 2,
}
    enum PTHREAD_CANCELED = cast(void*)-1;
    enum PTHREAD_NEEDS_INIT = 0;
    enum PTHREAD_DONE_INIT = 1;
    enum PTHREAD_MUTEX_INITIALIZER = null;
    enum PTHREAD_ADAPTIVE_MUTEX_INITIALIZER_NP = null;
    enum PTHREAD_COND_INITIALIZER = null;
    enum PTHREAD_RWLOCK_INITIALIZER = null;
}
}
}
    version (Posix)
{
    int pthread_atfork(void function(), void function(), void function());
    int pthread_attr_destroy(pthread_attr_t*);
    int pthread_attr_getdetachstate(in pthread_attr_t*, int*);
    int pthread_attr_getschedparam(in pthread_attr_t*, sched_param*);
    int pthread_attr_init(pthread_attr_t*);
    int pthread_attr_setdetachstate(pthread_attr_t*, int);
    int pthread_attr_setschedparam(in pthread_attr_t*, sched_param*);
    int pthread_cancel(pthread_t);
}
    version (linux)
{
    alias void function(void*) _pthread_cleanup_routine;
    struct _pthread_cleanup_buffer
{
    _pthread_cleanup_routine __routine;
    void* __arg;
    int __canceltype;
    _pthread_cleanup_buffer* __prev;
}
    void _pthread_cleanup_push(_pthread_cleanup_buffer*, _pthread_cleanup_routine, void*);
    void _pthread_cleanup_pop(_pthread_cleanup_buffer*, int);
    struct pthread_cleanup
{
    _pthread_cleanup_buffer buffer = void;
    template push()
{
void push(_pthread_cleanup_routine routine, void* arg)
{
_pthread_cleanup_push(&buffer,routine,arg);
}
}
    template pop()
{
void pop(int execute)
{
_pthread_cleanup_pop(&buffer,execute);
}
}
}
}
else
{
    version (OSX)
{
    alias void function(void*) _pthread_cleanup_routine;
    struct _pthread_cleanup_buffer
{
    _pthread_cleanup_routine __routine;
    void* __arg;
    _pthread_cleanup_buffer* __next;
}
    struct pthread_cleanup
{
    _pthread_cleanup_buffer buffer = void;
    template push()
{
void push(_pthread_cleanup_routine routine, void* arg)
{
pthread_t self = pthread_self();
buffer.__routine = routine;
buffer.__arg = arg;
buffer.__next = cast(_pthread_cleanup_buffer*)self.__cleanup_stack;
self.__cleanup_stack = cast(pthread_handler_rec*)&buffer;
}
}
    template pop()
{
void pop(int execute)
{
pthread_t self = pthread_self();
self.__cleanup_stack = cast(pthread_handler_rec*)buffer.__next;
if (execute)
{
buffer.__routine(buffer.__arg);
}
}
}
}
}
else
{
    version (FreeBSD)
{
    alias void function(void*) _pthread_cleanup_routine;
    struct _pthread_cleanup_info
{
    uintptr_t[8] pthread_cleanup_pad;
}
    struct pthread_cleanup
{
    _pthread_cleanup_info __cleanup_info__ = void;
    template push()
{
void push(_pthread_cleanup_routine cleanup_routine, void* cleanup_arg)
{
__pthread_cleanup_push_imp(cleanup_routine,cleanup_arg,&__cleanup_info__);
}
}
    template pop()
{
void pop(int execute)
{
__pthread_cleanup_pop_imp(execute);
}
}
}
    void __pthread_cleanup_push_imp(_pthread_cleanup_routine, void*, _pthread_cleanup_info*);
    void __pthread_cleanup_pop_imp(int);
}
else
{
    version (Posix)
{
    void pthread_cleanup_push(void function(void*), void*);
    void pthread_cleanup_pop(int);
}
}
}
}
    version (Posix)
{
    int pthread_cond_broadcast(pthread_cond_t*);
    int pthread_cond_destroy(pthread_cond_t*);
    int pthread_cond_init(in pthread_cond_t*, pthread_condattr_t*);
    int pthread_cond_signal(pthread_cond_t*);
    int pthread_cond_timedwait(pthread_cond_t*, pthread_mutex_t*, in timespec*);
    int pthread_cond_wait(pthread_cond_t*, pthread_mutex_t*);
    int pthread_condattr_destroy(pthread_condattr_t*);
    int pthread_condattr_init(pthread_condattr_t*);
    int pthread_create(pthread_t*, in pthread_attr_t*, void* function(void*), void*);
    int pthread_detach(pthread_t);
    int pthread_equal(pthread_t, pthread_t);
    void pthread_exit(void*);
    void* pthread_getspecific(pthread_key_t);
    int pthread_join(pthread_t, void**);
    int pthread_key_create(pthread_key_t*, void function(void*));
    int pthread_key_delete(pthread_key_t);
    int pthread_mutex_destroy(pthread_mutex_t*);
    int pthread_mutex_init(pthread_mutex_t*, pthread_mutexattr_t*);
    int pthread_mutex_lock(pthread_mutex_t*);
    int pthread_mutex_trylock(pthread_mutex_t*);
    int pthread_mutex_unlock(pthread_mutex_t*);
    int pthread_mutexattr_destroy(pthread_mutexattr_t*);
    int pthread_mutexattr_init(pthread_mutexattr_t*);
    int pthread_once(pthread_once_t*, void function());
    int pthread_rwlock_destroy(pthread_rwlock_t*);
    int pthread_rwlock_init(in pthread_rwlock_t*, pthread_rwlockattr_t*);
    int pthread_rwlock_rdlock(pthread_rwlock_t*);
    int pthread_rwlock_tryrdlock(pthread_rwlock_t*);
    int pthread_rwlock_trywrlock(pthread_rwlock_t*);
    int pthread_rwlock_unlock(pthread_rwlock_t*);
    int pthread_rwlock_wrlock(pthread_rwlock_t*);
    int pthread_rwlockattr_destroy(pthread_rwlockattr_t*);
    int pthread_rwlockattr_init(pthread_rwlockattr_t*);
    pthread_t pthread_self();
    int pthread_setcancelstate(int, int*);
    int pthread_setcanceltype(int, int*);
    int pthread_setspecific(pthread_key_t, in void*);
    void pthread_testcancel();
}
    version (linux)
{
    enum PTHREAD_BARRIER_SERIAL_THREAD = -1;
    int pthread_barrier_destroy(pthread_barrier_t*);
    int pthread_barrier_init(pthread_barrier_t*, in pthread_barrierattr_t*, uint);
    int pthread_barrier_wait(pthread_barrier_t*);
    int pthread_barrierattr_destroy(pthread_barrierattr_t*);
    int pthread_barrierattr_getpshared(in pthread_barrierattr_t*, int*);
    int pthread_barrierattr_init(pthread_barrierattr_t*);
    int pthread_barrierattr_setpshared(pthread_barrierattr_t*, int);
}
else
{
    version (FreeBSD)
{
    enum PTHREAD_BARRIER_SERIAL_THREAD = -1;
    int pthread_barrier_destroy(pthread_barrier_t*);
    int pthread_barrier_init(pthread_barrier_t*, in pthread_barrierattr_t*, uint);
    int pthread_barrier_wait(pthread_barrier_t*);
    int pthread_barrierattr_destroy(pthread_barrierattr_t*);
    int pthread_barrierattr_getpshared(in pthread_barrierattr_t*, int*);
    int pthread_barrierattr_init(pthread_barrierattr_t*);
    int pthread_barrierattr_setpshared(pthread_barrierattr_t*, int);
}
}
    version (linux)
{
    int pthread_spin_destroy(pthread_spinlock_t*);
    int pthread_spin_init(pthread_spinlock_t*, int);
    int pthread_spin_lock(pthread_spinlock_t*);
    int pthread_spin_trylock(pthread_spinlock_t*);
    int pthread_spin_unlock(pthread_spinlock_t*);
}
else
{
    version (FreeBSD)
{
    int pthread_spin_init(pthread_spinlock_t*, int);
    int pthread_spin_destroy(pthread_spinlock_t*);
    int pthread_spin_lock(pthread_spinlock_t*);
    int pthread_spin_trylock(pthread_spinlock_t*);
    int pthread_spin_unlock(pthread_spinlock_t*);
}
}
    version (linux)
{
    enum PTHREAD_MUTEX_NORMAL = 0;
    enum PTHREAD_MUTEX_RECURSIVE = 1;
    enum PTHREAD_MUTEX_ERRORCHECK = 2;
    enum PTHREAD_MUTEX_DEFAULT = PTHREAD_MUTEX_NORMAL;
    int pthread_attr_getguardsize(in pthread_attr_t*, size_t*);
    int pthread_attr_setguardsize(pthread_attr_t*, size_t);
    int pthread_getconcurrency();
    int pthread_mutexattr_gettype(in pthread_mutexattr_t*, int*);
    int pthread_mutexattr_settype(pthread_mutexattr_t*, int);
    int pthread_setconcurrency(int);
}
else
{
    version (OSX)
{
    enum PTHREAD_MUTEX_NORMAL = 0;
    enum PTHREAD_MUTEX_ERRORCHECK = 1;
    enum PTHREAD_MUTEX_RECURSIVE = 2;
    enum PTHREAD_MUTEX_DEFAULT = PTHREAD_MUTEX_NORMAL;
    int pthread_attr_getguardsize(in pthread_attr_t*, size_t*);
    int pthread_attr_setguardsize(pthread_attr_t*, size_t);
    int pthread_getconcurrency();
    int pthread_mutexattr_gettype(in pthread_mutexattr_t*, int*);
    int pthread_mutexattr_settype(pthread_mutexattr_t*, int);
    int pthread_setconcurrency(int);
}
else
{
    version (FreeBSD)
{
    enum 
{
PTHREAD_MUTEX_ERRORCHECK = 1,
PTHREAD_MUTEX_RECURSIVE = 2,
PTHREAD_MUTEX_NORMAL = 3,
PTHREAD_MUTEX_ADAPTIVE_NP = 4,
PTHREAD_MUTEX_TYPE_MAX,
}
    enum PTHREAD_MUTEX_DEFAULT = PTHREAD_MUTEX_ERRORCHECK;
    int pthread_attr_getguardsize(in pthread_attr_t*, size_t*);
    int pthread_attr_setguardsize(pthread_attr_t*, size_t);
    int pthread_getconcurrency();
    int pthread_mutexattr_gettype(pthread_mutexattr_t*, int*);
    int pthread_mutexattr_settype(pthread_mutexattr_t*, int);
    int pthread_setconcurrency(int);
}
}
}
    version (linux)
{
    int pthread_getcpuclockid(pthread_t, clockid_t*);
}
else
{
    version (FreeBSD)
{
    int pthread_getcpuclockid(pthread_t, clockid_t*);
}
}
    version (linux)
{
    int pthread_mutex_timedlock(pthread_mutex_t*, timespec*);
    int pthread_rwlock_timedrdlock(pthread_rwlock_t*, in timespec*);
    int pthread_rwlock_timedwrlock(pthread_rwlock_t*, in timespec*);
}
else
{
    version (OSX)
{
    int pthread_mutex_timedlock(pthread_mutex_t*, timespec*);
    int pthread_rwlock_timedrdlock(pthread_rwlock_t*, in timespec*);
    int pthread_rwlock_timedwrlock(pthread_rwlock_t*, in timespec*);
}
else
{
    version (FreeBSD)
{
    int pthread_mutex_timedlock(pthread_mutex_t*, timespec*);
    int pthread_rwlock_timedrdlock(pthread_rwlock_t*, in timespec*);
    int pthread_rwlock_timedwrlock(pthread_rwlock_t*, in timespec*);
}
}
}
    version (OSX)
{
    enum 
{
PTHREAD_PRIO_NONE,
PTHREAD_PRIO_INHERIT,
PTHREAD_PRIO_PROTECT,
}
    int pthread_mutex_getprioceiling(in pthread_mutex_t*, int*);
    int pthread_mutex_setprioceiling(pthread_mutex_t*, int, int*);
    int pthread_mutexattr_getprioceiling(in pthread_mutexattr_t*, int*);
    int pthread_mutexattr_getprotocol(in pthread_mutexattr_t*, int*);
    int pthread_mutexattr_setprioceiling(pthread_mutexattr_t*, int);
    int pthread_mutexattr_setprotocol(pthread_mutexattr_t*, int);
}
    version (linux)
{
    enum 
{
PTHREAD_SCOPE_SYSTEM,
PTHREAD_SCOPE_PROCESS,
}
    int pthread_attr_getinheritsched(in pthread_attr_t*, int*);
    int pthread_attr_getschedpolicy(in pthread_attr_t*, int*);
    int pthread_attr_getscope(in pthread_attr_t*, int*);
    int pthread_attr_setinheritsched(pthread_attr_t*, int);
    int pthread_attr_setschedpolicy(pthread_attr_t*, int);
    int pthread_attr_setscope(pthread_attr_t*, int);
    int pthread_getschedparam(pthread_t, int*, sched_param*);
    int pthread_setschedparam(pthread_t, int, in sched_param*);
}
else
{
    version (OSX)
{
    enum 
{
PTHREAD_SCOPE_SYSTEM = 1,
PTHREAD_SCOPE_PROCESS = 2,
}
    int pthread_attr_getinheritsched(in pthread_attr_t*, int*);
    int pthread_attr_getschedpolicy(in pthread_attr_t*, int*);
    int pthread_attr_getscope(in pthread_attr_t*, int*);
    int pthread_attr_setinheritsched(pthread_attr_t*, int);
    int pthread_attr_setschedpolicy(pthread_attr_t*, int);
    int pthread_attr_setscope(pthread_attr_t*, int);
    int pthread_getschedparam(pthread_t, int*, sched_param*);
    int pthread_setschedparam(pthread_t, int, in sched_param*);
}
else
{
    version (FreeBSD)
{
    enum 
{
PTHREAD_SCOPE_PROCESS = 0,
PTHREAD_SCOPE_SYSTEM = 2,
}
    int pthread_attr_getinheritsched(in pthread_attr_t*, int*);
    int pthread_attr_getschedpolicy(in pthread_attr_t*, int*);
    int pthread_attr_getscope(in pthread_attr_t*, int*);
    int pthread_attr_setinheritsched(pthread_attr_t*, int);
    int pthread_attr_setschedpolicy(pthread_attr_t*, int);
    int pthread_attr_setscope(in pthread_attr_t*, int);
    int pthread_getschedparam(pthread_t, int*, sched_param*);
    int pthread_setschedparam(pthread_t, int, sched_param*);
}
}
}
    version (linux)
{
    int pthread_attr_getstack(in pthread_attr_t*, void**, size_t*);
    int pthread_attr_getstackaddr(in pthread_attr_t*, void**);
    int pthread_attr_getstacksize(in pthread_attr_t*, size_t*);
    int pthread_attr_setstack(pthread_attr_t*, void*, size_t);
    int pthread_attr_setstackaddr(pthread_attr_t*, void*);
    int pthread_attr_setstacksize(pthread_attr_t*, size_t);
}
else
{
    version (OSX)
{
    int pthread_attr_getstack(in pthread_attr_t*, void**, size_t*);
    int pthread_attr_getstackaddr(in pthread_attr_t*, void**);
    int pthread_attr_getstacksize(in pthread_attr_t*, size_t*);
    int pthread_attr_setstack(pthread_attr_t*, void*, size_t);
    int pthread_attr_setstackaddr(pthread_attr_t*, void*);
    int pthread_attr_setstacksize(pthread_attr_t*, size_t);
}
else
{
    version (FreeBSD)
{
    int pthread_attr_getstack(in pthread_attr_t*, void**, size_t*);
    int pthread_attr_getstackaddr(in pthread_attr_t*, void**);
    int pthread_attr_getstacksize(in pthread_attr_t*, size_t*);
    int pthread_attr_setstack(pthread_attr_t*, void*, size_t);
    int pthread_attr_setstackaddr(pthread_attr_t*, void*);
    int pthread_attr_setstacksize(pthread_attr_t*, size_t);
}
}
}
    version (FreeBSD)
{
    int pthread_condattr_getpshared(in pthread_condattr_t*, int*);
    int pthread_condattr_setpshared(pthread_condattr_t*, int);
    int pthread_mutexattr_getpshared(in pthread_mutexattr_t*, int*);
    int pthread_mutexattr_setpshared(pthread_mutexattr_t*, int);
    int pthread_rwlockattr_getpshared(in pthread_rwlockattr_t*, int*);
    int pthread_rwlockattr_setpshared(pthread_rwlockattr_t*, int);
}
else
{
    version (OSX)
{
    int pthread_condattr_getpshared(in pthread_condattr_t*, int*);
    int pthread_condattr_setpshared(pthread_condattr_t*, int);
    int pthread_mutexattr_getpshared(in pthread_mutexattr_t*, int*);
    int pthread_mutexattr_setpshared(pthread_mutexattr_t*, int);
    int pthread_rwlockattr_getpshared(in pthread_rwlockattr_t*, int*);
    int pthread_rwlockattr_setpshared(pthread_rwlockattr_t*, int);
}
}
}
