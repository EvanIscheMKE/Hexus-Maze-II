//
//  HDHexagonNode.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDHexagonNode.h"
#import "SKColor+HDColor.h"

@interface HDHexagonNode ()

@end

@implementation HDHexagonNode

- (instancetype)init
{
    if (self = [super init]) {
        [self setLineWidth:4.0f];
        [self setGlowWidth:0.0f];
    }
    return self;
}

- (void)updateLabelWithText:(NSString *)text
{
    [self updateLabelWithText:text color:[SKColor flatEmeraldColor]];
}

- (void)updateLabelWithText:(NSString *)text color:(UIColor *)color
{
    if (!self.label)
    {
         self.label = [SKLabelNode labelNodeWithText:text];
        [self.label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [self.label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [self.label setPosition:CGPointMake(0.0f, 0.0f)];
        [self.label setFontName:@"GillSans-Light"];
        [self.label setFontSize:CGRectGetHeight(self.frame) / 3];
        [self.label setFontColor:color];
        [self addChild:self.label];
    }
}

@end
