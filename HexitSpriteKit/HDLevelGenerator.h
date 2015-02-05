//
//  HDLevelGenerator.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/26/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef  enum {
    HDLevelGeneratorDifficultyEasy = 0,
    HDLevelGeneratorDifficultyMedium,    
    HDLevelGeneratorDifficultyHard
} HDLevelGeneratorDifficulty;

typedef void(^CallbackBlock)(NSDictionary *dictionary, NSError *error);
@interface HDLevelGenerator : NSObject
@property (nonatomic, assign) NSUInteger numberOfTiles;
@property (nonatomic, assign) HDLevelGeneratorDifficulty difficulty;
- (void)generateWithCompletionHandler:(CallbackBlock)handler;
@end