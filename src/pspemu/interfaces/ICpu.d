module pspemu.interfaces.ICpu;

public import pspemu.core.cpu.Registers;
public import pspemu.interfaces.IInterruptable;

interface ICpu : IInterruptable {
    void execute_loop_limit(Registers registers, uint maxInstructions);
	void execute_loop(Registers registers);
	void execute(Registers registers);	
}