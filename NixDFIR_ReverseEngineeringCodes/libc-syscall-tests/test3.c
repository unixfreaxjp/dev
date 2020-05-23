#include <sys/syscall.h>
main ()
 {
   syscall (SYS_write,1,"\nHello\n",7);
  }
