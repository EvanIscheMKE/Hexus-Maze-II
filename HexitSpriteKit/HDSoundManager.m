//
//  HDSoundManager.m
//  SixTilesSquare
//
//  Created by Evan William Ische on 6/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import AVFoundation;
@import AudioToolbox;

#import "HDSettingsManager.h"
#import "HDSoundManager.h"

@interface HDSoundManager ()<AVAudioPlayerDelegate>
@property (nonatomic, getter=isSoundSessionActive, assign) BOOL soundSessionActive;
@property (nonatomic, strong) AVAudioPlayer *loopPlayer;
@end

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

#pragma mark - Sounds Manager For UIKit

- (void)setPlayLoop:(BOOL)playLoop
{
    if (!self.loopPlayer) {
        return;
    }
    
    _playLoop = playLoop;
    if (playLoop && ![[self class] isOtherAudioPlaying] && [[HDSettingsManager sharedManager] music]) {
        [self.loopPlayer play];
    } else {
        [self.loopPlayer stop];
    }
}

- (void)preloadLoopWithName:(NSString *)filename;
{
//    NSError *error = nil;
//    NSString *soundPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
//    self.loopPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:soundPath] error:&error];
//    self.loopPlayer.delegate = self;
//    self.loopPlayer.numberOfLoops = -1; /* Will continue to play until we tell it to stop. */
//    [self.loopPlayer prepareToPlay];
}

- (void)preloadSounds:(NSArray *)soundNames
{
    if (!_sounds) {
        
        _sounds = [NSMutableDictionary dictionary];
        
        for (NSString *effect in soundNames) {
            NSError *error = nil;
            NSString *soundPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: effect];
            AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:soundPath] error:&error];
            [player prepareToPlay];
            _sounds[effect] = player;
        }
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

/* AVAudioSession cannot be active while the application is in the background, so we have to stop it when going in to background, and reactivate it when entering foreground. */

+ (BOOL)isOtherAudioPlaying
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    return audioSession.otherAudioPlaying;
}

- (void)startAudio
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *error = nil;
    if (audioSession.otherAudioPlaying) {
        [audioSession setCategory: AVAudioSessionCategoryAmbient error:&error];
    } else {
        [audioSession setCategory: AVAudioSessionCategorySoloAmbient error:&error];
    }
    
    if (error) {
        [self startAudio];
    } else {
        [audioSession setActive:YES error:&error];
        self.soundSessionActive = YES;
        self.playLoop = YES;
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

#pragma mark - <AVAudioDelegate>

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.loopPlayer stop];
    [self.loopPlayer prepareToPlay];
}

@end
