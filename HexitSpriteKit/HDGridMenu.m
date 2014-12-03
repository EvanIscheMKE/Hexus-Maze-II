//
//  HDGridMenu.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/1/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDGridMenu.h"
#import "UIColor+FlatColors.h"

static const CGFloat containerSize = 280.0f;

@interface HDGridMenu ()
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *alertView;
@end

@implementation HDGridMenu {
    NSUInteger _levelIndex;
}

- (instancetype)initWithFrame:(CGRect)frame level:(NSInteger)level
{
    if (self = [super initWithFrame:frame]) {
        
        _levelIndex = level;
        [self _setupSubviews];
    }
    return self;
}

- (void)_setupSubviews;
{
    CGRect backgroundViewFrame = self.bounds;
     self.backgroundView = [[UIView alloc] initWithFrame:backgroundViewFrame];
    [self.backgroundView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.5f]];
    [self.backgroundView setAlpha:0.0f];
    [self addSubview:self.backgroundView];
    
    CGRect alertViewFrame = CGRectMake(0.0f, 0.0f, containerSize, containerSize);
     self.alertView = [[UIView alloc] initWithFrame:alertViewFrame];
    [self.alertView setCenter:CGPointMake(CGRectGetMidX(self.bounds), -(containerSize /2))];
    [self.alertView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.alertView];
    
    CAShapeLayer *outline = [CAShapeLayer layer];
    [outline setFrame:CGRectInset(self.alertView.bounds, -16.0f, -16.0f)];
    [outline setPath:[HDHelper hexagonPathForBounds:CGRectInset(self.alertView.bounds, -16.0f, -16.0f)]];
    [outline setStrokeColor:[[UIColor whiteColor] CGColor]];
    [outline setFillColor:[[UIColor blackColor] CGColor]];
    [outline setLineWidth:3.0f];
    [self.alertView.layer addSublayer:outline];
    
    CAShapeLayer *mask = [CAShapeLayer layer];
    [mask setFrame:self.alertView.bounds];
    [mask setPath:[HDHelper hexagonPathForBounds:self.alertView.bounds]];
    [mask setFillColor:[[UIColor flatPeterRiverColor] CGColor]];
    [self.alertView.layer addSublayer:mask];
    
    CGRect beginGameFrame = CGRectMake(0.0f, 0.0f, 160.0f, 40.0f);
    self.beginGame = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beginGame addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.beginGame setFrame:beginGameFrame];
    [self.beginGame setBackgroundColor:[UIColor flatMidnightBlueColor]];
    [self.beginGame setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.beginGame setTitle:@"Begin Game" forState:UIControlStateNormal];
    [[self.beginGame titleLabel] setTextAlignment:NSTextAlignmentCenter];
    [[self.beginGame titleLabel] setFont:GILLSANS_LIGHT(16.0f)];
    [self.beginGame.layer setCornerRadius:CGRectGetMidY(self.beginGame.bounds)];
    [self.beginGame setCenter:CGPointMake(CGRectGetMidX(self.alertView.bounds), CGRectGetHeight(self.alertView.bounds) * .75)];
    [self.alertView addSubview:self.beginGame];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:[NSString stringWithFormat:@"Level %lu",_levelIndex]];
    [titleLabel setTextColor:[UIColor flatSilverColor]];
    [titleLabel setFont:GILLSANS_LIGHT(24)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel sizeToFit];
    [titleLabel setCenter:CGPointMake(CGRectGetMidX(self.alertView.bounds), containerSize/6)];
    [self.alertView addSubview:titleLabel];
    
    [[self keyWindow] setTintAdjustmentMode: UIViewTintAdjustmentModeDimmed];
    [[self keyWindow] tintColorDidChange];
}

- (UIWindow *)keyWindow
{
    return ADelegate.window;
}

- (void)show
{
    [UIView animateWithDuration:.3f animations:^{
        [self.backgroundView setAlpha:.5f];
        [self.alertView setCenter:self.center];
    }];
    [[self keyWindow] addSubview:self];
}

- (void)dismiss
{
    [UIView animateWithDuration:.3f animations:^{
        
        [self.backgroundView setAlpha:0.0f];
        [self.alertView setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) + containerSize/2)];
        
        [[self keyWindow] setTintAdjustmentMode: UIViewTintAdjustmentModeNormal];
        [[self keyWindow] tintColorDidChange];
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            if (self.completion) {
                self.completion();
            }
        }
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    BOOL insideMenu = CGRectContainsPoint(self.alertView.frame, location);
    
    if (!insideMenu) {
        [self dismiss];
    }
}

@end
