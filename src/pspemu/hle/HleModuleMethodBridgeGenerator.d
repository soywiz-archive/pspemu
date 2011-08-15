module pspemu.hle.HleModuleMethodBridgeGenerator;

import pspemu.utils.TraitsUtils;

import std.conv;

/**
 * This module does a bit of magic generating bridge delegates converting Registers or stack into a formal D call.
 * It allows to have hle modules with functions that matches their original definitions. 
 */

class HleModuleMethodBridgeGenerator {
	/**
	 * Returns a string to use with a mixin that defines a delegate bridging
	 * a PSP call with a native function.
	 */
	static public string getDelegate(alias nativeFunction, uint nid = 0)() {
		string r = "";
		r ~= "delegate void() {";
		{
			r ~= "{";
			r ~= getCallWithDebug!(nativeFunction, nid);
			r ~= "}";
		}
		r ~= "}";
		return r;
	}
	
	static public string getCallWithDebug(alias nativeFunction, uint nid = 0)() {
		string r = "";
		{
			r ~= "currentExecutingNid = " ~ to!string(nid) ~ ";";
			r ~= "Logger.log(Logger.Level.TRACE, \"Module\", std.string.format(\"%s\", \"" ~ functionName ~ "\"));";
			r ~= "logLevel(Logger.Level.TRACE, std.string.format(\"%s\", \"" ~ functionName ~ "\"));";
			
			r ~= getCall!(nativeFunction);
		}
		return r;
	}
	
	static public string getCall(alias nativeFunction)() {
		string functionName    = FunctionName!(nativeFunction);
		bool   doesReturnValue = !is(ReturnType!(nativeFunction) == void);

		string r = "";
		r ~= "{";
		{
			if (doesReturnValue) r ~= "auto retval = ";
			{
				r ~= "this." ~ functionName ~ "(" ~ getCallParameters!(nativeFunction) ~ ");";
			}
			if (doesReturnValue) {
				if (isPointerType!(ReturnType!(nativeFunction))) {
					r ~= "currentRegisters.V0 = currentMemory.getPointerReverseOrNull(cast(void *)retval);";
				} else {
					r ~= "currentRegisters.V0 = (cast(uint *)&retval)[0];";
					if (ReturnType!(nativeFunction).sizeof == 8) {
						r ~= "currentRegisters.V1 = (cast(uint *)&retval)[1];";
					}
				}
			}
		}
		r ~= "}";
		return r;
	}

	static public string getCallParameters(alias nativeFunction)() {
		string r = "";
		int paramIndex = 0;
		foreach (param; ParameterTypeTuple!(nativeFunction)) {
			if (paramIndex > 0) r ~= ", ";

			// A String
			if (isString!(param)) {
				r ~= "paramsz(" ~ to!string(paramIndex) ~ ")";
			}
			// A Pointer or a Class
			else if (isPointerType!(param) || isClassType!(param)) {
				r ~= "cast(" ~ param.stringof ~ ")param_p(" ~ to!string(paramIndex) ~ ")";
				//pragma(msg, "class!");
			}
			// A 64-bit parameter
			else if (param.sizeof == 8) {
				// TODO. FIXME!
				if (paramIndex % 2) paramIndex++; // PADDING
				r ~= "cast(" ~ param.stringof ~ ")param64(" ~ to!string(paramIndex) ~ ")";
				paramIndex++; // extra incremnt
			}
			// Other type (try to convert as an integer)
			else {
				r ~= "cast(" ~ param.stringof ~ ")param(" ~ to!string(paramIndex) ~ ")";
			}

			paramIndex++;
		}
		return r;
	}
}
