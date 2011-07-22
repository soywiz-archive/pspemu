// D import file generated from 'src\core\sys\posix\poll.d'
module core.sys.posix.poll;
private import core.sys.posix.config;

extern (C) version (linux)
{
    struct pollfd
{
    int fd;
    short events;
    short revents;
}
    alias c_ulong nfds_t;
    enum 
{
POLLIN = 1,
POLLRDNORM = 64,
POLLRDBAND = 128,
POLLPRI = 2,
POLLOUT = 4,
POLLWRNORM = 256,
POLLWRBAND = 512,
POLLERR = 8,
POLLHUP = 16,
POLLNVAL = 32,
}
    int poll(pollfd*, nfds_t, int);
}
else
{
    version (OSX)
{
    struct pollfd
{
    int fd;
    short events;
    short revents;
}
    alias uint nfds_t;
    enum 
{
POLLIN = 1,
POLLPRI = 2,
POLLOUT = 4,
POLLRDNORM = 64,
POLLWRNORM = POLLOUT,
POLLRDBAND = 128,
POLLWRBAND = 256,
POLLEXTEND = 512,
POLLATTRIB = 1024,
POLLNLINK = 2048,
POLLWRITE = 4096,
POLLERR = 8,
POLLHUP = 16,
POLLNVAL = 32,
POLLSTANDARD = POLLIN | POLLPRI | POLLOUT | POLLRDNORM | POLLRDBAND | POLLWRBAND | POLLERR | POLLHUP | POLLNVAL,
}
    int poll(pollfd*, nfds_t, int);
}
else
{
    version (FreeBSD)
{
    alias uint nfds_t;
    struct pollfd
{
    int fd;
    short events;
    short revents;
}
    enum 
{
POLLIN = 1,
POLLPRI = 2,
POLLOUT = 4,
POLLRDNORM = 64,
POLLWRNORM = POLLOUT,
POLLRDBAND = 128,
POLLWRBAND = 256,
POLLERR = 8,
POLLHUP = 16,
POLLNVAL = 32,
POLLSTANDARD = POLLIN | POLLPRI | POLLOUT | POLLRDNORM | POLLRDBAND | POLLWRBAND | POLLERR | POLLHUP | POLLNVAL,
}
    int poll(pollfd*, nfds_t, int);
}
}
}

