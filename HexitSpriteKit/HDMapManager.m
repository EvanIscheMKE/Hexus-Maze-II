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

@interface HDMapManager ()
@property (nonatomic, readonly) NSArray *levels;
@end

@implementation HDMapManager{
    NSUInteger _numberOfLevels;
    NSMutableArray *_levels;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
        NSArray *levelFiles = [mainBundle pathsForResourcesOfType:@"json" inDirectory:nil];
        _numberOfLevels = levelFiles.count - 2;
        [self _verifyNumberOfLevels];
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

- (HDLevel *)levelAtIndex:(NSInteger)index
{
    if (index >= _numberOfLevels) {
        return nil;
    }
    return [self.levels objectAtIndex:index];
}

- (NSUInteger)numberOfLevels
{
    return _numberOfLevels;
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
    
    [[NSUserDefaults standardUserDefaults] setInteger:index + 1 forKey:@"HDLastLevelCompletedKey"];
    
    HDLevel *currentLevel = [self levelAtIndex:MAX(index, 0)];
    HDLevel *nextLevel    = [self levelAtIndex:MIN(index + 1, _numberOfLevels - 1)];
    
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

- (void)_verifyNumberOfLevels
{
    NSArray *levelsIKnowAbout = [self levels]?:@[];
    if (levelsIKnowAbout.count >= _numberOfLevels) {
        return; //Nothing to do.
    }
    
    NSMutableArray *levels = [[self levels] mutableCopy];
    NSUInteger startIndex = levelsIKnowAbout.count == 0? 0 : levelsIKnowAbout.count - 1;
    for (NSUInteger newLevelIdx = startIndex; newLevelIdx < _numberOfLevels; newLevelIdx++) {
        HDLevel *level = [HDLevel levelUnlocked:(newLevelIdx == 0) index:newLevelIdx completed:NO];
        [levels addObject:level];
    }
    
    NSMutableArray *allLevels = [NSMutableArray array];
    for (HDLevel *level in levels) {
        NSData *levelData = [NSKeyedArchiver archivedDataWithRootObject:level];
        [allLevels addObject:levelData];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:allLevels forKey:HDDefaultLevelKey];
    
    _levels = levels;
}

@end
