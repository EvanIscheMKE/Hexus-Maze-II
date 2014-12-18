//
//  HDMapManager.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevel.h"
#import "HDMapManager.h"
#import "HDGameCenterManager.h"

static const NSInteger MAX_LEVELS = 150;

@interface HDMapManager ()
@property (nonatomic, readonly) NSArray *levels;
@end

@implementation HDMapManager{
      NSMutableArray *_levels;
}

- (instancetype)init
{
    if (self = [super init]) {
   
    }
    return self;
}

+ (HDMapManager *)sharedManager
{
    static HDMapManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[HDMapManager alloc] init];
    });
    return _manager;
}

- (NSArray *)levels
{
    if (_levels) {
        return _levels;
    }
    
    _levels = [NSMutableArray array];
    
    for (NSData *data in [[NSUserDefaults standardUserDefaults] objectForKey:HDDefaultLevelKey]) {
        HDLevel *level = (HDLevel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        [_levels addObject:level];
    }
    
    return _levels;
}

- (void)configureDataBaseForFirstRun
{
    NSMutableArray *levels = [NSMutableArray array];
    
    for (int i = 0; i < MAX_LEVELS; i++) {
        HDLevel *level = [HDLevel levelUnlocked:(i == 0) index:i completed:NO];
        
        NSData *levelData = [NSKeyedArchiver archivedDataWithRootObject:level];
        [levels addObject:levelData];
    }
    [[NSUserDefaults standardUserDefaults] setObject:levels forKey:HDDefaultLevelKey];
}

- (HDLevel *)levelAtIndex:(NSInteger)index
{
    return [self.levels objectAtIndex:index];
}

- (NSInteger)indexOfCurrentLevel
{
    for (HDLevel *level in self.levels) {
        if (!level.completed && level.unlocked) {
            return level.levelIndex + 1;
        }
    }
    return 1;
}

- (void)completedLevelAtIndex:(NSInteger)index
{
    [[HDGameCenterManager sharedManager] reportLevelCompletion:index + 1];
    
    HDLevel *currentLevel = [self levelAtIndex:MAX(index, 0)];
    HDLevel *nextLevel    = [self levelAtIndex:MIN(index + 1, MAX_LEVELS - 1)];
    
    if (currentLevel.completed) {
        return;
    }
    
    [currentLevel setCompleted:YES];
    [nextLevel setUnlocked:YES];
    
    NSMutableArray *levels = [NSMutableArray array];
    for (HDLevel *level in self.levels) {
        NSData *levelData = [NSKeyedArchiver archivedDataWithRootObject:level];
        [levels addObject:levelData];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:levels forKey:HDDefaultLevelKey];
}

@end
