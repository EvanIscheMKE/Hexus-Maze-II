//
//  HDHexusIAdHelper.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/6/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHexusIAdHelper.h"

@implementation HDHexusIAdHelper

+ (HDHexusIAdHelper *)sharedInstance
{
    static HDHexusIAdHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.EvanIsche.hexus.removeAds", nil];
        helper = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return helper;
}

@end
