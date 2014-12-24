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

@implementation HDHexagonView{
    HDHexagonType _type;
    UIColor *_hexaStroke;
}

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
        _type = type;
        _hexaStroke = strokeColor;
        [self _setup];
    }
    return self;
}

- (void)_setup
{
    [[self hexaLayer] setFillColor:[[UIColor flatMidnightBlueColor] CGColor]];
    [[self hexaLayer] setPath:[[HDHelper roundedPolygonPathWithRect:self.bounds lineWidth:0 sides:6 cornerRadius:2.0f] CGPath]];
    [[self hexaLayer] setStrokeColor:[_hexaStroke CGColor]];
    [[self hexaLayer] setLineWidth:8.0f];
    
    self.container = [[UIView alloc] initWithFrame:self.bounds];
    self.container.userInteractionEnabled = NO;
    [self addSubview:self.container];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.userInteractionEnabled = NO;
    self.imageView.contentMode = UIViewContentModeCenter;
    [self.container addSubview:self.imageView];
    
    self.indexLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.indexLabel.userInteractionEnabled = NO;
    self.indexLabel.font = GILLSANS(CGRectGetWidth(self.bounds)/3);
    self.indexLabel.textAlignment = NSTextAlignmentCenter;
    self.indexLabel.textColor = [UIColor whiteColor];
    [self.container addSubview:self.indexLabel];
    
    if (_type == HDHexagonTypePoint) {
        self.container.transform = CGAffineTransformMakeRotation(-M_PI_2); 
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    [self.container setTag:tag];
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
            self.hexaLayer.strokeColor = [[UIColor flatEmeraldColor] CGColor];
            self.imageView.image = [UIImage imageNamed:@"Locked"];
            break;
        case HDHexagonStateUnlocked:
            self.hexaLayer.strokeColor = [[UIColor whiteColor] CGColor];
            self.indexLabel.textColor  = [UIColor whiteColor];
            self.indexLabel.text       = [NSString stringWithFormat:@"%lu", index];
            break;
        case HDHexagonStateCompleted:
            self.hexaLayer.fillColor  = [[UIColor flatPeterRiverColor] CGColor];
            self.indexLabel.textColor = [UIColor flatMidnightBlueColor];
            self.indexLabel.text      = [NSString stringWithFormat:@"%lu", index];
            
            // Move text down to make room for completion start
            CGPoint labelPosition = self.indexLabel.center;
            labelPosition.y = CGRectGetHeight(self.bounds) * .7f;
            self.indexLabel.center = labelPosition;
            
            // Move imageviews center point up to make room for image
            CGPoint imagePosition = self.imageView.center;
            imagePosition.y = CGRectGetHeight(self.bounds) * .25f;
            
            self.imageView.center    = imagePosition;
            self.imageView.image     = [self _star];
            self.imageView.transform = CGAffineTransformMakeRotation(M_PI);
            
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
