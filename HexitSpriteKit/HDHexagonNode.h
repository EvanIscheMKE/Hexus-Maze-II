//
//  HDHexagonNode.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

@interface HDHexagonNode : SKSpriteNode

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *strokeColor;

@property (nonatomic, assign) CGPathRef pathRef;
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, assign) CGPoint defaultPosition;
@property (nonatomic, getter=isLocked, assign) BOOL locked;

+ (instancetype)shapeNodeWithPath:(CGPathRef)pathRef;

- (void)addHexaLayer;
- (void)setStrokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor;
- (void)indicatorPositionFromHexagonType:(HDHexagonType)type;
- (void)indicatorPositionFromHexagonType:(HDHexagonType)type withTouchesCount:(NSInteger)count;

@end


