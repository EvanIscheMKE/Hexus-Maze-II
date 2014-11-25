//
//  HDWelcomeViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDWelcomeViewController.h"
#import "UIColor+FlatColors.h"
#import "HDSpaceView.h"
#import "HDHelper.h"

@interface HDWelcomeViewController ()

@property (nonatomic, strong) UIButton *startButton;

@end

@implementation HDWelcomeViewController

- (void)loadView
{
    CGRect spaceRect = [[UIScreen mainScreen] bounds];
    HDSpaceView *space = [[HDSpaceView alloc] initWithFrame:spaceRect];
    [self setView:space];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor flatMidnightBlueColor]];
    
    CGSize kTitleSize = [HDHelper sizeFromWidth:CGRectGetWidth(self.view.bounds) font:GILLSANS_LIGHT(90.0f) text:@"HEXUS"];
    
    CGRect rect = CGRectMake(CGRectGetMidX(self.view.bounds) - (kTitleSize.width / 2), 190.0f, kTitleSize.width, kTitleSize.height);
    UILabel *title = [[UILabel alloc] initWithFrame:rect];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:[UIColor whiteColor]];
    [title setText:@"HEXUS"];
    [title setFont:GILLSANS_LIGHT(90.0f)];
    [self.view addSubview:title];
    
    CGRect startRect = CGRectMake(CGRectGetMidX(self.view.bounds) - 65.0f, CGRectGetHeight(self.view.bounds) - 275.0f, 130.0f, 40.0f);
    self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startButton addTarget:ADelegate action:@selector(presentLevelViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.startButton setFrame:startRect];
    [self.startButton setBackgroundColor:[UIColor flatPeterRiverColor]];
    [[self.startButton titleLabel] setTextAlignment:NSTextAlignmentCenter];
    [[self.startButton titleLabel] setFont:GILLSANS_LIGHT(22.0f)];
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor flatMidnightBlueColor] forState:UIControlStateNormal];
    [self.startButton.layer setCornerRadius:20.0f];
    [self.view addSubview:self.startButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.startButton setAlpha:0.0f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_block_t animateStart = ^{
        [self.startButton setAlpha:1.0f];
    };
    
    [UIView animateWithDuration:1.0f animations:animateStart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
