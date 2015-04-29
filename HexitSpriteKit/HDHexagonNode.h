//
//  HDHexagonNode.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;
#import "HDHexagon.h"

@interface HDHexagonNode : SKSpriteNode
@property (nonatomic, assign) CGPoint defaultPosition;
@property (nonatomic, getter=isLocked, assign) BOOL locked;
- (void)indicatorPositionFromHexagonType:(HDHexagonType)type;
- (void)indicatorPositionFromHexagonType:(HDHexagonType)type withTouchesCount:(NSInteger)count;
@end


