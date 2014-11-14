//
//  HDHexagonNode.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHexagonNode.h"
#import "SKColor+HDColor.h"

@interface HDHexagonNode ()

@end

@implementation HDHexagonNode

- (instancetype)init
{
    if (self = [super init]) {
        [self setLineWidth:4.0f];
    }
    return self;
}

- (void)updateLabelWithText:(NSString *)text
{
    [self updateLabelWithText:text color:[SKColor flatEmeraldColor]];
}

- (void)updateLabelWithText:(NSString *)text color:(UIColor *)color
{
    if (!self.label) {
         self.label = [SKLabelNode labelNodeWithText:text];
        [self.label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [self.label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [self.label setPosition:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];
        [self.label setFontName:@"GillSans"];
        [self.label setFontSize:20.0f];
        [self.label setFontColor:color];
        [self addChild:self.label];
    }
}

@end
