module pspemu.formats.Lzr;

import std.stdio, std.stream, std.string, std.file;

class LZR {
	enum Error : int {
		BUFFER_SIZE   = 0x80000104, // Output buffer is not enough.
		INPUT_STREAM  = 0x80000108, // 
		MEM_ALLOC     = 0x800200D9,
		UNSUPPORTED   = 0x80020325,
	}
	
	enum Encode : byte {
		UNCOMPRESSED = 0xFF,
	}
	
	enum DataType : ubyte {
		_08BIT = 0x05,
		_16BIT = 0x06,
		_32BIT = 0x07,
		_64BIT = 0x08,
	}

	static protected void LZRFillBuffer(uint *test_mask, uint *mask, uint *buffer, ubyte **next_in) {
		/* if necessary: fill up in buffer and shift mask */
		if (*test_mask <= 0x00FFFFFFu) {
			(*buffer) = ((*buffer) << 8) + *(*next_in)++;
			*mask = *test_mask << 8;
		}
	}

	static protected ubyte LZRNextBit(ubyte *buf_ptr1, int *number, uint *test_mask, uint *mask, uint *buffer, ubyte **next_in) {
		/* extract and return next bit of information from in stream, update buffer and mask */
		LZRFillBuffer(test_mask, mask, buffer, next_in);
		uint value = (*mask >> 8) * (*buf_ptr1);
		if (test_mask != mask) *test_mask = value;
		*buf_ptr1 -= *buf_ptr1 >> 3;
		if (number) (*number) <<= 1;
		if (*buffer < value) {
			*mask = value;		
			*buf_ptr1 += 31;		
			if (number) (*number)++;
			return 1;
		} else {
			*buffer -= value;
			*mask -= value;
			return 0;
		}
	}

	static protected int LZRGetNumber(byte n_bits, ubyte *buf_ptr, char inc, char *flag, uint *mask, uint *buffer, ubyte **next_in) {
		/* extract and return a number (consisting of n_bits bits) from in stream */
		int number = 1;
		if (n_bits >= 3) {
			LZRNextBit(buf_ptr+3*inc, &number, mask, mask, buffer, next_in);
			if (n_bits >= 4) {
				LZRNextBit(buf_ptr+3*inc, &number, mask, mask, buffer, next_in);
				if (n_bits >= 5) {
					LZRFillBuffer(mask, mask, buffer, next_in);
					for (; n_bits >= 5; n_bits--) {
						number <<= 1;
						(*mask) >>= 1;
						if (*buffer < *mask) number++; else (*buffer) -= *mask;
					}
				}
			}
		}
		*flag = LZRNextBit(buf_ptr, &number, mask, mask, buffer, next_in);
		if (n_bits >= 1) {
			LZRNextBit(buf_ptr+inc, &number, mask, mask, buffer, next_in);
			if (n_bits >= 2) {
				LZRNextBit(buf_ptr+2*inc, &number, mask, mask, buffer, next_in);
			}
		}	
		return number;
	}

