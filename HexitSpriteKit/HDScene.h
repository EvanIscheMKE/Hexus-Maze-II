//
//  HDScene.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

@class HDHexagon;
@class HDGridManager;

@protocol HDSceneDelegate;
@interface HDScene : SKScene
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL includeEndTile;
@property (nonatomic, assign) BOOL countDownSoundIndex;
@property (nonatomic, assign) NSInteger soundIndex;
@property (nonatomic, assign) NSInteger levelIndex;
@property (nonatomic, strong) NSArray *hexagons;
@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, copy) dispatch_block_t layoutCompletion;
@property (nonatomic, weak) id<HDSceneDelegate> myDelegate;
@property (nonatomic, readonly) SKNode *gameLayer;
- (BOOL)unlockLastTile;
- (BOOL)isGameOverAfterPlacingTile:(HDHexagon *)hexagon;
- (HDHexagon *)findHexagonContainingPoint:(CGPoint)point;
- (void)checkGameStateForTile:(HDHexagon *)tile;
- (void)performEffectsForTile:(HDHexagon *)tile;
- (BOOL)validateNextMoveToHexagon:(HDHexagon *)toHexagon fromHexagon:(HDHexagon *)fromHexagon;
- (void)playSoundForHexagon:(HDHexagon *)hexagon vibration:(BOOL)vibration;
- (void)centerTilePositionWithCompletion:(dispatch_block_t)completion;
- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion;
- (void)layoutNodesWithGrid:(NSArray *)grid completion:(dispatch_block_t)completion;
- (void)startConfettiEmitter;
- (void)initialSetupCompletion;
- (void)removeConfettiEmitter;
- (NSUInteger)inPlayTileCount;
- (void)nextLevel;
@end

@protocol HDSceneDelegate <NSObject, SKSceneDelegate>
@optional
- (void)startTileWasSelectedInScene:(HDScene *)scene;
- (void)scene:(HDScene *)scene proceededToLevel:(NSUInteger)level;
- (void)scene:(HDScene *)scene gameEndedWithCompletion:(BOOL)completion;
- (void)gameWillResetInScene:(HDScene *)scene;
@end
