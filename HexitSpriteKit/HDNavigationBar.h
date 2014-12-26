//
//  HDNavigationBar.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/25/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDNavigationBar : UIView
@property (nonatomic, strong) UIImage *toggleImage;
@property (nonatomic, strong) UIImage *activityImage;
@property (nonatomic, readonly) UIButton *navigationButton;
@property (nonatomic, readonly) UIButton *activityButton;
+ (instancetype)viewWithToggleImage:(UIImage *)toggleImage activityImage:(UIImage *)activityImage;
- (instancetype)initWithToggleImage:(UIImage *)toggleImage activityImage:(UIImage *)activityImage;
@end
