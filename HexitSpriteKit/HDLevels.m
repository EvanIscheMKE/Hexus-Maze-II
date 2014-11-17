//
//  Levels.m
//  Hexagon
//
//  Created by Evan Ische on 10/4/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevels.h"
#import "HDLevel.h"
#import "HDHexagon.h"
#import "HDHexagonNode.h"

typedef void(^CallBackBlock)(NSDictionary *dictionary, NSError *error);
@implementation HDLevels {
    NSMutableDictionary *_levelCache;
    NSMutableArray *_hexagons;
    HDHexagon *_hexagon[18][9];
    NSNumber *_grid[18][9];
}

- (id)initWithLevel:(NSInteger)level
{
    if (self = [super init]) {
        
        _levelCache = [NSMutableDictionary dictionary];
        
        NSDictionary *grid = [self levelWithFileName:LEVEL_URL(level)];
        
        for (int row = 0; row < NumberOfRows; row++) {
            NSArray *rows = [grid[hdHexGridKey] objectAtIndex:row];
            for (int column = 0; column < NumberOfColumns; column++) {
                
                NSNumber *columns = [rows objectAtIndex:column];
                
                NSInteger tileRow = NumberOfRows - row - 1;
                
                if ([columns integerValue] != 0) {
                    _grid[tileRow][column] = columns;
                }
            }
        }
    }
    return self;
}

- (NSDictionary *)levelWithFileName:(NSString *)filename
{
    __block NSDictionary *gridInfo;
    [self loadJSON:filename withCallBack:^(NSDictionary *dictionary, NSError *error) {
        if (!error) {
            gridInfo = [[NSDictionary alloc] initWithDictionary:dictionary];
        } else {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
    
    return gridInfo;
}

- (void)loadJSON:(NSString *)filename withCallBack:(CallBackBlock)callBack
{
    if (_levelCache[filename]) {
        if (callBack) {
            callBack(_levelCache[filename],nil);
            return;
        }
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if (data == nil) {
        if (callBack) {
            callBack(nil,error);
            return;
        }
    }
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (dictionary != nil){
        _levelCache[filename] = dictionary;
    }
    
    if (callBack){
        callBack(dictionary,nil);
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
                    
                    HDHexagon *cookie = [self makeHexagonAtRow:row column:column];
                    [_hexagons addObject:cookie];
                    
                    _hexagon[row][column] = cookie;
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

- (HDHexagon *)makeHexagonAtRow:(NSInteger)row column:(NSInteger)column
{
    HDHexagon *hexagon = [[HDHexagon alloc] init];
    [hexagon setColumn:column];
    [hexagon setRow:row];
    
    _hexagon[row][column] = hexagon;
    
    return hexagon;
}

@end
