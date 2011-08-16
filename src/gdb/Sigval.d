module gdb.Sigval;

enum Sigval {
	Ok = -1,
	InvalidOpcode = 4,
	DebugException = 5,
	DoubleFault = 7,
	DivideByZero = 8,
	MemoryException = 11,
	Overflow = 16,
}
