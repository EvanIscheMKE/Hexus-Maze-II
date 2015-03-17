//
//  HDHintsView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/5/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

//extern NSString * const HD
extern NSString * const HDTitleLocalizationKey;
@interface HDHintsView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, readonly) UILabel *titleLabel;

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                  description:(NSString *)description
                       images:(NSArray *)images;

- (instancetype)initWithFrame:(CGRect)frame
                  description:(NSString *)description
                       images:(NSArray *)images;
@end
