//
//  HDGridScrollView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/19/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import CoreMotion;

#import "HDLevel.h"
#import "HDHexagonView.h"
#import "HDGridScrollView.h"
#import "NSMutableArray+UniqueAdditions.h"
#import "UIColor+FlatColors.h"

static const CGFloat kPadding = 4.0f;
static const CGFloat kTileHeightInsetMultiplier = .855f;

#define kHexaSize [[UIScreen mainScreen] bounds].size.width / 6.0f
@interface HDGridScrollView ()
@property (nonatomic, weak) id <HDGridScrollViewDelegate> delegate;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIAttachmentBehavior *attachment;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) HDMapManager *manager;
@end

@implementation HDGridScrollView {
    NSArray *_hexaArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    NSAssert(NO, @"Use initWithFrame:(CGRect)frame manager:(HDMapManager *)manager delegate:(id<HDGridScrollViewDelegate>)delegate instead");
    return [self initWithFrame:frame manager:nil delegate:nil];
}

- (instancetype)initWithFrame:(CGRect)frame manager:(HDMapManager *)manager delegate:(id<HDGridScrollViewDelegate>)delegate
{
    if (self = [super initWithFrame:frame]) {
        [self setContentSize:CGSizeMake(CGRectGetWidth(self.bounds)*numberOfPages, CGRectGetHeight(self.bounds))];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setPagingEnabled:YES];
        [self setClipsToBounds:YES]; // Want to be able to see multiple pages, inform user they can scroll
        [self setManager:manager];
        [self setDelegate:delegate];
        
        [self _setup];
    }
    return self;
}

#pragma mark - 
#pragma mark - < PUBLIC >

- (void)performIntroAnimationWithCompletion:(dispatch_block_t)completion
{
    const NSTimeInterval kIncreaseInterval = .03f;
    for (NSArray *pageOfTiles in _hexaArray) {
        
        NSTimeInterval delay = 0.0f;
        
        NSMutableArray *tiles = [pageOfTiles mutableCopy];
        [tiles shuffle];
        
        for (HDHexagonView *hexa in tiles) {
            
            [hexa performSelector:@selector(setHidden:) withObject:0 afterDelay:delay];
            
            CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            [scale setValues:@[@0.0f,@1.1f,@1.0f]];
            [scale setDuration:.3f];
            [scale setBeginTime:CACurrentMediaTime() + delay];
            [hexa.layer addAnimation:scale forKey:@"ScaleIn"];
            
            delay += kIncreaseInterval;
        }
    }
}

- (void)performOutroAnimationWithCompletion:(dispatch_block_t)completion
{
    const NSTimeInterval kIncreaseInterval = .03f;
    for (NSArray *pageOfTiles in _hexaArray) {
        
        NSTimeInterval delay = 0.0f;
        
        NSMutableArray *tiles = [pageOfTiles mutableCopy];
        [tiles shuffle];
        
        for (HDHexagonView *hexa in tiles) {
            
            CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            [scale setValues:@[@1.0f,@1.1f,@0.0f]];
            [scale setDuration:.3f];
            [scale setRemovedOnCompletion:NO];
            [scale setFillMode:kCAFillModeForwards];
            [scale setBeginTime:CACurrentMediaTime() + delay];
            [hexa.layer addAnimation:scale forKey:@"ScaleOut"];
            
            delay += kIncreaseInterval;
        }
    }
    
    CGFloat delayTotal = [[_hexaArray firstObject] count] * .03f;
    
    NSTimeInterval callBackDelay = delayTotal + .3f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(callBackDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion();
    });
}

#pragma mark -
#pragma mark - < PRIVATE >

