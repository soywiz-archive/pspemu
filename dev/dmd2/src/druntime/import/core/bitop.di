// D import file generated from 'src\core\bitop.d'
module core.bitop;
nothrow 
{
    pure int bsf(size_t v);

        pure int bsr(size_t v);

        pure int bt(in size_t* p, size_t bitnum);

    int btc(size_t* p, size_t bitnum);
    int btr(size_t* p, size_t bitnum);
    int bts(size_t* p, size_t bitnum);
        pure uint bswap(uint v);

    ubyte inp(uint port_address);
    ushort inpw(uint port_address);
    uint inpl(uint port_address);
    ubyte outp(uint port_address, ubyte value);
    ushort outpw(uint port_address, ushort value);
    uint outpl(uint port_address, uint value);
    int popcnt(uint x)
{
x = x - (x >> 1 & 1431655765);
x = ((x & -858993460u) >> 2) + (x & 858993459);
x += x >> 4;
x &= 252645135;
x += x >> 8;
x &= 16711935;
x += x >> 16;
x &= 65535;
return x;
}
    debug (UnitTest)
{
    }
    uint bitswap(uint x);
    debug (UnitTest)
{
    }
}
