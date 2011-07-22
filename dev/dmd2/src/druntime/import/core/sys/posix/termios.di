// D import file generated from 'src\core\sys\posix\termios.d'
module core.sys.posix.termios;
private import core.sys.posix.config;

public import core.sys.posix.sys.types;

extern (C) 
{
    version (linux)
{
    alias ubyte cc_t;
    alias uint speed_t;
    alias uint tcflag_t;
    enum NCCS = 32;
    struct termios
{
    tcflag_t c_iflag;
    tcflag_t c_oflag;
    tcflag_t c_cflag;
    tcflag_t c_lflag;
    cc_t c_line;
    cc_t[NCCS] c_cc;
    speed_t c_ispeed;
    speed_t c_ospeed;
}
    enum VEOF = 4;
    enum VEOL = 11;
    enum VERASE = 2;
    enum VINTR = 0;
    enum VKILL = 3;
    enum VMIN = 6;
    enum VQUIT = 1;
    enum VSTART = 8;
    enum VSTOP = 9;
    enum VSUSP = 10;
    enum VTIME = 5;
    enum BRKINT = 2;
    enum ICRNL = 256;
    enum IGNBRK = 1;
    enum IGNCR = 128;
    enum IGNPAR = 4;
    enum INLCR = 64;
    enum INPCK = 16;
    enum ISTRIP = 32;
    enum IXOFF = 4096;
    enum IXON = 1024;
    enum PARMRK = 8;
    enum OPOST = 1;
    enum B0 = 0;
    enum B50 = 1;
    enum B75 = 2;
    enum B110 = 3;
    enum B134 = 4;
    enum B150 = 5;
    enum B200 = 6;
    enum B300 = 7;
    enum B600 = 8;
    enum B1200 = 9;
    enum B1800 = 10;
    enum B2400 = 11;
    enum B4800 = 12;
    enum B9600 = 13;
    enum B19200 = 14;
    enum B38400 = 15;
    enum CSIZE = 48;
    enum CS5 = 0;
    enum CS6 = 16;
    enum CS7 = 32;
    enum CS8 = 48;
    enum CSTOPB = 64;
    enum CREAD = 128;
    enum PARENB = 256;
    enum PARODD = 512;
    enum HUPCL = 1024;
    enum CLOCAL = 2048;
    enum ECHO = 8;
    enum ECHOE = 16;
    enum ECHOK = 32;
    enum ECHONL = 64;
    enum ICANON = 2;
    enum IEXTEN = 32768;
    enum ISIG = 1;
    enum NOFLSH = 128;
    enum TOSTOP = 256;
    enum TCSANOW = 0;
    enum TCSADRAIN = 1;
    enum TCSAFLUSH = 2;
    enum TCIFLUSH = 0;
    enum TCOFLUSH = 1;
    enum TCIOFLUSH = 2;
    enum TCIOFF = 2;
    enum TCION = 3;
    enum TCOOFF = 0;
    enum TCOON = 1;
    speed_t cfgetispeed(in termios*);
    speed_t cfgetospeed(in termios*);
    int cfsetispeed(termios*, speed_t);
    int cfsetospeed(termios*, speed_t);
    int tcdrain(int);
    int tcflow(int, int);
    int tcflush(int, int);
    int tcgetattr(int, termios*);
    int tcsendbreak(int, int);
    int tcsetattr(int, int, in termios*);
}
else
{
    version (OSX)
{
    alias ubyte cc_t;
    alias uint speed_t;
    alias uint tcflag_t;
    enum NCCS = 20;
    struct termios
{
    tcflag_t c_iflag;
    tcflag_t c_oflag;
    tcflag_t c_cflag;
    tcflag_t c_lflag;
    cc_t[NCCS] c_cc;
    speed_t c_ispeed;
    speed_t c_ospeed;
}
    enum VEOF = 0;
    enum VEOL = 1;
    enum VERASE = 3;
    enum VINTR = 8;
    enum VKILL = 5;
    enum VMIN = 16;
    enum VQUIT = 9;
    enum VSTART = 12;
    enum VSTOP = 13;
    enum VSUSP = 10;
    enum VTIME = 17;
    enum BRKINT = 2;
    enum ICRNL = 256;
    enum IGNBRK = 1;
    enum IGNCR = 128;
    enum IGNPAR = 4;
    enum INLCR = 64;
    enum INPCK = 16;
    enum ISTRIP = 32;
    enum IXOFF = 1024;
    enum IXON = 512;
    enum PARMRK = 8;
    enum OPOST = 1;
    enum B0 = 0;
    enum B50 = 50;
    enum B75 = 75;
    enum B110 = 110;
    enum B134 = 134;
    enum B150 = 150;
    enum B200 = 200;
    enum B300 = 300;
    enum B600 = 600;
    enum B1200 = 1200;
    enum B1800 = 1800;
    enum B2400 = 2400;
    enum B4800 = 4800;
    enum B9600 = 9600;
    enum B19200 = 19200;
    enum B38400 = 38400;
    enum CSIZE = 768;
    enum CS5 = 0;
    enum CS6 = 256;
    enum CS7 = 512;
    enum CS8 = 768;
    enum CSTOPB = 1024;
    enum CREAD = 2048;
    enum PARENB = 4096;
    enum PARODD = 8192;
    enum HUPCL = 16384;
    enum CLOCAL = 32768;
    enum ECHO = 8;
    enum ECHOE = 2;
    enum ECHOK = 4;
    enum ECHONL = 16;
    enum ICANON = 256;
    enum IEXTEN = 1024;
    enum ISIG = 128;
    enum NOFLSH = -2147483648u;
    enum TOSTOP = 4194304;
    enum TCSANOW = 0;
    enum TCSADRAIN = 1;
    enum TCSAFLUSH = 2;
    enum TCIFLUSH = 1;
    enum TCOFLUSH = 2;
    enum TCIOFLUSH = 3;
    enum TCIOFF = 3;
    enum TCION = 4;
    enum TCOOFF = 1;
    enum TCOON = 2;
    speed_t cfgetispeed(in termios*);
    speed_t cfgetospeed(in termios*);
    int cfsetispeed(termios*, speed_t);
    int cfsetospeed(termios*, speed_t);
    int tcdrain(int);
    int tcflow(int, int);
    int tcflush(int, int);
    int tcgetattr(int, termios*);
    int tcsendbreak(int, int);
    int tcsetattr(int, int, in termios*);
}
else
{
    version (FreeBSD)
{
    alias ubyte cc_t;
    alias uint speed_t;
    alias uint tcflag_t;
    enum NCCS = 20;
    struct termios
{
    tcflag_t c_iflag;
    tcflag_t c_oflag;
    tcflag_t c_cflag;
    tcflag_t c_lflag;
    cc_t[NCCS] c_cc;
    speed_t c_ispeed;
    speed_t c_ospeed;
}
    enum VEOF = 0;
    enum VEOL = 1;
    enum VERASE = 3;
    enum VINTR = 8;
    enum VKILL = 5;
    enum VMIN = 16;
    enum VQUIT = 9;
    enum VSTART = 12;
    enum VSTOP = 13;
    enum VSUSP = 10;
    enum VTIME = 17;
    enum BRKINT = 2;
    enum ICRNL = 256;
    enum IGNBRK = 1;
    enum IGNCR = 128;
    enum IGNPAR = 4;
    enum INLCR = 64;
    enum INPCK = 16;
    enum ISTRIP = 32;
    enum IXOFF = 1024;
    enum IXON = 512;
    enum PARMRK = 8;
    enum OPOST = 1;
    enum B0 = 0;
    enum B50 = 50;
    enum B75 = 75;
    enum B110 = 110;
    enum B134 = 134;
    enum B150 = 150;
    enum B200 = 200;
    enum B300 = 300;
    enum B600 = 600;
    enum B1200 = 1200;
    enum B1800 = 1800;
    enum B2400 = 2400;
    enum B4800 = 4800;
    enum B9600 = 9600;
    enum B19200 = 19200;
    enum B38400 = 38400;
    enum CSIZE = 768;
    enum CS5 = 0;
    enum CS6 = 256;
    enum CS7 = 512;
    enum CS8 = 768;
    enum CSTOPB = 1024;
    enum CREAD = 2048;
    enum PARENB = 4096;
    enum PARODD = 8192;
    enum HUPCL = 16384;
    enum CLOCAL = 32768;
    enum ECHO = 8;
    enum ECHOE = 2;
    enum ECHOK = 4;
    enum ECHONL = 16;
    enum ICANON = 256;
    enum IEXTEN = 1024;
    enum ISIG = 128;
    enum NOFLSH = -2147483648u;
    enum TOSTOP = 4194304;
    enum TCSANOW = 0;
    enum TCSADRAIN = 1;
    enum TCSAFLUSH = 2;
    enum TCIFLUSH = 1;
    enum TCOFLUSH = 2;
    enum TCIOFLUSH = 3;
    enum TCIOFF = 3;
    enum TCION = 4;
    enum TCOOFF = 1;
    enum TCOON = 2;
    speed_t cfgetispeed(in termios*);
    speed_t cfgetospeed(in termios*);
    int cfsetispeed(termios*, speed_t);
    int cfsetospeed(termios*, speed_t);
    int tcdrain(int);
    int tcflow(int, int);
    int tcflush(int, int);
    int tcgetattr(int, termios*);
    int tcsendbreak(int, int);
    int tcsetattr(int, int, in termios*);
}
}
}
    version (linux)
{
    enum IXANY = 2048;
    enum ONLCR = 4;
    enum OCRNL = 8;
    enum ONOCR = 16;
    enum ONLRET = 32;
    enum OFILL = 64;
    enum NLDLY = 256;
    enum NL0 = 0;
    enum NL1 = 256;
    enum CRDLY = 1536;
    enum CR0 = 0;
    enum CR1 = 512;
    enum CR2 = 1024;
    enum CR3 = 1536;
    enum TABDLY = 6144;
    enum TAB0 = 0;
    enum TAB1 = 2048;
    enum TAB2 = 4096;
    enum TAB3 = 6144;
    enum BSDLY = 8192;
    enum BS0 = 0;
    enum BS1 = 8192;
    enum VTDLY = 16384;
    enum VT0 = 0;
    enum VT1 = 16384;
    enum FFDLY = 32768;
    enum FF0 = 0;
    enum FF1 = 32768;
    pid_t tcgetsid(int);
}
else
{
    version (FreeBSD)
{
    enum IXANY = 2048;
    enum ONLCR = 2;
    enum OCRNL = 16;
    enum ONOCR = 32;
    enum ONLRET = 64;
    enum TABDLY = 4;
    enum TAB0 = 0;
    enum TAB3 = 4;
    pid_t tcgetsid(int);
}
}
}
