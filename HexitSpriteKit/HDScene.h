//
//  HDScene.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

@class HDGridManager;
@interface HDScene : SKScene

@property (nonatomic, assign) NSUInteger levelIndex;
@property (nonatomic, strong) HDGridManager *gridManager;

- (void)layoutNodesWithGrid:(NSArray *)grid;
- (void)addUnderlyingIndicatorTiles;
- (void)restart;

@end
