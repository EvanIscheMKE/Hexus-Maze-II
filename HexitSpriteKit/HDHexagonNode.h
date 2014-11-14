//
//  HDHexagonNode.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

@interface HDHexagonNode : SKShapeNode

@property (nonatomic, strong) SKLabelNode *label;

- (void)updateLabelWithText:(NSString *)text;
- (void)updateLabelWithText:(NSString *)text color:(UIColor *)color;

@end


