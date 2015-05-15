//
//  HDHexagonView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDHexaButton : UIButton
@property (nonatomic, assign) HDLevelState levelState;
@property (nonatomic, assign) NSInteger row;
- (instancetype)initWithLevelState:(HDLevelState)levelState;
- (instancetype)initWithImage:(UIImage *)image
                  shadowImage:(UIImage *)shadowImage;
@end
