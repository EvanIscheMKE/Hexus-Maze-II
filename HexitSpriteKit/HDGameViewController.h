//
//  ViewController.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDGameViewController : UIViewController
@property (nonatomic, readonly) NSInteger level;
- (instancetype)initWithLevel:(NSInteger)level;
- (void)showAlertWithTitle:(NSString *)title
               description:(NSString *)descripton
                       tag:(NSInteger)tag
                  delegate:(id<UIAlertViewDelegate>)delegate;
@end

