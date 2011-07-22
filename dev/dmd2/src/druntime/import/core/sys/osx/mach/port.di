// D import file generated from 'src\core\sys\osx\mach\port.d'
module core.sys.osx.mach.port;
version (OSX)
{
    extern (C) 
{
    version (X86)
{
    version = i386;
}
    version (X86_64)
{
    version = i386;
}
    version (i386)
{
    alias uint natural_t;
    alias natural_t mach_port_t;
}
}
}
