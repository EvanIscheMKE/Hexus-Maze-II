//
//  HDHexusIAdHelper.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/6/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHexusIAdHelper.h"

NSString *const IAPremoveAdsProductIdentifier = @"com.EvanIsche.Hexus.RemoveAds";
NSString *const IAPUnlockAllLevelsProductIdentifier = @"";
@implementation HDHexusIAdHelper

+ (HDHexusIAdHelper *)sharedHelper {
    static HDHexusIAdHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      IAPremoveAdsProductIdentifier, nil];
        helper = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return helper;
}

@end
