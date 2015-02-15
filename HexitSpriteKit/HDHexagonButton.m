//
//  HDHexagonView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevel.h"
#import "HDHelper.h"
#import "HDHexagonButton.h"
#import "UIColor+FlatColors.h"
#import "CAEmitterCell+HD.h"

@implementation HDHexagonButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

#pragma mark - Private

- (void)_setup {
    
    self.titleLabel.textAlignment    = NSTextAlignmentCenter;
    self.titleLabel.font             = GILLSANS(CGRectGetWidth(self.bounds)/3);
    self.imageView.clipsToBounds     = NO;
    self.imageView.contentMode       = UIViewContentModeCenter;
    self.adjustsImageWhenDisabled    = NO;
    self.adjustsImageWhenHighlighted = NO;
    self.titleEdgeInsets = UIEdgeInsetsMake(12.0f, 0.0f, -12.0f, 0.0f);
    
    [self setTitleColor:[UIColor flatWetAsphaltColor] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"Default-Count-Grid"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"Locked-25"] forState:UIControlStateNormal];
}

#pragma mark - Setters

- (void)setIndex:(NSInteger)index
{
    _index = index;
    
    if (self.levelState == HDLevelStateLocked) {
        [self setTitle:nil forState:UIControlStateNormal];
        return;
    }
    
    [self setTitle:[NSString stringWithFormat:@"%zd", index] forState:UIControlStateNormal];
    [self setImage:nil forState:UIControlStateNormal];
}

- (void)setLevelState:(HDLevelState)levelState
{
    _levelState = levelState;
    
    switch (levelState) {
        case HDLevelStateCompleted:
             [self setBackgroundImage:[UIImage imageNamed:@"Selected-OneTap-Grid"] forState:UIControlStateNormal];
            break;
        case HDLevelStateUnlocked:
            [self setBackgroundImage:[UIImage imageNamed:@"OneTap-Grid"] forState:UIControlStateNormal];
            break;
        case HDLevelStateLocked:
            [self setBackgroundImage:[UIImage imageNamed:@"Default-Count-Grid"] forState:UIControlStateNormal];
            break;
        case HDLevelStateNone:
            
            break;
        default:
            break;
    }
    self.index = self.index;
}

@end
