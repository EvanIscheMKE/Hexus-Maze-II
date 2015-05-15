//
//  HDHexagonNode.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHexaObject.h"
#import "HDHelper.h"
#import "HDHexaNode.h"
#import "UIColor+ColorAdditions.h"
#import "UIImage+ImageAdditions.h"

NSString * const HDLockedKey = @"locked";
NSString * const HDIndicatorKey = @"Indicator";
@implementation HDHexaNode

- (void)setLocked:(BOOL)locked {
    
    _locked = locked;
    if (locked) {
        SKSpriteNode *lock = [SKSpriteNode spriteNodeWithImageNamed:@"Locked-Node"];
        lock.name = HDLockedKey;
        lock.scale = IS_IPAD ? 1.0f : TRANSFORM_SCALE_X;
        [self addChild:lock];
    } else {
        [[self childNodeWithName:HDLockedKey] removeFromParent];
    }
}

- (void)displayNextMoveIndicatorWithColor:(UIColor *)color
                                direction:(HDTileDirection)direction
                                 animated:(BOOL)animated {
    
    UIImage *image = [UIImage tileFromSize:self.size
                                     color:color
                                 direction:direction];
    SKTexture *texture = [SKTexture textureWithImage:image];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture];
    sprite.position = CGPointMake(0.0f, 1.0f);
    sprite.name = HDIndicatorKey;
    [self addChild:sprite];
    
    if (animated) {
        [sprite runAction:[SKAction rotateByAngle:M_PI duration:.150f] completion:^{
            sprite.zRotation = 0.0f;
        }];
    }
}

- (void)setDisplayNextMoveIndicator:(BOOL)displayNextMoveIndicator {
    
    _displayNextMoveIndicator = displayNextMoveIndicator;
    if (!_displayNextMoveIndicator) {
        [[self childNodeWithName:HDIndicatorKey] removeFromParent];
    }
}

@end
