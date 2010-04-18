module pspemu.hle.kd.pspnet_apctl; // kd/pspnet_apctl.prx (sceNetApctl_Library)

//debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

struct sockaddr;
struct in_addr;

class sceNetApctl : Module {
	void initNids() {
		mixin(registerd!(0xE2F91F9B, sceNetApctlInit));
		mixin(registerd!(0xB3EDD0EC, sceNetApctlTerm));
		mixin(registerd!(0x2BEFDF23, sceNetApctlGetInfo));
		mixin(registerd!(0xCFB957C6, sceNetApctlConnect));
		mixin(registerd!(0x24FE91A1, sceNetApctlDisconnect));
		mixin(registerd!(0x5DEAC81B, sceNetApctlGetState));
	}

	/**
	 * Init the apctl.
	 *
	 * @param stackSize - The stack size of the internal thread.
	 *
	 * @param initPriority - The priority of the internal thread.
	 *
	 * @return < 0 on error.
	 */
	int sceNetApctlInit(int stackSize, int initPriority) {
		unimplemented();
		return -1;
	}

	/**
	 * Terminate the apctl.
	 *
	 * @return < 0 on error.
	 */
	int sceNetApctlTerm() {
		unimplemented();
		return -1;
	}

	/**
	 * Get the apctl information.
	 *
	 * @param code - One of the PSP_NET_APCTL_INFO_* defines.
	 *
	 * @param pInfo - Pointer to a ::SceNetApctlInfo.
	 *
	 * @return < 0 on error.
	 */
	int sceNetApctlGetInfo(int code, SceNetApctlInfo* pInfo) {
		unimplemented();
		return -1;
	}

	/**
	 * Connect to an access point.
	 *
	 * @param connIndex - The index of the connection.
	 *
	 * @return < 0 on error.
	 */
	int sceNetApctlConnect(int connIndex) {
		unimplemented();
		return -1;
	}

	/**
	 * Disconnect from an access point.
	 *
	 * @return < 0 on error.
	 */
	int sceNetApctlDisconnect() {
		unimplemented();
		return -1;
	}

	/**
	 * Get the state of the access point connection.
	 *
	 * @param pState - Pointer to receive the current state (one of the PSP_NET_APCTL_STATE_* defines).
	 *
	 * @return < 0 on error.
	 */
	int sceNetApctlGetState(int *pState) {
		unimplemented();
		return -1;
	}
}

union SceNetApctlInfo  { 
	char name[64];				/* Name of the config used */ 
	ubyte bssid[6];		/* MAC address of the access point */ 
	ubyte ssid[32];		/* ssid */ 			
	uint ssidLength;	/* ssid string length*/ 
	uint securityType;	/* 0 for none, 1 for WEP, 2 for WPA) */ 
	ubyte strength;		/* Signal strength in % */ 
	ubyte channel;		/* Channel */ 
	ubyte powerSave;	/* 1 on, 0 off */ 
	char ip[16];				/* PSP's ip */ 
	char subNetMask[16];		/* Subnet mask */ 
	char gateway[16];			/* Gateway */ 
	char primaryDns[16];		/* Primary DNS */ 
	char secondaryDns[16];		/* Secondary DNS */ 
	uint useProxy;		/* 1 for proxy, 0 for no proxy */ 
	char proxyUrl[128];			/* Proxy url */ 
	ushort proxyPort;	/* Proxy port */ 
	uint eapType;		/* 0 is none, 1 is EAP-MD5 */ 
	uint startBrowser;	/* Should browser be started */ 
	uint wifisp;		/* 1 if connection is for Wifi service providers (WISP) */ 
}

static this() {
	mixin(Module.registerModule("sceNetApctl"));
}