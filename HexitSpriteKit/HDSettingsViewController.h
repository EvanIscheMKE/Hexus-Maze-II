//
//  HDSettingsViewController.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 1/2/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HDHexagonView;
@interface HDSettingsControlsView : UIView
@property (nonatomic, strong) HDHexagonView *hexaToggle;
@property (nonatomic, strong) UILabel *descriptionLabel;
@end

@interface HDSettingsViewController : UIViewController
@end
