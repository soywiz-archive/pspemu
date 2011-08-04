module pspemu.hle.kd.sysmem.Types;

public import pspemu.hle.kd.Types;

/** Type for Kprintf handler */
//extern (C) function 
//typedef int (*PspDebugKprintfHandler)(const char *format, u32 *args);
alias void* PspDebugKprintfHandler;

enum PspPartition : int {
	Kernel0 = 0,
	Kernel1 = 1,
	User    = 2,
}

/** Specifies the type of allocation used for memory blocks. */
enum PspSysMemBlockTypes {
	/** Allocate from the lowest available address. */
	PSP_SMEM_Low = 0,
	/** Allocate from the highest available address. */
	PSP_SMEM_High = 1,
	/** Allocate from the specified address. */
	PSP_SMEM_Addr = 2,
	
	PSP_SMEM_Low_Aligned = 3,
	PSP_SMEM_High_Aligned = 4,
}

struct PspSysmemPartitionInfo {
	SceSize size;
	uint startaddr;
	uint memsize;
	uint attr;
}

/** Structure of a UID control block */
struct uidControlBlock {
    uidControlBlock* parent;
    uidControlBlock* nextChild;
    uidControlBlock* type;   //(0x8)
    u32 UID;                 //(0xC)
    char* name;              //(0x10)
	ubyte unk;
	ubyte size;              // Size in words
    short attribute;
    uidControlBlock* nextEntry;
}

//typedef int(* 	PspSysEventHandlerFunc )(int ev_id, char *ev_name, void *param, int *result)
alias uint PspSysEventHandlerFunc;

struct PspSysEventHandler{
  int size;
  char* name;
  int type_mask;
  //int (*handler)(int ev_id, char* ev_name, void* param, int* result);
  PspSysEventHandlerFunc handler;
  int r28;
  int busy;
  PspSysEventHandler *next;
  int reserved[9];
}
