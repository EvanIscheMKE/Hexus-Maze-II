//
//  HDMapManager.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevel.h"
#import "HDMapManager.h"

@interface HDMapManager ()

@property (nonatomic, assign) NSUInteger totalNumberOfLevels;
@property (nonatomic, assign) NSUInteger numberOfSections;
@property (nonatomic, assign) NSUInteger numberOfLevelsInSection;

@end

@implementation HDMapManager{
      NSMutableArray *_levels;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.totalNumberOfLevels = 75;
        self.numberOfSections = 5;
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

- (void)configureLevelDataForFirstRun
{
    NSMutableArray *levels = [NSMutableArray array];
    
    for (int i = 1; i < self.totalNumberOfLevels + 1; i++) {
        HDLevel *level = [HDLevel levelUnlocked:(i == 1) index:i completed:NO];
        
        NSData *levelData = [NSKeyedArchiver archivedDataWithRootObject:level];
        [levels addObject:levelData];
    }
    [[NSUserDefaults standardUserDefaults] setObject:levels forKey:HDDefaultLevelKey];
}

- (void)completedLevelAtIndex:(NSInteger)index
{
    if (!index) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:HDDefaultLevelKey];
    
    HDLevel *thisLevel = [_levels objectAtIndex:index - 1];
    HDLevel *nextLevel = [_levels objectAtIndex:MIN(index, self.totalNumberOfLevels - 1)];
    
    [thisLevel setCompleted:YES];
    [nextLevel setUnlocked:YES];
    
    NSMutableArray *levels = [NSMutableArray array];
    
    for (HDLevel *level in _levels) {
        NSData *levelData = [NSKeyedArchiver archivedDataWithRootObject:level];
        [levels addObject:levelData];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:levels forKey:HDDefaultLevelKey];
}

- (NSUInteger)numberOfLevelsInSection
{
    return self.totalNumberOfLevels / self.numberOfSections;
}


@end
