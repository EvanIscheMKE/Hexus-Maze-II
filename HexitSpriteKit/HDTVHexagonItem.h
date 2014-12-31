//
//  HDTVHexagonItem.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/27/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDTVHexagonItem : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *hexDescription;
+ (instancetype)itemWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image;
@end
