//
//  HDTileDescriptorView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 1/14/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDTileDescriptorView : UIView
- (instancetype)initWithDescription:(NSString *)description
                              image:(UIImage *)image NS_DESIGNATED_INITIALIZER;
@property (nonatomic, readonly) UILabel *descriptorLabel;
@end
