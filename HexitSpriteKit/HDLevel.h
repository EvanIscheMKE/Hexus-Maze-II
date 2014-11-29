//
//  Level.h
//  Hexagon
//
//  Created by Evan Ische on 10/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDLevel : NSObject <NSCoding>
@property (nonatomic, assign) NSInteger levelIndex;
@property (nonatomic, assign) NSUInteger countUntilCompletion;
@property (nonatomic, getter=isUnlocked,  assign) BOOL unlocked;
@property (nonatomic, getter=isCompleted, assign) BOOL completed;
+ (HDLevel *)levelUnlocked:(BOOL)unlocked index:(NSInteger)index completed:(BOOL)completed;
@end
