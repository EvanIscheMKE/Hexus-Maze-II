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

- (void)_setup
{
    SKTexture *indicatorTexture = [SKTexture textureWithImageNamed:@"indicator"];
    _indicator = [SKSpriteNode spriteNodeWithTexture:indicatorTexture];
    _indicator.position    = CGPointZero;
    [self addChild:_indicator];
}

- (void)setLocked:(BOOL)locked
{
    if (_locked == locked) {
        return;
    }
    
    _locked = locked;
    
    if (locked) {
        // Add lock
        SKSpriteNode *lock = [SKSpriteNode spriteNodeWithImageNamed:@"Locked.png"];
        [self addChild:lock];
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
    } else {
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
        }
        _indicator.position = position;
    }
}

@end
