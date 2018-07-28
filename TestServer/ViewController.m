
//  ViewController.m
//  TestServer
//
//  Created by Baby on 7/22/18.
//  Copyright © 2018 babyorg. All rights reserved.
//

#import "ServerThread.h"
#import "ViewController.h"

@interface ViewController()

@property(strong, nonatomic) ServerThread *server;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewDidAppear {
    [super viewDidAppear];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSelectorInBackground:@selector(startServer) withObject:nil];
    });

}

- (void) startServer {
    self.server = [[ServerThread alloc] init];
    [self.server start];
}

@end
