
//  ViewController.m
//  TestServer
//
//  Created by Baby on 7/22/18.
//  Copyright © 2018 babyorg. All rights reserved.
//

#import "ServerThread.h"
#import "ViewController.h"
#import "TestServer-Swift.h"


@interface ViewController()

@property (strong, nonatomic) ServerThread *server;
@property (unsafe_unretained) IBOutlet NSTextView *logsTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.server = [[ServerThread alloc] init];
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

@end
