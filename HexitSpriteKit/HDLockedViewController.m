//
//  HDLockedViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/23/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLockedViewController.h"
#import "HDLockedView.h"

@interface HDLockedViewController ()
@end

@implementation HDLockedViewController

- (HDLockedView *)lockedView {
    return (HDLockedView *)self.view;
}

- (void)loadView {
    self.view = [HDLockedView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.lockedView startMonitoringMotionUpdates];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.lockedView stopMonitoringMotionUpdates];
}

@end
