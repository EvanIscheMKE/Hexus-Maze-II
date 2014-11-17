//
//  HDSpriteNode.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/16/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHexagon.h"
#import <SpriteKit/SpriteKit.h>

typedef enum{
    HDSpriteDirectionLeft       = 1,
    HDSpriteDirectionRight      = 2,
    HDSpriteDirectionDownRight  = 3,
    HDSpriteDirectionDownLeft   = 4,
    HDSpriteDirectionUpRight    = 5,
    HDSpriteDirectionUpLeft     = 6,
    HDSpriteDirectionNone       = 0
}HDSpriteDirection;

@interface HDSpriteNode : SKSpriteNode

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger column;

- (void)updateTextureFromHexagonType:(HDHexagonType)type direction:(HDSpriteDirection)direction;

@end
