//
//  Level.m
//  Hexagon
//
//  Created by Evan Ische on 10/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevel.h"

NSString * const HDCompletedKey  = @"completed";
NSString * const HDUnlockedKey   = @"unlocked";
NSString * const HDLevelIndexKey = @"levelIndex";
NSString * const HDCountKey      = @"count";

@implementation HDLevel

+ (HDLevel *)levelUnlocked:(BOOL)unlocked index:(NSInteger)index completed:(BOOL)completed
{
    HDLevel *level = [[self alloc] init];
    [level setUnlocked:unlocked];
    [level setLevelIndex:index];
    [level setCompleted:completed];
    
    return level;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeBool:self.unlocked      forKey:HDUnlockedKey];
    [encoder encodeBool:self.completed     forKey:HDCompletedKey];
    [encoder encodeInteger:self.levelIndex forKey:HDLevelIndexKey];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        [self setUnlocked:  [decoder decodeBoolForKey:HDUnlockedKey]];
        [self setCompleted: [decoder decodeBoolForKey:HDCompletedKey]];
        [self setLevelIndex:[decoder decodeIntegerForKey:HDLevelIndexKey]];
    }
    return self;
}

- (HDLevelState)state
{
    if (self.completed) {
        return HDLevelStateCompleted;
    } else if (!self.completed && self.isUnlocked) {
        return HDLevelStateUnlocked;
    } else {
        return HDLevelStateLocked;
    }
}

- (NSString *)description
{
    NSString *completed = self.completed ? @"YES" : @"NO";
    NSString *unlocked  = self.unlocked  ? @"YES" : @"NO";
    
    return [NSString stringWithFormat:@"Completed: %@, Unlocked: %@, LevelIndex: %ld", completed, unlocked, self.levelIndex];
}

@end
