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
@property (nonatomic, getter=isPlayingLoop, assign) BOOL playLoop;
@property (nonatomic, strong) NSMutableDictionary *sounds;
+ (HDSoundManager *)sharedManager;

- (void)playSound:(NSString *)soundName;
- (void)preloadSounds:(NSArray *)preloadedSounds;

 /* AVAudioSession cannot be active while the application is in the background, so we have to stop it when going in to background, and reactivate it when entering foreground. */
- (void)startAudio;
- (void)stopAudio;

@end
