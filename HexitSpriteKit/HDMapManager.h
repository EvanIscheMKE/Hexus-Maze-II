//
//  HDMapManager.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSUInteger LEVELS_PER_PAGE = 15;

@class HDLevel;
@interface HDMapManager : NSObject

@property (nonatomic, assign)   NSUInteger currentLevel;
@property (nonatomic, readonly) NSUInteger totalNumberOfLevels;
@property (nonatomic, readonly) NSUInteger numberOfSections;
@property (nonatomic, readonly) NSUInteger numberOfLevelsInSection;

+ (HDMapManager *)sharedManager;
- (void)configureLevelDataForFirstRun;
- (void)completedLevelAtIndex:(NSInteger)index;
- (HDLevel *)levelAtIndex:(NSInteger)index;

@end
