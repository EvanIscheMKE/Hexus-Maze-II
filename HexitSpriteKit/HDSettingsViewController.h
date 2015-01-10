//
//  HDSettingsViewController.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 1/2/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HDHexagonButton;
@interface HDSettingsControlsView : UIView
@property (nonatomic, strong) HDHexagonButton *hexaToggle;
@property (nonatomic, strong) UILabel *descriptionLabel;
@end

@interface HDSettingsViewController : UIViewController
@end
