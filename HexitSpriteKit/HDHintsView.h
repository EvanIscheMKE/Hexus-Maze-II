//
//  HDHintsView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/5/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDHintsView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, readonly) UILabel *titleLabel;
- (instancetype)initWithDescription:(NSString *)description;
@end
