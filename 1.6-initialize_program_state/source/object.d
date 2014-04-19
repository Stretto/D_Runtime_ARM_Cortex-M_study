// object.d

module object;

alias size_t    = typeof(int.sizeof);
alias ptrdiff_t = typeof(cast(void*)0 - cast(void*)0);

alias string = immutable(char)[];

class Object
{ }

class TypeInfo
{ 
    const(void)[] init() nothrow pure const @safe { return null; }
}

class TypeInfo_Class : TypeInfo
{
    
    ubyte[68] ignore;
}

class TypeInfo_Struct : TypeInfo
{
    ubyte[52] ignore;
}

class TypeInfo_Array : TypeInfo
{  
    ubyte[1] ignore;
}

class TypeInfo_Enum : TypeInfo
{  
    ubyte[20] ignore;
}

bool _xopEquals(in void*, in void*)
{
    //assert(false, "Not Implemented");
    //throw new Error("TypeInfo.equals is not implemented");
    return true;
}

class TypeInfo_i : TypeInfo
{

}

///////////////////////////////////////////////////////////////////////////////
// ModuleInfo
///////////////////////////////////////////////////////////////////////////////


// enum
// {
//     MIctorstart = 0x1, // we've started constructing it
//     MIctordone = 0x2, // finished construction
//     MIstandalone = 0x4, // module ctor does not depend on other module
//                         // ctors being done first
//     MItlsctor = 8,
//     MItlsdtor = 0x10,
//     MIctor = 0x20,
//     MIdtor = 0x40,
//     MIxgetMembers = 0x80,
//     MIictor = 0x100,
//     MIunitTest = 0x200,
//     MIimportedModules = 0x400,
//     MIlocalClasses = 0x800,
//     MIname = 0x1000,
// }
// 
// private @property size_t length(immutable char* p) pure nothrow
// {
//     uint l = 0;
//     while(*p != '\0')
//     {
//         l++;
//     }
//     
//     return l;
// }
// 
// 
// struct ModuleInfo
// {
//     import rt.minfo;
//     
//     uint _flags;
//     uint _index; // index into _moduleinfo_array[]
// 
//     private void* addrOf(int flag) nothrow pure
//     in
//     {
//         assert(flag >= MItlsctor && flag <= MIname);
//         assert(!(flag & (flag - 1)) && !(flag & ~(flag - 1) << 1));
//     }
//     body
//     {
//         void* p = cast(void*)&this + ModuleInfo.sizeof;
// 
//         if (flags & MItlsctor)
//         {
//             if (flag == MItlsctor) return p;
//             p += typeof(tlsctor).sizeof;
//         }
//         if (flags & MItlsdtor)
//         {
//             if (flag == MItlsdtor) return p;
//             p += typeof(tlsdtor).sizeof;
//         }
//         if (flags & MIctor)
//         {
//             if (flag == MIctor) return p;
//             p += typeof(ctor).sizeof;
//         }
//         if (flags & MIdtor)
//         {
//             if (flag == MIdtor) return p;
//             p += typeof(dtor).sizeof;
//         }
//         if (flags & MIxgetMembers)
//         {
//             if (flag == MIxgetMembers) return p;
//             p += typeof(xgetMembers).sizeof;
//         }
//         if (flags & MIictor)
//         {
//             if (flag == MIictor) return p;
//             p += typeof(ictor).sizeof;
//         }
//         if (flags & MIunitTest)
//         {
//             if (flag == MIunitTest) return p;
//             p += typeof(unitTest).sizeof;
//         }
//         if (flags & MIimportedModules)
//         {
//             if (flag == MIimportedModules) return p;
//             p += size_t.sizeof + *cast(size_t*)p * typeof(importedModules[0]).sizeof;
//         }
//         if (flags & MIlocalClasses)
//         {
//             if (flag == MIlocalClasses) return p;
//             p += size_t.sizeof + *cast(size_t*)p * typeof(localClasses[0]).sizeof;
//         }
//         if (true || flags & MIname) // always available for now
//         {
//             if (flag == MIname) return p;
//             p += (cast(immutable char*)p).length;
//         }
//         assert(0);
//     }
// 
//     @property uint index() nothrow pure { return _index; }
//     @property void index(uint i) nothrow pure { _index = i; }
// 
//     @property uint flags() nothrow pure { return _flags; }
//     @property void flags(uint f) nothrow pure { _flags = f; }
// 
//     @property void function() tlsctor() nothrow pure
//     {
//         return flags & MItlsctor ? *cast(typeof(return)*)addrOf(MItlsctor) : null;
//     }
// 
//     @property void function() tlsdtor() nothrow pure
//     {
//         return flags & MItlsdtor ? *cast(typeof(return)*)addrOf(MItlsdtor) : null;
//     }
// 
//     @property void* xgetMembers() nothrow pure
//     {
//         return flags & MIxgetMembers ? *cast(typeof(return)*)addrOf(MIxgetMembers) : null;
//     }
// 
//     @property void function() ctor() nothrow pure
//     {
//         return flags & MIctor ? *cast(typeof(return)*)addrOf(MIctor) : null;
//     }
// 
//     @property void function() dtor() nothrow pure
//     {
//         return flags & MIdtor ? *cast(typeof(return)*)addrOf(MIdtor) : null;
//     }
// 
//     @property void function() ictor() nothrow pure
//     {
//         return flags & MIictor ? *cast(typeof(return)*)addrOf(MIictor) : null;
//     }
// 
//     @property void function() unitTest() nothrow pure
//     {
//         return flags & MIunitTest ? *cast(typeof(return)*)addrOf(MIunitTest) : null;
//     }
// 
//     @property ModuleInfo*[] importedModules() nothrow pure
//     {
//         if (flags & MIimportedModules)
//         {
//             auto p = cast(size_t*)addrOf(MIimportedModules);
//             return (cast(ModuleInfo**)(p + 1))[0 .. *p];
//         }
//         return null;
//     }
// 
//     @property TypeInfo_Class[] localClasses() nothrow pure
//     {
//         if (flags & MIlocalClasses)
//         {
//             auto p = cast(size_t*)addrOf(MIlocalClasses);
//             return (cast(TypeInfo_Class*)(p + 1))[0 .. *p];
//         }
//         return null;
//     }
// 
//     @property string name() nothrow pure
//     {
//         if (true || flags & MIname) // always available for now
//         {
//             auto p = cast(immutable char*)addrOf(MIname);
//             return p[0 .. p.length];
//         }
//     }
// 
//     alias int delegate(ref ModuleInfo*) ApplyDg;
// 
//     static int opApply(scope ApplyDg dg)
//     {
//         return rt.minfo.moduleinfos_apply(dg);
//     }
// }