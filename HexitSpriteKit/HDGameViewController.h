//
//  ViewController.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>
@import SpriteKit;

@interface HDGameViewController : UIViewController
@property (nonatomic, assign) BOOL pauseGame;
- (void)performExitAnimationWithCompletion:(dispatch_block_t)completion;
- (instancetype)initWithLevel:(NSInteger)level;
- (IBAction)restart:(id)sender;
@end

