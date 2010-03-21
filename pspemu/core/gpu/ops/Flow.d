module pspemu.core.gpu.ops.Flow;

template Gpu_Flow() {
	auto OP_JUMP() {
		auto address = (gpu.info.baseAddress | command.param24) & (~0b_11);
		gpu.list = cast(Command *)gpu.memory.getPointer(address);
		writefln("   %08X", address);
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