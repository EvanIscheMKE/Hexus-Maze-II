//
//  HDGameCenterManager.m
//  SixTilesSquare
//
//  Created by Evan William Ische on 6/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import GameKit;

#import "HDGameCenterManager.h"

NSString * const HDLeaderBoardKey = @"LevelLeaderboard";
@implementation HDGameCenterManager

+ (HDGameCenterManager *)sharedManager
{
    static HDGameCenterManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[HDGameCenterManager alloc] init];
    });
    return _manager;
}

- (void)authenticateGameCenter
{
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        
        __weak GKLocalPlayer *weakLocalPlayer = localPlayer;
        localPlayer.authenticateHandler = ^(UIViewController* viewController, NSError *error) {
            if (weakLocalPlayer.authenticated) {
                
            } else if(viewController) {
                
            }
        };
    }
}

- (void)reportLevelCompletion:(int64_t)level
{
    if (level == 1) {
        [self submitAchievementWithIdenifier:@"Achievement" completionBanner:YES percentComplete:100];
    }
    
    [self submitAchievementForLevel:level];
    
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        GKScore *completedLevel = [[GKScore alloc] initWithLeaderboardIdentifier:HDLeaderBoardKey];
        completedLevel.value = level;
        [GKScore reportScores:@[completedLevel] withCompletionHandler:^(NSError *error) {
            if (error) {
                
            }
        }];
    }
}

- (void)submitAchievementForLevel:(int64_t)level
{
    NSInteger identifierIndex  = ceilf(level / 14.0f);
    NSInteger percentCompleted = ceilf((level % 14) / 14.0f * 100);
    
    if (percentCompleted == 0) {
        percentCompleted += 100;
    }
    
    [self submitAchievementWithIdenifier:[NSString stringWithFormat:@"Achievement%zd",identifierIndex]
                        completionBanner:(percentCompleted == 100)
                         percentComplete:percentCompleted];
}

- (void)submitAchievementWithIdenifier:(NSString *)identifier completionBanner:(BOOL)banner percentComplete:(NSUInteger)percentCompleted
{
    GKAchievement *scoreAchievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    scoreAchievement.showsCompletionBanner = (percentCompleted == 100);
    scoreAchievement.percentComplete = percentCompleted;
    [GKAchievement reportAchievements:@[scoreAchievement] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
}

@end
