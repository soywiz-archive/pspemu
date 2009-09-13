module sceIOFileManager; // kd/iofilemgr.prx

import kernel;

enum {
	PSP_O_RDONLY  = 0x0001,
	PSP_O_WRONLY  = 0x0002,
	PSP_O_RDWR    = (PSP_O_RDONLY | PSP_O_WRONLY),
	PSP_O_NBLOCK  = 0x0004,
	PSP_O_DIROPEN = 0x0008, // Internal use for dopen
	PSP_O_APPEND  = 0x0100,
	PSP_O_CREAT   = 0x0200,
	PSP_O_TRUNC   = 0x0400,
	PSP_O_EXCL    = 0x0800,
	PSP_O_NOWAIT  = 0x8000,
}

enum {
	PSP_SEEK_SET = 0,
	PSP_SEEK_CUR = 1,
	PSP_SEEK_END = 2,
}

static this() {
	sceExportModule("sceIOFileManager");
}

class IoFileMgrForUser : KLibrary { // 0x00000000
	static void sceIoPollAsync() { // 0x3251EA56
		throw(new UnimplementedFunctionException(0x3251EA56, "sceIoPollAsync"));
	}
	
	static void sceIoWaitAsync() { // 0xE23EEC33
		throw(new UnimplementedFunctionException(0xE23EEC33, "sceIoWaitAsync"));
	}
	
	static void sceIoWaitAsyncCB() { // 0x35DBD746
		throw(new UnimplementedFunctionException(0x35DBD746, "sceIoWaitAsyncCB"));
	}
	
	static void sceIoGetAsyncStat() { // 0xCB05F8D6
		throw(new UnimplementedFunctionException(0xCB05F8D6, "sceIoGetAsyncStat"));
	}
	
	static void sceIoChangeAsyncPriority() { // 0xB293727F
		throw(new UnimplementedFunctionException(0xB293727F, "sceIoChangeAsyncPriority"));
	}
	
	static void sceIoSetAsyncCallback() { // 0xA12A0514
		throw(new UnimplementedFunctionException(0xA12A0514, "sceIoSetAsyncCallback"));
	}
	
	static void sceIoClose() { // 0x810C4BC3
		throw(new UnimplementedFunctionException(0x810C4BC3, "sceIoClose"));
	}
	
	static void sceIoCloseAsync() { // 0xFF5940B6
		throw(new UnimplementedFunctionException(0xFF5940B6, "sceIoCloseAsync"));
	}
	
	static void sceIoOpen() { // 0x109F50BC
		throw(new UnimplementedFunctionException(0x109F50BC, "sceIoOpen"));
	}
	
	static void sceIoOpenAsync() { // 0x89AA9906
		throw(new UnimplementedFunctionException(0x89AA9906, "sceIoOpenAsync"));
	}
	
	static void sceIoRead() { // 0x6A638D83
		throw(new UnimplementedFunctionException(0x6A638D83, "sceIoRead"));
	}
	
	static void sceIoReadAsync() { // 0xA0B5A7C2
		throw(new UnimplementedFunctionException(0xA0B5A7C2, "sceIoReadAsync"));
	}
	
	static void sceIoWrite() { // 0x42EC03AC
		throw(new UnimplementedFunctionException(0x42EC03AC, "sceIoWrite"));
	}
	
	static void sceIoWriteAsync() { // 0x0FACAB19
		throw(new UnimplementedFunctionException(0x0FACAB19, "sceIoWriteAsync"));
	}
	
	static void sceIoLseek() { // 0x27EB27B8
		throw(new UnimplementedFunctionException(0x27EB27B8, "sceIoLseek"));
	}
	
	static void sceIoLseekAsync() { // 0x71B19E77
		throw(new UnimplementedFunctionException(0x71B19E77, "sceIoLseekAsync"));
	}
	
	static void sceIoLseek32() { // 0x68963324
		throw(new UnimplementedFunctionException(0x68963324, "sceIoLseek32"));
	}
	
