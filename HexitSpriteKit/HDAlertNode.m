//
//  HDAlertNode.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/22/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDAlertNode.h"
#import "SKColor+HDColor.h"
#import "UIColor+FlatColors.h"

NSString * const RIGHT_BUTTON_KEY = @"RightButtonKey";
NSString * const LEFT_BUTTON_KEY  = @"LeftButtonKey";

@interface HDAlertNode ()

@property (nonatomic, strong) SKShapeNode *container;

@property (nonatomic, strong) SKSpriteNode *rightButton;
@property (nonatomic, strong) SKSpriteNode *leftButton;
@property (nonatomic, strong) SKSpriteNode *stripe;

@property (nonatomic, strong) SKLabelNode *descriptionLabel;
@property (nonatomic, strong) SKLabelNode *activityLabel;

@property (nonatomic, strong) SKShapeNode *button;
@property (nonatomic, strong) SKShapeNode *star;

@end

@implementation HDAlertNode

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size]) {
        
        [self setAnchorPoint:CGPointMake(.5f, .5f)];
        [self setUserInteractionEnabled:YES];
        
        CGRect containerFrame = CGRectInset(self.frame, 25.0f, 110.0f);
         self.container = [SKShapeNode shapeNodeWithPath:[[UIBezierPath bezierPathWithRoundedRect:containerFrame cornerRadius:15.0f] CGPath]
                                                centered:YES];
        [self.container setPosition:CGPointMake(CGRectGetWidth(self.frame), 0.0f)];
        [self.container setAntialiased:YES];
        [self.container setFillColor:[[SKColor flatCloudsColor] colorWithAlphaComponent:1.0f]];
        [self.container setLineWidth:0];
        [self.container setZPosition:100.0f];
        [self addChild:self.container];
        
        [self _layoutStarProgressNodes];
        [self _layoutMenuButtons];
        [self _layoutDisplayBar];
        [self _layoutLabels];
        
    }
    return self;
}

#pragma mark -
#pragma mark - <PUBLIC>

- (void)show
{
    [self.container runAction:[SKAction moveToX:0.0f duration:.3f] completion:^{
        [self.star runAction:[SKAction sequence:@[[SKAction scaleTo:1.3 duration:.4f],[SKAction scaleTo:1.0f duration:.2f]]]];
    }];
}

- (void)dismissWithCompletion:(dispatch_block_t)completion
{
    [self.container runAction:[SKAction moveToX:CGRectGetWidth(self.frame) duration:.3f] completion:^{
        [self removeFromParent];
        if (completion) {
            completion();
        }
    }];
}

#pragma mark -
#pragma mark - <PRIVATE>

- (void)_layoutStarProgressNodes
{
    CGPathRef middleStarPath = [HDHelper starPathForBounds:CGRectMake(0.0f, 0.0, 140.0f, 140.0f)];
    self.star = [SKShapeNode shapeNodeWithPath:middleStarPath centered:YES];
    [self.star setPosition:CGPointMake(0.0f, 90.0f)];
    [self.star setStrokeColor:[SKColor flatEmeraldColor]];
    [self.star setScale:0.0f];
    [self.star setLineWidth:2.0f];
    [self.star setFillColor:[SKColor flatEmeraldColor]];
    [self.container addChild:self.star];
}

- (void)_layoutMenuButtons
{
    UIImage *nextLevelImage = [self _nextLevelImageTexture];
    self.rightButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:nextLevelImage]];
    [self.rightButton setName:RIGHT_BUTTON_KEY];
    [self.rightButton setAnchorPoint:CGPointMake(.0f, .5f)];
    [self.rightButton setPosition:CGPointMake(CGRectGetWidth(self.container.frame)/2  - CGRectGetWidth(self.container.frame)/1.5,
                                              -(CGRectGetHeight(self.container.frame)/2 - nextLevelImage.size.height/2))];
    [self.container addChild:self.rightButton];
    
    UIImage *menuButtonImage = [self _restartButtonTexture];
    self.leftButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:menuButtonImage]];
    [self.leftButton setName:LEFT_BUTTON_KEY];
    [self.leftButton setAnchorPoint:CGPointMake(.0f, .5f)];
    [self.leftButton setPosition:CGPointMake( -(CGRectGetWidth(self.container.frame)/2),
                                             -(CGRectGetHeight(self.container.frame)/2 - nextLevelImage.size.height/2))];
    [self.container addChild:self.leftButton];
}

