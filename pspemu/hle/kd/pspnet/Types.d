module pspemu.hle.kd.pspnet.Types;

public import pspemu.hle.kd.Types;

alias ubyte sa_family_t;
alias uint socklen_t;
alias uint ssize_t;
alias uint useconds_t;
alias int suseconds_t;
alias int time_t;
alias uint in_addr_t;

struct sockaddr {
	ubyte       sa_len;     /* total length */
	sa_family_t sa_family;  /* address family */
	char[14]    sa_data;    /* actually longer; address value */
}

struct timeval {
	time_t      tv_sec;
	suseconds_t tv_usec;
}

struct in_addr {
	in_addr_t s_addr;
}


/*
#define	__NBBY		8
typedef uint32_t	__fd_mask;


#define __NFDBITS	((unsigned int)sizeof(__fd_mask) * __NBBY)

#define	__howmany(x, y)	(((x) + ((y) - 1)) / (y))

#define	FD_SETSIZE	256

typedef	struct fd_set {
	__fd_mask	fds_bits[__howmany(FD_SETSIZE, __NFDBITS)];
} fd_set;
*/

struct fd_set {
	uint fds_bits[256 * 4 * 8]; // TO CHECK
}