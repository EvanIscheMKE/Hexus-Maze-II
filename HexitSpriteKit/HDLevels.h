//
//  Levels.h
//  Hexagon
//
//  Created by Evan Ische on 10/4/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HDHexagon;
@interface HDLevels : NSObject
@property (nonatomic, readonly) NSArray *hexagons;
- (HDHexagon *)hexagonAtRow:(NSInteger)row column:(NSInteger)column;
- (id)initWithLevel:(NSInteger)level;
@end

