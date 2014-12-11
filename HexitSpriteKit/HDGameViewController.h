//
//  ViewController.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDGameViewController : UIViewController

@property (nonatomic, assign) BOOL navigationBarHidden;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, readonly) NSInteger level;

- (instancetype)initWithLevel:(NSInteger)level;
- (instancetype)initWithRandomlyGeneratedLevel;

- (void)restartGame;

@end

