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

static const CGFloat kHexagonInset = 9.0f;

static NSString * const DOUBLE_KEY = @"double";
static NSString * const TRIPLE_KEY = @"triple";

@interface HDHexagonNode ()

@end

@implementation HDHexagonNode

- (instancetype)init
{
    if (self = [super init]) {
        [self setLineWidth:6.0f];
    }
    return self;
}

- (void)setStrokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    [self setStrokeColor:strokeColor];
    [self setFillColor:fillColor];
}

- (void)endTile
{
    SKSpriteNode *lock = [SKSpriteNode spriteNodeWithImageNamed:@"Flag"];
    [self addChild:lock];
}

- (void)setLocked:(BOOL)locked
{
    if (_locked == locked) {
        return;
    }
    
    _locked = locked;
    
    if (locked) {
        // Add lock png
        SKSpriteNode *lock = [SKSpriteNode spriteNodeWithImageNamed:@"Locked.png"];
        [self addChild:lock];
    } else {
        // Remove Lock png
        for (id nodes in self.children) {
            if ([nodes isKindOfClass:[SKSpriteNode class]]) {
                [nodes removeFromParent];
            }
        }
    }
}

- (void)addDoubleNodeWithStroke:(UIColor *)stroke fill:(UIColor *)fill
{
    const CGFloat kTileSizeWithInset = CGRectGetHeight(CGRectInset(self.frame, kHexagonInset, kHexagonInset));
    
    CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0f, kTileSizeWithInset, kTileSizeWithInset)];
    SKShapeNode *hexagon = [SKShapeNode shapeNodeWithPath:pathRef centered:YES];
    [hexagon setName:DOUBLE_KEY];
    [hexagon setAntialiased:YES];
    [hexagon setPosition:CGPointZero];
    [hexagon setStrokeColor:stroke];
    [hexagon setFillColor:fill];
    [hexagon setLineWidth:self.lineWidth];
    [self addChild:hexagon];
}

- (void)addTripleNodeWithStroke:(UIColor *)stroke fill:(UIColor *)fill;
{
    CGRect rectWithInset = CGRectInset([(SKShapeNode *)[[self children] lastObject] frame], kHexagonInset, kHexagonInset);
    const CGFloat kTileSizeWithInset = CGRectGetHeight(rectWithInset);
    
    CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0f, kTileSizeWithInset, kTileSizeWithInset)];
    SKShapeNode *hexagon = [SKShapeNode shapeNodeWithPath:pathRef centered:YES];
    [hexagon setName:TRIPLE_KEY];
    [hexagon setAntialiased:YES];
    [hexagon setPosition:CGPointZero];
    [hexagon setStrokeColor:stroke];
    [hexagon setFillColor:fill];
    [hexagon setLineWidth:self.lineWidth];
    [[[self children] lastObject] addChild:hexagon];
}

@end
