//
//  HDTVHexagonItem.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/27/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDTVHexagonItem.h"

@implementation HDTVHexagonItem

+ (instancetype)itemWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image
{
    HDTVHexagonItem *item = [[self alloc] init];
    item.title          = title;
    item.hexDescription = description;
    item.image          = image;
    
    return item;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"description: %@ title: %@ image: %@",self.hexDescription, self.title, self.image];
}

@end
