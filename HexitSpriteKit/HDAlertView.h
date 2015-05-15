//
//  HDAlertView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 5/4/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import UIKit;

#import "HDLayoverView.h"

@interface HDAlertView : HDLayoverView
- (instancetype)initWithTitle:(NSString *)title
                  description:(NSString *)description
                  buttonTitle:(NSString *)buttonTitle
                        image:(UIImage *)image;
@end
