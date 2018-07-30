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
}

@end

@implementation SocketConnectionService

- (void) main {

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
        NSString *message = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];

        NSString *formattedMessage = [self formatMessage:message];
        [self sendMessageToDelegate:formattedMessage];

        NSData *dataForClient = [formattedMessage dataUsingEncoding:NSUTF8StringEncoding];

        // so client could see the message to
        [outputStream write:[dataForClient bytes] maxLength:[dataForClient length]];
    } else if (dataLength < 0) {
        [self sendErrorToDelegate:[stream streamError]];
    }
}

- (NSString*) formatMessage:(NSString*) message {
    NSString *messageDate = [[NSDateFormatter MessageDate] stringFromDate:[[NSDate alloc] init]];
    return [NSString stringWithFormat:@"[%@] %@", messageDate, message];
}

- (void) sendMessageToDelegate:(NSString*) message {
    [self.delegate serverDidReceiveMessage:message];
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
        case NSStreamEventHasBytesAvailable: {
            [self readReceivedDataFromInputStream:(NSInputStream*)aStream];
        }

        default:
            NSLog(@"Unprocessed eventCode: %lu", eventCode);
            break;
    }
}

@end