	static void sceIoLseek32Async() { // 0x1B385D8F
		throw(new UnimplementedFunctionException(0x1B385D8F, "sceIoLseek32Async"));
	}
	
	static void sceIoIoctl() { // 0x63632449
		throw(new UnimplementedFunctionException(0x63632449, "sceIoIoctl"));
	}
	
	static void sceIoIoctlAsync() { // 0xE95A012B
		throw(new UnimplementedFunctionException(0xE95A012B, "sceIoIoctlAsync"));
	}
	
	static void sceIoDopen() { // 0xB29DDF9C
		throw(new UnimplementedFunctionException(0xB29DDF9C, "sceIoDopen"));
	}
	
	static void sceIoDread() { // 0xE3EB004C
		throw(new UnimplementedFunctionException(0xE3EB004C, "sceIoDread"));
	}
	
	static void sceIoDclose() { // 0xEB092469
		throw(new UnimplementedFunctionException(0xEB092469, "sceIoDclose"));
	}
	
	static void sceIoRemove() { // 0xF27A9C51
		throw(new UnimplementedFunctionException(0xF27A9C51, "sceIoRemove"));
	}
	
	static void sceIoMkdir() { // 0x06A70004
		throw(new UnimplementedFunctionException(0x06A70004, "sceIoMkdir"));
	}
	
	static void sceIoRmdir() { // 0x1117C65F
		throw(new UnimplementedFunctionException(0x1117C65F, "sceIoRmdir"));
	}
	
	static void sceIoChdir() { // 0x55F4717D
		throw(new UnimplementedFunctionException(0x55F4717D, "sceIoChdir"));
	}
	
	static void sceIoSync() { // 0xAB96437F
		throw(new UnimplementedFunctionException(0xAB96437F, "sceIoSync"));
	}
	
	static void sceIoGetstat() { // 0xACE946E8
		throw(new UnimplementedFunctionException(0xACE946E8, "sceIoGetstat"));
	}
	
	static void sceIoChstat() { // 0xB8A740F4
		throw(new UnimplementedFunctionException(0xB8A740F4, "sceIoChstat"));
	}
	
	static void sceIoRename() { // 0x779103A0
		throw(new UnimplementedFunctionException(0x779103A0, "sceIoRename"));
	}
	
	static void sceIoDevctl() { // 0x54F5FB11
		throw(new UnimplementedFunctionException(0x54F5FB11, "sceIoDevctl"));
	}
	
	static void sceIoGetDevType() { // 0x08BD7374
		throw(new UnimplementedFunctionException(0x08BD7374, "sceIoGetDevType"));
	}
	
	static void sceIoAssign() { // 0xB2A628C1
		throw(new UnimplementedFunctionException(0xB2A628C1, "sceIoAssign"));
	}
	
	static void sceIoUnassign() { // 0x6D08A871
		throw(new UnimplementedFunctionException(0x6D08A871, "sceIoUnassign"));
	}
	
	static void sceIoCancel() { // 0xE8BC6571
		throw(new UnimplementedFunctionException(0xE8BC6571, "sceIoCancel"));
	}
	
