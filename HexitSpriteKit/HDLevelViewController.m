//
//  HDLevelViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHexagonView.h"
#import "HDMapScrollView.h"
#import "UIColor+FlatColors.h"
#import "HDLevelViewController.h"
#import "HDContainerViewController.h"
#import "HDGameViewController.h"

@implementation HDIndicator

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        CAShapeLayer *shape = (CAShapeLayer *)self.layer;
        [shape setPath:[[self indicatorPathFromBounds:self.bounds] CGPath]];
        [shape setStrokeColor:[[UIColor flatPeterRiverColor] CGColor]];
        [shape setFillColor:[[UIColor flatMidnightBlueColor] CGColor]];
        [shape setLineWidth:4];
        
        CGRect bounds = CGRectMake(0.0f, 0.0f, 36.0f, 36.0f);
        CALayer *layer = [CALayer layer];
        [layer setBounds:bounds];
        [layer setBorderWidth:2];
        [layer setCornerRadius:CGRectGetMidX(bounds)];
        [layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
        [layer setBorderColor:[[UIColor flatPeterRiverColor] CGColor]];
        [layer setPosition:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) / 2)];
        [self.layer addSublayer:layer];
        
    }
    return self;
}

- (UIBezierPath *)indicatorPathFromBounds:(CGRect)bounds
{
    UIBezierPath *_path = [UIBezierPath bezierPath];
    
    [_path addArcWithCenter:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) / 2)
                     radius:CGRectGetMidX(bounds)
                 startAngle:M_PI - .3f
                   endAngle:.3f
                  clockwise:YES];
    [_path addLineToPoint:CGPointMake(CGRectGetMidX(bounds), CGRectGetHeight(bounds) - (CGRectGetMidX(bounds) / 4))];
    [_path closePath];
    
    return _path;
}

@end

@interface HDLevelViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HDLevelViewController{
    NSMutableArray *_levelSelectors;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect rect = CGRectMake(25.0f, 130.0f, 325.0f, 325.0f);
    HDMapScrollView *scrollView = [[HDMapScrollView alloc] initWithFrame:rect];
    [scrollView setDelegate:self];
    [self.view addSubview:scrollView];
    
    [self.view setClipsToBounds:YES];
    [self _layoutLevelGrid];
}

- (void)_layoutLevelGrid
{
    if (!_levelSelectors) {
        _levelSelectors = [NSMutableArray array];
    }
    
    const CGSize kButtonSize = CGSizeMake(96.0f, 96.0f);
    for (int row = 0; row < 2; row++) {
        
        NSInteger columns = (row % 2 == 0) ? 2 : 3;
        for (int column = 0; column < columns; column++) {
            
            CGRect bounds = CGRectMake(0.0f, 0.0f, kButtonSize.width, kButtonSize.height);
            HDHexagonView *button = [[HDHexagonView alloc] initWithFrame:bounds];
            [button setCenter:[self buttonPositionForRow:row column:column size:CGRectGetHeight(button.bounds)]];
            [[button titleLabel] setTextAlignment:NSTextAlignmentCenter];
            [[button titleLabel] setFont:GILLSANS_LIGHT(18.0f)];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(openLevel:) forControlEvents:UIControlEventTouchUpInside];
            [_levelSelectors addObject:button];
            [self.view addSubview:button];
            
            CAShapeLayer *layer = (CAShapeLayer*)button.layer;
            [layer setStrokeColor:[[UIColor flatPeterRiverColor] CGColor]];
            [layer setFillColor:[[UIColor flatMidnightBlueColor] CGColor]];
            [layer setLineWidth:6.0f];
           
        }
    }
    
    [self updateLevelSelectorStartingAtIndex:1];
    
    CGRect bounds = CGRectMake(0.0f, 0.0f, 56.0f, 70.0f);
    HDIndicator *indicator = [[HDIndicator alloc] initWithFrame:bounds];
    [indicator setCenter:CGPointMake(190.0f, 530.0f)];
    [self.view addSubview:indicator];
}

- (void)updateLevelSelectorStartingAtIndex:(NSInteger)index
{
    for (HDHexagonView *hexagon in _levelSelectors) {
        [hexagon.textLabel setText:[NSString stringWithFormat:@"%lu",index]];
        index++;
    }
}

- (CGPoint)buttonPositionForRow:(NSInteger)row column:(NSInteger)column size:(CGFloat)size
{
    const CGFloat kOriginX = ceilf(CGRectGetMidX(self.view.bounds) - size) + (column * size);
    const CGFloat kOriginY = 565.0f + ((row * (size * .845f)) - (size / 2));
    const CGFloat kOffsetX = (row % 2 == 0) ? size / 2.f : 0.0f;
    
    return CGPointMake(kOffsetX + kOriginX, kOriginY);
}

- (void)openLevel:(id)sender
{
    HDHexagonView *button = (HDHexagonView *)sender;
    
    NSInteger selectedLevel = button.textLabel.text.integerValue;
    
    [ADelegate navigateToNewLevel:selectedLevel];
}

#pragma mark -
#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSUInteger page = ceilf(scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds));
    
    switch (page) {
        case 0:
            [self updateLevelSelectorStartingAtIndex:1];
            break;
        case 1:
            [self updateLevelSelectorStartingAtIndex:6];
            break;
        case 2:
            [self updateLevelSelectorStartingAtIndex:11];
            break;
        case 3:
            [self updateLevelSelectorStartingAtIndex:16];
            break;
        case 4:
            [self updateLevelSelectorStartingAtIndex:21];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
