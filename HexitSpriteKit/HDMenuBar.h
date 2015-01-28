//
//  HDNavigationBar.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/25/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDMenuBar : UIView
@property (nonatomic, strong) UIImage *activityImage;
@property (nonatomic, readonly) UIButton *navigationButton;
@property (nonatomic, readonly) UIButton *activityButton;
+ (instancetype)menuBarWithActivityImage:(UIImage *)activityImage;
- (instancetype)initWithActivityImage:(UIImage *)activityImage NS_DESIGNATED_INITIALIZER;
@end
