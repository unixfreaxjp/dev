Starting new test of [https://github.com/unixfreaxjp/dev/blob/master/r2ppc.md] based on advise received xref:[https://github.com/radare/radare2/issues/4720#issuecomment-214844475] 

Same environment:
```asm
$ sys/user.sh
WARNING: Updating from remote repository
remote: Counting objects: 146, done.
remote: Compressing objects: 100% (42/42), done.
remote: Total 146 (delta 108), reused 93 (delta 93), pack-reused 11
Receiving objects: 100% (146/146), 85.04 KiB, done.
Resolving deltas: 100% (108/108), completed with 75 local objects.
From https://github.com/radare/radare2
   e9dc4ae..26fc8f9  master     -> origin/master
Updating e9dc4ae..26fc8f9
Fast-forward
 libr/anal/p/anal_arm_cs.c               |   18 +++++++++---------
 libr/anal/p/anal_ppc_cs.c               |   23 ++++++++++++++++++++++-
 libr/asm/arch/cr16/cr16_disas.c         |   30 ------------------------------
 libr/asm/arch/dcpu16/dis.c              |    2 +-
 libr/asm/asm.c                          |    1 -
 libr/bin/format/objc/mach0_classes.c    |    2 +-
 libr/config.mk.tail                     |   11 +++++++++--
 libr/core/cmd_anal.c                    |    4 +++-
 libr/crypto/p/Makefile                  |    2 --
 libr/crypto/p/crypto_aes.c              |    2 +-
 libr/crypto/p/crypto_aes_cbc.c          |    2 +-
 libr/debug/p/debug_native.c             |    5 ++---
 libr/debug/p/native/linux/linux_debug.c |    4 ++--
 libr/debug/p/native/xnu/xnu_debug.c     |   50 +++++++++-----------------------------------------
 libr/debug/p/native/xnu/xnu_debug.h     |    2 ++
 libr/hash/xxhash.c                      |    2 +-
 libr/include/sdb/sdb.h                  |   11 +++++++++--
 libr/include/sdb/sdb_version.h          |    2 +-
 libr/io/p/io_debug.c                    |    4 +++-
 libr/magic/Makefile                     |    2 +-
 libr/magic/apprentice.c                 |   24 +++++++++++++-----------
 libr/magic/file.h                       |    4 +++-
 libr/magic/print.c                      |    4 ++--
 libr/parse/p/6502_pseudo.mk             |    2 +-
 libr/parse/p/arm_pseudo.mk              |    2 +-
 libr/parse/p/att2intel.mk               |    2 +-
 libr/parse/p/dalvik_pseudo.mk           |    3 ++-
 libr/parse/p/m68k_pseudo.mk             |    3 ++-
 libr/parse/p/mips_pseudo.mk             |    3 ++-
 libr/parse/p/ppc_pseudo.mk              |    2 +-
 libr/parse/p/x86_pseudo.mk              |    2 +-
 libr/parse/p/z80_pseudo.mk              |    3 ++-
 libr/parse/parse.c                      |    1 -
 libr/rules.mk                           |   10 +++++++++-
 libr/socket/run.c                       |    4 +++-
 libr/util/sys.c                         |   13 ++++++++++++-
 mk/gcc.mk                               |    1 +
 shlr/bochs/Makefile                     |    7 ++++++-
 shlr/gdb/Makefile                       |   10 +++++++++-
 shlr/qnx/Makefile                       |    7 ++++++-
 shlr/qnx/include/utils.h                |    2 +-
 shlr/qnx/src/utils.c                    |    4 ++--
 shlr/sdb/config.mk                      |    4 ++--
 shlr/sdb/src/array.c                    |   95 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---------------------
 shlr/sdb/src/cdb_make.c                 |    2 +-
 shlr/sdb/src/sdb.c                      |   10 +++++-----
 shlr/sdb/src/sdb.h                      |   11 +++++++++--
 shlr/zip/zip/Makefile                   |    2 +-
 shlr/zip/zlib/Makefile                  |    2 +-
 49 files changed, 250 insertions(+), 168 deletions(-)

export USE_R2_CAPSTONE=

```
Obviously debug mode is not yet supported in ppc:
```asm
CC linux_debug.c
CC asm_java.c
p/debug_native.c:1320:2: warning: #warning Unsupported architecture [-Wcpp]
CC asm_lanai_gnu.c
CC lanai-dis.c
CC lanai-opc.c
p/native/linux/linux_debug.c: In function ▒linux_reg_profile▒:
p/native/linux/linux_debug.c:28:2: error: #error "Unsupported Linux CPU"
p/native/linux/linux_debug.c: In function ▒linux_handle_signals▒:
p/native/linux/linux_debug.c:43:2: warning: #warning DO MORE RDEBUGREASON HERE [-Wcpp]
p/native/linux/linux_debug.c: In function ▒print_fpu▒:
p/native/linux/linux_debug.c:291:2: warning: #warning not implemented for this platform [-Wcpp]
p/native/linux/linux_debug.c: In function ▒linux_reg_read▒:
p/native/linux/linux_debug.c:376:3: warning: #warning not implemented for this platform [-Wcpp]
p/native/linux/linux_debug.c:383:4: error: unknown type name ▒R_DEBUG_REG_T▒
p/native/linux/linux_debug.c:296:7: warning: variable ▒showfpu▒ set but not used [-Wunused-but-set-variable]
p/native/linux/linux_debug.c: In function ▒linux_reg_write▒:
p/native/linux/linux_debug.c:425:43: error: ▒struct user▒ has no member named ▒u_debugreg▒
p/native/linux/linux_debug.c:431:17: error: ▒R_DEBUG_REG_T▒ undeclared (first use in this function)
p/native/linux/linux_debug.c:431:17: note: each undeclared identifier is reported only once for each function it appears in
p/native/linux/linux_debug.c: At top level:
p/native/linux/linux_debug.c:203:13: warning: ▒print_fpu▒ defined but not used [-Wunused-function]
p/native/linux/linux_debug.c: In function ▒linux_reg_profile▒:
p/native/linux/linux_debug.c:30:1: warning: control reaches end of non-void function [-Wreturn-type]
make[4]: *** [p/native/linux/linux_debug.o] Error 1
make[4]: *** Waiting for unfinished jobs....
CC asm_lh5801.c
CC asm_lm32.c
CC asm_m68k.c
CC m68k_disasm.c
CC asm_m68k_cs.c
CC asm_malbolge.c
make[3]: *** [foo] Error 2
make[2]: *** [debug] Error 2
make[2]: *** Waiting for unfinished jobs....
CC asm_mcs96.c
CC asm_mips_cs.c
CC asm_mips_gnu.c
CC mips-dis.c
CC mips16-opc.c
CC mips-opc.c
CC mipsasm.c
CC asm_msp430.c
CC asm_nios2.c
CC nios2-dis.c
CC nios2-opc.c
CC asm_pic18c.c
CC asm_ppc_cs.c
CC asm_ppc_gnu.c
CC ppc-dis.c
CC ppc-opc.c
CC asm_rar.c
CC asm_riscv.c
CC asm_sh.c
CC sh-dis.c
CC asm_snes.c
CC asm_sparc_cs.c
CC asm_sparc_gnu.c
CC sparc-dis.c
CC sparc-opc.c
CC asm_spc700.c
CC asm_sysz.c
CC asm_tms320.c
CC asm_tricore.c
CC tricore-dis.c
CC tricore-opc.c
CC cpu-tricore.c
CC asm_v810.c
CC asm_v850.c
CC asm_vax.c
CC vax-dis.c
CC asm_ws.c
CC asm_x86_as.c
CC asm_x86_cs.c
CC asm_x86_nasm.c
CC asm_x86_nz.c
CC asm_x86_olly.c
CC disasm.c
CC asmserv.c
CC assembl.c
CC asm_x86_tab.c
CC asm_x86_udis.c
CC asm_xcore_cs.c
CC asm_xtensa.c
CC xtensa-dis.c
CC xtensa-isa.c
CC xtensa-modules.c
CC elf32-xtensa.c
CC asm_z80.c
CC asm_z80_cr.c
CC asm.c
CC code.c
LD libr_asm.so
CC asm_propeller.c
CC propeller_disas.c
gcc: warning: /test/radare2/libr/../shlr/capstone/libcapstone.a: linker input file unused because linking not done
gcc: warning: /test/radare2/libr/../shlr/capstone/libcapstone.a: linker input file unused because linking not done
make[1]: *** [all] Error 2
make: *** [all] Error 2
Oops
```
Continuing testing with the below advise:
> ![](https://lh3.googleusercontent.com/-S3VpBidVApg/VyC3rhqZ6cI/AAAAAAAAUyg/Km23CGbxgwMtZo6FE3klFvOaSrWQyfPAgCLcB/s600/001.PNG)

Configure part, without debugger was executed well:
```asm
$ ./configure --without-debugger
configure-plugins: Loading ./plugins.cfg ..
configure-plugins: Generating libr/config.h ..
configure-plugins: Generating libr/config.mk ..
SHARED: io.shm
STATIC: anal.6502 anal.8051 anal.arc anal.arm_cs anal.arm_gnu [...]  parse.x86_pseudo

WARNING: Unknown flag '--without-debugger'.
```
cancelled, it seems invalid option, checking the without option...
```asm
Optional Features:
  --disable-debugger     disable native debugger features
  --with-sysmagic        force to use system's magic
  --disable-loadlibs     disable loading plugins
  --without-fork         disable fork
  --with-syscapstone     force to use system-wide capstone
  --with-syszip          force to use system's libzip and zlib
  --without-gpl          do not build GPL code (grub, cxx, .
  ```
  retried with --disable-debugger
  
