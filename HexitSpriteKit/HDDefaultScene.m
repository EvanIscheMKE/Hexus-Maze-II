//
//  HDDefaultScene.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 3/16/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDDefaultScene.h"
#import "SKColor+HDColor.h"

@implementation HDDefaultScene

- (instancetype)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor flatMidnightBlueColor];
        [self _setupBackgroundEmitters];
    }
    return self;
}

- (void)_setupBackgroundEmitters {
    
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"Space" ofType:@"sks"];
    self.space = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.space.particleColor = [SKColor whiteColor];
    self.space.particleColorSequence = nil;
    [self.space advanceSimulationTime:10.0f];
    self.space.position = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame));
    [self addChild:self.space];
}

- (void)update:(NSTimeInterval)currentTime {
    if (self.space) {
        NSArray *colors = @[[SKColor flatPeterRiverColor],
                            [SKColor whiteColor],
                            [SKColor flatEmeraldColor],
                            [SKColor flatAlizarinColor],
                            [SKColor flatSilverColor]];
        self.space.particleColor = [colors objectAtIndex:arc4random() % colors.count];
    }
}

@end
