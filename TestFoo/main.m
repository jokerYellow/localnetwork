//
//  main.m
//  TestFoo
//
//  Created by apple on 2022/2/9.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "fishhook.h"
#import <dlfcn.h>
#include <sys/socket.h>
#include <netinet/in.h>

static int (*orig_close)(int);
static int (*orig_open)(const char *, int, ...);
 
static int (*orig_socket)(int, int, int);
static int (*orig_connect)(int, const struct sockaddr *, socklen_t);

static CFSocketRef (*origin_CFSocketCreate)(CFAllocatorRef allocator, SInt32 protocolFamily, SInt32 socketType, SInt32 protocol, CFOptionFlags callBackTypes, CFSocketCallBack callout, const CFSocketContext *context);

CFSocketRef  my_CFSocketCreate(CFAllocatorRef allocator, SInt32 protocolFamily, SInt32 socketType, SInt32 protocol, CFOptionFlags callBackTypes, CFSocketCallBack callout, const CFSocketContext *context){
    NSLog(@"cfsocket");
    return origin_CFSocketCreate(allocator,protocolFamily,socketType,protocol,callBackTypes,callout,context);
}

int my_socket(int domain, int type, int protocol)
{
    printf("this is my socket! domain:%d type:%d protocol:%d\n",domain,type,protocol);
    return orig_socket(domain,type,protocol);
}
int my_connect(int socket, const struct sockaddr * addr, socklen_t len)
{
    printf("this is my connect,socket:%d addr:%s len:%d",socket,addr,len);
    return orig_connect(socket,addr,len);
}

int my_close(int fd) {
  printf("Calling real close(%d)\n", fd);
  return orig_close(fd);
}
 
int my_open(const char *path, int oflag, ...) {
  va_list ap = {0};
  mode_t mode = 0;
 
  if ((oflag & O_CREAT) != 0) {
    // mode only applies to O_CREAT
    va_start(ap, oflag);
    mode = va_arg(ap, int);
    va_end(ap);
    printf("Calling real open('%s', %d, %d)\n", path, oflag, mode);
    return orig_open(path, oflag, mode);
  } else {
    printf("Calling real open('%s', %d)\n", path, oflag);
    return orig_open(path, oflag, mode);
  }
}

int main(int argc, char * argv[]) {
    rebind_symbols((struct rebinding[5]){
        {"close", my_close, (void *)&orig_close},
        {"open", my_open, (void *)&orig_open},
        {"socket",my_socket,(void *)&orig_socket},
        {"send",my_connect,(void *)&orig_connect},
        {"CFSocketCreate",my_CFSocketCreate,(void *)&origin_CFSocketCreate},
    }, 5);
     
        // Open our own binary and print out first 4 bytes (which is the same
        // for all Mach-O binaries on a given architecture)
        int fd = open(argv[0], O_RDONLY);
        uint32_t magic_number = 0;
        read(fd, &magic_number, 4);
        printf("Mach-O Magic Number: %x \n", magic_number);
        close(fd);
    
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
