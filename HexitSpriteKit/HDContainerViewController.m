//
//  ViewController.m
//  SideMenuExample
//
//  Created by Evan Ische on 10/15/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDContainerViewController.h"
#import "HDGameViewController.h"
#import "HDLevelViewController.h"
#import "UIColor+FlatColors.h"
#import "HDHexagon.h"
#import "HDHelper.h"
#import "HDConstants.h"

static const NSUInteger totalAmountOfLives = 5;
static const CGFloat kPadding   = 12.0f;
static const CGFloat kHeartSize = 30.0f;

@interface HDNavigationBar ()

@property (nonatomic, assign) NSTimeInterval remainingTime;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation HDNavigationBar{
    NSMutableArray *_amountOfLives;
}

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame numberOfLives:totalAmountOfLives time:1800];
}

- (instancetype)initWithFrame:(CGRect)frame numberOfLives:(NSInteger)count time:(NSTimeInterval)seconds
{
    if (self = [super initWithFrame:frame]) {
        
        _remainingTime = seconds;
        
        _amountOfLives = [NSMutableArray arrayWithCapacity:totalAmountOfLives];
        
        CAShapeLayer *layer = (CAShapeLayer *)self.layer;
        [layer setPath:[[self _navigationPathForBounds:self.bounds] CGPath]];
        [layer setFillColor:[[UIColor flatCloudsColor] CGColor]];
        [layer setStrokeColor:[[UIColor flatCloudsColor] CGColor]];
        [layer setLineWidth:6.0f];
        
        CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds));
        
        CAShapeLayer *left = [CAShapeLayer layer];
        [left setBounds:bounds];
        [left setPath:[HDHelper hexagonPathForBounds:bounds]];
        [left setPosition:CGPointMake(CGRectGetMidY(self.bounds), CGRectGetMidY(self.bounds))];
        [left setFillColor:[[UIColor flatSilverColor] CGColor]];
        [left setStrokeColor:[[UIColor flatSilverColor] CGColor]];
        [left setLineWidth:6];
        [self.layer addSublayer:left];
        
         self.toggleSideMenu = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.toggleSideMenu setImage:[UIImage imageNamed:@"BounceButton"] forState:UIControlStateNormal];
        [self.toggleSideMenu setBackgroundColor:[UIColor clearColor]];
        [self.toggleSideMenu setBounds:bounds];
        [self.toggleSideMenu setCenter:left.position];
        [self addSubview:self.toggleSideMenu];
        
        CAShapeLayer *right = [CAShapeLayer layer];
        [right setBounds:bounds];
        [right setPath:[HDHelper hexagonPathForBounds:bounds]];
        [right setPosition:CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetMidY(self.bounds), CGRectGetMidY(self.bounds))];
        [right setFillColor:[[UIColor flatSilverColor] CGColor]];
        [right setStrokeColor:[[UIColor flatSilverColor] CGColor]];
        [right setLineWidth:6];
        [self.layer addSublayer:right];
        
         self.timeLabel = [[UILabel alloc] init];
        [self.timeLabel setBounds:bounds];
        [self.timeLabel setCenter:right.position];
        [self.timeLabel setFont:GILLSANS(16.0f)];
        [self.timeLabel setTextColor:[UIColor whiteColor]];
        [self.timeLabel setText:[self _hoursAndMinutesFromSeconds:seconds]];
        [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.timeLabel];
        
        const CGFloat kCenterStartX = CGRectGetMidX(self.bounds) -  ((kHeartSize + kPadding) * 2);
        
        for (int i = 0; i < 5; i++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBounds:CGRectMake(0.0f, 0.0f, kHeartSize, kHeartSize)];
            [button setImage:[UIImage imageNamed:@"BlueHeartFill.png"]   forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"BlueHeartStroke.png"] forState:UIControlStateSelected];
            [button setCenter:CGPointMake(kCenterStartX + (i * (kHeartSize + kPadding)), CGRectGetMidY(self.bounds))];
            [button setSelected:( i + 1 > count )];
            [_amountOfLives addObject:button];
            [self addSubview:button];
            
        }
        
        if (_remainingTime > 0) {
            [self _setupTimer];
        }
    }
    return self;
}

- (NSArray *)lives
{
    if (_amountOfLives) {
        return _amountOfLives;
    }
    return [NSArray array];
}

