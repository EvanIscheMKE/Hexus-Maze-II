//
//  HDHelper.m
//  Hexagon
//
//  Created by Evan Ische on 10/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"

@implementation HDHelper

+ (void)blinkView:(UIView *)view duration:(NSTimeInterval)duration repeat:(NSInteger)count
{
    [self blinkView:view duration:duration repeat:count scale:.95f];
}

- (void)blinkView:(UIView *)view duration:(NSTimeInterval)duration repeat:(NSInteger)count scale:(CGFloat)scale
{
    UIViewAnimationOptions options = UIViewAnimationOptionAutoreverse | UIViewAnimationCurveEaseInOut |
                                     UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
                         [UIView setAnimationRepeatCount:count];
                         [view setTransform:CGAffineTransformMakeScale(scale, scale)];
                     } completion:^(BOOL finished){
                         if (finished) {
                             [view setTransform:CGAffineTransformMakeScale(1, 1)];
                             [view.layer removeAllAnimations];
                         }
                     }];
}

+ (CGSize)sizeFromWidth:(CGFloat)width font:(UIFont *)font text:(NSString *)text
{
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName: font };
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    CGRect rect = CGRectIntegral([string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                      context:nil]);
    return rect.size;
}

@end
