module pspemu.hle.kd.loadexec.Types;

public import pspemu.hle.kd.Types; 

/** Structure to pass to loadexec */
struct SceKernelLoadExecParam {
	/** Size of the structure */
	SceSize     size;
	/** Size of the arg string */
	SceSize     args;
	/** Pointer to the arg string */
	void *  argp;
	/** Encryption key ? */
	//const char *    key;
	char *    key;
}