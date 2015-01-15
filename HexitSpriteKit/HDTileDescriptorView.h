//
//  HDTileDescriptorView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 1/14/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HDTileDescriptorDelegate;
@interface HDTileDescriptorView : UIView
- (instancetype)initWithTitle:(NSString *)title
                  description:(NSString *)description
                        image:(UIImage *)image NS_DESIGNATED_INITIALIZER;
@property (nonatomic, weak) id<HDTileDescriptorDelegate> delegate;
- (void)show;
- (void)dismiss;
@end

@protocol HDTileDescriptorDelegate <NSObject>
- (void)descriptorViewClickedDismissalButton:(HDTileDescriptorView *)view;
@end
