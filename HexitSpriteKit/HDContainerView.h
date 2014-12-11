//
//  HDSpaceView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/24/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDContainerView : UIView
@property (nonatomic, assign) BOOL animate;
@property (nonatomic, assign) BOOL shouldAnimteWhenMovedToSuperView;

- (void)_animateHexAlongPath;
@end
