Starting new test of [https://github.com/unixfreaxjp/dev/blob/master/r2ppc.md] based on advise in [] 
Sample environment:
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
