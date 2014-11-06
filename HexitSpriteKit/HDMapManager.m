//
//  HDMapManager.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevel.h"
#import "HDMapManager.h"

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
    
    for (NSData *data in [[NSUserDefaults standardUserDefaults] objectForKey:hdDefaultLevelKey]) {
        HDLevel *level = (HDLevel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        [level setUnlocked:YES];
        [_levels addObject:level];
    }
    
    return _levels;
}

- (void)initalizeLevelsForFirstRun
{
    NSMutableArray *levels = [NSMutableArray array];
    
    for (int i = 1; i < 31; i++) {
        HDLevel *level = [HDLevel levelUnlocked:(i == 1) index:i completed:NO];
        
        NSData *levelData = [NSKeyedArchiver archivedDataWithRootObject:level];
        [levels addObject:levelData];
    }
    [[NSUserDefaults standardUserDefaults] setObject:levels forKey:hdDefaultLevelKey];
}

- (void)completedLevelAtIndex:(NSInteger)index
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:hdDefaultLevelKey];
    
    HDLevel *thisLevel = [_levels objectAtIndex:index - 1];
    HDLevel *nextLevel = [_levels objectAtIndex:MIN(index, 29)];
    
    [thisLevel setCompleted:YES];
    [nextLevel setUnlocked:YES];
    
    NSMutableArray *levels = [NSMutableArray array];
    
    for (HDLevel *level in _levels) {
        NSData *levelData = [NSKeyedArchiver archivedDataWithRootObject:level];
        [levels addObject:levelData];
    }
    [[NSUserDefaults standardUserDefaults] setObject:levels forKey:hdDefaultLevelKey];
}


@end
