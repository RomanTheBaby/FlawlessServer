//
//  ServerThread.h
//  TestServer
//
//  Created by Baby on 7/27/18.
//  Copyright © 2018 babyorg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ServerThread : NSThread

- (void) stopServer;
- (void) startServer;

@end
