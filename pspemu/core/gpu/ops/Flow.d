module pspemu.core.gpu.ops.Flow;

template Gpu_Flow() {
	auto OP_JUMP() {
		gpu.list = cast(Command *)gpu.memory.getPointer((gpu.info.baseAddress | command.param24) & (~0b_11));
	}

	/*
	auto OP_CALL() {
	}

	auto OP_RET() {
	}

	auto OP_SIGNAL() {
	}
	*/
}