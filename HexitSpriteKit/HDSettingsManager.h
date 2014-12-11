//
//  HDSettingsManager.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/18/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDSettingsManager : NSObject

@property (nonatomic, assign) BOOL sound;
@property (nonatomic, assign) BOOL vibration;
@property (nonatomic, assign) BOOL space;
@property (nonatomic, assign) BOOL guide;
+ (HDSettingsManager *)sharedManager;

@end
