//
//  HDSettingsManager.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/18/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDRearViewController.h"

@interface HDSettingsManager : NSObject<HDRearViewControllerDelegate>

@property (nonatomic, readonly) BOOL sound;
@property (nonatomic, readonly) BOOL vibration;
@property (nonatomic, readonly) BOOL space;
@property (nonatomic, readonly) BOOL guide;

+ (HDSettingsManager *)sharedManager;

@end