	static this() {
		sceExportLibraryStart("IoFileMgrForUser");
		
		sceExportFunction(0x3251EA56, &sceIoPollAsync);
		sceExportFunction(0xE23EEC33, &sceIoWaitAsync);
		sceExportFunction(0x35DBD746, &sceIoWaitAsyncCB);
		sceExportFunction(0xCB05F8D6, &sceIoGetAsyncStat);
		sceExportFunction(0xB293727F, &sceIoChangeAsyncPriority);
		sceExportFunction(0xA12A0514, &sceIoSetAsyncCallback);
		sceExportFunction(0x810C4BC3, &sceIoClose);
		sceExportFunction(0xFF5940B6, &sceIoCloseAsync);
		sceExportFunction(0x109F50BC, &sceIoOpen);
		sceExportFunction(0x89AA9906, &sceIoOpenAsync);
		sceExportFunction(0x6A638D83, &sceIoRead);
		sceExportFunction(0xA0B5A7C2, &sceIoReadAsync);
		sceExportFunction(0x42EC03AC, &sceIoWrite);
		sceExportFunction(0x0FACAB19, &sceIoWriteAsync);
		sceExportFunction(0x27EB27B8, &sceIoLseek);
		sceExportFunction(0x71B19E77, &sceIoLseekAsync);
		sceExportFunction(0x68963324, &sceIoLseek32);
		sceExportFunction(0x1B385D8F, &sceIoLseek32Async);
		sceExportFunction(0x63632449, &sceIoIoctl);
		sceExportFunction(0xE95A012B, &sceIoIoctlAsync);
		sceExportFunction(0xB29DDF9C, &sceIoDopen);
		sceExportFunction(0xE3EB004C, &sceIoDread);
		sceExportFunction(0xEB092469, &sceIoDclose);
		sceExportFunction(0xF27A9C51, &sceIoRemove);
		sceExportFunction(0x06A70004, &sceIoMkdir);
		sceExportFunction(0x1117C65F, &sceIoRmdir);
		sceExportFunction(0x55F4717D, &sceIoChdir);
		sceExportFunction(0xAB96437F, &sceIoSync);
		sceExportFunction(0xACE946E8, &sceIoGetstat);
		sceExportFunction(0xB8A740F4, &sceIoChstat);
		sceExportFunction(0x779103A0, &sceIoRename);
		sceExportFunction(0x54F5FB11, &sceIoDevctl);
		sceExportFunction(0x08BD7374, &sceIoGetDevType);
		sceExportFunction(0xB2A628C1, &sceIoAssign);
		sceExportFunction(0x6D08A871, &sceIoUnassign);
		sceExportFunction(0xE8BC6571, &sceIoCancel);
		
		sceExportLibraryEnd();
	}
}

class IoFileMgrForKernel : KLibrary { // 0x00000000
	static void sceIoPollAsync() { // 0x3251EA56
		throw(new UnimplementedFunctionException(0x3251EA56, "sceIoPollAsync"));
	}
	
	static void sceIoWaitAsync() { // 0xE23EEC33
		throw(new UnimplementedFunctionException(0xE23EEC33, "sceIoWaitAsync"));
	}
	
	static void sceIoWaitAsyncCB() { // 0x35DBD746
		throw(new UnimplementedFunctionException(0x35DBD746, "sceIoWaitAsyncCB"));
	}
	
	static void sceIoGetAsyncStat() { // 0xCB05F8D6
		throw(new UnimplementedFunctionException(0xCB05F8D6, "sceIoGetAsyncStat"));
	}
	
	static void sceIoChangeAsyncPriority() { // 0xB293727F
		throw(new UnimplementedFunctionException(0xB293727F, "sceIoChangeAsyncPriority"));
	}
	
	static void sceIoSetAsyncCallback() { // 0xA12A0514
		throw(new UnimplementedFunctionException(0xA12A0514, "sceIoSetAsyncCallback"));
	}
	
	static void sceIoClose() { // 0x810C4BC3
		throw(new UnimplementedFunctionException(0x810C4BC3, "sceIoClose"));
	}
	
	static void sceIoCloseAsync() { // 0xFF5940B6
		throw(new UnimplementedFunctionException(0xFF5940B6, "sceIoCloseAsync"));
	}
	
	static void sceIoCloseAll() { // 0xA905B705
		throw(new UnimplementedFunctionException(0xA905B705, "sceIoCloseAll"));
	}
	
	static void sceIoOpen() { // 0x109F50BC
		throw(new UnimplementedFunctionException(0x109F50BC, "sceIoOpen"));
	}
	
	static void sceIoOpenAsync() { // 0x89AA9906
		throw(new UnimplementedFunctionException(0x89AA9906, "sceIoOpenAsync"));
	}
	
	static void sceIoReopen() { // 0x3C54E908
		throw(new UnimplementedFunctionException(0x3C54E908, "sceIoReopen"));
	}
	
	static void sceIoRead() { // 0x6A638D83
		throw(new UnimplementedFunctionException(0x6A638D83, "sceIoRead"));
	}
	
