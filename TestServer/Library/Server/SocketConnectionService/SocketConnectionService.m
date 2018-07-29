//
//  SocketConnectionService.m
//  TestServer
//
//  Created by Baby on 7/27/18.
//  Copyright © 2018 babyorg. All rights reserved.
//

#import "TestServer-Swift.h"
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

        [receivedDataArray insertObject:receivedData atIndex:0];

        NSString *receivedMessage = [[NSString alloc] initWithBytes:buff length:dataLength encoding:NSUTF8StringEncoding];
        [self sendMessageToDelegate:receivedMessage];
        //[didWriteString dataUsingEncoding:NSUTF8StringEncoding]
        [outputStream write: [[[NSString stringWithFormat:@""] dataUsingEncoding:NSUTF8StringEncoding] bytes] maxLength:1];
    } else if (dataLength < 0) {
        [self sendErrorToDelegate:[stream streamError]];
    }
}

- (void) writeDataToStream:(NSOutputStream*) stream {
    const NSUInteger maxLength = 1024;

    if ([receivedDataArray count] > 0) {
        NSData *data = [receivedDataArray lastObject];
        uint8_t dataBytes = (uint8_t)[data bytes];
//        dataBytes += currentOffset;
        // defining lenght

        NSInteger length = [data length] - currentOffset > maxLength ? maxLength : [data length] - currentOffset;
        NSInteger sentLength = [stream write:&dataBytes maxLength: length];

        if (sentLength > 0) {
            currentOffset += sentLength;

            if (currentOffset == [data length]) {
                [receivedDataArray removeLastObject];
                currentOffset = 0;
            }

        } else if (sentLength < 0) {
            [self sendErrorToDelegate:stream.streamError];
        }
    }
}

- (void) sendMessageToDelegate:(NSString*) message {
    NSString *messageDate = [[NSDateFormatter MessageDate] stringFromDate:[[NSDate alloc] init]];
    NSString *formattedMessage = [NSString stringWithFormat:@"[%@] %@", messageDate, message];
    [self.delegate serverDidReceiveMessage:formattedMessage];
}

- (void) sendErrorToDelegate:(NSError* _Nullable) error {
    if (!error) {
        error = [NSError describing: @"Unknown Error occured"];
    }
    [self.delegate socketDidReceiveError:error];
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

        default:
            NSLog(@"Unprocessed eventCode: %lu", eventCode);
            break;
    }
}

@end
