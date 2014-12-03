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
         self.label = [self _makeDropShadowString:text color:color];
        [self addChild:self.label];
    } else {
        for (id label in self.children) {
            if ([label isKindOfClass:[SKLabelNode class]]) {
                [label setText:text];
                [label setFontColor:color];
            }
        }
    }
}

- (void)setStrokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    [self setStrokeColor:strokeColor];
    [self setFillColor:fillColor];
}

#pragma mark -
#pragma mark - < PRIVATE >

- (SKLabelNode *)_makeDropShadowString:(NSString *)labelText color:(UIColor *)color
{
    const CGFloat kOffset = 1.0f;
    
    SKLabelNode *completedString = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Light"];
    [completedString setFontColor:color];
    
    SKLabelNode *dropShadow = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Light"];
    [dropShadow setFontSize:CGRectGetHeight(self.frame) / 3];
    [dropShadow setFontColor:[SKColor blackColor]];
    [dropShadow setZPosition:completedString.zPosition - 1];
    [dropShadow setPosition:CGPointMake(dropShadow.position.x - kOffset, dropShadow.position.y - kOffset)];
    
    [completedString addChild:dropShadow];
    for (SKLabelNode *label in @[completedString, dropShadow]) {
        [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [label setFontSize:CGRectGetHeight(self.frame) / 3];
        [label setText:labelText];
    }
    
    return completedString;
}

@end
