//
//  HDSoundManager.m
//  SixTilesSquare
//
//  Created by Evan William Ische on 6/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "HDSettingsManager.h"
#import "HDSoundManager.h"

@interface HDSoundManager ()
@property (nonatomic, getter=isSoundSessionActive, assign) BOOL soundSessionActive;
@end

@implementation HDSoundManager

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

+ (HDSoundManager *)sharedManager
{
    static HDSoundManager *_soundController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _soundController = [[HDSoundManager alloc] init];
    });
    return _soundController;
}

+ (BOOL)isOtherAudioPlaying {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    return audioSession.otherAudioPlaying;
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
    if ([[HDSettingsManager sharedManager] sound] && ![HDSoundManager isOtherAudioPlaying]) {
        [player play];
    }
}

#pragma mark - Audio Session 

- (void)startAudio
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *error = nil;
    if (audioSession.otherAudioPlaying) {
        [audioSession setCategory: AVAudioSessionCategoryAmbient error:&error];
    } else {
        [audioSession setCategory: AVAudioSessionCategorySoloAmbient error:&error];
    }
    
    if (!error) {
        [audioSession setActive:YES error:&error];
        self.soundSessionActive = YES;
    }
}

- (void)stopAudio
{
    if (!self.isSoundSessionActive){
        return;
    }
    
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:&error];
    
    if (error) {
        [self stopAudio];
    } else {
        self.soundSessionActive = NO;
    }
}


@end
