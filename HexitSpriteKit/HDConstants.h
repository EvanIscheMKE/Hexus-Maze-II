//
//  Constants.h
//  Hexagon
//
//  Created by Evan Ische on 10/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

static inline CGFloat DEGREES_RADIANS(CGFloat degrees){
    return ((degrees * M_PI) / 180.0f);
}

//keys
extern NSString * const HDIntroAnimationNotification;
extern NSString * const HDAnimateLabelNotification;
extern NSString * const HDCompletedTileCountNotification;
extern NSString * const HDClearTileCountNotification;

extern NSString * const HDNextLevelNotification;
extern NSString * const HDToggleControlsNotification;
extern NSString * const HDSoundNotification;
extern NSString * const HDVibrationNotification;
extern NSString * const HDRestartNotificaiton;

//UserDefault Keys
extern NSString * const HDDefaultLevelKey;
extern NSString * const HDGuideKey;
extern NSString * const HDFirstRunKey;
extern NSString * const HDEffectsKey;
extern NSString * const HDSoundkey;
extern NSString * const HDVibrationKey;
extern NSString * const HDRemainingLivesKey;
extern NSString * const HDRemainingTime;
extern NSString * const HDBackgroundDate;

//
extern NSString * const HDBubbleSoundKey;
extern NSString * const HDHexGridKey;

extern NSString * const HDSoundLoopKey;
extern NSString * const HDButtonSound;
extern NSString * const HDSwipeSound;
extern NSString * const HDC3;
extern NSString * const HDD3;
extern NSString * const HDE3;
extern NSString * const HDF3;

#define GILLSANS(x)       [UIFont fontWithName:@"GillSans" size:x]
#define GILLSANS_LIGHT(x) [UIFont fontWithName:@"GillSans-Light" size:x]

#define LEVEL_URL(x) [NSString stringWithFormat:@"Grid-%ld",x]

#define SOUNDS_TO_PRELOAD @[HDButtonSound, HDSwipeSound, HDC3, HDD3, HDE3, HDF3]
