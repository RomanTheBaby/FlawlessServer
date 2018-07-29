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

@interface ServerThread() <SocketServiceDelegate>

@property(assign, nonatomic) CFSocketRef socket;

@end

@implementation ServerThread

-(id) init {
    return [super init];
}

- (void) initializeServer {

    CFSocketContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    self.socket = CFSocketCreate(kCFAllocatorDefault,
                                 PF_INET,
                                 SOCK_STREAM,
                                 IPPROTO_TCP,
                                 kCFSocketAcceptCallBack,
                                 socketCallback, // CFSocketCallBack
                                 &context);

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

    [self.delegate serverDidReceiveMessage:@"\nServer Started server..."];

    CFRunLoopSourceRef socketLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault,
                                                                      self.socket,
                                                                      0);

    CFRunLoopAddSource(CFRunLoopGetCurrent(),
                       socketLoopSource,
                       kCFRunLoopDefaultMode);

    CFRelease(socketLoopSource);
    CFRunLoopRun();
}

- (void) stopServer {
    [self.delegate serverDidReceiveMessage:@"Will stop server...\n"];
    CFSocketInvalidate(self.socket);
    CFRelease(self.socket);
    CFRunLoopStop(CFRunLoopGetCurrent());
}

void socketCallback(CFSocketRef cfSocket, CFSocketCallBackType type,
                    CFDataRef address, const void *data, void *info)
{
    switch (type) {
        case kCFSocketAcceptCallBack: {
            ServerThread *thread = (__bridge ServerThread *)(info);
            SocketConnectionService *connection = [[SocketConnectionService alloc] init];
            connection.delegate = thread;
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

#pragma mark - SocketServiceDelegate

- (void) socketDidReceiveError:(NSError*) error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate socketDidReceiveError:error];
    });
}

- (void) serverDidReceiveMessage:(NSString*) message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate serverDidReceiveMessage:message];
    });
}

@end
