/* 
	KIRK ENGINE CODE
	Thx for coyotebean, Davee, hitchhikr, kgsws, Mathieulh, SilverSpring
	
	Ported from:
	http://code.google.com/p/kirk-engine/source/browse/trunk/kirk_engine.c
*/
module pspemu.core.kirk.kirk_engine;

import pspemu.core.kirk.crypto;

import std.stdio, std.file, std.stream, std.random;

typedef ubyte u8;
typedef ushort u16;
typedef uint u32;

//Kirk return values
enum {
	KIRK_OPERATION_SUCCESS = 0,
	KIRK_NOT_ENABLED = 1,
	KIRK_INVALID_MODE = 2,
	KIRK_HEADER_HASH_INVALID = 3,
	KIRK_DATA_HASH_INVALID = 4,
	KIRK_SIG_CHECK_INVALID = 5,
	KIRK_UNK_1 = 6,
	KIRK_UNK_2 = 7,
	KIRK_UNK_3 = 8,
	KIRK_UNK_4 = 9,
	KIRK_UNK_5 = 0xA,
	KIRK_UNK_6 = 0xB,
	KIRK_NOT_INITIALIZED = 0xC,
	KIRK_INVALID_OPERATION = 0xD,
	KIRK_INVALID_SEED_CODE = 0xE,
	KIRK_INVALID_SIZE = 0xF,
	KIRK_DATA_SIZE_ZERO = 0x10,
}

struct KIRK_AES128CBC_HEADER {
	int mode;      // 0
	int unk_4;     // 4
	int unk_8;     // 8
	int keyseed;   // C
	int data_size; // 10
	
	static assert (this.sizeof == 0x14);
}

struct KIRK_CMD1_HEADER {
	u8 AES_key[16];            // 0
	u8 CMAC_key[16];           // 10
	u8 CMAC_header_hash[16];   // 20
	u8 CMAC_data_hash[16];     // 30
	u8 unused[32];             // 40
	u32 mode;                  // 60
	u8 unk3[12];               // 64
	u32 data_size;             // 70
	u32 data_offset;           // 74  
	u8 unk4[8];                // 78
	u8 unk5[16];               // 80
	
	static assert (this.sizeof == 0x90);
}

struct KIRK_SHA1_HEADER {
    u32 data_size; //0
	
	static assert (this.sizeof == 4);
}

//mode passed to sceUtilsBufferCopyWithRange
enum {
	KIRK_CMD_DECRYPT_PRIVATE = 1,
	KIRK_CMD_ENCRYPT_IV_0 = 4,
	KIRK_CMD_ENCRYPT_IV_FUSE = 5,
	KIRK_CMD_ENCRYPT_IV_USER = 6,
	KIRK_CMD_DECRYPT_IV_0 = 7,
	KIRK_CMD_DECRYPT_IV_FUSE = 8,
	KIRK_CMD_DECRYPT_IV_USER = 9,
	KIRK_CMD_PRIV_SIG_CHECK = 10,
	KIRK_CMD_SHA1_HASH = 11,
}

//"mode" in header
enum {
	KIRK_MODE_CMD1 = 1,
	KIRK_MODE_CMD2 = 2,
	KIRK_MODE_CMD3 = 3,
	KIRK_MODE_ENCRYPT_CBC = 4,
	KIRK_MODE_DECRYPT_CBC = 5,
}

//sceUtilsBufferCopyWithRange errors
enum {
	SUBCWR_NOT_16_ALGINED = 0x90A,
	SUBCWR_HEADER_HASH_INVALID = 0x920,
	SUBCWR_BUFFER_TOO_SMALL = 0x1000,
}

