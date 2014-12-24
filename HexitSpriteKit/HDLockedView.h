//
//  HDLockedView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/23/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDLockedView : UIView
- (void)stopMonitoringMotionUpdates;
- (void)startMonitoringMotionUpdates;
@end
