//
//  HDSoundManager.m
//  SixTilesSquare
//
//  Created by Evan William Ische on 6/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDSoundManager.h"

@implementation HDSoundManager

+ (HDSoundManager *)sharedManager
{
    static HDSoundManager *_soundController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _soundController = [[HDSoundManager alloc] init];
    });
    return _soundController;
}

- (void)preloadSounds:(NSArray *)soundNames
{
    if (!_sounds) {
        _sounds = [NSMutableDictionary dictionary];
    }
    
    for (NSString *effect in soundNames) {
        
        NSError *error = nil;
        NSString *soundPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: effect];
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:soundPath] error:&error];
        [player prepareToPlay];
        _sounds[effect] = player;
    }
}

- (void)playSound:(NSString *)soundName
{
    AVAudioPlayer *player = (AVAudioPlayer *)_sounds[soundName];
   // if ([[NSUserDefaults standardUserDefaults] boolForKey:HDSoundkey]) {
        [player play];
   // }
}


@end
