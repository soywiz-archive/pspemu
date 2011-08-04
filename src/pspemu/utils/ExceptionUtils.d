module pspemu.utils.ExceptionUtils;

T onException(T)(lazy T t, T errorValue) { try { return t(); } catch { return errorValue; } }
T nullOnException(T)(lazy T t) { return onException!(T)(t, null); }