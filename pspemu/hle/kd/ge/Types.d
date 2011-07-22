module pspemu.hle.kd.ge.Types;

/** Stores the state of the GE. */
struct PspGeContext {
	uint context[512];
}

/** Typedef for a GE callback */
//alias void function(int id, void *arg) PspGeCallback;
alias uint PspGeCallback;

/** Structure to hold the callback data */
struct PspGeCallbackData {
	/** GE callback for the signal interrupt */
	PspGeCallback signal_func;
	/** GE callback argument for signal interrupt */
	void *signal_arg;
	/** GE callback for the finish interrupt */
	PspGeCallback finish_func;
	/** GE callback argument for finish interrupt */
	void *finish_arg;
}

struct PspGeListArgs {
	uint	size;
	PspGeContext*	context;
}

