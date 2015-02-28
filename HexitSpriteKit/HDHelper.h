//
//  HDHelper.h
//  Hexagon
//
//  Created by Evan Ische on 10/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//


#import <Foundation/Foundation.h>

NSString *descriptionForLevelIdx(NSUInteger levelIdx);

typedef NS_ENUM(NSUInteger, HDLevelTip){
    HDLevelTipOne   = 1,
    HDLevelTipTwo   = 29,
    HDLevelTipThree = 57,
    HDLevelTipFour  = 85,
    HDLevelTipFive  = 113,
    HDLevelTipSix   = 141,
    HDLevelTipSeven = 85,
};

@class HDHexagon;
@interface HDHelper : NSObject
+ (UIBezierPath *)restartArrowAroundPoint:(CGPoint)center;
+ (BOOL)isIpad;
+ (NSArray *)imageFromLevelIdx:(NSUInteger)levelIdx;
+ (void)entranceAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion;
+ (void)completionAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion;
+ (NSArray *)possibleMovesForHexagon:(HDHexagon *)hexagon inArray:(NSArray *)array;
@end
