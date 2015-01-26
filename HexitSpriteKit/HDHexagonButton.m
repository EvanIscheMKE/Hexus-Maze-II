//
//  HDHexagonView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDLevel.h"
#import "HDHelper.h"
#import "HDHexagonButton.h"
#import "UIColor+FlatColors.h"

@implementation HDHexagonButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

#pragma mark - Private

- (void)_setup
{
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = GILLSANS(CGRectGetWidth(self.bounds)/3);
    self.imageView.clipsToBounds = NO;
    self.imageView.contentMode = UIViewContentModeCenter;
    
    CGAffineTransform scale =  CGAffineTransformMakeScale(CGRectGetWidth(self.bounds) / 64.5f, CGRectGetWidth(self.bounds)/ 64.5f);
    self.imageView.transform  = scale;
    self.titleLabel.transform = scale;
    
    [self setTitleColor:[UIColor flatWetAsphaltColor] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"Default-Count"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"Locked"] forState:UIControlStateNormal];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat spacing =  [HDHelper isWideScreen] ? 2.0f : 0.0f;
    CGSize imageSize = self.imageView.image.size;
    
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(self.frame.size.width, self.frame.size.height - (imageSize.height + spacing))];
    
    self.imageView.frame = CGRectMake(
                                      (self.frame.size.width - imageSize.width)/2,
                                      (self.frame.size.height - (imageSize.height+spacing+titleSize.height))/2,
                                      imageSize.width,
                                      imageSize.height
                                      );
    
    self.titleLabel.frame = CGRectMake(
                                       (self.frame.size.width - titleSize.width)/2,
                                       CGRectGetMaxY(self.imageView.frame)+spacing,
                                       titleSize.width,
                                       titleSize.height
                                       );
}

#pragma mark - Setters

- (void)setIndex:(NSInteger)index
{
    _index = index;
    if (self.levelState != HDLevelStateLocked) {
        [self setBackgroundImage:[UIImage imageNamed:@"Selected-OneTouch"] forState:UIControlStateNormal];
        [self setTitle:[NSString stringWithFormat:@"%zd", index] forState:UIControlStateNormal];
    } else {
        [self setTitle:nil forState:UIControlStateNormal];
    }
}

- (void)setLevelState:(HDLevelState)levelState
{
    _levelState = levelState;
    if (levelState != HDLevelStateLocked) {
        [self setImage:[UIImage imageNamed:(levelState == HDLevelStateCompleted)? @"WhiteStar-" : @"BlueStar-"]
              forState:UIControlStateNormal];
        return;
    }
    self.index = self.index;
}

@end
