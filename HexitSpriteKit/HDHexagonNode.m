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

static const CGFloat kHexagonInset = 9.0f;

@interface HDHexagonNode ()

@end

@implementation HDHexagonNode {
    SKShapeNode *_indicator;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.lineWidth = 6;
    }
    return self;
}

- (void)_setup
{
    CGRect pathFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame)/4, CGRectGetWidth(self.frame)/4);
    CGPathRef path = [HDHelper hexagonPathForBounds:pathFrame];
    _indicator = [SKShapeNode shapeNodeWithPath:path centered:YES];
    _indicator.strokeColor = [SKColor whiteColor];
    _indicator.fillColor   = [SKColor flatWetAsphaltColor];
    _indicator.position    = CGPointZero;
    _indicator.lineWidth   = 4;
    _indicator.hidden      = YES;
    [self addChild:_indicator];
}

- (void)setStrokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    self.strokeColor = strokeColor;
    self.fillColor   = fillColor;
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

- (void)addDoubleNodeWithStroke:(UIColor *)stroke fill:(UIColor *)fill
{
    const CGFloat kTileSizeWithInset = CGRectGetHeight(CGRectInset(self.frame,
                                                                   kHexagonInset,
                                                                   kHexagonInset)
                                                       );
    
    CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0f, kTileSizeWithInset, kTileSizeWithInset)];
    SKShapeNode *hexagon = [SKShapeNode shapeNodeWithPath:pathRef centered:YES];
    hexagon.name        = HDDoubleKey;
    hexagon.antialiased = YES;
    hexagon.position    = CGPointZero;
    hexagon.strokeColor = stroke;
    hexagon.fillColor   = fill;
    hexagon.lineWidth   = self.lineWidth;
    [self addChild:hexagon];
}

- (void)addTripleNodeWithStroke:(UIColor *)stroke fill:(UIColor *)fill;
{
    CGRect rectWithInset = CGRectInset([(SKShapeNode *)[[self children] lastObject] frame], kHexagonInset, kHexagonInset);
    
    const CGFloat kTileSizeWithInset = CGRectGetHeight(rectWithInset);
    
    CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0f, kTileSizeWithInset, kTileSizeWithInset)];
    SKShapeNode *hexagon = [SKShapeNode shapeNodeWithPath:pathRef centered:YES];
    hexagon.name        = HDTripleKey;
    hexagon.antialiased = YES;
    hexagon.position    = CGPointZero;
    hexagon.strokeColor = stroke;
    hexagon.fillColor   = fill;
    hexagon.lineWidth   = self.lineWidth;
    [[[self children] lastObject] addChild:hexagon];
}

- (void)indicatorPositionFromHexagonType:(HDHexagonType)type
{
    [self indicatorPositionFromHexagonType:type withTouchesCount:0];
}

- (void)indicatorPositionFromHexagonType:(HDHexagonType)type withTouchesCount:(NSInteger)count;
{
    if (!_indicator) {
        [self _setup];
    }

    if (type == HDHexagonTypeNone) {
        [_indicator removeFromParent];
        _indicator = nil;
    } else {
        _indicator.hidden = NO;
        
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
