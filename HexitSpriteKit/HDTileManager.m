//
//  HDTileManager.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/11/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDTileManager.h"

@interface HDTileManager ()
@property (nonatomic, strong) NSMutableArray *bank;
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
        self.bank = [NSMutableArray array];
    }
    return self;
}

- (void)clear {
    [self.bank removeAllObjects];
}

- (HDHexagon *)lastHexagonObject {
    return self.bank.lastObject;
}

- (void)addHexagon:(HDHexagon *)hexagon {
    [self.bank addObject:hexagon];
}

- (BOOL)isEmpty {
    return self.bank.count == 0;
}


@end
