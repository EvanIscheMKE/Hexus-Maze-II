//
//  HDSettingsViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 1/2/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHexagonView.h"
#import "UIColor+FlatColors.h"
#import "HDSettingsViewController.h"

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

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
