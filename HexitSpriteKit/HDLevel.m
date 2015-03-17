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
@implementation HDLevel

+ (instancetype)levelUnlocked:(BOOL)unlocked index:(NSUInteger)index completed:(BOOL)completed {
    HDLevel *level = [[self alloc] initUnlocked:unlocked index:index completed:completed];
    return level;
}

- (instancetype)initUnlocked:(BOOL)unlocked index:(NSUInteger)index completed:(BOOL)completed {
    if (self = [super init]) {
        self.unlocked   = unlocked;
        self.levelIndex = index;
        self.completed  = completed;
    }
    return self;
}

#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:self.unlocked      forKey:HDUnlockedKey];
    [encoder encodeBool:self.completed     forKey:HDCompletedKey];
    [encoder encodeInteger:self.levelIndex forKey:HDLevelIndexKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.unlocked   =  [decoder decodeBoolForKey:HDUnlockedKey];
        self.completed  = [decoder decodeBoolForKey:HDCompletedKey];
        self.levelIndex = [decoder decodeIntegerForKey:HDLevelIndexKey];
    }
    return self;
}

#pragma mark - Getter

- (HDLevelState)state {
    
    if (self.completed) {
        return HDLevelStateCompleted;
    } else if (!self.completed && self.isUnlocked) {
        return HDLevelStateUnlocked;
    } else {
        return HDLevelStateLocked;
    }
}

#pragma mark - Description

- (NSString *)titleFromState:(HDLevelState)state {
    switch (state) {
        case HDLevelStateCompleted:
            return @"Completed";
        case HDLevelStateUnlocked:
            return @"Unlocked";
        case HDLevelStateLocked:
            return @"Locked";
    }
    return nil;
}

- (NSString *)description {
    NSString *completed = self.completed ? @"YES" : @"NO";
    NSString *unlocked = self.unlocked ? @"YES" : @"NO";
    return [NSString stringWithFormat:@" Completed:%@ Unlocked:%@ State:%@",completed,unlocked,[self titleFromState:self.state]];
}

@end
