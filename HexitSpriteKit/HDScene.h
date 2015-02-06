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
@property (nonatomic, weak) id<HDSceneDelegate> myDelegate;

- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion;
- (void)layoutNodesWithGrid:(NSArray *)grid;
- (void)restart;

@end

@protocol HDSceneDelegate <NSObject, SKSceneDelegate>
@required
- (void)scene:(HDScene *)scene proceededToLevel:(NSUInteger)level;
- (void)scene:(HDScene *)scene gameEndedWithCompletion:(BOOL)completion;
@optional
- (void)gameWillResetInScene:(HDScene *)scene;
@end
