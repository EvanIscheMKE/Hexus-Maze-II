//
//  HDSpriteNode.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/16/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHexagon.h"
#import <SpriteKit/SpriteKit.h>


@interface HDSpriteNode : SKSpriteNode

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger column;

- (void)updateTextureFromHexagonType:(HDHexagonType)type;
- (void)updateTextureFromHexagonType:(HDHexagonType)type touchesCount:(NSInteger)count;

@end
