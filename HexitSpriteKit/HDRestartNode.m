//
//  HDMenuNode.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/25/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDRestartNode.h"
#import "SKColor+HDColor.h"

@interface HDRestartNode ()
@property (nonatomic, strong) SKLabelNode *restart;
@end

@implementation HDRestartNode

- (instancetype)init
{
    if (self = [super init]) {
        self.strokeColor = [SKColor whiteColor];
        self.lineWidth   = 5;
        [self _setup];
    }
    return self;
}

- (void)_setup
{
    CGPoint labelPosition = CGPointMake(0.0f, 0.0f);
     self.restart = [SKLabelNode labelNodeWithText:@"Try Again"];
    self.restart.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.restart.verticalAlignmentMode   = SKLabelVerticalAlignmentModeCenter;
    self.restart.fontColor = [SKColor whiteColor];
    self.restart.fontName  = @"GillSans-Light";
    self.restart.fontSize  = 26.0f;
    self.restart.position  = labelPosition;
    [self addChild:self.restart];
}

@end
