/* For internal education only, not for public (c)unixfreaxjp                                */
/* initiation started here.. you can add the etc function for etc code additional            */
/* be aware, code is THE SAME, but libraries are DIFFERENT in each computers, so if you -    */
/* face error with libs, check the development packages related to that error                */

#include <iostream>
#include <cstring>   
#include <sys/socket.h>
#include <netdb.h>
#include <sys/unistd.h>
#include <stdio.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int gethostname(char *name, size_t len);

int main()
{
   int status;
   struct addrinfo host_info;          /* this is how the pointer for the hostname alloc'ed in mem */
   struct addrinfo *host_info_list;  /* understanding this is making you easier to reverse the malware in unix */
   struct addrinfo sin_addr;
   memset(&host_info, 0, sizeof host_info);
   host_info.ai_family = AF_UNSPEC;    /* AF_UNSPEC can be doubled interfaces of v4 and v6 in the same time..be noted */
   host_info.ai_socktype = SOCK_STREAM;
   host_info.ai_flags = AI_PASSIVE;

   status = getaddrinfo(NULL, "443", &host_info, &host_info_list);  /* you can change the port number in here  */
   if (status != 0)  std::cout << "getaddrinfo error" << gai_strerror(status) ;   /* from this line is basic socket programming */
   std::cout << "Creating a socket..."  << std::endl;
   int socketfd ;
   socketfd = socket(host_info_list->ai_family, host_info_list->ai_socktype,
                     host_info_list->ai_protocol);
   if (socketfd == -1)  std::cout << "socket error " ;

   std::cout << "Binding socket..."  << std::endl;
   int yes = 1;
   status = setsockopt(socketfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int));
   status = bind(socketfd, host_info_list->ai_addr, host_info_list->ai_addrlen);
   if (status == -1)  std::cout << "bind error" << std::endl ;

   std::cout << "Listen()ing for connections..."  << std::endl;
   status =  listen(socketfd, 5);
   if (status == -1)  std::cout << "listen error" << std::endl ;

   int new_sd;
   struct sockaddr_storage their_addr;
   struct sockaddr_in antelope;

   char *some_addr;
   socklen_t addr_size = sizeof(their_addr);
   new_sd = accept(socketfd, (struct sockaddr *)&their_addr, &addr_size);
   if (new_sd == -1)
   {
       std::cout << "listen error" << std::endl ;
   }
   else
   {
some_addr = inet_ntoa(((struct sockaddr_in *)&their_addr)->sin_addr);
std::cout << some_addr << "\n";
       std::cout << "Connection accepted. Using new socketfd : "  <<  new_sd << std::endl;
   }

   std::cout << "Waiting to recieve data..."  << std::endl;
   ssize_t bytes_recieved;
   char incomming_data_buffer[1000];
   bytes_recieved = recv(new_sd, incomming_data_buffer,1000, 0);  /* 1,000 bytes sounds reasobable for toying purpose, in real u should set into 65,355.. yet the possibility of buffer overflow came up the bigger size you entered..gotta make the trapping for that */
   if (bytes_recieved == 0) std::cout << "host shut down." << std::endl ;
   if (bytes_recieved == -1)std::cout << "recieve error!" << std::endl ;
   std::cout << bytes_recieved << " bytes recieved :" << std::endl ;
   incomming_data_buffer[bytes_recieved] = '\0';
   std::cout << incomming_data_buffer << std::endl;
   freeaddrinfo(host_info_list);
   close(new_sd);
   close(socketfd);
return 0;
/* uncomment the below part for the heartbledd (daemon) and comment the above part instead */
/* return main(); */
}