#pragma mark -
#pragma mark - Private

- (void)_setupTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(_updateTime:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)_updateTime:(NSTimer *)timer
{
    _remainingTime -= 1;
    
    [self.timeLabel setText:[self _hoursAndMinutesFromSeconds:_remainingTime]];
    
    if (_remainingTime == 0) {
        [self _updateRemainingLives];
    }
}

- (void)_updateRemainingLives
{
    NSUInteger lives = [[NSUserDefaults standardUserDefaults] integerForKey:HDRemainingLivesKey];
    
    NSUInteger count = 0;
    for (UIButton *life in self.lives) {
        if (life.selected) {
            [life setSelected:NO];
            [self.timer invalidate];
            [self setTimer:nil];
            [[NSUserDefaults standardUserDefaults] setInteger:lives + 1 forKey:HDRemainingLivesKey];
            
            if (count != 4) {
                _remainingTime = 1200; // 20 minutes * 60 seconds
                [self _setupTimer];
            }
            
            return;
        }
        count++;
    }
}

- (void)updateLives:(NSInteger)lives time:(NSTimeInterval)seconds
{
    if (self.timer) {
        [self setTimer:nil];
        [self.timer invalidate];
    }
}

- (NSString *)_hoursAndMinutesFromSeconds:(NSInteger)totalSeconds
{
    if (totalSeconds > 0) {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)(totalSeconds / 60) % 60, (long)totalSeconds % 60];
    }
    return @"";
}

- (UIBezierPath *)_navigationPathForBounds:(CGRect)bounds
{
    
    const CGFloat kPadding = CGRectGetHeight(bounds) / 8 / 2;
    UIBezierPath *_path = [UIBezierPath bezierPath];
    [_path moveToPoint:CGPointMake(CGRectGetMidX(bounds), 0.0f)];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) - kPadding, 0.0f)];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) - kPadding, CGRectGetHeight(bounds) * .25f)];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) - kPadding, CGRectGetHeight(bounds) * .75f)];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) - CGRectGetHeight(bounds) / 2, CGRectGetHeight(bounds))];
    [_path addLineToPoint:CGPointMake(CGRectGetMidX(bounds), CGRectGetHeight(bounds))];
    [_path addLineToPoint:CGPointMake(CGRectGetHeight(bounds) / 2, CGRectGetHeight(bounds))];
    [_path addLineToPoint:CGPointMake(kPadding, CGRectGetHeight(bounds) * .75f)];
    [_path addLineToPoint:CGPointMake(kPadding, CGRectGetHeight(bounds) * .25f)];
    [_path addLineToPoint:CGPointMake(kPadding, 0.0f)];
    [_path closePath];
    
    return _path;
}

@end

@implementation UIViewController (HDMenuViewController)

- (HDContainerViewController *)containerViewController
{
    UIViewController *parent = self;
    Class revealClass = [HDContainerViewController class];
    while ( nil != (parent = [parent parentViewController])
           && ![parent isKindOfClass:revealClass] ) {
    
    }
    return (id)parent;
}

@end

static CGFloat const kAnimationOffsetX = 180.0f;

@interface HDContainerViewController ()

@property (nonatomic, strong) HDNavigationBar *navigationBar;

@property (nonatomic, strong) UIViewController *gameViewController;
@property (nonatomic, strong) UIViewController *rearViewController;

@property (nonatomic, setter=setExpanded:, assign) BOOL isExpanded;

@end

@implementation HDContainerViewController{
    BOOL _isExpanded;
}

