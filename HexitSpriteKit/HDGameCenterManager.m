//
//  HDGameCenterManager.m
//  SixTilesSquare
//
//  Created by Evan William Ische on 6/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import GameKit;

#import "HDGameCenterManager.h"

NSString * const LEADERBOARDID_KEY = @"LevelLeaderboard";

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
    if (level % 15 == 0) {
        [self submitAchievementWithIdentifier:[NSString stringWithFormat:@"LevelSet%lld",level/15]];
    }
    
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        GKScore *completedLevel = [[GKScore alloc] initWithLeaderboardIdentifier:LEADERBOARDID_KEY];
        [completedLevel setValue:level];
        [GKScore reportScores:@[completedLevel] withCompletionHandler:^(NSError *error) {
            if (error) {
                
            }
        }];
    }
}

- (void)submitAchievementWithIdentifier:(NSString *)identifier
{
    GKAchievement *scoreAchievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    [scoreAchievement setShowsCompletionBanner:YES];
    [scoreAchievement setPercentComplete:100];
    
    [GKAchievement reportAchievements:@[scoreAchievement] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
}

@end
