//
//  SocketConnectionService.m
//  TestServer
//
//  Created by Baby on 7/27/18.
//  Copyright © 2018 babyorg. All rights reserved.
//

#import "SocketConnectionService.h"

@interface SocketConnectionService() <NSStreamDelegate> {
    __strong NSInputStream *inputStream;
    __strong NSOutputStream *outputStream;

    NSInteger currentOffset;
    NSMutableArray *receivedDataArray;
}

@end

@implementation SocketConnectionService

- (void) main {
    currentOffset = 0;
    receivedDataArray = [NSMutableArray new];
    inputStream = (__bridge NSInputStream *)(readStream);
    outputStream = (__bridge NSOutputStream *)(writeStream);

    [inputStream setDelegate:self];
    [outputStream setDelegate:self];

    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    [inputStream open];
    [outputStream open];

    CFRunLoopRun();
}

- (void) readReceivedDataFromInputStream:(NSInputStream*) stream {
    const NSUInteger maxLength = 1024;
    uint8_t buff[maxLength];
    NSInteger dataLength = [stream read:buff maxLength:maxLength];

    if (dataLength > 0) {
        NSData *receivedData = [NSData dataWithBytes:buff length:dataLength];
        [receivedDataArray insertObject:receivedData atIndex:0]; //addObject:receivedData]; // or add at index 0?
    } else if (dataLength < 0) {
        NSError *error = [stream streamError];
        NSLog(@"Error occured: %@", [error localizedDescription]);
    }
}

- (void) writeDataToStream:(NSOutputStream*) stream {
    const NSUInteger maxLength = 1024;

    if ([receivedDataArray count] > 0) {
        NSData *data = [receivedDataArray lastObject];
        uint8_t dataBytes = (uint8_t)[data bytes];
        dataBytes += currentOffset;
        // defining lenght
        NSInteger length = [data length] - currentOffset > maxLength ? maxLength : [data length] > currentOffset;
        NSInteger sentLength = [stream write:&dataBytes maxLength: length];

        if (sentLength > 0) {
            currentOffset += sentLength;

            if (currentOffset == [data length]) {
                [receivedDataArray removeLastObject];
                currentOffset = 0;
            }

        } else if (sentLength < 0) {
            NSError *error = stream.streamError;
            NSLog(@"%@", error.localizedDescription);
        }

    }
}

#pragma mark - NSStreamDelegate

- (void) stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasSpaceAvailable: {
            [self writeDataToStream:(NSOutputStream*)aStream];
        }
            break;

        case NSStreamEventHasBytesAvailable: {
            [self readReceivedDataFromInputStream:(NSInputStream*)aStream];
        }

        case NSStreamEventErrorOccurred: {
            NSError *error = [aStream streamError];
            NSLog(@"Occured Error: %li, %@", [error code], [error localizedDescription]);
        }
            break;

        case NSStreamEventEndEncountered: {
            NSLog(@"Event completed");
        }
        default:
            break;
    }
}

@end
