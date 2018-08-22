# Network Buffers and Memory Management

## Introduction
The Linux operating system implements the industry-standard Berkeley socket API, which has its origins in the BSD Unix developments (4.2/4.3/4.4 BSD). 

In this article, we will look at the way the memory management and buffering is implemented for network layers and network device drivers under the existing Linux kernel, as well as explain how and why some things have changed over time. 

## The core concept

The networking layer is fairly object-oriented in its design, as indeed is much of the Linux kernel. The core structure of the networking code goes back to the initial networking and socket implementations by Ross Biro and Orest Zborowski respectively. 
The key objects are:
- *Device or Interface:* A network interface is programming code for sending and receiving data packets. Usually an interface is used for a physical device like an Ethernet card; however, some devices are software only, e.g., the loopback device used for sending data to yourself.
- *Protocol:* Each protocol is effectively a different networking language. Some protocols exist purely because vendors chose to use proprietary networking schemes, while others are designed for special purposes. Within the Linux kernel each protocol is a separate module of code which provides services to the socket layer.
- *Socket*: A socket is a connection in the networking that provides Unix file I/O and exists as a file descriptor to the user program. In the kernel each socket is a pair of structures that represent the high level socket interface and the low level protocol interface.
- *sk_buff:* All the buffers used by the networking layers are sk_buffs. The control for these buffers is provided by core low-level library routines that are available to all of the networking system. sk_buffs provide the general buffering and flow control facilities needed by network protocols.

## Implementation of *sk_buffs*

The primary goal of the *sk_buff routines* is to provide a consistent and efficient buffer-handling method for all of the network layers, and by being consistent to make it possible to provide higher level sk_buff and socket handling facilities to all of the protocols.

A *sk_buff* is a control structure with a block of memory attached. Two primary sets of functions are provided in the *sk_buff library*. The first set consists of routines to manipulate doubly linked lists of *sk_buffs*; the second of functions for controlling the attached memory. The buffers are held on linked lists optimised for the common network operations of append to end and remove from start. As so much of the networking functionality occurs during interrupts these routines are written to use atomic memory. The small extra overhead that results is well worth the pain it saves in bug hunting.

We use the list operations to manage groups of packets as they arrive from the network, and as we send them to the physical interfaces. We use the memory manipulation routines for handling the contents of packets in a standardised and efficient manner.

At its most basic level, a list of buffers is managed using functions like this:
```c
void append_frame(char *buf, int len)
{
  struct sk_buff *skb=alloc_skb(len, GFP_ATOMIC);
  if(skb==NULL)
    my_dropped++;
  else
  {
    skb_put(skb,len);
    memcpy(skb->data,data,len);
    skb_append(&my_list, skb);
  }
}
void process_queue(void)
{
  struct sk_buff *skb;
  while((skb=skb_dequeue(&my_list))!=NULL)
  {
    process_data(skb);
    kfree_skb(skb, FREE_READ);
  }
}
```
These two fairly simplistic pieces of code actually demonstrate the receive packet mechanism quite accurately. The *append_frame()* function is similar to the code called from an interrupt by a device driver receiving a packet, and **process_frame()* is similar to the code called to feed data into the protocols. If you look in `net/core/dev.c` at *netif_rx()* and *net_bh()*, you will see that they manage buffers similarly. They are far more complex, as they have to feed packets to the right protocol and manage flow control, but the basic operations are the same. This is just as true if you look at buffers going from the protocol code to a user application.

The example also shows the use of one of the data control functions, *skb_put()*. Here it is used to reserve space in the buffer for the data we wish to pass down.

Let's look at *append_frame()*. The *alloc_skb() function* obtains a buffer of len bytes (Figure 1), which consists of:
- 0 bytes of room at the head of the buffer
- 0 bytes of data, and
- `len` bytes of room at the end of the data.

<img src="https://i.imgur.com/CyIGawR.png" width="400">

The *skb_put() function* (Figure 4) grows the data area upwards in memory through the free space at the buffer end, and thus reserves space for the *memcpy()*. Many network operations that send data packets add space to the start of the frame each time a send is executed, so that headers can be added to the packets. For this reason, the *skb_push() function* (Figure 5) is provided so that the start of the data frame can be moved down through memory, if enough space has been reserved to leave room for completing this operation.

<img src="https://i.imgur.com/PXlr4xQ.png" width="800">
<img src="https://i.imgur.com/WljiL3y.png" width="800">

Immediately after a buffer has been allocated, all the available room is at the end. Another function, *skb_reserve()* (Figure 2), can be called before data is added. 

<img src="https://i.imgur.com/qwKjjYJ.png" width="400">

This function allows you to specify that some of the space should be at the beginning of the buffer. Thus, many sending routines start with code that looks like:
```c
    skb=alloc_skb(len+headspace, GFP_KERNEL);
    skb_reserve(skb, headspace);
    skb_put(skb,len);
    memcpy_fromfs(skb->data,data,len);
    pass_to_m_protocol(skb);
```

In systems such as BSD Unix, we don't need to know in advance how much space we will need, as it uses `chains of small buffers` called **(mbufs)** for its network buffers. Linux chooses to use linear buffers and save space in advance (often wasting a few bytes to allow for the worst case), because linear buffers make many other operations much faster.

Linux provides the following functions for manipulating lists:
- *skb_dequeue()* takes the first buffer from a list. If the list is empty, a `NULL pointer` is returned. This function is used to pull buffers off queues. The buffers are added with the routines *skb_queue_head()* and *skb_queue_tail()*.
- *skb_queue_head()* places a buffer at the start of a list. As with all the list operations, it is atomic.
- *skb_queue_tail()* places a buffer at the end of a list and is the most commonly used function. Almost all the queues are handled with one set of routines queuing data with this function and another set removing items from the same queues with *skb_dequeue()*.
- *skb_unlink()* removes a buffer from whatever list contains it. The buffer is not freed, merely removed from the list. To make some operations easier, you need not know what list the buffer is in, and you can always call skb_unlink() for a buffer which is not in any list. This function enables network code to pull a buffer out of use even when the network protocol has no idea who is currently using the buffer. A separate locking mechanism is provided, so that a buffer currently in use by a device driver can not be removed.
- Some more complex protocols, like `TCP`, keep frames in order, and re-order their input as data is received. Two functions, *skb_insert()* and *skb_append()*, exist to allow users to place sk_buffs before or after a specific buffer in a list.
- *alloc_skb()* creates a *new sk_buff* and initializes it. The returned buffer is ready to use but assumes you will fill in a few fields to indicate how the buffer should be freed. Normally this is done by `skb->free=1`. A buffer can be flagged as not freeable by *kfree_skb()* (see below).
- *kfree_skb()* releases a buffer, and if `skb->sk` is set, it lowers the memory use counts of the `socket (sk)`. It is up to the socket and protocol-level routines to increment these counts and to avoid freeing a socket with outstanding buffers. The memory counts are very important, as the kernel networking layers need to know how much memory is tied up by each connection in order to prevent remote machines or local processes from using too much memory.
- *skb_clone()* makes a copy of a *sk_buff*, but does not copy the data area, which must be considered `read only`.
- Sometimes a copy of the data is needed for editing, and *skb_copy()* provides the same facilities as *skb_clone*, but also copies the data (and thus has a much higher overhead).

/tba (unixfreaxjp)
