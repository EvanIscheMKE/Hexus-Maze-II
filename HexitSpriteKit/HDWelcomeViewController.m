//
//  HDWelcomeViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDWelcomeViewController.h"
#import "UIColor+FlatColors.h"
#import "HDHelper.h"

@interface HDWelcomeViewController ()

@end

@implementation HDWelcomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor flatMidnightBlueColor]];
    
    CGSize kTitleSize = [HDHelper sizeFromWidth:CGRectGetWidth(self.view.bounds) font:GILLSANS_LIGHT(90.0f) text:@"HEXUS"];
    
    CGRect rect = CGRectMake(CGRectGetMidX(self.view.bounds) - (kTitleSize.width / 2), 160.0f, kTitleSize.width, kTitleSize.height);
    UILabel *title = [[UILabel alloc] initWithFrame:rect];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:[UIColor whiteColor]];
    [title setText:@"HEXUS"];
    [title setFont:GILLSANS_LIGHT(90.0f)];
    [self.view addSubview:title];
    
    CGRect startRect = CGRectMake(CGRectGetMidX(self.view.bounds) - 60.0f, CGRectGetHeight(self.view.bounds) - 275.0f, 120.0f, 40.0f);
    UIButton *start = [UIButton buttonWithType:UIButtonTypeCustom];
    [start addTarget:ADelegate action:@selector(presentLevelViewController) forControlEvents:UIControlEventTouchUpInside];
    [start setFrame:startRect];
    [start setBackgroundColor:[UIColor flatPeterRiverColor]];
    [[start titleLabel] setTextAlignment:NSTextAlignmentCenter];
    [[start titleLabel] setFont:GILLSANS_LIGHT(22.0f)];
    [start setTitle:@"Start" forState:UIControlStateNormal];
    [start setTitleColor:[UIColor flatMidnightBlueColor] forState:UIControlStateNormal];
    [start.layer setCornerRadius:20.0f];
    [self.view addSubview:start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
