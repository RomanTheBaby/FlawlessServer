//
//  ServerThread.h
//  TestServer
//
//  Created by Baby on 7/27/18.
//  Copyright © 2018 babyorg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#pragma mark - ServerDelegate

@protocol ServerDelegate

- (void) socketDidReceiveError:(NSError*) error;
- (void) serverDidReceiveMessage:(NSString*) message;

@end

#pragma mark - ServerThread

@interface ServerThread : NSThread

@property (assign, nonatomic) id<ServerDelegate> delegate;

- (void) stopServer;
- (void) startServer;

@end
