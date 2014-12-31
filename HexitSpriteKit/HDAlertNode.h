//
//  HDAlertNode.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/22/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

extern NSString * const HDNextLevelKey;
extern NSString * const HDRestartLevelKey;
extern NSString * const HDShareKey;
extern NSString * const HDGCLeaderboardKey;
extern NSString * const HDRateKey;
extern NSString * const HDGCAchievementsKey;

@protocol HDAlertnodeDelegate;
@interface HDAlertNode : SKSpriteNode
@property (nonatomic, weak) id<HDAlertnodeDelegate> delegate;
@property (nonatomic, strong) SKLabelNode *levelLabel;
- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size lastLevel:(BOOL)lastLevel;
- (void)show;
@end

@protocol HDAlertnodeDelegate <NSObject>
@optional
- (void)alertNode:(HDAlertNode *)alertNode clickedButtonWithTitle:(NSString *)title;
- (void)alertNodeFinishedIntroAnimation:(HDAlertNode *)alertNode;
@end
