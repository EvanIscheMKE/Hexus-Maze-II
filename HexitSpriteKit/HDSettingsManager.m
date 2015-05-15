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

#pragma mark - Configure

- (void)configureSettingsForFirstRun {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:YES forKey:HDSoundkey];
    [defaults setBool:YES forKey:HDMusickey];
    [defaults setBool:YES forKey:HDParallaxBackgroundKey];
    
    self.music = [defaults boolForKey:HDMusickey];
    self.sound = [defaults boolForKey:HDSoundkey];
    self.parallaxBackground = [defaults boolForKey:HDParallaxBackgroundKey];
}

#pragma mark - Initalizer

- (instancetype)init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.parallaxBackground = [defaults boolForKey:HDParallaxBackgroundKey];
        self.sound = [defaults boolForKey:HDSoundkey];
        self.music = [defaults boolForKey:HDMusickey];
    }
    return self;
}

+ (HDSettingsManager *)sharedManager {
    static HDSettingsManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HDSettingsManager alloc] init];
    });
    return manager;
}

#pragma mark - Override Setters

- (void)setSound:(BOOL)sound {
    _sound = sound;
    [[NSUserDefaults standardUserDefaults] setBool:_sound forKey:HDSoundkey];
}

- (void)setMusic:(BOOL)music {
    _music = music;
    [[NSUserDefaults standardUserDefaults] setBool:_music forKey:HDMusickey];
}

- (void)setParallaxBackground:(BOOL)parallaxBackground {
    _parallaxBackground = parallaxBackground;
    [[NSUserDefaults standardUserDefaults] setBool:_parallaxBackground forKey:HDParallaxBackgroundKey];
}

@end
