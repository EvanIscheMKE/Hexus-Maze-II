//
//  HDHelper.h
//  Hexagon
//
//  Created by Evan Ische on 10/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDHelper : NSObject
+ (CGPathRef)hexagonPathForBounds:(CGRect)bounds;
+ (CGSize)sizeFromWidth:(CGFloat)width font:(UIFont *)font text:(NSString *)text;
+ (void)blinkView:(UIView *)view duration:(NSTimeInterval)duration repeat:(NSInteger)count;
+ (void)blinkView:(UIView *)view duration:(NSTimeInterval)duration repeat:(NSInteger)count scale:(CGFloat)scale;
@end
