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
@property (nonatomic, assign) BOOL effects;

@end

@implementation HDSettingsManager

- (instancetype)init
{
    if (self = [super init]) {
        
        [self setSound:    [[NSUserDefaults standardUserDefaults] boolForKey:hdSoundkey]];
        [self setVibration:[[NSUserDefaults standardUserDefaults] boolForKey:hdVibrationKey]];
        [self setEffects:  [[NSUserDefaults standardUserDefaults] boolForKey:hdEffectsKey] ];
        
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
        [array[2] setSelected:self.effects];
        
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
            [[NSUserDefaults standardUserDefaults] setBool:self.sound forKey:hdSoundkey];
            break;
        case 1:
            [self setVibration:!self.vibration];
            [[NSUserDefaults standardUserDefaults] setBool:self.vibration forKey:hdVibrationKey];
            break;
        case 2:
            [self setEffects:!self.effects];
            [[NSUserDefaults standardUserDefaults] setBool:self.effects forKey:hdEffectsKey];
            break;
        default:
            break;
    }
}

@end
