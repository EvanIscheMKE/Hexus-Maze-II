//
//  HDAlertNode.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/22/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDAlertNode.h"
#import "SKColor+HDColor.h"
#import "UIColor+FlatColors.h"

@interface HDAlertNode ()

@property (nonatomic , strong) SKSpriteNode *container;

@property (nonatomic , strong) SKSpriteNode *leftButton;
@property (nonatomic , strong) SKSpriteNode *rightButton;

@end

@implementation HDAlertNode

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size]) {
        
        [self setAnchorPoint:CGPointMake(.5f, .5f)];
        
         self.container = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[self alertContainer]]];
        [self.container setAnchorPoint:CGPointMake(.5f, .5f)];
        [self addChild:self.container];
        
         self.leftButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[self leftAlertButton]]];
        [self.leftButton setAnchorPoint:CGPointZero];
        [self.leftButton setPosition:CGPointMake( -(CGRectGetWidth(self.container.frame) / 2),
                                                  -(CGRectGetHeight(self.container.frame) / 2))];
        [self.container addChild:self.leftButton];
        
         self.rightButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[self rightAlertButton]]];
        [self.rightButton setAnchorPoint:CGPointZero];
        [self.rightButton setPosition:CGPointMake( -35.0f, -(CGRectGetHeight(self.container.frame) / 2))];
        [self.container addChild:self.rightButton];
        
        SKSpriteNode *display = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[self displayImage]]];
        [display setAnchorPoint:CGPointMake(0.5f, 0.5f)];
        [display setPosition:CGPointMake(0.0, 50.0f)];
        [self.container addChild:display];
        
        SKLabelNode *levelLabel = [[SKLabelNode alloc] initWithFontNamed:@"GillSans-Light"];
        [levelLabel setPosition:CGPointMake(0.0f, CGRectGetHeight(self.container.frame) / 2 - 5.0f)];
        [levelLabel setFontSize:24.0f];
        [levelLabel setFontColor:color];
        [levelLabel setText:[NSString stringWithFormat:@"Level %ld", [ADelegate previousLevel]]];
        [levelLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [levelLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeTop];
        [self.container addChild:levelLabel];
        
    }
    return self;
}

- (void)showAlertNode
{
    [self runAction:[SKAction moveTo:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)
                            duration:.3f]];
}

- (void)dismissAlertNode
{
    
}

- (UIImage *)displayImage
{
    CGRect containerRect = CGRectMake(0.0f, 0.0f, 140.0f, 140.0f);
    UIGraphicsBeginImageContext(containerRect.size);
    
    [[UIColor flatPeterRiverColor] setFill];
    
    UIBezierPath *container = [UIBezierPath bezierPathWithOvalInRect:containerRect];
    
    [container addClip];
    [container fill];
    
    UIImage *circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return circle;

}

- (UIImage *)rightAlertButton
{
    CGRect containerRect = CGRectMake(0.0f, 0.0f, 180.0f, 90.0f);
    UIGraphicsBeginImageContext(containerRect.size);
    
    [[UIColor flatTurquoiseColor] setFill];
    
    UIBezierPath *container = [UIBezierPath bezierPathWithRoundedRect:containerRect
                                                    byRoundingCorners:UIRectCornerBottomRight
                                                          cornerRadii:CGSizeMake(15.0f, 15.0f)];
    
    
    [container addClip];
    [container fill];
    
    UIImage *texture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return texture;
}

- (UIImage *)leftAlertButton
{
    CGRect containerRect = CGRectMake(0.0f, 0.0f, 110.0f, 90.0f);
    UIGraphicsBeginImageContext(containerRect.size);
    
    [[UIColor flatPeterRiverColor] setFill];
    
    UIBezierPath *container = [UIBezierPath bezierPathWithRoundedRect:containerRect
                                                    byRoundingCorners:UIRectCornerBottomLeft
                                                          cornerRadii:CGSizeMake(15.0f, 15.0f)];
                              
    
    [container addClip];
    [container fill];
    
    UIImage *texture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return texture;
}

- (UIImage *)alertContainer
{
    
    CGRect containerRect = CGRectMake(0.0f, 0.0f, 290.0f, 400.0f);
    UIGraphicsBeginImageContext(containerRect.size);
    
    [[UIColor flatSilverColor] setFill];
    
    UIBezierPath *container = [UIBezierPath bezierPathWithRoundedRect:containerRect cornerRadius:15.0f];
    
    [container addClip];
    [container fill];
    
    UIImage *texture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return texture;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch     = [touches anyObject];
    CGPoint location   = [touch locationInNode:self];
    SKSpriteNode *node = (SKSpriteNode *)[self nodeAtPoint:location];
}

@end
