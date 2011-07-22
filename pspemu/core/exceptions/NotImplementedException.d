module pspemu.core.exceptions.NotImplementedException;

class NotImplementedException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    	super(msg, file, line, next);
    }
}