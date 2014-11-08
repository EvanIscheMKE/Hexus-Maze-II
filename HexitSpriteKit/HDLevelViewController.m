//
//  HDLevelViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "UIColor+FlatColors.h"
#import "HDLevelViewController.h"
#import "HDMenuViewController.h"
#import "HDGameViewController.h"

static const CGFloat numberOfRows = 10;
static const CGFloat numberOfColumns = 3;

@interface HDLevelViewController ()

@end

@implementation HDLevelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor flatMidnightBlueColor]];
    [self _layoutTemporarybuttons];
    // Do any additional setup after loading the view.
}

- (void)_layoutTemporarybuttons
{
    CGSize kButtonSize = CGSizeMake(ceilf(CGRectGetWidth(self.view.bounds) /numberOfColumns), CGRectGetHeight(self.view.bounds) /numberOfRows);
    
    NSInteger titleIndex = 1;
    for (int row = 0; row < numberOfRows; row++) {
        
        for (int column = 0; column < numberOfColumns; column++) {
            
            CGRect rect = CGRectMake(column * kButtonSize.width, row * kButtonSize.height, kButtonSize.width, kButtonSize.height);
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:rect];
            [[button titleLabel] setTextAlignment:NSTextAlignmentCenter];
            [[button titleLabel] setFont:GILLSANS_LIGHT(18.0f)];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:[NSString stringWithFormat:@"%ld",titleIndex] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(openLevel:) forControlEvents:UIControlEventTouchUpInside];
            [button.layer setBorderColor:[[UIColor flatEmeraldColor] CGColor]];
            [button.layer setBorderWidth:2.0f];
            [self.view addSubview:button];
            
            titleIndex++;
        }
    }
}

- (void)openLevel:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    HDGameViewController *controller = [[HDGameViewController alloc] initWithLevel:button.titleLabel.text.integerValue];
    [self setFrontViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
