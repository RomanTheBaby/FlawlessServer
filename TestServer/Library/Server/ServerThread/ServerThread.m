//
//  ServerThread.m
//  TestServer
//
//  Created by Baby on 7/27/18.
//  Copyright © 2018 babyorg. All rights reserved.
//

#import "ServerThread.h"
#include <sys/socket.h>
#include <netinet/in.h>
#import "SocketConnectionService.h"
#include <CoreFoundation/CoreFoundation.h>

@interface ServerThread()

@property(assign, nonatomic) CFSocketRef socket;

@end

@implementation ServerThread

-(id) init {
    return [super init];
}

- (void) initializeServer {

    self.socket = CFSocketCreate(kCFAllocatorDefault,
                                 PF_INET,
                                 SOCK_STREAM,
                                 IPPROTO_TCP,
                                 kCFSocketAcceptCallBack,
                                 socketCallback, // CFSocketCallBack
                                 NULL);

    struct sockaddr_in sin;

    memset(&sin, 0, sizeof(sin));
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET; /* Address family */
    sin.sin_port = htons(3345); /* Or a specific port */
    sin.sin_addr.s_addr = INADDR_ANY;

    // Binding address to the socket

    CFDataRef sincfd = CFDataCreate(
                                    kCFAllocatorDefault,
                                    (UInt8 *)&sin,
                                    sizeof(sin));

    CFSocketSetAddress(self.socket, sincfd);


    CFRelease(sincfd);
}

- (void) cancel {
    [super cancel];
    [self stopServer];
}

- (void) startServer {
    [self initializeServer];

    CFRunLoopSourceRef socketLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault,
                                                                      self.socket,
                                                                      0);

    CFRunLoopAddSource(CFRunLoopGetCurrent(),
                       socketLoopSource,
                       kCFRunLoopDefaultMode);

    CFRelease(socketLoopSource);
    NSLog(@"IS in loop");
    CFRunLoopRun();
}

- (void) stopServer {
    NSLog(@"Will stop server");
    CFSocketInvalidate(self.socket);
    CFRelease(self.socket);
    CFRunLoopStop(CFRunLoopGetCurrent());
}

void socketCallback(CFSocketRef cfSocket, CFSocketCallBackType type,
                    CFDataRef address, const void *data, void *info)
{
    switch (type) {
        case kCFSocketAcceptCallBack: {
            SocketConnectionService *connection = [[SocketConnectionService alloc] init];
            CFStreamCreatePairWithSocket(kCFAllocatorDefault, *(CFSocketNativeHandle*)data,
                                         &(connection->readStream), &(connection->writeStream));
            CFReadStreamSetProperty(connection->readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            CFWriteStreamSetProperty(connection->writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            [connection start];
        }
            break;
        case kCFSocketNoCallBack:
            break;
        case kCFSocketDataCallBack:
            break;
        case kCFSocketReadCallBack:
            break;
        case kCFSocketWriteCallBack:
            break;
        case kCFSocketConnectCallBack:
            break;
    }
}

@end
