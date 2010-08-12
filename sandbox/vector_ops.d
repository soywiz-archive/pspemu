import std.date, std.stdio;

const list = [1,2,3];
//const list = [1,2,3,4];
//const list = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
//const list = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19];
//const list = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];

/*
dmd -inline -release -run g.d
2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64
func0: 90
func1: 97
func2: 328
func3: 141
func4: 143
func5: 207
*/

/*
dmd -inline -release -O -run g.d
2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64
func0: 86
func1: 85
func2: 69
func3: 70
func4: 74
func5: 74
func6: 62
func7: 118
*/

/*
dmd -inline -release -O -run g.d
2 4 6 8
func0: 291
func1: 293
func2: 109
func3: 109
func4: 115
func5: 119
func6: 154
func7: 176
*/

/*
dmd -release -inline -O -run vector_ops.d
2 4 6
func0: 275
func1: 305
func2: 89
func3a: 90
func3b: 87
func4: 135
func5: 100
func6: 112
func7: 151
*/

float[list.length] a, b = list, c = list;

void func0() { a[] = b[] + c[]; }
void func1() { a[0..$] = b[0..$] + c[0..$]; }
void func2() {
	foreach (n; 0..a.length) {
		float bb = b[n];
		float cc = c[n];
		a[n] = bb + cc;
	}
}
void func3a() {
	foreach (n; 0..a.length) {
		a[n] = b[n] + c[n];
	}
}
void func3b() {
	for (int n = 0; n < a.length; n++) {
		a[n] = b[n] + c[n];
	}
}
void func4() {
	int n = a.length;
	while (n--) {
		a[n] = b[n] + c[n];
	}
}
void func5() {
	float *_a = a.ptr;
	float *_b = b.ptr;
	float *_c = c.ptr;
	int n = a.length;
	while (n--) {
		*_a++ = *_b++ + *_c++;
	}
}
void func6() {
	float *_a = a.ptr;
	float *_b = b.ptr;
	float *_c = c.ptr;
	foreach (n; 0..a.length) {
		*_a++ = *_b++ + *_c++;
	}
}

void func7() {
	float *_a = a.ptr;
	float *_b = b.ptr;
	float *_c = c.ptr;
	foreach (n; 0..a.length) {
		float l = *_b++;
		float r = *_c++;
		*_a++ = l + r;
	}
}

void main() {
	d_time start, end;
	
	func1();
	writefln("%s", a);
	
	void test(string name, void function() call) {
		start = getUTCtime;
		foreach (n; 0..10000000) call();
		end = getUTCtime;
		writefln("%s: %d", name, end - start);
	}
	
	test("func0", &func0);
	test("func1", &func1);
	test("func2", &func2);
	test("func3a", &func3a);
	test("func3b", &func3b);
	test("func4", &func4);
	test("func5", &func5);
	test("func6", &func6);
	test("func7", &func7);
}