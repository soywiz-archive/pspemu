#include <sqlite3.h>

class Sqlite { public:
	sqlite3 *db;
	int error;

	Sqlite(char *name) {
		printf("#SQLITE_DB  :'%s'\n", (name != NULL) ? name : ":memory:");
		db = NULL;
		if (sqlite3_open(name, &db) != SQLITE_OK) {
			fprintf(stderr, "Error with 'sqlite3_open': '%s'\n", sqlite3_errmsg(db));
			error = 1;
		} else {
			error = 0;
		}
	}
	
	~Sqlite() {
		printf("~Sqlite()\n");
		if (sqlite3_close(db) != SQLITE_OK) {
			fprintf(stderr, "Error with 'sqlite3_close': '%s'\n", sqlite3_errmsg(db));
		}
	}

	int query(HSQUIRRELVM v, char *sql, int array_index) {
		sqlite3_stmt *stmt = NULL;
		if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) == SQLITE_OK) {
			if (array_index <= sq_gettop(v)) {
				int size = sq_getsize(v, array_index);
				sq_pushnull(v);
				for (int n = 0; n < size; n++) {
					sq_next(v, array_index);
					SQObjectType type = sq_gettype(v, -1);
					SQInteger intval;
					SQFloat floatval;
					switch (type) {
						case OT_NULL   : sqlite3_bind_null(stmt, n + 1); break;
						case OT_INTEGER:
						case OT_BOOL   : sq_getinteger(v, -1, &intval); sqlite3_bind_int(stmt, n + 1, intval); break;
						case OT_FLOAT  : sq_getfloat(v, -1, &floatval); sqlite3_bind_double(stmt, n + 1, floatval); break;
						default:
							sq_tostring(v, -1);
							sq_remove(v, -2);
						case OT_STRING : {
							int strlen = sq_getsize(v, -1);
							const SQChar *str = NULL;
							sq_getstring(v, -1, &str);
							sqlite3_bind_blob(stmt, n + 1, str, strlen, NULL);
						} break;
					}
					sq_pop(v, 2);
				}
			}
			sq_newarray(v, 0);
			while (sqlite3_step(stmt) == SQLITE_ROW) {
				sq_newtable(v);
				for (int n = 0, l = sqlite3_column_count(stmt); n < l; n++) {
					sq_pushstring(v, sqlite3_column_name(stmt, n), -1);
					switch (sqlite3_column_type(stmt, n)) {
						case SQLITE_NULL   : sq_pushnull   (v); break;
						case SQLITE_INTEGER: sq_pushinteger(v, (int           )sqlite3_column_int  (stmt, n)    ); break;
						case SQLITE_FLOAT  : sq_pushfloat  (v, (float         )sqlite3_column_double(stmt, n)    ); break;
						case SQLITE_TEXT   : sq_pushstring (v, (const SQChar *)sqlite3_column_text (stmt, n), -1); break;
						case SQLITE_BLOB   : sq_pushstring (v, (const SQChar *)sqlite3_column_blob (stmt, n), sqlite3_column_bytes(stmt, n)); break;
					}
					sq_rawset(v, -3);
				}
				sq_arrayappend(v, -2);
			}
			sqlite3_finalize(stmt);
		} else {
			//fprintf(stderr, "Error with 'sqlite3_exec': '%s'\n", sqlite3_errmsg(db));		
			return sq_throwerror(v, sqlite3_errmsg(db));
		}     

		return 1;
	}
	
	long long int last_insert_id() {
		return sqlite3_last_insert_rowid(db);
	}
};

#define SQTAG_Sqlite (SQUserPointer)0x80000013
DSQ_RELEASE_AUTO(Sqlite);

DSQ_METHOD(Sqlite, constructor)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_STR(2, s, NULL);
	if (s.data == NULL) {
		s.data = (unsigned char *)":memory:";
		s.len = 8;
	}

	Sqlite *self = new Sqlite((char *)s.data);
	sq_setinstanceup(v, 1, self);
	sq_setreleasehook(v, 1, CSQ_RELEASE(Sqlite));
	
	if (self->error) return sq_throwerror(v, sqlite3_errmsg(self->db));
	
	return 0;
}

DSQ_METHOD(Sqlite, _get)
{
	EXTRACT_PARAM_START();

	if (nargs >= 2) {
		EXTRACT_PARAM_SELF(Sqlite);
		EXTRACT_PARAM_STR(2, s, NULL);
		
		char *c = (char *)s.data;
		
		if (strcmp(c, "last_insert_id" ) == 0) RETURN_INT(self->last_insert_id());
	}
	
	return 0;
}

DSQ_METHOD(Sqlite, query)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Sqlite);
	EXTRACT_PARAM_STR(2, s, NULL);

	return self->query(v, (char *)s.data, 3);
}

void register_Sqlite(HSQUIRRELVM v) {
	CLASS_START(Sqlite);
	{
		NEWSLOT_METHOD(Sqlite, constructor, 0, "");
		NEWSLOT_METHOD(Sqlite, _get, 0, "");
		NEWSLOT_METHOD(Sqlite, query, 0, "");
	}
	CLASS_END;
}
