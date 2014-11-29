//
//  HDSettingsManager.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/18/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDSettingsManager.h"

@interface HDSettingsManager ()

@property (nonatomic, assign) BOOL sound;
@property (nonatomic, assign) BOOL vibration;
@property (nonatomic, assign) BOOL space;
@property (nonatomic, assign) BOOL guide;

@end

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

- (void)toggleSound
{
    [self setSound:!self.sound];
}

- (void)toggleVibration
{
    [self setVibration:!self.vibration];
}

- (void)toggleSpace
{
    [self setSpace:!self.space];
}

- (void)toggleGuide
{
    [self setGuide:!self.guide];
}


@end
