module pspemu.hle.HleModuleMethodParamParsing;

import std.conv;

import std.stdio;

import pspemu.core.Memory;
import pspemu.core.cpu.Registers;

import pspemu.utils.TraitsUtils;
import pspemu.utils.MathUtils;

struct HleModuleMethodParamParsing {
	Memory    memory;
	Registers registers;
	int       currentParameterIndex = 0;
	
	public void resetNextParameter() {
		currentParameterIndex = 0;
	}
	
	public T getNextParameter(T)() {
		moveNextAlignedValue(currentParameterIndex, getParameterSize!T);
		scope (exit) currentParameterIndex += getParameterSize!T;
		return getParameter!T(currentParameterIndex);
	}

	/**
	 * Extracts a parameter by index.
	 */
	public T getParameter(T)(int n) {
		if ((n % getParameterSize!T) != 0) {
			if ((n % 2) != 0) throw(new Exception("Invalid alignment extracting param"));
		}
		
		// A String
		static if (is(T == string)) {
			return to!string(getParameter!(char *)(n));
		}
		
		// A Pointer or a Class
		static if (isPointerType!T || isClassType!T) {
			
			return cast(T)memory.getPointer(getParameter!uint(n));
		}

		// An integral value.
		return *cast(T *)getParameterPointer(n);
	}

	/**
	 * Obtains the size of a parameter.
	 */
	static protected int getParameterSize(T)() {
		static if (is(T == string)) return 1;
		return T.sizeof / 4;
	}
	
	/**
	 * Obtains a pointer to a parameter by index.
	 */
	protected void* getParameterPointer(int n) {
		if (n >= 8) {
			return memory.getPointer(registers.SP + (n - 8) * 4);
		} else {
			return &registers.R[4 + n];
		}
	}
}
