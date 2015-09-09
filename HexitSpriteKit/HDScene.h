//
//  HDScene.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

extern NSString * const HDSoundActionKey;

@class HDHexaObject;
@class HDGridManager;

@protocol HDSceneDelegate;
@interface HDScene : SKScene
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL countDownSoundIndex;
@property (nonatomic, assign) NSInteger soundIndex;
@property (nonatomic, assign) NSInteger levelIndex;
@property (nonatomic, strong) NSArray *hexaObjects;
@property (nonatomic, strong) NSMutableArray *mines;
@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, copy) dispatch_block_t layoutCompletion;
@property (nonatomic, weak) id<HDSceneDelegate> myDelegate;
@property (nonatomic, readonly) SKNode *gameLayer;
@property (nonatomic, readonly) SKAction *explosion;
- (void)displayPossibleMovesFromHexaObject:(HDHexaObject *)fromObj;
- (HDHexaObject *)findHexagonContainingPoint:(CGPoint)point;
- (void)checkGameStateForTile:(HDHexaObject *)tile;
- (BOOL)validateNextMoveToHexagon:(HDHexaObject *)toHexagon fromHexagon:(HDHexaObject *)fromHexagon;
- (void)playSoundForHexagon:(HDHexaObject *)hexagon vibration:(BOOL)vibration;
- (void)centerTileGrid;
- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion;
- (void)layoutNodesWithGrid:(NSArray *)grid completion:(dispatch_block_t)completion;
- (void)initialLayoutCompletion;
- (NSUInteger)inPlayTileCount;
- (void)updateDataForNextLevel;
- (void)restartWithAlert:(NSNumber *)alert;
@end

@protocol HDSceneDelegate <NSObject, SKSceneDelegate>
@optional
- (void)startTileWasSelectedInScene:(HDScene *)scene;
- (void)scene:(HDScene *)scene proceededToLevel:(NSUInteger)level;
- (void)scene:(HDScene *)scene gameEndedWithCompletion:(BOOL)completion;
- (void)gameRestartedInScene:(HDScene *)scene alert:(BOOL)alert;
- (void)gameWillResetInScene:(HDScene *)scene;
@end
