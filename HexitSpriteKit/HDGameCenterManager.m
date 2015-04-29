//
//  HDGameCenterManager.m
//  SixTilesSquare
//
//  Created by Evan William Ische on 6/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDGameCenterManager.h"

NSString * const HDLeaderBoardKey = @"LevelLeaderboard";

const NSUInteger completion = 100;
const CGFloat levelsPerSection = 14;
@implementation HDGameCenterManager

+ (HDGameCenterManager *)sharedManager {
    static HDGameCenterManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[HDGameCenterManager alloc] init];
    });
    return _manager;
}

- (void)authenticateGameCenter {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        return;
    };
  
    [[NSNotificationCenter defaultCenter] addObserverForName:GKPlayerAuthenticationDidChangeNotificationName
                                                      object:[GKLocalPlayer localPlayer]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"%@",note);
                                                  }];
    
    [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController* viewController, NSError *error) {
        NSLog(@"%@",error);
    };
}

- (void)reportLevelCompletion:(int64_t)level {
    
    if (level == 1) {
        [self submitAchievementWithIdenifier:@"Achievement"
                            completionBanner:YES
                             percentComplete:completion];
    }
    
    [self submitAchievementForLevel:level];
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        GKScore *completedLevel = [[GKScore alloc] initWithLeaderboardIdentifier:HDLeaderBoardKey];
        completedLevel.value = level;
        [GKScore reportScores:@[completedLevel] withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"%@ : %@",error,NSStringFromSelector(_cmd));
            }
        }];
    }
}

- (void)reportTime:(NSTimeInterval)timeInterval leaderboard:(NSString *)identifier {
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        GKScore *completedLevel = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
        completedLevel.value = timeInterval;
        [GKScore reportScores:@[completedLevel] withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"%@ : %@",error,NSStringFromSelector(_cmd));
            }
        }];
    }

}

- (void)submitAchievementForLevel:(int64_t)level {
    NSUInteger percentComplete = [self _completionPercentageFromLevel:level];
    [self submitAchievementWithIdenifier:[NSString stringWithFormat:@"Achievement%zd",ceilf(level / levelsPerSection)]
                        completionBanner:(percentComplete == completion)
                         percentComplete:percentComplete];
}

- (void)submitAchievementWithIdenifier:(NSString *)identifier completionBanner:(BOOL)banner percentComplete:(NSUInteger)percentCompleted {
    GKAchievement *scoreAchievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    scoreAchievement.showsCompletionBanner = (percentCompleted == completion);
    scoreAchievement.percentComplete = percentCompleted;
    [GKAchievement reportAchievements:@[scoreAchievement] withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
}

#pragma mark - Private

- (NSInteger)_completionPercentageFromLevel:(int64_t)level {
    NSInteger percentCompleted = ceilf((level % (NSUInteger)levelsPerSection) / levelsPerSection * completion);
    if (percentCompleted == 0) {
        return completion;
    }
    
    return percentCompleted;
}

@end
