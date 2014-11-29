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

- (instancetype)initWithLevelNumber:(NSInteger)levelNumber
{
    return [self initWithLevel:LEVEL_URL(levelNumber)];
}

- (instancetype)initWithLevel:(NSString *)level
{
    if (self = [super init]) {
        
        _levelCache = [NSMutableDictionary dictionary];
        
        NSDictionary *grid = [self _levelWithFileName:level];
        [self layoutInitialGrid:grid];
    }
    return self;
}

- (instancetype)initWithRandomLevel:(NSDictionary *)grid
{
    if (self = [super init]) {
        [self layoutInitialGrid:grid];
    }
    return self;
}

- (void)layoutInitialGrid:(NSDictionary *)grid
{
    for (int row = 0; row < NumberOfRows; row++) {
        
        NSArray *rows = [grid[HDHexGridKey] objectAtIndex:row];
        
        for (int column = 0; column < NumberOfColumns; column++) {
            
            NSNumber *columns = [rows objectAtIndex:column];
            
            NSInteger tileRow = NumberOfRows - row - 1;
            
            if ([columns integerValue] != 0) {
                _grid[tileRow][column] = columns;
            }
        }
    }
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
                    
                    HDHexagon *cookie = [self _createHexagonAtRow:row column:column];
                    _hexagon[row][column] = cookie;
                    [_hexagons addObject:cookie];
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

#pragma mark -
#pragma mark - PRIVATE

- (NSDictionary *)_levelWithFileName:(NSString *)filename
{
    __block NSDictionary *gridInfo;
    [self _loadJSON:filename withCallback:^(NSDictionary *dictionary, NSError *error) {
        if (!error) {
            gridInfo = [[NSDictionary alloc] initWithDictionary:dictionary];
        } else {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
    
    return gridInfo;
}

- (void)_loadJSON:(NSString *)filename withCallback:(CallbackBlock)callback
{
    if (_levelCache[filename]) {
        if (callback) {
            callback(_levelCache[filename],nil);
            return;
        }
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    
    NSError *error = nil;
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

- (HDHexagon *)_createHexagonAtRow:(NSInteger)row column:(NSInteger)column
{
    HDHexagon *hexagon = [[HDHexagon alloc] initWithRow:row column:column];
    
    _hexagon[row][column] = hexagon;
    
    return hexagon;
}

@end
