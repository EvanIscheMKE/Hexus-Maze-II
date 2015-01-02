//
//  HDInfoView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/27/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDInfoView.h"
#import "HDTableViewCell.h"
#import "UIColor+FlatColors.h"

NSString * const tableViewIdentifier = @"identifer";

@interface HDInfoView ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *top;
@property (nonatomic, strong) UILabel *bottom;
@end

@implementation HDInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor flatAlizarinColor];
        self.layer.cornerRadius = 15.0f;
        self.layer.masksToBounds = YES;
        [self _setup];
    }
    return self;
}

- (void)_setup
{
    self.top = [[UILabel alloc] init];
    self.top.text = NSLocalizedString(@"Get to know the tiles", nil);
    
    self.bottom = [[UILabel alloc] init];
    self.bottom.text = NSLocalizedString(@"Touch anywhere to return!", nil);
    
    NSUInteger index = 0;
    for (UILabel *label in @[self.top, self.bottom]) {
        label.font = GILLSANS_LIGHT(20.0f);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        label.center = CGPointMake(
                                   CGRectGetMidX(self.bounds),
                                   (index == 0) ? 25.0f : CGRectGetHeight(self.bounds) - 25.0f
                                   );
        label.frame = CGRectIntegral(label.frame);
        [self addSubview:label];
        
        index++;
    }
    
    CGRect tableViewFrame = CGRectInset(self.bounds, 2.0f, 50.0f);
     self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame];
     self.tableView.backgroundColor = [UIColor flatWetAsphaltColor];
     self.tableView.showsVerticalScrollIndicator = NO;
     self.tableView.rowHeight = CGRectGetHeight(CGRectInset(self.bounds, 0.0f, 50.0f))/4;
    [self.tableView registerClass:[HDTableViewCell class] forCellReuseIdentifier:tableViewIdentifier];
    [self addSubview:self.tableView];
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate dataSource:(id<UITableViewDataSource>)datasource
{
    self.tableView.delegate = delegate;
    self.tableView.dataSource = datasource;
}

@end
