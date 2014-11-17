//
//  Hexagon.h
//  Hexagon
//
//  Created by Evan Ische on 10/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface HDHexagonView : UIButton
@property (nonatomic, strong) UILabel *textLabel;
- (UIBezierPath *)hexagonPathForBounds:(CGRect)bounds;
@end
