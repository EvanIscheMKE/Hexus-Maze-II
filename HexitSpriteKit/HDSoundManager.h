//
//  HDSoundManager.h
//  SixTilesSquare
//
//  Created by Evan William Ische on 6/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface HDSoundManager : NSObject
@property (nonatomic, strong) NSMutableDictionary *sounds;
+ (HDSoundManager *)sharedManager;
- (void)playSound:(NSString *)soundName;
- (void)preloadSounds:(NSArray *)preloadedSounds;
@end