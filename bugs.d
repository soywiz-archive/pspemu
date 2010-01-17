import std.variant;

void main() {
	void bug_1() {
		// Fails: Internal error: e2ir.c 4544
		foreach (k, v; [0 : 0]) { }

		// Works.
		auto l = [0 : 0];
		foreach (k, v; l) { }
	}

	// http://d.puremagic.com/issues/show_bug.cgi?id=3692
	void bug_2() {
		// When including std.variant and even without using Variant.
		// Fails:
		//  Error: template instance ambiguous template declaration std.variant.AssociativeArray(T) and object.AssociativeArray(Key,Value)
		//  Assertion failure: 'impl' on line 3882 in file 'mtype.c'
		class A { }
		A[string] l;
		foreach (a; l.values) { }
	}
}