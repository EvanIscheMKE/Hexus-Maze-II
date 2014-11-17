//
//  HDMapScrollView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/14/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDMapScrollView.h"
#import "UIColor+FlatColors.h"

@implementation HDMapScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
    
        for (int i = 0; i < 5; i++) {
            
            CGFloat kOriginX = ceilf(CGRectGetWidth(self.bounds) * i) + 5.0f;
            CGRect rect = CGRectMake(kOriginX, 0.0, CGRectGetWidth(CGRectInset(self.bounds, 5.0f, 0.0)), CGRectGetHeight(self.bounds));
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor whiteColor]];
            [button setAdjustsImageWhenHighlighted:NO];
            [button setImage:[UIImage imageNamed:@"hexagonshexagons.png"] forState:UIControlStateNormal];
            [button setFrame:rect];
            [self addSubview:button];
            
        }
        
        [self setClipsToBounds:NO];
        [self setPagingEnabled:YES];
        [self setContentSize:CGSizeMake(CGRectGetWidth(self.bounds) * 5, CGRectGetHeight(self.bounds))];
        [self setShowsHorizontalScrollIndicator:NO];
        
    }
    return self;
}

@end
