//
//  HDGridViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/21/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//



#import "HDLevel.h"
#import "HDHelper.h"
#import "HDMapManager.h"
#import "HDHexagonControl.h"
#import "HDSoundManager.h"
#import "HDHexagonView.h"
#import "UIColor+FlatColors.h"
#import "HDGridViewController.h"
#import "HDContainerViewController.h"

static NSString * const title = @"Locked";
static NSString * const cellReuseIdentifer = @"identifier";

static const NSUInteger numberOfRows    = 7;
static const NSUInteger numberOfColumns = 4;
static const NSUInteger numberOfPages   = 3;

static const CGFloat kPadding = 4.0f; //

static const CGFloat TILESIZE = 60.0f;
static const CGFloat kTileHeightInsetMultiplier = .845f;

@interface HDGridViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) HDHexagonControl *control;

@property (nonatomic, assign) BOOL navigationBarHidden;

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIButton *play;

@end

@implementation HDGridViewController {
    NSDictionary *_metrics;
    NSDictionary *_views;
    
    NSInteger _previousPage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor flatMidnightBlueColor]];
    [self.view setClipsToBounds:YES];
    
    CGRect scrollViewRect = CGRectInset(self.view.bounds, 50.0f, 90.0f);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(scrollView.bounds)*3, CGRectGetHeight(scrollView.bounds))];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setPagingEnabled:YES];
    [scrollView setClipsToBounds:NO];
    [scrollView setDelegate:self];
    [self.view addSubview:scrollView];
    
    NSUInteger tagIndex = 1;
    for (int page = 0; page < numberOfPages; page++) {
        
        CGPoint center  = CGPointMake(
                                      page * CGRectGetWidth(scrollView.bounds) + CGRectGetWidth(scrollView.bounds)/2,
                                      CGRectGetHeight(scrollView.bounds)/2
                                      );
        
        CGRect containerFrame = CGRectMake(
                                           0.0f,
                                           0.0f,
                                           TILESIZE * (numberOfColumns - 1),
                                           TILESIZE*kTileHeightInsetMultiplier * (numberOfRows - 1)
                                           );
        UIView *container = [[UIView alloc] initWithFrame:containerFrame];
        [container setCenter:center];
        [scrollView addSubview:container];
        
        
        for (int row = 0; row < numberOfRows; row++) {
            for (int column = 0; column < numberOfColumns; column++) {
                
                HDLevel *level = [[HDMapManager sharedManager] levelAtIndex:tagIndex - 1];
                
                CGRect bounds = CGRectMake(0.0f, 0.0f, TILESIZE - kPadding, TILESIZE - kPadding);
                HDHexagonView *hexagon = [[HDHexagonView alloc] initWithFrame:bounds strokeColor:[UIColor flatPeterRiverColor]];
                [hexagon setTag:tagIndex];
                [[hexagon titleLabel] setTextAlignment:NSTextAlignmentCenter];
                [[hexagon titleLabel] setFont:GILLSANS(CGRectGetHeight(hexagon.bounds)/3.5f)];
                [hexagon addTarget:self action:@selector(beginGame:) forControlEvents:UIControlEventTouchUpInside];
                [hexagon setCenter:[self _pointForColumn:column row:row]];
                [container addSubview:hexagon];
                
                if (level.completed) {
                    [(CAShapeLayer *)hexagon.layer setFillColor:[[UIColor flatPeterRiverColor] CGColor]];
                    [hexagon setTitleColor:[UIColor flatMidnightBlueColor] forState:UIControlStateNormal];
                    [hexagon setTitle:[NSString stringWithFormat:@"%lu",tagIndex] forState:UIControlStateNormal];
                } else if (!level.completed && level.isUnlocked) {
                    [(CAShapeLayer *)hexagon.layer setStrokeColor:[[UIColor whiteColor] CGColor]];
                    [hexagon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [hexagon setTitle:[NSString stringWithFormat:@"%lu",tagIndex] forState:UIControlStateNormal];
                } else {
                    [hexagon setImage:[UIImage imageNamed:@"WhiteLock"] forState:UIControlStateNormal];
                }
                
                tagIndex++;
            }
        }
    }
    [self _layoutNavigationButtons];
    
    CGRect controlRect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), 50.0f);
     self.control = [[HDHexagonControl alloc] initWithFrame:controlRect];
    [self.control setNumberOfPages:3];
    [self.control setCurrentPage:0];
    [self.control setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetHeight(self.view.bounds) + 25.0f)];
    [self.view addSubview:self.control];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    _navigationBarHidden = navigationBarHidden;
    
    if (_navigationBarHidden) {
        [self hideAnimated:YES];
    } else {
        [self showAnimated:YES];
    }
}

