//
//  HDLevelViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "UIColor+FlatColors.h"
#import "HDMapScene.h"
#import "HDMapViewController.h"
#import "HDContainerViewController.h"
#import "HDGameViewController.h"
#import "HDGridManager.h"

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

NSString * const MAP_GRID_JSON = @"MapGrid";

@interface HDMapViewController ()

@property (nonatomic, strong) HDGridManager *gridManager;

@property (nonatomic, strong) HDMapScene *scene;

//@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation HDMapViewController

- (void)loadView
{
    CGRect viewRect = [[UIScreen mainScreen] bounds];
    SKView *skView = [[SKView alloc] initWithFrame:viewRect];
    [self setView:skView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gridManager = [[HDGridManager alloc] initWithLevel:MAP_GRID_JSON];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        
        self.scene = [HDMapScene sceneWithSize:self.view.bounds.size];
        [self.scene setScaleMode:SKSceneScaleModeAspectFill];
        [self.scene setGridManager:self.gridManager];
        
        [skView presentScene:self.scene];
        
        [self _layoutMap];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_layoutMap
{
    [self.scene layoutNodesWithGrid:[self.gridManager hexagons]];
}

@end
