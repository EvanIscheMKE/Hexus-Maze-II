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
#import "UIColor+ColorAdditions.h"

@implementation HDHexagonButton

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.titleLabel.textAlignment    = NSTextAlignmentCenter;
        self.titleLabel.shadowOffset     = CGSizeMake(0.0f, 1.0f);
        self.titleLabel.font             = GILLSANS(CGRectGetWidth(self.bounds)/3.0f);
        self.adjustsImageWhenDisabled    = NO;
        self.adjustsImageWhenHighlighted = NO;
        
        [self setTitleColor:[UIColor whiteColor]
                   forState:UIControlStateNormal];
        
        [self setTitleShadowColor:[[UIColor whiteColor] colorWithAlphaComponent:.7f]
                         forState:UIControlStateNormal];
        
        [self setBackgroundImage:[UIImage imageNamed:@"Default-Count-Grid"]
                        forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"Unlocked-OneTap-Grid"]
                        forState:UIControlStateSelected];
        
        [self setImage:[UIImage imageNamed:@"Locked-Grid"]
              forState:UIControlStateNormal];
        
    }
    return self;
}


#pragma mark - Setters

- (void)setIndex:(NSInteger)index {
    _index = index;
}

- (void)setLevelState:(HDLevelState)levelState {
    
    _levelState = levelState;
    
    switch (levelState) {
        case HDLevelStateCompleted:
            self.selected = NO;
            [self setImage:[UIImage imageNamed:@"Star-Grid"]
                  forState:UIControlStateNormal];
            [self setTitle:nil
                  forState:UIControlStateNormal];
            break;
        case HDLevelStateUnlocked:
            self.selected = YES;
            [self setTitle:nil
                  forState:UIControlStateNormal];
            [self setImage:nil
                  forState:UIControlStateNormal];
            
            break;
        case HDLevelStateLocked: {
            
        }  break;
        default:
            break;
    }
}

@end
