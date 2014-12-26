//
//  HDSettingsManager.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/18/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDSettingsManager.h"
#import "HDSoundManager.h"

@implementation HDSettingsManager

#pragma mark -
#pragma mark - configure

- (void)configureSettingsForFirstRun
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HDVibrationKey];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HDEffectsKey];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HDSoundkey];
    
    self.vibe  =  [[NSUserDefaults standardUserDefaults] boolForKey:HDVibrationKey];
    self.fx    =  [[NSUserDefaults standardUserDefaults] boolForKey:HDEffectsKey];
    self.sound =  [[NSUserDefaults standardUserDefaults] boolForKey:HDSoundkey];
}

#pragma mark -
#pragma mark - initalizer

- (instancetype)init
{
    if (self = [super init]) {
        self.vibe  =  [[NSUserDefaults standardUserDefaults] boolForKey:HDVibrationKey];
        self.fx    =  [[NSUserDefaults standardUserDefaults] boolForKey:HDEffectsKey];
        self.sound =  [[NSUserDefaults standardUserDefaults] boolForKey:HDSoundkey];
        self.music = YES;
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

#pragma mark - Override Setters

- (void)setFx:(BOOL)fx
{
    _fx = fx;
    [[NSUserDefaults standardUserDefaults] setBool:_fx forKey:HDEffectsKey];
}

- (void)setSound:(BOOL)sound
{
    _sound = sound;
    [[NSUserDefaults standardUserDefaults] setBool:_sound forKey:HDSoundkey];
}

- (void)setVibe:(BOOL)vibe
{
    _vibe = vibe;
    [[NSUserDefaults standardUserDefaults] setBool:_vibe forKey:HDVibrationKey];
}

@end
