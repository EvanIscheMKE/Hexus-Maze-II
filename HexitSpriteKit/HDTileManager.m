//
//  HDTileManager.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/11/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDTileManager.h"
#import "NSMutableArray+UniqueAdditions.h"

@interface HDTileManager ()
@property (nonatomic, strong) NSMutableArray *selectedTileBank;
@end

@implementation HDTileManager

+ (HDTileManager *)sharedManager
{
    static HDTileManager *tileManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tileManager = [HDTileManager new];
    });
    return tileManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.selectedTileBank = [NSMutableArray array];
    }
    return self;
}

- (void)clear {
    [self.selectedTileBank removeAllObjects];
}

- (HDHexagon *)lastHexagonObject {
    return self.selectedTileBank.lastObject;
}

- (void)addHexagon:(HDHexagon *)hexagon {
    [self.selectedTileBank addObject:hexagon];
}

- (BOOL)isEmpty {
    return self.selectedTileBank.count == 0;
}


@end
