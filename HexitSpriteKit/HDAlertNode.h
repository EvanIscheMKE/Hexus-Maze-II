//
//  HDAlertNode.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/22/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

extern NSString * const NEXTLEVELKEY;
extern NSString * const RESTARTKEY;
extern NSString * const SHAREKEY;
extern NSString * const LEADERBOARDKEY;
extern NSString * const RATEKEY;
extern NSString * const ACHIEVEMENTSKEY;

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