/*
  // Private Sig + Cipher
  0x01: Super-Duper decryption (no inverse)
  0x02: Encrypt Operation (inverse of 0x03)
  0x03: Decrypt Operation (inverse of 0x02)

  // Cipher
  0x04: Encrypt Operation (inverse of 0x07) (IV=0)
  0x05: Encrypt Operation (inverse of 0x08) (IV=FuseID)
  0x06: Encrypt Operation (inverse of 0x09) (IV=UserDefined)
  0x07: Decrypt Operation (inverse of 0x04)
  0x08: Decrypt Operation (inverse of 0x05)
  0x09: Decrypt Operation (inverse of 0x06)
	  
  // Sig Gens
  0x0A: Private Signature Check (checks for private SCE sig)
  0x0B: SHA1 Hash
  0x0C: Mul1
  0x0D: Mul2
  0x0E: Random Number Gen
  0x0F: (absolutely no idea  could be KIRK initialization)
  0x10: Signature Gen
  // Sig Checks
  0x11: Signature Check (checks for generated sigs)
  0x12: Certificate Check (idstorage signatures)
*/


/* ------------------------- KEY VAULT ------------------------- */

u8[16] kirk1_key;
u8[16] kirk7_key03;
u8[16] kirk7_key04;
u8[16] kirk7_key05;
u8[16] kirk7_key0C;
u8[16] kirk7_key0D;
u8[16] kirk7_key0E;
u8[16] kirk7_key0F;
u8[16] kirk7_key10;
u8[16] kirk7_key11;
u8[16] kirk7_key12;
u8[16] kirk7_key38;
u8[16] kirk7_key39;
u8[16] kirk7_key3A;
u8[16] kirk7_key4B; //1.xx game eboot.bin
u8[16] kirk7_key53;
u8[16] kirk7_key57;
u8[16] kirk7_key5D;
u8[16] kirk7_key63;
u8[16] kirk7_key64;

static this() {
	auto fname = "kirk_keys.bin";
	if (std.file.exists(fname)) {
		scope f = new BufferedFile(fname);
		{
			f.read(cast(ubyte[])kirk1_key);
			f.read(cast(ubyte[])kirk7_key03);
			f.read(cast(ubyte[])kirk7_key04);
			f.read(cast(ubyte[])kirk7_key05);
			f.read(cast(ubyte[])kirk7_key0C);
			f.read(cast(ubyte[])kirk7_key0D);
			f.read(cast(ubyte[])kirk7_key0E);
			f.read(cast(ubyte[])kirk7_key0F);
			f.read(cast(ubyte[])kirk7_key10);
			f.read(cast(ubyte[])kirk7_key11);
			f.read(cast(ubyte[])kirk7_key12);
			f.read(cast(ubyte[])kirk7_key38);
			f.read(cast(ubyte[])kirk7_key39);
			f.read(cast(ubyte[])kirk7_key3A);
			f.read(cast(ubyte[])kirk7_key4B);
			f.read(cast(ubyte[])kirk7_key53);
			f.read(cast(ubyte[])kirk7_key57);
			f.read(cast(ubyte[])kirk7_key5D);
			f.read(cast(ubyte[])kirk7_key63);
			f.read(cast(ubyte[])kirk7_key64);
		}
		f.close();
	} else {
		writefln("Can't find '%s'", fname);
	}
}

/* ------------------------- KEY VAULT END ------------------------- */

/* ------------------------- INTERNAL STUFF ------------------------- */

struct header_keys { //small struct for temporary keeping AES & CMAC key from CMD1 header
    u8 AES[16];
    u8 CMAC[16];
}

u8 fuseID[16]; //Emulate FUSEID	

AES_ctx aes_kirk1; //global

char is_kirk_initialized; //"init" emulation

/* ------------------------- INTERNAL STUFF END ------------------------- */


/* ------------------------- IMPLEMENTATION ------------------------- */

