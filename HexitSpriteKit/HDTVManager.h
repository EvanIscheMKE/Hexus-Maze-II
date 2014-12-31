//
//  HDTVManager.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/27/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HDTVHexagonItem;
@interface HDTVManager : NSObject
+ (HDTVManager *)sharedManager;
- (HDTVHexagonItem *)itemAtIndex:(NSUInteger)index;
- (NSUInteger)count;
@end
