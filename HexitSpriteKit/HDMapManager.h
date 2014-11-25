//
//  HDMapManager.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDMapManager : NSObject
@property (nonatomic, readonly) NSArray *levels;

+ (HDMapManager *)sharedManager;
- (void)configureLevelDataForFirstRun;
- (void)completedLevelAtIndex:(NSInteger)index;

@end
