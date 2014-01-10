SOURCES:=$(wildcard source/*.d)
OBJECTS:=$(patsubst source/%.d, %.o, $(SOURCES))
OBJECTS:=$(addprefix objects/, $(OBJECTS))
PROGRAM=binary/start.elf

#The implicit make rule for compiling a C program is
# $(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

CC=~/gdc-arm-none-eabi/bin/arm-none-eabi-gdc
CFLAGS=
CXXFLAGS=-Isource -mthumb -mcpu=cortex-m4 -fno-emit-moduleinfo -ffunction-sections -fdata-sections -ggdb -c
LD=~/gdc-arm-none-eabi/bin/arm-none-eabi-ld
LDFLAGS=-T link/link.ld -Map binary/memory.map --gc-sections

all: build $(PROGRAM)

$(PROGRAM): $(OBJECTS)
	$(LD) $(LDFLAGS) $^ -o $@
	
objects/%.o: source/%.d
	$(CC) $(CXXFLAGS) $(CFLAGS) $< -o $@

build:
	@mkdir -p binary
	@mkdir -p objects
	
clean:
	rm -f $(OBJECTS) $(PROGRAM)