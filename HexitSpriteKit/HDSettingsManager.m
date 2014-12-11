//
//  HDSettingsManager.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/18/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDSettingsManager.h"

@implementation HDSettingsManager

- (instancetype)init
{
    if (self = [super init]) {
        [self setSound:    [[NSUserDefaults standardUserDefaults] boolForKey:HDSoundkey]];
        [self setVibration:[[NSUserDefaults standardUserDefaults] boolForKey:HDVibrationKey]];
        [self setSpace:    [[NSUserDefaults standardUserDefaults] boolForKey:HDEffectsKey]];
        [self setGuide:    [[NSUserDefaults standardUserDefaults] boolForKey:HDGuideKey]];
    }
    return self;
}

+ (HDSettingsManager *)sharedManager
{
    static HDSettingsManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HDSettingsManager alloc] init];
    });
    return manager;
}

@end