	/**
	 * Decompress a LZR stream.
	 *
	 * @param out - Array to decompressed stream
	 * @param in  - Array to LZR stream
	 *
	 * @returns The number of decompressed bytes on success; A negative error code on failure
	 */
	static public int LZRDecompress(ubyte[] _out, ubyte[] _in) { 
		ubyte **next_in, *tmp, *next_out, *out_end, *next_seq, *seq_end, *buf_ptr1, *buf_ptr2;
		ubyte last_char = 0;
		int seq_len, seq_off, n_bits, buf_off = 0, i, j;	
		uint mask = 0xFFFFFFFF, test_mask;
		char flag;
		
		byte type = *(byte*)_in.ptr;
		uint buffer = ((uint)*(ubyte*)(_in.ptr+1) << 24) + 
							  ((uint)*(ubyte*)(_in.ptr+2) << 16) + 
							  ((uint)*(ubyte*)(_in.ptr+3) <<  8) + 
							  ((uint)*(ubyte*)(_in.ptr+4)      );	
		next_in = (in_end) ? in_end : &tmp; //use user provided counter if available
		*next_in = _in.ptr + 5;
		next_out = _out.ptr;
		out_end  = _out.ptr + _out.length;

		if (type < 0) { 
			
			/* copy from stream without decompression */

			seq_end = next_out + buffer;
			if (seq_end > out_end) return Error.BUFFER_SIZE;
			while (next_out < seq_end) {
				*next_out++ = *(*next_in)++;
			} 
			(*next_in)++; //skip 1 byte padding
			return next_out - (ubyte*)_out.ptr; 

		}

		/* create and init buffer */
		ubyte *buf = (ubyte*)malloc(2800);
		if (!buf) return Error.MEM_ALLOC;
		for (i = 0; i < 2800; i++) buf[i] = 0x80;

		while (1) {

			buf_ptr1 = buf + buf_off + 2488;
			if (!LZRNextBit(buf_ptr1, 0, &mask, &mask, &buffer, next_in)) {

				/* single new char */

				if (buf_off > 0) buf_off--;
				if (next_out == out_end) return Error.BUFFER_SIZE;
				buf_ptr1 = buf + (((((((int)(next_out - (ubyte*)_out.ptr)) & 0x07) << 8) + last_char) >> type) & 0x07) * 0xFF - 0x01;
				for (j = 1; j <= 0xFF; ) {
					LZRNextBit(buf_ptr1+j, &j, &mask, &mask, &buffer, next_in);
				}
				*next_out++ = j;

			} else {                       

				/* sequence of chars that exists in out stream */

				/* find number of bits of sequence length */			
				test_mask = mask;
				n_bits = -1;
				do {
					buf_ptr1 += 8;
					flag = LZRNextBit(buf_ptr1, 0, &test_mask, &mask, &buffer, next_in);
					n_bits += flag;
				} while ((flag != 0) && (n_bits < 6));
				
				/* find sequence length */
				buf_ptr2 = buf + n_bits + 2033;
				j = 64;
				if ((flag != 0) || (n_bits >= 0)) {
					buf_ptr1 = buf + (n_bits << 5) + (((((int)(next_out - (ubyte*)_out.ptr)) << n_bits) & 0x03) << 3) + buf_off + 2552;
					seq_len = LZRGetNumber(n_bits, buf_ptr1, 8, &flag, &mask, &buffer, next_in);
					if (seq_len == 0xFF) return next_out - (ubyte*)_out.ptr; //end of data stream
					if ((flag != 0) || (n_bits > 0)) {
						buf_ptr2 += 56;
						j = 352;
					}
				} else {
					seq_len = 1;
				}

				/* find number of bits of sequence offset */			
				i = 1;
				do {
					n_bits = (i << 4) - j;
					flag = LZRNextBit(buf_ptr2 + (i << 3), &i, &mask, &mask, &buffer, next_in);
				} while (n_bits < 0);

				/* find sequence offset */
				if (flag || (n_bits > 0)) {
					if (!flag) n_bits -= 8;
					seq_off = LZRGetNumber(n_bits/8, buf+n_bits+2344, 1, &flag, &mask, &buffer, next_in);
				} else {
					seq_off = 1;
				}

				/* copy sequence */
				next_seq = next_out - seq_off;
				if (next_seq < (ubyte*)_out.ptr) return Error.INPUT_STREAM;
				seq_end = next_out + seq_len + 1;
				if (seq_end > out_end) return Error.BUFFER_SIZE;
				buf_off = ((((int)(seq_end - (ubyte*)_out.ptr))+1) & 0x01) + 0x06;
				do {
					*next_out++ = *next_seq++;
				} while (next_out < seq_end);

			}
			last_char = *(next_out-1);		
		}
	}

	/**
	 * Encode a LZR stream.
	 *
	 * @param out  - An array for the encoded stream
	 * @param in   - An array with the raw data stream
	 * @param type - Type of raw data stream (only Encode.UNCOMPRESSED is supported)
	 *
	 * @returns The number of decompressed bytes on success; A negative error code on failure
	 */
	static public int LZRCompress(ubyte[] _out, ubyte[] _in, Encode type) {
		ubyte *next_in, *next_out, *out_end, *seq_end;
		next_in  = _in.ptr;
		next_out = _out.ptr;
		out_end  = _out + _out.length;

		if (type == Encode.UNCOMPRESSED) {
			
			/* copy from stream without compression */

			seq_end = next_out + in_length + 6;
			if (seq_end > out_end) return Error.BUFFER_SIZE;
			*next_out++ = type;
			*next_out++ = in_length >> 24;
			*next_out++ = in_length >> 16;
			*next_out++ = in_length >>  8;
			*next_out++ = in_length      ;
			while (next_out < seq_end - 1) {
				*next_out++ = *next_in++;
			} 
			*next_out++ = 0; //add 1 byte padding
			return next_out - (ubyte*)out; 

		}

		/* real lzr compression not yet supported */

		return Error.UNSUPPORTED;
	}

}

/*
libLZR - A library to de- and encode LZR streams (as used in the Sony PSP firmware)

libLZR Version 0.11 by BenHur - http://www.psp-programming.com/benhur


-=Info=-

The library de- and encodes LZR streams (as used in the Sony PSP firmware).

Decompression results should be identical to Sonys internal decompression algorithm.
Please report incompatible streams to benhur(at)alpenjodel(dot)de.

Compression currently does not actually compress the data, but only produces a valid 
LZR stream. Future versions of this library might implement real compression.


-=Samples=-

There is currently no sample included due to the simple nature of this library.
A typical usage might be (out points to output array, in points to LZR stream):
int ret = LZRDecompress(out, out_capacity, in, NULL);


-=Dependencies=-

none


-=Changelog=-

0.11  - bug fixed where certain LZR streams were not decompressed correctly
      - potential bug fixed that could prevent correct decompression of certain LZR streams
      - initial public release

0.10  - initial release (not public)


-=Credits=-

Dark_Alex for his help with the LZR format


-=License=-

This is released under the Creative Commons Attribution-Share Alike 3.0 License.
See LICENSE for more information.


-=Atttribution=-

With accordance to the license, the following must be adhered to:

If you use the code in any way, shape or form you must attribute it in the following way:

'Uses libLZR by BenHur'

If you alter the code in any way, shape or form you must also release the updated code
under the same license.

See http://creativecommons.org/licenses/by-sa/3.0/ if you need more information.
 
*/
