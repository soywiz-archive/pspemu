// D import file generated from 'src\core\atomic.d'
module core.atomic;
version (D_InlineAsm_X86)
{
    version = AsmX86;
    version = AsmX86_32;
    enum has64BitCAS = true;
}
version (D_InlineAsm_X86_64)
{
    version = AsmX86;
    version = AsmX86_64;
    enum has64BitCAS = true;
}
private template HeadUnshared(T)
{
static if(is(T U : shared(U*)))
{
    alias shared(U)* HeadUnshared;
}
else
{
    alias T HeadUnshared;
}
}

version (AsmX86)
{
    private template atomicValueIsProperlyAligned(T)
{
bool atomicValueIsProperlyAligned(size_t addr)
{
return addr % T.sizeof == 0;
}
}

}
version (D_Ddoc)
{
    template atomicOp(string op,T,V1) if (__traits(compiles,mixin("val" ~ op ~ "mod")))
{
HeadUnshared!(T) atomicOp(ref shared T val, V1 mod)
{
return HeadUnshared!(T).init;
}
}
    template cas(T,V1,V2) if (__traits(compiles,mixin("*here = writeThis")))
{
bool cas(shared(T)* here, const V1 ifThis, const V2 writeThis)
{
return false;
}
}
    template atomicLoad(msync ms = msync.seq,T)
{
HeadUnshared!(T) atomicLoad(ref const shared T val)
{
return HeadUnshared!(T).init;
}
}
    template atomicStore(msync ms = msync.seq,T,V1) if (__traits(compiles,mixin("val = newval")))
{
void atomicStore(ref shared T val, V1 newval)
{
}
}
    enum msync 
{
raw,
acq,
rel,
seq,
}
}
else
{
    version (AsmX86_32)
{
    template atomicOp(string op,T,V1) if (__traits(compiles,mixin("val" ~ op ~ "mod")))
{
HeadUnshared!(T) atomicOp(ref shared T val, V1 mod)
in
{
static if(T.sizeof > size_t.sizeof)
{
assert(atomicValueIsProperlyAligned!(size_t)(cast(size_t)&val));
}
else
{
assert(atomicValueIsProperlyAligned!(T)(cast(size_t)&val));
}

}
body
{
static if(op == "+" || op == "-" || op == "*" || op == "/" || op == "%" || op == "^^" || op == "&" || op == "|" || op == "^" || op == "<<" || op == ">>" || op == ">>>" || op == "~" || op == "==" || op == "!=" || op == "<" || op == "<=" || op == ">" || op == ">=")
{
HeadUnshared!(T) get = atomicLoad!(msync.raw)(val);
mixin("return get " ~ op ~ " mod;");
}
else
{
static if(op == "+=" || op == "-=" || op == "*=" || op == "/=" || op == "%=" || op == "^^=" || op == "&=" || op == "|=" || op == "^=" || op == "<<=" || op == ">>=" || op == ">>>=")
{
HeadUnshared!(T) get,set;
do
{
get = (set = atomicLoad!(msync.raw)(val));
mixin("set " ~ op ~ " mod;");
}
while (!cas(&val,get,set));
return set;
}
else
{
static assert(false,"Operation not supported.");
}

}

}
}
    template cas(T,V1,V2) if (__traits(compiles,mixin("*here = writeThis")))
{
bool cas(shared(T)* here, const V1 ifThis, const V2 writeThis)
in
{
static if(T.sizeof > size_t.sizeof)
{
assert(atomicValueIsProperlyAligned!(size_t)(cast(size_t)here));
}
else
{
assert(atomicValueIsProperlyAligned!(T)(cast(size_t)here));
}

}
body
{
static if(T.sizeof == (byte).sizeof)
{
asm { mov DL,writeThis; }
asm { mov AL,ifThis; }
asm { mov ECX,here; }
asm { lock; }
asm { cmpxchg[ECX],DL; }
asm { setz AL; }
}
else
{
static if(T.sizeof == (short).sizeof)
{
asm { mov DX,writeThis; }
asm { mov AX,ifThis; }
asm { mov ECX,here; }
asm { lock; }
asm { cmpxchg[ECX],DX; }
asm { setz AL; }
}
else
{
static if(T.sizeof == (int).sizeof)
{
asm { mov EDX,writeThis; }
asm { mov EAX,ifThis; }
asm { mov ECX,here; }
asm { lock; }
asm { cmpxchg[ECX],EDX; }
asm { setz AL; }
}
else
{
static if(T.sizeof == (long).sizeof && has64BitCAS)
{
asm { push EDI; }
asm { push EBX; }
asm { lea EDI,writeThis; }
asm { mov EBX,[EDI]; }
asm { mov ECX,4[EDI]; }
asm { lea EDI,ifThis; }
asm { mov EAX,[EDI]; }
asm { mov EDX,4[EDI]; }
asm { mov EDI,here; }
asm { lock; }
asm { cmpxchg8b[EDI]; }
asm { setz AL; }
asm { pop EBX; }
asm { pop EDI; }
}
else
{
static assert(false,"Invalid template type specified.");
}

}

}

}

}
}
    enum msync 
{
raw,
acq,
rel,
seq,
}
    private 
{
    template isHoistOp(msync ms)
{
enum bool isHoistOp = ms == msync.acq || ms == msync.seq;
}
    template isSinkOp(msync ms)
{
enum bool isSinkOp = ms == msync.rel || ms == msync.seq;
}
    template needsLoadBarrier(msync ms)
{
const bool needsLoadBarrier = ms != msync.raw;

}
    template needsStoreBarrier(msync ms)
{
const bool needsStoreBarrier = ms == msync.seq || isHoistOp!(ms);

}
}
    template atomicLoad(msync ms = msync.seq,T)
{
HeadUnshared!(T) atomicLoad(ref const shared T val)
{
static if(T.sizeof == (byte).sizeof)
{
static if(needsLoadBarrier!(ms))
{
asm { mov DL,0; }
asm { mov AL,0; }
asm { mov ECX,val; }
asm { lock; }
asm { cmpxchg[ECX],DL; }
}
else
{
asm { mov EAX,val; }
asm { mov AL,[EAX]; }
}

}
else
{
static if(T.sizeof == (short).sizeof)
{
static if(needsLoadBarrier!(ms))
{
asm { mov DX,0; }
asm { mov AX,0; }
asm { mov ECX,val; }
asm { lock; }
asm { cmpxchg[ECX],DX; }
}
else
{
asm { mov EAX,val; }
asm { mov AX,[EAX]; }
}

}
else
{
static if(T.sizeof == (int).sizeof)
{
static if(needsLoadBarrier!(ms))
{
asm { mov EDX,0; }
asm { mov EAX,0; }
asm { mov ECX,val; }
asm { lock; }
asm { cmpxchg[ECX],EDX; }
}
else
{
asm { mov EAX,val; }
asm { mov EAX,[EAX]; }
}

}
else
{
static if(T.sizeof == (long).sizeof && has64BitCAS)
{
asm { push EDI; }
asm { push EBX; }
asm { mov EBX,0; }
asm { mov ECX,0; }
asm { mov EAX,0; }
asm { mov EDX,0; }
asm { mov EDI,val; }
asm { lock; }
asm { cmpxchg8b[EDI]; }
asm { pop EBX; }
asm { pop EDI; }
}
else
{
static assert(false,"Invalid template type specified.");
}

}

}

}

}
}
    template atomicStore(msync ms = msync.seq,T,V1) if (__traits(compiles,mixin("val = newval")))
{
void atomicStore(ref shared T val, V1 newval)
{
static if(T.sizeof == (byte).sizeof)
{
static if(needsStoreBarrier!(ms))
{
asm { mov EAX,val; }
asm { mov DL,newval; }
asm { lock; }
asm { xchg[EAX],DL; }
}
else
{
asm { mov EAX,val; }
asm { mov DL,newval; }
asm { mov[EAX],DL; }
}

}
else
{
static if(T.sizeof == (short).sizeof)
{
static if(needsStoreBarrier!(ms))
{
asm { mov EAX,val; }
asm { mov DX,newval; }
asm { lock; }
asm { xchg[EAX],DX; }
}
else
{
asm { mov EAX,val; }
asm { mov DX,newval; }
asm { mov[EAX],DX; }
}

}
else
{
static if(T.sizeof == (int).sizeof)
{
static if(needsStoreBarrier!(ms))
{
asm { mov EAX,val; }
asm { mov EDX,newval; }
asm { lock; }
asm { xchg[EAX],EDX; }
}
else
{
asm { mov EAX,val; }
asm { mov EDX,newval; }
asm { mov[EAX],EDX; }
}

}
else
{
static if(T.sizeof == (long).sizeof && has64BitCAS)
{
asm { push EDI; }
asm { push EBX; }
asm { lea EDI,newval; }
asm { mov EBX,[EDI]; }
asm { mov ECX,4[EDI]; }
asm { mov EDI,val; }
asm { mov EAX,[EDI]; }
asm { mov EDX,4[EDI]; }
L1:
asm { lock; }
asm { cmpxchg8b[EDI]; }
asm { jne L1; }
asm { pop EBX; }
asm { pop EDI; }
}
else
{
static assert(false,"Invalid template type specified.");
}

}

}

}

}
}
}
else
{
    version (AsmX86_64)
{
    template atomicOp(string op,T,V1) if (__traits(compiles,mixin("val" ~ op ~ "mod")))
{
HeadUnshared!(T) atomicOp(ref shared T val, V1 mod)
in
{
static if(T.sizeof > size_t.sizeof)
{
assert(atomicValueIsProperlyAligned!(size_t)(cast(size_t)&val));
}
else
{
assert(atomicValueIsProperlyAligned!(T)(cast(size_t)&val));
}

}
body
{
static if(op == "+" || op == "-" || op == "*" || op == "/" || op == "%" || op == "^^" || op == "&" || op == "|" || op == "^" || op == "<<" || op == ">>" || op == ">>>" || op == "~" || op == "==" || op == "!=" || op == "<" || op == "<=" || op == ">" || op == ">=")
{
HeadUnshared!(T) get = atomicLoad!(msync.raw)(val);
mixin("return get " ~ op ~ " mod;");
}
else
{
static if(op == "+=" || op == "-=" || op == "*=" || op == "/=" || op == "%=" || op == "^^=" || op == "&=" || op == "|=" || op == "^=" || op == "<<=" || op == ">>=" || op == ">>>=")
{
HeadUnshared!(T) get,set;
do
{
get = (set = atomicLoad!(msync.raw)(val));
mixin("set " ~ op ~ " mod;");
}
while (!cas(&val,get,set));
return set;
}
else
{
static assert(false,"Operation not supported.");
}

}

}
}
    template cas(T,V1,V2) if (__traits(compiles,mixin("*here = writeThis")))
{
bool cas(shared(T)* here, const V1 ifThis, const V2 writeThis)
in
{
static if(T.sizeof > size_t.sizeof)
{
assert(atomicValueIsProperlyAligned!(size_t)(cast(size_t)here));
}
else
{
assert(atomicValueIsProperlyAligned!(T)(cast(size_t)here));
}

}
body
{
static if(T.sizeof == (byte).sizeof)
{
asm { mov DL,writeThis; }
asm { mov AL,ifThis; }
asm { mov RCX,here; }
asm { lock; }
asm { cmpxchg[RCX],DL; }
asm { setz AL; }
}
else
{
static if(T.sizeof == (short).sizeof)
{
asm { mov DX,writeThis; }
asm { mov AX,ifThis; }
asm { mov RCX,here; }
asm { lock; }
asm { cmpxchg[RCX],DX; }
asm { setz AL; }
}
else
{
static if(T.sizeof == (int).sizeof)
{
asm { mov EDX,writeThis; }
asm { mov EAX,ifThis; }
asm { mov RCX,here; }
asm { lock; }
asm { cmpxchg[RCX],EDX; }
asm { setz AL; }
}
else
{
static if(T.sizeof == (long).sizeof)
{
asm { mov RDX,writeThis; }
asm { mov RAX,ifThis; }
asm { mov RCX,here; }
asm { lock; }
asm { cmpxchg[RCX],RDX; }
asm { setz AL; }
}
else
{
static assert(false,"Invalid template type specified.");
}

}

}

}

}
}
    enum msync 
{
raw,
acq,
rel,
seq,
}
    private 
{
    template isHoistOp(msync ms)
{
enum bool isHoistOp = ms == msync.acq || ms == msync.seq;
}
    template isSinkOp(msync ms)
{
enum bool isSinkOp = ms == msync.rel || ms == msync.seq;
}
    template needsLoadBarrier(msync ms)
{
const bool needsLoadBarrier = ms != msync.raw;

}
    template needsStoreBarrier(msync ms)
{
const bool needsStoreBarrier = ms == msync.seq || isHoistOp!(ms);

}
}
    template atomicLoad(msync ms = msync.seq,T)
{
HeadUnshared!(T) atomicLoad(ref const shared T val)
{
static if(T.sizeof == (byte).sizeof)
{
static if(needsLoadBarrier!(ms))
{
asm { mov DL,0; }
asm { mov AL,0; }
asm { mov RCX,val; }
asm { lock; }
asm { cmpxchg[RCX],DL; }
}
else
{
asm { mov RAX,val; }
asm { mov AL,[RAX]; }
}

}
else
{
static if(T.sizeof == (short).sizeof)
{
static if(needsLoadBarrier!(ms))
{
asm { mov DX,0; }
asm { mov AX,0; }
asm { mov RCX,val; }
asm { lock; }
asm { cmpxchg[RCX],DX; }
}
else
{
asm { mov RAX,val; }
asm { mov AX,[RAX]; }
}

}
else
{
static if(T.sizeof == (int).sizeof)
{
static if(needsLoadBarrier!(ms))
{
asm { mov EDX,0; }
asm { mov EAX,0; }
asm { mov RCX,val; }
asm { lock; }
asm { cmpxchg[RCX],EDX; }
}
else
{
asm { mov RAX,val; }
asm { mov EAX,[RAX]; }
}

}
else
{
static if(T.sizeof == (long).sizeof)
{
static if(needsLoadBarrier!(ms))
{
asm { mov RDX,0; }
asm { mov RAX,0; }
asm { mov RCX,val; }
asm { lock; }
asm { cmpxchg[RCX],RDX; }
}
else
{
asm { mov RAX,val; }
asm { mov RAX,[RAX]; }
}

}
else
{
static assert(false,"Invalid template type specified.");
}

}

}

}

}
}
    template atomicStore(msync ms = msync.seq,T,V1) if (__traits(compiles,mixin("val = newval")))
{
void atomicStore(ref shared T val, V1 newval)
{
static if(T.sizeof == (byte).sizeof)
{
static if(needsStoreBarrier!(ms))
{
asm { mov RAX,val; }
asm { mov DL,newval; }
asm { lock; }
asm { xchg[RAX],DL; }
}
else
{
asm { mov RAX,val; }
asm { mov DL,newval; }
asm { mov[RAX],DL; }
}

}
else
{
static if(T.sizeof == (short).sizeof)
{
static if(needsStoreBarrier!(ms))
{
asm { mov RAX,val; }
asm { mov DX,newval; }
asm { lock; }
asm { xchg[RAX],DX; }
}
else
{
asm { mov RAX,val; }
asm { mov DX,newval; }
asm { mov[RAX],DX; }
}

}
else
{
static if(T.sizeof == (int).sizeof)
{
static if(needsStoreBarrier!(ms))
{
asm { mov RAX,val; }
asm { mov EDX,newval; }
asm { lock; }
asm { xchg[RAX],EDX; }
}
else
{
asm { mov RAX,val; }
asm { mov EDX,newval; }
asm { mov[RAX],EDX; }
}

}
else
{
static if(T.sizeof == (long).sizeof && has64BitCAS)
{
static if(needsStoreBarrier!(ms))
{
asm { mov RAX,val; }
asm { mov RDX,newval; }
asm { lock; }
asm { xchg[RAX],RDX; }
}
else
{
asm { mov RAX,val; }
asm { mov RDX,newval; }
asm { mov[RAX],RDX; }
}

}
else
{
static assert(false,"Invalid template type specified.");
}

}

}

}

}
}
}
}
}
version (unittest)
{
    template testCAS(T)
{
void testCAS(T val = T.init + 1)
{
T base;
shared(T) atom;
assert(base != val);
assert(atom == base);
assert(cas(&atom,base,val));
assert(atom == val);
assert(!cas(&atom,base,base));
assert(atom == val);
}
}
    template testLoadStore(msync ms = msync.seq,T)
{
void testLoadStore(T val = T.init + 1)
{
T base;
shared(T) atom;
assert(base != val);
assert(atom == base);
atomicStore!(ms)(atom,val);
base = atomicLoad!(ms)(atom);
assert(base == val);
assert(atom == val);
}
}
    template testType(T)
{
void testType(T val = T.init + 1)
{
static if(!is(T U : U*))
{
testCAS!(T)(val);
}

testLoadStore!(msync.seq,T)(val);
testLoadStore!(msync.raw,T)(val);
}
}
    }
