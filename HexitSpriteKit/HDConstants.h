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

typedef enum {
    HDLevelStateLocked    = 0,
    HDLevelStateUnlocked  = 1,
    HDLevelStateCompleted = 2,
    HDLevelStateNone      = 3
} HDLevelState;

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
extern NSString * const HDHexGridKey;
extern NSString * const HDSoundLoopKey;
extern NSString * const HDButtonSound;
extern NSString * const HDSwipeSound;

static const CGFloat kSmallButtonSize  = 34.0f;
static const CGFloat kLargeButtonSize  = 42.0f;
static const CGFloat kButtonInset      = 20.0f;

#define sound0 @"C4.m4a"
#define sound1 @"D4.m4a"
#define sound2 @"E4.m4a"
#define sound3 @"win.mp3"

//MarkerFelt-Thin
#define GILLSANS(x)       [UIFont fontWithName:@"GillSans" size:x]
#define GILLSANS_LIGHT(x) [UIFont fontWithName:@"GillSans-Light" size:x]

#define LEVEL_URL(x) [NSString stringWithFormat:@"Grid-%ld",x]

#define SOUNDS_TO_PRELOAD @[HDButtonSound, HDSwipeSound, sound1, sound2, sound3, sound0]
