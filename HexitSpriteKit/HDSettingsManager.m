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

#pragma mark -
#pragma mark - <HDRearViewControllerDelegate>

- (void)layoutToggleSwitchesForSettingsFromArray:(NSArray *)array
{
    if (array) {
        
        for (UIButton *button in array) {
            [button addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [array[0] setSelected:self.vibration];
        [array[1] setSelected:self.sound];
        [array[2] setSelected:self.space];
       // [array[3] setSelected:self.guide];
    }
}

#pragma mark -
#pragma mark - Switches

- (void)toggleSwitch:(id)sender
{
    UIButton *toggleSwitch = (UIButton *)sender;
    [toggleSwitch setSelected:!toggleSwitch.selected];
    
    switch (toggleSwitch.tag) {
        case 0:
            [self setSound:!self.sound];
            [[NSUserDefaults standardUserDefaults] setBool:self.sound forKey:HDSoundkey];
            break;
        case 1:
            [self setVibration:!self.vibration];
            [[NSUserDefaults standardUserDefaults] setBool:self.vibration forKey:HDVibrationKey];
            break;
        case 2:
            [self setSpace:!self.space];
            [[NSUserDefaults standardUserDefaults] setBool:self.space forKey:HDEffectsKey];
            break;
        case 3:
            [self setGuide:!self.guide];
            [[NSUserDefaults standardUserDefaults] setBool:self.guide forKey:HDGuideKey];
            break;
    }
}

@end
