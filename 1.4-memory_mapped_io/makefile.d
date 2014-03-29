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
     compilation
    */
    auto dFiles = filter!`endsWith(a.name,".d")`(dirEntries("source", SpanMode.depth));
    
    string[] objectFiles = new string[0];
    
    bool success = true;
    
    foreach(dFile; parallel(dFiles, 1))
    {
	string objectFile = "objects" ~ chompPrefix(dFile.name, "source") ~ ".o";
	objectFiles ~= objectFile;
	
	string objectDir = dirName(objectFile);
	if (!exists(objectDir))
	{
	    mkdirRecurse(objectDir);
	}
	
//  	string cmd = 
//  	    "~/ldc2-0.13.0-linux-x86_64/bin/ldc2 " 
//  	    ~ "-march=thumb -mcpu=cortex-m4 "
//  	    ~ "-c "
//  	    ~ dFile.name
//  	    ~ " -of="
//  	    ~ objectFile;
		
    
 	string cmd = 
 	    "~/gdc-arm-none-eabi/bin/arm-none-eabi-gdc " 
 	    ~ "-Isource -mthumb -mcpu=cortex-m4 "
 	    ~ "-fno-emit-moduleinfo -ffunction-sections -fdata-sections "
 	    ~ "-O3 "
 	    ~ "-c "
 	    ~ "-Wa,-adhln=" ~ objectFile ~ ".s -fverbose-asm "
 	    //~ "-S -fverbose-asm -Wa,-adhln "  //generate assembly
 	    ~ dFile.name
 	    ~ " -o "
 	    ~ objectFile;
	
	writeln(cmd);
	    
	auto pid = spawnShell(cmd);
	auto exitCode = wait(pid);
	if (exitCode != 0)
	{
	    success = false;
	}
    }
    
    if (!success)
    {
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
        ~ "-Wl,-T link/link.ld -Wl,-Map binary/memory.map -Wl,--gc-sections ";
        
    foreach(oFile; objectFiles)
    {
	linkCmd ~= " " ~ oFile;
    }
    
    linkCmd ~= " -o binary/start.elf";
    
    writeln(linkCmd);
    
    auto pid = spawnShell(linkCmd);
    auto exitCode = wait(pid);
    
    if (exitCode != 0)
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