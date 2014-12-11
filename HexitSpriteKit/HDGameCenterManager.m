//
//  HDGameCenterManager.m
//  SixTilesSquare
//
//  Created by Evan William Ische on 6/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import GameKit;

#import "HDGameCenterManager.h"

NSString * const LEADERBOARDID_KEY = @"leaderboardkey";
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

// Login user into Game Center. If their Game Center is not set up, continue to game, otherwise check for scores to submit
- (void)authenticateForGameCenter
{
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        
        __weak GKLocalPlayer *weakLocalPlayer = localPlayer;
        localPlayer.authenticateHandler = (^(UIViewController* viewController, NSError *error) {
            if (weakLocalPlayer.authenticated) {
            
            } else if(viewController) {
                /* Any feature using Game Center will alert user they're not logged in, instead of waiting for an unpredictable signup controller thats annoying as shit! */
            }
        });
    }
}

- (void)reportLevelCompletion:(int64_t)level
{
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
