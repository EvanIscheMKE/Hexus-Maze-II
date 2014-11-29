//
//  HDSettingsManager.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/18/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDSettingsManager : NSObject

@property (nonatomic, readonly) BOOL sound;
@property (nonatomic, readonly) BOOL vibration;
@property (nonatomic, readonly) BOOL space;
@property (nonatomic, readonly) BOOL guide;

- (void)toggleSound;
- (void)toggleVibration;
- (void)toggleSpace;
- (void)toggleGuide;

+ (HDSettingsManager *)sharedManager;

@end
