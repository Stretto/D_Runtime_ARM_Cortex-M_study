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
    foreach(dFile; parallel(dFiles, 1))
    {
	sourceFiles ~= " " ~ dFile.name;
    }
		
    string objectFile = "objects/start.o";
    string cmd = 
        "~/gdc-arm-none-eabi/bin/arm-none-eabi-gdc " 
        ~ "-Isource -mthumb -mcpu=cortex-m4 "
        ~ "-fno-emit-moduleinfo -ffunction-sections -fdata-sections "
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
        "~/gdc-arm-none-eabi/bin/arm-none-eabi-gdc -nostdlib "
        ~ "-Wl,-T link/link.ld -Wl,-Map binary/memory.map -Wl,--gc-sections "
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
    
}