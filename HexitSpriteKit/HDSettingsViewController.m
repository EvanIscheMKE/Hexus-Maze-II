//
//  HDSettingsViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 1/2/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHexagonButton.h"
#import "UIColor+FlatColors.h"
#import "HDSettingsViewController.h"

static const CGFloat defaultCellHeight = 70.0;

@interface HDSettingsControlsView ()

@end

@implementation HDSettingsControlsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor flatWetAsphaltColor];
        [self _setup];
    }
    return self;
}

- (void)_setup
{
    
    CGRect descriptionFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds) - CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds));
    self.descriptionLabel = [[UILabel alloc] initWithFrame:descriptionFrame];
    self.descriptionLabel.font = GILLSANS_LIGHT(CGRectGetHeight(self.bounds)/2.5f);
    self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    self.descriptionLabel.center = CGPointMake(CGRectGetWidth(self.bounds)/1.5f + 5.0f, CGRectGetMidY(self.descriptionLabel.bounds));
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.text = @"Vibration";
    [self addSubview:self.descriptionLabel];
}

@end

@interface HDSettingsViewController ()

@end

@implementation HDSettingsViewController

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    [self _setup];
}

#pragma mark - Private

- (void)_setup
{
    
    for (int i = 0; i < 4; i++) {
        CGRect controlFrame = CGRectMake(50.0f, 50.0f, CGRectGetWidth(self.view.bounds) - 100.0f, defaultCellHeight);
        HDSettingsControlsView *control = [[HDSettingsControlsView alloc] initWithFrame:controlFrame];
        [self.view addSubview:control];
    }
}

@end