	static void sceIoReadAsync() { // 0xA0B5A7C2
		throw(new UnimplementedFunctionException(0xA0B5A7C2, "sceIoReadAsync"));
	}
	
	static void sceIoWrite() { // 0x42EC03AC
		throw(new UnimplementedFunctionException(0x42EC03AC, "sceIoWrite"));
	}
	
	static void sceIoWriteAsync() { // 0x0FACAB19
		throw(new UnimplementedFunctionException(0x0FACAB19, "sceIoWriteAsync"));
	}
	
	static void sceIoLseek() { // 0x27EB27B8
		throw(new UnimplementedFunctionException(0x27EB27B8, "sceIoLseek"));
	}
	
	static void sceIoLseekAsync() { // 0x71B19E77
		throw(new UnimplementedFunctionException(0x71B19E77, "sceIoLseekAsync"));
	}
	
	static void sceIoLseek32() { // 0x68963324
		throw(new UnimplementedFunctionException(0x68963324, "sceIoLseek32"));
	}
	
	static void sceIoLseek32Async() { // 0x1B385D8F
		throw(new UnimplementedFunctionException(0x1B385D8F, "sceIoLseek32Async"));
	}
	
	static void sceIoIoctl() { // 0x63632449
		throw(new UnimplementedFunctionException(0x63632449, "sceIoIoctl"));
	}
	
	static void sceIoIoctlAsync() { // 0xE95A012B
		throw(new UnimplementedFunctionException(0xE95A012B, "sceIoIoctlAsync"));
	}
	
	static void sceIoDopen() { // 0xB29DDF9C
		throw(new UnimplementedFunctionException(0xB29DDF9C, "sceIoDopen"));
	}
	
	static void sceIoDread() { // 0xE3EB004C
		throw(new UnimplementedFunctionException(0xE3EB004C, "sceIoDread"));
	}
	
	static void sceIoDclose() { // 0xEB092469
		throw(new UnimplementedFunctionException(0xEB092469, "sceIoDclose"));
	}
	
	static void sceIoRemove() { // 0xF27A9C51
		throw(new UnimplementedFunctionException(0xF27A9C51, "sceIoRemove"));
	}
	
	static void sceIoMkdir() { // 0x06A70004
		throw(new UnimplementedFunctionException(0x06A70004, "sceIoMkdir"));
	}
	
	static void sceIoRmdir() { // 0x1117C65F
		throw(new UnimplementedFunctionException(0x1117C65F, "sceIoRmdir"));
	}
	
	static void sceIoChdir() { // 0x55F4717D
		throw(new UnimplementedFunctionException(0x55F4717D, "sceIoChdir"));
	}
	
	static void sceIoSync() { // 0xAB96437F
		throw(new UnimplementedFunctionException(0xAB96437F, "sceIoSync"));
	}
	
	static void sceIoGetstat() { // 0xACE946E8
		throw(new UnimplementedFunctionException(0xACE946E8, "sceIoGetstat"));
	}
	
	static void sceIoChstat() { // 0xB8A740F4
		throw(new UnimplementedFunctionException(0xB8A740F4, "sceIoChstat"));
	}
	
	static void sceIoRename() { // 0x779103A0
		throw(new UnimplementedFunctionException(0x779103A0, "sceIoRename"));
	}
	
	static void sceIoDevctl() { // 0x54F5FB11
		throw(new UnimplementedFunctionException(0x54F5FB11, "sceIoDevctl"));
	}
	
	static void sceIoGetDevType() { // 0x08BD7374
		throw(new UnimplementedFunctionException(0x08BD7374, "sceIoGetDevType"));
	}
	
	static void sceIoAssign() { // 0xB2A628C1
		throw(new UnimplementedFunctionException(0xB2A628C1, "sceIoAssign"));
	}
	
	static void sceIoUnassign() { // 0x6D08A871
		throw(new UnimplementedFunctionException(0x6D08A871, "sceIoUnassign"));
	}
	
