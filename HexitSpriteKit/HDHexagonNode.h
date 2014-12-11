//
//  HDHexagonNode.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

@interface HDHexagonNode : SKShapeNode
@property (nonatomic, getter=isLocked, assign) BOOL locked;
@property (nonatomic, strong) SKLabelNode *label;

- (void)setStrokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor;

- (void)updateLabelWithText:(NSString *)text;
- (void)updateLabelWithText:(NSString *)text color:(UIColor *)color;

- (void)addTripleNodeWithStroke:(UIColor *)stroke fill:(UIColor *)fill;
- (void)addDoubleNodeWithStroke:(UIColor *)stroke fill:(UIColor *)fill;

@end


