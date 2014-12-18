//
//  HDMapManager.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HDLevel;
@interface HDMapManager : NSObject
+ (HDMapManager *)sharedManager;
- (void)configureDataBaseForFirstRun;
- (void)completedLevelAtIndex:(NSInteger)index;

- (HDLevel *)levelAtIndex:(NSInteger)index;
- (NSInteger)indexOfCurrentLevel;

@end
