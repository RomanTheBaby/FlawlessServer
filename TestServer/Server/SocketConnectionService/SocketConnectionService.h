//
//  SocketConnectionService.h
//  TestServer
//
//  Created by Baby on 7/27/18.
//  Copyright © 2018 babyorg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketConnectionService: NSThread {
@public
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
}

- (void) readReceivedDataFromInputStream:(NSInputStream*) stream;
- (void) writeDataToStream:(NSOutputStream*) stream;

@end
