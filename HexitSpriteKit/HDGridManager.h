//
//  Levels.h
//  Hexagon
//
//  Created by Evan Ische on 10/4/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HDHexagon;
@interface HDGridManager : NSObject

@property (nonatomic, readonly) NSArray *hexagons;

- (HDHexagon *)hexagonAtRow:(NSInteger)row column:(NSInteger)column;
- (NSInteger)hexagonTypeAtRow:(NSInteger)row column:(NSInteger)column;

- (instancetype)initWithLevelNumber:(NSInteger)levelNumber;
- (instancetype)initWithRandomLevel:(NSDictionary *)grid;
- (instancetype)initWithLevel:(NSString *)level;

@end

