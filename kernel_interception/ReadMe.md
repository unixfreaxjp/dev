# olderkernel_interceptor

Linux security lecture: A simple code for older-kernel's intercepting for syscall in linux kernel.

# how

It's using a simple asm linkages to the kernel's sys_open and sys_close. The new functions new_sys_open and new_sys_close is defining the intercepted real sys_open & sys_close functions. Each new functions will grab the UID and log the data in output.txt
Then they call real syscall using references to the original functions via returning real function's return value. 

Recoded/Patched by @ unixfreaxjp - the code is tweaked here and there for educational & lecture purpose, you need to adjust to make it practically working.

# bug maintainance - memo

contact: @unixfreaxjp 

---
@unixfreaxjp
