
//  ViewController.m
//  TestServer
//
//  Created by Baby on 7/22/18.
//  Copyright © 2018 babyorg. All rights reserved.
//

#import "ServerThread.h"
#import "ViewController.h"
#import "TestServer-Swift.h"

@interface ViewController() <ServerDelegate>

@property (strong, nonatomic) ServerThread *server;
@property (unsafe_unretained) IBOutlet NSTextView *logsTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.server = [[ServerThread alloc] init];
    self.server.delegate = self;
    [self.server start];
}

- (void) viewDidAppear {
    [super viewDidAppear];

}
- (IBAction)stopServer:(NSButton *)sender {
    [self stopServer];
}

- (IBAction)startServer:(NSButton *)sender {
    [self startServer];
}

- (void) startServer {
    [self.server startServer];
}

- (void) stopServer {
    [self.server stopServer];
}

#pragma mark - ServerDelegate

- (void) socketDidReceiveError:(NSError*) error {
    [self.logsTextView addErrorMessage:[error localizedDescription]];
}

- (void) serverDidReceiveMessage:(NSString*) message {
    [self.logsTextView addMessage:message];
}

@end
