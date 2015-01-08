//
//  HDHexagonNode.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHexagon.h"
#import "HDHelper.h"
#import "HDHexagonNode.h"
#import "SKColor+HDColor.h"

static const CGFloat kPadding = 3.0f;
static const CGFloat kHexagonInset = 9.0;

@interface HDHexagonNode ()
@property (nonatomic, strong) SKLabelNode *countLabel;
@end

@implementation HDHexagonNode {
    SKSpriteNode *_indicator;
    NSUInteger _layerIndex;
}

- (instancetype)initWithPath:(CGPathRef)pathRef
{
    if (self = [super init]) {
        
        self.lineWidth = 6.0f;
        self.pathRef   = pathRef;
        self.fillColor = [UIColor yellowColor];

    }
    return self;
}

+ (instancetype)shapeNodeWithPath:(CGPathRef)pathRef
{
    return [[HDHexagonNode alloc] initWithPath:pathRef];
}

+ (SKTexture *)textureFromPath:(CGPathRef)pathRef
                          size:(CGSize)size
                   strokeColor:(UIColor *)strokeColor
                     fillColor:(UIColor *)fillColor
                     lineWidth:(CGFloat)lineWidth
                numberOfLayers:(NSUInteger)layersCount
{
    if (!pathRef) {
        return nil;
    }
    
    if (lineWidth < 1) {
        return nil;
    }
    
    if (layersCount == 0) {
        return nil;
    }
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return nil;
    }
    
    if (strokeColor == nil) {
        return nil;
    }
    
    if (fillColor == nil) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    
    [fillColor setFill];
    [strokeColor setStroke];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:pathRef];
    path.lineWidth = lineWidth;
    path.lineJoinStyle = kCGLineJoinRound;
    [path fill];
    [path stroke];
    
    UIImage *imageForTexture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [SKTexture textureWithImage:imageForTexture];
}

- (void)_setup
{
    CGSize pathSize = CGSizeMake(CGRectGetWidth(self.frame)/4, CGRectGetWidth(self.frame)/4);
    UIGraphicsBeginImageContextWithOptions(pathSize, NO, [[UIScreen mainScreen] scale]);
    
    [[UIColor whiteColor] setStroke];
    
    CGRect pathFrame = CGRectMake(2.0f, 2.0f, CGRectGetWidth(self.frame)/4 - 4.0f, CGRectGetWidth(self.frame)/4 - 4.0f);
    CGPathRef path = [[HDHelper bezierHexagonInFrame:pathFrame] CGPath];
    UIBezierPath *bezierDot = [UIBezierPath bezierPathWithCGPath:path];
    bezierDot.lineWidth = 3.0f;
    [bezierDot stroke];
    
    UIImage *indicator = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    SKTexture *indicatorTexture = [SKTexture textureWithImage:indicator];
    _indicator = [SKSpriteNode spriteNodeWithTexture:indicatorTexture];
    _indicator.position    = CGPointZero;
    [self insertChild:_indicator atIndex:0];
}

- (void)setStrokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    self.strokeColor = strokeColor;
    self.fillColor   = fillColor;
}

- (void)setLocked:(BOOL)locked
{
    if (_locked == locked) {
        return;
    }
    
    _locked = locked;
    
    if (locked) {
        // Add lock
        SKSpriteNode *lock = [SKSpriteNode spriteNodeWithImageNamed:@"Locked.png"];
        [self addChild:lock];
    } else {
        // Remove Lock
        [self.children makeObjectsPerformSelector:@selector(removeFromParent)];
    }
}

- (void)addHexaLayer;
{

    CGRect rectWithInset = CGRectInset([[self children] lastObject] ?
                                       [(SKSpriteNode *)[[self children] lastObject] frame] : self.frame, kHexagonInset, kHexagonInset);
    
    CGRect pathFrame = CGRectMake(kPadding, kPadding, CGRectGetHeight(rectWithInset) - kPadding*2, CGRectGetHeight(rectWithInset) - kPadding*2);
    
    CGPathRef pathRef = [[HDHelper bezierHexagonInFrame:pathFrame] CGPath];
    
    SKTexture *imageTexture = [[self class] textureFromPath:pathRef
                                                       size:CGSizeMake(CGRectGetHeight(rectWithInset),
                                                                       CGRectGetHeight(rectWithInset))
                                                strokeColor:self.strokeColor
                                                  fillColor:self.fillColor
                                                  lineWidth:6.0f
                                             numberOfLayers:1];
    
    SKSpriteNode *hexagon = [SKSpriteNode spriteNodeWithTexture:imageTexture];
    hexagon.position    = CGPointMake(1.0f, 1.0f);
    [[[self children] lastObject] ? [[self children] lastObject] : self addChild:hexagon];
}

- (void)indicatorPositionFromHexagonType:(HDHexagonType)type
{
    [self indicatorPositionFromHexagonType:type withTouchesCount:0];
}

- (void)indicatorPositionFromHexagonType:(HDHexagonType)type withTouchesCount:(NSInteger)count;
{
    if (type == HDHexagonTypeNone) {
        [_indicator removeFromParent];
        _indicator = nil;
    } else {
        [self _setup];
        _indicator.position = CGPointMake(0.0f, 0.0f);
    }
}

- (void)_invalidate
{
  self.texture = [[self class] textureFromPath:self.pathRef
                                          size:self.size
                                   strokeColor:self.strokeColor
                                     fillColor:self.fillColor
                                     lineWidth:self.lineWidth
                                numberOfLayers:1];
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
    [self _invalidate];
}

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    [self _invalidate];
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    [self _invalidate];
}

- (void)setPathRef:(CGPathRef)pathRef
{
    if (_pathRef != nil) {
        CGPathRelease(pathRef);
    }
    
    _pathRef = CGPathRetain(pathRef);
    [self _invalidate];
}

- (void)setSize:(CGSize)size
{
    [super setSize:size];
    [self _invalidate];
}

@end
