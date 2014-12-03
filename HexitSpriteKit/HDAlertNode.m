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

@interface HDAlertNode ()
@property (nonatomic, strong) SKShapeNode *container;
@property (nonatomic, strong) SKShapeNode *topButton;
@property (nonatomic, strong) SKShapeNode *bottomButton;
@end

@implementation HDAlertNode

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size completion:(BOOL)completion
{
    if (self = [super initWithColor:[SKColor flatMidnightBlueColor] size:size]) {
        
        [self setAnchorPoint:CGPointMake(.5f, .5f)];
        
        CGRect containerFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame)-20.0f, CGRectGetWidth(self.frame)-20.0f);
         self.container = [SKShapeNode shapeNodeWithPath:[HDHelper hexagonPathForBounds:containerFrame] centered:YES];
        [self.container setPosition:CGPointMake(0.0f, 0.0f)];
        [self.container setFillColor:[SKColor flatAsbestosColor]];
        [self.container setLineWidth:0];
        [self.container setZPosition:100.0f];
        [self addChild:self.container];
        
        /*      subclass     */
        CGRect topButtonFrame = CGRectMake(0.0f, 0.0, 160.0f, 35.0f);
        CGPathRef path = [[UIBezierPath bezierPathWithRoundedRect:topButtonFrame cornerRadius:CGRectGetMidY(topButtonFrame)] CGPath];
         self.topButton = [SKShapeNode shapeNodeWithPath:path centered:YES];
        [self.topButton setFillColor:[SKColor flatPeterRiverColor]];
        [self.topButton setLineWidth:0.0f];
        [self.topButton setName:@"Top"];
        [self.topButton setPosition:CGPointMake(0.0, -60.0f)];
        [self.container addChild:self.topButton];
        
        SKLabelNode *topLabel = [[SKLabelNode alloc] initWithFontNamed:@"GillSans-Light"];
        [topLabel setPosition:CGPointMake(0.0f, CGRectGetHeight(self.container.frame) / 2.75)];
        [topLabel setFontSize:28.0f];
        [topLabel setFontColor:[SKColor flatMidnightBlueColor]];
        [topLabel setText:[NSString stringWithFormat:@"Level %ld",[ADelegate previousLevel]]];
        [topLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [topLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeTop];
        [self.topButton addChild:topLabel];
        /*      end    */
        
        /*      subclass     */
         self.bottomButton = [SKShapeNode shapeNodeWithPath:path centered:YES];
        [self.bottomButton setFillColor:[SKColor flatEmeraldColor]];
        [self.bottomButton setLineWidth:0.0f];
        [self.bottomButton setName:@"Bottom"];
        [self.bottomButton setPosition:CGPointMake(0.0, -100.0f)];
        [self.container addChild:self.bottomButton];
        
        SKLabelNode *bottomLabel = [[SKLabelNode alloc] initWithFontNamed:@"GillSans-Light"];
        [bottomLabel setPosition:CGPointMake(0.0f, CGRectGetHeight(self.container.frame) / 2.75)];
        [bottomLabel setFontSize:28.0f];
        [bottomLabel setFontColor:[SKColor flatMidnightBlueColor]];
        [bottomLabel setText:[NSString stringWithFormat:@"Level %ld",[ADelegate previousLevel]]];
        [bottomLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [bottomLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeTop];
        [self.bottomButton addChild:bottomLabel];
        /*      end     */
        
        SKLabelNode *levelLabel = [[SKLabelNode alloc] initWithFontNamed:@"GillSans-Light"];
        [levelLabel setPosition:CGPointMake(0.0f, CGRectGetHeight(self.container.frame) / 2.75)];
        [levelLabel setFontSize:28.0f];
        [levelLabel setFontColor:[SKColor flatMidnightBlueColor]];
        [levelLabel setText:[NSString stringWithFormat:@"Level %ld", [ADelegate previousLevel]]];
        [levelLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [levelLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeTop];
        [self.container addChild:levelLabel];
        
    }
    return self;
}

- (void)show
{
//    [self runAction:[SKAction moveTo:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)
//                            duration:.3f]];
}

- (void)dismiss
{
    
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
    
    if ([node.name isEqualToString:@"Top"]) {
        
    } else if ([node.name isEqualToString:@"Bottom"]) {
        
    }
}

@end
