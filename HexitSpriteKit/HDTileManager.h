//
//  HDTileManager.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/11/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//


#import <Foundation/Foundation.h>

@class HDHexagon;
@interface HDTileManager : NSObject
+ (HDTileManager *)sharedManager;
- (HDHexagon *)lastHexagonObject;
- (HDHexagon *)teleportTile;
- (NSArray *)teleportTiles;
- (void)emptyTeleportBank;
- (void)addTeleportTile:(HDHexagon *)hexagon;
- (void)addHexagon:(HDHexagon *)hexagon;
- (BOOL)isEmpty;
- (void)clear;
@end
