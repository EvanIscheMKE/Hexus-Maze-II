//
//  HDHexagonView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDHelper.h"
#import "HDHexagonView.h"
#import "UIColor+FlatColors.h"

@interface HDHexagonView ()
@property (nonatomic, assign) HDHexagonState state;
@end

@implementation HDHexagonView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (CAShapeLayer *)hexaLayer
{
    return (CAShapeLayer *)self.layer;
}

- (id)initWithFrame:(CGRect)frame type:(HDHexagonType)type strokeColor:(UIColor *)strokeColor
{
    if (self = [super initWithFrame:frame]) {
        
        [[self hexaLayer] setFillColor:[[UIColor flatMidnightBlueColor] CGColor]];
        [[self hexaLayer] setPath:[[HDHelper roundedPolygonPathWithRect:self.bounds lineWidth:0 sides:6 cornerRadius:2.0f] CGPath]];
        [[self hexaLayer] setStrokeColor:[strokeColor CGColor]];
        [[self hexaLayer] setLineWidth:8.0f];
        
         self.container = [[UIView alloc] initWithFrame:self.bounds];
        [self.container setUserInteractionEnabled:NO];
        [self addSubview:self.container];
        
         self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.imageView setUserInteractionEnabled:NO];
        [self.imageView setContentMode:UIViewContentModeCenter];
        [self.container addSubview:self.imageView];
        
         self.indexLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [self.indexLabel setUserInteractionEnabled:NO];
        [self.indexLabel setFont:GILLSANS(CGRectGetWidth(self.bounds)/3)];
        [self.indexLabel setTextAlignment:NSTextAlignmentCenter];
        [self.indexLabel setTextColor:[UIColor whiteColor]];
        [self.container addSubview:self.indexLabel];
        
        if (type == HDHexagonTypePoint) {
            [self.container setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        }
    }
    return self;
}

 - (void)setBackgroundColor:(UIColor *)backgroundColor
{
    NSAssert(NO, @"Use setFill and setStroke %@",NSStringFromSelector(_cmd));
}

- (void)setState:(HDHexagonState)state index:(NSInteger)index
{
    [self setState:state];
    switch (state) {
        case HDHexagonStateLocked:
            
            // Setup for Locked
            [[self hexaLayer] setStrokeColor:[[UIColor flatEmeraldColor] CGColor]];
            [self.imageView setImage:[UIImage imageNamed:@"Locked"]];
            
            break;
        case HDHexagonStateUnlocked:
            
            // Setup for Unlocked
            [[self hexaLayer] setStrokeColor:[[UIColor whiteColor] CGColor]];
            [self.indexLabel setTextColor:[UIColor whiteColor]];
            [self.indexLabel setText:[NSString stringWithFormat:@"%lu", index]];
            
            break;
        case HDHexagonStateCompleted:
            
            // Setup for completed
            [[self hexaLayer] setFillColor:[[UIColor flatPeterRiverColor] CGColor]];
            [self.indexLabel setTextColor:[UIColor flatMidnightBlueColor]];
            [self.indexLabel setText:[NSString stringWithFormat:@"%lu", index]];
            
            // Move text down to make room for completion start
            CGPoint labelPosition = self.indexLabel.center;
            labelPosition.y = CGRectGetHeight(self.bounds) * .7f;
            [self.indexLabel setCenter:labelPosition];
            
            // Move imageviews center point up to make room for image
            CGPoint imagePosition = self.imageView.center;
            imagePosition.y = CGRectGetHeight(self.bounds) * .25f;
            [self.imageView setCenter:imagePosition];
            [self.imageView setImage:[self _star]];
            [self.imageView setTransform:CGAffineTransformMakeRotation(M_PI)];
            
            break;
        default:
            NSAssert(NO, @"%@",NSStringFromSelector(_cmd));
            break;
    }
}

- (UIImage *)_star
{
    // Create the star little less that half the size of bounds
    CGSize _startSize = CGSizeMake(CGRectGetHeight(self.bounds)/2.25f, CGRectGetHeight(self.bounds)/2.25f);
    UIGraphicsBeginImageContextWithOptions(_startSize, NO, [[UIScreen mainScreen] scale]);
    
    [[UIColor whiteColor] setFill];
    
    CGPathRef starRef = [HDHelper starPathForBounds:CGRectMake(0.0f, 0.0f, _startSize.width, _startSize.height)];
    UIBezierPath *starPath = [UIBezierPath bezierPathWithCGPath:starRef];

    [starPath fill];
    
    UIImage *star = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return star;
}

@end
