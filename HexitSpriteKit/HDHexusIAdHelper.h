//
//  HDHexusIAdHelper.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/6/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDIAdHelper.h"

extern NSString *const IAPUnlockAllLevelsProductIdentifier;
extern NSString *const IAPremoveAdsProductIdentifier;
@interface HDHexusIAdHelper : HDIAdHelper
+ (HDHexusIAdHelper *)sharedHelper;
@end
