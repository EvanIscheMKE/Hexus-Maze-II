//
//  HDLabel.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 5/19/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDLabel.h"

@implementation HDLabel

- (void)setText:(NSString *)text
{
    [super setText:[text uppercaseString]];
}

@end
