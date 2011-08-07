module pspemu.hle.vfs.VirtualFileSystemTest;

import pspemu.hle.vfs.VirtualFileSystem;

import tests.Test;

class VirtualFileSystemTest : Test {
	void testCompiles() {
		scope vfs = new VirtualFileSystem();
		vfs.init();
		
		expectException!NotImplementedException({
			vfs.open("dummy", FileOpenMode.In, FileAccessMode.All);
		});
		
		vfs.exit();
	}
}