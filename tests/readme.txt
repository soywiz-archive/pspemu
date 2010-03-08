What is this and how it works?
------------------------------

This is an attempt to create tests in slighly more large/complex programs.

How it works:
- From a .c source and pspsdk (that can be downloaded and installed launched dmd/setup.bat) it generates an elf file.
- That file will call special syscalls 0x2308, 0x2309, 0x230A that will "emit" values generated in the program.
- Each test has a .expected file with the expected emited values.

It will allow for example to make a complex program using GE and after that, generate a crc32 with the value of the
frame buffer memory to check that the context of the screen is the expected.