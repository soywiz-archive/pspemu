module pspemu.interfaces.IComponent;

public import pspemu.interfaces.IStartable;
public import pspemu.interfaces.IResetable;
public import pspemu.interfaces.IInterruptable;

interface IComponent : IStartable, IResetable, IInterruptable {
}