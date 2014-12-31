//
//  HDTVManager.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/27/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDTVHexagonItem.h"
#import "HDTVManager.h"

@interface HDTVManager ()
@property (nonatomic, strong) NSArray *hexaObjects;
@end

@implementation HDTVManager {
    NSMutableArray *_hexaObjects;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

+ (HDTVManager *)sharedManager
{
    static HDTVManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HDTVManager alloc] init];
    });
    return manager;
}

- (HDTVHexagonItem *)itemAtIndex:(NSUInteger)index
{
    return [self.hexaObjects objectAtIndex:index];
}

- (NSUInteger)count
{
    return self.hexaObjects.count;
}

- (NSArray *)hexaObjects
{
    if (_hexaObjects) {
        return _hexaObjects;
    }
    
    _hexaObjects = [NSMutableArray array];
    
    [_hexaObjects addObject:[HDTVHexagonItem itemWithTitle:@"Starter Tile"
                                               description:@"The first tile to be selected in every level, if there is more then one, any starter tile can be used as a starting point."
                                                     image:[UIImage imageNamed:@"StarterTile-"]]];
    
    [_hexaObjects addObject:[HDTVHexagonItem itemWithTitle:@"One Touch Tile"
                                               description:@""
                                                     image:[UIImage imageNamed:@"BaseTile-"]]];
    
    [_hexaObjects addObject:[HDTVHexagonItem itemWithTitle:@"Two Touch Tile"
                                               description:@""
                                                     image:[UIImage imageNamed:@"DoubleTouchTile-"]]];
    
    [_hexaObjects addObject:[HDTVHexagonItem itemWithTitle:@"Triple Touch Tile"
                                               description:@""
                                                     image:[UIImage imageNamed:@"TripleTouchTile-"]]];
    
    [_hexaObjects addObject:[HDTVHexagonItem itemWithTitle:@"Unlocked Count Tile"
                                               description:@"Tile "
                                                     image:[UIImage imageNamed:@"UnlockedCountTile-"]]];
    
    [_hexaObjects addObject:[HDTVHexagonItem itemWithTitle:@"Locked Count Tile"
                                               description:@""
                                                     image:[UIImage imageNamed:@"LockedCountTile-"]]];
    
    [_hexaObjects addObject:[HDTVHexagonItem itemWithTitle:@"End Tile"
                                               description:@"The last tile to be touched in every level where one is present. The tile will be locked until all other tiles are selected!"
                                                     image:[UIImage imageNamed:@"EndTile-"]]];

    return _hexaObjects;
}

@end
