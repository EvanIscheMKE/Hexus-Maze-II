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

@property (nonatomic, assign) NSInteger levelIndex;
@property (nonatomic, strong) HDGridManager *gridManager;

- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion;
- (void)layoutNodesWithGrid:(NSArray *)grid;
- (void)layoutIndicatorTiles;
- (void)restart;

@end

