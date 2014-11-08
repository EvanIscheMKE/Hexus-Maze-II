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
@property (nonatomic, strong) SKLabelNode *label;
@end

@implementation HDHexagonNode

- (instancetype)init
{
    if (self = [super init]) {
     
    }
    return self;
}

- (void)updateLabelWithText:(NSString *)text
{
    if (!self.label) {
         self.label = [SKLabelNode labelNodeWithText:text];
        [self.label setFontName:@"GillSans-Light"];
        [self.label setFontSize:18.0f];
        [self.label setFontColor:[SKColor blackColor]];
        [self.label setPosition:CGPointMake(20.0f, 13.0f)];
        [self addChild:self.label];
    }
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    [super setStrokeColor:strokeColor];
    [self setFillColor:strokeColor];
}

@end
