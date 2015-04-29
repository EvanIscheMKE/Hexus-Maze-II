//
//  HDHelper.h
//  Hexagon
//
//  Created by Evan Ische on 10/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//


#import <Foundation/Foundation.h>

NSString *descriptionForLevelIdx(NSUInteger levelIdx);

typedef NS_OPTIONS(NSUInteger, HDLevelTip){
    HDLevelTipOne   = 1,
    HDLevelTipTwo   = 29,
    HDLevelTipThree = 57,
    HDLevelTipFour  = 85,
    HDLevelTipFive  = 113,
    HDLevelTipSix   = 141,
    HDLevelTipSeven = 85,
};

typedef NS_OPTIONS(NSUInteger, HDTileDirection){
    HDTileDirectionTopRight    = 0x0,
    HDTileDirectionTopLeft     = 0x1 << 0,
    HDTileDirectionRight       = 0x1 << 1,
    HDTileDirectionLeft        = 0x1 << 2,
    HDTileDirectionBottomRight = 0x1 << 3,
    HDTileDirectionBottomLeft  = 0x1 << 4
};

@class HDHexagon;
@interface HDHelper : NSObject
+ (NSArray *)imageFromLevelIdx:(NSUInteger)levelIdx;
+ (void)entranceAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion;
+ (void)completionAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion;
+ (NSArray *)possibleMovesForHexagon:(HDHexagon *)hexagon inArray:(NSArray *)array;
+ (NSArray *)tileDirectionsToObject:(NSArray *)objects fromTile:(HDHexagon *)fromHexagon;
@end
