module pspemu.core.exceptions.UnknownOperationException;

class UnknownOperationException : Exception {
	uint PC;
	this(uint PC, string str) {
		this.PC = PC;
		super(str);
	}
}