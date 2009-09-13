@echo off
SET PSPSDK=c:\devkitPro\devkitPSP\psp\sdk
psp-gcc -I. -I"%PSPSDK%\include" -g3 -ggdb3 -gstabs3 -O2 -Wall -D_PSP_FW_VERSION=150  -L. -L"%PSPSDK%\lib"   main.c -lSDL -lpspaudio -lpsphprm -lpspgu -lm -lpspdebug -lpspdisplay -lpspge -lpspctrl -lpspsdk -lc -lpspnet -lpspnet_inet -lpspnet_apctl -lpspnet_resolver -lpsputility -lpspuser -lpspkernel -o sdl.elf
psp-fixup-imports sdl.elf
mksfo "Sample Menu Grafico" PARAM.SFO
psp-strip sdl.elf -o sdl_strip.elf
pack-pbp EBOOT.PBP PARAM.SFO NULL NULL NULL NULL NULL  sdl.elf NULL