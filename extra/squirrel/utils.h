#include <math.h>

#include <assert.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define ubyte  unsigned char
#define ushort unsigned short
#define uint   unsigned int

#define SQ_RELEASE(CLASS) CLASS##__sqreleasehook
#define SQ_FUNC(NAME) __sqfunc_##NAME
#define SQ_METHOD(CLASS, NAME) CLASS##__sqmethod_##NAME

#define CSQ_RELEASE(CLASS) ((SQRELEASEHOOK)SQ_RELEASE(CLASS))

#define DSQ_FUNC(NAME) static SQInteger SQ_FUNC(NAME)(HSQUIRRELVM v)
#define DSQ_METHOD(CLASS, NAME) static SQInteger SQ_METHOD(CLASS, NAME)(HSQUIRRELVM v)
#define DSQ_RELEASE(CLASS) static SQInteger SQ_RELEASE(CLASS)(CLASS *self, SQInteger size)

#define DSQ_RELEASE_AUTO(CLASS) DSQ_RELEASE(CLASS) { if (self != NULL) delete self; return 0; }
#define DSQ_RELEASE_AUTO_RELEASECAPTURE(CLASS) DSQ_RELEASE(CLASS) { if (self != NULL) self->release(); return 0; }

#define NEWSLOT_FLOAT(KEY, VALUE) { sq_pushstring(v, KEY, -1); sq_pushfloat(v, VALUE); sq_createslot(v, -3); }
#define NEWSLOT_INT(KEY, VALUE) { sq_pushstring(v, KEY, -1); sq_pushinteger(v, VALUE); sq_createslot(v, -3); }
#define NEWSLOT_STR(KEY, VALUE) { sq_pushstring(v, KEY, -1); sq_pushstring(v, VALUE, -1); sq_createslot(v, -3); }
#define NEWSLOT_FUNC_EX(KEY, FUNC, PARAMS_COUNT, PARAMS) { \
	sq_pushstring(v, KEY, -1); \
	sq_newclosure(v, FUNC, 0); \
	sq_setparamscheck(v, PARAMS_COUNT, PARAMS); \
	sq_setnativeclosurename(v, -1, KEY); \
	sq_createslot(v, -3); \
}

#define NEWSLOT_FUNC(NAME, PARAMS_COUNT, PARAMS) NEWSLOT_FUNC_EX(#NAME, SQ_FUNC(NAME), PARAMS_COUNT, PARAMS)
#define NEWSLOT_METHOD(CLASS, NAME, PARAMS_COUNT, PARAMS) NEWSLOT_FUNC_EX(#NAME, SQ_METHOD(CLASS, NAME), PARAMS_COUNT, PARAMS)
#define RETURN_VOID return 0;
#define RETURN_FLOAT(VALUE) { sq_pushfloat(v, (float)(VALUE)); return 1; }
#define RETURN_INT(VALUE) { sq_pushinteger(v, (int)(VALUE)); return 1; }
#define RETURN_STR(VALUE) { sq_pushstring(v, VALUE, -1); return 1; }

#define CLASS_START(CLASS) { sq_pushstring(v, #CLASS, -1); sq_newclass(v, 0); sq_settypetag(v, -1, SQTAG_##CLASS); }
#define CLASS_END sq_createslot(v, -3);

#define EXTRACT_PARAM_START() int nargs = sq_gettop(v);
#define EXTRACT_PARAM_SELF(TYPE) TYPE *self = NULL; (nargs >= 1) && sq_getinstanceup(v, 1, (SQUserPointer *)&self, SQTAG_##TYPE); if (self == NULL) return 0;
#define EXTRACT_PARAM_OBJ(N, TYPE, V) TYPE *V = NULL; (nargs >= N) && sq_getinstanceup(v, N, (SQUserPointer *)&V, SQTAG_##TYPE);
#define EXTRACT_PARAM_STR(N, V, D) STRING V = {(ubyte *)D, sizeof(D) - 1}; (nargs >= N) && (sq_getstring(v, N, (const SQChar **)&V.data) == 0) && (V.len = strlen((const char *)V.data));
#define EXTRACT_PARAM_INT(N, V, D) int V = D; (nargs >= N) && sq_getinteger(v, N, &V);
#define EXTRACT_PARAM_FLO(N, V, D) float V = D; (nargs >= N) && sq_getfloat(v, N, &V);
#define EXTRACT_PARAM_COL(N, V) /*float V[4] = D;*/ (nargs >= N) && color_extract(v, N, &V);

#define CREATE_OBJECT(TYPE, OBJ) \
	sq_pushroottable(v); \
	sq_pushstring(v, #TYPE, -1); \
	sq_get(v, -2); \
	sq_createinstance(v, -1); \
	sq_setinstanceup(v, -1, OBJ); \
	sq_setreleasehook(v, -1, CSQ_RELEASE(TYPE));


typedef struct {
	ubyte *data;
	uint len;
} STRING;

STRING STRING_ALLOC(uint len) {
	STRING r;
	r.data = (ubyte *)malloc(r.len = len);
	return r;
}

void STRING_FREAD(STRING s, FILE *f) {
	fread(s.data, s.len, 1, f);
}

void STRING_FREE(STRING *s) {
	if (s == NULL || s->data == NULL) return;
	free(s->data);
	s->data = NULL;
}

void STRING_FILE_PUT(STRING s, char *name) {
	FILE *f = fopen(name, "wb");
	if (f == NULL) return;
	fwrite(s.data, s.len, 1, f);
	fclose(f);
}

#define FREAD_V(f, v) fread(&v, sizeof(v), 1, f)
#define FERROR(s, ...) { fprintf(stderr, s "\n", __VA_ARGS__); goto __cleanup; }

extern HSQUIRRELVM v;

void game_quit() {
	sq_close(v);
	exit(0);
}

int color_extract(HSQUIRRELVM v, int idx, float colors[][4]) {
	if (colors == NULL) return 0;
	int size = sq_getsize(v, idx);
	sq_pushnull(v);
	for (int n = 0; n < size; n++) {
		sq_next(v, idx);
		sq_getfloat(v, -1, &(*colors)[n]);
		sq_pop(v, 2);
	}
	sq_poptop(v);
	return size;
}

int extract_vector_int(HSQUIRRELVM v, int idx, int *vector, int max_count) {
	if (vector == NULL) return 0;
	if (idx < 0) idx += sq_gettop(v) + 1;
	int size = sq_getsize(v, idx);
	if (size > max_count) size = max_count;
	sq_pushnull(v);
	for (int n = 0; n < size; n++) {
		sq_next(v, idx);
		sq_getinteger(v, -1, &vector[n]);
		sq_pop(v, 2);
	}
	sq_poptop(v);
	return size;
}

int rmod(int v, int mod) {
	return (v < 0) ? (mod - ((-v - 1) % mod) - 1) : (v % mod);
}

STRING STRING_READSTREAM(SQStream *stream)
{
	STRING s = STRING_ALLOC(stream->Len());
	SQInteger back = stream->Tell();
	{
		stream->Seek(0, SQ_SEEK_SET);
		s.len = stream->Read(s.data, s.len);
	}
	stream->Seek(back, SQ_SEEK_SET);
	return s;
}
