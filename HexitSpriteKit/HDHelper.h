//
//  HDHelper.h
//  Hexagon
//
//  Created by Evan Ische on 10/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//


#import "HDHelper.h"
#import "HDHexaObject.h"
#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, HDLevelTip)
{
    HDLevelTipOne   = 1,
    HDLevelTipTwo   = 29,
    HDLevelTipThree = 57,
    HDLevelTipFour  = 85,
    HDLevelTipFive  = 113,
    HDLevelTipSix   = 141,
};

typedef NS_OPTIONS(NSUInteger, HDTileDirection)
{
    HDTileDirectionTopRight    = 0x0,
    HDTileDirectionTopLeft     = 0x1 << 0,
    HDTileDirectionRight       = 0x1 << 1,
    HDTileDirectionLeft        = 0x1 << 2,
    HDTileDirectionBottomRight = 0x1 << 3,
    HDTileDirectionBottomLeft  = 0x1 << 4
};

CGFloat angleForDirection(HDTileDirection direction);
NSString *descriptionForLevelIdx(NSUInteger levelIdx);

@class HDHexaObject;
@interface HDHelper : NSObject
+ (UIColor *)colorFromType:(HDHexagonType)type touchCount:(NSUInteger)touchCount;
+ (NSString *)imageURLFromType:(HDHexagonType)type;
+ (UIImage *)imageFromLevelIdx:(NSUInteger)levelIdx;
+ (void)entranceAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion;
+ (void)completionAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion;
+ (NSArray *)possibleMovesForHexagon:(HDHexaObject *)hexagon inArray:(NSArray *)array;
+ (HDTileDirection)tileDirectionsToTile:(HDHexaObject *)toHexagon fromTile:(HDHexaObject *)fromHexagon;
+ (HDTileDirection)oppositeForDirection:(HDTileDirection)direction;
+ (NSArray *)possibleMovesFromMine:(HDHexaObject *)obj containedIn:(NSArray *)array;
@end