	static void sceIoGetThreadCwd() { // 0x411106BA
		throw(new UnimplementedFunctionException(0x411106BA, "sceIoGetThreadCwd"));
	}
	
	static void sceIoChangeThreadCwd() { // 0xCB0A151F
		throw(new UnimplementedFunctionException(0xCB0A151F, "sceIoChangeThreadCwd"));
	}
	
	static void sceIoCancel() { // 0xE8BC6571
		throw(new UnimplementedFunctionException(0xE8BC6571, "sceIoCancel"));
	}
	
	static void sceIoAddDrv() { // 0x8E982A74
		throw(new UnimplementedFunctionException(0x8E982A74, "sceIoAddDrv"));
	}
	
	static void sceIoDelDrv() { // 0xC7F35804
		throw(new UnimplementedFunctionException(0xC7F35804, "sceIoDelDrv"));
	}
	
	static this() {
		sceExportLibraryStart("IoFileMgrForKernel");
		
		sceExportFunction(0x3251EA56, &sceIoPollAsync);
		sceExportFunction(0xE23EEC33, &sceIoWaitAsync);
		sceExportFunction(0x35DBD746, &sceIoWaitAsyncCB);
		sceExportFunction(0xCB05F8D6, &sceIoGetAsyncStat);
		sceExportFunction(0xB293727F, &sceIoChangeAsyncPriority);
		sceExportFunction(0xA12A0514, &sceIoSetAsyncCallback);
		sceExportFunction(0x810C4BC3, &sceIoClose);
		sceExportFunction(0xFF5940B6, &sceIoCloseAsync);
		sceExportFunction(0xA905B705, &sceIoCloseAll);
		sceExportFunction(0x109F50BC, &sceIoOpen);
		sceExportFunction(0x89AA9906, &sceIoOpenAsync);
		sceExportFunction(0x3C54E908, &sceIoReopen);
		sceExportFunction(0x6A638D83, &sceIoRead);
		sceExportFunction(0xA0B5A7C2, &sceIoReadAsync);
		sceExportFunction(0x42EC03AC, &sceIoWrite);
		sceExportFunction(0x0FACAB19, &sceIoWriteAsync);
		sceExportFunction(0x27EB27B8, &sceIoLseek);
		sceExportFunction(0x71B19E77, &sceIoLseekAsync);
		sceExportFunction(0x68963324, &sceIoLseek32);
		sceExportFunction(0x1B385D8F, &sceIoLseek32Async);
		sceExportFunction(0x63632449, &sceIoIoctl);
		sceExportFunction(0xE95A012B, &sceIoIoctlAsync);
		sceExportFunction(0xB29DDF9C, &sceIoDopen);
		sceExportFunction(0xE3EB004C, &sceIoDread);
		sceExportFunction(0xEB092469, &sceIoDclose);
		sceExportFunction(0xF27A9C51, &sceIoRemove);
		sceExportFunction(0x06A70004, &sceIoMkdir);
		sceExportFunction(0x1117C65F, &sceIoRmdir);
		sceExportFunction(0x55F4717D, &sceIoChdir);
		sceExportFunction(0xAB96437F, &sceIoSync);
		sceExportFunction(0xACE946E8, &sceIoGetstat);
		sceExportFunction(0xB8A740F4, &sceIoChstat);
		sceExportFunction(0x779103A0, &sceIoRename);
		sceExportFunction(0x54F5FB11, &sceIoDevctl);
		sceExportFunction(0x08BD7374, &sceIoGetDevType);
		sceExportFunction(0xB2A628C1, &sceIoAssign);
		sceExportFunction(0x6D08A871, &sceIoUnassign);
		sceExportFunction(0x411106BA, &sceIoGetThreadCwd);
		sceExportFunction(0xCB0A151F, &sceIoChangeThreadCwd);
		sceExportFunction(0xE8BC6571, &sceIoCancel);
		sceExportFunction(0x8E982A74, &sceIoAddDrv);
		sceExportFunction(0xC7F35804, &sceIoDelDrv);
		
		sceExportLibraryEnd();
	}
}
