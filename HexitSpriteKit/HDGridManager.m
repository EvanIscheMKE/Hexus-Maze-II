//
//  Levels.m
//  Hexagon
//
//  Created by Evan Ische on 10/4/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDGridManager.h"
#import "HDLevel.h"
#import "HDHexagon.h"
#import "HDHexagonNode.h"

typedef void(^CallbackBlock)(NSDictionary *dictionary, NSError *error);
@implementation HDGridManager {
    NSMutableDictionary *_levelCache;
    NSMutableArray *_hexagons;
    HDHexagon *_hexagon[18][9];
    NSNumber *_grid[18][9];
}

- (instancetype)initWithLevelIndex:(NSInteger)index {
    return [self initWithLevel:LEVEL_URL((long)index)];
}

- (instancetype)initWithLevel:(NSString *)level
{
    if (self = [super init]) {
        _levelCache = [NSMutableDictionary dictionary];
        NSDictionary *grid = [self _levelWithFileName:level];
        [self _layoutInitialGrid:grid];
    }
    return self;
}

- (NSArray *)hexagons
{
    if (_hexagons) {
        return _hexagons;
    }
    
    _hexagons = [NSMutableArray array];
    for (NSInteger row = 0; row < NumberOfRows; row++) {
        for (NSInteger column = 0; column < NumberOfColumns; column++) {
            if (_grid[row][column] != nil) {
                HDHexagon *hexagon = [self _createHexagonAtRow:row column:column type:[_grid[row][column] intValue]];
                _hexagon[row][column] = hexagon;
                [_hexagons addObject:hexagon];
            }
        }
    }
    return _hexagons;
}

- (NSInteger)hexagonTypeAtRow:(NSInteger)row column:(NSInteger)column
{
    return [_grid[row][column]integerValue];
}

- (HDHexagon *)hexagonAtRow:(NSInteger)row column:(NSInteger)column
{
    return _hexagon[row][column];
}

#pragma mark - Private

- (void)_layoutInitialGrid:(NSDictionary *)grid
{
    for (int row = 0; row < NumberOfRows; row++) {
        NSArray *rows = [grid[HDHexGridKey] objectAtIndex:row];
        for (int column = 0; column < NumberOfColumns; column++) {
            NSNumber *index = [rows objectAtIndex:column];
            NSInteger tileRow = NumberOfRows - row - 1;
            
            if ([index integerValue] != 0) {
                _grid[tileRow][column] = index;
            }
        }
    }
}

- (NSDictionary *)_levelWithFileName:(NSString *)filename
{
    __block NSDictionary *gridInfo;
    [self _loadJSON:filename callback:^(NSDictionary *dictionary, NSError *error) {
        if (!error) {
            gridInfo = [[NSDictionary alloc] initWithDictionary:dictionary];
        } else {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
    return gridInfo;
}

- (void)_loadJSON:(NSString *)filename callback:(CallbackBlock)callback
{
    if (_levelCache[filename]) {
        if (callback) {
            callback(_levelCache[filename],nil);
            return;
        }
    }
    
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if (data == nil) {
        if (callback) {
            callback(nil,error);
            return;
        }
    }
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (dictionary != nil) {
        _levelCache[filename] = dictionary;
    }
    
    if (callback){
        callback(dictionary,nil);
    }
}

- (HDHexagon *)_createHexagonAtRow:(NSInteger)row column:(NSInteger)column type:(HDHexagonType)type
{
    HDHexagon *hexagon = [[HDHexagon alloc] initWithRow:row column:column type:type];
    _hexagon[row][column] = hexagon;
    
    return hexagon;
}

@end
