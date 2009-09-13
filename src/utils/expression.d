module expression;

import std.stdio;
import std.string;

class Expression {
	struct Token {
		char[] value;
		bool op;
		
		void dump() {
			writefln("TOKEN: '%s' (%s)", value, op);
		}		
	}

	Token[] tokens;
	uint tokenpos = 0;
	
	bool more() {
		return (tokenpos < tokens.length);
	}
	
	Token current() {
		return tokens[tokenpos];
	}
	
	void next() {
		tokenpos++;
	}
	
	static long function(char[], out bool)[] mapvalues;
	
	static long number_base(char[] s, int base) {
		long r;
		foreach (c; s) {
			int cv = -1;
			if (c >= '0' && c <= '9') cv = c - '0';
			else if (c >= 'a' && c <= 'z') cv = c - 'a' + 0xa;
			else if (c >= 'A' && c <= 'Z') cv = c - 'A' + 0xA;
			
			if (cv >= 0 && cv < base) {
				r *= base;
				r += cv;
			} else {
				throw(new Exception(std.string.format("Invalid character '%s' in number '%s' in base '%d'", [cast(char)c], s, base)));
			}
		}
		return r;
	}
	
	static long number(char[] s) {
		if (s.length > 2 && s[0..2] == "0x") {
			return number_base(s[2..s.length], 16);
		} else if (s.length > 2 && s[0..2] == "0b") {
			return number_base(s[2..s.length], 2);
		} else if (s.length > 1 && s[0] == '0') {
			return number_base(s[1..s.length], 8);
		} else {
			return number_base(s, 10);
		}
	}

	static long value(Token t) {
		long r;
		char[] exp = t.value;
		bool found;
		
		foreach (mv; mapvalues) {
			r = mv(exp, found);
			if (found) return r;
		}

		return number(exp);
	}

	long exp2() { // ( num
		long r;
		Token t = current;
		
		if (t.op) {
			switch (t.value) {
				case "(":
					next();
					r = exp0;					
					if (current.value != ")") throw(new Exception(") mismatch"));
					next();
				break;
				case "-": next(); r = -exp0; break;
				case "+": next(); r = exp0; break;
				default:
					throw(new Exception(std.string.format("Invalid operator '%s'", t.value)));
				break;
			}
		}
		// Numero
		else {
			next();			
			r = value(t);
			//writefln("PUSH %08X (%s) %s", r, t.value, t.op);
		}
		
		return r;
	}
	
	long exp1() { // * /
		long r = exp2;

		while (more) {
			Token t = current;
			
			if (!t.op) return r;

			switch (t.value) {
				case "+":
					next(); r += exp0;
					//writefln("SUM (%d)", r);
				break;
				case "-":
					next(); r -= exp0;
				break;
				default: return r;
			}
		}
	}
	
	long exp0() { // + -
		long r = exp1;
		
		while (more) {
			Token t = current;
			
			if (!t.op) return r;

			switch (t.value) {
				case "*": next(); r *= exp0; break;
				case "/": next(); r /= exp0; break;
				default: return r;
			}
		}
		
		return r;
	}
	
	this(char[] exp) {
		int type = -1;
		char[] s;
		
		void flush(int ct = -1, bool force = false) {
			if (type != -1) {
				if (force || (type != ct && s.length)) {
					tokens ~= Token(s, (type == 1));
					s = "";
					//writefln("flush");
				}
			}
			type = ct;
		}
		
		foreach (c; std.string.tolower(exp)) {
			if (c == ' ' || c == '\n' || c == '\r') {
				continue;
			}
			
			// keyword/number
			if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) {
				flush(0);
				s ~= c;
			}
			// operator
			else {
				flush(1, true);
				s ~= c;				
			}
		}
		
		flush();
		
		tokens ~= Token("", true);
		
		//foreach (t; tokens) t.dump();
	}
	
	static long evaluate(char[] exp) {
		auto obj = new Expression(exp); 
		return obj.exp0;
	}
}