- (void)_layoutDisplayBar
{
    CGPoint stripePosition = CGPointMake(0.0f, CGRectGetMaxY(self.rightButton.frame) + 45.0f);
    self.stripe = [SKSpriteNode spriteNodeWithColor:[SKColor flatAsbestosColor]
                                               size:CGSizeMake(CGRectGetWidth(self.container.frame), 90.0f)];
    [self.stripe setName:LEFT_BUTTON_KEY];
    [self.stripe setPosition:stripePosition];
    [self.container addChild:self.stripe];
    
     self.button = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(200.0f, 46.0f) cornerRadius:20.0f];
    [self.button setFillColor:[SKColor flatMidnightBlueColor]];
    [self.button setName:@"activityButton"];
    [self.button setLineWidth:0.0f];
    [self.button setPosition:CGPointMake(0.0, 0.0f)];
    [self.stripe addChild:self.button];
    
    CGPoint descriptionCenter = CGPointMake(0.0f, 0.0);
     self.activityLabel = [SKLabelNode labelNodeWithText:@"Leave a Review"];
    [self.activityLabel setName:@"activityButton"];
    [self.activityLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    [self.activityLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [self.activityLabel setFontColor:[SKColor whiteColor]];
    [self.activityLabel setFontName:@"GillSans-Light"];
    [self.activityLabel setFontSize:20.0f];
    [self.activityLabel setPosition:descriptionCenter];
    [self.button addChild:self.activityLabel];
}

- (void)_layoutLabels
{
    CGPoint descriptionCenter = CGPointMake(0.0f, CGRectGetMaxY(self.stripe.frame) + 12.0f);
    self.descriptionLabel = [SKLabelNode labelNodeWithText:@"Amazing job!"];
    [self.descriptionLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    [self.descriptionLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [self.descriptionLabel setFontColor:[SKColor flatMidnightBlueColor]];
    [self.descriptionLabel setFontName:@"GillSans-Light"];
    [self.descriptionLabel setFontSize:18.0f];
    [self.descriptionLabel setPosition:descriptionCenter];
    [self.container addChild:self.descriptionLabel];
    
    self.levelLabel = [[SKLabelNode alloc] initWithFontNamed:@"GillSans-Light"];
    [self.levelLabel setPosition:CGPointMake(0.0f, CGRectGetHeight(self.container.frame) / 2.5)];
    [self.levelLabel setFontSize:28.0f];
    [self.levelLabel setFontColor:[SKColor flatMidnightBlueColor]];
    [self.levelLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    [self.levelLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeBottom];
    [self.container addChild:self.levelLabel];
}

#pragma mark -
#pragma mark - images for textures

- (UIImage *)_restartButtonTexture
{
    static UIImage *menuButton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGRect imageFrame = CGRectMake(
                                       0.0f,
                                       0.0f,
                                       CGRectGetWidth(self.container.frame) / 3,
                                       100.0f
                                       );
        
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, [[UIScreen mainScreen] scale]);
        
        
        UIBezierPath *button = [UIBezierPath bezierPathWithRoundedRect:imageFrame
                                                     byRoundingCorners:UIRectCornerBottomLeft
                                                           cornerRadii:CGSizeMake(15.0f, 15.0f)];
        [button addClip];

        menuButton = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return menuButton;
}

- (UIImage *)_nextLevelImageTexture
{
    static UIImage *nextLevel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGRect imageFrame = CGRectMake(
                                       0.0f,
                                       0.0f,
                                       CGRectGetWidth(self.container.frame) / 1.5,
                                       100.0f
                                       );
        
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, [[UIScreen mainScreen] scale]);
        
        [[UIColor flatEmeraldColor] setFill];
        UIBezierPath *button = [UIBezierPath bezierPathWithRoundedRect:imageFrame
                                                     byRoundingCorners:UIRectCornerBottomRight
                                                           cornerRadii:CGSizeMake(15.0f, 15.0f)];
        [button fill];
        [button addClip];
        
        [[UIColor whiteColor] setStroke];
        
        CGFloat kPointX[2];
        kPointX[0] = 90.0f;
        kPointX[1] = 105.0f;
        
        CGFloat kPoint1X[2];
        kPoint1X[0] = 115.0f;
        kPoint1X[1] = 130.0f;
        
        for (int i = 0; i < 2; i++) {
            
            UIBezierPath *rightArrow = [UIBezierPath bezierPath];
            [rightArrow setLineWidth:8.0f];
            [rightArrow setLineCapStyle:kCGLineCapRound];
            [rightArrow moveToPoint:   CGPointMake(kPointX[i], 30.0f)];
            [rightArrow addLineToPoint:CGPointMake(kPoint1X[i], CGRectGetHeight(imageFrame)/2)];
            [rightArrow addLineToPoint:CGPointMake(kPointX[i],  CGRectGetHeight(imageFrame) - 30.0f)];
            [rightArrow stroke];
            
        }
        
        nextLevel = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return nextLevel;
}

#pragma mark -
#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKNode *node = [self nodeAtPoint:location];

    if (self.delegate && [self.delegate respondsToSelector:@selector(alertNode:clickedButtonAtIndex:)]) {
        if ([node.name isEqualToString:RIGHT_BUTTON_KEY]) {
            [self setName:RIGHT_BUTTON_KEY];
            [self.delegate alertNodeWillDismiss:self];
            [self dismissWithCompletion:^{
                 [self.delegate alertNode:self clickedButtonAtIndex:0];
            }];
        } else if ([node.name isEqualToString:LEFT_BUTTON_KEY]) {
            [self setName:LEFT_BUTTON_KEY];
            [self.delegate alertNodeWillDismiss:self];
            [self dismissWithCompletion:^{
                 [self.delegate alertNode:self clickedButtonAtIndex:1];
            }];
        } else if ([node.name isEqualToString:@"activityButton"]) {
            [self setName:@"activityButton"];
            [self.delegate alertNode:self clickedButtonAtIndex:2];
        }
    }
}

@end
