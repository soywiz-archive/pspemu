module pspemu.hle.vfs.ZipFileSystemTest;

import pspemu.hle.vfs.ZipFileSystem;

import tests.Test;

class ZipFileSystemTest : Test {
	ZipArchive    zipArchive;
	ZipFileSystem zipFileSystem;
	
	this() {
		
	}
	
	void setUp() {
		zipArchive    = new ZipArchive(cast(void[])import("test.zip"));
		zipFileSystem = new ZipFileSystem(zipArchive);
	}
	
	void testOpenInvalid() {
		expectException!FileNotExistsException({
			zipFileSystem.open("unexistant.file", FileOpenMode.In, FileAccessMode.All);
		});
	}
	
	void testOpenValid() {
		assertEquals("Hello World", cast(string)zipFileSystem.readAll("file1.txt"));
	}
	
	void testOpenInFolder() {
		assertEquals("Hello World Two!", cast(string)zipFileSystem.readAll("folder/file3.txt"));
	}
	
	void testGetStatFile() {
		FileStat fileStat = zipFileSystem.getstat("folder/file4.txt");
		assertEquals(false, fileStat.isDir);
		assertEquals(24, fileStat.size);
	}

	void testGetStatDirectory() {
		FileStat fileStat = zipFileSystem.getstat("folder");
		assertEquals(true, fileStat.isDir);
	}
}