//
//  HDLockedView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/23/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import CoreMotion;

#import "HDLockedView.h"
#import "UIColor+FlatColors.h"

static const CGFloat kPadding = 4.0f;
@interface HDLockedView ()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *floatingAnchorBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@end

@implementation HDLockedView
{
    BOOL _isStarted;
}

- (void)dealloc
{
    [self stopMonitoringMotionUpdates];
}

- (void)startMonitoringMotionUpdates
{
    if (_isStarted) {
        return;
    }
    [self _setup];
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                            withHandler:
     ^(CMDeviceMotion *motion, NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             double angle = atan2(CGVectorMake(-motion.gravity.x, -motion.gravity.y).dy,
                                  CGVectorMake( motion.gravity.x,  motion.gravity.y).dx);
             [self.floatingAnchorBehavior setAnchorPoint:[self _pointFromAngle:angle
                                                                        center:self.attachmentBehavior.anchorPoint
                                                                        radius:CGRectGetMidY(self.bounds)]];
         });
     }];
    _isStarted = YES;
}

- (void)stopMonitoringMotionUpdates
{
    if (!_isStarted) {
        return;
    }
    [self.motionManager stopDeviceMotionUpdates];
    [self _teardown];
    _isStarted = NO;
}

#pragma mark -
#pragma mark - <PRIVATE>

- (void)_setup
{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    
    UIImageView *pictureFrame = [[UIImageView alloc] initWithImage:[self _levelsComingSoonSign]];
    [pictureFrame setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds)/3)];
    pictureFrame.layer.allowsEdgeAntialiasing = YES;
    pictureFrame.layer.borderWidth = 10.0f;
    pictureFrame.layer.borderColor = [[UIColor clearColor] CGColor];
    [self addSubview:pictureFrame];
    
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[pictureFrame]];
    
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[pictureFrame]];
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:self.collisionBehavior];
    
    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:pictureFrame
                                                        offsetFromCenter:UIOffsetMake(0.0f, -CGRectGetHeight(pictureFrame.bounds)/2.5f)
                                                        attachedToAnchor:CGPointMake(
                                                                                     CGRectGetMidX(self.bounds),
                                                                                     CGRectGetHeight(self.bounds)/5
                                                                                     )];
    self.attachmentBehavior.damping   = 0;
    self.attachmentBehavior.length    = 0;
    self.attachmentBehavior.frequency = 0;
    [self.animator addBehavior:self.attachmentBehavior];
    
    self.floatingAnchorBehavior = [[UIAttachmentBehavior alloc] initWithItem:pictureFrame
                                                            offsetFromCenter:UIOffsetMake(0.0f, CGRectGetHeight(pictureFrame.bounds)/2)
                                                            attachedToAnchor:CGPointMake(
                                                                                         CGRectGetWidth(self.bounds),
                                                                                         CGRectGetHeight(self.bounds)
                                                                                         )];
    self.floatingAnchorBehavior.damping   = .2f;
    self.floatingAnchorBehavior.length    = 0;
    self.floatingAnchorBehavior.frequency = 1;
    [self.animator addBehavior:self.floatingAnchorBehavior];

//    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[pictureFrame]];
//    [itemBehavior setElasticity:.25f];
    
    self.motionManager = [[CMMotionManager alloc] init];
    [self.motionManager setDeviceMotionUpdateInterval:1/60.0f];
}

- (void)_teardown
{
    [self.animator removeAllBehaviors];
    self.gravityBehavior = nil;
    self.attachmentBehavior = nil;
    self.floatingAnchorBehavior = nil;
    self.motionManager = nil;
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma -

- (UIImage *)_levelsComingSoonSign
{
    static UIImage *comingSoonSign;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGSize imageSize = CGSizeMake(CGRectGetWidth(self.bounds)/1.35f, CGRectGetHeight(self.bounds)/1.8f);
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, [[UIScreen mainScreen] scale]);
        
        CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
        CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
        
        [[UIColor whiteColor] setFill];
        [[UIColor flatPeterRiverColor] setStroke];
        
        CGRect nailFrame = CGRectMake(imageSize.width/2 - kPadding*5/2, imageSize.height/20, kPadding*5, kPadding*5);
        CGRect signFrame = CGRectMake(3.0f, imageSize.height/3.25, imageSize.width - 6.0f, imageSize.height/1.5f);
        
        UIBezierPath *leftString  = [UIBezierPath bezierPath];
        [leftString moveToPoint:CGPointMake(CGRectGetMidX(nailFrame), CGRectGetMidY(nailFrame))];
        [leftString addLineToPoint:CGPointMake(imageSize.width/3.f, imageSize.height/3.25)];
        
        UIBezierPath *rightString = [UIBezierPath bezierPath];
        [rightString moveToPoint:CGPointMake(CGRectGetMidX(nailFrame), CGRectGetMidY(nailFrame))];
        [rightString addLineToPoint:CGPointMake(imageSize.width/1.5f, imageSize.height/3.25)];
        
        for (UIBezierPath *path in @[leftString, rightString]) {
            path.lineWidth = 5.0f;
            [path stroke];
        }
        
        [[UIColor flatEmeraldColor] setStroke];
        
        UIBezierPath *signPath = [UIBezierPath bezierPathWithRoundedRect:signFrame cornerRadius:10.0f];
        signPath.lineWidth = 8.0f;
        [signPath stroke];
        
        UIBezierPath *nail = [UIBezierPath bezierPathWithOvalInRect:nailFrame];
        [nail fill];
        
        //  [@"Coming Soon"]
        
        comingSoonSign = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return comingSoonSign;
}

- (CGPoint)_pointFromAngle:(double)rAngle center:(CGPoint)centerPoint radius:(double)radius
{
    return CGPointMake(radius * cos(rAngle) + centerPoint.x, radius * sin(rAngle) + centerPoint.y);
}

@end
