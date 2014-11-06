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

- (void)initalizeLevelsForFirstRun;
- (void)completedLevelAtIndex:(NSInteger)index;
+ (HDMapManager *)sharedManager;
@end