- (void)_setup
{
    
    NSMutableArray *hexaArray = [NSMutableArray arrayWithCapacity:numberOfPages];
    
    // Loop through number of pages, add a container at the center of page for each container
    NSUInteger tagIndex = 1;
    for (int page = 0; page < numberOfPages; page++) {
        
        CGPoint center  = CGPointMake(
                                      page * CGRectGetWidth(self.bounds) + CGRectGetWidth(self.bounds)/2,
                                      CGRectGetHeight(self.bounds)/2
                                      );
        
        if (page < (numberOfPages - numberOfLocked)) {
            
            CGRect containerFrame = CGRectMake(
                                               0.0f,
                                               0.0f,
                                               kHexaSize * numberOfColumns,
                                               kHexaSize * kTileHeightInsetMultiplier * (numberOfRows - 1)
                                               );
            
            UIView *container = [[UIView alloc] initWithFrame:containerFrame];
            [container setCenter:center];
            [self addSubview:container];
            
            NSMutableArray *_pageArray = [NSMutableArray arrayWithCapacity:numberOfColumns*numberOfRows];
            
            for (int row = 0; row < numberOfRows; row++) {
                for (int column = 0; column < numberOfColumns; column++) {
                    
                    HDLevel *level = [self.manager levelAtIndex:tagIndex - 1];
                    
                    CGRect bounds = CGRectMake(0.0f, 0.0f, kHexaSize - kPadding, kHexaSize - kPadding);
                    HDHexagonView *hexagon = [[HDHexagonView alloc] initWithFrame:bounds
                                                                             type:HDHexagonTypePoint
                                                                      strokeColor:[UIColor flatPeterRiverColor]];
                    [hexagon setTag:tagIndex];
                    [hexagon setHidden:YES];
                    [hexagon setCenter:[self _pointForColumn:column row:row]];
                    [_pageArray addObject:hexagon];
                    [container addSubview:hexagon];
                    
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_beginGame:)];
                    [tap setNumberOfTapsRequired:1];
                    [hexagon addGestureRecognizer:tap];
                    
                    if (level.completed) {
                        [hexagon setState:HDHexagonStateCompleted index:tagIndex];
                    } else if (!level.completed && level.isUnlocked) {
                        [hexagon setState:HDHexagonStateUnlocked index:tagIndex];
                    } else {
                        [hexagon setState:HDHexagonStateLocked index:tagIndex];
                    }
                    tagIndex++;
                }
            }
            
            [hexaArray addObject:_pageArray];
            
        } else {
            
            UIView *container = [[UIView alloc] initWithFrame:self.bounds];
            [container setCenter:center];
            [self addSubview:container];
            
            UIImageView *locked = [[UIImageView alloc] initWithImage:[self _levelsComingSoonSign]];
            [locked.layer setAnchorPoint:CGPointMake(.5, .05)];
            [locked setCenter:CGPointMake(CGRectGetMidX(container.bounds), 40.0f)];
            [container addSubview:locked];
            
            
            
                self.motionManager = [[CMMotionManager alloc] init];
            NSOperationQueue* motionQueue = [[NSOperationQueue alloc] init];
                CGFloat updateInterval = 5.0;
                CMAttitudeReferenceFrame frame = CMAttitudeReferenceFrameXArbitraryCorrectedZVertical;
                [self.motionManager setDeviceMotionUpdateInterval:updateInterval];
                [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:frame
                                                                       toQueue:motionQueue
                                                                   withHandler:
                 ^(CMDeviceMotion* motion, NSError* error){
                     CGFloat angle =  atan2( motion.gravity.x, motion.gravity.y );
                     NSLog(@"%f",angle);
                     [locked.layer setValue:@(angle) forKeyPath:@"transform.rotation.z"];
                 }];
            
//            self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:container];
//            
//            self.attachment = [[UIAttachmentBehavior alloc] initWithItem:locked
//                                                        attachedToAnchor:CGPointMake(CGRectGetMidX(self.bounds), 60.0f)];
//            [self.attachment setDamping:0];
//            [self.attachment setLength:0];
//            [self.attachment setFrequency:0];
//            [self.animator addBehavior:self.attachment];
//            
//            self.gravity = [[UIGravityBehavior alloc] initWithItems:@[locked]];
//            [self.animator addBehavior:self.gravity];
//         
//            UIDynamicItemBehavior *lockedBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[locked]];
//            [lockedBehavior setDensity:1000000.0f];
//            [lockedBehavior setAllowsRotation:YES];
//            [self.animator addBehavior:lockedBehavior];
//            
//            NSOperationQueue* motionQueue = [[NSOperationQueue alloc] init];
//            
//             self.motionManager = [[CMMotionManager alloc] init];
//            [self.motionManager startDeviceMotionUpdatesToQueue:motionQueue
//                                                    withHandler:^(CMDeviceMotion *motion, NSError *error) {
//                
//                CMAcceleration gravity = motion.gravity;
//                
//                CGFloat x = gravity.x;
//                CGFloat y = gravity.y;
//         
//                [lockedBehavior addAngularVelocity:-x/35 forItem:locked];
//                                
//            }];

        }
    }
    _hexaArray = hexaArray;
}

- (CGPoint)_pointForColumn:(NSInteger)column row:(NSInteger)row
{
    // Find position from Column/Row
    const CGFloat kOriginY = ((row * (kHexaSize * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = kHexaSize/4 + ((column * kHexaSize));
    const CGFloat kAlternateOffset = (row % 2 == 0) ? kHexaSize / 2 : 0.0f;
    
    return CGPointMake(kAlternateOffset + kOriginX, kOriginY);
}

- (void)_beginGame:(UIGestureRecognizer *)gesture
{
    UIButton *button = (UIButton *)gesture.view;
    if (self.delegate && [self.delegate respondsToSelector:@selector(beginGameAtLevelIndex:)]) {
        [self.delegate beginGameAtLevelIndex:button.tag];
    }
}

- (UIImage *)_levelsComingSoonSign
{
    static UIImage *comingSoonSign;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGSize imageSize = CGSizeMake(CGRectGetWidth(self.bounds)/1.35f, CGRectGetHeight(self.bounds)/1.8f);
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, [[UIScreen mainScreen] scale]);
        
        [[UIColor whiteColor] setFill];
        [[UIColor flatPeterRiverColor] setStroke];
        
        CGRect nailFrame = CGRectMake(imageSize.width/2 - kPadding*5/2, imageSize.height/20, kPadding*5, kPadding*5);
        CGRect signFrame = CGRectMake(0.0, imageSize.height/3.25, imageSize.width, imageSize.height/1.5f);
        
        UIBezierPath *leftString  = [UIBezierPath bezierPath];
        [leftString moveToPoint:CGPointMake(CGRectGetMidX(nailFrame), CGRectGetMidY(nailFrame))];
        [leftString addLineToPoint:CGPointMake(imageSize.width/3.f, imageSize.height/3.25)];
        [leftString stroke];
        
        UIBezierPath *rightString = [UIBezierPath bezierPath];
        [rightString moveToPoint:CGPointMake(CGRectGetMidX(nailFrame), CGRectGetMidY(nailFrame))];
        [rightString addLineToPoint:CGPointMake(imageSize.width/1.5f, imageSize.height/3.25)];
        [rightString stroke];
        
        for (UIBezierPath *path in @[leftString, rightString]) {
            [path setLineWidth:5.0f];
            [path stroke];
        }
        
        [[UIColor whiteColor] setStroke];
        
        UIBezierPath *signPath = [UIBezierPath bezierPathWithRoundedRect:signFrame cornerRadius:10.0f];
        [signPath fill];
        
        UIBezierPath *nail = [UIBezierPath bezierPathWithOvalInRect:nailFrame];
        [nail fill];
        
      //  [@"Coming Soon"]
        
        comingSoonSign = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return comingSoonSign;
}

@end
