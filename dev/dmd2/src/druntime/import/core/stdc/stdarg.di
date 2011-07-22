// D import file generated from 'src\core\stdc\stdarg.d'
module core.stdc.stdarg;
@system version (X86)
{
    alias void* va_list;
    template va_start(T)
{
void va_start(out va_list ap, ref T parmn)
{
ap = cast(va_list)(cast(void*)&parmn + (T.sizeof + (int).sizeof - 1 & ~((int).sizeof - 1)));
}
}
    template va_arg(T)
{
T va_arg(ref va_list ap)
{
T arg = *cast(T*)ap;
ap = cast(va_list)(cast(void*)ap + (T.sizeof + (int).sizeof - 1 & ~((int).sizeof - 1)));
return arg;
}
}
    template va_arg(T)
{
void va_arg(ref va_list ap, ref T parmn)
{
parmn = *cast(T*)ap;
ap = cast(va_list)(cast(void*)ap + (T.sizeof + (int).sizeof - 1 & ~((int).sizeof - 1)));
}
}
    template va_arg()
{
void va_arg(ref va_list ap, TypeInfo ti, void* parmn)
{
auto p = ap;
auto tsize = ti.tsize();
ap = cast(void*)(cast(size_t)p + (tsize + size_t.sizeof - 1 & ~(size_t.sizeof - 1)));
parmn[0..tsize] = p[0..tsize];
}
}
    void va_end(va_list ap)
{
}
    void va_copy(out va_list dest, va_list src)
{
dest = src;
}
}
else
{
    version (X86_64)
{
    struct __va_list
{
    uint offset_regs = 6 * 8;
    uint offset_fpregs = 6 * 8 + 8 * 16;
    void* stack_args;
    void* reg_args;
}
    struct __va_argsave_t
{
    size_t[6] regs;
    real[8] fpregs;
    __va_list va;
}
    alias void* va_list;
    template va_start(T)
{
void va_start(out va_list ap, ref T parmn)
{
ap = &parmn.va;
}
}
    template va_arg(T)
{
T va_arg(va_list ap)
{
T a;
va_arg(ap,a);
return a;
}
}
    template va_arg(T)
{
void va_arg(va_list apx, ref T parmn)
{
__va_list* ap = cast(__va_list*)apx;
static if(is(T U == __argTypes))
{
static if(U.length == 0 || T.sizeof > 16 || U[0].sizeof > 8)
{
auto p = cast(size_t)ap.stack_args + T.alignof - 1 & ~(T.alignof - 1);
ap.stack_args = cast(void*)(p + (T.sizeof + size_t.sizeof - 1 & ~(size_t.sizeof - 1)));
parmn = *cast(T*)p;
}
else
{
static if(U.length == 1)
{
alias U[0] T1;
static if(is(T1 == double) || is(T1 == float))
{
if (ap.offset_fpregs < 6 * 8 + 16 * 8)
{
parmn = *cast(T*)(ap.reg_args + ap.offset_fpregs);
ap.offset_fpregs += 16;
}
else
{
parmn = *cast(T*)ap.stack_args;
ap.stack_args += T1.sizeof + size_t.sizeof - 1 & ~(size_t.sizeof - 1);
}
}
else
{
if (ap.offset_regs < 6 * 8 && T.sizeof <= 8)
{
parmn = *cast(T*)(ap.reg_args + ap.offset_regs);
ap.offset_regs += 8;
}
else
{
auto p = cast(size_t)ap.stack_args + T.alignof - 1 & ~(T.alignof - 1);
ap.stack_args = cast(void*)(p + (T.sizeof + size_t.sizeof - 1 & ~(size_t.sizeof - 1)));
parmn = *cast(T*)p;
}
}

}
else
{
static if(U.length == 2)
{
alias U[0] T1;
alias U[1] T2;
static if(is(T1 == double) || is(T1 == float))
{
if (ap.offset_fpregs < 6 * 8 + 16 * 8)
{
*cast(T1*)&parmn = *cast(T1*)(ap.reg_args + ap.offset_fpregs);
ap.offset_fpregs += 16;
}
else
{
*cast(T1*)&parmn = *cast(T1*)ap.stack_args;
ap.stack_args += T1.sizeof + size_t.sizeof - 1 & ~(size_t.sizeof - 1);
}
}
else
{
if (ap.offset_regs < 6 * 8 && T1.sizeof <= 8)
{
*cast(T1*)&parmn = *cast(T1*)(ap.reg_args + ap.offset_regs);
ap.offset_regs += 8;
}
else
{
*cast(T1*)&parmn = *cast(T1*)ap.stack_args;
ap.stack_args += 8;
}
}

auto p = cast(void*)&parmn + 8;
static if(is(T2 == double) || is(T2 == float))
{
if (ap.offset_fpregs < 6 * 8 + 16 * 8)
{
*cast(T2*)p = *cast(T2*)(ap.reg_args + ap.offset_fpregs);
ap.offset_fpregs += 16;
}
else
{
*cast(T2*)p = *cast(T2*)ap.stack_args;
ap.stack_args += T2.sizeof + size_t.sizeof - 1 & ~(size_t.sizeof - 1);
}
}
else
{
void* a = void;
if (ap.offset_regs < 6 * 8 && T2.sizeof <= 8)
{
a = ap.reg_args + ap.offset_regs;
ap.offset_regs += 8;
}
else
{
a = ap.stack_args;
ap.stack_args += 8;
}
const sz2 = T.sizeof - 8;
p[0..sz2] = a[0..sz2];
}

}
else
{
static assert(false);
}

}

}

}
else
{
static assert(false,"not a valid argument type for va_arg");
}

}
}
    template va_arg()
{
void va_arg(va_list apx, TypeInfo ti, void* parmn)
{
__va_list* ap = cast(__va_list*)apx;
TypeInfo arg1,arg2;
if (!ti.argTypes(arg1,arg2))
{
if (arg1 && arg1.tsize() <= 8)
{
auto tsize = arg1.tsize();
void* p;
auto s = arg1.toString();
if (s == "double" || s == "float" || s == "idouble" || s == "ifloat")
{
if (ap.offset_fpregs < 6 * 8 + 16 * 8)
{
p = ap.reg_args + ap.offset_fpregs;
ap.offset_fpregs += 16;
}
else
{
p = ap.stack_args;
ap.stack_args += tsize + size_t.sizeof - 1 & ~(size_t.sizeof - 1);
}
}
else
{
if (ap.offset_regs < 6 * 8)
{
p = ap.reg_args + ap.offset_regs;
ap.offset_regs += 8;
}
else
{
p = ap.stack_args;
ap.stack_args += 8;
}
}
parmn[0..tsize] = p[0..tsize];
if (arg2)
{
parmn += 8;
tsize = arg2.tsize();
s = arg2.toString();
if (s == "double" || s == "float" || s == "idouble" || s == "ifloat")
{
if (ap.offset_fpregs < 6 * 8 + 16 * 8)
{
p = ap.reg_args + ap.offset_fpregs;
ap.offset_fpregs += 16;
}
else
{
p = ap.stack_args;
ap.stack_args += tsize + size_t.sizeof - 1 & ~(size_t.sizeof - 1);
}
}
else
{
if (ap.offset_regs < 6 * 8)
{
p = ap.reg_args + ap.offset_regs;
ap.offset_regs += 8;
}
else
{
p = ap.stack_args;
ap.stack_args += 8;
}
}
tsize = ti.tsize() - 8;
parmn[0..tsize] = p[0..tsize];
}
}
else
{
auto talign = ti.talign();
auto tsize = ti.tsize();
auto p = cast(void*)(cast(size_t)ap.stack_args + talign - 1 & ~(talign - 1));
ap.stack_args = cast(void*)(cast(size_t)p + (tsize + size_t.sizeof - 1 & ~(size_t.sizeof - 1)));
parmn[0..tsize] = p[0..tsize];
}
}
else
{
assert(false,"not a valid argument type for va_arg");
}
}
}
    void va_end(va_list ap)
{
}
    void va_copy(out va_list dest, va_list src)
{
dest = src;
}
}
else
{
    static assert(false,"Unsupported platform");
}
}

