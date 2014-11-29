//
//  Level.m
//  Hexagon
//
//  Created by Evan Ische on 10/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevel.h"

NSString * const hdCompletedKey  = @"completed";
NSString * const hdUnlockedKey   = @"unlocked";
NSString * const hdLevelIndexKey = @"levelIndex";
NSString * const hdCountKey      = @"count";

@implementation HDLevel

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeBool:self.unlocked                forKey:hdUnlockedKey];
    [encoder encodeBool:self.completed               forKey:hdCompletedKey];
    [encoder encodeInteger:self.levelIndex           forKey:hdLevelIndexKey];
    [encoder encodeInteger:self.countUntilCompletion forKey:hdCountKey];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        [self setUnlocked:  [decoder decodeBoolForKey:hdUnlockedKey]];
        [self setCompleted: [decoder decodeBoolForKey:hdCompletedKey]];
        [self setLevelIndex:[decoder decodeIntegerForKey:hdLevelIndexKey]];
        [self setCountUntilCompletion:[decoder decodeIntegerForKey:hdCountKey]];
    }
    return self;
}

+ (HDLevel *)levelUnlocked:(BOOL)unlocked index:(NSInteger)index completed:(BOOL)completed
{
    HDLevel *level = [[self alloc] init];
    [level setCountUntilCompletion:0];
    [level setUnlocked:unlocked];
    [level setLevelIndex:index];
    [level setCompleted:completed];
    
    return level;
}

- (NSString *)description
{
    NSString *completed = self.completed ? @"YES" : @"NO";
    NSString *unlocked  = self.unlocked  ? @"YES" : @"NO";
    
    return [NSString stringWithFormat:@"Completed: %@, Unlocked: %@, LevelIndex: %ld", completed, unlocked, self.levelIndex];
}

@end
