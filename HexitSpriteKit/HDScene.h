//
//  HDScene.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

@class HDGridManager;
@protocol HDSceneDelegate;
@interface HDScene : SKScene

@property (nonatomic, assign) NSInteger levelIndex;
@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, weak) id<HDSceneDelegate> delegate;

- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion;
- (void)layoutNodesWithGrid:(NSArray *)grid;
- (void)layoutIndicatorTiles;
- (void)restart;

@end

@protocol HDSceneDelegate <NSObject, SKSceneDelegate>
@required
- (void)scene:(HDScene *)scene proceededToLevel:(NSUInteger)level;
- (void)scene:(HDScene *)scene updatedSelectedTileCount:(NSUInteger)count;
- (void)scene:(HDScene *)scene gameEndedWithCompletion:(BOOL)completion;
- (void)multipleTouchTileWasTouchedInScene:(HDScene *)scene;
- (void)gameWillResetInScene:(HDScene *)scene;
@end
