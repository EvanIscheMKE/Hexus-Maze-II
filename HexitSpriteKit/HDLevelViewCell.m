//
//  HDLevelViewCell.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/21/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDHelper.h"
#import "HDLevelViewCell.h"
#import "UIColor+FlatColors.h"

NSString * const levelCellReuseIdentifer = @"levelReuseIdentifier";

static const CGFloat kPadding = 15.0f;
@interface HDLevelViewCell ()
@property (nonatomic, strong) CAShapeLayer *rotatingHexagon;
@property (nonatomic, strong) CAShapeLayer *outlineLayer;
@end

@implementation HDLevelViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
         self.outlineLayer = [CAShapeLayer layer];
        [self.outlineLayer setPath:[HDHelper hexagonPathForBounds:self.bounds]];
        [self.outlineLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
        [self.outlineLayer setFillColor:[[UIColor clearColor] CGColor]];
        [self.outlineLayer setLineWidth:2.0f];
        [self.contentView.layer addSublayer:_outlineLayer];
        
        self.hexagonLayer = [CAShapeLayer layer];
        [self.hexagonLayer setPath:[HDHelper hexagonPathForBounds:CGRectInset(self.contentView.bounds, 2.0f, 2.0f)]];
        [self.hexagonLayer setStrokeColor:[[UIColor flatMidnightBlueColor] CGColor]];
        [self.hexagonLayer setFillColor:[[UIColor flatPeterRiverColor] CGColor]];
        [self.hexagonLayer setLineWidth:4.0f];
        [self.contentView.layer addSublayer:self.hexagonLayer];
        
        CGRect indexRect = CGRectMake(0.0f, 0.0f, CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
        self.indexLabel = [[UILabel alloc] initWithFrame:indexRect];
        [self.indexLabel setFont:GILLSANS_LIGHT(CGRectGetMidY(self.contentView.bounds) / 1.5)];
        [self.indexLabel setNumberOfLines:1];
        [self.indexLabel setTextAlignment:NSTextAlignmentCenter];
        [self.indexLabel setTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.indexLabel];
        
        self.middleStar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"STAR_NOT_COMPLETED.png"]];
        [self.contentView addSubview:self.middleStar];
        
    }
    return self;
}

- (void)prepareForReuse
{
    [self setAnimate:NO];
    [super prepareForReuse];
    
    if (self.rotatingHexagon) {
        [self.rotatingHexagon removeAllAnimations];
        [self.rotatingHexagon removeFromSuperlayer];
        [self setRotatingHexagon:nil];
    }
}

- (void)setAnimate:(BOOL)animate
{
    _animate = animate;
    
    if (animate) {
        
        const CGFloat hexaInset = -14.0f;
        CGRect hexaBounds = CGRectInset(self.contentView.bounds, hexaInset, hexaInset);
        self.rotatingHexagon = [CAShapeLayer layer];
        [self.rotatingHexagon setFrame:hexaBounds];
        [self.rotatingHexagon setPath:[HDHelper hexagonPathForBounds:hexaBounds]];
        [self.rotatingHexagon setStrokeColor:[[UIColor whiteColor] CGColor]];
        [self.rotatingHexagon setFillColor:[[UIColor clearColor] CGColor]];
        [self.rotatingHexagon setLineWidth:1.0f];
        [self.contentView.layer addSublayer:_rotatingHexagon];
        
        CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        [rotate setToValue:@(-(M_PI * 2))];
        [rotate setDuration:3.f];
        [rotate setRepeatCount:HUGE_VAL];
        [_rotatingHexagon addAnimation:rotate forKey:@"continiousRotation"];
        
    }
}

- (void)setCompleted:(BOOL)completed
{
    if (_completed == completed) {
        return;
    }
    
    _completed = completed;
    
    if (_completed) {
        [self.middleStar setImage:[UIImage imageNamed:@"STAR_COMPLETED.png"]];
    } else {
        [self.middleStar setImage:[UIImage imageNamed:@"STAR_NOT_COMPLETED.png"]];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.outlineLayer setFrame:self.contentView.bounds];
    [self.hexagonLayer setFrame:CGRectInset(self.contentView.bounds, 2.0f, 2.0f)];
    [self.middleStar   setCenter:CGPointMake(CGRectGetMidX(self.contentView.bounds), kPadding * 1.5f)];
    [self.indexLabel   setCenter:CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds) + kPadding)];
}

@end