- (void)hideAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGRect rect = self.container.frame;
        rect.origin.y = -70.0f;
        [self.container setFrame:rect];
        
        CGPoint center = self.control.center;
        center.y =  CGRectGetHeight(self.view.bounds) + 25.0f;
        [self.control setCenter:center];
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.3f animations:animate];
    }
}

- (void)showAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGRect rect = self.container.frame;
        rect.origin.y = 0.0f;
        [self.container setFrame:rect];
        
        CGPoint center = self.control.center;
        center.y = CGRectGetHeight(self.view.bounds) - 45.0f;
        [self.control setCenter:center];
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.3f animations:animate];
    }
}

- (CGPoint)_pointForColumn:(NSInteger)column row:(NSInteger)row
{
    const CGFloat kOriginY = ((row * (TILESIZE * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = -TILESIZE/4 + ((column * TILESIZE));
    const CGFloat kAlternateOffset = (row % 2 == 0) ? TILESIZE/2 : 0.0f;
    
    return CGPointMake(kAlternateOffset + kOriginX, kOriginY);
}

- (void)_beginLastUnlockedLevel
{
    [self beginLevel:[[HDMapManager sharedManager] indexOfCurrentLevel]];
}

- (void)beginGame:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self beginLevel:button.tag];
}

- (void)beginLevel:(NSInteger)level
{
    HDLevel *gamelevel = [[HDMapManager sharedManager] levelAtIndex:(NSInteger)level - 1];
    
    if (gamelevel.isUnlocked) {
        
        [self setNavigationBarHidden:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[HDSoundManager sharedManager] playSound:HDButtonSound];
            [ADelegate navigateToNewLevel:(NSInteger)level];
        });
    }
}

- (void)_layoutNavigationButtons
{
    HDContainerViewController *container = self.containerViewController;
    
    CGRect containerFrame = CGRectMake(0.0f, -70.0f, CGRectGetWidth(self.view.bounds), 70.0f);
    self.container = [[UIView alloc] initWithFrame:containerFrame];
    [self.container setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.container];
    
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.toggleButton setImage:[UIImage imageNamed:@"Grid@2x"] forState:UIControlStateNormal];
    [self.toggleButton addTarget:container action:@selector(toggleHDMenuViewController) forControlEvents:UIControlEventTouchUpInside];
    
    self.play = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.play setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    [self.play addTarget:self action:@selector(_beginLastUnlockedLevel) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *button in @[self.toggleButton, self.play]) {
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.container addSubview:button];
    }
    
    UIButton *toggle = self.toggleButton;
    UIButton *play   = self.play;
    
    _views = NSDictionaryOfVariableBindings(toggle, play);
    
    _metrics = @{ @"buttonHeight" : @42.0f, @"inset" : @20.0f };
    
    NSArray *toggleHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[toggle(buttonHeight)]"
                                                                                  options:0
                                                                                  metrics:_metrics
                                                                                    views:_views];
    [self.view addConstraints:toggleHorizontalConstraint];
    
    NSArray *toggleVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[toggle(buttonHeight)]"
                                                                                  options:0
                                                                                  metrics:_metrics
                                                                                    views:_views];
    [self.view addConstraints:toggleVerticalConstraint];
    
    NSArray *shareHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[play(buttonHeight)]-inset-|"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
    [self.view addConstraints:shareHorizontalConstraint];
    
    NSArray *shareVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[play(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
    [self.view addConstraints:shareVerticalConstraint];
}

#pragma mark -
#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSUInteger page = (NSUInteger)floorf(scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds));
    [self.control setCurrentPage:MIN(page, 2)];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[HDSoundManager sharedManager] playSound:@"Swooshed.mp3"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
