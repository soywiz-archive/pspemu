This is a set of special programs that start and ends very fast and calls Kprintf system method.
The aim for these programs is to test some features that emulator should execute in a proper way.

Running the emulator with --test modifier will search for .expected files inside this folder.
Then it will run el .elf file associated with the same base name as the .expected file.
The generated output by the .elf file calling Kprintf method will be compared with the .expected contents.
It will output OK or FAIL for that program if the output is the expected or not. IF not it will show the differences between the outputs.

Because it uses the standard Kprintf method these tests should work on other emulators.