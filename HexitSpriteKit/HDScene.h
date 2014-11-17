//
//  HDScene.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

@class HDLevels;
@protocol HDSceneDelegate;
@interface HDScene : SKScene
@property (nonatomic, weak) id<HDSceneDelegate> delegate;
@property (nonatomic, strong) HDLevels *levels;
- (void)layoutNodesWithGrid:(NSArray *)grid;
- (void)addUnderlyingIndicatorTiles;
@end

@protocol HDSceneDelegate <SKSceneDelegate>

- (void)gameOverWithCompletion:(BOOL)completion;

@end