// run with rdmd

module makefile;

import std.process;
import std.stdio;
import std.file;
import std.algorithm;
import std.parallelism;
import std.string;
import std.process;
import std.path;
import std.range;

void main()
{
    /************************************************************************************
     Compile
    */
    auto dFiles = filter!`endsWith(a.name,".d")`(dirEntries("source", SpanMode.depth));
    
    bool success = true;
    
    // concatenate all source files for inclusion in command line.  This is dene because
    // GDC doesn't yet support LTO for fully inlining functions compiled to separate
    // object files
    string sourceFiles = "";
    foreach(dFile; dFiles)
    {
	sourceFiles ~= " " ~ dFile.name;
    }
		
    string objectFile = "objects/start.o";
    string cmd = 
        "~/gdc-arm-none-eabi/bin/arm-none-eabi-gdc " 
        ~ "-Isource -mthumb -mcpu=cortex-m4 "
        ~ "-fno-emit-moduleinfo "
        ~ "-ffunction-sections -fdata-sections "
        ~ "-O3 "
        ~ "-c "
        ~ "-Wa,-adhln=" ~ objectFile ~ ".s -fverbose-asm "
        ~ sourceFiles
        ~ " -o "
        ~ objectFile;

    writeln(cmd);

    auto pid = spawnShell(cmd);
    if (wait(pid) != 0)
    {
        success = false;
        writeln("Compilation failed");
	return;
    }
    
    /************************************************************************************
     link 
    */
    string binaryDir = "binary";
    if (!exists(binaryDir))
    {
        mkdirRecurse(binaryDir);
    }
    
    string linkCmd = 
        "~/gdc-arm-none-eabi/bin/arm-none-eabi-gdc -nostdlib"
        ~ " -Wl,-static"
        ~ " -Wl,-T link/link.ld"
        ~ " -Wl,-Map binary/memory.map" 
        ~ " -Wl,--gc-sections "
        ~ " -L/home/mike/gdc-arm-none-eabi/lib/gcc/arm-none-eabi/4.8.2 "
        //~ " /home/mike/gdc-arm-none-eabi/lib/gcc/arm-none-eabi/4.8.2/crti.o "
        //~ " /home/mike/gdc-arm-none-eabi/lib/gcc/arm-none-eabi/4.8.2/crtbegin.o "
        //~ "  "
        //~ " /home/mike/gdc-arm-none-eabi/lib/gcc/arm-none-eabi/4.8.2/crtend.o "
        //~ " /home/mike/gdc-arm-none-eabi/lib/gcc/arm-none-eabi/4.8.2/crtn.o "
        ~ objectFile
        ~ " -o binary/start.elf";
    
    writeln(linkCmd);
    
    pid = spawnShell(linkCmd);
    
    if (wait(pid) != 0)
    {
	writeln("Link failed");
	return;
    }
    
    /************************************************************************************
     Generate assembly listing
    */
    string listingCmd = "~/gdc-arm-none-eabi/bin/arm-none-eabi-objdump -d -S -l binary/start.elf > binary/start.elf.s 2>&1";
    writeln(listingCmd);
    pid = spawnShell(listingCmd);
    wait(pid);
    
    /************************************************************************************
     Display executable size
    */
    string sizeCmd = "~/gdc-arm-none-eabi/bin/arm-none-eabi-size binary/start.elf";
    writeln(sizeCmd);
    pid = spawnShell(sizeCmd);
    wait(pid);
    
    /************************************************************************************
     Generate symbol table
    */
    string symbolTableCmd = "~/gdc-arm-none-eabi/bin/arm-none-eabi-nm -S --size-sort binary/start.elf > binary/start.elf.nm 2>&1";
    writeln(symbolTableCmd);
    pid = spawnShell(symbolTableCmd);
    wait(pid);
    
    /************************************************************************************
     Generate symbol table
    */
    string symbolTable2Cmd = "~/gdc-arm-none-eabi/bin/arm-none-eabi-objdump -t binary/start.elf > binary/start.elf.objdump 2>&1";
    writeln(symbolTable2Cmd);
    pid = spawnShell(symbolTable2Cmd);
    wait(pid);
    
    /************************************************************************************
     Generate symbol table
    */
    string x = "~/gdc-arm-none-eabi/bin/arm-none-eabi-readelf -x .minfo binary/start.elf > binary/start.elf.readelf 2>&1";
    writeln(x);
    pid = spawnShell(x);
    wait(pid);
    
}