int kirk_CMD0(ubyte* outbuff, ubyte* inbuff, int size, int generate_trash) {
	if (is_kirk_initialized == 0) return KIRK_NOT_INITIALIZED;
	
    KIRK_CMD1_HEADER* header = cast(KIRK_CMD1_HEADER*)outbuff;
    
	outbuff[0..size] = inbuff[0..size];
    
	if (header.mode != KIRK_MODE_CMD1) return KIRK_INVALID_MODE;
	
	header_keys *keys = cast(header_keys *)outbuff; //0-15 AES key, 16-31 CMAC key
	
	//FILL PREDATA WITH RANDOM DATA
	if (generate_trash) kirk_CMD14(outbuff + KIRK_CMD1_HEADER.sizeof, header.data_offset);
	
	//Make sure data is 16 aligned
	int chk_size = header.data_size;
	if(chk_size % 16) chk_size += 16 - (chk_size % 16);
	
	//ENCRYPT DATA
	AES_ctx k1;
	AES_set_key(&k1, cast(const ubyte *)keys.AES.ptr, 128);
	
	AES_cbc_encrypt(&k1, inbuff+KIRK_CMD1_HEADER.sizeof+header.data_offset, outbuff+KIRK_CMD1_HEADER.sizeof+header.data_offset, chk_size);
	
	//CMAC HASHES
	AES_ctx cmac_key;
	AES_set_key(&cmac_key, cast(const ubyte *)keys.CMAC, 128);
	    
	ubyte cmac_header_hash[16];
	ubyte cmac_data_hash[16];
		
	AES_CMAC(&cmac_key, outbuff + 0x60, 0x30, cmac_header_hash.ptr);
	AES_CMAC(&cmac_key, outbuff + 0x60, 0x30 + chk_size + header.data_offset, cmac_data_hash.ptr);
	
	header.CMAC_header_hash[0..16] = (cast(u8 *)cmac_header_hash.ptr)[0..16];
	header.CMAC_data_hash[0..16] = (cast(u8 *)cmac_data_hash.ptr)[0..16];
	
	//ENCRYPT KEYS
	
	AES_cbc_encrypt(&aes_kirk1, inbuff, outbuff, 16*2);
	return KIRK_OPERATION_SUCCESS;
}

int kirk_CMD1(ubyte* outbuff, ubyte* inbuff, int size, int do_check) {
	if (is_kirk_initialized == 0) return KIRK_NOT_INITIALIZED;
	
    KIRK_CMD1_HEADER* header = cast(KIRK_CMD1_HEADER*)inbuff;
	if(header.mode != KIRK_MODE_CMD1) return KIRK_INVALID_MODE;
	
	header_keys keys; //0-15 AES key, 16-31 CMAC key
	
	AES_cbc_decrypt(&aes_kirk1, inbuff, cast(ubyte *)&keys, 16 * 2); //decrypt AES & CMAC key to temp buffer
	
	// HOAX WARRING! I have no idea why the hash check on last IPL block fails, so there is an option to disable checking
	if (do_check) {
		int ret = kirk_CMD10(inbuff, size);
		if (ret != KIRK_OPERATION_SUCCESS) return ret;
	}
	
	AES_ctx k1;
	AES_set_key(&k1, cast(const ubyte *)keys.AES.ptr, 128);
	
	AES_cbc_decrypt(&k1, inbuff + KIRK_CMD1_HEADER.sizeof + header.data_offset, outbuff, header.data_size);	
	
	return KIRK_OPERATION_SUCCESS;
}

int kirk_CMD4(ubyte* outbuff, ubyte* inbuff, int size) {
	if (is_kirk_initialized == 0) return KIRK_NOT_INITIALIZED;
	
	KIRK_AES128CBC_HEADER *header = cast(KIRK_AES128CBC_HEADER*)inbuff;
	if(header.mode != KIRK_MODE_ENCRYPT_CBC) return KIRK_INVALID_MODE;
	if(header.data_size == 0) return KIRK_DATA_SIZE_ZERO;
	
	u8* key = kirk_4_7_get_key(header.keyseed);
	if (key == cast(u8*)KIRK_INVALID_SIZE) return KIRK_INVALID_SIZE;
	
	//Set the key
	AES_ctx aesKey;
	AES_set_key(&aesKey, cast(ubyte *)key, 128);
 	AES_cbc_encrypt(&aesKey, inbuff+KIRK_AES128CBC_HEADER.sizeof, outbuff, size);
	
	return KIRK_OPERATION_SUCCESS;
}

