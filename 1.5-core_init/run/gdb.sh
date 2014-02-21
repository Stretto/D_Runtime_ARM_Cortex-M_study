~/gcc-arm-none-eabi/bin/arm-none-eabi-gdb ../binary/start.elf -ex "target remote localhost:3333" \
    -ex "monitor arm semihosting enable" 
