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

//static CGFloat RADIANS_DEGREES(CGFloat radians){
//    return ((radians * 180) / M_PI);
//}
//
//static CGFloat half(CGFloat number){
//    return number / 2.0f;
//};
//
static CGFloat HEXAGON_WITH_INSET(CGFloat number){
    return number / 1.25f;
};

//keys
extern NSString * const hdSoundNotification;
extern NSString * const hdVibrationNotification;
extern NSString * const hdRestartNotificaiton;

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
extern NSString * const hdBubbleSoundKey;
extern NSString * const hdHexGridKey;
extern NSString * const hdHexZoomKey;

#define GILLSANS(x)       [UIFont fontWithName:@"GillSans" size:x]
#define GILLSANS_BOLD(x)  [UIFont fontWithName:@"GillSans-Bold" size:x]
#define GILLSANS_LIGHT(x) [UIFont fontWithName:@"GillSans-Light" size:x]

#define LEVEL_URL(x) [NSString stringWithFormat:@"Grid-%ld",x]

#define HDSoundsForPreload @[hdBubbleSoundKey]