int kirk_CMD7(ubyte* outbuff, ubyte* inbuff, int size) {
	if (is_kirk_initialized == 0) return KIRK_NOT_INITIALIZED;
	
	KIRK_AES128CBC_HEADER *header = cast(KIRK_AES128CBC_HEADER*)inbuff;
	if(header.mode != KIRK_MODE_DECRYPT_CBC) return KIRK_INVALID_MODE;
	if(header.data_size == 0) return KIRK_DATA_SIZE_ZERO;
	
	u8* key = kirk_4_7_get_key(header.keyseed);
	if (key == cast(u8*)KIRK_INVALID_SIZE) return KIRK_INVALID_SIZE;
	
	//Set the key
	AES_ctx aesKey;
	AES_set_key(&aesKey, cast(ubyte *)key, 128);
	
 	AES_cbc_decrypt(&aesKey, inbuff+KIRK_AES128CBC_HEADER.sizeof, outbuff, size);
	
	return KIRK_OPERATION_SUCCESS;
}

int kirk_CMD10(ubyte* inbuff, int insize) {
	if (is_kirk_initialized == 0) return KIRK_NOT_INITIALIZED;
	
    KIRK_CMD1_HEADER* header = cast(KIRK_CMD1_HEADER*)inbuff;
    
	if (!(header.mode == KIRK_MODE_CMD1 || header.mode == KIRK_MODE_CMD2 || header.mode == KIRK_MODE_CMD3)) return KIRK_INVALID_MODE;
	if (header.data_size == 0) return KIRK_DATA_SIZE_ZERO;
	
	if(header.mode == KIRK_MODE_CMD1)
	{
        header_keys keys; //0-15 AES key, 16-31 CMAC key
        
        AES_cbc_decrypt(&aes_kirk1, inbuff, cast(ubyte*)&keys, 32); //decrypt AES & CMAC key to temp buffer
	    
	    AES_ctx cmac_key;
	    AES_set_key(&cmac_key, cast(ubyte *)keys.CMAC, 128);
	    
		u8 cmac_header_hash[16];
		u8 cmac_data_hash[16];
		
		AES_CMAC(&cmac_key, inbuff + 0x60, 0x30, cast(ubyte *)cmac_header_hash.ptr);
	
		//Make sure data is 16 aligned
		int chk_size = header.data_size;
		if(chk_size % 16) chk_size += 16 - (chk_size % 16);
		AES_CMAC(&cmac_key, inbuff + 0x60, 0x30 + chk_size + header.data_offset, cast(ubyte *)cmac_data_hash.ptr);
	
		if (cmac_header_hash[0..16] != header.CMAC_header_hash[0..16]) {
            writefln("header hash invalid\n");
            return KIRK_HEADER_HASH_INVALID;
        }

		if (cmac_data_hash[0..16] != header.CMAC_data_hash[0..16]) {
            writefln("data hash invalid\n");
            return KIRK_DATA_HASH_INVALID;
        }
	
		return KIRK_OPERATION_SUCCESS;
	}
	return KIRK_SIG_CHECK_INVALID; //Checks for cmd 2 & 3 not included right now
}

int kirk_CMD11(ubyte* outbuff, ubyte* inbuff, int size) {
    if (is_kirk_initialized == 0) return KIRK_NOT_INITIALIZED;
	KIRK_SHA1_HEADER *header = cast(KIRK_SHA1_HEADER *)inbuff;
	if(header.data_size == 0 || size == 0) return KIRK_DATA_SIZE_ZERO;
	
    SHA1Context sha;
    SHA1Reset(&sha);
    size <<= 4;
    size >>= 4;
	size = size < header.data_size ? size : header.data_size;
    SHA1Input(&sha, inbuff+KIRK_SHA1_HEADER.sizeof, size);
	outbuff[0..16] = (cast(ubyte *)sha.Message_Digest.ptr)[0..16];
    return KIRK_OPERATION_SUCCESS;
}

