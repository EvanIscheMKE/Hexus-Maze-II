//
//  HDHexagonNode.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHexagon.h"
#import "HDHelper.h"
#import "HDHexagonNode.h"
#import "SKColor+HDColor.h"

@interface HDHexagonNode ()
@property (nonatomic, strong) SKLabelNode *countLabel;
@end

@implementation HDHexagonNode {
    SKSpriteNode *_indicator;
    NSUInteger _layerIndex;
}

#pragma mark - Private

- (void)_setup
{
    SKTexture *indicatorTexture = [SKTexture textureWithImageNamed:@"indicator"];
    _indicator = [SKSpriteNode spriteNodeWithTexture:indicatorTexture];
    _indicator.scale    = CGRectGetWidth([[UIScreen mainScreen] bounds])/375.0f;
    _indicator.position = CGPointZero;
    [self addChild:_indicator];
}

#pragma mark - Public

- (void)setLocked:(BOOL)locked
{
    _locked = locked;
    
    if (locked) {
        // Add lock
        if (![[self children] count]) {
            SKSpriteNode *lock = [SKSpriteNode spriteNodeWithImageNamed:@"Locked-22"];
            lock.scale = CGRectGetWidth([[UIScreen mainScreen] bounds])/375.0f;
            [self addChild:lock];
        }
    } else {
        // Remove Lock
        [self.children makeObjectsPerformSelector:@selector(removeFromParent)];
    }
}

- (void)indicatorPositionFromHexagonType:(HDHexagonType)type
{
    [self indicatorPositionFromHexagonType:type withTouchesCount:0];
}

- (void)indicatorPositionFromHexagonType:(HDHexagonType)type withTouchesCount:(NSInteger)count;
{
    if (type == HDHexagonTypeNone) {
        [_indicator removeFromParent];
        _indicator = nil;
        return;
    }
    
    [self _setup];
    
    CGPoint position = CGPointZero;
    switch (type) {
        case HDHexagonTypeDouble:
            if (count == 0) {
                position = CGPointMake(1.0f, 1.0f);
            } break;
        case HDHexagonTypeTriple:
            if (count == 0) {
                position = CGPointMake(2.0f, 2.0f);
            } else if (count == 1) {
                position = CGPointMake(1.0f, 1.0f);
            } break;
        default:
            break;
    }
    _indicator.position = position;
}

@end
