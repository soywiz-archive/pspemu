module kernel.loader.pbp;

import kernel.common;

class PBP {
	enum Files { param_sfo, icon0_png, icon1_pmf, pic0_png, pic1_png, snd0_at3, psp_data, psar_data }
	
	align(4) struct Header {
		char[4] magic;
		uint    ver;
		uint[8] offsets;
	}
	
	Header header;
	Stream pbps;
	Stream[8] streams;
	
	this(Stream pbps) {
		this.pbps = (pbps = new SliceStream(pbps));
		pbps.readExact(&header, header.sizeof);
		if (header.magic != "\0PBP") throw(new Exception("Not a PBP file"));
		if (header.ver != 0x10000) throw(new Exception("Invalid PBP version"));
		uint[9] offsets2;
		offsets[0..8] = header.offsets;
		offsets[8] = pbps.size;
		for (int n = 0; n < 8; n++) streams[n] = new SliceStream(pbps, offsets[n], offsets[n + 1]);
	}
}