int kirk_CMD14(ubyte* outbuff, int size) {
    if (is_kirk_initialized == 0) return KIRK_NOT_INITIALIZED;
    for (int i = 0; i < size; i++) outbuff[i] = rand_gen.front & 0xFF;
    return KIRK_OPERATION_SUCCESS;
}

Mt19937 rand_gen;

int kirk_init() {
    AES_set_key(&aes_kirk1, cast(const ubyte *)kirk1_key.ptr, 128);
	is_kirk_initialized = 1;
	//srand(time(0));
	rand_gen.seed(0);
    return KIRK_OPERATION_SUCCESS;
}

u8* kirk_4_7_get_key(int key_type) {
    switch(key_type) {
		case(0x03): return kirk7_key03.ptr; break;
		case(0x04): return kirk7_key04.ptr; break;
		case(0x05): return kirk7_key05.ptr; break;
		case(0x0C): return kirk7_key0C.ptr; break;
		case(0x0D): return kirk7_key0D.ptr; break;
		case(0x0E): return kirk7_key0E.ptr; break;
		case(0x0F): return kirk7_key0F.ptr; break;
		case(0x10): return kirk7_key10.ptr; break;
		case(0x11): return kirk7_key11.ptr; break;
		case(0x12): return kirk7_key12.ptr; break;
		case(0x38): return kirk7_key38.ptr; break;
		case(0x39): return kirk7_key39.ptr; break;
		case(0x3A): return kirk7_key3A.ptr; break;
		case(0x4B): return kirk7_key4B.ptr; break;
		case(0x53): return kirk7_key53.ptr; break;
		case(0x57): return kirk7_key57.ptr; break;
		case(0x5D): return kirk7_key5D.ptr; break;
		case(0x63): return kirk7_key63.ptr; break;
		case(0x64): return kirk7_key64.ptr; break;
		default: return cast(u8*)KIRK_INVALID_SIZE; break; //need to get the real error code for that, placeholder now :)
	}
}

int kirk_CMD1_ex(ubyte* outbuff, ubyte* inbuff, int size, KIRK_CMD1_HEADER* header) {
    scope ubyte[] buffer = new ubyte[size];
	*cast(KIRK_CMD1_HEADER *)(buffer.ptr) = *header;
	(cast(ubyte *)(buffer.ptr + KIRK_CMD1_HEADER.sizeof))[0..header.data_size] = inbuff[0..header.data_size];
	return kirk_CMD1(outbuff, buffer.ptr, size, 1);
}

int sceUtilsSetFuseID(ubyte* fuse) {
	fuseID[0..16] = cast(u8[])fuse[0..16];
	return 0;
}

int sceUtilsBufferCopyWithRange(ubyte* outbuff, int outsize, ubyte* inbuff, int insize, int cmd) {
    switch(cmd) {
		case KIRK_CMD_DECRYPT_PRIVATE: 
             if (insize % 16) return SUBCWR_NOT_16_ALGINED;
             int ret = kirk_CMD1(outbuff, inbuff, insize, 1); 
             if(ret == KIRK_HEADER_HASH_INVALID) return SUBCWR_HEADER_HASH_INVALID;
             return ret;
		case KIRK_CMD_ENCRYPT_IV_0: return kirk_CMD4(outbuff, inbuff, insize);
		case KIRK_CMD_DECRYPT_IV_0: return kirk_CMD7(outbuff, inbuff, insize);
		case KIRK_CMD_PRIV_SIG_CHECK: return kirk_CMD10(inbuff, insize);
		case KIRK_CMD_SHA1_HASH: return kirk_CMD11(outbuff, inbuff, insize);
		default:
	}
	return -1;
}

//int main() { return 0; }