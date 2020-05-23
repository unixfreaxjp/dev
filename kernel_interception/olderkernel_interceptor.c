/* THE EXAMPLE LINUX KERNEL INTERCEPTOR 
Recoded/Patched by @ unixfreaxjp
SHARED FIRSTLY IN ALL JAPAN SECCAMP 2017 - Z1 TRACK/unixfreaxjp 

=============
makeファイルは自分で用意してください
=============

obj-m := Intercept_open_close.o
KDIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
*/

// ==========================
// Intercept_open_close.c 
// ここはソースコードですね。コメントの所をよく読んで、変更が必要場合どうぞ変更してください。
// もっと詳細なコードがあるけど、基本的には同じなので、成功した本冠変え方をシェアしました。
// ==========================

// We need to define __KERNEL__ and MODULE to be in Kernel space
// If they are defined, undefined them and define them again:

#undef __KERNEL__
#undef MODULE

#define __KERNEL__ 
#define MODULE

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/syscalls.h>
#include <linux/cred.h>

unsigned long **sys_call_table;

asmlinkage long (*ref_sys_open)(const char __user *filename, int flags, umode_t mode);
asmlinkage long (*ref_sys_close)(unsigned int fd);

asmlinkage long new_sys_open(const char __user *filename, int flags, umode_t mode) {
	int uid = current_uid();
	if(uid >= 1000){
		printk(KERN_INFO "User %d is opening file: %s", uid, filename);
	}	
	
	return ref_sys_open(filename, flags, mode);
}

asmlinkage long new_sys_close(unsigned int fd){
	int uid = current_uid();
	if(uid >= 1000){
		printk(KERN_INFO "User %d is closing file descriptor: %d", uid, fd);
	}	
	
	return ref_sys_close(fd);	
}


static unsigned long **find_sys_call_table(void) {
	unsigned long int offset = PAGE_OFFSET;
	unsigned long **sct;

	while (offset < ULLONG_MAX) {
		sct = (unsigned long **)offset;

		if (sct[__NR_close] == (unsigned long *) sys_close) {
			printk(KERN_INFO "Interceptor: Found syscall table at address: 0x%02lX", (unsigned long) sct);
			return sct;
		}

	offset += sizeof(void *);
	}

	return NULL;
}	// 下記のコードをコメントした理由はよけに動かなくなってしまう..
  // static unsigned long **find_sys_call_table(void)


static void disable_page_protection(void) {
	/*
  cr0 in kernel manages how CPU operates.
  Bit #16 prevents the CPU from writing to memory, is patched to off.
  We read current values of the registers (32 or 64 bits wide), 
  with a value where all bits are 0 excep the 16th bit (negation operation), 
  will make write_cr0 value's 16th bit cleared (other are the same).
	*/

	write_cr0 (read_cr0 () & (~ 0x10000));

}	//static void disable_page_protection(void)


static void enable_page_protection(void) {
	/*
	See the above description for cr0. Here, we use an OR to set the
	16th bit to re-enable write protection on the CPU.
	*/

	write_cr0 (read_cr0 () | 0x10000);

}	// static void enable_page_protection(void)


static int __init interceptor_start(void) {
	/* Find the system call table */
	if(!(sys_call_table = find_sys_call_table())) {
		/* Well, that didn't work.
		Cancel the module loading step. */
		return -1;
	}


	/* Store a copy of all the existing functions */
	ref_sys_open = (void *)sys_call_table[__NR_open];
	ref_sys_close = (void *)sys_call_table[__NR_close];

	/* Replace the existing system calls */
	disable_page_protection();

	sys_call_table[__NR_open] = (unsigned long *)new_sys_open;
	sys_call_table[__NR_close] = (unsigned long*)new_sys_close;

	enable_page_protection();

	/* And indicate the load was successful */
	printk(KERN_INFO "Loaded interceptor!");

	return 0;
}	// static int __init interceptor_start(void)


static void __exit interceptor_end(void) {
	/* If we don't know what the syscall table is, don't bother. */
	if(!sys_call_table)
		return;

	/* Revert all system calls to what they were before we began. */
	disable_page_protection();
	sys_call_table[__NR_open] = (unsigned long *)ref_sys_open;
	sys_call_table[__NR_close] = (unsigned long *)ref_sys_close;
	enable_page_protection();

	printk(KERN_INFO "Unloaded interceptor!");
}	// static void __exit interceptor_end(void)

MODULE_LICENSE("GPL");
module_init(interceptor_start);
module_exit(interceptor_end);
