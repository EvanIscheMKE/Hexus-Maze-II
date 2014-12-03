//
//  HDGridMenu.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/1/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDGridMenu : UIView
@property (nonatomic, copy) dispatch_block_t completion;
@property (nonatomic, strong) UIButton *beginGame;

- (instancetype)initWithFrame:(CGRect)frame level:(NSInteger)level;
- (void)show;
- (void)dismiss;
@end
