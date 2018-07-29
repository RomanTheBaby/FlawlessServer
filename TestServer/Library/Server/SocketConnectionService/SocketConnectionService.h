//
//  SocketConnectionService.h
//  TestServer
//
//  Created by Baby on 7/27/18.
//  Copyright © 2018 babyorg. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SocketServiceDelegate

- (void) socketDidReceiveError:(NSError*) error;
- (void) serverDidReceiveMessage:(NSString*) message;

@end

@interface SocketConnectionService: NSThread {
@public
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
}

@property (assign, nonatomic) id<SocketServiceDelegate> delegate;

- (void) readReceivedDataFromInputStream:(NSInputStream*) stream;
- (void) writeDataToStream:(NSOutputStream*) stream;

@end