@synthesize isExpanded = _isExpanded;
- (instancetype)initWithGameViewController:(UIViewController *)gameController rearViewController:(UIViewController *)rearController
{
    NSParameterAssert(gameController);
    NSParameterAssert(rearController);
    if (self = [super init]) {
        [self setGameViewController:gameController];
        [self setRearViewController:rearController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.rearViewController.view];
    [self.view addSubview:self.gameViewController.view];
    
    [self addChildViewController:self.gameViewController];
    [self addChildViewController:self.rearViewController];
    
    [self.gameViewController didMoveToParentViewController:self];
    [self.rearViewController didMoveToParentViewController:self];
    
    [self _layoutNavigationBarWithLives:[[NSUserDefaults standardUserDefaults] integerForKey:HDRemainingLivesKey]
                                   time:[[NSUserDefaults standardUserDefaults] integerForKey:HDRemainingTime]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setFrontViewController:(UIViewController *)controller animated:(BOOL)animated
{
    UIViewController *oldController = self.gameViewController;
    
    [self setGameViewController:controller];
    [self addChildViewController:self.gameViewController];
    
    void (^completionBlock)(BOOL) = ^(BOOL finished){
        
        [oldController willMoveToParentViewController:nil];
        [oldController removeFromParentViewController];
        [self.gameViewController didMoveToParentViewController:self];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(container:transitionedFromController:toController:)]) {
            [self.delegate container:self transitionedFromController:oldController toController:self.gameViewController];
        }
    };
    
    dispatch_block_t animation = ^{
        if (!animated) {
            [oldController.view removeFromSuperview];
            [self.view addSubview:self.gameViewController.view];
        }
        
        [self.navigationBar removeFromSuperview];
        [self.gameViewController.view addSubview:self.navigationBar];
        
        if (self.isExpanded) {
            self.isExpanded = NO;
            
            CGRect rect = self.gameViewController.view.frame;
            rect.origin.x = 0;
            [self.gameViewController.view setFrame:rect];
        }
    };
    
    if (animated) {
        [self transitionFromViewController:oldController
                          toViewController:self.gameViewController
                                  duration:.3f
                                   options:UIViewAnimationOptionTransitionFlipFromRight
                                animations:animation
                                completion:completionBlock];
    } else {
        animation();
        completionBlock(YES);
    }
}

- (void)setExpanded:(BOOL)isExpanded
{
    if (_isExpanded == isExpanded) {
        return;
    }
    
    _isExpanded = isExpanded;
    
    if (_isExpanded) {
        [self _expandAnimated:YES];
    } else {
        [self _closeAnimated:YES];
    }
}

#pragma mark -
#pragma mark - Private

- (void)_applicationDidEnterBackground
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    if (self.navigationBar.timer) {
        NSLog(@"INVALIDATING TIMER");
       [self.navigationBar.timer invalidate];
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.navigationBar.lives.count forKey:HDRemainingLivesKey];
    [[NSUserDefaults standardUserDefaults] setFloat:self.navigationBar.remainingTime forKey:HDRemainingTime];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date]                   forKey:HDBackgroundDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)_applicationDidBecomeActive
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    
    NSUInteger remainingLives = [[NSUserDefaults standardUserDefaults] integerForKey:HDRemainingLivesKey];
    NSUInteger remainingTime  = [[NSUserDefaults standardUserDefaults] floatForKey:HDRemainingTime];
    
    NSDate *wentIntoBackground = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:HDBackgroundDate];
    NSTimeInterval secondsInBackground = [[NSDate date] timeIntervalSinceDate:wentIntoBackground];
    
    
    
    NSLog(@"%f", secondsInBackground);
}

- (void)_closeAnimated:(BOOL)flag
{
    dispatch_block_t closeAnimation = ^{
        CGRect rect = self.gameViewController.view.frame;
        rect.origin.x = 0;
        [self.gameViewController.view setFrame:rect];
    };
    
    if (!flag) {
        closeAnimation();
    } else {
        [UIView animateWithDuration:.3f
                         animations:closeAnimation
                         completion:nil];
    }
}

- (void)_expandAnimated:(BOOL)flag
{
    dispatch_block_t expandAnimation = ^{
        CGRect rect = self.gameViewController.view.frame;
        rect.origin.x += kAnimationOffsetX;
        [self.gameViewController.view setFrame:rect];
    };
    
    if (!flag) {
        expandAnimation();
    } else {
        [UIView animateWithDuration:.3f
                         animations:expandAnimation
                         completion:nil];
    }
}

- (void)_layoutNavigationBarWithLives:(NSInteger)lives time:(NSTimeInterval)seconds;
{
    CGRect navigationBarFrame = CGRectMake(0.0f, 3.0f, CGRectGetWidth(self.view.bounds), 50.0f);
     self.navigationBar = [[HDNavigationBar alloc] initWithFrame:navigationBarFrame numberOfLives:lives time:seconds];
    [self.navigationBar.toggleSideMenu addTarget:self action:@selector(_toggleHDMenuViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.gameViewController.view addSubview:self.navigationBar];
}

- (void)_toggleHDMenuViewController
{
    [self setExpanded:!self.isExpanded];
}

@end

